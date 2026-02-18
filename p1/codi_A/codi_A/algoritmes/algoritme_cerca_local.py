from abc import ABC, abstractmethod
from problemes.problema import ProblemaCercaLocal


class AlgoritmeCercaLocal(ABC):
    """
    :returns:
        millor_estat: millor estat que ha trobat
        historia: llistat de costos
    """
    @abstractmethod
    def executa(self, problema:ProblemaCercaLocal):

        pass