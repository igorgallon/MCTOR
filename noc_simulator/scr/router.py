import threading
import time
import queue
from constants import MAX_BUFFER_SIZE, RT_SLEEP_THREAD_SECONDS

class Router(threading.Thread):

    def __init__(self, x, y):
        '''
        Initializes a Router instance at coordinates (x, y).
        '''
        super().__init__()
        self.x = x # X coordinate of the router
        self.y = y # Y coordinate of the router
        self.name = f"RT_{x}_{y}"
        self.daemon = True  # Ensures thread exits when main program exits
        self.running = True

        # Connection queues for incoming packets from neighbors and local endpoints
        self.in_queues = {
            "local": queue.Queue(maxsize=MAX_BUFFER_SIZE),  # Local queue for packets destined to this router
            "north": queue.Queue(maxsize=MAX_BUFFER_SIZE),  # North neighbor
            "south": queue.Queue(maxsize=MAX_BUFFER_SIZE),  # South neighbor
            "east": queue.Queue(maxsize=MAX_BUFFER_SIZE),   # East neighbor
            "west": queue.Queue(maxsize=MAX_BUFFER_SIZE)    # West neighbor
        }
        # Connection queues for outgoing packets to neighbors and local endpoints
        # These will be set by the 'set_neighbors' function
        self.out_queues = {}

    def set_neighbors(self, out_queues):
        '''
        Sets the outgoing queues for the router to its neighbors and local endpoints.
        This is called after the router is created to establish connections with its neighbors.
            :param out_queues: A dictionary mapping directions to their respective outgoing queues.
        '''
        if not isinstance(out_queues, dict):
            raise ValueError("'out_queues' must be a dictionary mapping directions to queues.")

        self.out_queues = out_queues

    def route(self, packet):
        '''
        Routes a packet to the appropriate outgoing queue based on its destination.
        '''
        dst_x, dst_y = packet.dst
        x_offset = dst_x - self.x
        y_offset = dst_y - self.y

        if x_offset == 0 and y_offset == 0:
            # Packet is destined for this router
            return "local"
        # Directions: x is south/north, y is east/west
        if x_offset > 0:
            return "south"
        if x_offset < 0:
            return "north"
        if y_offset > 0:
            return "east"
        if y_offset < 0:
            return "west"
        else:
            raise ValueError(f"Invalid packet destination coordinates: {packet.dst} cannot be routed from {self.name}.")
        
    def run(self):
        '''
        Main loop for the router thread.
        '''
        queue_keys = list(self.in_queues.keys())
        idx = 0
        while self.running:
            direction = queue_keys[idx]
            q = self.in_queues[direction]
            try:
                # print(f"Checking for packets in direction {direction}")
                packet = q.get_nowait()
                packet.hops += 1
                # If a packet is found, route it to the appropriate outgoing queue
                next_dir = self.route(packet)
                print(f"{self.name} received packet {packet.id} from {direction}, routing to {next_dir}")
                # If the next direction is valid, put the packet in the corresponding outgoing queue
                if next_dir in self.out_queues:
                    self.out_queues[next_dir].put(packet)
                 # Sleep to simulate processing time
                time.sleep(RT_SLEEP_THREAD_SECONDS)
            except queue.Empty:
                # print(f"Empty queue {direction}")
                pass
            idx = (idx + 1) % len(queue_keys)

    def stop(self):
        '''
        Stops the router thread.
        '''
        self.running = False
