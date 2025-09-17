from datetime import datetime
import queue
import time
import threading

class MetricsCollector:
    _instance = None
    _lock = threading.Lock()


    def __new__(cls):
        with cls._lock:
            if cls._instance is None:
                cls._instance = super().__new__(cls)
                cls._instance.metrics_queue = queue.Queue(maxsize=10000)
                cls._instance.metrics_list = []
                cls._instance.metrics_list_lock = threading.Lock()
                cls._instance.metrics_file_name = f"noc_simulator/simulation_results/metrics_{time.strftime('%Y%m%d_%H%M%S')}.csv"
            return cls._instance

    def push_metric(self, metric):
        if not isinstance(metric, dict):
            raise ValueError("Metric must be a dictionary.")
        m = {
            'source': metric.get('source', ''),
            'type': metric.get('type', ''),
            'timestamp': datetime.now(),
            'packet_id': metric.get('packet_id', ''),
            'src': metric.get('src', ''),
            'dst': metric.get('dst', ''),
            'hops': metric.get('hops', 0),
            'from_dir': metric.get('from_dir', ''),
            'to_dir': metric.get('to_dir', ''),
            'creation_time': metric.get('creation_time', ''),
            'deliver_time': metric.get('deliver_time', ''),
            "traffic": metric.get("traffic", ''),
            "weight": metric.get("weight", '')
        }        
        self.metrics_queue.put(m)
        with self.metrics_list_lock:
            self.metrics_list.append(m)

    def get_metric(self):
        try:
            return self.metrics_queue.get_nowait()
        except queue.Empty:
            return None
        
    def get_all_metrics(self):
        with self.metrics_list_lock:
            return list(self.metrics_list)