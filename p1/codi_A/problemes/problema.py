from abc import ABC, abstractmethod

class ProblemaCercaLocal(ABC):

    @abstractmethod
    def estat_inicial(self):
        pass

    @abstractmethod
    def veinat(self, estat):
        pass

    @abstractmethod
    def cost(self, estat):
        pass

    """es_millor compara dos estats del problema
    Assumeix que és un problema de *minimització*
    :param estat1: primer estat a comparar
    :param estat2: segon estat a comparar
    :return:  si l'estat1 té un cost menor que l'estat2"""
    def es_millor(self, estat1, estat2):
        return self.cost(estat1) < self.cost(estat2)


    """ mètodes necessaris si volem fer servir un algoritme genètic """
    def introdueix_canvi_aleatori(self, estat):
        raise NotImplementedError

    def combina_dos_estats(self, estat1, estat2):
        raise NotImplementedError



