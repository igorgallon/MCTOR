import tkinter as tk
from tkinter import ttk, messagebox, filedialog
from pathlib import Path
from config import load_config, save_config

class NoCSimulatorGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("NoC Simulator Configuration")
        self.root.geometry("800x800")
        self.root.resizable(True, True)
        
        # Configure style
        style = ttk.Style()
        style.theme_use('clam')
        
        # Create main notebook (tabs)
        self.notebook = ttk.Notebook(root)
        self.notebook.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Create tabs
        self.create_network_tab()
        self.create_simulation_tab()
        self.create_traffic_tab()
        self.create_routing_tab()
        self.create_summary_tab()
        
        # Create bottom button frame
        self.create_button_frame()
        
        # Load default config
        self.load_config_values(load_config())
        
    def create_network_tab(self):
        """Network configuration tab"""
        frame = ttk.Frame(self.notebook)
        self.notebook.add(frame, text="🌐 Network")
        
        # Mesh size
        ttk.Label(frame, text="Mesh Configuration", font=('Arial', 12, 'bold')).pack(pady=10)
        
        mesh_frame = ttk.LabelFrame(frame, text="Mesh Dimensions")
        mesh_frame.pack(padx=20, pady=10, fill=tk.BOTH)
        
        ttk.Label(mesh_frame, text="Rows:").pack(anchor=tk.W, padx=10, pady=5)
        self.mesh_rows = ttk.Scale(mesh_frame, from_=2, to=16, orient=tk.HORIZONTAL)
        self.mesh_rows.pack(padx=10, pady=5, fill=tk.X)
        self.mesh_rows_label = ttk.Label(mesh_frame, text="6", foreground="blue")
        self.mesh_rows_label.pack(anchor=tk.W, padx=10)
        self.mesh_rows.config(command=lambda v: self.mesh_rows_label.config(text=str(int(float(v)))))
        
        ttk.Label(mesh_frame, text="Columns:").pack(anchor=tk.W, padx=10, pady=5)
        self.mesh_cols = ttk.Scale(mesh_frame, from_=2, to=16, orient=tk.HORIZONTAL)
        self.mesh_cols.pack(padx=10, pady=5, fill=tk.X)
        self.mesh_cols_label = ttk.Label(mesh_frame, text="6", foreground="blue")
        self.mesh_cols_label.pack(anchor=tk.W, padx=10)
        self.mesh_cols.config(command=lambda v: self.mesh_cols_label.config(text=str(int(float(v)))))
        
    def create_simulation_tab(self):
        """Simulation parameters tab"""
        frame = ttk.Frame(self.notebook)
        self.notebook.add(frame, text="⚙️ Simulation")
        
        ttk.Label(frame, text="Simulation Parameters", font=('Arial', 12, 'bold')).pack(pady=10)
        
        # Simulation steps
        sim_frame = ttk.LabelFrame(frame, text="Simulation Steps")
        sim_frame.pack(padx=20, pady=10, fill=tk.X)
        
        ttk.Label(sim_frame, text="Total Cycles:").pack(anchor=tk.W, padx=10, pady=5)
        self.sim_steps = ttk.Scale(sim_frame, from_=100, to=10000, orient=tk.HORIZONTAL)
        self.sim_steps.set(500)
        self.sim_steps.pack(padx=10, pady=5, fill=tk.X)
        self.sim_steps_label = ttk.Label(sim_frame, text="500", foreground="blue")
        self.sim_steps_label.pack(anchor=tk.W, padx=10)
        self.sim_steps.config(command=lambda v: self.sim_steps_label.config(text=str(int(float(v)))))
        
        # Max flits per node
        flits_frame = ttk.LabelFrame(frame, text="Buffer Configuration")
        flits_frame.pack(padx=20, pady=10, fill=tk.X)
        
        ttk.Label(flits_frame, text="Max Flits per Node:").pack(anchor=tk.W, padx=10, pady=5)
        self.max_flits = ttk.Scale(flits_frame, from_=100, to=5000, orient=tk.HORIZONTAL)
        self.max_flits.set(1000)
        self.max_flits.pack(padx=10, pady=5, fill=tk.X)
        self.max_flits_label = ttk.Label(flits_frame, text="1000", foreground="blue")
        self.max_flits_label.pack(anchor=tk.W, padx=10)
        self.max_flits.config(command=lambda v: self.max_flits_label.config(text=str(int(float(v)))))
        
    def create_traffic_tab(self):
        """Traffic configuration tab"""
        frame = ttk.Frame(self.notebook)
        self.notebook.add(frame, text="📈 Traffic")
        
        ttk.Label(frame, text="Traffic Configuration", font=('Arial', 12, 'bold')).pack(pady=10)
        
        # Traffic steps
        steps_frame = ttk.LabelFrame(frame, text="Number of Steps")
        steps_frame.pack(padx=20, pady=10, fill=tk.X)
        
        ttk.Label(steps_frame, text="Traffic Steps:").pack(anchor=tk.W, padx=10, pady=5)
        self.traffic_steps = ttk.Scale(steps_frame, from_=5, to=100, orient=tk.HORIZONTAL)
        self.traffic_steps.set(20)
        self.traffic_steps.pack(padx=10, pady=5, fill=tk.X)
        self.traffic_steps_label = ttk.Label(steps_frame, text="20", foreground="blue")
        self.traffic_steps_label.pack(anchor=tk.W, padx=10)
        self.traffic_steps.config(command=lambda v: self.traffic_steps_label.config(text=str(int(float(v)))))
        
        # Traffic range
        range_frame = ttk.LabelFrame(frame, text="Traffic Range (%)")
        range_frame.pack(padx=20, pady=10, fill=tk.X)
        
        ttk.Label(range_frame, text="Start (%):").pack(anchor=tk.W, padx=10, pady=5)
        self.traffic_start = ttk.Scale(range_frame, from_=0, to=50, orient=tk.HORIZONTAL)
        self.traffic_start.set(0)
        self.traffic_start.pack(padx=10, pady=5, fill=tk.X)
        self.traffic_start_label = ttk.Label(range_frame, text="0.0%", foreground="blue")
        self.traffic_start_label.pack(anchor=tk.W, padx=10)
        self.traffic_start.config(command=lambda v: self.traffic_start_label.config(text=f"{float(v):.1f}%"))
        
        ttk.Label(range_frame, text="End (%):").pack(anchor=tk.W, padx=10, pady=5)
        self.traffic_end = ttk.Scale(range_frame, from_=1, to=150, orient=tk.HORIZONTAL)
        self.traffic_end.set(5)
        self.traffic_end.pack(padx=10, pady=5, fill=tk.X)
        self.traffic_end_label = ttk.Label(range_frame, text="5.0%", foreground="blue")
        self.traffic_end_label.pack(anchor=tk.W, padx=10)
        self.traffic_end.config(command=lambda v: self.traffic_end_label.config(text=f"{float(v):.1f}%"))
        
    def create_routing_tab(self):
        """Routing algorithms and files tab"""
        frame = ttk.Frame(self.notebook)
        self.notebook.add(frame, text="🛣️ Routing & Files")
        
        # Routing algorithms
        routing_frame = ttk.LabelFrame(frame, text="Routing Algorithms")
        routing_frame.pack(padx=20, pady=10, fill=tk.X)
        
        self.routing_vars = {}
        algorithms = ["XY", "NEGATIVE_FIRST", "WEST_FIRST", "NORTH_LEAST"]
        for algo in algorithms:
            var = tk.BooleanVar(value=True)
            self.routing_vars[algo] = var
            ttk.Checkbutton(routing_frame, text=algo, variable=var).pack(anchor=tk.W, padx=10, pady=5)
        
        # File selection
        files_frame = ttk.LabelFrame(frame, text="Input Files")
        files_frame.pack(padx=20, pady=10, fill=tk.BOTH, expand=True)
        
        ttk.Label(files_frame, text="Application File (.app):").pack(anchor=tk.W, padx=10, pady=5)
        app_frame = ttk.Frame(files_frame)
        app_frame.pack(padx=10, pady=5, fill=tk.X)
        
        self.app_file = ttk.Combobox(app_frame, width=40, state="readonly")
        self.app_file["values"] = ["mpeg4.app", "mms.app", "vopd.app", "e3s_autoindust_ori.app", "e3s_networking_ori.app"]
        self.app_file.set("mpeg4.app")
        self.app_file.pack(side=tk.LEFT, fill=tk.X, expand=True)
        
        ttk.Button(app_frame, text="Browse", width=10).pack(side=tk.LEFT, padx=5)
        
        ttk.Label(files_frame, text="Mapping File (.map):").pack(anchor=tk.W, padx=10, pady=5)
        map_frame = ttk.Frame(files_frame)
        map_frame.pack(padx=10, pady=5, fill=tk.X)
        
        self.map_file = ttk.Entry(map_frame, width=50)
        self.map_file.insert(0, "mpeg4_mapping.map")
        self.map_file.pack(side=tk.LEFT, fill=tk.X, expand=True)
        
        ttk.Button(map_frame, text="Browse", width=10).pack(side=tk.LEFT, padx=5)
        
    def create_summary_tab(self):
        """Configuration summary tab"""
        frame = ttk.Frame(self.notebook)
        self.notebook.add(frame, text="📋 Summary")
        
        ttk.Label(frame, text="Configuration Summary", font=('Arial', 12, 'bold')).pack(pady=10)
        
        # Text widget with scrollbar
        scrollbar = ttk.Scrollbar(frame)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        self.summary_text = tk.Text(frame, height=20, width=70, yscrollcommand=scrollbar.set)
        self.summary_text.pack(padx=20, pady=10, fill=tk.BOTH, expand=True)
        scrollbar.config(command=self.summary_text.yview)
        
        # Refresh button
        ttk.Button(frame, text="Refresh Summary", command=self.update_summary).pack(pady=10)
        
    def create_button_frame(self):
        """Bottom button frame"""
        btn_frame = ttk.Frame(self.root)
        btn_frame.pack(side=tk.BOTTOM, fill=tk.X, padx=10, pady=10)
        
        ttk.Button(btn_frame, text="💾 Save Configuration", command=self.save_config_action).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="📖 Load Configuration", command=self.load_config_action).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="🚀 Run Simulation", command=self.run_simulation).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="❌ Exit", command=self.root.quit).pack(side=tk.RIGHT, padx=5)
        
    def get_config(self):
        """Get current configuration"""
        selected_algorithms = [algo for algo, var in self.routing_vars.items() if var.get()]
        
        if not selected_algorithms:
            messagebox.showerror("Error", "Please select at least one routing algorithm!")
            return None
        
        config = {
            "mesh_size": [int(float(self.mesh_rows.get())), int(float(self.mesh_cols.get()))],
            "simulation_steps": int(float(self.sim_steps.get())),
            "max_flits_per_node": int(float(self.max_flits.get())),
            "traffic_steps": int(float(self.traffic_steps.get())),
            "traffic_start": float(self.traffic_start.get()) / 100,
            "traffic_end": float(self.traffic_end.get()) / 100,
            "application_file": f"embedded_app_graphs/{self.app_file.get()}",
            "mapping_file": f"simpynoc/{self.map_file.get()}",
            "routing_algorithms": selected_algorithms
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
        summary += f"Network Configuration:\n"
        summary += f"  Mesh Size: {config['mesh_size'][0]} x {config['mesh_size'][1]}\n\n"
        summary += f"Simulation Parameters:\n"
        summary += f"  Simulation Steps: {config['simulation_steps']} cycles\n"
        summary += f"  Max Flits/Node: {config['max_flits_per_node']}\n\n"
        summary += f"Traffic Configuration:\n"
        summary += f"  Number of Steps: {config['traffic_steps']}\n"
        summary += f"  Range: {config['traffic_start']*100:.1f}% - {config['traffic_end']*100:.1f}%\n\n"
        summary += f"Input Files:\n"
        summary += f"  Application: {config['application_file']}\n"
        summary += f"  Mapping: {config['mapping_file']}\n\n"
        summary += f"Routing Algorithms ({len(config['routing_algorithms'])}):\n"
        for algo in config['routing_algorithms']:
            summary += f"  ✓ {algo}\n"
        
        self.summary_text.insert(tk.END, summary)
    
    def save_config_action(self):
        """Save configuration to file"""
        config = self.get_config()
        if not config:
            return
        
        if save_config(config, "simulation_config.json"):
            messagebox.showinfo("Success", "Configuration saved to simulation_config.json")
        else:
            messagebox.showerror("Error", "Failed to save configuration")
    
    def load_config_action(self):
        """Load configuration from file"""
        file_path = filedialog.askopenfilename(
            defaultextension=".json",
            filetypes=[("JSON files", "*.json"), ("All files", "*.*")]
        )
        
        if file_path:
            config = load_config(file_path)
            self.load_config_values(config)
            messagebox.showinfo("Success", f"Configuration loaded from {Path(file_path).name}")
    
    def load_config_values(self, config):
        """Load values into GUI from config dict"""
        self.mesh_rows.set(config["mesh_size"][0])
        self.mesh_cols.set(config["mesh_size"][1])
        self.sim_steps.set(config["simulation_steps"])
        self.max_flits.set(config["max_flits_per_node"])
        self.traffic_steps.set(config["traffic_steps"])
        self.traffic_start.set(config["traffic_start"] * 100)
        self.traffic_end.set(config["traffic_end"] * 100)
        
        app_file = Path(config["application_file"]).name
        self.app_file.set(app_file)
        
        map_file = Path(config["mapping_file"]).name
        self.map_file.delete(0, tk.END)
        self.map_file.insert(0, map_file)
        
        for algo in config["routing_algorithms"]:
            if algo in self.routing_vars:
                self.routing_vars[algo].set(True)
        
        self.update_summary()
    
    def run_simulation(self):
        """Run simulation with current configuration"""
        config = self.get_config()
        if not config:
            return
        
        if save_config(config, "simulation_config.json"):
            messagebox.showinfo(
                "Simulation Ready",
                "Configuration saved!\n\n"
                "Run this command in terminal:\n"
                "python main.py --config simulation_config.json"
            )
        else:
            messagebox.showerror("Error", "Failed to save configuration")


if __name__ == "__main__":
    root = tk.Tk()
    gui = NoCSimulatorGUI(root)
    root.mainloop()

