;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PROBLEMA SIMPLE A — pb_simplea
;; Evacuació Sector Alfa
;; No hi ha ordre de dispensació
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (problem pb_simplea)
  (:domain magabot-simple)

  ;; --------------------------------------------------------------------------
  ;; OBJECTES
  ;; --------------------------------------------------------------------------
  (:objects
      R1 R2 - robot
      pkg1 pkg2 pkg3 - paquet
      L11 L12 L13 L14 L15 L16
      L21 L22 L23 L24 L25 L26
      L31 L32 L33 L34 L35 L36
      L41 L42 L43 L44 L45 L46
      L51 L52 L53 L54 L55 L56
      L61 L62 L63 L64 L65 L66 - lloc

      E1 E2 - estanteria
      D - dispensador
  )

  ;; --------------------------------------------------------------------------
  ;; ESTAT INICIAL
  ;; --------------------------------------------------------------------------
  (:init

      ;; Robots
      (at R1 L61)
      (at R2 L51)

      ;; Estanteries
      (top pkg1 E1)
      (top pkg3 E2)

      ;; Paquets demanats
      (requested pkg1)
      (requested pkg2)
      (requested pkg3)

      ;; Adjacències (només exemples, s’han d’omplir totes)
      ;; Aquí només poso unes quantes per mostrar l’estructura.
      ;; En el teu fitxer final hauràs d’afegir totes les adjacències de la graella.

      (adjacent L61 L51)
      (adjacent L51 L41)
      (adjacent L41 L42)
      (adjacent L42 L43)
      (adjacent L43 L44)

      ;; Assignació de posicions especials
      ;; E1 = (2,2) → L22
      ;; E2 = (2,5) → L25
      ;; D  = (4,4) → L44

      ;; Robots no poden entrar-hi, però poden estar adjacents
  )

  ;; --------------------------------------------------------------------------
  ;; OBJECTIU
  ;; --------------------------------------------------------------------------
  (:goal (and
      (dispensed pkg1)
      (dispensed pkg2)
      (dispensed pkg3)
  ))
)
