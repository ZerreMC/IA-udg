from algoritmes.algoritme_cerca_local import AlgoritmeCercaLocal

class HillClimbing(AlgoritmeCercaLocal):

    def __init__(self, max_iter=500, max_reinici=20):
        self.max_iter = max_iter
        self.max_reinici = max_reinici

    def executa(self, problema):
        millor_estat_global = None
        millor_cost_global = float("inf")
        historia = []

        for _ in range(self.max_reinici):
            estat_actual = problema.estat_inicial()
            cost_actual = problema.cost(estat_actual)

            if cost_actual < millor_cost_global:
                millor_cost_global = cost_actual
                millor_estat_global = list(estat_actual)

            historia.append(millor_cost_global)

            for _ in range(self.max_iter):
                millor_vei = None
                millor_cost_vei = cost_actual

                for vei in problema.veinat(estat_actual):
                    c = problema.cost(vei)
                    if c < millor_cost_vei:
                        millor_cost_vei = c
                        millor_vei = vei

                if millor_vei:
                    estat_actual = millor_vei
                    cost_actual = millor_cost_vei

                    if cost_actual < millor_cost_global:
                        millor_cost_global = cost_actual
                        millor_estat_global = list(estat_actual)

                    historia.append(millor_cost_global)

        return millor_estat_global, historia