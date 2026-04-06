;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DOMAIN SIMPLE MAGABOT
;; Model bàsic sense energia ni pesos
;; Només es controla moviment, agafar, deixar i dispensar
;; Totes les accions són deterministes i sense costos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (domain magabot-simple)
    (:requirements :strips :typing :negative-preconditions)
    ;; --------------------------------------------------------------------------
    ;; 1. TIPUS
    ;; --------------------------------------------------------------------------

    (:types
        robot
        paquet
        lloc
        estanteria - lloc      ; lloc especial no transitable
        dispensador - lloc     ; lloc especial no transitable
    )

  ;; --------------------------------------------------------------------------
  ;; 2. PREDICATS
  ;; --------------------------------------------------------------------------

    (:predicates
        ;; Posició i navegació
        (at ?r - robot ?l - lloc)          ; robot ?r està a la casella ?l
        (adjacent ?l1 - lloc ?l2 - lloc)   ; caselles veïnes, moviment permès
        (occupied ?l - lloc)               ; la casella està ocupada
        (transitable ?l - lloc)            ; el robot pot entrar-hi

        ;; Piles a estanteries
        (on-shelf ?p - paquet ?e - estanteria) ; paquet ?p està directament sobre l’estanteria
        (on ?p1 - paquet ?p2 - paquet)         ; paquet ?p1 apilat sobre ?p2
        (in-shelf ?p - paquet ?e - estanteria)
        (clear ?p - paquet)                    ; paquet sense res a sobre
        (shelf-empty ?e - estanteria)          ; estanteria sense cap paquet

        ;; Estat del robot
        (holding ?r - robot ?p - paquet)       ; robot sosté el paquet
        (handempty ?r - robot)                 ; robot no sosté res

        ;; Objectius
        (requested ?p - paquet)                ; paquet que cal dispensar
        (dispensed ?p - paquet)                ; paquet ja dispensat

        ;; Ordre de dispensació
        (can-dispense ?p - paquet)             ; paquet que toca dispensar ara
        (next ?p1 - paquet ?p2 - paquet)       ; després de ?p1 toca ?p2
        (last ?p - paquet)                     ; últim paquet de la seqüència
    )

  ;; --------------------------------------------------------------------------
  ;; 3. ACCIONS
  ;; --------------------------------------------------------------------------

  ;; --------------------------------------------------------------------------
  ;; 3.1. Moure un robot
  ;; --------------------------------------------------------------------------

    (:action move
        :parameters (?r - robot ?from - lloc ?to - lloc)
        :precondition (and
            (at ?r ?from)        ; el robot és al punt d’origen
            (adjacent ?from ?to) ; els llocs són adjacents
            (transitable ?to)    ; el robot pot entrar a ?to
            (not (occupied ?to)) ; la casella destí està lliure
        )
        :effect (and
            (not (at ?r ?from))     ; deixa el lloc d’origen
            (at ?r ?to)             ; passa al lloc destí
            (occupied ?to)          ; el lloc destí queda ocupat
            (not (occupied ?from))  ;
        )
    )

  ;; --------------------------------------------------------------------------
  ;; 3.2. Agafar paquets
  ;; --------------------------------------------------------------------------

    (:action pick-from-shelf
        :parameters (?r - robot ?p - paquet ?e - estanteria ?l - lloc)
        :precondition (and
            (at ?r ?l)           ; robot a la casella adjacent
            (adjacent ?l ?e)
            (on-shelf ?p ?e)     ; paquet sobre l’estanteria
            (in-shelf ?p ?e)
            (clear ?p)           ; paquet sense res a sobre
            (handempty ?r)       ; robot amb mà buida
            (not (dispensed ?p)) ; no dispensat encara
        )
        :effect (and
            (holding ?r ?p)      ; ARA EL ROBOT SOSTÉ EL PAQUET
            (not (handempty ?r))
            (not (on-shelf ?p ?e)) ; ja no és a l’estanteria
            (shelf-empty ?e)       ; l’estanteria queda buida
            (not (in-shelf ?p ?e))
        )
    )

    (:action pick-from-package
        :parameters (?r - robot ?p - paquet ?q - paquet ?e - estanteria ?l - lloc)
        :precondition (and
            (at ?r ?l)
            (adjacent ?l ?e)
            (on ?p ?q)           ; ?p està sobre ?q
            (in-shelf ?p ?e)
            (in-shelf ?q ?e)
            (clear ?p)           ; ?p és el paquet superior
            (handempty ?r)
            (not (dispensed ?p))
        )
        :effect (and
            (holding ?r ?p) 
            (not (handempty ?r))
            (not (on ?p ?q))     ; es desfà la relació d’apilat
            (not (in-shelf ?p ?e))
            (clear ?q)           ; ?q queda lliure a sobre
        )
    )

  ;; --------------------------------------------------------------------------
  ;; 3.3. Deixar paquets
  ;; --------------------------------------------------------------------------

    (:action drop-on-empty-shelf
        :parameters (?r - robot ?p - paquet ?e - estanteria ?l - lloc)
        :precondition (and
            (at ?r ?l)
            (adjacent ?l ?e)
            (holding ?r ?p)      ; robot sosté el paquet
            (shelf-empty ?e)     ; estanteria buida
            (not (dispensed ?p))
        )
        :effect (and
            (on-shelf ?p ?e)     ; paquet col·locat a l’estanteria
            (in-shelf ?p ?e)
            (clear ?p)           ; queda com a paquet superior
            (not (shelf-empty ?e))
            (handempty ?r)
            (not (holding ?r ?p))
        )
    )

    (:action drop-on-package
        :parameters (?r - robot ?p - paquet ?q - paquet ?e - estanteria ?l - lloc)
        :precondition (and
            (at ?r ?l)
            (adjacent ?l ?e)
            (holding ?r ?p)
            (clear ?q)           ; paquet base lliure
            (in-shelf ?q ?e)
            (not (dispensed ?p))
        )
        :effect (and
            (on ?p ?q)           ; ?p queda sobre ?q
            (in-shelf ?p ?e)     ; ASSIGNACIÓ CORREGIDA (?p en comptes de ?q)
            (clear ?p)           ; ?p és el nou paquet superior
            (not (clear ?q))     ; ?q deixa d’estar lliure
            (handempty ?r)
            (not (holding ?r ?p))
        )
    )

  ;; --------------------------------------------------------------------------
  ;; 3.4. Dispensar paquets
  ;; --------------------------------------------------------------------------

    (:action dispense-free
        :parameters (?r - robot ?p - paquet ?d - dispensador ?l - lloc)
        :precondition (and
            (at ?r ?l)
            (adjacent ?l ?d)
            (holding ?r ?p)
            (requested ?p)       ; paquet sol·licitat
            (not (dispensed ?p))
        )
        :effect (and
            (dispensed ?p)       ; marcat com a dispensat
            (handempty ?r)
            (not (holding ?r ?p))
        )
    )
)