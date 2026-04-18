import subprocess
import sys
import tkinter as tk
from tkinter import ttk, messagebox, filedialog
from pathlib import Path
from config import load_config, save_config

class SimpyNoCGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("SimpyNoC")
        self.root.geometry("900x820")
        self.root.resizable(True, True)

        self.script_dir = Path(__file__).resolve().parent
        self.project_root = self.script_dir.parent.parent
        self.embedded_apps_dir = self.project_root / "embedded_app_graphs"
        self.simpynoc_dir = self.project_root / "simpynoc"
        self.app_file_path = None
        self.map_file_path = None
        self.last_config_file = None
        
        # Configure style
        style = ttk.Style()
        style.theme_use('clam')
        
        # Create main notebook (tabs)
        self.notebook = ttk.Notebook(root)
        self.notebook.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Create tabs
        self.create_input_files_tab()
        self.create_noc_parameters_tab()
        self.create_simulation_tab()
        
        # Create bottom button frame
        self.create_button_frame()
        
        # Load default config
        self.load_config_values(load_config())
        
    def create_input_files_tab(self):
        """Input Files tab"""
        frame = ttk.Frame(self.notebook)
        self.notebook.add(frame, text="📁 Input Files")

        ttk.Label(frame, text="Input Files", font=('Arial', 12, 'bold')).pack(pady=10)

        files_frame = ttk.LabelFrame(frame, text="Application & Mapping Files")
        files_frame.pack(padx=20, pady=10, fill=tk.BOTH)

        ttk.Label(files_frame, text="Application File (.app):").pack(anchor=tk.W, padx=10, pady=5)
        app_frame = ttk.Frame(files_frame)
        app_frame.pack(padx=10, pady=5, fill=tk.X)

        self.app_file = ttk.Combobox(app_frame, width=45, state="readonly")
        app_values = sorted([p.name for p in self.embedded_apps_dir.glob("*.app")]) if self.embedded_apps_dir.exists() else []
        self.app_file["values"] = app_values
        self.app_file.set(app_values[0] if app_values else "")
        self.app_file.pack(side=tk.LEFT, fill=tk.X, expand=True)
        self.app_file.bind("<<ComboboxSelected>>", lambda e: self._load_app_file_preview())

        ttk.Button(app_frame, text="Browse", width=12, command=self.browse_app_file).pack(side=tk.LEFT, padx=5)

        ttk.Label(files_frame, text="Mapping File (.map):").pack(anchor=tk.W, padx=10, pady=5)
        map_frame = ttk.Frame(files_frame)
        map_frame.pack(padx=10, pady=5, fill=tk.X)

        self.map_file = ttk.Entry(map_frame, width=46)
        self.map_file.insert(0, "mpeg4_mapping.map")
        self.map_file.pack(side=tk.LEFT, fill=tk.X, expand=True)
        self.map_file.bind("<KeyRelease>", lambda e: self._load_map_file_preview())

        ttk.Button(map_frame, text="Browse", width=12, command=self.browse_map_file).pack(side=tk.LEFT, padx=5)

        # File visualizers - side by side
        preview_container = ttk.Frame(frame)
        preview_container.pack(padx=20, pady=10, fill=tk.BOTH, expand=True)

        # Application file visualizer
        app_preview_frame = ttk.LabelFrame(preview_container, text="Application File Preview")
        app_preview_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(0, 5))

        app_scrollbar = ttk.Scrollbar(app_preview_frame)
        app_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        self.app_preview_text = tk.Text(app_preview_frame, height=12, yscrollcommand=app_scrollbar.set, font=("Courier", 9))
        self.app_preview_text.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        app_scrollbar.config(command=self.app_preview_text.yview)

        # Mapping file visualizer
        map_preview_frame = ttk.LabelFrame(preview_container, text="Mapping File Preview")
        map_preview_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(5, 0))

        map_scrollbar = ttk.Scrollbar(map_preview_frame)
        map_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        self.map_preview_text = tk.Text(map_preview_frame, height=12, yscrollcommand=map_scrollbar.set, font=("Courier", 9))
        self.map_preview_text.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        map_scrollbar.config(command=self.map_preview_text.yview)

        # Load initial previews
        self._load_app_file_preview()
        self._load_map_file_preview()

    def create_noc_parameters_tab(self):
        """NoC parameters tab"""
        frame = ttk.Frame(self.notebook)
        self.notebook.add(frame, text="🛠️ NoC Parameters")

        ttk.Label(frame, text="NoC Parameters", font=('Arial', 12, 'bold')).pack(pady=10)

        routing_frame = ttk.LabelFrame(frame, text="Routing Algorithms")
        routing_frame.pack(padx=20, pady=10, fill=tk.X)

        self.routing_vars = {}
        algorithms = ["XY", "NEGATIVE_FIRST", "WEST_FIRST", "NORTH_LEAST"]
        for algo in algorithms:
            var = tk.BooleanVar(value=True)
            self.routing_vars[algo] = var
            ttk.Checkbutton(routing_frame, text=algo, variable=var).pack(anchor=tk.W, padx=10, pady=2)

        arbiter_frame = ttk.LabelFrame(frame, text="Arbiter Strategy")
        arbiter_frame.pack(padx=20, pady=10, fill=tk.X)

        ttk.Label(arbiter_frame, text="Select Arbiter Strategy:").pack(anchor=tk.W, padx=10, pady=5)
        self.arbiter_strategy = ttk.Combobox(arbiter_frame, values=["ROUND_ROBIN", "PRIORITY"], state="readonly")
        self.arbiter_strategy.set("ROUND_ROBIN")
        self.arbiter_strategy.pack(fill=tk.X, padx=10, pady=5)

        topology_frame = ttk.LabelFrame(frame, text="Topology")
        topology_frame.pack(padx=20, pady=10, fill=tk.X)

        ttk.Label(topology_frame, text="Topology:").pack(anchor=tk.W, padx=10, pady=5)
        self.topology = ttk.Combobox(topology_frame, values=["MESH"], state="readonly")
        self.topology.set("MESH")
        self.topology.pack(fill=tk.X, padx=10, pady=5)

        mesh_frame = ttk.LabelFrame(frame, text="Mesh Size")
        mesh_frame.pack(padx=20, pady=10, fill=tk.X)

        ttk.Label(mesh_frame, text="Rows:").grid(row=0, column=0, sticky=tk.W, padx=10, pady=5)
        self.mesh_rows_spinbox = ttk.Spinbox(mesh_frame, from_=2, to=16, increment=1, width=6)
        self.mesh_rows_spinbox.set(6)
        self.mesh_rows_spinbox.grid(row=0, column=1, sticky=tk.W, padx=10, pady=5)

        ttk.Label(mesh_frame, text="Columns:").grid(row=0, column=2, sticky=tk.W, padx=(20, 10), pady=5)
        self.mesh_cols_spinbox = ttk.Spinbox(mesh_frame, from_=2, to=16, increment=1, width=6)
        self.mesh_cols_spinbox.set(6)
        self.mesh_cols_spinbox.grid(row=0, column=3, sticky=tk.W, padx=10, pady=5)

        buffer_frame = ttk.LabelFrame(frame, text="Buffer Configuration")
        buffer_frame.pack(padx=20, pady=10, fill=tk.X)

        depth_frame = ttk.Frame(buffer_frame)
        depth_frame.pack(fill=tk.X, padx=10, pady=5)
        ttk.Label(depth_frame, text="Buffers depth:").pack(side=tk.LEFT)
        self.buffers_depth_spinbox = ttk.Spinbox(depth_frame, from_=1, to=100, increment=1, width=10)
        self.buffers_depth_spinbox.set(4)
        self.buffers_depth_spinbox.pack(side=tk.LEFT, padx=10)

    def create_simulation_tab(self):
        """Simulation configuration tab"""
        frame = ttk.Frame(self.notebook)
        self.notebook.add(frame, text="🚀 Simulation")

        ttk.Label(frame, text="Simulation Settings", font=('Arial', 12, 'bold')).pack(pady=10)

        injection_frame = ttk.LabelFrame(frame, text="Packet Injection Strategy")
        injection_frame.pack(padx=20, pady=10, fill=tk.X)

        ttk.Label(injection_frame, text="Strategy:").pack(anchor=tk.W, padx=10, pady=5)
        self.injection_strategy = ttk.Combobox(injection_frame, values=["LINEAR", "BURST"], state="readonly")
        self.injection_strategy.set("LINEAR")
        self.injection_strategy.pack(fill=tk.X, padx=10, pady=5)

        cycles_frame = ttk.LabelFrame(frame, text="Simulation Time")
        cycles_frame.pack(padx=20, pady=10, fill=tk.X)

        cycle_row = ttk.Frame(cycles_frame)
        cycle_row.pack(fill=tk.X, padx=10, pady=5)
        ttk.Label(cycle_row, text="Max Number of Cycles:").pack(side=tk.LEFT)
        self.sim_steps_spinbox = ttk.Spinbox(cycle_row, from_=100, to=10000, increment=100, width=10)
        self.sim_steps_spinbox.set(500)
        self.sim_steps_spinbox.pack(side=tk.LEFT, padx=10)

        traffic_frame = ttk.LabelFrame(frame, text="Traffic Range")
        traffic_frame.pack(padx=20, pady=10, fill=tk.X)

        range_subframe = ttk.Frame(traffic_frame)
        range_subframe.pack(fill=tk.X, padx=10, pady=5)
        ttk.Label(range_subframe, text="Start (%):").grid(row=0, column=0, sticky=tk.W)
        self.traffic_start_entry = ttk.Entry(range_subframe, width=10)
        self.traffic_start_entry.insert(0, "0.0")
        self.traffic_start_entry.grid(row=0, column=1, sticky=tk.W, padx=5)

        ttk.Label(range_subframe, text="End (%):").grid(row=0, column=2, sticky=tk.W, padx=(20,5))
        self.traffic_end_entry = ttk.Entry(range_subframe, width=10)
        self.traffic_end_entry.insert(0, "5.0")
        self.traffic_end_entry.grid(row=0, column=3, sticky=tk.W)

        steps_frame = ttk.LabelFrame(frame, text="Traffic Steps")
        steps_frame.pack(padx=20, pady=10, fill=tk.X)

        steps_row = ttk.Frame(steps_frame)
        steps_row.pack(fill=tk.X, padx=10, pady=5)
        ttk.Label(steps_row, text="Number of Steps:").pack(side=tk.LEFT)
        self.traffic_steps_spinbox = ttk.Spinbox(steps_row, from_=5, to=100, increment=1, width=6)
        self.traffic_steps_spinbox.set(20)
        self.traffic_steps_spinbox.pack(side=tk.LEFT, padx=10)

        summary_frame = ttk.LabelFrame(frame, text="Configuration Summary")
        summary_frame.pack(padx=20, pady=10, fill=tk.BOTH, expand=True)

        scrollbar = ttk.Scrollbar(summary_frame)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        self.summary_text = tk.Text(summary_frame, height=12, yscrollcommand=scrollbar.set)
        self.summary_text.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        scrollbar.config(command=self.summary_text.yview)

        ttk.Button(frame, text="Refresh Summary", command=self.update_summary).pack(pady=5)

    def create_button_frame(self):
        """Bottom button frame"""
        btn_frame = ttk.Frame(self.root)
        btn_frame.pack(side=tk.BOTTOM, fill=tk.X, padx=10, pady=10)
        
        ttk.Button(btn_frame, text="💾 Save Configuration", command=self.save_config_action).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="📖 Load Configuration", command=self.load_config_action).pack(side=tk.LEFT, padx=5)
        
        run_btn = tk.Button(btn_frame, text="🚀 Run Simulation", command=self.run_simulation,
                           bg="#4CAF50", fg="white", font=("Arial", 10, "bold"), padx=15, pady=5)
        run_btn.pack(side=tk.LEFT, padx=5)
        
        ttk.Button(btn_frame, text="❌ Exit", command=self.root.quit).pack(side=tk.RIGHT, padx=5)

    def get_config(self):
        """Get current configuration"""
        selected_algorithms = [algo for algo, var in self.routing_vars.items() if var.get()]
        
        if not selected_algorithms:
            messagebox.showerror("Error", "Please select at least one routing algorithm!")
            return None
        
        try:
            mesh_rows = int(self.mesh_rows_spinbox.get())
            mesh_cols = int(self.mesh_cols_spinbox.get())
            sim_steps = int(self.sim_steps_spinbox.get())
            buffers_depth = int(self.buffers_depth_spinbox.get())
            traffic_steps = int(self.traffic_steps_spinbox.get())
            traffic_start = float(self.traffic_start_entry.get()) / 100
            traffic_end = float(self.traffic_end_entry.get()) / 100
        except ValueError:
            messagebox.showerror("Error", "Please enter valid numeric values for mesh size, cycles, traffic, and steps.")
            return None
        
        if self.app_file_path and Path(self.app_file_path).exists():
            application_file = self.app_file_path
        else:
            application_file = str(self.embedded_apps_dir / self.app_file.get())
        
        if self.map_file_path and Path(self.map_file_path).exists():
            mapping_file = self.map_file_path
        else:
            candidate_map = self.simpynoc_dir / "maps" / self.map_file.get()
            if candidate_map.exists():
                mapping_file = str(candidate_map)
            else:
                candidate_map = self.simpynoc_dir / self.map_file.get()
                mapping_file = str(candidate_map if candidate_map.exists() else self.map_file.get())
        
        config = {
            "mesh_size": [mesh_rows, mesh_cols],
            "simulation_steps": sim_steps,
            "buffers_depth": buffers_depth,
            "traffic_steps": traffic_steps,
            "traffic_start": traffic_start,
            "traffic_end": traffic_end,
            "application_file": application_file,
            "mapping_file": mapping_file,
            "routing_algorithms": selected_algorithms,
            "arbiter_strategy": self.arbiter_strategy.get(),
            "topology": self.topology.get(),
            "injection_strategy": self.injection_strategy.get()
        }
        
        return config
    
    def update_summary(self):
        """Update the summary display"""
        config = self.get_config()
        if not config:
            return
        
        self.summary_text.delete(1.0, tk.END)
        summary = "SIMULATION CONFIGURATION\n"
        summary += "=" * 50 + "\n\n"
        summary += "Input Files:\n"
        summary += f"  Application File: {config['application_file']}\n"
        summary += f"  Mapping File: {config['mapping_file']}\n\n"
        summary += "NoC Parameters:\n"
        summary += f"  Topology: {config['topology']}\n"
        summary += f"  Arbiter Strategy: {config['arbiter_strategy']}\n"
        summary += f"  Mesh Size: {config['mesh_size'][0]} x {config['mesh_size'][1]}\n"
        summary += f"  Buffers depth: {config['buffers_depth']}\n\n"
        summary += "Simulation Settings:\n"
        summary += f"  Packet Injection Strategy: {config['injection_strategy']}\n"
        summary += f"  Max Cycles: {config['simulation_steps']}\n"
        summary += f"  Traffic Range: {config['traffic_start']*100:.1f}% - {config['traffic_end']*100:.1f}%\n"
        summary += f"  Traffic Steps: {config['traffic_steps']}\n\n"
        summary += f"Routing Algorithms ({len(config['routing_algorithms'])}):\n"
        for algo in config['routing_algorithms']:
            summary += f"  ✓ {algo}\n"
        
        self.summary_text.insert(tk.END, summary)
    
    def save_config_action(self):
        """Save configuration to file"""
        config = self.get_config()
        if not config:
            return

        file_path = filedialog.asksaveasfilename(
            defaultextension=".json",
            filetypes=[("JSON files", "*.json"), ("All files", "*.*")],
            initialfile="simulation_config.json",
            initialdir=self.script_dir
        )
        if not file_path:
            return

        if save_config(config, file_path):
            self.last_config_file = file_path
            run_command = f'"{sys.executable}" "{self.script_dir / "main.py"}" --config "{self.last_config_file}"'
            messagebox.showinfo(
                "Success",
                f"Configuration saved to {Path(file_path).name}\n\nRun this command in terminal:\n{run_command}"
            )
        else:
            messagebox.showerror("Error", "Failed to save configuration")
    
    def load_config_action(self):
        """Load configuration from file"""
        file_path = filedialog.askopenfilename(
            defaultextension=".json",
            filetypes=[("JSON files", "*.json"), ("All files", "*.*")],
            initialdir=self.script_dir
        )
        
        if file_path:
            config = load_config(file_path)
            self.last_config_file = file_path
            self.load_config_values(config)
            messagebox.showinfo("Success", f"Configuration loaded from {Path(file_path).name}")

    def _resolve_file_path(self, path_value, search_dirs):
        path = Path(path_value)
        if path.is_absolute() and path.exists():
            return str(path)
        if path.exists():
            return str(path)
        for directory in search_dirs:
            candidate = Path(directory) / path_value
            if candidate.exists():
                return str(candidate)
        return str(path)

    def browse_app_file(self):
        initialdir = self.embedded_apps_dir if self.embedded_apps_dir.exists() else Path.cwd()
        file_path = filedialog.askopenfilename(
            initialdir=initialdir,
            title="Select Application File",
            filetypes=[("Application Files", "*.app"), ("All Files", "*.*")]
        )
        if file_path:
            self.app_file.set(Path(file_path).name)
            self.app_file_path = file_path
            self._load_app_file_preview()

    def browse_map_file(self):
        initialdir = self.simpynoc_dir / "maps" if (self.simpynoc_dir / "maps").exists() else self.simpynoc_dir
        file_path = filedialog.askopenfilename(
            initialdir=initialdir,
            title="Select Mapping File",
            filetypes=[("Mapping Files", "*.map"), ("All Files", "*.*")]
        )
        if file_path:
            self.map_file.delete(0, tk.END)
            self.map_file.insert(0, Path(file_path).name)
            self.map_file_path = file_path
            self._load_map_file_preview()

    def _load_app_file_preview(self):
        """Load and display the selected .app file in the preview area"""
        try:
            app_filename = self.app_file.get()
            if not app_filename:
                self.app_preview_text.delete(1.0, tk.END)
                self.app_preview_text.insert(tk.END, "No application file selected.")
                return
            
            app_path = self.embedded_apps_dir / app_filename
            if not app_path.exists():
                self.app_preview_text.delete(1.0, tk.END)
                self.app_preview_text.insert(tk.END, f"File not found: {app_path}")
                return
            
            with open(app_path, 'r') as f:
                content = f.read()
            
            self.app_preview_text.delete(1.0, tk.END)
            self.app_preview_text.insert(tk.END, content)
        except Exception as e:
            self.app_preview_text.delete(1.0, tk.END)
            self.app_preview_text.insert(tk.END, f"Error loading file: {e}")

    def _load_map_file_preview(self):
        """Load and display the selected .map file in the preview area"""
        try:
            map_filename = self.map_file.get()
            if not map_filename:
                self.map_preview_text.delete(1.0, tk.END)
                self.map_preview_text.insert(tk.END, "No mapping file selected.")
                return
            
            map_path = self.simpynoc_dir / "maps" / map_filename
            if not map_path.exists():
                map_path = self.simpynoc_dir / map_filename
            
            if not map_path.exists():
                self.map_preview_text.delete(1.0, tk.END)
                self.map_preview_text.insert(tk.END, f"File not found: {map_filename}")
                return
            
            with open(map_path, 'r') as f:
                content = f.read()
            
            self.map_preview_text.delete(1.0, tk.END)
            self.map_preview_text.insert(tk.END, content)
        except Exception as e:
            self.map_preview_text.delete(1.0, tk.END)
            self.map_preview_text.insert(tk.END, f"Error loading file: {e}")

    def load_config_values(self, config):
        """Load values into GUI from config dict"""
        self.mesh_rows_spinbox.set(config["mesh_size"][0])
        self.mesh_cols_spinbox.set(config["mesh_size"][1])
        self.sim_steps_spinbox.set(config["simulation_steps"])
        self.buffers_depth_spinbox.set(config.get("buffers_depth", 4))
        self.traffic_steps_spinbox.set(config["traffic_steps"])
        self.traffic_start_entry.delete(0, tk.END)
        self.traffic_start_entry.insert(0, f"{config['traffic_start']*100:.1f}")
        self.traffic_end_entry.delete(0, tk.END)
        self.traffic_end_entry.insert(0, f"{config['traffic_end']*100:.1f}")
        
        self.arbiter_strategy.set(config.get("arbiter_strategy", "ROUND_ROBIN"))
        self.topology.set(config.get("topology", "MESH"))
        self.injection_strategy.set(config.get("injection_strategy", "LINEAR"))
        
        self.app_file_path = self._resolve_file_path(config["application_file"], [self.embedded_apps_dir])
        self.app_file.set(Path(self.app_file_path).name)
        
        self.map_file_path = self._resolve_file_path(config["mapping_file"], [self.simpynoc_dir / "maps", self.simpynoc_dir])
        self.map_file.delete(0, tk.END)
        self.map_file.insert(0, Path(self.map_file_path).name)
        
        for var in self.routing_vars.values():
            var.set(False)
        for algo in config["routing_algorithms"]:
            if algo in self.routing_vars:
                self.routing_vars[algo].set(True)
        
        self.update_summary()
    
    def run_simulation(self):
        """Run simulation with current configuration"""
        config = self.get_config()
        if not config:
            return

        if not self.last_config_file:
            self.last_config_file = str(self.script_dir / "simulation_config.json")

        if save_config(config, self.last_config_file):
            try:
                subprocess.Popen(
                    [sys.executable, str(self.script_dir / "main.py"), "--config", str(self.last_config_file)],
                    cwd=str(self.script_dir)
                )
                messagebox.showinfo(
                    "Running Simulation",
                    f"Simulation launched with {Path(self.last_config_file).name}.\nCheck the terminal for output."
                )
            except Exception as e:
                messagebox.showerror("Error", f"Failed to run simulation: {e}")
        else:
            messagebox.showerror("Error", "Failed to save configuration before running")


if __name__ == "__main__":
    root = tk.Tk()
    gui = SimpyNoCGUI(root)
    root.mainloop()

