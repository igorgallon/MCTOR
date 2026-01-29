import os
import sys
import argparse
import numpy as np
from clock import get_cycle
from logger import Logger
from network import Network
from metrics import MetricsCollector
from stats import analyze_and_plot_metrics, plot_all_algorithms_comparison
from config import load_config
import matplotlib.pyplot as plt

def load_application_graph(file_path: str) -> tuple[int, list[dict]]:
    """
    Loads the application graph from a .tgff or .app file.
    """
    num_tasks = 0
    graph = list()

    file_name = os.path.basename(file_path) # Extract the file name from the path
    name, ext = os.path.splitext(file_name) # Split the file name into name and extension
    if ext not in ['.tgff', '.app']:
        Logger().get_logger().critical(f"Unsupported file extension: {ext}. Only .tgff and .app files are supported.")
        raise ValueError(f"Unsupported file extension: {ext}. Only .tgff and .app files are supported.")

    # Load the graph data from the file
    with open(file_path, "r") as f:
        lines = f.readlines()
        
    if ext == '.app':
        index_graph = None
        index_num_tasks = None
        # Parse the .app file format
        for i, line in enumerate(lines):
            if line.strip().lower() in ["# number of tasks", "#[ntasks]"]:
                if i + 1 < len(lines):
                    index_num_tasks = i + 1
            if line.strip().lower() in ["# bandwidth requires", "# bandwidth constraint", "# bandwidth requirements", "#[graph]"]:
                index_graph = i + 1
                break
        if index_graph is None:
            Logger().get_logger().critical("Invalid .app file format: missing graph section.")
            raise ValueError("Invalid .app file format: missing graph section.")
        if index_num_tasks is None:
            Logger().get_logger().critical("Invalid .app file format: missing number of tasks section.")
            raise ValueError("Invalid .app file format: missing number of tasks section.")
        # Extract the number of tasks
        num_tasks = int(lines[index_num_tasks].strip())
        # Extract the graph data
        graph_data = [line.strip() for line in lines[index_graph:] if line.strip() and not line.strip().startswith("#")]
        for line in graph_data:
            if line.strip():
                parts = line.split()
                if len(parts) != 3:
                    Logger().get_logger().warning(f"Warning: Skipping malformed line in graph section: '{line}'")
                    continue
                src, dst, weight = parts
                graph.append({"source": int(src), "target": int(dst), "weight": float(weight)})
    
    elif ext == '.tgff':
        raise NotImplementedError("TGFF file format parsing is not yet implemented.")
    
    return num_tasks, graph


def load_tasks_mapping(file_path: str) -> tuple[int, int, list[int]]:
    """
    Loads the tasks mapping from a file or other source.
    """
    # Load the .map file
    with open(file_path, "r") as f:
        lines = f.readlines()
    # Parse the first line for rows and columns
    first_line = lines[0].strip().split()
    rows, columns = int(first_line[0]), int(first_line[1])
    # Parse the chromosome mapping
    chromosome = lines[1].strip().split()
    # Build the mapping from task IDs to router coordinates. 0-indexed
    mapping = [int(i) - 1 for i in chromosome]
    
    return rows, columns, mapping


def get_linear_list(num_steps, init_pct=0.0, end_pct=1.0) -> list[float]:
    return np.linspace(init_pct, end_pct, num_steps+1).tolist()[1:]


"""

Metodologia:
APP -> MCTOR Matlab -> Mapeamento Inteligente -> Simula em Python

1 - Motivação:
    Contextualização

2 - 
Deixar no texto justificado por quê feito em MATLAB (toolbox pronta com algoritmos multi-objetivos
e depois em Python (implementação mais simples de Multiprocessamento). Por que escolhida as taxas de testes


Comparação com outros simuladores. Comparações qualitativas

Comparação quantitativa:
- Diferentes algoritmos de roteamento
- Tamanho do Grid

Comparação qualitativa:
- Outros NoCs, no que o nosso é melhor

https://ieeexplore-ieee-org.ez31.periodicos.capes.gov.br/document/4919636
https://ieeexplore-ieee-org.ez31.periodicos.capes.gov.br/document/11141644/

https://chat.deepseek.com/share/gqbiivql6tvccke492

Test1: Comparação com os resultados do Khan Tahir
 - Apontar diferenças: o nosso não tem perda de pacotes, por exemplo
 - Comparar métricas (tamanho do GRID, buffer size, número de ciclos, etc)

Test2: Comparação de diferentes, algoritmos que vieram do MCTOR Matlab
-------------------------------
Artigo IEEE:

> Só do simulador NoC em python

Comparação 1:
    Artigo Noxim (Zhi Cheng) com diferentes roteamentos, falar que experimentos deram parecidos/curvas.
    Apontar as diferenças entre o Noxim e o nosso: python, mais flexivel, etc.
    AI: Ver se tem como normalizar os resultados para fazer comparação 

Comparação 2:
    Pegar os mapeamentos dos benchmarks do artigo Morphological e comparar Energia/FaultTolerance no NoC simulator

-------------------------------------------------------------------

Comparar simulador NoC: comparação com o artigo Morphological
Comparar métricas/algoritmos: comparar com o artigo dos chineses

Pegar melhores casos do artigo Morphological e colocar no NoC simulator. Pega as métricas e comparar com o artigo.
Depois comparar com artigo dos chineses

"""
if __name__ == "__main__":
    
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='NoC Simulator')
    parser.add_argument('--config', type=str, help='Configuration file (JSON)', default=None)
    args = parser.parse_args()
    
    # Load configuration
    # cfg = load_config(args.config)
    cfg = load_config("noc_simulator/scr/simulation_config.json")
    
    Logger().get_logger().info("Loading the Application Graph...")
    num_tasks, graph = load_application_graph(cfg["application_file"])

    Logger().get_logger().info("Loading tasks mapping...")
    rows, columns, mapping = load_tasks_mapping(cfg["mapping_file"])

    # Merge the Application Graphs with the mapping
    if not graph:
        Logger().get_logger().critical("Application graph is empty. Please check the .app file format.")
        raise ValueError("Application graph is empty. Please check the .app file format.")
    if not mapping:
        Logger().get_logger().critical("Tasks mapping is empty. Please check the .map file format.")
        raise ValueError("Tasks mapping is empty. Please check the .map file format.")
    
    if rows <= 0 or columns <= 0:
        Logger().get_logger().critical("ROWS and COLUMNS must be positive integers.")
        raise ValueError("ROWS and COLUMNS must be positive integers.")
    
    # Create the context for the simulation
    context = {
        "simulation_steps": cfg["simulation_steps"],
        "input_traffic_rate": get_linear_list(num_steps=cfg["traffic_steps"], init_pct=cfg["traffic_start"], end_pct=cfg["traffic_end"]),
        "mesh_size": cfg["mesh_size"],
        "max_flits_per_node": cfg["max_flits_per_node"]
    }

    routing_algorithms = cfg["routing_algorithms"]
    
    all_stats = {}  # Store statistics for all routing algorithms

    for r in routing_algorithms:

        Logger().get_logger().info("Initializing Mesh Network Simulation...")
        Logger().get_logger().info(f"Configuration: {context}")
        Logger().get_logger().info(f"Routing Algorithm: {r}")
        mesh_network = Network(context=context, routing_algorithm=r)
        mesh_network.start()
        
        Logger().get_logger().info("Simulation started! Injecting flits...")

        try:
            total_progress = len(context["input_traffic_rate"])
            # Run simulation for each input traffic rate
            for p, traffic in enumerate(context["input_traffic_rate"]):
                
                Logger().get_logger().info(f">>> ({p+1}/{total_progress}) Injecting flits ({round(traffic*100, 2)}%)")
                
                mesh_network.begin_processing()

                flits_injected, cycles_taken = mesh_network.run(injection_rate=traffic, max_flits_per_node=context["max_flits_per_node"], total_cycles=context["simulation_steps"])

                Logger().get_logger().info(f"<<< ({p+1}/{total_progress}) Traffic finished in {cycles_taken} cycles")
                MetricsCollector().push_metric({
                    'source': 'simulation',
                    "type": 'simulation_finished',
                    "execution_id": traffic,
                    "weight": get_cycle()
                })
                mesh_network.stop_processing()
        
        finally:
            mesh_network.stop()
            metrics_file = MetricsCollector().save_metrics_to_csv(suffix=r)
            
            # Analyze statistics (without displaying individual plots yet)
            try:
                Logger().get_logger().info(f"Analyzing statistics for {r} routing algorithm...")
                stats, fig = analyze_and_plot_metrics(metrics_file, r)
                all_stats[r] = stats  # Store for later comparison
                
                # Save the individual figure
                plot_file = metrics_file.replace('.csv', '_analysis.png')
                fig.savefig(plot_file, dpi=100, bbox_inches='tight')
                Logger().get_logger().info(f"Plot saved to {plot_file}")
                plt.close(fig)  # Close to free memory
                
            except Exception as e:
                Logger().get_logger().warning(f"Error analyzing statistics for {r}: {e}")
            
            del mesh_network
    
    # Create and display comparison plots after all simulations complete
    if all_stats:
        Logger().get_logger().info("Creating comparison plots for all routing algorithms...")
        try:
            comparison_file = plot_all_algorithms_comparison(all_stats, MetricsCollector().get_metrics_folder(), context)
            Logger().get_logger().info(f"Comparison plot saved to {comparison_file}")
            
            # Display summary table
            Logger().get_logger().info(f"\n{'='*80}")
            Logger().get_logger().info("FINAL STATISTICS SUMMARY")
            Logger().get_logger().info(f"{'='*80}\n")
            for algo, stats in all_stats.items():
                Logger().get_logger().info(f"\n{algo}:")
                Logger().get_logger().info(f"  Throughput:   {stats['throughput'].min():.4f} - {stats['throughput'].max():.4f}")
                Logger().get_logger().info(f"  Latency:      {stats['latency_mean'].min():.2f} - {stats['latency_mean'].max():.2f} cycles")
                Logger().get_logger().info(f"  Extra Delay:  {stats['extra_delay'].min():.2f} - {stats['extra_delay'].max():.2f} cycles")
                Logger().get_logger().info(f"  Packet Loss:  {stats['packet_loss'].sum():.0f} total")
            Logger().get_logger().info(f"{'='*80}\n")
            
            # Show all comparison plots
            plt.show()
        except Exception as e:
            Logger().get_logger().warning(f"Error creating comparison plots: {e}")
    sys.exit(0)