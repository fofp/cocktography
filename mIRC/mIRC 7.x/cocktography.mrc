;Secret Dechoder Ring v2.2.1 by Vin
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

alias cockload {
  .hmake cocktography 90
  ;
  ;
  ;Modify the path below for the hash table
  ;
  ;
  /hload cocktography c:/mirc/code/dickoder.txt

}

on 1:start:{
  cockload
}

alias enchode {
  var %input = $1-
  if ($len($1-) > 150) {
    %input = $left(%input,150)
    echo -at 4Warning: Enchoded text truncated to prevent excess flood.

  }
  var %e = $encode($encode(%input,m),m)
  var %newstring = $hget(cocktography,start)
  var %len = $len(%e)

  var %i = 0
  while (%i < %len) {
    %newstring = %newstring $+ $chr(32) $+ $cockplace($left($right(%e,$calc(%len - %i)),1))
    if ($len(%newstring) > 340) {
      .msg $active %newstring $+ $chr(32) $+ $hget(cocktography,cont)
      ;echo -at 9Test: %newstring
      %newstring = $hget(cocktography,mark)
    }
    inc %i
  }
  %newstring = %newstring $+ $chr(32) $+ $hget(cocktography,stop)
  ;echo -at 9Test: %newstring
  .msg $active %newstring
  echo -at <4 $+ $me $+ > %input
}

alias dechode {

  var %v $1-
  var %letters = $numtok(%v,32)
  var %i = 0
  var %newstring
  while (%i <= %letters) {
    %newstring = %newstring $+ $hget(cocktography,$gettok(%v,%i,32))
    inc %i
  }
  if ($isid == $true) {
    return $decode($decode(%newstring,m),m)
  }
  else {
    echo -at 4Dechoded Message: $decode($decode(%newstring,m),m)
  }
}

on ^1:text:*:#:{
  var %message $1-
  if ($left(%message,6) === $hget(cocktography,start)) {
    if ($gettok(%message,$numtok(%message,32),32) == $hget(cocktography,cont)) {
      var %m2 = $left($right(%message,$calc($len(%message) - 7)),$calc($len(%message)-14))
      set %pen. $+ $nick $+ . $+ $chan %m2
      halt
    }
    if ($gettok(%message,$numtok(%message,32),32) == $hget(cocktography,stop)) {
      echo -t $chan <4 $+ $nick $+ > $dechode($left($right(%message,$calc($len(%message) - 7)),$calc($len(%message)-14)))
      halt
    }
  }
  if ($left(%message,4) === 8wmD)  {
    var %m2 = $left($right(%message,$calc($len(%message) - 5)),$calc($len(%message)-12))
    set %pen. $+ $nick $+ . $+ $chan $eval($+(%,pen,.,$nick,.,$chan),2)$+ $chr(32) $+ %m2
    if ($gettok(%message,$numtok(%message,32),32) == $hget(cocktography,stop)) {
      echo -t $chan <4 $+ $nick $+ > $dechode($eval($+(%,pen,.,$nick,.,$chan),2))
      unset %pen. $+ $nick $+ . $+ $chan
      halt
    }
    halt
  }
  ;halt
}

alias cockplace {
  var %letter = $1
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
    %newletter = $replacecs(%newletter,$chr(47),8==wD~~~~)
  }
  if ($len(%newletter) == 0) {
    %newletter = 8mD
  }
  return %newletter

}
