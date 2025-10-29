# Maximum number of elements in a income/outcome buffers
MAX_BUFFER_SIZE = 10

LINK_BANDWIDTH = 1  # packets per cycle

NUMBER_OF_CYCLES = 500 # Total number of cycles for the each simulation

INJECTION_INTERVAL_SECONDS = 0.7  # Interval between packet injections
RT_SLEEP_THREAD_SECONDS = 0.2
PE_SLEEP_RETRY_SECONDS = 1
PLOTTER_UPDATE_INTERVAL_SECONDS = 10
METRICS_COLLECTOR_INTERVAL_SECONDS = 10

ENABLE_RETRY_MECHANISM = False  # Enable retry mechanism for sending packets when the queue is full
RETRY_LIMIT = 3  # Number of retries for sending packets when the queue is full

DEBUGGER_MODE = False  # Set to True to enable debugging mode