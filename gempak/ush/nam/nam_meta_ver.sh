#!/bin/sh
#
# Metafile Script : nam_meta_ver_new
#
# Log :
# J. Carr/HPC     1/98   Added new metafile
# J. Carr/HPC     5/98   Converted to gdplot2
# J. Carr/HPC     8/98   Changed map to medium resolution
# J. Carr/HPC     2/99   Changed skip to 0
# J. Carr/HPC     6/99   Added latlon and a filter to map
# J. Carr/HPC     7/99   Added South American area.
# J. Carr/HPC   2/2001   Edited to run on the IBM.
# J. Carr/HPC   5/2001   Added a mn variable for a/b side dbnet root variable.
# J. Carr/HPC   6/2001   Converted to a korn shell prior to delivering script to Production.
# J. Carr/HPC   7/2001   Submitted.
# J. Carr/PMB  11/2004   Added a ? to all title/TITLE lines.
#
# Set up Local Variables
#
set -x
#
export PS4='ver:$SECONDS + '
mkdir $DATA/ver
cd $DATA/ver
cp $FIXgempak/datatype.tbl datatype.tbl

mdl=nam
MDL=NAM
metatype="ver"
metaname="namver_${cyc}.meta"
device="nc | ${metaname}"
PDY2=`echo ${PDY} | cut -c3-`
#
# DEFINE 1 CYCLE AGO
dc1=`$NDATE -06 ${PDY}${cyc} | cut -c -10`
date1=`echo ${dc1} | cut -c -8`
sdate1=`echo ${dc1} | cut -c 3-8`
cycle1=`echo ${dc1} | cut -c 9,10`
# DEFINE 2 CYCLES AGO
dc2=`$NDATE -12 ${PDY}${cyc} | cut -c -10`
date2=`echo ${dc2} | cut -c -8`
sdate2=`echo ${dc2} | cut -c 3-8`
cycle2=`echo ${dc2} | cut -c 9,10`
# DEFINE 3 CYCLES AGO
dc3=`$NDATE -18 ${PDY}${cyc} | cut -c -10`
date3=`echo ${dc3} | cut -c -8`
sdate3=`echo ${dc3} | cut -c 3-8`
cycle3=`echo ${dc3} | cut -c 9,10`
# DEFINE 4 CYCLES AGO
dc4=`$NDATE -24 ${PDY}${cyc} | cut -c -10`
date4=`echo ${dc4} | cut -c -8`
sdate4=`echo ${dc4} | cut -c 3-8`
cycle4=`echo ${dc4} | cut -c 9,10`
# DEFINE 5 CYCLES AGO
dc5=`$NDATE -30 ${PDY}${cyc} | cut -c -10`
date5=`echo ${dc5} | cut -c -8`
sdate5=`echo ${dc5} | cut -c 3-8`
cycle5=`echo ${dc5} | cut -c 9,10`
# DEFINE 6 CYCLES AGO
dc6=`$NDATE -36 ${PDY}${cyc} | cut -c -10`
date6=`echo ${dc6} | cut -c -8`
sdate6=`echo ${dc6} | cut -c 3-8`
cycle6=`echo ${dc6} | cut -c 9,10`
# DEFINE 7 CYCLES AGO
dc7=`$NDATE -42 ${PDY}${cyc} | cut -c -10`
date7=`echo ${dc7} | cut -c -8`
sdate7=`echo ${dc7} | cut -c 3-8`
cycle7=`echo ${dc7} | cut -c 9,10`
# DEFINE 8 CYCLES AGO
dc8=`$NDATE -48 ${PDY}${cyc} | cut -c -10`
date8=`echo ${dc8} | cut -c -8`
sdate8=`echo ${dc8} | cut -c 3-8`
cycle8=`echo ${dc8} | cut -c 9,10`
# DEFINE 9 CYCLES AGO
dc9=`$NDATE -54 ${PDY}${cyc} | cut -c -10`
date9=`echo ${dc9} | cut -c -8`
sdate9=`echo ${dc9} | cut -c 3-8`
cycle9=`echo ${dc9} | cut -c 9,10`
# DEFINE 10 CYCLES AGO
dc10=`$NDATE -60 ${PDY}${cyc} | cut -c -10`
date10=`echo ${dc10} | cut -c -8`
sdate10=`echo ${dc10} | cut -c 3-8`
cycle10=`echo ${dc10} | cut -c 9,10`
# DEFINE 11 CYCLES AGO
dc11=`$NDATE -66 ${PDY}${cyc} | cut -c -10`
date11=`echo ${dc11} | cut -c -8`
sdate11=`echo ${dc11} | cut -c 3-8`
cycle11=`echo ${dc11} | cut -c 9,10`
# DEFINE 12 CYCLES AGO
dc12=`$NDATE -72 ${PDY}${cyc} | cut -c -10`
date12=`echo ${dc12} | cut -c -8`
sdate12=`echo ${dc12} | cut -c 3-8`
cycle12=`echo ${dc12} | cut -c 9,10`
# DEFINE 13 CYCLES AGO
dc13=`$NDATE -78 ${PDY}${cyc} | cut -c -10`
date13=`echo ${dc13} | cut -c -8`
sdate13=`echo ${dc13} | cut -c 3-8`
cycle13=`echo ${dc13} | cut -c 9,10`
# DEFINE 14 CYCLES AGO
dc14=`$NDATE -84 ${PDY}${cyc} | cut -c -10`
date14=`echo ${dc14} | cut -c -8`
sdate14=`echo ${dc14} | cut -c 3-8`
cycle14=`echo ${dc14} | cut -c 9,10`
# DEFINE 15 CYCLES AGO
dc15=`$NDATE -90 ${PDY}${cyc} | cut -c -10`
date15=`echo ${dc15} | cut -c -8`
sdate15=`echo ${dc15} | cut -c 3-8`
cycle15=`echo ${dc15} | cut -c 9,10`
# DEFINE 16 CYCLES AGO
dc16=`$NDATE -96 ${PDY}${cyc} | cut -c -10`
date16=`echo ${dc16} | cut -c -8`
sdate16=`echo ${dc16} | cut -c 3-8`
cycle16=`echo ${dc16} | cut -c 9,10`
# DEFINE 17 CYCLES AGO
dc17=`$NDATE -102 ${PDY}${cyc} | cut -c -10`
date17=`echo ${dc17} | cut -c -8`
sdate17=`echo ${dc17} | cut -c 3-8`
cycle17=`echo ${dc17} | cut -c 9,10`
# DEFINE 18 CYCLES AGO
dc18=`$NDATE -108 ${PDY}${cyc} | cut -c -10`
date18=`echo ${dc18} | cut -c -8`
sdate18=`echo ${dc18} | cut -c 3-8`
cycle18=`echo ${dc18} | cut -c 9,10`
# DEFINE 19 CYCLES AGO
dc19=`$NDATE -114 ${PDY}${cyc} | cut -c -10`
date19=`echo ${dc19} | cut -c -8`
sdate19=`echo ${dc19} | cut -c 3-8`
cycle19=`echo ${dc19} | cut -c 9,10`
# DEFINE 20 CYCLES AGO
dc20=`$NDATE -120 ${PDY}${cyc} | cut -c -10`
date20=`echo ${dc20} | cut -c -8`
sdate20=`echo ${dc20} | cut -c 3-8`
cycle20=`echo ${dc20} | cut -c 9,10`
# DEFINE 21 CYCLES AGO
dc21=`$NDATE -126 ${PDY}${cyc} | cut -c -10`
date21=`echo ${dc21} | cut -c -8`
sdate21=`echo ${dc21} | cut -c 3-8`
cycle21=`echo ${dc21} | cut -c 9,10`

# SET CURRENT CYCLE AS THE VERIFICATION GRIDDED FILE.
vergrid="F-${MDL} | ${PDY2}/${cyc}00"
fcsthr="f00"

# SET WHAT RUNS TO COMPARE AGAINST BASED ON MODEL CYCLE TIME.
verdays="${dc1} ${dc2} ${dc3} ${dc4} ${dc5} ${dc6} ${dc7} ${dc8} ${dc10} ${dc12} ${dc14}"

#GENERATING THE METAFILES.
MDL2="NAMHPC"
for verday in ${verdays} 
do
    cominday=`echo ${verday} | cut -c -8`
    export HPCNAM=${COMROOT:?}/nawips/${envir:?}/${mdl}.${cominday}
    if [ ${verday} -eq ${dc1} ] ; then
        dgdattim=f006
        grid="F-${MDL2} | ${sdate1}/${cycle1}00"
    elif [ ${verday} -eq ${dc2} ] ; then
        dgdattim=f012
        grid="F-${MDL2} | ${sdate2}/${cycle2}00"
    elif [ ${verday} -eq ${dc3} ] ; then
        dgdattim=f018
        grid="F-${MDL2} | ${sdate3}/${cycle3}00"
    elif [ ${verday} -eq ${dc4} ] ; then
        dgdattim=f024
        grid="F-${MDL2} | ${sdate4}/${cycle4}00"
    elif [ ${verday} -eq ${dc5} ] ; then
        dgdattim=f030
        grid="F-${MDL2} | ${sdate5}/${cycle5}00"
    elif [ ${verday} -eq ${dc6} ] ; then
        dgdattim=f036
        grid="F-${MDL2} | ${sdate6}/${cycle6}00"
    elif [ ${verday} -eq ${dc7} ] ; then
        dgdattim=f042
        grid="F-${MDL2} | ${sdate7}/${cycle7}00"
    elif [ ${verday} -eq ${dc8} ] ; then
        dgdattim=f048
        grid="F-${MDL2} | ${sdate8}/${cycle8}00"
    elif [ ${verday} -eq ${dc9} ] ; then
        dgdattim=f054
        grid="F-${MDL2} | ${sdate9}/${cycle9}00"
    elif [ ${verday} -eq ${dc10} ] ; then
        dgdattim=f060
        grid="F-${MDL2} | ${sdate10}/${cycle10}00"
    elif [ ${verday} -eq ${dc11} ] ; then
        dgdattim=f066
        grid="F-${MDL2} | ${sdate11}/${cycle11}00"
    elif [ ${verday} -eq ${dc12} ] ; then
        dgdattim=f072
        grid="F-${MDL2} | ${sdate12}/${cycle12}00"
    elif [ ${verday} -eq ${dc13} ] ; then
        dgdattim=f078
        grid="F-${MDL2} | ${sdate13}/${cycle13}00"
    elif [ ${verday} -eq ${dc14} ] ; then
        dgdattim=f084
        grid="F-${MDL2} | ${sdate14}/${cycle14}00"
    elif [ ${verday} -eq ${dc15} ] ; then
        dgdattim=f090
        grid="F-${MDL2} | ${sdate15}/${cycle15}00"
    elif [ ${verday} -eq ${dc16} ] ; then
        dgdattim=f096
        grid="F-${MDL2} | ${sdate16}/${cycle16}00"
    elif [ ${verday} -eq ${dc17} ] ; then
        dgdattim=f102
        grid="F-${MDL2} | ${sdate17}/${cycle17}00"
    elif [ ${verday} -eq ${dc18} ] ; then
        dgdattim=f108
        grid="F-${MDL2} | ${sdate18}/${cycle18}00"
    elif [ ${verday} -eq ${dc19} ] ; then
        dgdattim=f114
        grid="F-${MDL2} | ${sdate19}/${cycle19}00"
    elif [ ${verday} -eq ${dc20} ] ; then
        dgdattim=f120
        grid="F-${MDL2} | ${sdate20}/${cycle20}00"
    elif [ ${verday} -eq ${dc21} ] ; then
        dgdattim=f126
        grid="F-${MDL2} | ${sdate21}/${cycle21}00"
    fi

# 500 MB HEIGHT METAFILE
export pgm=gdplot2_nc;. prep_step; startmsg

gdplot2_nc >runlog << EOFplt
PROJ     = STR/90.0;-95.0;0.0
GAREA    = 5.1;-124.6;49.6;-11.9
map      = 1//2
clear    = yes
text     = 1/22/////hw
contur   = 2
skip     = 0
type     = c

gdfile   = ${vergrid}
gdattim  = ${fcsthr}
device   = ${device}
gdpfun   = sm5s(hght)
glevel   = 500
gvcord   = pres
scale    = -1
cint     = 6
line     = 6/1/3
title    = 6/-2/~ ? NAM 500 MB HGT|~500 HGT DIFF
r

gdfile   = ${grid}
gdattim  = ${dgdattim}
line     = 5/1/3
contur   = 4
title    = 5/-1/~ ? NAM 500 MB HGT
clear    = no
r

gdfile   = ${vergrid}
gdattim  = ${fcsthr}
gdpfun   = sm5s(pmsl)
glevel   = 0
gvcord   = none
scale    = 0
cint     = 4
line     = 6/1/3
contur   = 2
title    = 6/-2/~ ? NAM PMSL|~PMSL DIFF
clear    = yes
r

gdfile   = ${grid}
gdattim  = ${dgdattim}
line     = 5/1/3
contur   = 4
title    = 5/-1/~ ? NAM PMSL
clear    = no
r

PROJ     = 
GAREA    = bwus
gdfile   = ${vergrid}
gdattim  = ${fcsthr}
gdpfun   = sm5s(pmsl)
glevel   = 0
gvcord   = none
scale    = 0
cint     = 4
line     = 6/1/3
contur   = 2
title    = 6/-2/~ ? NAM PMSL |~US PMSL DIFF
clear    = yes
r

gdfile   = ${grid}
gdattim  = ${dgdattim}
line     = 5/1/3
contur   = 4
title    = 5/-1/~ ? NAM PMSL
clear    = no
r

ex
EOFplt
export err=$?;err_chk
cat runlog
done

#####################################################
# GEMPAK DOES NOT ALWAYS HAVE A NON ZERO RETURN CODE
# WHEN IT CAN NOT PRODUCE THE DESIRED GRID.  CHECK
# FOR THIS CASE HERE.
#####################################################
ls -l $metaname
export err=$?;export pgm="GEMPAK CHECK FILE";err_chk

if [ $SENDCOM = "YES" ] ; then
   mv ${metaname} ${COMOUT}/namver_${PDY}_${cyc}
   if [ $SENDDBN = "YES" ] ; then
      ${DBNROOT}/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job \
      ${COMOUT}/namver_${PDY}_${cyc}
      if [ $DBN_ALERT_TYPE = "NAM_METAFILE_LAST" ] ; then
        DBN_ALERT_TYPE=NAM_METAFILE
        ${DBNROOT}/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job \
        ${COMOUT}/namver_${PDY}_${cyc}
      fi
   fi
fi

exit
