import threading
from constants import ARBITER_ALGORITHM, ROUTING_ALGORITHM
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