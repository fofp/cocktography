on *:START: {
  .disable #cpi.*
  .enable #cpi.init
  cpi.init
}

#cpi.init off
alias cpi.init {
  var %ticks $ticks
  set -nig %cpi.kontolchodes_filename kontol_chodes.txt
  set -nig %cpi.thinchodes_filename   cock_bytes.txt
  set -nig %cpi.widechodes_filename   rodsetta_stone.txt
  var %fname = $qt($scriptdir $+ %cpi.kontolchodes_filename)
  tokenize 32 START STOP CONT MARK
  scon -r set -neg % $!+ cpi.KONTOL_CHODE. $!+ $* $!read(%fname, sn, $* )
  hfree -w cpi.*
  set -neg %cpi.init.line 1
  filter -kf $qt($scriptdir $+ %cpi.thinchodes_filename) _parsethinchodes
  %cpi.init.line = 1
  filter -kf $qt($scriptdir $+ %cpi.widechodes_filename) _parsewidechodes
  unset %cpi.init.line
  set -neg %cpi.COCKBLOCK_MASK.SINGLETON    %cpi.KONTOL_CHODE.START * %cpi.KONTOL_CHODE.STOP
  set -neg %cpi.COCKBLOCK_MASK.INITIAL      %cpi.KONTOL_CHODE.START * %cpi.KONTOL_CHODE.CONT
  set -neg %cpi.COCKBLOCK_MASK.INTERMEDIATE %cpi.KONTOL_CHODE.MARK  * %cpi.KONTOL_CHODE.CONT
  set -neg %cpi.COCKBLOCK_MASK.FINAL        %cpi.KONTOL_CHODE.MARK  * %cpi.KONTOL_CHODE.STOP
  set -neg %cpi.ESCAPE_SENTINEL 15
  set -neg %cpi.SEPARATOR 32
  set -neg %cpi.COCKBLOCK_PADDING $&
    $calc($iif($len(%cpi.KONTOL_CHODE.START) > $len(%cpi.KONTOL_CHODE.MARK), $v1, $v2) $&
    + $iif($len(%cpi.KONTOL_CHODE.CONT) > $len(%cpi.KONTOL_CHODE.STOP), $v1, $v2) + 2)
  .enable #cpi.*
  .disable #cpi.init
  echo $color(info) -eqs * Cocktographic chodes initialized in $calc($ticks - %ticks) $+ ms
}

alias -l _parsethinchodes {
  hadd -m329 cpi.thinchode2value $1 %cpi.init.line
  hadd -m329 cpi.value2thinchode %cpi.init.line $1
  inc %cpi.init.line
}

alias -l _parsewidechodes {
  hadd -m10000 cpi.widechode2value $1 %cpi.init.line
  hadd -m10000 cpi.value2widechode %cpi.init.line $1
  inc %cpi.init.line
}
#cpi.init end

#cpi.aliases on
alias cpi.decyphallicize {
  if (!$isid) { return }
  var %out &cpi.out, %in &cpi.in
  var %error $iif(e isincs $2, $true, $false)
  if ($regex(cpi, $2, /r(\d+)?/)) {
    if ($regml(cpi, 0)) { var %replace = $regml(cpi, 1) }
    else { var %replace 65533 }
  }
  if (b isincs $2) { %in = $$1 }
  else { bunset %in | bset -t %in 1 $$1 }
  bunset %out
  var %pos 1, %s = $bvar(%in, 0)
  while (%pos <= %s) {
    while ($bvar(%in, %pos) == %cpi.SEPARATOR) { inc %pos }
    if ($bfind(%in, %pos, %cpi.SEPARATOR)) { var %wordend $v1 - 1 }
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
  unset %cpi.strokes
  var %out &cpi.out, %c 0
  if (b isincs $2) { %out = $$1 }
  else { bunset %out | bset -t %out 1 $$1 }
  while ($_isdestrokable(%out) && $decode(%out, bm)) { inc %c }
  if ($bvar(%out, 1) == %cpi.ESCAPE_SENTINEL) { bcopy -c %out 1 %out 2 -1 }
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
  if ($bvar($$1, 1) == %cpi.ESCAPE_SENTINEL) { return $false }
  elseif (!$_isbase64($$1)) { return $false }
  return $true
}

alias -l _isbase64 {
  var %s $bvar($$1, 0), %pos 1, %c 4096, %r = %s % %c
  var %e /^[+\/0-9A-Za-z]+$/, %eend /^[+\/0-9A-Za-z]+={0,2}$/
  if (4 \\ %s) { return $false }
  if (%r) { dec %s %r }
  else { dec %s %c }
  if (!$regex(cpi, $bvar($$1, $calc(%s + 1) -).text, %eend)) { return $false }
  while (%pos <= %s) {
    if (!$regex(cpi, $bvar($$1, %pos, %c).text, %e)) { return $false }
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
        if (%prev === $null) { %prev = $bvar(%in, %pos) }
        else {
          _appendwide %out %prev $bvar(%in, %pos)
          %prev = ""
        }
        inc %pos
      }
    }
    elseif (%mode === mixed) {
      while (%pos <= %s) {
        if ($r(1, 100) < %mixed) {
          if (%prev === $null) { _appendthin %out $bvar(%in, %pos) }
          else {
            _appendthin %out %prev
            %prev = $bvar(%in, %pos)
          }
        }
        else {
          if (%prev === $null) { %prev = $bvar(%in, %pos) }
          else {
            _appendwide %out %prev $bvar(%in, %pos)
            %prev = ""
          }
        }
        inc %pos
      }
    }
    if (%prev !== $null) { _appendthin %out %prev }
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
  bset $$1 -1 %cpi.SEPARATOR
}

alias -l _appendwide {
  bset -t $$1 -1 $hget(cpi.value2widechode, $calc($$2 * 256 + $$3 + 1))
  bset $$1 -1 %cpi.SEPARATOR
}

alias cpi.stroke {
  if (!$isid) { return }
  var %out &cpi.out, %in &cpi.in, %i $$2
  if (b isincs $3) { %in = $$1 }
  else { bunset %in | bset -t %in 1 $$1 }
  bunset %out | bset %out 1 %cpi.ESCAPE_SENTINEL
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

  var %pos 1, %bound %pos, %s $bvar(%in, 0)
  bset -t %out 1 %cpi.KONTOL_CHODE.START
  var %prev %bound
  while (%bound > 0) {
    inc %bound
    var %len %bound - %pos
    if (%len >= %maxblocklen) {
      %bound = %prev
      %len = %bound - %pos
      bset %out -1 %cpi.SEPARATOR
      bcopy %out -1 %in %pos %len
      bset -t %out -1 %cpi.KONTOL_CHODE.CONT
      bset %out -1 0
      bset -t %out -1 %cpi.KONTOL_CHODE.MARK
      %pos = %bound
      inc %bound
    }
    %prev = %bound
    %bound = $bfind(%in, %bound, %cpi.SEPARATOR)
  }
  bset %out -1 %cpi.SEPARATOR
  bcopy %out -1 %in %pos -1
  bset %out -1 %cpi.SEPARATOR
  bset -t %out -1 %cpi.KONTOL_CHODE.STOP
  if (b isincs $2) {
    bcopy -c %in 1 %out 1 -1
    bunset %out
    if ($prop == text) {
      breplace %in 0 %cpi.ESCAPE_SENTINEL
      returnex $bvar(%in, 1-).text
    }
    if ($prop == count) { return %count }
    else { return $bvar(%in, 0) }
  }
  else {
    breplace %out 0 %cpi.ESCAPE_SENTINEL
    var %ret = $bvar(%out, 1-).text
    bunset %in %out
    returnex %ret
  }
}

alias cpi.strokes { return %cpi.strokes }
#cpi.aliases end
