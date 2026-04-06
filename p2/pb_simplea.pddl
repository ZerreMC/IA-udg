(define (problem pb_simplea)
    (:domain magabot_simple)
    (:objects
        r1 r2 - robot
        pkg1 pkg2 pkg3 - package
        l11 l12 l13 l14 l15 l21 l31 l33 l35 l41 l43 l45 l51 l52 l53 l54 l55 l56 l61 l63 - location
        e1 e2 - shelf
        d - dispenser
    )
    (:init
        (allowed-to-dispense pkg1)
        (allowed-to-dispense pkg2)
        (allowed-to-dispense pkg3)

        (at r1 l61)
        (at r2 l55)

        (clear r1)
        (clear r2)

        (occupied l61)
        (occupied l55)

        (on pkg1 pkg2)
        (on pkg2 e1)
        (clear pkg1)

        (on pkg3 e2)
        (clear pkg3)

        (in-stack e1 e1)
        (in-stack e2 e2)
        (in-stack r1 r1)
        (in-stack r2 r2)
        (in-stack pkg1 e1)
        (in-stack pkg2 e1)
        (in-stack pkg3 e2)

        (connected l11 l12)
        (connected l12 l11)
        (connected l12 l13)
        (connected l13 l12)
        (connected l13 l14)
        (connected l14 l13)
        (connected l14 l15)
        (connected l15 l14)

        (connected l11 l21)
        (connected l21 l11)
        (connected l21 l31)
        (connected l31 l21)
        (connected l31 l41)
        (connected l41 l31)
        (connected l41 l51)
        (connected l51 l41)
        (connected l51 l61)
        (connected l61 l51)

        (connected l51 l52)
        (connected l52 l51)
        (connected l52 l53)
        (connected l53 l52)
        (connected l53 l54)
        (connected l54 l53)
        (connected l54 l55)
        (connected l55 l54)
        (connected l55 l56)
        (connected l56 l55)

        (connected l33 l43)
        (connected l43 l33)
        (connected l43 l53)
        (connected l53 l43)
        (connected l53 l63)
        (connected l63 l53)

        (connected l35 l45)
        (connected l45 l35)
        (connected l45 l55)
        (connected l55 l45)

        (adjacent-shelf l12 e1)
        (adjacent-shelf l21 e1)

        (adjacent-shelf l15 e2)

        (adjacent-dispenser l43 d)
        (adjacent-dispenser l45 d)
        (adjacent-dispenser l54 d)
    )
    (:goal
        (and
            (dispensed pkg1)
            (dispensed pkg2)
            (dispensed pkg3)
        )
    )
)