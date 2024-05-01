class CompositeStatusLogger:
    def __init__(self, *status_loggers):
        self.status_loggers = list(status_loggers)

    def add_logger(self, status_logger):
        self.status_loggers.append(status_logger)

    def __getattr__(self, attr):
        def method_call(*args, **kwargs):
            for status_logger in self.status_loggers:
                getattr(status_logger, attr)(*args, **kwargs)

        return method_call
