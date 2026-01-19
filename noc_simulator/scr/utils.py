import random
from packet import Packet

####################################
# Routing Algorithms Implementations
####################################

def __route_xy(current_x: int, current_y: int, packet: Packet) -> list[str]:
    '''
    Routes a packet using X-Y routing algorithm: First in X direction, then in Y direction.
    '''
    dst_x, dst_y = packet.dst
    directions = list()

    if dst_x == current_x and dst_y == current_y:
        # Packet is destined for this router
        return ["local"]
    # Directions: x is south/north, y is east/west
    if dst_y > current_y:
        directions.append("east")
    elif dst_y < current_y:
        directions.append("west")
    elif dst_x > current_x:
        directions.append("south")
    else:
        directions.append("north")
    
    return directions

def __route_negative_first(current_x: int, current_y: int, packet: Packet) -> list[str]:
    '''
    Routes a packet using Negative-First routing algorithm.
    '''
    dst_x, dst_y = packet.dst
    directions = list()

    # Negative-First Routing: Route negative offsets first
    if dst_x > current_x or dst_y < current_y:
        if dst_x > current_x:
            directions.append("south")
        if dst_y < current_y:
            directions.append("west")
    else:
        # Positive offsets
        if dst_x < current_x or dst_y > current_y:
            if dst_x < current_x:
                directions.append("north")
            if dst_y > current_y:
                directions.append("east")
        else:
            # Packet is at destination
            directions.append("local")
    return directions


def __route_west_first(current_x: int, current_y: int, packet: Packet) -> list[str]:
    '''
    Routes a packet using West-First routing algorithm.
    '''
    dst_x, dst_y = packet.dst
    directions = list()

    if dst_y <= current_y or dst_x == current_x:
        return __route_xy(current_x, current_y, packet)
    
    # West-First Routing: Route west first if needed
    if dst_x < current_x:
        directions.append("north")
        directions.append("east")
    else:
        directions.append("south")
        directions.append("east")
    return directions

def __route_north_last(current_x: int, current_y: int, packet: Packet) -> list[str]:
    '''
    Routes a packet using North-Last routing algorithm.
    '''
    dst_x, dst_y = packet.dst
    directions = list()

    if dst_y == current_y or dst_x <= current_x:
        return __route_xy(current_x, current_y, packet)

    # North-Last Routing: Route south/east/west first
    if dst_y < current_y:
        directions.append("south")
        directions.append("west")
    else:
        directions.append("south")
        directions.append("east")
    
    return directions


def __route_odd_even(current_x: int, current_y: int, packet: Packet, **kwargs) -> list[str]:
    """
    Função pura de roteamento OddEven
    
    Args:
        src: (x, y) - posição atual
        dest: (dx, dy) - destino
        grid_width: largura da grade (colunas)
        grid_height: altura da grade (linhas)
        
    Returns:
        Direção do próximo salto ou None se chegou
    """
    possible_paths = list()
    
    n = 6  # número de linhas
    # m = 6   # número de colunas

    x, y = current_x, current_y
    dx, dy = packet.dst
    
    diff_x = dx - x
    diff_y = dy - y

    if (x, y) == (dx, dy):
        possible_paths.append("local")
    else:   
        # COLUNA PAR
        if y % 2 == 0:
            # Pode mover para Leste
            if diff_y > 0:
                return "east"
            # Precisa mover para Oeste - deve mover verticalmente primeiro
            elif diff_y < 0:
                # Se pode mover para Norte
                if diff_x < 0:
                    return 'north'
                # Se pode mover para Sul
                elif diff_x > 0:
                    return 'south'
                # Mesma linha (diff_x = 0) - escolhe Norte se possível
                else:
                    if x > 0:  # Não está na borda superior
                        return 'north'
                    elif x < n - 1:  # Está na borda superior, vai para Sul
                        return 'south'
                    # Caso extremo: linha única - tem que quebrar a regra
                    else:
                        return 'west'
            # Mesma coluna (diff_y = 0)
            else:
                if diff_x > 0:
                    return 'east'
                elif diff_x < 0:
                    return 'west'

        # COLUNA ÍMPAR
        else:
            # Pode mover para Oeste
            if diff_y < 0:
                return 'west'
            # Precisa mover para Leste - deve mover verticalmente primeiro
            elif diff_y > 0:
                # Se pode mover para Norte
                if diff_x < 0:
                    return 'north'
                # Se pode mover para Sul
                elif diff_x > 0:
                    return 'south'
                # Mesma linha (diff_x = 0) - escolhe Norte se possível
                else:
                    if x > 0:  # Não está na borda superior
                        return 'north'
                    elif x < n - 1:  # Está na borda superior, vai para Sul
                        return 'south'
                    # Caso extremo: linha única - tem que quebrar a regra
                    else:
                        return 'west'
            # Mesma coluna (diff_y = 0)
            else:
                if diff_x > 0:
                    return 'east'
                elif diff_x < 0:
                    return 'west'

    return possible_paths


# def __route_odd_even(router_x: int, router_y: int, packet: Packet) -> str:
#     '''
#     Routes a packet using Odd-Even routing algorithm.
#     '''
#     directions = list()
    
#     current_x = router_x
#     current_y = router_y
#     src_x, src_y = packet.src
#     dst_x, dst_y = packet.dst

#     e0 = dst_x - current_x
#     e1 = -(dst_y - current_y)

#     if e0 == 0 and e1 == 0:
#         # Packet is destined for this router
#         directions.append("local")
#     else:
#         if (e0 == 0):
#             if (e1 > 0):
#                 directions.append("north")
#             else:
#                 directions.append("south")
#         else:
#             if (e0 > 0):
#                 if (e1 == 0):
#                     directions.append("east")
#                 else:
#                     if ((current_x % 2 == 1) or (current_x == src_x)):
#                         if (e1 > 0):
#                             directions.append("north")
#                         else:
#                             directions.append("south")

#                     if ((dst_x % 2 == 1) or (e0 != 1)):
#                         directions.append("east")
#             else:
#                 directions.append("west")
#                 if (current_x % 2 == 0):
#                     if (e1 > 0):
#                         directions.append("north")
#                     if (e1 < 0):
#                         directions.append("south")
    
#     # Return the first move only for simplicity
#     # TODO: Add more complex handling in arbiter if multiple moves are possible
#     return directions[0]

ROUTING_ALGORITHMS = {
    "XY": __route_xy,
    "NEGATIVE_FIRST": __route_negative_first,
    "WEST_FIRST": __route_west_first,
    "NORTH_LEAST": __route_north_last,
    "ODD_EVEN": __route_odd_even
}

######################################
# Selection Strategies Implementations
######################################

SELECTION_STRATEGIES = {
    "RANDOM": lambda buffers: random.choice(buffers),
    "BUFFER_LEVEL": None  # To be implemented,
}

####################################
# Arbiter Algorithms Implementations
####################################


def __realistic_rr_arbiter(arbiter_index: int) -> tuple[str, int]:
    '''
    Realistic Round-Robin arbiter for selecting output direction.
    '''
    DIRECTIONS = ["local", "north", "east", "south", "west"]

    # Get the next direction in round-robin fashion
    next_direction = DIRECTIONS[arbiter_index]
    # Update the index for next call
    arbiter_index = (arbiter_index + 1) % len(DIRECTIONS)
    return next_direction, arbiter_index


ARBITER_ALGORITHMS = {
    "ROUND_ROBIN": __realistic_rr_arbiter
}