import os
import random
import sys
import time
import pandas as pd
import numpy as np
import threading
from logger import Logger
from network import create_network_2d_mesh
from packet import Packet
from metrics import MetricsCollector
from constants import (
    INJECTION_INTERVAL_SECONDS,
    METRICS_COLLECTOR_INTERVAL_SECONDS,
    NUMBER_OF_CYCLES
)

def load_application_graph(file_path: str):
    """
    Loads the application graph from a .tgff or .app file.
    """
    file_name = os.path.basename(file_path) # Extract the file name from the path
    name, ext = os.path.splitext(file_name) # Split the file name into name and extension
    if ext not in ['.tgff', '.app']:
        Logger().get_logger().critical(f"Unsupported file extension: {ext}. Only .tgff and .app files are supported.")
        raise ValueError(f"Unsupported file extension: {ext}. Only .tgff and .app files are supported.")

    # Load the graph data from the file
    with open(file_path, "r") as f:
        lines = f.readlines()
    
    graph = list()
    
    if ext == '.app':
        index_graph = None
        index_num_tasks = None
        # Parse the .app file format
        for i, line in enumerate(lines):
            if line.strip().lower().startswith("# number of tasks"):
                if i + 1 < len(lines):
                    index_num_tasks = i + 1
            if line.strip().lower() in ["# bandwidth requires", "# bandwidth constraint", "# bandwidth requirements"]:
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
    # else:
    #     for line in graph_data.splitlines():
    #     if line.strip():
    #         src, dst = line.split()
    #         graph.setdefault(src, []).append(dst)

    return num_tasks, graph

def load_tasks_mapping(file_path: str):
    """
    Loads the tasks mapping from a file or other source.

    """
    # Load the .map file
    with open(file_path, "r") as f:
        lines = f.readlines()
    
    # Parse the first line for rows and columns
    first_line = lines[0].strip().split()
    rows = int(first_line[0])
    columns = int(first_line[1])

    # Parse the chromosome mapping
    chromosome = lines[1].strip().split()
    mapping = list()

    # Build the mapping from task IDs to router coordinates. 0-indexed
    for task_id, ep_id in enumerate(chromosome, start=0):
        # ep_id = int(ep_id)
        # router_x, router_y = int((ep_id-1) // rows), int((ep_id-1) % columns)
        mapping.append(int(ep_id) - 1)

    return rows, columns, mapping

def inject_packet(eps, graph, mapping, traffic) -> int:
    """
    Injects a packet to all active EPs based on the input traffic rate.
    """
    packets_injected = 0
    # for v in graph:
    #     src_ep = eps[mapping[v["source"]]]
    #     dst_ep = eps[mapping[v["target"]]]
    #     payload = {
    #         "traffic_pct": traffic,
    #         "weight": v["weight"]
    #     }
    #     pkt = Packet(src=src_ep.position, dst=dst_ep.position, payload=payload)
    #     src_ep.inject_packet(pkt)
    #     packets_injected += 1

    # Inject packets to all EPs randomly
    for ep in eps:
         # Uses the Bernoulli distribution for traffic injection
        if random.random() <= traffic:
            dst_ep = random.choice(eps)
            while dst_ep == ep:
                dst_ep = random.choice(eps)
            payload = {
                "traffic_pct": traffic,
                "weight": traffic
            }
            pkt = Packet(src=ep.position, dst=dst_ep.position, payload=payload)
            if ep.inject_packet(pkt):
                packets_injected += 1

    return packets_injected

def metrics_collector(user_stop_event):

    collector = MetricsCollector()
    Logger().get_logger().info(f"Metrics will be saved to {collector.metrics_file_name}")

    while not user_stop_event.is_set():
        metrics_dump = []
        # Collect all available metrics from the queue (non-blocking)
        metric = collector.get_metric()
        while metric is not None:
            metrics_dump.append(metric)
            metric = collector.get_metric()
        
        if metrics_dump:
            # Append collected metrics to a CSV file
            df = pd.DataFrame(metrics_dump)
            metrics_exists = os.path.isfile(collector.metrics_file_name)
            df.to_csv(collector.metrics_file_name, index=False,  mode='a' if metrics_exists else 'w', header=not metrics_exists)

        time.sleep(METRICS_COLLECTOR_INTERVAL_SECONDS)

# def user_input_listener(context, stop_event, eps, graph, mapping):
#     import msvcrt
#     # Logger().get_logger().info("Press 'i' to inject a random packet, 'q' to quit.")
#     while not stop_event.is_set():
#         if msvcrt.kbhit():
#             key = msvcrt.getwch()
#             # if key.lower() == 'i':
#             #     inject_random_packets(eps, num_packets=1)
#             #     stop_event.clear()
#             if key.lower() == 'q':
#                 stop_event.set()
#                 break
#         for traffic in context["input_traffic_rate"]:
#             Logger().get_logger().warning(f"Injecting packets with traffic percentage: {traffic}")
#             # Run simulation according to SIMULATION_STEPS
#             for _ in range(context["simulation_steps"]):
#                 # Inject packets according to the PACKAGE_INJECTION_RATE
#                 if random.random() < traffic:
#                     inject_packet(eps, graph, mapping, traffic)
#                 time.sleep(context["injection_interval"])
#         stop_event.set()
#         break

def get_linear_list(num_steps):
    return np.linspace(0, 1, num_steps+1).tolist()[1:]

"""

Metodologia:
APP -> MCTOR Matlab -> Mapeamento Inteligente -> Simula em Python

1 - Motivação:
    Contextualização

2 - 
Deixar no texto justificado por quê feito em MATLAB (toolbox pronta com algoritmos multi-objetivos
e depois em Python (implementação mais simples de Multiprocessamento). Por que escolhida as taxas de testes


Comparação com outros simuladores. Comparações qualitativas

Test1: Comparação com os resultados do Khan Tahir
 - Apontar diferenças: o nosso não tem perda de pacotes, por exemplo
 - Comparar métricas (tamanho do GRID, buffer size, número de ciclos, etc)

Test2: Comparação de diferentes, algoritmos que vieram do MCTOR Matlab

-------------------------------------------------------------------

Comparar simulador NoC: comparação com o artigo Morphological
Comparar métricas/algoritmos: comparar com o artigo dos chineses

Pegar melhores casos do artigo Morphological e colocar no NoC simulator. Pega as métricas e comparar com o artigo.
Depois comparar com artigo dos chineses

"""


if __name__ == "__main__":
    
    Logger().get_logger().info("Loading the Application Graph...")
    num_tasks, graph = load_application_graph("embedded_app_graphs/mpeg4.app")

    Logger().get_logger().info("Loading tasks mapping...")
    rows, columns, mapping = load_tasks_mapping("noc_simulator/mpeg4_mapping8_8.map")

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
        "simulation_steps": NUMBER_OF_CYCLES,
        "input_traffic_rate": get_linear_list(30),
        "injection_interval": INJECTION_INTERVAL_SECONDS,
        "mesh_size": (rows, columns)
    }

    Logger().get_logger().info("Initializing Mesh Network Simulation...")
    Logger().get_logger().info(f"Configuration: {context}")
    routers, eps = create_network_2d_mesh(context)

    Logger().get_logger().info("Created network with routers and processing elements:")
    for r in routers.values():
        r.start()
    Logger().get_logger().info("Starting processing elements...")
    for ep in eps:
        ep.start()
    
    Logger().get_logger().info("Simulation started! Injecting packets...")
    stop_event = threading.Event()
    metrics_thread = threading.Thread(target=metrics_collector, args=(stop_event,), daemon=True)
    metrics_thread.start()

    try:
        total_progress = len(context["input_traffic_rate"])
        # Run simulation for each input traffic rate
        for p, traffic in enumerate(context["input_traffic_rate"]):
            Logger().get_logger().warning(f">>> ({p+1}/{total_progress}) Injecting packets ({traffic}%)")
            packets_injected = 0
            # Run simulation according to 'simulation_steps'
            for cycle in range(context["simulation_steps"]):
                # Inject packets according to the PACKAGE_INJECTION_RATE
                packets_injected += inject_packet(eps, graph, mapping, traffic)
                time.sleep(context["injection_interval"])

            Logger().get_logger().warning(f">>> Waiting for completion of {packets_injected} packets ({traffic}%)")
            # Wait for completion
            all_done = False
            while not all_done:
                packets_arrived = len([met for met in MetricsCollector().get_all_metrics() if met.get('traffic') == traffic and (met.get('type') == 'packet_arrived' or met.get('type') == 'packet_loss')])
                all_done = packets_arrived >= packets_injected
                Logger().get_logger().info(f"Progress: {packets_arrived}/{packets_injected} packets ({traffic}%)")
                time.sleep(2)
            Logger().get_logger().warning(f"<<< Traffic finished: {traffic}")
    finally:
        
        stop_event.set()

        for ep in eps:
            ep.stop()
        for r in routers.values():
            r.stop()
        for ep in eps:
            ep.join()
        for r in routers.values():
            r.join()
        
        metrics_thread.join()

    Logger().get_logger().info(f"Simulation ended. Metrics saved to {MetricsCollector().get_metrics_file_name()}. Exiting...")
    sys.exit(0)