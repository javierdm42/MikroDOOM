{
    :local names {"doom-audio";"doom-levels";"doom-step";"doom-enemies";"doom-render";"doom-mikrotik";"doom-tests";"doom-install-lock"}
    :local files {"doom-native/doom-levels.rsc";"doom-native/doom-audio.rsc";"doom-native/doom-mikrotik.rsc";"doom-native/doom-tests.rsc"}
    :local version [/system resource get version]
    :if ([:pick $version 0 6] != "6.44.1") do={ :error "DOOM: se requiere RouterOS 6.44.1" }
    :if (([:len $version] > 6) && ([:pick $version 6 7] != " ")) do={ :error "DOOM: version distinta" }
    :foreach n in=$names do={
        :if ([:len [/system script find name=$n]] > 0) do={ :error ("DOOM: nombre ocupado, sin instalar: " . $n) }
    }
    :foreach f in=$files do={ :if ([:len [/file find name=$f]] != 1) do={ :error ("DOOM: falta " . $f) } }
    /system script add name="doom-install-lock" comment="doom-native/1.1/6.44.1" policy=read source={ :put "Instalacion DOOM en curso" }
    :do {
        :foreach f in=$files do={ /import file-name=$f }
        :foreach n in=$names do={
            :if ([:len [/system script find name=$n comment="doom-native/1.1/6.44.1"]] != 1) do={ :error ("Falta " . $n) }
        }
    } on-error={
        :foreach n in=$names do={ /system script remove [find name=$n comment="doom-native/1.1/6.44.1"] }
        :error "DOOM: importacion incompleta; componentes de esta instalacion retirados"
    }
    /system script remove [find name="doom-install-lock" comment="doom-native/1.1/6.44.1"]
    :put "DOOM instalado. Usar: /system script run doom-mikrotik"
}
