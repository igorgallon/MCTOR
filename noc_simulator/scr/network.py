import threading
from constants import ARBITER_ALGORITHM, ROUTING_ALGORITHM, INJECTION_PATTERN
from clock import reset, tick, get_cycle
from packet import Packet
from router import Router
from processing_element import ProcessingElement

class Network:

    def __init__(self, context):
        self.rows, self.columns = context["mesh_size"]
        self.routers = {} # Dictionary to hold routers indexed by their (x, y) coordinates
        self.eps = [] # List to hold processing elements
        # Add start processing event
        self.start_processing = threading.Event()
        self.__setup_mesh()
    
    
    def __setup_mesh(self):
        '''
        Creates a network of routers and processing elements based on the specified rows and columns.
        Each router is connected to its neighbors using the X-Y topology and it has a local queue for
        processing elements.
        '''
        # Create routers for each coordinate in the specified rows and columns
        for x in range(self.rows):
            for y in range(self.columns):
                router = Router(x, y, routing_algorithm=ROUTING_ALGORITHM, arbiter_algorithm=ARBITER_ALGORITHM)
                self.routers[(x, y)] = router
        
        # Set up neighbors based on the X-Y topology
        for (x, y), router in self.routers.items():
            neighbors = {}    
            # Check for neighbors in the four cardinal directions
            if (x, y - 1) in self.routers:
                neighbors["west"] = self.routers[(x, y - 1)].in_queues["east"]
            if (x, y + 1) in self.routers:
                neighbors["east"] = self.routers[(x, y + 1)].in_queues["west"]
            if (x + 1, y) in self.routers:
                neighbors["south"] = self.routers[(x + 1, y)].in_queues["north"]
            if (x - 1, y) in self.routers:
                neighbors["north"] = self.routers[(x - 1, y)].in_queues["south"]
            # Create a processing element for each router at its coordinates
            ep = ProcessingElement(x, y)
            # Set the router's local queue as the processing element's outgoing queue
            ep.set_router_queue(router.in_queues["local"])
            neighbors["local"] = ep.in_router_queue
            # Set the outgoing queues for the router to its neighbors
            router.set_neighbors(neighbors)

            self.eps.append(ep)

        return self.routers, self.eps
    

    def start(self):
        '''
        Initialize Routers and Processing Elements
        '''
        for r in self.routers.values():
            r.start()
        for ep in self.eps:
            ep.start()
    

    def stop(self):
        '''
        Stop Routers and Processing Elements
        '''
        for ep in self.eps:
            ep.stop()
        for r in self.routers.values():
            r.stop()
    

    def begin_processing(self):
        '''
        Set the event to start processing in all routers.
        '''
        for r in self.routers.values():
            r.start()
        for ep in self.eps:
            ep.start()
    
    
    def stop_processing(self):
        '''
        Clear the event to stop processing in all routers.
        '''
        for r in self.routers.values():
            r.stop()
        for ep in self.eps:
            ep.stop()
    

    def run_step(self):
        '''
        Runs a single simulation step by advancing each router and processing element by one cycle.
        '''
        for r in self.routers.values():
            r.run_cycle()
        for ep in self.eps:
            ep.run_cycle()


    def __inject_traffic_continuous(self, injection_rate_per_node):
        """
        Injects traffic into the network continuously based on the specified injection rate per node.
        
        Args:
            injection_rate_per_node: flits/cycle per node (e.g., 0.5 = 1 flit every 2 cycles)
        """
        import random
        
        flits_injected = 0

        for p in self.eps:
            # Generate flits probabilistically based on the injection rate
            if random.random() < injection_rate_per_node:
                # Choose random destination (different from source)
                while True:
                    dst_ep = random.choice(self.eps)
                    if dst_ep.position != p.position:
                        break
                payload = {
                    "execution_id": injection_rate_per_node,
                    "weight": 1
                }
                packet = Packet(src=p.position, dst=dst_ep.position, payload=payload) # Flit
                
                # Try to inject packet
                if p.inject_packet(packet):
                    flits_injected += 1

        return flits_injected


    def __inject_traffic_random(self, total_flits):
        """
        Injects a specified total number of flits into the network at random source and destination nodes.
        
        Args:
            total_flits: Total number of flits to inject into the network.
        """
        import random
        
        flits_injected = 0

        for _ in range(total_flits):
            # Choose random source and destination (different)
            while True:
                src_ep = random.choice(self.eps)
                dst_ep = random.choice(self.eps)
                if dst_ep.position != src_ep.position:
                    break
            payload = {
                "execution_id": total_flits,
                "weight": 1
            }
            packet = Packet(src=src_ep.position, dst=dst_ep.position, payload=payload) # Flit
            
            # Try to inject packet
            if src_ep.inject_packet(packet):
                flits_injected += 1

        return flits_injected
    

    def __inject_traffic_uniform(self, total_flits):
        """
        Injects a specified total number of flits into the network from each node uniformly to random destination nodes.
        
        Args:
            total_flits: Total number of flits to inject per node into the network.
        """
        import random
        
        flits_injected = 0

        for p in self.eps:
            for _ in range(total_flits):
                # Choose random destination (different)
                while True:
                    dst_ep = random.choice(self.eps)
                    if dst_ep.position != p.position:
                        break
                payload = {
                    "execution_id": total_flits,
                    "weight": 1
                }
                packet = Packet(src=p.position, dst=dst_ep.position, payload=payload) # Flit
            
                # Try to inject packet
                if p.inject_packet(packet):
                    flits_injected += 1

        return flits_injected

    def get_injection_pattern(self):
        algorithm = {
            "RANDOM": self.__inject_traffic_random,
            "CONTINUOUS": self.__inject_traffic_continuous,
            "UNIFORM": self.__inject_traffic_uniform,
            "TRANSPOSE": None,
            "HOTSPOT": None
        }.get(INJECTION_PATTERN, None)
        if not algorithm:
            raise Exception(f"Injection pattern '{INJECTION_PATTERN}' not implemented!")
        else:
            return algorithm

    def run(self, injection_rate, total_cycles: int=0):
        '''
        Runs the network with continuous packet injection at the specified rate for a total number of cycles.
        '''
        # Reset the global cycle counter
        reset()
        
        # Inject packets
        num_flits_injected = self.__inject_traffic_uniform(injection_rate)

        for cycle in range(total_cycles):
            # Advance each router and processing element by one cycle
            for ep in self.eps:
                ep.run_cycle()
            for r in self.routers.values():
                r.run_cycle()
            
            # Advance global cycle counter (start of cycle)
            tick()
        
        return num_flits_injected
