import threading
import queue
import time
from packet import Packet
from constants import PE_SLEEP_THREAD_SECONDS, MAX_BUFFER_SIZE


class ProcessingElement(threading.Thread):
    
    def __init__(self, x, y):
        '''
        Initializes a ProcessingElement instance at coordinates (x, y).
        '''
        super().__init__()
        self.x = x # X coordinate of the processing element
        self.y = y # Y coordinate of the processing element
        self.name = f"EP_{x}_{y}"
        self.daemon = True  # Ensures thread exits when main program exits
        self.in_router_queue = queue.Queue(maxsize=MAX_BUFFER_SIZE)  # Queue for incoming from the router
        self.running = True

    def set_router_queue(self, out_router_queue):
        '''
        Sets the outgoing router queue for the processing element.
        This is called after the processing element is created to establish connection with its router.
            :param out_router_queue: The queue to which packets will be sent.
        '''
        if not isinstance(out_router_queue, queue.Queue):
            raise ValueError("'out_router_queue' must be a queue instance.")
        self.out_router_queue = out_router_queue

    def inject_packet(self, p: Packet):
        '''
        Injects a packet into the processing element.
        '''
        if p.dst != (self.x, self.y):
            print(f"> {self.name} Injecting Packet {p.id} from {(self.x, self.y)} Router {p.dst}")
            self.out_router_queue.put_nowait(p)
        else:
            print(f"! {self.name} Injecting Packet {p.id} to itself is not allowed.")

    def run(self):
        '''
        Main loop for the processing element thread.
        '''
        while self.running:
            try:
                # Wait for a packet from the router's incoming queue
                received = self.in_router_queue.get_nowait()
                # Process the received packet
                print(f"{self.name} received packet {received.id} from Router {received.src}")
                received.has_arrived()
                # Sleep to simulate processing time
                # time.sleep(PE_SLEEP_THREAD_SECONDS)
            
            except queue.Empty:
                continue

    def stop(self):
        '''
        Stops the processing element thread.
        '''
        self.running = False

    @property
    def position(self):
        '''
        Returns the position of the processing element as a tuple (x, y).
        '''
        return (self.x, self.y)