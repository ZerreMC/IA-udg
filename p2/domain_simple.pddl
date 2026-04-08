(define (domain magabot_simple)
    (:requirements :strips :typing :negative-preconditions)

    (:types
        location dispenser package robot shelf - stack_element
        ; stack_element és un supertipus per representar elements apilables:
        ; robots (com a base d'una pila)
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

        (next-to-dispense ?p - package)
        (order-seq ?curr - package ?next - package)
    )

    ; Permet al robot desplaçar-se entre ubicacions connectades sempre que la destinació estigui lliure. Manté la coherència de l'estat actualitzant "occupied" i la posició del robot
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

    ; El robot recull un paquet de la prestatgeria. El paquet ha de ser el de dalt de la pila (clear), i el robot ha de tenir un punt superior lliure per carregar-lo. L'acció mou el paquet de la pila de la prestatgeria a la pila del robot.
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

    ; El robot deixa un paquet a la prestatgeria. El paquet ha de ser el de dalt de la pila del robot, i la prestatgeria ha de tenir un punt superior lliure. L'acció mou el paquet de la pila del robot a la pila de la prestatgeria.
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

    ; El robot lliura un paquet al dispensador. Només pot dispensar el paquet marcat com a "next-to-dispense", i l'acció actualitza la seqüència perquè el següent paquet passi a ser el nou objectiu. El paquet es treu de la pila del robot i es marca com a dispensat.
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
        )
    )
)