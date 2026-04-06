;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DOMAIN SIMPLE MAGABOT
;; Model bàsic sense energia ni pesos
;; Només es controla moviment, agafar, deixar i dispensar
;; Totes les accions són deterministes i sense costos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (domain magabot-simple)

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
        (free ?l - lloc)                   ; la casella està lliure
        (transitable ?l - lloc)            ; el robot pot entrar-hi

        ;; Piles a estanteries
        (on-shelf ?p - paquet ?e - estanteria) ; paquet ?p està directament sobre l’estanteria
        (on ?p1 - paquet ?p2 - paquet)         ; paquet ?p1 apilat sobre ?p2
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
            (free ?to)           ; la casella destí està lliure
        )
        :effect (and
            (not (at ?r ?from))  ; deixa el lloc d’origen
            (at ?r ?to)          ; passa al lloc destí
            (free ?from)         ; el lloc d’origen queda lliure
            (not (free ?to))     ; el lloc destí queda ocupat
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
            (clear ?p)           ; paquet sense res a sobre
            (handempty ?r)       ; robot amb mà buida
            (not (dispensed ?p)) ; no dispensat encara
        )
        :effect (and
            (holding ?r ?p)      ; robot sosté el paquet
            (not (handempty ?r))
            (not (on-shelf ?p ?e)) ; ja no és a l’estanteria
            (shelf-empty ?e)       ; l’estanteria queda buida
        )
    )

    (:action pick-from-package
        :parameters (?r - robot ?p - paquet ?q - paquet ?e - estanteria ?l - lloc)
        :precondition (and
            (at ?r ?l)
            (adjacent ?l ?e)
            (on ?p ?q)           ; ?p està sobre ?q
            (clear ?p)           ; ?p és el paquet superior
            (handempty ?r)
            (not (dispensed ?p))
        )
        :effect (and
            (holding ?r ?p)      ; robot sosté ?p
            (not (handempty ?r))
            (not (on ?p ?q))     ; es desfà la relació d’apilat
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
            (not (dispensed ?p))
        )
        :effect (and
            (on ?p ?q)           ; ?p queda sobre ?q
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

    (:action dispense-ordered-next
        :parameters (?r - robot ?p - paquet ?pnext - paquet ?d - dispensador ?l - lloc)
        :precondition (and
            (at ?r ?l)
            (adjacent ?l ?d)
            (holding ?r ?p)
            (requested ?p)
            (can-dispense ?p)    ; és el paquet que toca
            (next ?p ?pnext)     ; el següent serà ?pnext
            (not (dispensed ?p))
        )
        :effect (and
            (dispensed ?p)
            (not (can-dispense ?p))
            (can-dispense ?pnext) ; activem el següent
            (handempty ?r)
            (not (holding ?r ?p))
        )
    )

    (:action dispense-ordered-last
        :parameters (?r - robot ?p - paquet ?d - dispensador ?l - lloc)
        :precondition (and
            (at ?r ?l)
            (adjacent ?l ?d)
            (holding ?r ?p)
            (requested ?p)
            (can-dispense ?p)
            (last ?p)            ; és l’últim de la seqüència
            (not (dispensed ?p))
        )
        :effect (and
            (dispensed ?p)
            (not (can-dispense ?p)) ; ja no queda res més per dispensar
            (handempty ?r)
            (not (holding ?r ?p))
        )
    )
)
