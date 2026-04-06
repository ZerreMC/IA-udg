;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PROBLEMA SIMPLE A — pb_simplea
;; Evacuació Sector Alfa
;; Sense ordre de dispensació
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
        L61 L63 L66 - cella

        E1 E2 - estanteria
        D - dispensador
    )

    (:init
        ;; Posició inicial dels robots
        (at R1 L61)
        (at R2 L55)
        (occupied L61)
        (occupied L55)
        (handempty R1)
        (handempty R2)

        ;; Estat de les estanteries
        ;; E1: pkg2 (bottom), pkg1 (top)
        (on-shelf pkg2 E1)
        (in-shelf pkg2 E1)
        (on pkg1 pkg2)
        (in-shelf pkg1 E1)
        (clear pkg1)

        ;; E2: pkg3
        (on-shelf pkg3 E2)
        (in-shelf pkg3 E2)
        (clear pkg3)

        ;; Paquets demanats
        (requested pkg1)
        (requested pkg2)
        (requested pkg3)

        ;; Adjacències entre caselles transitables
        ;; Fila 1
        (adjacent L11 L12)
        (adjacent L12 L11)
        (adjacent L12 L13)
        (adjacent L13 L12)
        (adjacent L13 L14)
        (adjacent L14 L13)
        (adjacent L14 L15)
        (adjacent L15 L14)

        ;; Columna esquerra
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

        ;; Adjacències amb objectes especials
        ;; E1 = (2,2)
        (adjacent L12 E1)
        (adjacent L21 E1)

        ;; E2 = (2,5)
        (adjacent L15 E2)
        (adjacent L35 E2)

        ;; D = (4,4)
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
