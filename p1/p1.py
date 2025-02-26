import numpy as np
from timeit import default_timer as timer
import copy
import os


def distancia(p1, p2):
    """ Distància Euclidiana entre dos punts"""
    return np.linalg.norm(p1 - p2)


def funcio_avaluacio(assignacio, data):
    """
        Funció d'avaluació d'una assignació de grups a punts de dades.
        Retorna un valor que indica com de bona és l'assignació.
    """
    # Inicialitzem la suma de les distàncies
    suma_distancies = 0

    # Per cada grup
    for grup in np.unique(assignacio):
        # Seleccionem els punts assignats a aquest grup
        punts = data[assignacio == grup]
        if len(punts) > 1: # Si hi ha més d'un punt
            # Calculem la mitjana dels punts del grup
            mitjana = np.mean(punts, axis=0)
            suma_distancies += np.sum([distancia(p, mitjana) for p in punts])

    return suma_distancies


def generar_veins(assignacio_actual, n_grups):
    """
        Genera veïns canviant la assignació d'un hospital a un altre grup.
        Retorna una llista amb les assignacions veïnes.
    """
    veins = []
    for i in range(len(assignacio_actual)): # Per cada element
        for nou_grup in range(n_grups): # Per cada grup
            if nou_grup != assignacio_actual[i]:  # Evita assignar al mateix grup
                nova_assignacio = assignacio_actual.copy()
                nova_assignacio[i] = nou_grup
                veins.append(nova_assignacio)
    return veins


def cerca_local_beam(problema, beam_size=5, iteracions=10):
    """ 
        Executa la cerca local per feixos (beams).
        `beam_size` determina el nombre d'assignacions que passen entre iteracions
        `iterations` determina el nombre d'iteracions
    """

    # CREAR i GUARDAR a `beam` les `beam_size` assignacions inicials
    n_elements = problema["n_elements"]
    n_grups = problema["n_grups"]
    beam = [np.random.randint(0, n_grups, n_elements) for _ in range(beam_size)]

    # AVALUAR les assignacions inicials
    avaluacions = [funcio_avaluacio(assignacio, problema["data"]) for assignacio in beam]

    millor_assignacio = beam[np.argmin(avaluacions)]
    millor_valor = min(avaluacions)
    
    # Per cada iteració, mentre sigui necessari:
    for _ in range(iteracions):
        veins = []

        # BUSCAR VEINS de cada assignació del beam que milloren l'actual
        for assignacio in beam:
            veins.extend(generar_veins(assignacio, n_grups))

        # AVALUAR-LOS
        veins_avaluats = [(vei, funcio_avaluacio(vei, problema["data"])) for vei in veins]
        veins_avaluats.sort(key=lambda x: x[1]) # Ordenar per valor d'avaluació (menor distància mitjana)
        
        # SELECCIONAR els `beam_size` millors veins i GUARDAR-los a `beam`
        beam = [vei[0] for vei in veins_avaluats[:beam_size]]
        avaluacions = [vei[1] for vei in veins_avaluats[:beam_size]]

        # COMPROVAR si calen més iteracions
        if avaluacions[0] < millor_valor:
            millor_assignacio = beam[0]
            millor_valor = avaluacions[0]
        else:
            break # Si no millora, sortir del bucle

    # RETORNAR millor assignació del beam
    return millor_assignacio


def get_data_path(nom_fitxer):
    """ Retorna el path del directori de dades."""
    script_dir = os.path.dirname(os.path.abspath(__file__))  # Ruta del script actual
    return os.path.join(script_dir, nom_fitxer)


def main():
    # ------------------------------------------------------------
    # 1. Configurem el problema ----------------------------------
    np.random.seed(11) # Fixem la llavor per reproducibilitat

    # Carreguem les dades
    data_path = get_data_path("datapoints.csv")
    try:
        X = np.loadtxt("datapoints.csv", delimiter=",", dtype=float, skiprows=1)
    except FileNotFoundError:
        print(f"Error: No s'ha trobat el fitxer {data_path}")
        return

    problema = dict()
    problema["data"] = X
    problema["n_elements"] = X.shape[0]
    problema["ndim"] = X.shape[1]

    problema["n_grups"] = 4
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
