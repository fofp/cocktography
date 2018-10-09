on *:START: {
  set -nig %cpi.kontolchodes_filename     kontol_chodes.txt
  set -nig %cpi.thinchodes_filename       cock_bytes.txt
  set -nig %cpi.widechodes_filename       rodsetta_stone.txt
  set -nig %cpi.thinchodes_rev_filename   cock_bytes.rev
  set -nig %cpi.widechodes_rev_filename   rodsetta_stone.rev
  .fopen kontols $scriptdir $+ %cpi.kontolchodes_filename
  if ($fopen(kontols).err) {
    echo $color(info) -lbft File error: kontols => %fname
    return
  }
  var %name
  while (!$fopen(kontols).eof) {
    if (& !iswm $fread(kontols)) { break }
    %name = $v2
    if (& !iswm $fread(kontols)) { break }
    set -neg $+(%, cpi.KONTOL_CHODE., %name) $v2
  }
  .fclose kontols
  .enable #cpi.init
  unset %cpi.init
  cpi.initialize thin
  cpi.initialize wide
  if (%cpi.init) {
    set -neg %cpi.COCKBLOCK_MASK.SINGLETON    %cpi.KONTOL_CHODE.START * %cpi.KONTOL_CHODE.STOP
    set -neg %cpi.COCKBLOCK_MASK.INITIAL      %cpi.KONTOL_CHODE.START * %cpi.KONTOL_CHODE.CONT
    set -neg %cpi.COCKBLOCK_MASK.INTERMEDIATE %cpi.KONTOL_CHODE.MARK  * %cpi.KONTOL_CHODE.CONT
    set -neg %cpi.COCKBLOCK_MASK.FINAL        %cpi.KONTOL_CHODE.MARK  * %cpi.KONTOL_CHODE.STOP
    set -neg %cpi.ESCAPE_SENTINEL $chr(15)
    .enable #cpi.*
  }
  else { .disable #cpi.* }
  .disable #cpi.init
}

#cpi.init off
alias cpi.initialize {
  var %rfname $scriptdir $+ $evalnext($+(%, cpi., $$1, chodes_rev_filename))
  var %fname  $scriptdir $+ $evalnext($+(%, cpi., $$1, chodes_filename))
  var %c2v $+(cpi., $$1, chode2value)
  var %v2c $+(cpi.value2, $$1, chode)
  if ($isfile(%rfname)) {
    hmake %v2c
    hload -n %v2c %fname
    hmake %c2v
    hload -b %c2v %rfname
  }
  else {
    if (& !iswm %cpi.init) {
      set -neg %cpi.init $input(Initialize chodes? $+ $crlf $+ This might take a while.,abdk60wy)
    }
    if (!%cpi.init) { return }

    var %i 1, %fhandle $+(cpi., $$1, chodes)
    .fopen %fhandle %fname
    if ($fopen(%fhandle).err) {
      echo $color(info) -lbft File error: %handle => %fname
      return
    }
    hmake %v2c
    hmake %c2v
    while (!$fopen(%fhandle).eof) {
      if (& !iswm $fread(%fhandle)) { break }
      hadd %v2c %i $v2
      hadd %c2v $v2 %i
      inc %i
    }
    .fclose %fhandle
    hsave -b %c2v %rfname
  }
}
#cpi.init end

#cpi.aliases off

alias cpi.decyphallicize {
  if !$isid { return }
  tokenize 32 $$1
  var %i 1, %c, %p
  bunset &decy
  while (%i <= $0) {
    %p = $evalnext($ $+ %i)
    if     ($hget(cpi.thinchode2value, %p)) { noop }
    elseif ($hget(cpi.widechode2value, %p)) { noop }
    else { inc %i | continue }
    bset &decy -1 $iif($calc($v1 - 1) > 255, $int($calc($v1 / 256)) $calc($v1 % 256), $v1)
    inc %i
  }
  returnex $bvar(&decy, 1-).text
}

alias cpi.destroke {
  set -neg %cpi.strokes 0, %out $$1
  while ($cpi.destrokable(%out)) {
    %out = $decode(%out, m)
    inc %cpi.strokes
  }
  if ($left(%out, 1) === %cpi.ESCAPE_SENTINEL) { %out = $right(%out, -1) }
  returnex %out
}

alias cpi.destrokable {
  ; Is the first character the terminator sentinel?
  if ($left($1, 1) === %cpi.ESCAPE_SENTINEL) { return $false }
  ; Is it an invalid MIME base64 length? (indivisible by 4)
  elseif (4 \\ $len($1)) { return $false }
  ; Are there any non MIME base64 characters?
  elseif ($regex($1, /[^+/=0-9A-Za-z]/)) { return $false }
  ; Are there no characters?
  elseif (!$len($1)) { return $false }
  else { return $true }
}

#cpi.aliases end
