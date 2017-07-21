#!/bin/sh


# $1=Build target, $2=Target lib (default is RPGMAP, will be created first)


# The alternate sort sequence that may be used for char data and strings.
# This variable is used when building srvpgm RPGMAP, build target D or S,
# to fill in control spec keyword srtseq in module RPGMAPCVA.
SRTSEQ="*LANGIDSHR"  


# Sources with names ending with .t.RPGLE are templates. A template is
# copied with substitutions to a source with the same name but without ".t".
# The latter is compiled. Not all templates necessarily end with .t.RPGLE.


typeset -u TARGET
typeset -u TLIB


# $1=Target
# D: default (default)
# S: srvpgm RPGMAP
# T: test pgms
TARGET=$1
case $TARGET in
  ""        ) TARGET=DEFAULT ;;
  D         ) TARGET=DEFAULT ;;
  T         ) TARGET=TEST ;;
  S         ) TARGET=SRVPGM ;;
  *         )
    print "Unrecognized target ($TARGET)."
    exit 1 ;;
esac


# $2=Target lib
TLIB=$2
if [ -z "$TLIB" ]; then
  TLIB=RPGMAP
fi


# Source directory
SRC=.


# Settings for dev
#DBGVW="*ALL"
#RPGOPTMZ="*NONE"
#COPTMZ="10"

# Settings for prod
DBGVW="*NONE"
RPGOPTMZ="*FULL"
COPTMZ="40"


# Set CCSID for new files.
export QIBM_CCSID=819


echo ">>>>> Build RpgMap: target $TARGET, lib $TLIB <<<<<"


#Define functions
# $1=command
function xcmd {
  system -sv $1
}
function xcmdks {
  system -ksv $1
}
# $1=srcfile1, $2=srcfile2, ...
function substtlib {
  for x in $* 
  do
    sed "s/_TLIB_/$TLIB/g" $SRC/$x.t.RPGLE > $SRC/$x.RPGLE
  done
}
# $1=msgid, $2=msg, $3=fmt
function addmsgd {
  xcmd "ADDMSGD MSGID($1) MSGF($TLIB/RPGMAP) MSG('$2') SEV(30) FMT($3)"
}
# $1=pgm1, $2=pgm2, ...
function dltpgms {
  for x in $* ; do xcmd "DLTPGM PGM($TLIB/$x)"; done
}
# $1=sp1, $2=sp2, ...
function dltsrvpgms {
  for x in $* ; do xcmd "DLTSRVPGM SRVPGM($TLIB/$x)"; done
}
# $1=mod1, $2=mod2, ...
function dltmods {
  for x in $* ; do xcmd "DLTMOD MODULE($TLIB/$x)" ; done
}
# $1=obj/src name, $2=description
function crtrpgmod {
  xcmdks "CRTRPGMOD MODULE($TLIB/$1) SRCSTMF('$SRC/$1.RPGLE') TEXT('$2')\
 OUTPUT(*PRINT) OPTIMIZE($RPGOPTMZ) OPTION(*NOSHOWCPY) DBGVIEW($DBGVW) REPLACE(*YES)"
}
function crtcmod {
  xcmdks "CRTCMOD MODULE($TLIB/$1) SRCSTMF('$SRC/$1.C') TEXT('$2')\
 TGTCCSID(37) SYSIFCOPT(*IFSIO) OUTPUT(*PRINT) OPTIMIZE($COPTMZ) DBGVIEW($DBGVW) REPLACE(*YES)"
}
# $3=modules
function crtsrvpgm {
  xcmdks "CRTSRVPGM SRVPGM($TLIB/$1) MODULE($3) SRCSTMF('$SRC/$1.BND') TEXT('$2')\
 REPLACE(*YES)"
}
# $4=actgrp
function crtpgm {
  xcmdks "CRTPGM PGM($TLIB/$1) MODULE($3) TEXT('$2') ACTGRP($4) REPLACE(*YES)"
}
# $1=src, $2=member, $3=srctype, $4=description
function cpy2inclrpgmbr {
  xcmd "CPYFRMSTMF FROMSTMF('$SRC/$1') TOMBR('/QSYS.LIB/$TLIB.LIB/TEMP.FILE/X.MBR')\
 MBROPT(*REPLACE)"
  xcmd "CPYF FROMFILE($TLIB/TEMP) TOFILE($TLIB/INCLUDERPG) FROMMBR(X) TOMBR($2)\
 MBROPT(*REPLACE) FMTOPT(*CVTSRC)"
  xcmd "CHGPFM FILE($TLIB/INCLUDERPG) MBR($2) SRCTYPE($3) TEXT('$4')"
}
# $1=num ("001", "002", ...)
function crttestpgm {
  echo ">>>>> Substitute _TLIB_ with $TLIB in RPGMAPT$1.RPGLE"
  substtlib RPGMAPT$1
  echo ">>>>> (Re)create *PGM RPGMAPT$1"
  dltpgms   RPGMAPT$1
  dltmods   RPGMAPT$1
  crtrpgmod RPGMAPT$1 "RpgMap Test $1"
  crtpgm    RPGMAPT$1 "RpgMap Test $1" "$TLIB/RPGMAPT$1" "*NEW"
  dltmods   RPGMAPT$1
}


if [[ $TARGET == DEFAULT ]]; then

echo ">>>>> Create target lib"
xcmd "CRTLIB LIB($TLIB)"

echo ">>>>> (Re)create binding directory RPGMAP"
xcmd "DLTBNDDIR BNDDIR($TLIB/RPGMAP)"
xcmd "CRTBNDDIR BNDDIR($TLIB/RPGMAP)"
xcmd "ADDBNDDIRE BNDDIR($TLIB/RPGMAP) OBJ(($TLIB/RPGMAP *SRVPGM))"

echo ">>>>> (Re)create source file INCLUDERPG with RPG include source members"
xcmd "DLTF FILE($TLIB/INCLUDERPG)"
xcmd "CRTSRCPF FILE($TLIB/INCLUDERPG) RCDLEN(120) TEXT('Include RPG sources')"                      
xcmd "CRTPF FILE($TLIB/TEMP) RCDLEN(108) MBR(X)"
sed "s/_TLIB_/$TLIB/g" $SRC/RPGMAP.RPGLE > \
                       /QSYS.LIB/$TLIB.LIB/TEMP.FILE/X.MBR
xcmd "CPYF FROMFILE($TLIB/TEMP) TOFILE($TLIB/INCLUDERPG)\
 FROMMBR(X) TOMBR(RPGMAP) MBROPT(*REPLACE) FMTOPT(*CVTSRC)"
xcmd "CHGPFM FILE($TLIB/INCLUDERPG) MBR(RPGMAP) SRCTYPE(RPGLE)\
 TEXT('RpgMap header file')"
cpy2inclrpgmbr LICENSE          LICENSE    TXT   "License file"
cpy2inclrpgmbr RPGMAPI001.RPGLE RPGMAPI001 RPGLE "rm_m/mm/ins/insc/insx key/item parameters"
cpy2inclrpgmbr RPGMAPI002.RPGLE RPGMAPI002 RPGLE "rm_v item parameters"
cpy2inclrpgmbr RPGMAPI003.RPGLE RPGMAPI003 RPGLE "rm_dis obj parameters"
cpy2inclrpgmbr RPGMAPI051.RPGLE RPGMAPI051 RPGLE "rm__ key parameters"
cpy2inclrpgmbr RPGMAPI052.RPGLE RPGMAPI052 RPGLE "rm__i key parameters"
cpy2inclrpgmbr RPGMAPI053.RPGLE RPGMAPI053 RPGLE "rm__p key parameters"
cpy2inclrpgmbr RPGMAPI054.RPGLE RPGMAPI054 RPGLE "rm__d key parameters"
cpy2inclrpgmbr RPGMAPI055.RPGLE RPGMAPI055 RPGLE "rm__t key parameters"
cpy2inclrpgmbr RPGMAPI056.RPGLE RPGMAPI056 RPGLE "rm__z key parameters"
cpy2inclrpgmbr RPGMAPI057.RPGLE RPGMAPI057 RPGLE "rm__n key parameters"
cpy2inclrpgmbr RPGMAPI058.RPGLE RPGMAPI058 RPGLE "rm__a key parameters"
cpy2inclrpgmbr RPGMAPI059.RPGLE RPGMAPI059 RPGLE "rm__s key parameters"
cpy2inclrpgmbr RPGMAPI060.RPGLE RPGMAPI060 RPGLE "rm__aa key parameters"
cpy2inclrpgmbr RPGMAPI061.RPGLE RPGMAPI061 RPGLE "rm__sa key parameters"
cpy2inclrpgmbr RPGMAPI062.RPGLE RPGMAPI062 RPGLE "rm__x key parameters"
cpy2inclrpgmbr RPGMAPI063.RPGLE RPGMAPI063 RPGLE "rm__xp key parameters"
xcmd "DLTF FILE($TLIB/TEMP)"

echo ">>>>> (Re)create message file RPGMAP"
xcmd "DLTMSGF MSGF($TLIB/RPGMAP)"
xcmd "CRTMSGF MSGF($TLIB/RPGMAP)"
addmsgd RM00001 "Key is *null." ""
addmsgd RM00002 "Key is not an integer." ""
addmsgd RM00010 "Automatically disposed map is already contained in a map." ""
addmsgd RM00011 "Value is not compatible." ""
addmsgd RM00012 "Value is already contained in a map." ""
addmsgd RM00022 "Character or string data can not exceed 30.000 bytes." ""
addmsgd RM00023 "Character or string data must be at least 1 byte." ""
addmsgd RM00030 "Can not dispose automatically disposed map or value contained in a map." ""
addmsgd RM00032 "Object to copy is not a value or a map." ""
addmsgd RM00033 "Special properties can only be set for values and maps." ""
addmsgd RM00041 "Map is not empty." ""
addmsgd RM00101 "Unknown keyword: &1" "(*CHAR 10)"
addmsgd RM00111 "Option not supported: &1" "(*CHAR 30)"
addmsgd RM00201 "A cursor can not be inserted into a map." ""
addmsgd RM09001 "Object is not a map." ""
addmsgd RM09002 "Object is not a value." ""
addmsgd RM09003 "Object is not a cursor." ""
addmsgd RM09011 "Unknown object." ""

fi

if [[ $TARGET == DEFAULT || $TARGET == SRVPGM ]]; then

echo ">>>>> Substitute _SRTSEQ_ with $SRTSEQ in RPGMAPCVA.RPGLE"
sed "s/_SRTSEQ_/$SRTSEQ/g" $SRC/RPGMAPCVA.t.RPGLE > $SRC/RPGMAPCVA.RPGLE
                      
echo ">>>>> Substitute _TLIB_ with $TLIB in RPGMAPGDEF.RPGLE, RPGMAPMAIN.RPGLE and RPGMAPVAL.RPGLE"
substtlib RPGMAPGDEF RPGMAPMAIN RPGMAPVAL

echo ">>>>> (Re)create *SRVPGM RPGMAP, alt. sort seq. $SRTSEQ"
dltsrvpgms RPGMAP
dltmods RPGMAPMAIN RPGMAPVAL RPGMAPSER RPGMAPSYS RPGMAPCVA RPGMAPRBTC
crtrpgmod RPGMAPMAIN "RpgMap Main"
crtrpgmod RPGMAPVAL  "RpgMap Values"
crtrpgmod RPGMAPSER  "RpgMap Serialization"
crtrpgmod RPGMAPSYS  "RpgMap System"
crtrpgmod RPGMAPCVA  "RpgMap Compare Values Alt seq"
crtcmod   RPGMAPRBTC "RpgMap RedBlackTree And Cursors Impl."
crtsrvpgm RPGMAP     "RpgMap" \
"$TLIB/RPGMAPMAIN $TLIB/RPGMAPVAL $TLIB/RPGMAPSER $TLIB/RPGMAPSYS $TLIB/RPGMAPCVA $TLIB/RPGMAPRBTC"
dltmods RPGMAPMAIN RPGMAPVAL RPGMAPSER RPGMAPSYS RPGMAPCVA RPGMAPRBTC

fi

if [[ $TARGET == DEFAULT || $TARGET == TEST ]]; then

crttestpgm "000"
crttestpgm "001"
crttestpgm "002"

fi


echo ">>>>> End Build RpgMap <<<<<"


if [[ $TARGET == DEFAULT || $TARGET == SRVPGM ]]; then

  if [ ! -e /QSYS.LIB/$TLIB.LIB/RPGMAP.SRVPGM ]; then
    echo "FAILED to create serviceprogram $TLIB/RPGMAP."
    exit 5
  fi

  echo "OK; serviceprogram $TLIB/RPGMAP has been created."
  exit 0

fi

exit 0