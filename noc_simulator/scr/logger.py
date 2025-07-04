from datetime import datetime
import logging

def singleton(cls):
    instances = {}

    def get_instance(*args, **kwargs):
        if cls not in instances:
            instances[cls] = cls(*args, **kwargs)
        return instances[cls]

    return get_instance

@singleton
class Logger:
    
    def __init__(self):
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        logging.basicConfig(filename=f"noc_simulator_{timestamp}.log", level=logging.DEBUG)
        self.logger = logging.getLogger(__name__)
    
    def get_logger(self):
        return self.logger