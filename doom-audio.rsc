/system script add name="doom-audio" comment="doom-native/1.1/6.44.1" policy=read,test source={
:local ev $1
    # E1M1 beeper arrangement supplied by bdallen/NetworkScripts (see README).
    # One token indexes frequency, note length and interval until the next attack.
    :if ($ev = "score") do={
        :local song [:toarray ""]
        :set ($song->"alphabet") "abcdefghijklmnopqrstuvwxyzABCD"
        :set ($song->"hz") {160;160;329;293;261;233;246;233;740;660;554;880;783;622;987;659;1318;1567;197;440;392;349;311;311;587;523;440;440;493;392}
        :set ($song->"dur") {20ms;150ms;100ms;100ms;100ms;100ms;100ms;500ms;50ms;50ms;50ms;50ms;50ms;50ms;50ms;50ms;50ms;50ms;50ms;100ms;100ms;100ms;100ms;500ms;50ms;50ms;50ms;50ms;50ms;50ms}
        :set ($song->"gap") {120ms;120ms;120ms;120ms;120ms;120ms;120ms;500ms;60ms;60ms;60ms;60ms;60ms;60ms;60ms;60ms;60ms;60ms;60ms;120ms;120ms;120ms;120ms;500ms;60ms;60ms;60ms;120ms;60ms;60ms}
        :local order ""
        :set order ($order . "abcabdabeabfabgeabcabdabeabhabcabdabeabfabgeabcabdabeabhabcabdabeabfabgeabcabdabeabhabcabdabeabf")
        :set order ($order . "abgeabcabdabijkilminimlolmikabcabdabeabfabgeabcabdabompmomoqomomoqrsabtabuabvabwabcvabtabuabvabx")
        :set order ($order . "abtabuabvabwabcvabtabuabpyzpzAzlpzpzpzBabcabdabeabfabgeabcabdabeabhabcabdabeabfabgeabcabdabeabha")
        :set order ($order . "btabuabvabwabcvabtabuabvabxabcabdabeabfabgeabcabdabpmCDpCmpmpCDpmoqabcabdabeabfabgeabcabdabeabha")
        :set order ($order . "bcabdabeabfabgeabcabdabeabhabcabdabeabfabgeabcabdabeabhabcabdabeabfabgeabcabdabijkilminimlolmika")
        :set order ($order . "bcabdabeabfabgeabcabdabompmomoqomomoqrsabtabuabvabwabcvabtabuabvabxabtabuabvabwabcvabtabuabpyzpz")
        :set order ($order . "AzlpzpzpzBabcabdabeabfabgeabcabdabeabhabcabdabeabfabgeabcabdabeabhabtabuabvabwabcvabtabuabvabxab")
        :set order ($order . "cabdabeabfabgeabcabdabpmCDpCmpmpCDpmoq")
        :set ($song->"order") $order
        :return $song
    }
    :if ($ev = "note") do={
        :local song $2
        :local slot $3
        :local hz (($song->"hz")->$slot)
        :local dur (($song->"dur")->$slot)
        :beep frequency=$hz length=$dur
        :if ($4 = true) do={ /terminal cuu }
        :return $hz
    }
    :local notes [:toarray ""]
    :local dur 18ms
    :if ($ev = "pistol") do={ :set notes {1600} }
    :if ($ev = "shotgun") do={ :set notes {170;135;110}; :set dur 12ms }
    :if ($ev = "hit") do={ :set notes {850;510} }
    :if ($ev = "hurt") do={ :set notes {145}; :set dur 36ms }
    :if ($ev = "ammo") do={ :set notes {680;1020} }
    :if ($ev = "med") do={ :set notes {560;700;840} }
    :if ($ev = "door") do={ :set notes {320;650} }
    :if ($ev = "kill") do={ :set notes {580;360;190} }
    :if ($ev = "win") do={ :set notes {480;610;750;960}; :set dur 24ms }
    :if ($ev = "over") do={ :set notes {320;240;160;110}; :set dur 28ms }
    :foreach hz in=$notes do={
        :beep frequency=$hz length=$dur
        :delay ($dur + 5ms)
    }
}
