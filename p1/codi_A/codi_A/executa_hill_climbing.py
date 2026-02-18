import random
import numpy as np

from problemes.el_meu_problema import ElMeuProblema
from algoritmes.hill_climbing import HillClimbing

def main():
    np.random.seed(31)
    random.seed(31)

    n = 30

    """ DEFINICIO DEL PROBLEMA """

    matriu_cost = np.random.randint(0, 10, size=(n, n))
    preferencies = []
    k = random.sample(range(n // 5), 1)[0]  # màxim una 5a part d'elements tenen una posició ideal
    for elem in random.sample(range(n), k):
        pos = random.randint(0, n - 1)
        preferencies.append((elem, pos))
    problema = ElMeuProblema(matriu_cost, preferencies)


    """ EXECUTA ALGORITME """

    algo = HillClimbing()
    solucio, historic_cost = algo.executa(problema)

    print("Solució:",solucio)
    print("Cost final:", historic_cost[-1])

    print("Num. iterations:", len(historic_cost))
    print("Històric de cost:", historic_cost)


if __name__ == "__main__":
    main()