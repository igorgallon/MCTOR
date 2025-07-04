from router import Router
from processing_element import ProcessingElement

def create_network_2d_mesh(rows, columns):
    '''
    Creates a network of routers and processing elements based on the specified rows and columns.
    Each router is connected to its neighbors using the X-Y topology and it has a local queue for
    processing elements.
    '''
    routers = {} # Dictionary to hold routers indexed by their (x, y) coordinates
    eps = [] # List to hold processing elements

    # Create routers for each coordinate in the specified rows and columns
    for y in range(columns):
        for x in range(rows):
            router = Router(x, y)
            routers[(x, y)] = router
    
    # Set up neighbors based on the X-Y topology
    for (x, y), router in routers.items():
        neighbors = {}    
        # Check for neighbors in the four cardinal directions
        if (x, y - 1) in routers:
            neighbors["west"] = routers[(x, y - 1)].in_queues["east"]
        if (x, y + 1) in routers:
            neighbors["east"] = routers[(x, y + 1)].in_queues["west"]
        if (x + 1, y) in routers:
            neighbors["south"] = routers[(x + 1, y)].in_queues["north"]
        if (x - 1, y) in routers:
            neighbors["north"] = routers[(x - 1, y)].in_queues["south"]
        # Create a processing element for each router at its coordinates
        ep = ProcessingElement(x, y)
        # Set the router's local queue as the processing element's outgoing queue
        ep.set_router_queue(router.in_queues["local"])
        neighbors["local"] = ep.in_router_queue
        # Set the outgoing queues for the router to its neighbors
        router.set_neighbors(neighbors)
        
        eps.append(ep)

    return routers, eps
