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
        for i in range(self.n):
            for j in range(i+1, self.n):
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
        for tasca, pos_pref in self.preferencies.items():
            pos_actual = estat.index(tasca)
            cost_total += abs(pos_actual - pos_pref)

        return cost_total
