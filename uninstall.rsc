{
    :local names {"doom-audio";"doom-levels";"doom-step";"doom-enemies";"doom-render";"doom-mikrotik";"doom-tests";"doom-install-lock"}
    :foreach n in=$names do={
        :if ([:len [/system script job find where script=$n]] > 0) do={ :error ("DOOM: detener primero " . $n) }
    }
    :foreach n in=$names do={ /system script remove [find name=$n comment="doom-native/1.1/6.44.1"] }
    :put "DOOM retirado. Puedes eliminar la carpeta de carga doom-native."
}
