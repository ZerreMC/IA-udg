import random
from problemes.problema import ProblemaCercaLocal

class ElMeuProblema(ProblemaCercaLocal):

    def __init__(self, matriu_cost, preferencies):
        self.C = matriu_cost
        self.preferencies = dict(preferencies)
        self.n = len(matriu_cost)

    def estat_inicial(self):
        estat = list(range(self.n))
        random.shuffle(estat)
        return estat

    def veinat(self, estat):
        veins = []
        n = len(estat)
        for i in range(n - 1):
            for j in range(i+1, n):
                nou = estat.copy()
                nou[i], nou[j] = nou[j], nou[i]
                veins.append(nou)
        return veins

    def cost(self, estat):
        cost_total = 0

        # Cost per parelles consecutives
        for i in range(self.n - 1):
            x = estat[i]
            y = estat[i+1]
            cost_total += self.C[x][y]

        # Penalització per preferències
        if self.preferencies:
            pos = [0] * self.n
            for idx, tasca in enumerate(estat):
                pos[tasca] = idx
            for tasca, pos_ideal in self.preferencies:
                cost_total += abs(pos[tasca] - pos_ideal)

        return cost_total
