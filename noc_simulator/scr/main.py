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
from constants import INJECTION_INTERVAL_SECONDS, METRICS_COLLECTOR_INTERVAL_SECONDS

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

def inject_random_packets(context, eps, num_packets=1):
    """
    Injects random packets into the network.
    Each packet is sent from a random endpoint to a random destination endpoint.
    """
    if not eps:
        return
    for _ in range(num_packets):
        src_ep = random.choice(eps)
        dst_ep = random.choice(eps)
        # Ensure src != dst
        while dst_ep == src_ep and len(eps) > 1:
            dst_ep = random.choice(eps)
        payload = f"msg from ({src_ep.x},{src_ep.y}) to ({dst_ep.x},{dst_ep.y})"
        pkt = Packet(context=context, src=(src_ep.x, src_ep.y), dst=(dst_ep.x, dst_ep.y), payload=payload)
        src_ep.inject_packet(pkt)

def inject_packet(eps, graph, mapping, input_traffic_pct) -> int:
    """
    Injects a packet from all tasks to its mapped processing element.
    """
    packets_injected = 0
    for v in graph:
        src_ep = eps[mapping[v["source"]]]
        dst_ep = eps[mapping[v["target"]]]
        payload = {
            "traffic_pct": input_traffic_pct,
            "weight": v["weight"]
        }
        pkt = Packet(src=src_ep.position, dst=dst_ep.position, payload=payload)
        src_ep.inject_packet(pkt)
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
    

def user_input_listener(context, stop_event, eps, graph, mapping):
    import msvcrt
    # Logger().get_logger().info("Press 'i' to inject a random packet, 'q' to quit.")
    while not stop_event.is_set():
        if msvcrt.kbhit():
            key = msvcrt.getwch()
            # if key.lower() == 'i':
            #     inject_random_packets(eps, num_packets=1)
            #     stop_event.clear()
            if key.lower() == 'q':
                stop_event.set()
                break
        for traffic in context["input_traffic_pct"]:
            Logger().get_logger().warning(f"Injecting packets with traffic percentage: {traffic}")
            # Run simulation according to SIMULATION_STEPS
            for _ in range(context["simulation_steps"]):
                # Inject packets according to the PACKAGE_INJECTION_RATE
                if random.random() < traffic:
                    inject_packet(eps, graph, mapping, traffic)
                time.sleep(context["injection_interval"])
        stop_event.set()
        break

def get_linear_list(num_steps):
    return np.linspace(0, 1, num_steps+1).tolist()[1:]

if __name__ == "__main__":
    
    Logger().get_logger().info("Loading the Application Graph...")
    num_tasks, graph = load_application_graph("embedded_app_graphs/app_4.app")

    Logger().get_logger().info("Loading tasks mapping...")
    rows, columns, mapping = load_tasks_mapping("noc_simulator/test.map")

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
        "total_packets": 500,
        "input_traffic_pct": get_linear_list(50),
        "mesh_size": (rows, columns)
    }

    Logger().get_logger().info("Initializing Mesh Network Simulation...")
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

        for traffic in context["input_traffic_pct"]:
            # MetricsCollector().push_metric({
            #     'source': 'simulation',
            #     'type': 'simulation_start',
            #     'traffic': traffic
            # })
            total_packets = int(traffic * context["total_packets"])
            Logger().get_logger().warning(f">>> Injecting {total_packets} packets ({traffic}%)")
            packets_injected = 0
            # Run simulation according to SIMULATION_STEPS
            for _ in range(total_packets):
                # Inject packets according to the PACKAGE_INJECTION_RATE
                packets_injected += inject_packet(eps, graph, mapping, traffic)
                time.sleep(INJECTION_INTERVAL_SECONDS)

            Logger().get_logger().warning(f">>> Waiting for completion of {packets_injected} packets ({traffic}%)")
            # Wait for completion
            all_done = False
            while not all_done:
                packets_arrived = len([met for met in MetricsCollector().get_all_metrics() if met.get('traffic') == traffic and (met.get('type') == 'packet_arrived' or met.get('type') == 'packet_loss')])
                all_done = packets_arrived >= packets_injected
                time.sleep(2)
            
            Logger().get_logger().warning(f"<<< Traffic finished: {traffic}")

            # MetricsCollector().push_metric({
            #     'source': 'simulation',
            #     'type': 'simulation_end',
            #     'traffic': traffic
            # })
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
    
    Logger().get_logger().info("Simulation ended. Exiting...")
    sys.exit(0)