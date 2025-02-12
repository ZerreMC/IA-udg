import numpy as np
from timeit import default_timer as timer
import copy


def distancia(p1, p2):
    """ Distància Euclidiana entre dos punts"""
    return np.linalg.norm(p1 - p2)


def cerca_local_beam(problema, beam_size=5, iteracions=10):
    """ Executa la cerca local per feixos (beams).
    `beam_size` determina el nombre d'assignacions que passen entre iteracions
    `iterations` determina el nombre d'iteracions"""
    # CREAR i GUARDAR a `beam` les `beam_size` assignacions inicials
    # AVALUAR les assignacions inicials

    # Per cada iteració, mentre sigui necessari:
        # BUSCAR VEINS de cada assignació del beam que milloren l'actual
        # AVALUAR-LOS
        # SELECCIONAR els `beam_size` millors veins i GUARDAR-los a `beam`

        # COMPROVAR si calen més iteracions

    # RETORNAR millor assignació del beam


def main():
    # ------------------------------------------------------------
    # 1. Configurem el problema ----------------------------------
    np.random.seed(11) # Fixem la llavor per reproducibilitat

    # Carreguem les dades
    X = np.loadtxt("datapoints.csv", delimiter=",", dtype=float, skiprows=1)

    problema = dict()
    problema["data"] = X
    problema["n_elements"] = X.shape[0]
    problema["ndim"] = X.shape[1]

    problema["n_groups"] = 4
    # Defineix i enllaça aquí la funció d'avaluació
    #problema["f_aval"] = la_meva_funcio_davaluacio


    # ------------------------------------------------------------
    # 2. Configurem i executem la cerca local beam ---------------
    beam_size = 5  # B
    n_iterations = 100  # K


    t_start = timer()
    res = cerca_local_beam(problema, beam_size, n_iterations)
    t_end = timer()

    print("Millor assignació trobada:", res)
    print("En", t_end - t_start, "segons.")


    # ------------------------------------------------------------
    # ----------- Com fer servir el codi que us donem ------------
    # ------------------------------------------------------------
    # Càlcul de la distància entre dos punts
    print("Distància entre punts 1 i 2:", distancia(problema["data"][1,:], problema["data"][2,:]))


if __name__ == '__main__':
    main()
