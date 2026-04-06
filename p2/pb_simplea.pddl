;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PROBLEMA SIMPLE A — pb_simplea
;; Evacuació Sector Alfa
;; Sense ordre de dispensació
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (problem pb_simplea)
    (:domain magabot-simple)

    (:objects
        R1 R2 - robot
        pkg1 pkg2 pkg3 - paquet

        ;; Caselles transitables del mapa
        L11 L12 L13 L14 L15
        L21
        L31 L33 L35
        L41 L43 L45
        L51 L52 L53 L54 L55 L56
        L61 L63 L66 - lloc

        E1 E2 - estanteria
        D - dispensador
    )

    (:init
        ;; -----------------------------------------------------------
        ;; POSICIÓ INICIAL DELS ROBOTS
        ;; pb_simplea: R1 a (6,1), R2 a (5,5)
        ;; -----------------------------------------------------------
        (at R1 L61)
        (at R2 L55)

        (occupied L61)
        (occupied L55)

        (handempty R1)
        (handempty R2)

        ;; -----------------------------------------------------------
        ;; CASELLES TRANSITABLES
        ;; -----------------------------------------------------------
        (transitable L11)
        (transitable L12)
        (transitable L13)
        (transitable L14)
        (transitable L15)
        (transitable L21)
        (transitable L31)
        (transitable L33)
        (transitable L35)
        (transitable L41)
        (transitable L43)
        (transitable L45)
        (transitable L51)
        (transitable L52)
        (transitable L53)
        (transitable L54)
        (transitable L55)
        (transitable L56)
        (transitable L61)
        (transitable L63)
        (transitable L66)

        ;; -----------------------------------------------------------
        ;; ESTAT DE LES ESTANTERIES
        ;; E1: pkg2 (bottom), pkg1 (top)
        ;; E2: pkg3
        ;; -----------------------------------------------------------
        (on-shelf pkg2 E1)
        (in-shelf pkg2 E1)
        (on pkg1 pkg2)
        (in-shelf pkg1 E1)
        (clear pkg1)

        (on-shelf pkg3 E2)
        (in-shelf pkg3 E2)
        (clear pkg3)

        ;; E1 i E2 no són buides
        ;; No posem (shelf-empty E1) ni (shelf-empty E2)

        ;; -----------------------------------------------------------
        ;; PAQUETS DEMANATS
        ;; simplea NO té ordre
        ;; -----------------------------------------------------------
        (requested pkg1)
        (requested pkg2)
        (requested pkg3)

        ;; -----------------------------------------------------------
        ;; ADJACÈNCIES ENTRE CASELLES TRANSITABLES
        ;; -----------------------------------------------------------

        ;; Fila 1
        (adjacent L11 L12)
        (adjacent L12 L11)

        (adjacent L12 L13)
        (adjacent L13 L12)

        (adjacent L13 L14)
        (adjacent L14 L13)

        (adjacent L14 L15)
        (adjacent L15 L14)

        ;; Verticals esquerra
        (adjacent L11 L21)
        (adjacent L21 L11)

        (adjacent L21 L31)
        (adjacent L31 L21)

        (adjacent L31 L41)
        (adjacent L41 L31)

        (adjacent L41 L51)
        (adjacent L51 L41)

        (adjacent L51 L61)
        (adjacent L61 L51)

        ;; Columna 3
        (adjacent L33 L43)
        (adjacent L43 L33)

        (adjacent L43 L53)
        (adjacent L53 L43)

        (adjacent L53 L63)
        (adjacent L63 L53)

        ;; Columna 5
        (adjacent L35 L45)
        (adjacent L45 L35)

        (adjacent L45 L55)
        (adjacent L55 L45)

        ;; Columna 6
        (adjacent L56 L66)
        (adjacent L66 L56)

        ;; Fila 5
        (adjacent L51 L52)
        (adjacent L52 L51)

        (adjacent L52 L53)
        (adjacent L53 L52)

        (adjacent L53 L54)
        (adjacent L54 L53)

        (adjacent L54 L55)
        (adjacent L55 L54)

        (adjacent L55 L56)
        (adjacent L56 L55)

        ;; -----------------------------------------------------------
        ;; ADJACÈNCIES AMB OBJECTES ESPECIALS
        ;; E1 = (2,2)
        ;; E2 = (2,5)
        ;; D  = (4,4)
        ;; -----------------------------------------------------------

        ;; E1
        (adjacent L12 E1)
        (adjacent L21 E1)

        ;; E2
        (adjacent L15 E2)
        (adjacent L35 E2)

        ;; D
        (adjacent L43 D)
        (adjacent L45 D)
        (adjacent L54 D)
    )

    (:goal
        (and
            (dispensed pkg1)
            (dispensed pkg2)
            (dispensed pkg3)
        )
    )
)