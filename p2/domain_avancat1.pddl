(define (domain magabot_avancat1)
    (:requirements :strips :typing :negative-preconditions :numeric-fluents :conditional-effects)
    ; Afegeix numeric-fluents per gestionar bateria, càrrega i energia.
    ; Afegeix conditional-effects per permetre recàrrega parcial o total.
    (:types
        location dispenser charger package robot shelf - stack_element
        ; stack_element és un supertipus per representar elements apilables:
        ; robots (com a base d'una pila)
    )

    (:predicates
        (at ?r - robot ?l - location)
        (occupied ?l - location)
        (connected ?l1 - location ?l2 - location)

        (adjacent-shelf ?l - location ?s - shelf)
        (adjacent-dispenser ?l - location ?d - dispenser)
        (adjacent-charger ?l - location ?c - charger)

        (on ?top - package ?bottom - stack_element)
        (clear ?x - stack_element)
        (in-stack ?x - stack_element ?base - stack_element)

        (dispensed ?p - package)
        (next-to-dispense ?p - package)
        (order-seq ?curr - package ?next - package)
    )

    (:functions
        (battery ?r - robot) ; nivell de bateria actual del robot
        (max-battery ?r - robot) ; capacitat màxima de bateria del robot
        (load ?r - robot) ; càrrega actual del robot (suma dels pesos dels paquets que porta)
        (max-load ?r - robot) ; capacitat màxima de càrrega del robot
        (weight ?p - package) ; pes de cada paquet
        (total-energy-used) ; energia total consumida per tots els robots (per a estadístiques)
    )

    ; El robot es mou portant poca càrrega. Consumeix menys bateria (2 unitats) i només pot fer-ho si la càrrega és inferior a 5 i té bateria suficient.
    (:action moure-lleuger
        :parameters (?r - robot ?from - location ?to - location)
        :precondition (and
            (at ?r ?from)
            (connected ?from ?to)
            (not (occupied ?to))
            (< (load ?r) 5)
            (>= (battery ?r) 2)
        )
        :effect (and
            (not (at ?r ?from))
            (not (occupied ?from))
            (at ?r ?to)
            (occupied ?to)
            (decrease (battery ?r) 2)
            (increase (total-energy-used) 2)
        )
    )

    ; El robot es mou portant molta càrrega. Consumeix més bateria (3 unitats) i només pot fer-ho si la càrrega és igual o superior a 5.
    (:action moure-pesat
        :parameters (?r - robot ?from - location ?to - location)
        :precondition (and
            (at ?r ?from)
            (connected ?from ?to)
            (not (occupied ?to))
            (>= (load ?r) 5)
            (>= (battery ?r) 3)
        )
        :effect (and
            (not (at ?r ?from))
            (not (occupied ?from))
            (at ?r ?to)
            (occupied ?to)
            (decrease (battery ?r) 3)
            (increase (total-energy-used) 3)
        )
    )

    ; El robot recull un paquet de la prestatgeria. A més de les condicions d'apilat, comprova que el pes total no superi la seva capacitat màxima. L'acció incrementa la càrrega del robot segons el pes del paquet.
    (:action agafar
        :parameters (?r - robot ?loc - location ?s - shelf ?p - package ?p_under - stack_element ?r_top - stack_element)
        :precondition (and
            (at ?r ?loc)
            (adjacent-shelf ?loc ?s)
            (clear ?p)
            (on ?p ?p_under)
            (in-stack ?p ?s)
            (clear ?r_top)
            (in-stack ?r_top ?r)
            (<= (+ (load ?r) (weight ?p)) (max-load ?r))
        )
        :effect (and
            (not (on ?p ?p_under))
            (not (in-stack ?p ?s))
            (clear ?p_under)
            (not (clear ?r_top))
            (on ?p ?r_top)
            (in-stack ?p ?r)
            (increase (load ?r) (weight ?p))
        )
    )

    ; El robot deixa un paquet a la prestatgeria. A més de moure el paquet entre piles, redueix la càrrega total del robot segons el pes del paquet.
    (:action descarregar
        :parameters (?r - robot ?loc - location ?s - shelf ?p - package ?p_under - stack_element ?s_top - stack_element)
        :precondition (and
            (at ?r ?loc)
            (adjacent-shelf ?loc ?s)
            (clear ?p)
            (on ?p ?p_under)
            (in-stack ?p ?r)
            (clear ?s_top)
            (in-stack ?s_top ?s)
        )
        :effect (and
            (not (on ?p ?p_under))
            (not (in-stack ?p ?r))
            (clear ?p_under)
            (not (clear ?s_top))
            (on ?p ?s_top)
            (in-stack ?p ?s)
            (decrease (load ?r) (weight ?p))
        )
    )

    ; El robot dispensa un paquet al dispensador. A més de marcar-lo com dispensat i avançar la seqüència, redueix la càrrega del robot.
    (:action dispensar
        :parameters (?r - robot ?loc - location ?d - dispenser ?p - package ?p_under - stack_element ?p_next - package)
        :precondition (and
            (at ?r ?loc)
            (adjacent-dispenser ?loc ?d)
            (clear ?p)
            (on ?p ?p_under)
            (in-stack ?p ?r)
            (next-to-dispense ?p)
            (order-seq ?p ?p_next)
        )
        :effect (and
            (not (on ?p ?p_under))
            (clear ?p_under)
            (not (in-stack ?p ?r))
            (not (clear ?p))
            (dispensed ?p)
            (not (next-to-dispense ?p))
            (next-to-dispense ?p_next)
            (decrease (load ?r) (weight ?p))
        )
    )

    ; El robot recarrega la bateria quan està al costat d'un carregador. Utilitza efectes condicionals per evitar superar la bateria màxima:
    ; - Si hi ha espai suficient, afegeix 20 unitats.
    ; - Si no, assigna directament la bateria màxima.
    (:action recarregar
        :parameters (?r - robot ?loc - location ?c - charger)
        :precondition (and
            (at ?r ?loc)
            (adjacent-charger ?loc ?c)
            (< (battery ?r) (max-battery ?r))
        )
        :effect (and
            (when
                (<= (+ (battery ?r) 20) (max-battery ?r))
                (increase (battery ?r) 20))
            (when
                (> (+ (battery ?r) 20) (max-battery ?r))
                (assign (battery ?r) (max-battery ?r)))
        )
    )
)