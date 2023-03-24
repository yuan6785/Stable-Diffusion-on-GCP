import multiprocessing
import concurrent.futures
import threading

name = 'bounded_pool_executor'


class _BoundedPoolExecutor(object):

    semaphore = None

    def acquire(self):
        self.semaphore.acquire()

    def release(self, fn):
        self.semaphore.release()

    def submit(self, fn, *args, **kwargs):
        self.acquire()
        future = super(_BoundedPoolExecutor, self).submit(fn, *args, **kwargs)
        future.add_done_callback(self.release)

        return future


class BoundedProcessPoolExecutor(_BoundedPoolExecutor, concurrent.futures.ProcessPoolExecutor):

    def __init__(self, max_workers=None):
        super(BoundedProcessPoolExecutor, self).__init__(max_workers)
        self.semaphore = multiprocessing.BoundedSemaphore(max_workers)


class BoundedThreadPoolExecutor(_BoundedPoolExecutor, concurrent.futures.ThreadPoolExecutor):

    def __init__(self, max_workers=None):
        super(BoundedThreadPoolExecutor, self).__init__(max_workers)
        self.semaphore = threading.BoundedSemaphore(max_workers)

