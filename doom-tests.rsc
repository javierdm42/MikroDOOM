/system script add name="doom-tests" comment="doom-native/1.1/6.44.1" policy=read,test source={
:local level [:parse [/system script get [find name="doom-levels"] source]]
    :local step [:parse [/system script get [find name="doom-step"] source]]
    :local foes [:parse [/system script get [find name="doom-enemies"] source]]
    :local tone [:parse [/system script get [find name="doom-audio"] source]]
    :local check do={
        :if (!$1) do={ :error ("FALLO: " . $2) }
        :put ("OK " . $2)
    }
    :put "DOOM pruebas | 1 Motor / 2 Tecla / 3 ASCII y ANSI / 4 Audio / 5 E1M1 / Q salir"
    :local k [/terminal inkey timeout=30s]
    :if ($k = 50) do={
        :put "Pulsa W o espera 3s. Esperado: 119 (w), 87 (W), 65535 (tiempo)."
        :put ("Codigo: " . [/terminal inkey timeout=3s])
    }
    :if ($k = 51) do={ :put "ANTES: esta linea debe desaparecer."; :delay 1s; :put "\1B[2J\1B[H#@g D A + K X#"; :put "Si ves residuos, juega en texto normal." }
    :if ($k = 52) do={
        :foreach ev in={"pistol";"shotgun";"hit";"hurt";"ammo";"med";"door";"kill";"win";"over"} do={ :put $ev; $tone $ev; :delay 250ms }
    }
    :if ($k = 53) do={
        :local song [$tone "score"]
        :local order ($song->"order")
        $check ([:len $order] = 710) "partitura E1M1 completa"
        :put "E1M1: introduccion, 16 notas"
        :for i from=0 to=15 do={
            :local slot [:find ($song->"alphabet") [:pick $order $i ($i + 1)]]
            :local hz [$tone "note" $song $slot false]
            $check ($hz = (($song->"hz")->$slot)) ("nota " . ($i + 1))
            :delay (($song->"gap")->$slot)
        }
        :put "PASS E1M1"
    }
    :if ($k = 49) do={
        :local s [$level 1]
        $check ((($s->"hp") = 100) && ([:len ($s->"map")] = 384)) "carga"
        :set s [$step $s 100]
        $check (($s->"pos") = 67) "movimiento"
        :set s [$step $s 100]
        $check ((($s->"reserve") = 26) && ([:pick ($s->"map") 68 69] = ".")) "municion una vez"
        :set s [$level 1]
        :set ($s->"pos") 33
        :set s [$step $s 97]
        $check (($s->"pos") = 33) "pared"
        :set s [$level 1]
        :set s [$step $s 32]
        $check ((($s->"mag") = 5) && ((($s->"eh")->0) = 4)) "disparo e impacto"
        :set s [$step $s 32]
        $check ((($s->"left") = 1) && ((($s->"ep")->0) = -1)) "eliminacion"
        :set s [$step $s 114]
        $check ((($s->"mag") = 6) && (($s->"reserve") = 16)) "recarga"
        :set s [$level 1]
        :set ($s->"ep") {76;184}
        :set s [$step $s 32]
        $check (((($s->"eh")->0) = 12) && (($s->"mag") = 5)) "alcance"
        :set ($s->"pos") 175
        :set ($s->"ep") {178;184}
        :set s [$step $s 32]
        $check (((($s->"eh")->0) = 12) && (($s->"event") = "pistol")) "puerta detiene disparo"
        :set s [$step $s 101]
        $check ([:pick ($s->"map") 176 177] = "D") "puerta cerrada"
        :set ($s->"pos") 258
        :set s [$step $s 115]
        $check (($s->"keys") = 1) "recoger llave"
        :set ($s->"pos") 175
        :set ($s->"dir") 1
        :set s [$step $s 101]
        $check (([:pick ($s->"map") 176 177] = ".") && (($s->"keys") = 0)) "abrir puerta"
        :set s [$level 1]
        :set ($s->"turn") 2
        :set s [$foes $s]
        $check ((($s->"ep")->0) = 70) "deteccion y persecucion"
        :set ($s->"ep") {67;184}
        :set ($s->"armor") 1
        :set s [$foes $s]
        $check ((($s->"hp") = 97) && (($s->"armor") = 0)) "armadura y salud"
        :set ($s->"hp") 1
        :set s [$foes $s]
        $check (($s->"hp") = 0) "muerte"
        :set ($s->"hp") 60
        :set ($s->"pos") 226
        :set s [$step $s 100]
        $check (($s->"hp") = 95) "botiquin"
        :for stage from=1 to=3 do={
            :set s [$level $stage]
            :set ($s->"pos") 317
            :set s [$step $s 101]
            $check (!($s->"done")) ("salida protegida " . $stage)
            :set ($s->"left") 0
            :set s [$step $s 101]
            $check ($s->"done") ("salida habilitada " . $stage)
            :set s [$step $s (48 + $stage)]
            $check (($s->"gun") = $stage) ("arma de sector " . $stage)
        }
        :set s [$level 1]
        :local fp 2
        :set s [$step $s 119 $fp]
        $check ((($s->"pos") = 67) && (($s->"dir") = 1)) "avanzar hacia la mira"
        :set s [$step $s 115 $fp]
        $check ((($s->"pos") = 66) && (($s->"dir") = 1)) "retroceso sin cambiar mira"
        :set s [$step $s 97 $fp]
        $check ((($s->"pos") = 66) && (($s->"dir") = -32)) "giro izquierdo"
        :set s [$step $s 120 $fp]
        $check ((($s->"pos") = 67) && (($s->"dir") = -32)) "paso lateral derecho"
        :set s [$step $s 122 $fp]
        $check ((($s->"pos") = 66) && (($s->"dir") = -32)) "paso lateral izquierdo"
        :put "PASS motor"
    }
}
