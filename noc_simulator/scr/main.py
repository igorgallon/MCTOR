import time
import random
import sys
import threading
from network import create_network_2d_mesh
from packet import Packet

SIMULATION_TIME_SECONDS = 10
INJECTION_INTERVAL_SECONDS = 1

ROWS = 3
COLUMNS = 3

PACKAGE_INJECTION_RATE = 0.6

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

def user_input_listener(stop_event, eps):
    import msvcrt
    print("Press 'i' to inject a random packet, 'q' to quit.")
    while not stop_event.is_set():
        if msvcrt.kbhit():
            key = msvcrt.getwch()
            if key.lower() == 'i':
                inject_random_packets(eps, num_packets=1)
                stop_event.clear()
            elif key.lower() == 'q':
                stop_event.set()
                break
        time.sleep(0.05)

if __name__ == "__main__":
    
    if ROWS <= 0 or COLUMNS <= 0:
        raise ValueError("ROWS and COLUMNS must be positive integers.")

    print("Initializing Mesh Network Simulation...")
    routers, eps = create_network_2d_mesh(ROWS, COLUMNS)
    
    print("Created network with routers and processing elements:")
    print("Starting routers...")
    for r in routers.values():
        r.start()
    print("Starting processing elements...")
    for ep in eps:
        ep.start()
    
    print("Simulation started")
    stop_event = threading.Event()
    input_thread = threading.Thread(target=user_input_listener, args=(stop_event, eps), daemon=True)
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

    print("Simulation ended. Exiting...")  # Final message before exiting
    sys.exit(0)