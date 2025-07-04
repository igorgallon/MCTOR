import threading
from datetime import datetime

class Packet:
    
    _id_counter = 0
    _lock = threading.Lock()

    @classmethod
    def next_id(cls):
        '''
        Generates a unique ID for each packet.
        '''
        with cls._lock:
            cls._id_counter += 1
            return cls._id_counter

    def __init__(self, src, dst, payload):
        '''
        Initializes a new Packet instance.
            :param src: Source coordinates (x, y) of the packet.
            :param dst: Destination coordinates (x, y) of the packet.
            :param payload: The data payload of the packet.
        '''
        self.id = Packet.next_id()
        self.src = src # Source coordinates (x, y) of the packet
        self.dst = dst # Destination coordinates (x, y) of the packet
        self.payload = payload # Data carried by the packet
        self.hops = 0 # Number of hops the packet has made
        self.creation_time = datetime.now() # Time when the packet was created
        self.deliver_time = 0 # Time when the packet was delivered (0 if not yet delivered)
        # print(f"Created packet #{self.id} from {self.src} to {self.dst} with payload: {self.payload}")

    def has_arrived(self):
        '''
        Marks the packet as arrived by setting the delivery time.
        This method should be called when the packet reaches its destination.
        '''
        self.deliver_time = datetime.now()
        print(f"Packet #{self.id} arrived to {self.dst}!")