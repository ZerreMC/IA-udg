(define (domain magabot_simple)
    (:requirements :strips :typing :negative-preconditions)

    (:types
        location dispenser package robot shelf - stack_element
    )

    (:predicates
        (at ?r - robot ?l - location)
        (occupied ?l - location)
        (connected ?l1 - location ?l2 - location)

        (adjacent-shelf ?l - location ?s - shelf)
        (adjacent-dispenser ?l - location ?d - dispenser)

        (on ?top - package ?bottom - stack_element)
        (clear ?x - stack_element)

        (in-stack ?x - stack_element ?base - stack_element)

        (dispensed ?p - package)

        ;; Control de permisos
        (allowed-to-dispense ?p - package)

        ;; Control d’ordre
        (phase2)
        (phase3)

        ;; Identificadors de paquets
        (is-pkg2 ?p - package)
        (is-pkg3 ?p - package)
    )

    (:action moure
        :parameters (?r - robot ?from - location ?to - location)
        :precondition (and
            (at ?r ?from)
            (connected ?from ?to)
            (not (occupied ?to))
        )
        :effect (and
            (not (at ?r ?from))
            (not (occupied ?from))
            (at ?r ?to)
            (occupied ?to)
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
        )
        :effect (and
            (not (on ?p ?p_under))
            (not (in-stack ?p ?s))
            (clear ?p_under)

            (not (clear ?r_top))
            (on ?p ?r_top)
            (in-stack ?p ?r)
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
        )
    )

    (:action dispensar
        :parameters (?r - robot ?loc - location ?d - dispenser ?p - package ?p_under - stack_element)
        :precondition (and
            (at ?r ?loc)
            (adjacent-dispenser ?loc ?d)

            (clear ?p)
            (on ?p ?p_under)
            (in-stack ?p ?r)

            (allowed-to-dispense ?p)
        )
        :effect (and
            (not (on ?p ?p_under))
            (clear ?p_under)
            (not (in-stack ?p ?r))
            (not (clear ?p))
            (dispensed ?p)
        )
    )

    ;; Accions de control d’ordre
    (:action mark-phase2
        :parameters (?p - package)
        :precondition (and
            (is-pkg2 ?p)
            (dispensed ?p)
            (not (phase2))
        )
        :effect (phase2)
    )

    (:action mark-phase3
        :parameters (?p - package)
        :precondition (and
            (is-pkg3 ?p)
            (phase2)
            (dispensed ?p)
            (not (phase3))
        )
        :effect (phase3)
    )
)
