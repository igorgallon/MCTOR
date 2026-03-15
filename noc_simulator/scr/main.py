import os
import sys
import argparse
from clock import get_cycle
from network import Network
from logger import Logger
from metrics import MetricsCollector
from stats import calculate_metrics, plot_all_algorithms_comparison
from config import load_config
import matplotlib.pyplot as plt
from utils import (
    get_linear_list,
    load_application_graph,
    load_tasks_mapping
)
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

    # Logger().get_logger().info("Loading tasks mapping...")
    # rows, columns, mapping = load_tasks_mapping(cfg["mapping_file"])

    # Merge the Application Graphs with the mapping
    # if not graph:
    #     Logger().get_logger().critical("Application graph is empty. Please check the .app file format.")
    #     raise ValueError("Application graph is empty. Please check the .app file format.")
    # if not mapping:
    #     Logger().get_logger().critical("Tasks mapping is empty. Please check the .map file format.")
    #     raise ValueError("Tasks mapping is empty. Please check the .map file format.")
    
    # if rows <= 0 or columns <= 0:
    #     Logger().get_logger().critical("ROWS and COLUMNS must be positive integers.")
    #     raise ValueError("ROWS and COLUMNS must be positive integers.")
    
    # Create the context for the simulation
    context = {
        "simulation_steps": cfg["simulation_steps"],
        "input_traffic_rate": get_linear_list(num_steps=cfg["traffic_steps"], init_pct=cfg["traffic_start"], end_pct=cfg["traffic_end"]),
        "mesh_size": cfg["mesh_size"],
        "max_flits_per_node": cfg["max_flits_per_node"],
        "routing_algorithms": cfg["routing_algorithms"]
    }

    all_stats = {}  # Store statistics for all routing algorithms

    mappings = [
        "noc_simulator/maps/vopd_onmap.map",
        "noc_simulator/maps/vopd_xyadb.map",
        "noc_simulator/maps/vopd_mapgraph.map",
        "noc_simulator/maps/vopd_nmap.map",
        "noc_simulator/maps/vopd_lmap.map",
        "noc_simulator/maps/vopd_rmap.map",
        "noc_simulator/maps/vopd_ga.map",
        "noc_simulator/maps/vopd_sa.map",
        "noc_simulator/maps/vopd_castnet.map",
        "noc_simulator/maps/vopd_ilp.map",
        "noc_simulator/maps/vopd_mapgtom.map"
    ]

    for m in mappings:

        Logger().get_logger().info("Loading tasks mapping...")
        rows, columns, mapping = load_tasks_mapping(m)

        r = "XY"
        m_name = m.replace(".map", "").split("/")[-1]

        Logger().get_logger().info("Initializing Mesh Network Simulation...")
        Logger().get_logger().info(f"Configuration: {context}")
        Logger().get_logger().info(f"Using Mapping: {m_name}")
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

                flits_injected, cycles_taken = mesh_network.run(injection_rate=traffic, max_flits_per_node=context["max_flits_per_node"], total_cycles=context["simulation_steps"], graph=graph, mapping=mapping)

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
            metrics_file = MetricsCollector().save_logs_to_csv(suffix=m_name)
            
            # Analyze statistics (without displaying individual plots yet)
            try:
                Logger().get_logger().info(f"Analyzing statistics for {m_name} mapping...")
                all_stats[m_name] = calculate_metrics(metrics_file)  # Store for later comparison
                            
            except Exception as e:
                Logger().get_logger().warning(f"Error analyzing statistics for {m_name}: {e}")
            
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
            for label, stats in all_stats.items():
                Logger().get_logger().info(f"\n{label}:")
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