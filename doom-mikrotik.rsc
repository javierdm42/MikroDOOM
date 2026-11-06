/system script add name="doom-step" comment="doom-native/1.1/6.44.1" policy=read,test source={
# Pure turn resolver. State is returned to the caller; it never touches the router.
    :local s $1
    :local key $2
    :local pos ($s->"pos")
    :local dir ($s->"dir")
    :local tiles ($s->"map")
    :local ep ($s->"ep")
    :local eh ($s->"eh")
    :local gun ($s->"gun")
    :local step 0
    :set ($s->"event") ""
    :set ($s->"shot") false
    :set ($s->"msg") ""
    :if ($key = 119) do={ :set step -32 }
    :if ($key = 115) do={ :set step 32 }
    :if ($key = 97) do={ :set step -1 }
    :if ($key = 100) do={ :set step 1 }
    :local fp ($3 = 2)
    :set ($s->"bob") false
    :if ($fp && (($key = 97) || ($key = 100) || ($key = 122) || ($key = 120))) do={
        :local right 32
        :if ($dir = 32) do={ :set right -1 }
        :if ($dir = -1) do={ :set right -32 }
        :if ($dir = -32) do={ :set right 1 }
        :if (($key = 97) || ($key = 122)) do={ :set right (0 - $right) }
        :if (($key = 122) || ($key = 120)) do={ :set step $right } else={
            :set ($s->"dir") $right
            :set step 0
        }
    }
    :if ($fp && ($key = 119)) do={ :set step $dir }
    :if ($fp && ($key = 115)) do={ :set step (0 - $dir) }
    :if ($step != 0) do={
        :if (!$fp) do={ :set ($s->"dir") $step }
        :local dest ($pos + $step)
        :local tile [:pick $tiles $dest ($dest + 1)]
        :local free (($tile != "#") && ($tile != "D"))
        :foreach spot in=$ep do={ :if ($spot = $dest) do={ :set free false } }
        :if ($free) do={
            :set ($s->"pos") $dest
            :set ($s->"bob") ((($s->"turn") % 2) = 0)
            :if ($tile = "A") do={ :set ($s->"reserve") (($s->"reserve") + 8); :set ($s->"event") "ammo"; :set ($s->"msg") "Municion +8" }
            :if ($tile = "+") do={
                :local healed (($s->"hp") + 35)
                :if ($healed > 100) do={ :set healed 100 }
                :set ($s->"hp") $healed
                :set ($s->"event") "med"
                :set ($s->"msg") "Botiquin"
            }
            :if ($tile = "K") do={ :set ($s->"keys") 1; :set ($s->"msg") "Tienes la llave"; :set ($s->"event") "ammo" }
            :if (($tile = "A") || ($tile = "+") || ($tile = "K")) do={
                :set ($s->"map") ([:pick $tiles 0 $dest] . "." . [:pick $tiles ($dest + 1) [:len $tiles]])
            }
        } else={ :set ($s->"msg") "Paso bloqueado" }
    }
    :if ($key = 102) do={
        :local rot 1
        :if ($dir = 1) do={ :set rot 32 }
        :if ($dir = 32) do={ :set rot -1 }
        :if ($dir = -1) do={ :set rot -32 }
        :set ($s->"dir") $rot
    }
    :if (($key >= 49) && ($key <= 51)) do={
        :if (($key - 48) <= ($s->"stage")) do={ :set ($s->"gun") ($key - 48); :set ($s->"msg") "Arma lista" } else={ :set ($s->"msg") "Arma bloqueada" }
    }
    :if ($key = 114) do={
        :local rounds (6 - ($s->"mag"))
        :if ($rounds > ($s->"reserve")) do={ :set rounds ($s->"reserve") }
        :set ($s->"mag") (($s->"mag") + $rounds)
        :set ($s->"reserve") (($s->"reserve") - $rounds)
        :set ($s->"msg") ("Recarga +" . $rounds)
    }
    :if ($key = 101) do={
        :local dest ($pos + $dir)
        :local tile [:pick $tiles $dest ($dest + 1)]
        :if ($tile = "D") do={
            :if (($s->"keys") > 0) do={
                :set ($s->"map") ([:pick $tiles 0 $dest] . "." . [:pick $tiles ($dest + 1) [:len $tiles]])
                :set ($s->"keys") 0
                :set ($s->"msg") "Puerta abierta"
                :set ($s->"event") "door"
            } else={ :set ($s->"msg") "Necesitas K" }
        } else={
            :if (($tile = "X") || ([:pick $tiles $pos ($pos + 1)] = "X")) do={
                :if (($s->"left") = 0) do={ :set ($s->"done") true } else={ :set ($s->"msg") "Quedan enemigos" }
            } else={ :set ($s->"msg") "Mira hacia D o X" }
        }
    }
    :if ($key = 32) do={
        :if (($s->"mag") = 0) do={ :set ($s->"msg") "Sin cartuchos: R recarga" } else={
            :set ($s->"mag") (($s->"mag") - 1)
            :set ($s->"shot") true
            :set ($s->"event") "pistol"
            :local reach 9
            :local power 8
            :if ($gun = 2) do={ :set reach 5; :set power 18; :set ($s->"event") "shotgun" }
            :if ($gun = 3) do={ :set reach 12; :set power 28 }
            :local travel 0
            :local blocked false
            :set ($s->"msg") "Disparo al vacio"
            :while (($travel < $reach) && (!$blocked)) do={
                :set travel ($travel + 1)
                :local dest ($pos + $dir * $travel)
                :local tile [:pick $tiles $dest ($dest + 1)]
                :set blocked (($tile = "#") || ($tile = "D"))
                :if (!$blocked) do={
                    :for i from=0 to=([:len $ep] - 1) do={
                        :if (($ep->$i) = $dest) do={
                            :set blocked true
                            :set ($eh->$i) (($eh->$i) - $power)
                            :set ($s->"event") "hit"
                            :set ($s->"msg") ("Impacto -" . $power)
                            :if (($eh->$i) <= 0) do={
                                :set ($ep->$i) -1
                                :set ($s->"left") (($s->"left") - 1)
                                :set ($s->"score") (($s->"score") + 100)
                                :set ($s->"event") "kill"
                                :set ($s->"msg") "Enemigo eliminado +100"
                            }
                        }
                    }
                }
            }
        }
    }
    :set ($s->"ep") $ep
    :set ($s->"eh") $eh
    :set ($s->"turn") (($s->"turn") + 1)
    :return $s
}

/system script add name="doom-enemies" comment="doom-native/1.1/6.44.1" policy=read,test source={
:local s $1
    :local ep ($s->"ep")
    :local tiles ($s->"map")
    :local pos ($s->"pos")
    :local kinds ($s->"kinds")
    :local turn ($s->"turn")
    :local diff ($s->"diff")
    :local harm 0
    :for i from=0 to=([:len $ep] - 1) do={
        :local enemy ($ep->$i)
        :if ($enemy >= 0) do={
            :local kind [:pick $kinds $i ($i + 1)]
            :local dx (($pos % 32) - ($enemy % 32))
            :local dy (($pos / 32) - ($enemy / 32))
            :local ax $dx
            :local ay $dy
            :if ($ax < 0) do={ :set ax (0 - $ax) }
            :if ($ay < 0) do={ :set ay (0 - $ay) }
            :local distance ($ax + $ay)
            :local base 3
            :local pace 2
            :if ($kind = "r") do={ :set base 2; :set pace 1 }
            :if ($kind = "T") do={ :set base 6; :set pace 3 }
            :if ($kind = "B") do={ :set base 9 }
            :if ($distance = 1) do={ :set harm ($harm + $base + $diff - 1) } else={
                :local moves [:toarray ""]
                :if ($distance <= (5 + $diff)) do={
                    :if ((($turn + $i) % $pace) = 0) do={
                        :local hx 0
                        :local vy 0
                        :if ($dx > 0) do={ :set hx 1 }
                        :if ($dx < 0) do={ :set hx -1 }
                        :if ($dy > 0) do={ :set vy 32 }
                        :if ($dy < 0) do={ :set vy -32 }
                        :set moves ($hx,$vy)
                        :if ($ay > $ax) do={ :set moves ($vy,$hx) }
                    }
                } else={
                    :if ((($turn + $i) % 4) = 0) do={
                        :local delta 1
                        :if (((($turn + $i) / 4) % 2) = 1) do={ :set delta -1 }
                        :set moves [:toarray $delta]
                    }
                }
                :local moved false
                :foreach delta in=$moves do={
                    :if ((!$moved) && ($delta != 0)) do={
                        :local dest ($enemy + $delta)
                        :local tile [:pick $tiles $dest ($dest + 1)]
                        :local free (($dest != $pos) && ($tile != "#") && ($tile != "D"))
                        :foreach spot in=$ep do={ :if ($spot = $dest) do={ :set free false } }
                        :if ($free) do={ :set ($ep->$i) $dest; :set moved true }
                    }
                }
            }
        }
    }
    :set ($s->"ep") $ep
    :if ($harm > 0) do={
        :local absorb ($s->"armor")
        :if ($absorb > $harm) do={ :set absorb $harm }
        :set ($s->"armor") (($s->"armor") - $absorb)
        :local hp (($s->"hp") - $harm + $absorb)
        :if ($hp < 0) do={ :set hp 0 }
        :set ($s->"hp") $hp
        :set ($s->"msg") (($s->"msg") . " Ataque -" . $harm)
        :if (($s->"event") = "") do={ :set ($s->"event") "hurt" }
    }
    :return $s
}

/system script add name="doom-render" comment="doom-native/1.1/6.44.1" policy=read,test source={
:local s $1
    :local view $2
    :local ansi $3
    :local frame ""
    :if ($ansi) do={ :set frame "\1B[2J\1B[H" }
    :local tiles ($s->"map")
    :local ep ($s->"ep")
    :local kinds ($s->"kinds")
    :local pos ($s->"pos")
    :local dir ($s->"dir")
    :local label "E"
    :local lateral 32
    :if ($dir = -1) do={ :set label "O"; :set lateral -32 }
    :if ($dir = -32) do={ :set label "N"; :set lateral 1 }
    :if ($dir = 32) do={ :set label "S"; :set lateral -1 }
    :for i from=0 to=([:len $ep] - 1) do={
        :local e ($ep->$i)
        :if ($e >= 0) do={ :set tiles ([:pick $tiles 0 $e] . [:pick $kinds $i ($i + 1)] . [:pick $tiles ($e + 1) [:len $tiles]]) }
    }
    :if (($view = 2) && $ansi) do={
        # The WinBox terminal accepts standard foreground/background colour pairs.
        # Each ray fills three character columns. Emit a colour only when it changes.
        :local rows [:toarray ""]
        :local inks [:toarray ""]
        :for y from=0 to=12 do={ :set rows ($rows,""); :set inks ($inks,"") }
        :local peaks {2;3;3;2;1;1;2;3;2;2;3;4;3;2;2;1;2;3;3;2;1}
        :local shift 0
        :if ($dir = 32) do={ :set shift 5 }
        :if ($dir = -1) do={ :set shift 11 }
        :if ($dir = -32) do={ :set shift 16 }
        :local guns {"....____....";".../|==|\\...";"..//|__|\\\\..";"./_/|==|\\_\\."}
        :if (($s->"gun") = 2) do={ :set guns {"...__..__...";"..|()||()|..";"..|==||==|..";"./========\\."} }
        :if (($s->"gun") = 3) do={ :set guns {"...______...";"..[o::::o]..";"..[======]..";"./__|##|__\\."} }
        :local weaponX 25
        :if (($s->"bob") = true) do={ :set weaponX 26 }
        :local scene ""
        :for col from=0 to=20 do={
            :local cell $pos
            :local depth 0
            :local drift 0
            :local wall ""
            :local actor ""
            :local actorZ 99
            :local side 0
            :local item ""
            :local itemZ 99
            :while (($depth < 14) && ($wall = "")) do={
                :set depth ($depth + 1)
                :set cell ($cell + $dir)
                :local offset ((($col - 10) * $depth) / 10)
                :local tile [:pick $tiles $cell ($cell + 1)]
                :if (($tile != "#") && ($tile != "D")) do={
                    :set cell ($cell + ($offset - $drift) * $lateral)
                    :set tile [:pick $tiles $cell ($cell + 1)]
                }
                :set drift $offset
                :if (($tile = "#") || ($tile = "D")) do={ :set wall $tile } else={
                    :if ($tile != ".") do={
                        :local miss (($col - 10) * $depth - 10 * $offset)
                        :if ($miss < 0) do={ :set miss (0 - $miss) }
                        :if ($miss <= (2 + $depth / 2)) do={
                            :if (($actor = "") && ([:typeof [:find "grTB" $tile]] = "num")) do={ :set actor $tile; :set actorZ $depth; :set side (($col - 10) * $depth - 10 * $offset) }
                            :if (($item = "") && ([:typeof [:find "A+KX" $tile]] = "num")) do={ :set item $tile; :set itemZ $depth }
                        }
                    }
                }
            }
            :local half (10 / $depth)
            :local top (6 - $half)
            :local bottom (6 + $half)
            :local ridge ($peaks->(($col + $shift) % 21))
            :local lastRidge ($peaks->(($col + $shift + 20) % 21))
            :local slope "___"
            :if ($ridge > $lastRidge) do={ :set slope "\\__" }
            :if ($ridge < $lastRidge) do={ :set slope "__/" }
            :local plate (($cell + $col) % 4)
            :local floorY (7 + 7 / $itemZ)
            :local actorHalf (7 / $actorZ)
            :if ($actorHalf > 3) do={ :set actorHalf 3 }
            :for y from=0 to=12 do={
                :local ink "30;47"
                :local v "   "
                :if ($y >= $ridge) do={ :set ink "37;40"; :set v "   " }
                :if ($y = $ridge) do={ :set ink "30;47"; :set v $slope }
                :if ($y >= 6) do={
                    :set ink "30;43"
                    :local joint ((($col - 10) * ($y - 5) + $pos) % 7)
                    :if ($joint = 0) do={ :set v "|  " } else={ :set v "   " }
                    :if (($y = 9) || ($y = 12)) do={ :set v "---" }
                }
                :if (($wall != "") && ($y >= $top) && ($y <= $bottom)) do={
                    :set ink "30;47"
                    :set v "   "
                    :if ($depth > 6) do={ :set ink "37;40"; :set v ":::" }
                    :if (($plate = 0) && ($depth <= 6)) do={ :set v "|  " }
                    :if (($y = $top) || ($y = $bottom)) do={ :set v "===" }
                    :if (($y = 6) && ($depth <= 4) && ($plate = 2)) do={ :set ink "30;43"; :set v "/!\\" }
                    :if ($wall = "D") do={ :set ink "30;46"; :set v "|||"; :if ($y = 6) do={ :set ink "30;43"; :set v "[D]" } }
                }
                :if (($item != "") && ($y = $floorY)) do={
                    :set ink "30;43"; :set v ("[" . $item . "]")
                    :if ($item = "+") do={ :set ink "31;47" }
                    :if ($item = "X") do={ :set ink "37;42" }
                }
                :if (($actor != "") && ($y >= (6 - $actorHalf)) && ($y <= (6 + $actorHalf))) do={
                    # One silhouette per actor, projected across the rays that hit it.
                    :local part ($y - 6)
                    :local center (($side >= (0 - $actorZ / 2)) && ($side <= ($actorZ / 2)))
                    :local gear "37;41"
                    :if ($actor = "T") do={ :set gear "30;46" }
                    :if ($actor = "B") do={ :set gear "33;41" }
                    :if ($center) do={
                        :set ink $gear; :set v "[#]"
                        :if ($part < 0) do={ :set ink "30;43"; :set v "o^o" }
                        :if ($part < -1) do={ :set ink "37;40"; :set v "___" }
                        :if ($part > 0) do={ :set ink "37;40"; :set v "| |" }
                    } else={
                        :if ($part = 0) do={ :set ink $gear; :set v "/=="; :if ($side > 0) do={ :set v "==\\" } }
                        :if ($part = 1) do={ :set ink "30;43"; :set v " _/"; :if ($side > 0) do={ :set v "\\_ " } }
                        :if ($part > 1) do={ :set ink "37;40"; :set v " /|"; :if ($side > 0) do={ :set v "|\\ " } }
                    }
                }
                :if (($col = 10) && ($y = 6) && ($actor = "") && ($wall != "D")) do={ :set v " + " }
                :if (($col = 10) && ($y = 8) && ($s->"shot")) do={ :set ink "33;41"; :set v "\\*/" }
                :if (($y >= 9) && ($col >= 8) && ($col <= 12)) do={
                    :local gunLine ($guns->($y - 9))
                    :local chunk ""
                    :for j from=0 to=2 do={
                        :local gx ($col * 3 + $j - $weaponX)
                        :local glyph "."
                        :if (($gx >= 0) && ($gx < 12)) do={ :set glyph [:pick $gunLine $gx ($gx + 1)] }
                        :if ($glyph != ".") do={ :set chunk ($chunk . $glyph) } else={ :set chunk ($chunk . " ") }
                    }
                    :if ($chunk != "   ") do={ :set v $chunk; :set ink "37;40" }
                }
                :local line ($rows->$y)
                :if (($inks->$y) != $ink) do={
                    :set line ($line . "\1B[" . $ink . "m")
                    :set ($inks->$y) $ink
                }
                :set ($rows->$y) ($line . $v)
            }
        }
        :local nl "\r\n"
        :local reset "\1B[0m"
        :set scene ("\1B[2J\1B[H\1B[37;40m DOOM  |  " . ($s->"stage") . "/3   " . ($s->"title") . "  |  " . $label . " " . $reset . $nl)
        :foreach line in=$rows do={ :set scene ($scene . $line . $reset . $nl) }
        :local names {"Pistola";"Escopeta";"Canon"}
        :set scene ($scene . "\1B[37;41m VIDA " . ($s->"hp") . "% \1B[30;47m ARM " . ($s->"armor") . "% \1B[37;40m " . ($names->(($s->"gun") - 1)) . " " . ($s->"mag") . "/" . ($s->"reserve") . "  Mira " . $label . " " . $reset . $nl)
        :set scene ($scene . "Enemigos " . ($s->"left") . "  Llaves " . ($s->"keys") . "  Pts " . ($s->"score") . "  Turno " . ($s->"turn") . $nl . ($s->"msg") . $nl)
        :put ($scene . "W/S mover  A/D giro  Z/X lateral  ESP fuego" . $nl . "E usar  V mapa  C texto/color  B musica  P pausa  Q salir")
        :return []
    }
    :local nl "\r\n"
    :set frame ($frame . "DOOM RouterOS ASCII Edition" . $nl . ($s->"stage") . "/3  " . ($s->"title") . $nl)
    :if ($view = 2) do={
        # Two characters per ray compensate for tall terminal cells.
        :local rows [:toarray ""]
        :for row from=0 to=8 do={ :set rows ($rows,"") }
        :for col from=0 to=20 do={
            :local cell $pos
            :local depth 0
            :local drift 0
            :local wall ""
            :local icon ""
            :local nearAt 0
            :local item ""
            :local itemAt 0
            :while (($depth < 12) && ($wall = "")) do={
                :set depth ($depth + 1)
                :set cell ($cell + $dir)
                :local offset ((($col - 10) * $depth) / 10)
                :local tile [:pick $tiles $cell ($cell + 1)]
                :if (($tile != "#") && ($tile != "D")) do={
                    :set cell ($cell + ($offset - $drift) * $lateral)
                    :set tile [:pick $tiles $cell ($cell + 1)]
                }
                :set drift $offset
                :if (($tile = "#") || ($tile = "D")) do={ :set wall $tile }
                # Project a small object near its cell centre. A floor item leaves
                # the centre of the corridor clear for a target behind it.
                :if (($tile != ".") && ($wall = "")) do={
                    :local miss (($col - 10) * $depth - 10 * $offset)
                    :if ($miss < 0) do={ :set miss (0 - $miss) }
                    :local inner (2 + $depth / 2)
                    :if (($miss <= $inner) && ($icon = "") && ([:typeof [:find "grTB" $tile]] = "num")) do={
                        :set icon $tile
                        :set nearAt $depth
                    }
                    :if (($miss <= $inner) && ($item = "") && ([:typeof [:find "A+KX" $tile]] = "num")) do={
                        :set item $tile
                        :set itemAt $depth
                    }
                }
            }
            :local half (6 / $depth)
            :local shade "::"
            :if ($depth <= 6) do={ :set shade "==" }
            :if ($depth <= 3) do={ :set shade "##" }
            :if ($wall = "D") do={ :set shade "||" }
            :for row from=0 to=8 do={
                :local pixel "  "
                :if ($row > 4) do={ :set pixel ". " }
                :if (($wall != "") && ($row >= (4 - $half)) && ($row <= (4 + $half))) do={ :set pixel $shade }
                :if (($wall = "D") && ($row = 4)) do={ :set pixel "D|" }
                :if (($col = 10) && ($row = 4) && ($wall != "D")) do={ :set pixel "+ " }
                :if ($item != "") do={
                    :local ground (4 + 4 / $itemAt)
                    :if ($ground = 4) do={ :set ground 5 }
                    :if ($row = $ground) do={
                        :set pixel ($item . " ")
                        :if ($ansi) do={
                            :local ink "\1B[93m"
                            :if ($item = "X") do={ :set ink "\1B[92m" }
                            :set pixel ($ink . $pixel . "\1B[0m")
                        }
                    }
                }
                :if ($icon != "") do={
                    :if ($row = 4) do={
                        :set pixel ($icon . " ")
                        :if ($ansi) do={ :set pixel ("\1B[91m" . $pixel . "\1B[0m") }
                    }
                    :if (($nearAt < 4) && ($row = 3)) do={ :set pixel "oo" }
                    :if (($nearAt < 4) && ($row = 5) && (($item = "") || ($itemAt >= $nearAt))) do={ :set pixel "/\\" }
                }
                :set ($rows->$row) (($rows->$row) . $pixel)
            }
        }
        :foreach line in=$rows do={ :set frame ($frame . "|" . $line . "|" . $nl) }
        :local barrel "                   |==|"
        :local grip   "                  /|__|\\"
        :if (($s->"gun") = 2) do={ :set barrel "                  ||  ||"; :set grip "                 /======\\" }
        :if (($s->"gun") = 3) do={ :set barrel "                 [|::::|]"; :set grip "                /========\\" }
        :if ($s->"shot") do={ :set barrel "                 \\  **  /" }
        :if (($s->"bob") = true) do={ :set barrel (" " . $barrel); :set grip (" " . $grip) }
        :set frame ($frame . $barrel . $nl . $grip . $nl)
    } else={
        :set tiles ([:pick $tiles 0 $pos] . "@" . [:pick $tiles ($pos + 1) [:len $tiles]])
        :local x 0
        :local y 0
        :local width 32
        :local height 12
        :if ($view = 1) do={
            :set width 21
            :set height 7
            :set x (($pos % 32) - 10)
            :set y (($pos / 32) - 3)
            :if ($x < 0) do={ :set x 0 }
            :if ($x > 11) do={ :set x 11 }
            :if ($y < 0) do={ :set y 0 }
            :if ($y > 5) do={ :set y 5 }
        }
        :for row from=$y to=($y + $height - 1) do={
            :local start ($row * 32 + $x)
            :set frame ($frame . [:pick $tiles $start ($start + $width)] . $nl)
        }
    }
    :local names {"Pistola";"Escopeta";"Canon"}
    :local weapon ($names->(($s->"gun") - 1))
    :set frame ($frame . "Vida " . ($s->"hp") . "  Arm " . ($s->"armor") . "  K " . ($s->"keys") . $nl)
    :set frame ($frame . $weapon . " " . ($s->"mag") . "/" . ($s->"reserve") . "  Mira " . $label . $nl)
    :set frame ($frame . "Enemigos " . ($s->"left") . "  Pts " . ($s->"score") . $nl)
    :set frame ($frame . "Turno " . ($s->"turn") . "  " . ($s->"msg"))
    :if ($view = 2) do={ :set frame ($frame . $nl . "W/S mover  A/D giro  Z/X lateral  ESP fuego" . $nl . "E usar  V mapa  B musica  P pausa  Q salir") }
    :put $frame
}

/system script add name="doom-mikrotik" comment="doom-native/1.1/6.44.1" policy=read,test source={
:if ([:len [/system script job find where script="doom-mikrotik"]] > 1) do={ :error "DOOM ya tiene una sesion abierta" }
    :local level [:parse [/system script get [find name="doom-levels"] source]]
    :local step [:parse [/system script get [find name="doom-step"] source]]
    :local foes [:parse [/system script get [find name="doom-enemies"] source]]
    :local draw [:parse [/system script get [find name="doom-render"] source]]
    :local tone [:parse [/system script get [find name="doom-audio"] source]]
    :local mode "menu"
    :local sound true
    :local music true
    :local song [$tone "score"]
    :local order ($song->"order")
    :local beat 0
    :local beatLeft 0s
    :local quietBeat false
    :local aiLeft 1500ms
    :local lastKey [/system resource get uptime]
    :local ansi true
    :local view 2
    :local diff 2
    :local dirty true
    :local inputs 0
    :local began [/system resource get uptime]
    :local s [:toarray ""]
    :put "   ____   ___   ___  __  __"
    :put "  |  _ \\ / _ \\ / _ \\|  \\/  |"
    :put "  | |_| | (_) | (_) | |\\/| |"
    :put "  |____/ \\___/ \\___/|_|  |_|"
    :while (($mode != "out") && ($inputs < 900) && (([/system resource get uptime] - $began) < 30m)) do={
        :local old $mode
        :local key 65535
        :local didAct false
        :local timedAI false
        :local ticking (($mode = "play") && $sound && $music)
        :local live (($mode = "play") && ($view = 2))
        :local elapsed [:time {
        :if ($dirty) do={
            :if ($mode = "menu") do={
                :put "DOOM RouterOS ASCII Edition"
                :put ("1 Jugar   I Instrucciones   Q Salir\r\nM Audio: " . $sound . "   B Musica E1M1: " . $music . "   C Borrado ANSI: " . $ansi)
            }
            :if ($mode = "help") do={
                :put "Visor: W/S avanza/retrocede. A/D gira. Z/X paso lateral."
                :put "F gira 90 grados. ESPACIO dispara. R recarga. 1/2/3 arma."
                :put "A recoge municion, + cura, K abre D con E. E activa X."
                :put "g guardia, r corredor, T tanque, B jefe. Eliminalos a todos."
                :put "V mapa por turnos (WASD cardinal) / compacto / visor. B musica, M audio, P pausa, Q salir."
                :put "Pulsa I para volver."
            }
            :if ($mode = "difficulty") do={ :put "Dificultad: 1 Recluta / 2 Marine / 3 Pesadilla. Q salir." }
            :if ($mode = "pause") do={ :put ("PAUSA | P continuar / M sonido: " . $sound . " / B musica: " . $music . " / Q salir") }
            :if ($mode = "play") do={ $draw $s $view $ansi }
            :set dirty false
        }
        :local waitFor 90s
        :if ($ticking) do={
            # Fold late notes forward without playing a catch-up burst on the beeper.
            :local advanced 0
            :while (($beatLeft <= 0s) && ($advanced < 12)) do={
                :local slot [:find ($song->"alphabet") [:pick $order $beat ($beat + 1)]]
                :set beatLeft ($beatLeft + (($song->"gap")->$slot))
                :set beat (($beat + 1) % [:len $order])
                :set advanced ($advanced + 1)
                :if ($beatLeft > 0s) do={
                    :if (!$quietBeat) do={ :local hz [$tone "note" $song $slot $ansi] }
                    :set quietBeat false
                }
            }
            :if ($beatLeft <= 0s) do={ :set beatLeft 10ms }
            :set waitFor $beatLeft
        }
        :if ($live && ($aiLeft < $waitFor)) do={ :set waitFor $aiLeft }
        :if ($waitFor < 10ms) do={ :set waitFor 10ms }
        :set key [/terminal inkey timeout=$waitFor]
        :if ($key != 65535) do={
            :set inputs ($inputs + 1)
            :set lastKey [/system resource get uptime]
        }
        :if (($key >= 65) && ($key <= 90)) do={ :set key ($key + 32) }
        :set timedAI ($live && ($aiLeft <= 10ms) && ($key = 65535))
        :local idle (([/system resource get uptime] - $lastKey) >= 90s)
        :if (($key = 113) || $idle || (($key = 65535) && (!$live) && (!$ticking))) do={
            :if ($key = 65535) do={ :put "Fin por inactividad." }
            :set mode "out"
        } else={
            :if ($key = 98) do={
                :set music (!$music)
                :if ($music) do={ :set sound true }
                :set beatLeft 0s
                :if ($old = "play") do={ :set ($s->"msg") ("Musica: " . $music) }
                :set dirty true
            }
            :if ($key = 109) do={
                :set sound (!$sound)
                :if ($old = "play") do={ :set ($s->"msg") ("Sonido: " . $sound) }
                :set dirty true
            }
            :if (($key = 99) && (($old = "menu") || ($old = "play"))) do={
                :set ansi (!$ansi)
                :if ($old = "play") do={ :set ($s->"msg") ("ANSI: " . $ansi) }
                :set dirty true
            }
            :if ($old = "menu") do={
                :if ($key = 49) do={ :set mode "difficulty" }
                :if ($key = 105) do={ :set mode "help" }
            }
            :if (($old = "help") && ($key = 105)) do={ :set mode "menu" }
            :if (($old = "difficulty") && ($key >= 49) && ($key <= 51)) do={
                :set diff ($key - 48)
                :set s [$level 1]
                :set ($s->"diff") $diff
                :set mode "play"
            }
            :if (($old = "pause") && ($key = 112)) do={ :set mode "play" }
            :if ($old = "play") do={
                :if ($key = 112) do={ :set mode "pause" }
                :if ($key = 118) do={ :set view (($view + 1) % 3); :set dirty true }
                :local actions {119;97;115;100;102;114;101;32;49;50;51}
                :local act (($view = 2) && (($key = 122) || ($key = 120)))
                :foreach k in=$actions do={ :if ($k = $key) do={ :set act true } }
                :if ($act || $timedAI) do={
                    :set didAct true
                    :set s [$step $s $key $view]
                    :if ($s->"shot") do={
                        :if ($view = 2) do={ $draw $s $view $ansi } else={ :put "       < * >" }
                        :local blast "pistol"
                        :if (($s->"gun") = 2) do={ :set blast "shotgun" }
                        :if ($sound) do={ :set quietBeat true; $tone $blast }
                        :delay 55ms
                        :set ($s->"shot") false
                    }
                    :if (!($s->"done")) do={ :set s [$foes $s] }
                    :local ev ($s->"event")
                    :if ($sound && ($ev != "") && ($ev != "pistol") && ($ev != "shotgun")) do={ :set quietBeat true; $tone $ev }
                    :set dirty true
                    :if (($s->"hp") = 0) do={
                        $draw $s $view $ansi
                        :put ("GAME OVER | Puntos " . ($s->"score"))
                        :if ($sound) do={ $tone "over" }
                        :set mode "out"
                    }
                    :if ($s->"done") do={
                        :if ($sound) do={ $tone "win" }
                        :local stage ($s->"stage")
                        :local score (($s->"score") + 250)
                        :if ($stage = 3) do={
                            :put ("VICTORIA | Sector infernal despejado. Puntos " . $score)
                            :set mode "out"
                        } else={
                            :set s [$level ($stage + 1)]
                            :set ($s->"diff") $diff
                            :set ($s->"score") $score
                            :set ($s->"gun") ($stage + 1)
                            :set ($s->"msg") "Sector superado. Nueva arma y suministros."
                        }
                    }
                }
            }
        }
        :if ($old != $mode) do={ :set dirty true }
        :if (($mode != "out") && ($key != 65535)) do={ :delay 100ms }
        }]
        :if ($ticking) do={ :set beatLeft ($beatLeft - $elapsed) }
        :if ($didAct || (!$live)) do={ :set aiLeft 1500ms } else={ :set aiLeft ($aiLeft - $elapsed) }
    }
    :if ($mode != "out") do={ :put "Limite de sesion alcanzado." }
    :put "DOOM cerrado."
}
