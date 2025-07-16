import os
import random
import sys
import time
import threading
from logger import Logger
from network import create_network_2d_mesh
from packet import Packet

SIMULATION_TIME_SECONDS = 10
INJECTION_INTERVAL_SECONDS = 1

ROWS = 3
COLUMNS = 3

PACKAGE_INJECTION_RATE = 0.6

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

def inject_random_packets(eps, num_packets=1):
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
        pkt = Packet((src_ep.x, src_ep.y), (dst_ep.x, dst_ep.y), payload)
        src_ep.inject_packet(pkt)

def inject_packet(eps, graph, mapping):
    """
    Injects a packet from all tasks to its mapped processing element.
    """
    for v in graph:
        src_ep = eps[mapping[v["source"]]]
        dst_ep = eps[mapping[v["target"]]]
        pkt = Packet(src_ep.position, dst_ep.position, v["weight"])
        src_ep.inject_packet(pkt)

def user_input_listener(stop_event, eps, graph, mapping):
    import msvcrt
    Logger().get_logger().info("Press 'i' to inject a random packet, 'q' to quit.")
    while not stop_event.is_set():
        if msvcrt.kbhit():
            key = msvcrt.getwch()
            # if key.lower() == 'i':
            #     inject_random_packets(eps, num_packets=1)
            #     stop_event.clear()
            if key.lower() == 'q':
                stop_event.set()
                break
        # Inject packets according to the PACKAGE_INJECTION_RATE
        if random.random() < PACKAGE_INJECTION_RATE:
            inject_packet(eps, graph, mapping)
        time.sleep(0.05)

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

    Logger().get_logger().info("Initializing Mesh Network Simulation...")
    routers, eps = create_network_2d_mesh(rows, columns)

    Logger().get_logger().info("Created network with routers and processing elements:")
    for r in routers.values():
        r.start()
    Logger().get_logger().info("Starting processing elements...")
    for ep in eps:
        ep.start()
    
    Logger().get_logger().info("Simulation started! Injecting packets...")
    stop_event = threading.Event()
    input_thread = threading.Thread(target=user_input_listener, args=(stop_event, eps, graph, mapping), daemon=True)
    input_thread.start()
    try:
        while not stop_event.is_set():
            time.sleep(0.1)
    finally:
        stop_event.set()
        input_thread.join()
        for ep in eps:
            ep.stop()
        for r in routers.values():
            r.stop()
        for ep in eps:
            ep.join()
        for r in routers.values():
            r.join()

    Logger().get_logger().info("Simulation ended. Exiting...")  # Final message before exiting
    sys.exit(0)