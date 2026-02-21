import random
from algoritmes.algoritme_cerca_local import AlgoritmeCercaLocal

class HillClimbing(AlgoritmeCercaLocal):
    def __init__(self, max_iter=500, max_reinici=20):
        self.max_iter = max_iter
        self.max_reinici = max_reinici