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
  if ($cpi.initialize(thin) && $cpi.initialize(wide)) {
    set -neg %cpi.COCKBLOCK_MASK.SINGLETON    %cpi.KONTOL_CHODE.START * %cpi.KONTOL_CHODE.STOP
    set -neg %cpi.COCKBLOCK_MASK.INITIAL      %cpi.KONTOL_CHODE.START * %cpi.KONTOL_CHODE.CONT
    set -neg %cpi.COCKBLOCK_MASK.INTERMEDIATE %cpi.KONTOL_CHODE.MARK  * %cpi.KONTOL_CHODE.CONT
    set -neg %cpi.COCKBLOCK_MASK.FINAL        %cpi.KONTOL_CHODE.MARK  * %cpi.KONTOL_CHODE.STOP
    set -neg %cpi.ESCAPE_SENTINEL $chr(15)
    set -neg %cpi.COCKBLOCK_PADDING 0
    var %i $var(%cpi.KONTOL_CHODE.*)
    while (%i) {
      if ($calc(2 * $len( [ $var(%cpi.KONTOL_CHODE.*, %i) ] ) + 2) > %cpi.COCKBLOCK_PADDING) {
        %cpi.COCKBLOCK_PADDING = $v1
      }
      dec %i
    }
    .enable #cpi.*
    .disable #cpi.init
  }
  else { .disable #cpi.* }
}

#cpi.init off
alias cpi.initialize {
  var %rfname $scriptdir $+ $evalnext($+(%, cpi., $$1, chodes_rev_filename))
  var %fname  $scriptdir $+ $evalnext($+(%, cpi., $$1, chodes_filename))
  var %c2v $+(cpi., $$1, chode2value)
  var %v2c $+(cpi.value2, $$1, chode)
  if ($hget(%v2c, 0).item) { hfree %v2c }
  if ($hget(%c2v, 0).item) { hfree %c2v }
  if ($isfile(%rfname)) {
    hmake $iif($$1 === wide, -m10000, -m329) %v2c
    hload -n %v2c %fname
    hmake $iif($$1 === wide, -m10000, -m329) %c2v
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
      echo $color(info) -lbft File error: %fhandle => %fname
      return
    }
    hmake $iif($$1 === wide, -m10000, -m329) %v2c
    hmake $iif($$1 === wide, -m10000, -m329) %c2v
    while (!$fopen(%fhandle).eof) {
      if (& !iswm $fread(%fhandle)) { break }
      hadd %v2c %i $v2
      hadd %c2v $v2 %i
      inc %i
    }
    .fclose %fhandle
    hsave -b %c2v %rfname
  }
  return $true
}
#cpi.init end

#cpi.aliases on

alias cpi.decyphallicize {
  if (!$isid) { return }
  var %out &cpi.out, %in &cpi.in, %pos 1, %s
  var %error $iif(e isincs $2, $v1, $v1)
  if ($regex(cpi, $2, /m(\d+)?/)) {
    if ($regml(cpi, 0)) { var %replace = $regml(cpi, 1) }
    else { var %replace 65533 }
  }
  if (b isincs $2) { %in = $$1 }
  else { bunset %in | bset -t %in 1 $$1 }
  bunset %out
  %s = $bvar(%in, 0)
  while (%pos <= %s) {
    while ($bvar(%in, %pos) == 32) { inc %pos }
    if ($bfind(%in, %pos, 32)) { var %wordend $v1 - 1 }
    else { var %wordend %s }
    var %chode $bvar(%in, %pos - %wordend).text
    if ($hget(cpi.thinchode2value, %chode)) {
      bset %out -1 $calc($v1 - 1)
    }
    elseif ($hget(cpi.widechode2value, %chode)) {
      bset %out -1 $calc(($v1 - 1) / 256) $calc(($v1 - 1) % 256)
    }
    elseif (%error) { halt }
    elseif (%replace) { bset %out -1 %replace }
    %pos = %wordend + 2
  }
  if (b isincs $2) {
    bcopy -c %in 1 %out 1 -1
    bunset %out
    if ($prop === text) { returnex $bvar(%in, 1-).text }
    else { return $bvar(%in, 0) }
  }
  else {
    var %ret $bvar(%out, 1-).text
    bunset %in %out
    returnex %ret
  }
}

alias cpi.destroke {
  if (!$isid) { return }
  var %out &cpi.out, %c 0
  if (b isincs $2) { %out = $$1 }
  else { bunset %out | bset -t %out 1 $$1 }
  while ($_isdestrokable(%out)) {
    noop $decode(%out, bm)
    inc %c
  }
  if ($bvar(%out, 1).text === %cpi.ESCAPE_SENTINEL) { bcopy -c %out 1 %out 2 -1 }
  set -neg %cpi.strokes %c
  if (b isincs $2) {
    if ($prop === text) { returnex $bvar(%out, 1-).text }
    elseif ($prop === count) { return %c }
    else { return $bvar(%out, 0) }
  }
  else {
    var %ret = $bvar(%out, 1-).text
    bunset %out
    returnex %ret
  }
}

alias -l _isdestrokable {
  if ($bvar($$1, 1).text === %cpi.ESCAPE_SENTINEL) { return $false }
  elseif (!$_isbase64($$1)) { return $false }
  return $true
}

alias -l _isbase64 {
  var %s $bvar($$1, 0), %pos 1, %c 4096, %r = %s % %c
  if (4 \\ %s) { return $false }
  if (%r) {
    dec %s %r
    if (!$regex(cpi, $bvar($$1, $calc(%s + 1) -).text, /^[+/0-9A-Za-z]+(?:|=|==)$/)) {
      return $false
    }
  }
  while (%pos <= %s) {
    if (!$regex(cpi, $bvar($$1, %pos, %c).text, /^[+/0-9A-Za-z]+$/)) {
      return $false
    }
    inc %pos %c
  }
  return $true
}

alias cpi.cyphallicize {
  if (!$isid) { return }
  var %mode thin, %out &cpi.out, %in &cpi.in, %mixed 50
  if (w isincs $2) { %mode = wide }
  if (t isincs $2) { %mode = thin }
  if ($regex(cpi, $2, /m(\d\d?)?/)) {
    %mode = mixed
    if ($regml(cpi, 0)) { %mixed = $regml(cpi, 1) }
  }
  if (b isincs $2) { %in = $$1 }
  else { bunset %in | bset -t %in 1 $$1 }
  var %s $bvar(%in, 0), %pos 1
  bunset %out
  if (%mode === thin) {
    while (%pos <= %s) {
      _appendthin %out $bvar(%in, %pos)
      inc %pos
    }
  }
  else {
    var %prev
    if (%mode === wide) {
      while (%pos <= %s) {
        if (!%prev) { %prev = $bvar(%in, %pos) }
        else {
          _appendwide %out %prev $bvar(%in, %pos)
          %prev = $null
        }
        inc %pos
      }
    }
    elseif (%mode === mixed) {
      while (%pos <= %s) {
        if ($r(1, 100) < %mixed) {
          if (!%prev) { _appendthin %out $bvar(%in, %pos) }
          else {
            _appendthin %out %prev
            %prev = $bvar(%in, %pos)
          }
        }
        else {
          if (!%prev) { %prev = $bvar(%in, %pos) }
          else {
            _appendwide %out %prev $bvar(%in, %pos)
            %prev = $null
          }
        }
        inc %pos
      }
    }
    if (%prev) { _appendthin %out %prev }
  }
  if (b isincs $2) {
    bcopy -c %in 1 %out 1 -1
    bunset %out
    if ($prop === text) { return $bvar(%in, 1-).text }
    else { return $bvar(%in, 0) }
  }
  else {
    var %ret $bvar(%out, 1-).text
    bunset %in %out
    returnex %ret
  }
}

alias -l _appendthin {
  bset -t $$1 -1 $hget(cpi.value2thinchode, $calc($$2 + 1))
  bset $$1 -1 32
}

alias -l _appendwide {
  bset -t $$1 -1 $hget(cpi.value2widechode, $calc($$2 * 256 + $$3 + 1))
  bset $$1 -1 32
}

alias cpi.stroke {
  if (!$isid) { return }
  var %out &cpi.out, %in &cpi.in, %i $$2
  if (b isincs $3) { %in = $$1 }
  else { bunset %in | bset -t %in 1 $$1 }
  bunset %out | bset -t %out 1 %cpi.ESCAPE_SENTINEL
  bcopy -c %out -1 %in 1 -1
  while (%i > 0) {
    noop $encode(%out, bm)
    dec %i
  }
  if (b isincs $3) {
    bcopy -c %in 1 %out 1 -1
    bunset %out
    if ($prop == text) { returnex $bvar(%in, 1-).text }
    else { return $bvar(%in, 0) }
  }
  else {
    var %ret = $bvar(%out, 1-).text
    bunset %in %out
    returnex %ret
  }
}

alias cpi.cockchain {
  if (!$isid) { return }
  var %out &cpi.out, %in &cpi.in, %count 1
  var %maxblocklen = 340 - %cpi.COCKBLOCK_PADDING
  if ($regex(cpi, $2, /l(\d+)/)) {
    if ($calc($regml(cpi, 1) - %cpi.COCKBLOCK_PADDING) >= $calc(2 * %cpi.COCKBLOCK_PADDING)) {
      %maxblocklen = $v1
    }
    else { %maxblocklen = $v2 }
  }
  if (b isincs $2) { %in = $$1 }
  else { bunset %in | bset -t %in 1 $$1 }
  bunset %out

  noop TODO

  bset -t %out 1 %cpi.KONTOL_CHODE.START

  bset -t %out -1 %cpi.KONTOL_CHODE.CONT $+ $chr(10) $+ %cpi.KONTOL_CHODE.MARK

  bset -t %out -1 %cpi.KONTOL_CHODE.STOP


  if (b isincs $2) {
    bcopy -c %in 1 %out 1 -1
    bunset %out
    if ($prop == text) { returnex $bvar(%in, 1-).text }
    if ($prop == count) { return %count }
    else { return $bvar(%in, 0) }
  }
  else {
    var %ret = $bvar(%out, 1-).text
    bunset %in %out
    returnex %ret
  }

}

#cpi.aliases end
