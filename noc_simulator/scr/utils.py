from packet import Packet

####################################
# Routing Algorithms Implementations
####################################

def __route_xy(router_x: int, router_y: int, packet: Packet) -> str:
    '''
    Routes a packet using X-Y routing algorithm: First in X direction, then in Y direction.
    '''
    dst_x, dst_y = packet.dst
    x_offset = dst_x - router_x
    y_offset = dst_y - router_y

    if x_offset == 0 and y_offset == 0:
        # Packet is destined for this router
        return "local"
    # Directions: x is south/north, y is east/west
    if y_offset < 0:
        return "west"
    if y_offset > 0:
        return "east"
    if x_offset > 0:
        return "south"
    if x_offset < 0:
        return "north"
    # Fallback (should not reach here)
    raise ValueError(f"Invalid packet destination coordinates: {packet.dst} cannot be routed from {router_x, router_y})")


def __route_negative_first(router_x: int, router_y: int, packet: Packet) -> str:
    '''
    Routes a packet using Negative-First routing algorithm.
    '''
    dst_x, dst_y = packet.dst
    x_offset = dst_x - router_x
    y_offset = dst_y - router_y

    if x_offset == 0 and y_offset == 0:
        # Packet is destined for this router
        return "local"
    # Negative-First Routing: Route negative offsets first
    if y_offset < 0:
        return "west"
    if x_offset < 0:
        return "north"
    if y_offset > 0:
        return "east"
    if x_offset > 0:
        return "south"
    # Fallback (should not reach here)
    raise ValueError(f"Invalid packet destination coordinates: {packet.dst} cannot be routed from {router_x, router_y})")


def __route_west_first(router_x: int, router_y: int, packet: Packet) -> str:
    '''
    Routes a packet using West-First routing algorithm.
    '''
    dst_x, dst_y = packet.dst
    x_offset = dst_x - router_x
    y_offset = dst_y - router_y

    if x_offset == 0 and y_offset == 0:
        # Packet is destined for this router
        return "local"
    # West-First Routing: Route west first if needed
    if y_offset < 0:
        return "west"
    if x_offset < 0:
        return "north"
    if x_offset > 0:
        return "south"
    if y_offset > 0:
        return "east"
    # Fallback (should not reach here)
    raise ValueError(f"Invalid packet destination coordinates: {packet.dst} cannot be routed from {router_x, router_y})")


def __route_north_last(router_x: int, router_y: int, packet: Packet) -> str:
    '''
    Routes a packet using North-Last routing algorithm.
    '''
    dst_x, dst_y = packet.dst
    x_offset = dst_x - router_x
    y_offset = dst_y - router_y

    if x_offset == 0 and y_offset == 0:
        # Packet is destined for this router
        return "local"
    # North-Last Routing: Route south/east/west first
    if y_offset < 0:
        return "west"
    if y_offset > 0:
        return "east"
    if x_offset > 0:
        return "south"
    if x_offset < 0:
        return "north"
    
    # Fallback (should not reach here)
    raise ValueError(f"Invalid packet destination coordinates: {packet.dst} cannot be routed from {router_x, router_y})")


def __route_odd_even(router_x: int, router_y: int, packet: Packet) -> str:
    '''
    Routes a packet using Odd-Even routing algorithm.
    '''
    dst_x, dst_y = packet.dst
    x_offset = dst_x - router_x
    y_offset = dst_y - router_y

    if x_offset == 0 and y_offset == 0:
        # Packet is destined for this router
        return "local"
    
    # Odd-Even Routing logic
    if y_offset != 0:
        if (router_x % 2 == 0) or (y_offset > 0):
            return "east" if y_offset > 0 else "west"
    
    if x_offset != 0:
        return "south" if x_offset > 0 else "north"
    
    # Fallback (should not reach here)
    raise ValueError(f"Invalid packet destination coordinates: {packet.dst} cannot be routed from {router_x, router_y})")

ROUTING_ALGORITHMS = {
    "XY": __route_xy,
    "NEGATIVE_FIRST": __route_negative_first,
    "WEST_FIRST": __route_west_first,
    "NORTH_LEAST": __route_north_last,
    "ODD_EVEN": __route_odd_even
}


####################################
# Arbiter Algorithms Implementations
####################################


def __realistic_rr_arbiter(arbiter_index: int) -> tuple[str, int]:
    '''
    Realistic Round-Robin arbiter for selecting output direction.
    '''
    DIRECTIONS = ["north", "east", "south", "west", "local"]

    # Get the next direction in round-robin fashion
    next_direction = DIRECTIONS[arbiter_index]
    # Update the index for next call
    arbiter_index = (arbiter_index + 1) % len(DIRECTIONS)
    return next_direction, arbiter_index


ARBITER_ALGORITHMS = {
    "ROUND_ROBIN": __realistic_rr_arbiter
}