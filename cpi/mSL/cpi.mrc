on *:START: {
    set -nig %cpi.kontolchodes_filename kontol_chodes.txt
    set -nig %cpi.thinchodes_filename   cock_bytes.txt
    set -nig %cpi.widechodes_filename   rodsetta_stone.txt
    hload -m  cpi.kontol_chodes $scriptdir $+ %cpi.kontolchodes_filename
    hload -nm cpi.value2thinchodes    $scriptdir $+ %cpi.thinchodes_filename
    hload -nm cpi.value2widechodes    $scriptdir $+ %cpi.widechodes_filename
    var %i 1
    while ($hget(cpi.kontol_chodes, %i).item) {
        set -neg [ %cpi.KONTOL_CHODE. $+ [ $hget(cpi.kontol_chodes, $v1) ] ] $v1
        inc %i
    }
    %i = 1
    while ($hget(cpi.value2thinchodes, %i).item) {
        hadd -m cpi.thinchodes2value $v1 %i
        inc %i
    }
    %i = 1
    while ($hget(cpi.value2widechodes, %i).item) {
        hadd -m cpi.widechodes2value $v1 %i
        inc %i
    }
    hfree cpi.kontol_chodes
    set -neg %cpi.COCKBLOCK_MASK.SINGLETON    %cpi.KONTOL_CHODE.START * %cpi.KONTOL_CHODE.STOP
    set -neg %cpi.COCKBLOCK_MASK.INITIAL      %cpi.KONTOL_CHODE.START * %cpi.KONTOL_CHODE.CONT
    set -neg %cpi.COCKBLOCK_MASK.INTERMEDIATE %cpi.KONTOL_CHODE.MARK  * %cpi.KONTOL_CHODE.CONT
    set -neg %cpi.COCKBLOCK_MASK.FINAL        %cpi.KONTOL_CHODE.MARK  * %cpi.KONTOL_CHODE.STOP
}

decyphallicize {
    if !$isid { return }
    tokenize 32 $$1
    var %i 1, %c
    bunset &decy
    while (%i <= $0) {
        if     ($hget(thinchodes2value, %i).item) { set %c = $v1 - 1 }
        elseif ($hget(widechodes2value, %i).item) { set %c = $v1 - 1 }
        else { continue }
        if (%c > 255) { set -n %c }
        ; TODO
        bset &decy -1 %c
        inc %i
    }
}