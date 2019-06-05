
        SUBROUTINE SIG2P(KMAX,MTV2,MTV3,HDAT,PDAT,PSFCM,H,HP,KST)
c
c subprogram:
c   prgmmr: Qingfu Liu    org:              date: 2000-04-25 
c
c abstract:
c   Convert data from SIG surface to P surface.
c
c usage: call
c   Input: HDAT - DATA at SIG surface
c          KST: not used
C   Ouput: PDAT - DATA at P surface

        PARAMETER (IX=41, JX=41)
 
        REAL HDAT(IX,JX,MTV2),PDAT(IX,JX,MTV3)
        REAL ZS(IX,JX),PS(IX,JX),APS(IX,JX)
        REAL H(IX,JX,KMAX),HP(IX,JX,2*KMAX+1)

c        REAL(4) FHOUR,X(160),SI(KMAX+1),SL(KMAX)
        REAL*4 FHOUR,DUMMY(245)
        COMMON /COEF3/FHOUR,DUMMY
        
        REAL, ALLOCATABLE :: TV(:,:,:),DIV(:,:,:),VORT(:,:,:),
     &                       U(:,:,:),V(:,:,:),SH(:,:,:)
        REAL, ALLOCATABLE :: PSIG(:,:,:),RH(:,:,:),
     &                       APG(:,:,:),T(:,:,:)
        REAL, ALLOCATABLE :: P(:),AP(:)
        REAL, ALLOCATABLE :: DIVP(:,:,:),VORTP(:,:,:),UP(:,:,:),
     &                 VP(:,:,:),RHP(:,:,:),SHP(:,:,:),TP(:,:,:)      

        REAL, ALLOCATABLE :: SI(:),SL(:)
 
        KMAX1=KMAX+1
        NMAX=2*KMAX+1

        ALLOCATE ( SI(KMAX1),SL(KMAX) )

        DO K=1,KMAX1
          SI(K)=DUMMY(K)
        END DO
        DO K=1,KMAX
          SL(K)=DUMMY(KMAX1+K)
        END DO

        ALLOCATE ( TV(IX,JX,KMAX), DIV(IX,JX,KMAX),
     &             VORT(IX,JX,KMAX),U(IX,JX,KMAX),
     &             V(IX,JX,KMAX),SH(IX,JX,KMAX) )

        ALLOCATE ( PSIG(IX,JX,KMAX),RH(IX,JX,KMAX),
     &         APG(IX,JX,KMAX),T(IX,JX,KMAX) )

        ALLOCATE ( P(NMAX),AP(NMAX) )
        ALLOCATE ( DIVP(IX,JX,NMAX),VORTP(IX,JX,NMAX),
     &             UP(IX,JX,NMAX), VP(IX,JX,NMAX),
     &             RHP(IX,JX,NMAX),SHP(IX,JX,NMAX),
     &             TP(IX,JX,NMAX) )

        COEF1=461.5/287.05-1.
        COEF2=287.05/9.8

c Surface Height and Surface Press
        DO J=1,JX
        DO I=1,IX
          ZS(I,J)=HDAT(I,J,1)
          PS(I,J)=EXP(HDAT(I,J,2))*1000.
          APS(I,J)=ALOG(PS(I,J))
        END DO
        END DO

c DIV, VORT, U, V, T and Specific Humidity at Sigma Level
        DO K=1,KMAX
          DO J=1,JX
          DO I=1,IX
            DIV(I,J,K)=HDAT(I,J,KMAX+4+4*(K-1))    
            VORT(I,J,K)=HDAT(I,J,KMAX+5+4*(K-1))   
            U(I,J,K)=HDAT(I,J,KMAX+6+4*(K-1)) 
            V(I,J,K)=HDAT(I,J,KMAX+7+4*(K-1))
            SH(I,J,K)=HDAT(I,J,KMAX*5+3+K)
            TV(I,J,K)=HDAT(I,J,3+K)
            T(I,J,K)=TV(I,J,K)/(1.+COEF1*SH(I,J,K))
          END DO
          END DO
        END DO
     
c Press at Sigma-Level
        DO K=1,KMAX
        DO J=1,JX
        DO I=1,IX
          PSIG(I,J,K)=SL(K)*PS(I,J)
          APG(I,J,K)=ALOG(PSIG(I,J,K))
        END DO
        END DO
        END DO

        DO J=1,JX
        DO I=1,IX
          TVD=TV(I,J,1)
          H(I,J,1)=ZS(I,J)-
     &            COEF2*TVD*(APG(I,J,1)-APS(I,J))        
          DO K=2,KMAX
            TVU=TV(I,J,K)
            H(I,J,K)=H(I,J,K-1)-
     &      COEF2*0.5*(TVD+TVU)*(APG(I,J,K)-APG(I,J,K-1))
            TVD=TVU
          END DO
        END DO
        END DO

c Const. P-Level      
        DO K=1,KMAX
          P(2*K-1)=SI(K)*PSFCM
          P(2*K)=SL(K)*PSFCM
        END DO
        P(NMAX)=SL(KMAX)*0.5*PSFCM
        DO N=1,NMAX
          AP(N)=ALOG(P(N))
        END DO

        GAMA=6.5E-3
        COEF3=COEF2*GAMA
        DO J=1,JX
        DO I=1,IX
          HP(I,J,1)=H(I,J,1)+
     &        T(I,J,1)/GAMA*(1.-(P(1)/PSIG(I,J,1))**COEF3)
          HP(I,J,NMAX)=H(I,J,KMAX)+
     &    T(I,J,KMAX)/GAMA*(1.-(P(NMAX)/PSIG(I,J,KMAX))**COEF3)
          DO N=2,NMAX-1
            K=(N-1)/2+1
            HP(I,J,N)=H(I,J,K)+
     &          T(I,J,K)/GAMA*(1.-(P(N)/PSIG(I,J,K))**COEF3)
          END DO
        END DO
        END DO
 
        DO N=1,NMAX
          K=(N-1)/2+1
c          PRINT*,'Press=',N,P(N)/100.
!          PRINT*,'Press1=',N,K,P(N),HP(20,20,N),H(20,20,K)
        END DO

c RH at K=1 (Sigma=0.995)
!        DO K=1,KMAX
        K=1
        DO J=1,JX
        DO I=1,IX
          DTEMP=T(I,J,K)-273.15
          ES=611.2*EXP(17.67*DTEMP/(DTEMP+243.5))
          SHS=0.622*ES/(PSIG(I,J,K)-0.378*ES)
          RH(I,J,K)=MIN(MAX(SH(I,J,K)/SHS,0.),1.0)
        END DO
        END DO
!        END DO

! Interpolate to Const. Press Level.
        DO J=1,JX
        DO I=1,IX
        DO N=1,NMAX
          IF(P(N).GE.PSIG(I,J,1))THEN        
! below SIGMA K=1
            DIVP(I,J,N)=DIV(I,J,1)
            VORTP(I,J,N)=VORT(I,J,1)
            UP(I,J,N)=U(I,J,1)
            VP(I,J,N)=V(I,J,1)
            RHP(I,J,N)=RH(I,J,1)           ! RH at SIGMA K=1
            TDRY=T(I,J,1)-GAMA*(HP(I,J,N)-H(I,J,1))
            DTEMP=TDRY-273.15
            ES=611.2*EXP(17.67*DTEMP/(DTEMP+243.5))
            SHS=0.622*ES/(P(N)-0.378*ES)
            SHP(I,J,N)=RHP(I,J,N)*SHS
            TP(I,J,N)=TDRY*(1.+COEF1*SHP(I,J,N))
! within domain
           ELSE IF((P(N).LT.PSIG(I,J,1)).AND.
     &             (P(N).GT.PSIG(I,J,KMAX)))THEN                            
             DO L=1,KMAX
              IF((P(N).LT.PSIG(I,J,L)).AND.
     &               (P(N).GE.PSIG(I,J,L+1)))THEN 
                W=(AP(N)-APG(I,J,L))/(APG(I,J,L+1)-APG(I,J,L))
c             W1=(P(N)-PSIG(I,J,L))/(PSIG(I,J,L+1)-PSIG(I,J,L))
                DIVP(I,J,N)=DIV(I,J,L)+
     &                      W*(DIV(I,J,L+1)-DIV(I,J,L))
                VORTP(I,J,N)=VORT(I,J,L)+
     &                      W*(VORT(I,J,L+1)-VORT(I,J,L))
                UP(I,J,N)=U(I,J,L)+W*(U(I,J,L+1)-U(I,J,L))
                VP(I,J,N)=V(I,J,L)+W*(V(I,J,L+1)-V(I,J,L))
                TP(I,J,N)=TV(I,J,L)+W*(TV(I,J,L+1)-TV(I,J,L))
                SHP(I,J,N)=SH(I,J,L)+W*(SH(I,J,L+1)-SH(I,J,L)) 
                GO TO 123
              END IF
             END DO
 123         CONTINUE
! above top
         ELSE IF(P(N).LE.PSIG(I,J,KMAX))THEN
           DIVP(I,J,N)=DIV(I,J,KMAX)
           VORTP(I,J,N)=VORT(I,J,KMAX)
           UP(I,J,N)=U(I,J,KMAX)
           VP(I,J,N)=V(I,J,KMAX)
           TDRY=T(I,J,KMAX)-GAMA*(HP(I,J,N)-H(I,J,KMAX))
           SHP(I,J,N)=SH(I,J,KMAX)
           TP(I,J,N)=TDRY*(1.+COEF1*SHP(I,J,N))
         ELSE
           PRINT*,'SOMETHING IS WRONG'
         END IF

        END DO
        END DO
        END DO

        DO J=1,JX
        DO I=1,IX
          PDAT(I,J,1)=HDAT(I,J,1)
          PDAT(I,J,2)=HDAT(I,J,2)
          PDAT(I,J,3)=HDAT(I,J,3)
          DO N=1,NMAX
            PDAT(I,J,NMAX+4+4*(N-1))=DIVP(I,J,N)
            PDAT(I,J,NMAX+5+4*(N-1))=VORTP(I,J,N)
            PDAT(I,J,NMAX+6+4*(N-1))=UP(I,J,N)
            PDAT(I,J,NMAX+7+4*(N-1))=VP(I,J,N)
            PDAT(I,J,NMAX*5+3+N)=SHP(I,J,N) 
            PDAT(I,J,3+N)=TP(I,J,N)
          END DO
        END DO
        END DO

        DEALLOCATE ( SI,SL )

        DEALLOCATE ( T, TV, DIV, VORT, U, V, SH )

        DEALLOCATE ( PSIG, RH, APG )

        DEALLOCATE ( P, AP )
        DEALLOCATE ( DIVP, VORTP, UP, VP, RHP, SHP, TP )


        END


        SUBROUTINE P2SIG(KMAX,MTV2,MTV3,HDPB,PDPB,PDAT,HDAT,
     &                   PSFCM,H,HP,KST)

c P to SIG conversion
c
c Input: HDPB (perturbation part), PDPB (perturbation part)
c Input: PDAT (total field), PDPB+PDAT = ENV part
C Ouput: HDPB (the value at the top most level kmax is not changed)
c KST: not used

        PARAMETER (IX=41, JX=41)

        REAL HDPB(IX,JX,MTV2),HDAT(IX,JX,MTV2)
        REAL PDPB(IX,JX,MTV3),PDAT(IX,JX,MTV3)
        REAL ZS(IX,JX),PS(IX,JX),APS(IX,JX)
        REAL H(IX,JX,KMAX),HP(IX,JX,2*KMAX+1) 

c        REAL(4) FHOUR,X(160),SI(KMAX+1),SL(KMAX)
        REAL*4 FHOUR,DUMMY(245)
        COMMON /COEF3/FHOUR,DUMMY

        REAL, ALLOCATABLE :: TV(:,:,:),DIV(:,:,:),VORT(:,:,:),
     &                       U(:,:,:),V(:,:,:),SH(:,:,:)
        REAL, ALLOCATABLE :: PSIG(:,:,:),RH(:,:,:),
     &                       APG(:,:,:)
        REAL, ALLOCATABLE :: P(:),AP(:)
        REAL, ALLOCATABLE :: DIVP(:,:,:),VORTP(:,:,:),UP(:,:,:),
     &                       VP(:,:,:),RHP(:,:,:)
        REAL, ALLOCATABLE :: TVP(:,:,:),TVP_E(:,:,:)
        REAL, ALLOCATABLE :: TP_E(:,:,:)
        REAL, ALLOCATABLE :: SHP(:,:,:),SHP_E(:,:,:)
        REAL, ALLOCATABLE :: HT_T(:,:,:),HSH_T(:,:,:)

        REAL, ALLOCATABLE :: SI(:),SL(:)

        KMAX1=KMAX+1
        NMAX=2*KMAX+1

        ALLOCATE ( SI(KMAX1),SL(KMAX) )

        DO K=1,KMAX1
          SI(K)=DUMMY(K)
        END DO
        DO K=1,KMAX
          SL(K)=DUMMY(KMAX1+K)
        END DO

        ALLOCATE ( TV(IX,JX,KMAX), DIV(IX,JX,KMAX),
     &             VORT(IX,JX,KMAX),U(IX,JX,KMAX),
     &             V(IX,JX,KMAX),SH(IX,JX,KMAX) )

        ALLOCATE ( PSIG(IX,JX,KMAX),RH(IX,JX,KMAX),
     &             APG(IX,JX,KMAX) )

        ALLOCATE ( HT_T(IX,JX,KMAX),HSH_T(IX,JX,KMAX) )

        ALLOCATE ( TVP(IX,JX,NMAX),TVP_E(IX,JX,NMAX),
     &             SHP(IX,JX,NMAX),SHP_E(IX,JX,NMAX),
     &             TP_E(IX,JX,NMAX) )

        ALLOCATE ( P(NMAX),AP(NMAX) )
        ALLOCATE ( DIVP(IX,JX,NMAX),VORTP(IX,JX,NMAX),
     &             UP(IX,JX,NMAX), VP(IX,JX,NMAX),
     &             RHP(IX,JX,NMAX) )

        COEF1=461.5/287.05-1.
        COEF2=287.05/9.8

c Surface Height and Surface Press
        DO J=1,JX
        DO I=1,IX
          ZS(I,J)=PDPB(I,J,1)                 ! Full field
          PS(I,J)=EXP(PDPB(I,J,2))*1000.      ! FULL field
          APS(I,J)=ALOG(PS(I,J))
        END DO
        END DO

c DIV, VORT, U, V, T and Specific Humidity at P-Level
        DO J=1,JX
        DO I=1,IX
        DO N=1,NMAX
          DIVP(I,J,N)=PDPB(I,J,NMAX+4+4*(N-1))
          VORTP(I,J,N)=PDPB(I,J,NMAX+5+4*(N-1))
          UP(I,J,N)=PDPB(I,J,NMAX+6+4*(N-1))
          VP(I,J,N)=PDPB(I,J,NMAX+7+4*(N-1))
          SHP(I,J,N)=PDPB(I,J,NMAX*5+3+N)
          SHP_E(I,J,N)=SHP(I,J,N)+PDAT(I,J,NMAX*5+3+N)
          TVP(I,J,N)=PDPB(I,J,3+N)
          TVP_E(I,J,N)=TVP(I,J,N)+PDAT(I,J,3+N)
          TP_E(I,J,N)=TVP_E(I,J,N)/(1.+COEF1*SHP_E(I,J,N))
        END DO
        END DO
        END DO

        DO J=1,JX
        DO I=1,IX
          DO K=1,KMAX-1
            HSH_T(I,J,K)=HDAT(I,J,KMAX*5+3+K)      ! Specific Hum.
            HT_T(I,J,K)=HDAT(I,J,3+K)
          END DO
        END DO
        END DO

c Const. P-Level      
        DO K=1,KMAX
          P(2*K-1)=SI(K)*PSFCM
          P(2*K)=SL(K)*PSFCM
        END DO
        P(NMAX)=SL(KMAX)*0.5*PSFCM
        DO N=1,NMAX
          AP(N)=ALOG(P(N))
        END DO

        GAMA=6.5E-3
        COEF3=COEF2*GAMA
!        DO J=1,JX
!        DO I=1,IX
!          TVD=TVP_E(I,J,1)
!          HP(I,J,1)=ZS(I,J)-
!     &            TP_E(I,J,1)/GAMA*(1.-(PS(I,J)/P(1))**COEF3)
!          DO N=2,NMAX
!            TVU=TVP_E(I,J,N)
!            HP(I,J,N)=HP(I,J,N-1)-
!     &      COEF2*0.5*(TVD+TVU)*(AP(N)-AP(N-1))
!            TVD=TVU
!          END DO
!        END DO
!        END DO

c Press at Sigma-Level
        DO K=1,KMAX
        DO J=1,JX
        DO I=1,IX
          PSIG(I,J,K)=SL(K)*PS(I,J)
          APG(I,J,K)=ALOG(PSIG(I,J,K))
        END DO
        END DO
        END DO


!        DO K=1,KMAX
!          N=2*K
!          DO J=1,JX
!          DO I=1,IX
!            H(I,J,K)=HP(I,J,N)+
!     &        TP_E(I,J,N)/GAMA*(1.-(PSIG(I,J,K)/P(N))**COEF3)
!          END DO
!          END DO
!        END DO

        DO N=1,NMAX
          K=(N-1)/2+1
c          PRINT*,'Press=',N,P(N)/100.
c          PRINT*,'Press2=',N,K,P(N),HP(20,20,N),H(20,20,K)
        END DO
 
c RH at Press level
!        DO N=1,NMAX
        N=1
        DO J=1,JX
        DO I=1,IX
          DTEMP=TP_E(I,J,N)-273.15
          ES=611.2*EXP(17.67*DTEMP/(DTEMP+243.5))
          SHS=0.622*ES/(P(N)-0.378*ES)
          RHP(I,J,N)=MIN(MAX(SHP_E(I,J,N)/SHS,0.),1.0)
        END DO
        END DO
!        END DO

! Interpolate to Sigma Level.
        DO J=1,JX
        DO I=1,IX
        DO K=1,KMAX
          IF(PSIG(I,J,K).GE.P(1))THEN        
! below Press K=1
            DIV(I,J,K)=DIVP(I,J,1)
            VORT(I,J,K)=VORTP(I,J,1)
            U(I,J,K)=UP(I,J,1)
            V(I,J,K)=VP(I,J,1)
            RH(I,J,K)=RHP(I,J,1)           ! RH at SIGMA K=1
            TDRY=TP_E(I,J,1)-GAMA*(H(I,J,K)-HP(I,J,1))
            DTEMP=TDRY-273.15
            ES=611.2*EXP(17.67*DTEMP/(DTEMP+243.5))
            SHS=0.622*ES/(PSIG(I,J,K)-0.378*ES)
            SH_E=RH(I,J,K)*SHS
            SH(I,J,K)=SH_E-HSH_T(I,J,K)           ! Pert. Part
            TV(I,J,K)=TDRY*(1.+COEF1*SH_E)-HT_T(I,J,K)
!            PRINT*,'LLL2=',SHP(I,J,1),SHP_E(I,J,K)
!            PRINT*,'     ',SH(I,J,K),SH_E
! within domain
           ELSE IF((PSIG(I,J,K).LT.P(1)).AND.
     &             (PSIG(I,J,K).GT.P(NMAX)))THEN                            
             DO L=1,NMAX-1
              IF((PSIG(I,J,K).LT.P(L)).AND.
     &               (PSIG(I,J,K).GE.P(L+1)))THEN 
                W=(APG(I,J,K)-AP(L))/(AP(L+1)-AP(L))
c                W1=(PSIG(I,J,K)-P(L))/(P(L+1)-P(L))
                DIV(I,J,K)=DIVP(I,J,L)+
     &                     W*(DIVP(I,J,L+1)-DIVP(I,J,L))
                VORT(I,J,K)=VORTP(I,J,L)+
     &                      W*(VORTP(I,J,L+1)-VORTP(I,J,L))
                U(I,J,K)=UP(I,J,L)+W*(UP(I,J,L+1)-UP(I,J,L))
                V(I,J,K)=VP(I,J,L)+W*(VP(I,J,L+1)-VP(I,J,L))
                TV(I,J,K)=TVP(I,J,L)+W*(TVP(I,J,L+1)-TVP(I,J,L))
              SH(I,J,K)=SHP(I,J,L)+W*(SHP(I,J,L+1)-SHP(I,J,L)) 
                GO TO 123
              END IF
             END DO
 123         CONTINUE
! above top
         ELSE IF(PSIG(I,J,K).LE.P(NMAX))THEN
           DIV(I,J,K)=DIVP(I,J,NMAX)
           VORT(I,J,K)=VORTP(I,J,NMAX)
           U(I,J,K)=UP(I,J,NMAX)
           V(I,J,K)=VP(I,J,NMAX)
           TDRY=TP_E(I,J,NMAX)-GAMA*(H(I,J,K)-HP(I,J,NMAX))
           SH(I,J,K)=SHP(I,J,NMAX)
           SH_E=SH(I,J,K)+HSH_T(I,J,K)
           TV(I,J,K)=TDRY*(1.+COEF1*SH_E)-HT_T(I,J,K)
         ELSE
           PRINT*,'SOMETHING IS WRONG'
         END IF

        END DO
        END DO
        END DO

        DO J=1,JX
        DO I=1,IX
          HDPB(I,J,1)=PDPB(I,J,1)
          HDPB(I,J,2)=PDPB(I,J,2)
          HDPB(I,J,3)=PDPB(I,J,3)
          DO K=1,KMAX-1
            HDPB(I,J,KMAX+4+4*(K-1))=DIV(I,J,K)
            HDPB(I,J,KMAX+5+4*(K-1))=VORT(I,J,K)
            HDPB(I,J,KMAX+6+4*(K-1))=U(I,J,K)
            HDPB(I,J,KMAX+7+4*(K-1))=V(I,J,K)
            HDPB(I,J,KMAX*5+3+K)=SH(I,J,K) 
            HDPB(I,J,3+K)=TV(I,J,K)
          END DO
        END DO
        END DO

        DEALLOCATE ( SI,SL )

        DEALLOCATE ( TV, DIV, VORT, U, V, SH )

        DEALLOCATE ( PSIG, RH, APG )

        DEALLOCATE ( P, AP )
        DEALLOCATE ( DIVP, VORTP, UP, VP, RHP, SHP )

        DEALLOCATE ( TVP, TVP_E, TP_E, SHP_E, HT_T, HSH_T)

        END

   

        SUBROUTINE MOVETX1(IGU,JGU,GLON,GLAT,DATG,DDAT)
       
        PARAMETER (IX=41,JX=41,NSG=80000)

        DIMENSION DATG(IGU,JGU),DDAT(IGU,JGU)
        DIMENSION GLAT(IGU,JGU),GLON(IGU,JGU)
        DIMENSION ING(NSG),JNG(NSG)

        COMMON /TR/ING,JNG,IB
        COMMON /NHC2/MDX,MDY
        COMMON /NHC3/AMDX,AMDY

        IWMAX=0.
        IWMIN=1000.
        JWMAX=0.
        JWMIN=1000.
        DO I = 1,IB
          IW = ING(I)
          JW = JNG(I)
          IF(IWMAX.LT.IW)IWMAX=IW
          IF(IWMIN.GT.IW)IWMIN=IW
          IF(JWMAX.LT.JW)JWMAX=JW
          IF(JWMIN.GT.JW)JWMIN=JW
        END DO
        IWMAX2=IWMAX+2
        IWMIN2=IWMIN-2
        JWMAX2=JWMAX+2
        JWMIN2=JWMIN-2

        print*,'qliu=',IWMAX2,IWMIN2,JWMAX2,JWMIN2

        DO IW1 = IWMIN2,IWMAX2
        DO JW1 = JWMIN2,JWMAX2
          IW=IW1+MDX
          JW=JW1+MDY
          IF(IW.GT.IGU)IW=IW-IGU
          IF(IW.LT.1)IW=IW+IGU
          HLA = GLAT(IW,JW)
          HLO = GLON(IW,JW)
C
          DO II=1,IGU-1
            HLO1 = GLON(II,10)+AMDX
            HLO2 = GLON(II+1,10)+AMDX
            IF(HLO1.GT.360.)HLO1=HLO1-360.
            IF(HLO1.LT.0.)HLO1=HLO1+360. 
            IF(HLO2.GT.360.)HLO2=HLO2-360.
            IF(HLO2.LT.0.)HLO2=HLO2+360. 
            IF((HLO.GT.HLO1.and.HLO.LE.HLO2).OR.
     &        (HLO.LE.HLO1.and.HLO.GT.HLO2))THEN
              DO JJ=1,JGU-1
                HLA1=GLAT(10,JJ)+AMDY
                HLA2=GLAT(10,JJ+1)+AMDY
              IF(HLA.LT.HLA1.and.HLA.GE.HLA2)THEN
                LX=II
                LY=JJ+1

                DXX = HLO-HLO1
                IF(HLO1.GT.HLO2)DXX=1.-(HLO-HLO2)
                DYY = HLA-HLA2
C
         X1 = DDAT(LX  ,LY-1)*DYY + DDAT(LX  ,LY  )*(1-DYY)
         X2 = DDAT(LX+1,LY-1)*DYY + DDAT(LX+1,LY  )*(1-DYY)
         Y1 = DDAT(LX+1,LY  )*DXX + DDAT(LX  ,LY  )*(1-DXX)
         Y2 = DDAT(LX+1,LY-1)*DXX + DDAT(LX  ,LY-1)*(1-DXX)
            DATT=(X1*(1-DXX)+X2*DXX + Y1*(1-DYY)+Y2*DYY)/2.
                DATG(IW,JW)=DATG(IW,JW)+DATT
c                print*,'tttest=',DATT,DATG(IW,JW),LX,LY
                GO TO 555
              END IF
              END DO

            END IF
          END DO
 555   CONTINUE
 
      ENDDO
      ENDDO
      END
   

        SUBROUTINE MOVETX(IGU,JGU,GLON,GLAT,DATG,DDAT)
       
        PARAMETER (IX=41,JX=41,NSG=80000)

        DIMENSION DATG(IGU,JGU),DDAT(IGU,JGU)
        DIMENSION GLAT(IGU,JGU),GLON(IGU,JGU)
        DIMENSION ING(NSG),JNG(NSG)
        DIMENSION HLON(200),HLAT(200)
        DIMENSION DTT(200,200),DTT2(200,200)
c        DIMENSION TEST(IGU,JGU)

        COMMON /TR/ING,JNG,IB
        COMMON /NHC2/MDX,MDY
        COMMON /NHC3/AMDX,AMDY


        RDIST2=AMDX*AMDX+AMDY*AMDY
        IF(RDIST2.LE.0.02)THEN
          DO I = 1,IB
            IW = ING(I)
            JW = JNG(I)
            DATG(IW,JW)=DATG(IW,JW)+DDAT(IW,JW)
          END DO
          RETURN
        END IF

c        TEST=DATG
c        CALL MOVETX1(TEST,DDAT)

        IWMAX=0.
        IWMIN=1000.
        JWMAX=0.
        JWMIN=1000.
        DO I = 1,IB
          IW = ING(I)
          JW = JNG(I)
          IF(IWMAX.LT.IW)IWMAX=IW
          IF(IWMIN.GT.IW)IWMIN=IW
          IF(JWMAX.LT.JW)JWMAX=JW
          IF(JWMIN.GT.JW)JWMIN=JW
        END DO
        IWMAX1=IWMAX+1
        IWMIN1=IWMIN-1
        JWMAX1=JWMAX+1
        JWMIN1=JWMIN-1

c        print*,'qliu=',IWMAX1,IWMIN1,JWMAX1,JWMIN1

        IIM=IWMAX-IWMIN+5
        JJM=JWMAX-JWMIN+5
        DO II=1,IIM
          II1=II+IWMIN-3 
          IF(II1.GT.IGU)II1=II1-IGU
          IF(II1.LT.1)II1=II1+IGU
          HLON(II) = GLON(II1,10)+AMDX
          DO JJ=1,JJM
            JJ1=JJ+JWMIN-3
            HLAT(JJ)=90.-(GLAT(10,JJ1)+AMDY)
            DTT(II,JJ)=DDAT(II1,JJ1)
          END DO
        END DO

        CALL splie2(HLON,HLAT,DTT,IIM,JJM,DTT2)

        DO IW1 = IWMIN1,IWMAX1
        DO JW1 = JWMIN1,JWMAX1
          IW=IW1+MDX
          JW=JW1+MDY
          IF(IW.GT.IGU)IW=IW-IGU
          IF(IW.LT.1)IW=IW+IGU
          HLA = 90.-GLAT(IW,JW)
          HLO = GLON(IW,JW)
C
        CALL splin2(HLON,HLAT,DTT,DTT2,IIM,JJM,HLO,HLA,DATT)
        DATG(IW,JW)=DATG(IW,JW)+DATT

c        DIFF=TEST(IW,JW)-DATG(IW,JW)
c        DIFF1=ABS(DIFF/(ABS(TEST(IW,JW))+1.E-15))
c        IF(DIFF1.GT.0.2)THEN
c          PRINT*,'QQQQ=',DIFF,TEST(IW,JW),DATG(IW,JW)
c        END IF
      ENDDO
      ENDDO
      END


        SUBROUTINE splie2(x1a,x2a,ya,m,n,y2a)
        INTEGER m,n,NN
        PARAMETER (NN=200)
        REAL x1a(NN),x2a(NN),y2a(NN,NN),ya(NN,NN)
        INTEGER j,k
        REAL y2tmp(NN),ytmp(NN)
        do j=1,m
          do k=1,n
            ytmp(k)=ya(j,k)
          end do
          call spline(x2a,ytmp,n,1.e30,1.e30,y2tmp)
          do k=1,n
            y2a(j,k)=y2tmp(k)
          end do
        end do
        return
        END

        SUBROUTINE splin2(x1a,x2a,ya,y2a,m,n,x1,x2,y)
        INTEGER m,n,NN
        PARAMETER (NN=200)
        REAL x1,x2,y,x1a(NN),x2a(NN)
        REAL y2a(NN,NN),ya(NN,NN)
        INTEGER j,k
        REAL y2tmp(NN),ytmp(NN),yytmp(NN)
        do j=1,m
          do k=1,n
            ytmp(k)=ya(j,k)
            y2tmp(k)=y2a(j,k)
          end do
          call splint(x2a,ytmp,y2tmp,n,x2,yytmp(j))
        end do
        call spline(x1a,yytmp,m,1.e30,1.e30,y2tmp)
        call splint(x1a,yytmp,y2tmp,m,x1,y)
        return
        END
 
       
        SUBROUTINE splint(xa,ya,y2a,n,x,y)
        INTEGER n,NN
        PARAMETER (NN=200)
        REAL x,y,xa(NN),y2a(NN),ya(NN)
        INTEGER k,khi,klo
        REAL a,b,h
        klo=1
        khi=n
   1    if((khi-klo).gt.1)then
          k=(khi+klo)/2
          if(xa(k).gt.x)then
            khi=k
          else
            klo=k
          end if
          go to 1
        end if
        h=xa(khi)-xa(klo)
        if(h.eq.0.)pause 'bad xa input in splint'
        a=(xa(khi)-x)/h
        b=(x-xa(klo))/h
        y=a*ya(klo)+b*ya(khi)+
     *    ((a**3-a)*y2a(klo)+(b**3-b)*y2a(khi))*(h**2)/6.
        return
        END

        SUBROUTINE spline(x,y,n,yp1,ypn,y2)
        INTEGER n,NN,NMAX
        PARAMETER (NN=200,NMAX=1000)
        REAL yp1,ypn,x(NN),y(NN),y2(NN)
        INTEGER i,k
        REAL p,qn,sig,un,u(NMAX)
        if(yp1.gt..99e30)then
          y2(1)=0.
          u(1)=0.
        else
          y2(1)=-0.5
          u(1)=(3./(x(2)-x(1)))*((y(2)-y(1))/(x(2)-x(1))-yp1)
        end if
        do i=2,n-1
          sig=(x(i)-x(i-1))/(x(i+1)-x(i-1))
          p=sig*y2(i-1)+2.
          y2(i)=(sig-1.)/p
          u(i)=(6.*((y(i+1)-y(i))/(x(i+1)-x(i))-(y(i)-y(i-1))
     *         /(x(i)-x(i-1)))/(x(i+1)-x(i-1))-sig*u(i-1))/p
        end do
        if(ypn.gt..99e30)then
          qn=0.
          un=0.
        else
          qn=0.5
          un=(3./(x(n)-x(n-1)))*(ypn-(y(n)-y(n-1))/(x(n)-x(n-1)))
        end if
        y2(n)=(un-qn*u(n-1))/(qn*y2(n-1)+1.)
        do k=n-1,1,-1
          y2(k)=y2(k)*y2(k+1)+u(k)
        end do
        return
        END

C
      SUBROUTINE FIND_NEWCT1(UD,VD)
      PARAMETER (IR=15,IT=24,IX=41,JX=41)
      PARAMETER (ID=41,JD=41,DTX=0.2,DTY=0.2)    ! Search x-Domain (ID-1)*DTX
      DIMENSION TNMX(ID,JD),UD(IX,JX),VD(IX,JX)
      DIMENSION WTM(IR),R0(IT)
      COMMON /POSIT/CLON_NEW,CLAT_NEW,SLON,SLAT,CLON,CLAT,RAD

      COMMON /vect/R0,XVECT(IT),YVECT(IT)
c      COMMON /CT/SLON,SLAT,CLON,CLAT,RAD
c      COMMON /GA/CLON_NEW,CLAT_NEW,R0
C
      PI=ASIN(1.)*2.
      RAD=PI/180.
C
      XLAT = CLAT-(JD-1)*DTY/2.
      XLON = CLON-(ID-1)*DTX/2.
c      print *,'STARTING LAT, LON AT FIND NEW CENTER ',XLAT,XLON
C
      DO I=1,ID
      DO J=1,JD
      TNMX(I,J) = 0.
      BLON = XLON + (I-1)*DTX
      BLAT = XLAT + (J-1)*DTY
C
C.. CALCULATE TANGENTIAL WIND EVERY 1 deg INTERVAL
C..  10*10 deg AROUND 1ST 1ST GUESS VORTEX CENTER
C
      DO 10 JL=1,IR
      WTS= 0.
      DO 20 IL=1,IT
      DR = JL
      DD = (IL-1)*15*RAD
      DLON = DR*COS(DD)
      DLAT = DR*SIN(DD)
      TLON = BLON + DLON
      TLAT = BLAT + DLAT
C.. INTERPOLATION U, V AT TLON,TLAT AND CLACULATE TANGENTIAL WIND
      IDX = IFIX(TLON) - SLON + 1
      IDY = IFIX(TLAT) - SLAT + 1
      DXX  = TLON - IFIX(TLON)
      DYY  = TLAT - IFIX(TLAT)
C
      X1 = UD(IDX  ,IDY+1)*DYY + UD(IDX  ,IDY)*(1-DYY)
      X2 = UD(IDX+1,IDY+1)*DYY + UD(IDX+1,IDY)*(1-DYY)
      Y1 = UD(IDX+1,IDY  )*DXX + UD(IDX,IDY  )*(1-DXX)
      Y2 = UD(IDX+1,IDY+1)*DXX + UD(IDX,IDY+1)*(1-DXX)
      UT = (X1*(1-DXX)+X2*DXX + Y1*(1-DYY)+Y2*DYY)/2.
      IF(IL.EQ.0.OR.IL.EQ.13) UT = Y1
      IF(IL.EQ.7.OR.IL.EQ.19) UT = X1
C
      X1 = VD(IDX  ,IDY+1)*DYY + VD(IDX  ,IDY)*(1-DYY)
      X2 = VD(IDX+1,IDY+1)*DYY + VD(IDX+1,IDY)*(1-DYY)
      Y1 = VD(IDX+1,IDY  )*DXX + VD(IDX,IDY  )*(1-DXX)
      Y2 = VD(IDX+1,IDY+1)*DXX + VD(IDX,IDY+1)*(1-DXX)
      VT = (X1*(1-DXX)+X2*DXX + Y1*(1-DYY)+Y2*DYY)/2.
      IF(IL.EQ.0.OR.IL.EQ.13) VT = Y1
      IF(IL.EQ.7.OR.IL.EQ.19) VT = X1
C.. TANGENTIAL WIND
      WT = -SIN(DD)*UT + COS(DD)*VT
      WTS = WTS+WT
20    CONTINUE
      WTM(JL) = WTS/24.
10    CONTINUE
C
C Southern Hemisphere
      IF(CLAT_NEW.LT.0)THEN
        DO JL=1,IR
          WTM(JL)=-WTM(JL)
        END DO
      END IF
C EnD SH

      TX = -10000000.
      DO KL = 1,IR
      IF(WTM(KL).GE.TX) THEN
      TX = WTM(KL)
      ENDIF
      ENDDO
C
      TNMX(I,J) = TX
      ENDDO
      ENDDO
C.. FIND NEW CENTER
      TTX = -1000000.
      DO I=1,ID
      DO J=1,JD
      IF(TNMX(I,J).GE.TTX) THEN
      TTX = TNMX(I,J)
      NIC = I
      NJC = J
      ENDIF
      ENDDO
      ENDDO
C
      CLAT_NEW = XLAT + (NJC-1)*DTY
      CLON_NEW = XLON + (NIC-1)*DTX
C
      print *,'NEW CENTER,  I, J IS   ',NIC,NJC
      print *,'NEW CENTER, LAT,LON IS ',CLAT_NEW,CLON_NEW
      print *,'MAX TAN. WIND AT NEW CENTER IS ',TTX
C
      RETURN
      END

