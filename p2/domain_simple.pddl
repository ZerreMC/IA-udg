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
      (at ?r - robot ?l - lloc)
      (adjacent ?l1 - lloc ?l2 - lloc)

      ;; Estanteries
      (top ?p - paquet ?e - estanteria)
      (empty ?e - estanteria)

      ;; Robots carregant paquets
      (carrega-top ?r - robot ?p - paquet)

      ;; Paquets que cal dispensar
      (requested ?p - paquet)

      ;; Paquets ja dispensats
      (dispensed ?p - paquet)
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
      )
      :effect (and
          (not (at ?r ?from))
          (at ?r ?to)
      )
  )

  ;; --------------------------------------------------------------------------
  ;; 3.2. Agafar un paquet d'una estanteria
  ;; --------------------------------------------------------------------------
  ;; Només es pot agafar el paquet del capdamunt.
  ;; El robot ha d'estar en una casella adjacent a l'estanteria.
  ;; --------------------------------------------------------------------------

  (:action pick
      :parameters (?r - robot ?p - paquet ?e - estanteria ?l - lloc)
      :precondition (and
          (at ?r ?l)
          (adjacent ?l ?e)
          (top ?p ?e)
      )
      :effect (and
          ;; El paquet passa a ser el top del robot
          (carrega-top ?r ?p)
          ;; L'estanteria deixa de tenir aquest paquet al top
          (not (top ?p ?e))
      )
  )

  ;; --------------------------------------------------------------------------
  ;; 3.3. Deixar un paquet a una estanteria
  ;; --------------------------------------------------------------------------
  ;; El robot deixa el paquet que porta al capdamunt.
  ;; --------------------------------------------------------------------------

  (:action drop
      :parameters (?r - robot ?p - paquet ?e - estanteria ?l - lloc)
      :precondition (and
          (at ?r ?l)
          (adjacent ?l ?e)
          (carrega-top ?r ?p)
      )
      :effect (and
          ;; El paquet passa a ser el top de l'estanteria
          (top ?p ?e)
          ;; El robot deixa de portar-lo
          (not (carrega-top ?r ?p))
      )
  )

  ;; --------------------------------------------------------------------------
  ;; 3.4. Dispensar un paquet al dispensador
  ;; --------------------------------------------------------------------------
  ;; El robot ha d'estar adjacent al dispensador.
  ;; Només pot dispensar el paquet que porta al top.
  ;; --------------------------------------------------------------------------

  (:action dispense
      :parameters (?r - robot ?p - paquet ?d - dispensador ?l - lloc)
      :precondition (and
          (at ?r ?l)
          (adjacent ?l ?d)
          (carrega-top ?r ?p)
          (requested ?p)
      )
      :effect (and
          (dispensed ?p)
          (not (carrega-top ?r ?p))
      )
  )
)
