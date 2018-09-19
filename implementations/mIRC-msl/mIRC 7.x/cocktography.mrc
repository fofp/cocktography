; Secret Dechoder Ring v2.3.0 by Vin
;
;
; This script will automatically dechode and display messages
; encockted via cocktography. To transmit an enchoded message
; use:
;
; /enchode Text to send
;
; To manually dechode a message, use:
;
; /dechode enchoded message
;  
; This script relies on a hash table to function.
; The contents of this table can be gotten from:
; https://github.com/fidsah/cocktography/blob/master/mIRC/code/dickoder.txt
; Save the contents to a text file, and ensure that the path
; in the function below matches this file.
; First time use will require you to use the command
; /cockload
; to load the cocktography, however it will load automatically
; on subsequent client starts.
;
; Received messages will display their security level. 
; A message will show the number of strokes a message had
; as well as the following:
; ?? for messages using cocktography
; ?? because the sender is a dick, and is only using a cyphallus

alias cockload {
  .hmake cocktography 90
  ;
  ;
  ;Modify the path below for the hash table
  ;
  ;
  /hload cocktography c:/mirc/cock/rodsetta_stone.txt

  /set %cocktography.secure 🍆
  /set %cocktography.insecure 🐓

}

on 1:start:{
  cockload
}



; decyphallus
; This function converts a series of dongs to the string they represent 
; in ASCII
;
; usage
; /decyphallus <dongs>
; or 
; /echo -at $decyphallus(<dongs>)
;
;
;
; When used as an alias, will echo decyphallused text to the user.
; When used as an identifier, it will return the text instead.
;
; Example:
; input:
; /decyphallus 8=wm=D 8wm===D 8wD~~~ 8==D~ 8=mw=D
; output:
; Decyphallused: hi


alias decyphallus {
  var %v $1-
  var %letters = $numtok(%v,32)
  var %i = 1
  var %newstring
  while (%i <= %letters) {
    if ($gettok(%v,%i,32) != 8mD) {
      %newstring = %newstring $+ $hget(cocktography,$gettok(%v,%i,32))
    }
    else {
      if ($gettok(%v,%i,32) == 8mD) {
        inc %i
        %newstring = %newstring $+ $chr(32) $+ $hget(cocktography,$gettok(%v,%i,32))
      }

    }
    inc %i
  }
  if ($isid) {
    return %newstring
  }
  else {
    echo -at Decyphallused: %newstring
  }

}

; enchode
; This alias transmits the desired message using cocktography.
; Cocktography can add additional passes to a message before
; transmission. These passes are called strokes
;
; The default number of strokes used by cocktography is 2
; This can be controlled by using the -s flag as seen in the 
; examples below.
;
; usage
; /enchode <message>
; /enchode -s [x] <message>
;
; The number of strokes specified can reach a level where the user
; will be kicked off a server for excess flood.
; The script will determine the maximum level of strokes possible
; before this occurs, and use that.
;

alias enchode {
  var %strokes
  var %input
  if ($regex(strokes,$1-,^-s\s?(\d+))) {
    if ($regml(strokes,1) > 15) {
      echo -at Using max strokes of 15
      %strokes = 15
    }
    else {
      %strokes = $regml(strokes,1)
    }
    %input = $regsubex($1-,^-s\s?(\d+)\s,$chr(15))
  }
  else {
    %strokes = 2
    %input = $chr(15) $+ $1-
  }

  if ($len(%input) > 150) {
    %input = $left(%input,150)
    echo -at 4Warning: Enchoded text truncated to prevent excess flood.

  }
  var %e
  var %last = %input
  var %i = 1
  if (%strokes > 0) {
    while (%i <= %strokes) {
      %e = $encode(%last,m)
      if ($len(%e) > 280) {
        %strokes = $calc(%i -1)
        echo -at Warning: Selected strokes can cause a flood. Stopping at %strokes strokes.
        %e = %last
        break
      }
      %last = %e
      inc %i
    }
  }
  else {
    %e = %input
  }
  var %newstring = $hget(cocktography,start)
  var %len = $len(%e)

  %i = 0
  while (%i < %len) {
    %newstring = %newstring $+ $chr(32) $+ $cyphallus($left($right(%e,$calc(%len - %i)),1))
    if ($len(%newstring) > 420) {
      if (%cocktography.showchodes == $true) {
        /msg $active %newstring
      } 
      else {
        .msg $active %newstring $+ $chr(32) $+ $hget(cocktography,cont)
      }
      %newstring = $hget(cocktography,mark)
    }
    inc %i
  }
  set %cocktography.strokes %strokes
  %newstring = %newstring $+ $chr(32) $+ $hget(cocktography,stop)
  .msg $active %newstring
  .englyphen
  echo -at < $+ %cocktography.glyph $+ $me $+ > %input
}

; dechode
; This function is used to convert enchoded text back to plain text
; It can also be used to manually dechode a series of dongs that 
; were not automatically dechoded.
;
; usage
; /dechode <message>
;
; This will display the number of strokes the message used, 
; a dong showing the security level, and the dechoded message.

alias dechode {
  ;backwards compatibility
  var %dongs = $decyphallus($1-)

  var %old = $decode($decode(%dongs,m),m)
  var %strokes = 0
  var %d

  if ($left(%dongs,1) == $chr(15)) {
    %cocktography.strokes = 0
    %d = %dongs

  }
  else {
    while (%strokes <= 15) {
      inc %strokes
      %d = $decode(%dongs,m)
      ;cho -at test: $asc($left(%d,1))
      if ($left(%d,1) == $chr(15)) {
        break
      }
      %dongs = $decode(%dongs,m)
    }

    if ($left(%d,1) != $chr(15)) {
      %strokes = 2
      %d = %old
    }

    set %cocktography.strokes %strokes
  }
  if ($isid == $true) {

    return %d
  } 
  else {
    .englyphen
    echo -at < $+ cocktography.glyph $+ > Dechoded Message: %d
  }
}

; This remote detects and automatically dechodes cocktographical messages
; sent by other users

on ^1:text:*:#:{
  var %message $1-
  if ($left(%message,6) === $hget(cocktography,start)) {
    if ($gettok(%message,$numtok(%message,32),32) == $hget(cocktography,cont)) {

      var %m2 = $left($right(%message,$calc($len(%message) - 7)),$calc($len(%message)-14))
      set -u10 %pen. $+ $nick $+ . $+ $chan %m2
      halt
    }
    if ($gettok(%message,$numtok(%message,32),32) == $hget(cocktography,stop)) {
      var %dechoded $dechode($left($right(%message,$calc($len(%message) - 7)),$calc($len(%message)-14)))
      .englyphen
      echo -t $chan < $+ %cocktography.glyph $+ $nick $+ > %dechoded
      halt
    }
  }
  if ($left(%message,4) === 8wmD)  {
    var %m2 = $left($right(%message,$calc($len(%message) - 5)),$calc($len(%message)-12))
    set -u10 %pen. $+ $nick $+ . $+ $chan $eval($+(%,pen,.,$nick,.,$chan),2)$+ $chr(32) $+ %m2
    if ($gettok(%message,$numtok(%message,32),32) == $hget(cocktography,stop)) {
      var %dechoded $dechode($eval($+(%,pen,.,$nick,.,$chan),2))
      .englyphen
      echo -t $chan < $+ %cocktography.glyph $+ $nick $+ > %dechoded
      unset %pen. $+ $nick $+ . $+ $chan
      halt
    }
    halt
  }
  ;halt
}

; cyphallus
; This method converts characters to rock hard cocktography symbols.
;T his method is not designed to be called by the user. 
alias cyphallus {
  var %letter = $1-
  var %newletter
  ;check for our special special characters individually so they don't overwrite
  if (%letter === 8) {
    %newletter = 8=w==D~~
  }
  elseif (%letter === $chr(61)) {
    ;=
    %newletter = 8==w=D~
  }
  elseif (%letter === $chr(68)) {
    ;capital D
    %newletter = 8====D
  }
  elseif (%letter === $chr(119)) {
    ;lower w
    %newletter = 8=D~~
  }
  elseif (%letter === $chr(109)) {
    ;lower m
    %newletter = 8===D~~~~
  }
  elseif (%letter === $chr(126)) {
    ;tilde
    %newletter = 8=m==D~
  }
  else {
    %newletter = $replacecs(%letter,e,8=D,o,8==D,d,8===D,E,8=D~,i,8==D~,l,8===D~,L,8====D~,W,8==D~~,g,8===D~~,G,8====D~~,c,8=D~~~,C,8==D~~~,f,8===D~~~,F,8====D~~~,u,8=D~~~~,U,8==D~~~~,m,8===D~~~~,M,8====D~~~~,t,8wD,a,8w=D,H,8w==D,y,8w===D,T,8wD~,n,8w=D~,Y,8w==D~)
    %newletter = $replacecs(%newletter,p,8w===D~,P,8wD~~,b,8w=D~~,B,8w==D~~,¬,8w===D~~,h,8wD~~~,1,8w=D~~~,$chr(33),8w==D~~~,2,8w===D~~~,$chr(64),8wD~~~~,3,8w=D~~~~,$chr(35),8w==D~~~~,4,8w===D~~~~,A,8=wD,$chr(36),8=w=D,5,8=w==D,$chr(37),8=wD~,6,8=w=D~,$chr(94),8=w==D~,7,8=wD~~,$chr(38),8=w=D~~)
    %newletter = $replacecs(%newletter,$chr(42),8=wD~~~,9,8=w=D~~~,$chr(40),8=w==D~~~,0,8=wD~~~~,$chr(41),8=w=D~~~~,$chr(45),8=w==D~~~~,R,8==wD,_,8==w=D,$chr(43),8==wD~,$chr(44),8==wD~~,$chr(60),8==w=D~~,$chr(46),8==wD~~~,$chr(62),8==w=D~~~,$chr(63),8==w=D~~~~,$chr(59),8===wD,:,8===wD~,",8===wD~~)
    %newletter = $replacecs(%newletter,',8===wD~~~,$chr(91),8===wD~~~~,$chr(32),8mD,O,8m=D,$chr(123),8m==D,$chr(93),8m===D,I,8mD~,N,8m=D~,r,8m==D~,v,8m===D~,V,8mD~~,k,8m=D~~,K,8m==D~~,j,8m===D~~,J,8mD~~~,x,8m=D~~~,X,8m==D~~~,q,8m===D~~~,Q,8mD~~~~,z,8m=D~~~~,Z,8m==D~~~~,$chr(96),8m===D~~~~,s,8=mD)
    %newletter = $replacecs(%newletter,S,8=m=D,$chr(125),8=m==D,$chr(92),8=mD~,$chr(124),8=m=D~)
    %newletter = $replacecs(%newletter,$chr(47),8==wD~~~~,$chr(15),8wm===D)
  }
  if ($len(%newletter) == 0) {
    %newletter = 8mD
  }
  return %newletter
}

;helper function to avoid code duplication
alias englyphen {
  if (%cocktography.strokes > 0) {
    if (%cocktography.strokes == 2) {
      %cocktography.glyph = %cocktography.secure $+ 4

    }
    else {
      %cocktography.glyph = 04 $+ %cocktography.strokes $+  $+ %cocktography.secure $+ 4
    }
  }
  else {
    %cocktography.glyph = 03 $+ 0 $+  $+ %cocktography.insecure $+ 3
  }

}