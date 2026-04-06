(define (domain magabot_avancat1)
    (:requirements :strips :typing :negative-preconditions :numeric-fluents :conditional-effects)

    (:types
        location dispenser charger package robot shelf - stack_element
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
        (battery ?r - robot)
        (max-battery ?r - robot)
        (load ?r - robot)
        (max-load ?r - robot)
        (weight ?p - package)
        (total-energy-used)
    )

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