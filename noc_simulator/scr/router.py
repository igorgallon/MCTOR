import threading
import queue
from constants import MAX_BUFFER_SIZE
from logger import Logger
from metrics import MetricsCollector

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
            "local": queue.Queue(maxsize=100),  # Local queue for packets destined to this router
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
                Logger().get_logger().debug(f"{self.name} received packet {packet.id} from {direction}, routing to {next_dir}")
                # If the next direction is valid, put the packet in the corresponding outgoing queue
                if next_dir in self.out_queues:
                    self.out_queues[next_dir].put(packet)
                    # Log the routing of the packet
                    MetricsCollector().push_metric({
                        'source': 'router',
                        'type': 'packet_routed',
                        'packet_id': packet.id,
                        'from_dir': direction,
                        'to_dir': next_dir,
                        "traffic": packet.payload.get("traffic_pct", 0)
                    })
            
            except queue.Empty:
                pass

            except queue.Full:
                Logger().get_logger().debug(f"Full queue {direction}")
                # Log the full queue event
                MetricsCollector().push_metric({
                    'source': 'router',
                    'type': 'packet_loss',
                    'packet_id': packet.id,
                    "traffic": packet.payload.get("traffic_pct", 0)
                })
                pass
            idx = (idx + 1) % len(queue_keys)

            # TODO:
            # Primeiro pergunta se o router destino tem espaço para receber o pacote,
            # Se tiver, manda. Se não tiver, espera um pouco e tenta de novo.

    def stop(self):
        '''
        Stops the router thread.
        '''
        self.running = False

    @property
    def position(self):
        '''
        Returns the position of the router as a tuple (x, y).
        '''
        return (self.x, self.y)