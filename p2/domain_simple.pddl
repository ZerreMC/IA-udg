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
  ;; Definim els tipus principals del domini:
  ;; - robot: agents mòbils
  ;; - paquet: objectes que es poden moure
  ;; - lloc: qualsevol casella de la graella
  ;; - estanteria, dispensador: llocs especials
  ;; NOTA: estanteria i dispensador són subclasses de lloc
  ;;       però no són accessibles pels robots (no poden entrar-hi)
  ;; --------------------------------------------------------------------------

    (:types
        robot
        paquet
        lloc
        estanteria - lloc
        dispensador - lloc
    )

  ;; --------------------------------------------------------------------------
  ;; 2. PREDICATS
  ;; --------------------------------------------------------------------------
  ;; - (at ?r ?l)         : robot ?r està a la casella ?l
  ;; - (adjacent ?l1 ?l2) : les caselles són adjacents (moviment permès)
  ;; - (top ?p ?e)        : el paquet ?p és el que està al capdamunt d'una estanteria ?e
  ;; - (carrega-top ?r ?p): el robot ?r porta el paquet ?p al capdamunt de la seva pila
  ;; - (empty ?e)         : l’estanteria està buida
  ;; - (requested ?p)     : el paquet ?p ha de ser dispensat
  ;; --------------------------------------------------------------------------

    (:predicates
        ;; Posició
        (at ?r - robot ?l - lloc)
        (adjacent ?l1 - lloc ?l2 - lloc)
        (free ?l - lloc)
        (transitable ?l - lloc)

        ;; Piles a estanteries
        (on-shelf ?p - paquet ?e - estanteria)
        (on ?p1 - paquet ?p2 - paquet)
        (clear ?p - paquet)
        (shelf-empty ?e - estanteria)

        ;; Robot: només 1 paquet a la vegada
        (holding ?r - robot ?p - paquet)
        (handempty ?r - robot)

        ;; Objectiu
        (requested ?p - paquet)
        (dispensed ?p - paquet)
            
        ;; Ordre
        (can-dispense ?p - paquet)
        (next ?p1 - paquet ?p2 - paquet)
        (last ?p - paquet)
    )

  ;; --------------------------------------------------------------------------
  ;; 3. ACCIONS
  ;; --------------------------------------------------------------------------

  ;; --------------------------------------------------------------------------
  ;; 3.1. Moure un robot
  ;; --------------------------------------------------------------------------
  ;; El robot es pot moure entre caselles adjacents lliures.
  ;; No controlem energia ni càrrega.
  ;; --------------------------------------------------------------------------

    (:action move
        :parameters (?r - robot ?from - lloc ?to - lloc)
        :precondition (and
            (at ?r ?from)
            (adjacent ?from ?to)
            (transitable ?to)
            (free ?to)
        )
        :effect (and
            (not (at ?r ?from))
            (at ?r ?to)
            (free ?from)
            (not (free ?to))
        )
    )

    (:action pick-from-shelf
        :parameters (?r - robot ?p - paquet ?e - estanteria ?l - lloc)
        :precondition (and
            (at ?r ?l)
            (adjacent ?l ?e)
            (on-shelf ?p ?e)
            (clear ?p)
            (handempty ?r)
            (not (dispensed ?p))
        )
        :effect (and
            (holding ?r ?p)
            (not (handempty ?r))
            (not (on-shelf ?p ?e))
            (shelf-empty ?e)
        )
    )

    (:action pick-from-package
        :parameters (?r - robot ?p - paquet ?q - paquet ?e - estanteria ?l - lloc)
        :precondition (and
            (at ?r ?l)
            (adjacent ?l ?e)
            (on ?p ?q)
            (clear ?p)
            (handempty ?r)
            (not (dispensed ?p))
        )
        :effect (and
            (holding ?r ?p)
            (not (handempty ?r))
            (not (on ?p ?q))
            (clear ?q)
        )
    )


  ;; --------------------------------------------------------------------------
  ;; 3.3. Deixar un paquet a una estanteria
  ;; --------------------------------------------------------------------------
  ;; El robot deixa el paquet que porta al capdamunt.
  ;; --------------------------------------------------------------------------

    (:action drop-on-empty-shelf
        :parameters (?r - robot ?p - paquet ?e - estanteria ?l - lloc)
        :precondition (and
            (at ?r ?l)
            (adjacent ?l ?e)
            (holding ?r ?p)
            (shelf-empty ?e)
            (not (dispensed ?p))
        )
        :effect (and
            (on-shelf ?p ?e)
            (clear ?p)
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
            (clear ?q)
            (not (dispensed ?p))
        )
        :effect (and
            (on ?p ?q)
            (clear ?p)
            (not (clear ?q))
            (handempty ?r)
            (not (holding ?r ?p))
        )
    )

    (:action dispense-free
        :parameters (?r - robot ?p - paquet ?d - dispensador ?l - lloc)
        :precondition (and
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
        :parameters (?r - robot ?p - paquet ?pnext - paquet ?d - dispensador ?l - lloc)
        :precondition (and
            (at ?r ?l)
            (adjacent ?l ?d)
            (holding ?r ?p)
            (requested ?p)
            (can-dispense ?p)
            (next ?p ?pnext)
            (not (dispensed ?p))
        )
        :effect (and
            (dispensed ?p)
            (not (can-dispense ?p))
            (can-dispense ?pnext)
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
