; Auto-Cocktographic Messaging
on *:START: {
  ; format variables have the following moustaches available:
  ; {{nick}} the nick for the message
  ; {{dechoded}} the payload in plaintext
  ; {{count}} the number of MIME encoding iterations used
  ; {{stroke}} the stroke format string as specified
  ; NOTE: The following block of sets are initial values.
  ; To change their values, you must use the /set command or
  ; use the mIRC Scripts Editor - Variables tab

  ; The next variable dictatates the final entry which follows. Use an integer.
  set -ign %acm.stroke_max_format 3
  set -ign %acm.stroke_0_format 030🐓
  set -ign %acm.stroke_1_format 041🍆
  set -ign %acm.stroke_2_format 04🍆
  set -ign %acm.stroke_3_format 04{{count}}🍆
  set -ign %acm.text_format   {{stroke}}<{{nick}}> {{dechoded}}
  set -ign %acm.action_format * {{stroke}}{{nick}} {{dechoded}}
  set -ign %acm.subscriptions *
  set -ign %acm.echo_alias acm.echo
  ; Here there be dragons
  set -neg %acm._hkey $!iif($event,$+($cid,/,$target,/,$fulladdress,/,$event),command)
}

alias acm.enable {
  .enable #acm
  echo $color(info) -aeq * Auto-Cocktographic Messaging enabled
}

alias acm.disable {
  .disable #acm
  echo $color(info) -aeq * Auto-Cocktographic Messaging disabled
}

#acm on
; Intercept singleton cockblock/cockchain
on ^1:text:%cpi.COCKBLOCK_MASK.SINGLETON:%acm.subscriptions:   acm.s_handler $parms
on ^1:action:%cpi.COCKBLOCK_MASK.SINGLETON:%acm.subscriptions: acm.s_handler $parms

; Intercept first cockblock in a cockchain
on ^1:text:%cpi.COCKBLOCK_MASK.INITIAL:%acm.subscriptions:   acm.i_handler $parms
on ^1:action:%cpi.COCKBLOCK_MASK.INITIAL:%acm.subscriptions: acm.i_handler $parms

; Intercept intermediate cockblock in a cockchain
on ^1:text:%cpi.COCKBLOCK_MASK.INTERMEDIATE:%acm.subscriptions:   acm.m_handler $parms
on ^1:action:%cpi.COCKBLOCK_MASK.INTERMEDIATE:%acm.subscriptions: acm.m_handler $parms

; Intercept final cockblock in a cockchain
on ^1:text:%cpi.COCKBLOCK_MASK.FINAL:%acm.subscriptions:   acm.f_handler $parms
on ^1:action:%cpi.COCKBLOCK_MASK.FINAL:%acm.subscriptions: acm.f_handler $parms
#acm end

alias acm.echo {
  if ($event != input) { var -n %event $event, %dechoded $parms }
  else { var -n %event $$1, %dechoded $$2- }
  var -n %nick $iif($nick, $v1, $me), %strokes $iif(%acm._strokes !== $null, $v1, $cpi.strokes)
  var -n %index $iif(%acm.stroke_max_format < %strokes, $v1, $v2)
  var -n %stroke $+(%, acm.stroke_, %index, _format)
  var -n %format $+(%, acm., %event, _format)
  %stroke = $replacexcs($evalnext(%stroke), {{count}}, %strokes)
  %format = $replacexcs($evalnext(%format), {{stroke}}, %stroke, {{nick}}, %nick, {{dechoded}}, %dechoded)
  echo $color(%event) -lbft $iif($event, $target, $active) %format
}

alias acm.hkey { return $evalnext(%acm._hkey) }

alias acm.s_handler {
  [ %acm.echo_alias ] $cpi.destroke($cpi.decyphallicize($parms))
  halt
}

alias acm.i_handler {
  bset -ct &acm.i_handler 1 $parms
  if ($cpi.decyphallicize(&acm.i_handler, b)) {
    acm.bsetb &acm.i_handler
    bunset &acm.i_handler
    halt
  }
  else {
    bunset &acm.i_handler
    return
  }
}

alias acm.m_handler {
  bset -ct &acm.m_handler 1 $parms
  if ($cpi.decyphallicize(&acm.m_handler, b)) {
    acm.bappendb &acm.m_handler
    bunset &acm.m_handler
    halt
  }
  else {
    bunset &acm.m_handler
    return
  }
}

alias acm.f_handler {
  bset -ct &acm.f_handler.in 1 $parms
  if ($cpi.decyphallicize(&acm.f_handler.in, b)) {
    if ($acm.bget(&acm.f_handler.msg)) {
      bcopy &acm.f_handler.msg -1 &acm.f_handler.in 1 -1
      bunset &acm.f_handler.in
      acm.bunset
      if ($cpi.destroke(&acm.f_handler.msg, b)) {
        if ($v1 <= 4096) {
          [ %acm.echo_alias ] $bvar(&acm.f_handler.msg, 1-).text
          bunset &acm.f_handler.msg
          halt
        }
        else {
          noop TODO
          [ %acm.echo_alias ] [ERROR] MAXIMUM OVER-CHODE! - showing only the first 4096 bytes:
          [ %acm.echo_alias ] $bvar(&acm.f_handler.msg, 1-4096).text
          bunset &acm.f_handler.msg
          halt
        }
      }
      else { bunset &acm.f_handler.msg }
    }
    else {
      bunset &acm.f_handler.in &acm.f_handler.msg
      acm.bunset
    }
  }
  else { bunset &acm.f_handler.in }
}


alias acm.bget {
  if ($1) { return $hget(acm.buffer, $acm.hkey, $1) }
  else { returnex $hget(acm.buffer, $acm.hkey)) }
}

alias acm.bset { hadd -mu10 acm.buffer $acm.hkey $parms }
alias acm.bsetb { hadd -bmu10 acm.buffer $acm.hkey $$1 }
alias acm.bunset { hdel acm.buffer $acm.hkey }

alias acm.bappend {
  bset -ct &acm.bappend 1 $parms
  acm.bappendb &acm.bappend
  bunset &acm.bappend
}

alias acm.bappendb {
  if ($acm.bget(&acm.bappendb)) {
    bcopy -c &acm.bappendb -1 $$1 1 -1
    acm.bsetb &acm.bappendb
    bunset &acm.bappendb
  }
}

alias acm.enchode {
  if ($isid) { return }
  var -n %strokes 2, %event text
  if (--* iswm $1) { tokenize 32 $right($1, -1) $2- }
  elseif (-* iswm $1) {
    if (b isincs $1) {
      echo $color(info) -aq Switch "b" not allowed here.
      return
    }
    if (k isincs $1) {
      echo $color(info) -aq Switch "k" not allowed here.
      return
    }
    if ($regex(acm, $1, /s(\d\d?)/)) { %strokes = $regml(acm, 1) }
    var %switches $right($1, -1)
    tokenize 32 $2-
  }
  if (//* iswm $1) { tokenize 32 $right($1, -1) $2- }
  elseif (/me == $1) {
    %event = action
    tokenize 32 $2-
  }
  elseif (/ $+ * iswm $1) {
    echo $color(info) -aq Command $qt($v2) not allowed here. Did you mean "/ $+ $v2 $+ "?
    return
  }
  bset -ct &acm.enchode 1 $$1-
  if ($cpi.enchode(&acm.enchode, %strokes, %switches $+ kb)) {
    var -n %pos 1
    while ($true) {
      if (%event == text) { .msg $active $bvar(&acm.enchode, %pos -).text }
      elseif (%event == action) { .describe $active $bvar(&acm.enchode, %pos -).text }
      if ($bfind(&acm.enchode, %pos, 0)) {
        %pos = $v1 + 1
        while ($bvar(&acm.enchode, %pos) === 0) { inc %pos }
      }
      else { break }
    }
    set -neg %acm._strokes %strokes
    [ %acm.echo_alias ] %event $$1-
    unset %acm._strokes
  }
  bunset &acm.enchode
}
