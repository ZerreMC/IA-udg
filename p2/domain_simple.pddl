;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DOMAIN SIMPLE MAGABOT
;; Model bàsic sense energia ni pesos
;; Corregit per reduir grounding: les accions de moviment i operació
;; treballen només amb caselles transitables (cella)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (domain magabot-simple)
    (:requirements :strips :typing :negative-preconditions)

    (:types
        robot
        paquet
        lloc
        cella - lloc
        estanteria - lloc
        dispensador - lloc
    )

    (:predicates
        ;; Posició i navegació
        (at ?r - robot ?l - cella)
        (adjacent ?l1 - lloc ?l2 - lloc)
        (occupied ?l - cella)

        ;; Piles a estanteries
        (on-shelf ?p - paquet ?e - estanteria)
        (on ?p1 - paquet ?p2 - paquet)
        (in-shelf ?p - paquet ?e - estanteria)
        (clear ?p - paquet)
        (shelf-empty ?e - estanteria)

        ;; Estat del robot
        (holding ?r - robot ?p - paquet)
        (handempty ?r - robot)

        ;; Objectius
        (requested ?p - paquet)
        (dispensed ?p - paquet)

        ;; Variants ordenades
        (ordered-mission)
        (can-dispense ?p - paquet)
        (next ?p1 - paquet ?p2 - paquet)
        (last ?p - paquet)
    )

    (:action move
        :parameters (?r - robot ?from - cella ?to - cella)
        :precondition (and
            (at ?r ?from)
            (adjacent ?from ?to)
            (not (occupied ?to))
        )
        :effect (and
            (not (at ?r ?from))
            (at ?r ?to)
            (occupied ?to)
            (not (occupied ?from))
        )
    )

    (:action pick-from-shelf
        :parameters (?r - robot ?p - paquet ?e - estanteria ?l - cella)
        :precondition (and
            (at ?r ?l)
            (adjacent ?l ?e)
            (on-shelf ?p ?e)
            (in-shelf ?p ?e)
            (clear ?p)
            (handempty ?r)
            (not (dispensed ?p))
        )
        :effect (and
            (holding ?r ?p)
            (not (handempty ?r))
            (not (on-shelf ?p ?e))
            (not (in-shelf ?p ?e))
            (shelf-empty ?e)
        )
    )

    (:action pick-from-package
        :parameters (?r - robot ?p - paquet ?q - paquet ?e - estanteria ?l - cella)
        :precondition (and
            (at ?r ?l)
            (adjacent ?l ?e)
            (on ?p ?q)
            (in-shelf ?p ?e)
            (in-shelf ?q ?e)
            (clear ?p)
            (handempty ?r)
            (not (dispensed ?p))
        )
        :effect (and
            (holding ?r ?p)
            (not (handempty ?r))
            (not (on ?p ?q))
            (not (in-shelf ?p ?e))
            (clear ?q)
        )
    )

    (:action drop-on-empty-shelf
        :parameters (?r - robot ?p - paquet ?e - estanteria ?l - cella)
        :precondition (and
            (at ?r ?l)
            (adjacent ?l ?e)
            (holding ?r ?p)
            (shelf-empty ?e)
            (not (dispensed ?p))
        )
        :effect (and
            (on-shelf ?p ?e)
            (in-shelf ?p ?e)
            (clear ?p)
            (not (shelf-empty ?e))
            (handempty ?r)
            (not (holding ?r ?p))
        )
    )

    (:action drop-on-package
        :parameters (?r - robot ?p - paquet ?q - paquet ?e - estanteria ?l - cella)
        :precondition (and
            (at ?r ?l)
            (adjacent ?l ?e)
            (holding ?r ?p)
            (clear ?q)
            (in-shelf ?q ?e)
            (not (dispensed ?p))
        )
        :effect (and
            (on ?p ?q)
            (in-shelf ?p ?e)
            (clear ?p)
            (not (clear ?q))
            (handempty ?r)
            (not (holding ?r ?p))
        )
    )

    (:action dispense-free
        :parameters (?r - robot ?p - paquet ?d - dispensador ?l - cella)
        :precondition (and
            (not (ordered-mission))
            (at ?r ?l)
            (adjacent ?l ?d)
            (holding ?r ?p)
            (requested ?p)
            (not (dispensed ?p))
        )
        :effect (and
            (dispensed ?p)
            (handempty ?r)
            (not (holding ?r ?p))
        )
    )

    (:action dispense-ordered-next
        :parameters (?r - robot ?p - paquet ?p2 - paquet ?d - dispensador ?l - cella)
        :precondition (and
            (ordered-mission)
            (at ?r ?l)
            (adjacent ?l ?d)
            (holding ?r ?p)
            (requested ?p)
            (can-dispense ?p)
            (next ?p ?p2)
            (not (dispensed ?p))
        )
        :effect (and
            (dispensed ?p)
            (not (can-dispense ?p))
            (can-dispense ?p2)
            (handempty ?r)
            (not (holding ?r ?p))
        )
    )

    (:action dispense-ordered-last
        :parameters (?r - robot ?p - paquet ?d - dispensador ?l - cella)
        :precondition (and
            (ordered-mission)
            (at ?r ?l)
            (adjacent ?l ?d)
            (holding ?r ?p)
            (requested ?p)
            (can-dispense ?p)
            (last ?p)
            (not (dispensed ?p))
        )
        :effect (and
            (dispensed ?p)
            (not (can-dispense ?p))
            (handempty ?r)
            (not (holding ?r ?p))
        )
    )
)
