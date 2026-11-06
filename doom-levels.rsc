/system script add name="doom-levels" comment="doom-native/1.1/6.44.1" policy=read,test source={
:local stage $1
    :local tiles ""
    :local title ""
    :local spots [:toarray ""]
    :local health [:toarray ""]
    :local kinds ""
    :if ($stage = 1) do={
        :set title "Base abandonada"
        :set tiles ($tiles . "################################")
        :set tiles ($tiles . "#...............#..............#")
        :set tiles ($tiles . "#...A...........#..............#")
        :set tiles ($tiles . "#...............#..............#")
        :set tiles ($tiles . "#...#######.....#..............#")
        :set tiles ($tiles . "#...............D..............#")
        :set tiles ($tiles . "#...............#.+............#")
        :set tiles ($tiles . "#..+............#...#######....#")
        :set tiles ($tiles . "#...........A...#..............#")
        :set tiles ($tiles . "#.K.............#...A........X.#")
        :set tiles ($tiles . "#...............#..............#")
        :set tiles ($tiles . "################################")
        :set spots {71;184}
        :set health {12;12}
        :set kinds "gg"
    }
    :if ($stage = 2) do={
        :set title "Instalacion industrial"
        :set tiles ($tiles . "################################")
        :set tiles ($tiles . "#..................#...........#")
        :set tiles ($tiles . "#...A..............#...........#")
        :set tiles ($tiles . "#..................#...####....#")
        :set tiles ($tiles . "#.....###...###....#...........#")
        :set tiles ($tiles . "#.....###...###....D...........#")
        :set tiles ($tiles . "#.....###...###....#.+.........#")
        :set tiles ($tiles . "#..+..###...###....#...####....#")
        :set tiles ($tiles . "#...........A......#...........#")
        :set tiles ($tiles . "#.K................#...A.....X.#")
        :set tiles ($tiles . "#..................#...........#")
        :set tiles ($tiles . "################################")
        :set spots {72;272;187}
        :set health {12;12;28}
        :set kinds "rgT"
    }
    :if ($stage = 3) do={
        :set title "Sector infernal"
        :set tiles ($tiles . "################################")
        :set tiles ($tiles . "#.............#................#")
        :set tiles ($tiles . "#...A.........#................#")
        :set tiles ($tiles . "#.............#...###..........#")
        :set tiles ($tiles . "#...#####.....#...###..........#")
        :set tiles ($tiles . "#...#####.....D...###..........#")
        :set tiles ($tiles . "#.............#.+..............#")
        :set tiles ($tiles . "#..+..........#........###.....#")
        :set tiles ($tiles . "#...........A.#........###.....#")
        :set tiles ($tiles . "#.K...........#...A..........X.#")
        :set tiles ($tiles . "#.............#................#")
        :set tiles ($tiles . "################################")
        :set spots {73;264;183;316}
        :set health {28;12;12;70}
        :set kinds "TrgB"
    }
    :if ([:len $tiles] != 384) do={ :error "doom-levels: nivel desconocido" }
    :local s [:toarray ""]
    :set ($s->"stage") $stage
    :set ($s->"title") $title
    :set ($s->"map") $tiles
    # In v6, array literals can persist across calls to the same parsed function.
    :local liveSpots [:toarray ""]
    :local liveHealth [:toarray ""]
    :foreach v in=$spots do={ :set liveSpots ($liveSpots,$v) }
    :foreach v in=$health do={ :set liveHealth ($liveHealth,$v) }
    :set ($s->"ep") $liveSpots
    :set ($s->"eh") $liveHealth
    :set ($s->"kinds") $kinds
    :set ($s->"left") [:len $spots]
    :set ($s->"pos") 66
    :set ($s->"dir") 1
    :set ($s->"hp") 100
    :set ($s->"armor") 15
    :set ($s->"mag") 6
    :set ($s->"reserve") 18
    :set ($s->"gun") 1
    :set ($s->"keys") 0
    :set ($s->"score") 0
    :set ($s->"turn") 0
    :set ($s->"diff") 2
    :set ($s->"msg") "Encuentra K, abre D y limpia el sector."
    :set ($s->"event") ""
    :set ($s->"shot") false
    :set ($s->"done") false
    :return $s
}
