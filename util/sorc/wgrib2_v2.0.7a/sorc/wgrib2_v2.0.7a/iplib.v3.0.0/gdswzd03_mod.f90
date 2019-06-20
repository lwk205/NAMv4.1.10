 MODULE GDSWZD03_MOD
!$$$  MODULE DOCUMENTATION BLOCK
!
! $Revision: 71314 $
!
! MODULE:  GDSWZD03_MOD  GDS WIZARD MODULE FOR LAMBERT CONFORMAL CONIC
!   PRGMMR: GAYNO     ORG: W/NMC23       DATE: 2015-01-21
!
! ABSTRACT: - CONVERT FROM EARTH TO GRID COORDINATES OR VICE VERSA.
!           - COMPUTE VECTOR ROTATION SINES AND COSINES.
!           - COMPUTE MAP JACOBIANS.
!           - COMPUTE GRID BOX AREA.
!
! PROGRAM HISTORY LOG:
!   2015-01-21  GAYNO   INITIAL VERSION FROM A MERGER OF
!                       ROUTINES GDSWIZ03 AND GDSWZD03.
!
! USAGE:  "USE GDSWZD03_MOD"  THEN CALL THE PUBLIC DRIVER
!         ROUTINE "GDSWZD03".
!
! ATTRIBUTES:
!   LANGUAGE: FORTRAN 90
!
!$$$
!
 IMPLICIT NONE

 PRIVATE

 PUBLIC                        :: GDSWZD03

 REAL,           PARAMETER     :: RERTH=6.3712E6
 REAL,           PARAMETER     :: PI=3.14159265358979
 REAL,           PARAMETER     :: DPR=180./PI

 INTEGER                       :: IROT

 REAL                          :: AN, DLON, DR, DXS, DYS, H

 CONTAINS

 SUBROUTINE GDSWZD03(KGDS,IOPT,NPTS,FILL,XPTS,YPTS,RLON,RLAT,NRET, &
                     CROT,SROT,XLON,XLAT,YLON,YLAT,AREA)
!$$$  SUBPROGRAM DOCUMENTATION BLOCK
!
! SUBPROGRAM:  GDSWZD03   GDS WIZARD FOR LAMBERT CONFORMAL CONICAL
!   PRGMMR: IREDELL       ORG: W/NMC23       DATE: 96-04-10
!
! ABSTRACT: THIS SUBPROGRAM DECODES THE GRIB GRID DESCRIPTION SECTION
!           (PASSED IN INTEGER FORM AS DECODED BY SUBPROGRAM W3FI63)
!           AND RETURNS ONE OF THE FOLLOWING:
!             (IOPT=+1) EARTH COORDINATES OF SELECTED GRID COORDINATES
!             (IOPT=-1) GRID COORDINATES OF SELECTED EARTH COORDINATES
!           FOR LAMBERT CONFORMAL CONICAL PROJECTIONS.
!           IF THE SELECTED COORDINATES ARE MORE THAN ONE GRIDPOINT
!           BEYOND THE THE EDGES OF THE GRID DOMAIN, THEN THE RELEVANT
!           OUTPUT ELEMENTS ARE SET TO FILL VALUES.
!           THE ACTUAL NUMBER OF VALID POINTS COMPUTED IS RETURNED TOO.
!           OPTIONALLY, THE VECTOR ROTATIONS, MAP JACOBIANS AND
!           GRID BOX AREAS FOR THIS GRID MAY BE RETURNED AS WELL.
!           TO COMPUTE THE VECTOR ROTATIONS, THE OPTIONAL ARGUMENTS 
!           'SROT' AND 'CROT'  MUST BE PRESENT.  TO COMPUTE THE MAP
!           JACOBIANS, THE OPTIONAL ARGUMENTS 'XLON', 'XLAT', 
!           'YLON', 'YLAT' MUST BE PRESENT. TO COMPUTE THE GRID BOX 
!           AREAS THE OPTIONAL ARGUMENT 'AREA' MUST BE PRESENT.
!
! PROGRAM HISTORY LOG:
!   96-04-10  IREDELL
!   96-10-01  IREDELL  PROTECTED AGAINST UNRESOLVABLE POINTS
!   97-10-20  IREDELL  INCLUDE MAP OPTIONS
! 1999-04-27  GILBERT  CORRECTED MINOR ERROR CALCULATING VARIABLE AN
!                      FOR THE SECANT PROJECTION CASE (RLATI1.NE.RLATI2).
! 2012-08-14  GAYNO    FIX PROBLEM WITH SH GRIDS.  ENSURE GRID BOX
!                      AREA ALWAYS POSITIVE.
! 2015-01-21  GAYNO    MERGER OF GDSWIZ03 AND GDSWZD03.  MAKE
!                      CROT,SORT,XLON,XLAT,YLON,YLAT AND AREA
!                      OPTIONAL ARGUMENTS.  MAKE PART OF A MODULE.
!                      MOVE VECTOR ROTATION, MAP JACOBIAN AND GRID
!                      BOX AREA COMPUTATIONS TO SEPARATE SUBROUTINES.
!
! USAGE:    CALL GDSWZD03(KGDS,IOPT,NPTS,FILL,XPTS,YPTS,RLON,RLAT,NRET,
!    &                    CROT,SROT,XLON,XLAT,YLON,YLAT,AREA)
!
!   INPUT ARGUMENT LIST:
!     KGDS     - INTEGER (200) GDS PARAMETERS AS DECODED BY W3FI63
!     IOPT     - INTEGER OPTION FLAG
!                (+1 TO COMPUTE EARTH COORDS OF SELECTED GRID COORDS)
!                (-1 TO COMPUTE GRID COORDS OF SELECTED EARTH COORDS)
!     NPTS     - INTEGER MAXIMUM NUMBER OF COORDINATES
!     FILL     - REAL FILL VALUE TO SET INVALID OUTPUT DATA
!                (MUST BE IMPOSSIBLE VALUE; SUGGESTED VALUE: -9999.)
!     XPTS     - REAL (NPTS) GRID X POINT COORDINATES IF IOPT>0
!     YPTS     - REAL (NPTS) GRID Y POINT COORDINATES IF IOPT>0
!     RLON     - REAL (NPTS) EARTH LONGITUDES IN DEGREES E IF IOPT<0
!                (ACCEPTABLE RANGE: -360. TO 360.)
!     RLAT     - REAL (NPTS) EARTH LATITUDES IN DEGREES N IF IOPT<0
!                (ACCEPTABLE RANGE: -90. TO 90.)
!
!   OUTPUT ARGUMENT LIST:
!     XPTS     - REAL (NPTS) GRID X POINT COORDINATES IF IOPT<0
!     YPTS     - REAL (NPTS) GRID Y POINT COORDINATES IF IOPT<0
!     RLON     - REAL (NPTS) EARTH LONGITUDES IN DEGREES E IF IOPT>0
!     RLAT     - REAL (NPTS) EARTH LATITUDES IN DEGREES N IF IOPT>0
!     NRET     - INTEGER NUMBER OF VALID POINTS COMPUTED
!     CROT     - REAL, OPTIONAL (NPTS) CLOCKWISE VECTOR ROTATION COSINES
!     SROT     - REAL, OPTIONAL (NPTS) CLOCKWISE VECTOR ROTATION SINES
!                (UGRID=CROT*UEARTH-SROT*VEARTH;
!                 VGRID=SROT*UEARTH+CROT*VEARTH)
!     XLON     - REAL, OPTIONAL (NPTS) DX/DLON IN 1/DEGREES
!     XLAT     - REAL, OPTIONAL (NPTS) DX/DLAT IN 1/DEGREES
!     YLON     - REAL, OPTIONAL (NPTS) DY/DLON IN 1/DEGREES
!     YLAT     - REAL, OPTIONAL (NPTS) DY/DLAT IN 1/DEGREES
!     AREA     - REAL, OPTIONAL (NPTS) AREA WEIGHTS IN M**2
!                (PROPORTIONAL TO THE SQUARE OF THE MAP FACTOR)
!
! ATTRIBUTES:
!   LANGUAGE: FORTRAN 90
!
!$$$
 IMPLICIT NONE
!
 INTEGER,        INTENT(IN   ) :: IOPT, KGDS(200), NPTS
 INTEGER,        INTENT(  OUT) :: NRET
!
 REAL,           INTENT(IN   ) :: FILL
 REAL,           INTENT(INOUT) :: RLON(NPTS),RLAT(NPTS)
 REAL,           INTENT(INOUT) :: XPTS(NPTS),YPTS(NPTS)
 REAL, OPTIONAL, INTENT(  OUT) :: CROT(NPTS),SROT(NPTS)
 REAL, OPTIONAL, INTENT(  OUT) :: XLON(NPTS),XLAT(NPTS)
 REAL, OPTIONAL, INTENT(  OUT) :: YLON(NPTS),YLAT(NPTS),AREA(NPTS)
!
 INTEGER                       :: IM, JM, IPROJ, N
 INTEGER                       :: ISCAN, JSCAN
!
 LOGICAL                       :: LROT, LMAP, LAREA
!
 REAL                          :: ANTR, DI, DJ
 REAL                          :: DX, DY, DLON1
 REAL                          :: DE, DE2, DR2
 REAL                          :: HI, HJ
 REAL                          :: ORIENT, RLAT1, RLON1
 REAL                          :: RLATI1, RLATI2
 REAL                          :: XMAX, XMIN, YMAX, YMIN, XP, YP
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 IF(PRESENT(CROT)) CROT=FILL
 IF(PRESENT(SROT)) SROT=FILL
 IF(PRESENT(XLON)) XLON=FILL
 IF(PRESENT(XLAT)) XLAT=FILL
 IF(PRESENT(YLON)) YLON=FILL
 IF(PRESENT(YLAT)) YLAT=FILL
 IF(PRESENT(AREA)) AREA=FILL
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 IF(KGDS(1).EQ.003) THEN
   IM=KGDS(2)
   JM=KGDS(3)
   RLAT1=KGDS(4)*1.E-3
   RLON1=KGDS(5)*1.E-3
   IROT=MOD(KGDS(6)/8,2)
   ORIENT=KGDS(7)*1.E-3
   DX=KGDS(8)
   DY=KGDS(9)
   IPROJ=MOD(KGDS(10)/128,2)
   ISCAN=MOD(KGDS(11)/128,2)
   JSCAN=MOD(KGDS(11)/64,2)
   RLATI1=KGDS(12)*1.E-3
   RLATI2=KGDS(13)*1.E-3
   H=(-1.)**IPROJ
   HI=(-1.)**ISCAN
   HJ=(-1.)**(1-JSCAN)
   DXS=DX*HI
   DYS=DY*HJ
   IF(RLATI1.EQ.RLATI2) THEN
     AN=SIN(RLATI1/DPR)
   ELSE
     AN=LOG(COS(RLATI1/DPR)/COS(RLATI2/DPR))/ &
        LOG(TAN((90-RLATI1)/2/DPR)/TAN((90-RLATI2)/2/DPR))
   ENDIF
   DE=RERTH*COS(RLATI1/DPR)*TAN((RLATI1+90)/2/DPR)**AN/AN
   IF(H*RLAT1.EQ.90) THEN
     XP=1
     YP=1
   ELSE
     DR=DE/TAN((RLAT1+90)/2/DPR)**AN
     DLON1=MOD(RLON1-ORIENT+180+3600,360.)-180
     XP=1-SIN(AN*DLON1/DPR)*DR/DXS
     YP=1+COS(AN*DLON1/DPR)*DR/DYS
   ENDIF
   ANTR=1/(2*AN)
   DE2=DE**2
   XMIN=0
   XMAX=IM+1
   YMIN=0
   YMAX=JM+1
   NRET=0
   IF(PRESENT(CROT).AND.PRESENT(SROT))THEN
     LROT=.TRUE.
   ELSE
     LROT=.FALSE.
   ENDIF
   IF(PRESENT(XLON).AND.PRESENT(XLAT).AND.PRESENT(YLON).AND.PRESENT(YLAT))THEN
     LMAP=.TRUE.
   ELSE
     LMAP=.FALSE.
   ENDIF
   IF(PRESENT(AREA))THEN
     LAREA=.TRUE.
   ELSE
     LAREA=.FALSE.
   ENDIF
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!  TRANSLATE GRID COORDINATES TO EARTH COORDINATES
   IF(IOPT.EQ.0.OR.IOPT.EQ.1) THEN
     DO N=1,NPTS
       IF(XPTS(N).GE.XMIN.AND.XPTS(N).LE.XMAX.AND. &
          YPTS(N).GE.YMIN.AND.YPTS(N).LE.YMAX) THEN
         DI=H*(XPTS(N)-XP)*DXS
         DJ=H*(YPTS(N)-YP)*DYS
         DR2=DI**2+DJ**2
         DR=SQRT(DR2)
         IF(DR2.LT.DE2*1.E-6) THEN
           RLON(N)=0.
           RLAT(N)=H*90.
         ELSE
           RLON(N)=MOD(ORIENT+1./AN*DPR*ATAN2(DI,-DJ)+3600,360.)
           RLAT(N)=(2*DPR*ATAN((DE2/DR2)**ANTR)-90)
         ENDIF
         NRET=NRET+1
         DLON=MOD(RLON(N)-ORIENT+180+3600,360.)-180
         IF(LROT)  CALL GDSWZD03_VECT_ROT(CROT(N),SROT(N))
         IF(LMAP)  CALL GDSWZD03_MAP_JACOB(RLAT(N),FILL, &
                                           XLON(N),XLAT(N),YLON(N),YLAT(N))
         IF(LAREA) CALL GDSWZD03_GRID_AREA(RLAT(N),FILL,AREA(N))
       ELSE
         RLON(N)=FILL
         RLAT(N)=FILL
       ENDIF
     ENDDO
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!  TRANSLATE EARTH COORDINATES TO GRID COORDINATES
   ELSEIF(IOPT.EQ.-1) THEN
     DO N=1,NPTS
       IF(ABS(RLON(N)).LE.360.AND.ABS(RLAT(N)).LE.90.AND. &
                                      H*RLAT(N).NE.-90) THEN
         DR=H*DE*TAN((90-RLAT(N))/2/DPR)**AN
         DLON=MOD(RLON(N)-ORIENT+180+3600,360.)-180
         XPTS(N)=XP+H*SIN(AN*DLON/DPR)*DR/DXS
         YPTS(N)=YP-H*COS(AN*DLON/DPR)*DR/DYS
         IF(XPTS(N).GE.XMIN.AND.XPTS(N).LE.XMAX.AND. &
            YPTS(N).GE.YMIN.AND.YPTS(N).LE.YMAX) THEN
           NRET=NRET+1
           IF(LROT)  CALL GDSWZD03_VECT_ROT(CROT(N),SROT(N))
           IF(LMAP)  CALL GDSWZD03_MAP_JACOB(RLAT(N),FILL, &
                                             XLON(N),XLAT(N),YLON(N),YLAT(N))
           IF(LAREA) CALL GDSWZD03_GRID_AREA(RLAT(N),FILL,AREA(N))
         ELSE
           XPTS(N)=FILL
           YPTS(N)=FILL
         ENDIF
       ELSE
         XPTS(N)=FILL
         YPTS(N)=FILL
       ENDIF
     ENDDO
   ENDIF
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!  PROJECTION UNRECOGNIZED
 ELSE
   IF(IOPT.GE.0) THEN
     DO N=1,NPTS
       RLON(N)=FILL
       RLAT(N)=FILL
     ENDDO
   ENDIF
   IF(IOPT.LE.0) THEN
     DO N=1,NPTS
       XPTS(N)=FILL
       YPTS(N)=FILL
     ENDDO
   ENDIF
 ENDIF
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 END SUBROUTINE GDSWZD03
!
 SUBROUTINE GDSWZD03_VECT_ROT(CROT,SROT)
!$$$  SUBPROGRAM DOCUMENTATION BLOCK
!
! SUBPROGRAM:  GDSWZD03_VECT_ROT   VECTOR ROTATION FIELDS FOR
!                                  LAMBERT CONFORMAL CONICAL
!
!   PRGMMR: GAYNO     ORG: W/NMC23       DATE: 2015-01-21
!
! ABSTRACT: THIS SUBPROGRAM COMPUTES THE VECTOR ROTATION SINES AND
!           COSINES FOR A LAMBERT CONFORMAL CONICAL GRID
!
! PROGRAM HISTORY LOG:
! 2015-01-21  GAYNO    INITIAL VERSION
!
! USAGE:    CALL GDSWZD03_VECT_ROT(CROT,SROT)
!
!   INPUT ARGUMENT LIST:
!     NONE
!
!   OUTPUT ARGUMENT LIST:
!     CROT     - CLOCKWISE VECTOR ROTATION COSINES (REAL)
!     SROT     - CLOCKWISE VECTOR ROTATION SINES (REAL)
!                (UGRID=CROT*UEARTH-SROT*VEARTH;
!                 VGRID=SROT*UEARTH+CROT*VEARTH)
!
! ATTRIBUTES:
!   LANGUAGE: FORTRAN 90
!
!$$$
 IMPLICIT NONE

 REAL,           INTENT(  OUT) :: CROT, SROT

 IF(IROT.EQ.1) THEN
   CROT=COS(AN*DLON/DPR)
   SROT=SIN(AN*DLON/DPR)
 ELSE
   CROT=1.
   SROT=0.
 ENDIF

 END SUBROUTINE GDSWZD03_VECT_ROT
!
 SUBROUTINE GDSWZD03_MAP_JACOB(RLAT,FILL,XLON,XLAT,YLON,YLAT)
!$$$  SUBPROGRAM DOCUMENTATION BLOCK
!
! SUBPROGRAM:  GDSWZD03_MAP_JACOB  MAP JACOBIANS FOR
!                                  LAMBERT CONFORMAL CONICAL
!
!   PRGMMR: GAYNO     ORG: W/NMC23       DATE: 2015-01-21
!
! ABSTRACT: THIS SUBPROGRAM COMPUTES THE MAP JACOBIANS FOR
!           A LAMBERT CONFORMAL CONICAL GRID.
!
! PROGRAM HISTORY LOG:
! 2015-01-21  GAYNO    INITIAL VERSION
!
! USAGE:  CALL GDSWZD03_MAP_JACOB(RLAT,FILL,XLON,XLAT,YLON,YLAT)
!
!   INPUT ARGUMENT LIST:
!     RLAT     - GRID POINT LATITUDE IN DEGREES (REAL)
!     FILL     - FILL VALUE FOR UNDEFINED POINTS (REAL)
!
!   OUTPUT ARGUMENT LIST:
!     XLON     - DX/DLON IN 1/DEGREES (REAL)
!     XLAT     - DX/DLAT IN 1/DEGREES (REAL)
!     YLON     - DY/DLON IN 1/DEGREES (REAL)
!     YLAT     - DY/DLAT IN 1/DEGREES (REAL)
!
! ATTRIBUTES:
!   LANGUAGE: FORTRAN 90
!
!$$$

 IMPLICIT NONE

 REAL,           INTENT(IN   ) :: RLAT, FILL
 REAL,           INTENT(  OUT) :: XLON, XLAT, YLON, YLAT

 REAL                          :: CLAT

 CLAT=COS(RLAT/DPR)
 IF(CLAT.LE.0.OR.DR.LE.0) THEN
   XLON=FILL
   XLAT=FILL
   YLON=FILL
   YLAT=FILL
 ELSE
   XLON=H*COS(AN*DLON/DPR)*AN/DPR*DR/DXS
   XLAT=-H*SIN(AN*DLON/DPR)*AN/DPR*DR/DXS/CLAT
   YLON=H*SIN(AN*DLON/DPR)*AN/DPR*DR/DYS
   YLAT=H*COS(AN*DLON/DPR)*AN/DPR*DR/DYS/CLAT
 ENDIF

 END SUBROUTINE GDSWZD03_MAP_JACOB
!
 SUBROUTINE GDSWZD03_GRID_AREA(RLAT,FILL,AREA)
!$$$  SUBPROGRAM DOCUMENTATION BLOCK
!
! SUBPROGRAM:  GDSWZD03_GRID_AREA  GRID BOX AREA FOR
!                                  LAMBERT CONFORMAL CONICAL
!
!   PRGMMR: GAYNO     ORG: W/NMC23       DATE: 2015-01-21
!
! ABSTRACT: THIS SUBPROGRAM COMPUTES THE GRID BOX AREA FOR
!           A LAMBERT CONFORMAL CONICAL GRID.
!
! PROGRAM HISTORY LOG:
! 2015-01-21  GAYNO    INITIAL VERSION
!
! USAGE:  CALL GDSWZD03_GRID_AREA(RLAT,FILL,AREA)
!
!   INPUT ARGUMENT LIST:
!     RLAT     - LATITUDE OF GRID POINT IN DEGREES (REAL)
!     FILL     - FILL VALUE FOR UNDEFINED POINTS (REAL)
!
!   OUTPUT ARGUMENT LIST:
!     AREA     - AREA WEIGHTS IN M**2 (REAL)
!
! ATTRIBUTES:
!   LANGUAGE: FORTRAN 90
!
!$$$

 IMPLICIT NONE

 REAL,           INTENT(IN   ) :: RLAT
 REAL,           INTENT(IN   ) :: FILL
 REAL,           INTENT(  OUT) :: AREA

 REAL                          :: CLAT

 CLAT=COS(RLAT/DPR)
 IF(CLAT.LE.0.OR.DR.LE.0) THEN
   AREA=FILL
 ELSE
   AREA=RERTH**2*CLAT**2*ABS(DXS)*ABS(DYS)/(AN*DR)**2
 ENDIF

 END SUBROUTINE GDSWZD03_GRID_AREA
 
 END MODULE GDSWZD03_MOD
