 
!---------------------------------------------------------------------
!------------ FMS version number and tagname for this file -----------
         
! $Id: gases.f90,v 19.0 2012/01/06 20:04:44 fms Exp $
! $Name: siena $

  function gases(PRES_mb,T,RH,f)
  implicit none
  
! Purpose:
!   Compute 2-way gaseous attenuation through a volume in microwave
!
! Inputs:
!   [PRES_mb]   pressure (mb) (hPa)
!   [T]         temperature (K)
!   [RH]        relative humidity (%)
!   [f]         frequency (GHz), < 300 GHz
!
! Returns:
!   2-way gaseous attenuation (dB/km)
!
! Reference:
!   Uses method of Liebe (1985)
!
! Created:
!   12/09/05  John Haynes (haynes@atmos.colostate.edu)
! Modified:
!   01/31/06  Port from IDL to Fortran 90

  integer, parameter :: &
  nbands_o2 = 48 ,&
  nbands_h2o = 30
  real*8, intent(in) :: PRES_mb, T, RH, f
  real*8 :: gases, th, e, p, sumo, gm0, a0, ap, term1, term2, term3, &
            bf, be, term4, npp
  real*8, dimension(nbands_o2) :: v0, a1, a2, a3, a4, a5, a6
  real*8, dimension(nbands_h2o) :: v1, b1, b2, b3
  integer :: i
  
! // table1 parameters  v0, a1, a2, a3, a4, a5, a6  
  data v0/49.4523790,49.9622570,50.4742380,50.9877480,51.5033500, &
  52.0214090,52.5423930,53.0669060,53.5957480,54.1299999,54.6711570, &
  55.2213650,55.7838000,56.2647770,56.3378700,56.9681000,57.6124810, &
  58.3238740,58.4465890,59.1642040,59.5909820,60.3060570,60.4347750, &
  61.1505580,61.8001520,62.4112120,62.4862530,62.9979740,63.5685150, &
  64.1277640,64.6789000,65.2240670,65.7647690,66.3020880,66.8368270, &
  67.3695950,67.9008620,68.4310010,68.9603060,69.4890210,70.0173420, &
  118.7503410,368.4983500,424.7631200,487.2493700,715.3931500, &
  773.8387300, 834.1453300/
  data a1/0.0000001,0.0000003,0.0000009,0.0000025,0.0000061,0.0000141, &
  0.0000310,0.0000641,0.0001247,0.0002280,0.0003918,0.0006316,0.0009535, &
  0.0005489,0.0013440,0.0017630,0.0000213,0.0000239,0.0000146,0.0000240, &
  0.0000211,0.0000212,0.0000246,0.0000250,0.0000230,0.0000193,0.0000152, &
  0.0000150,0.0000109,0.0007335,0.0004635,0.0002748,0.0001530,0.0000801, &
  0.0000395,0.0000183,0.0000080,0.0000033,0.0000013,0.0000005,0.0000002, &
  0.0000094,0.0000679,0.0006380,0.0002350,0.0000996,0.0006710,0.0001800/
  data a2/11.8300000,10.7200000,9.6900000,8.8900000,7.7400000,6.8400000, &
  6.0000000,5.2200000,4.4800000,3.8100000,3.1900000,2.6200000,2.1150000, &
  0.0100000,1.6550000,1.2550000,0.9100000,0.6210000,0.0790000,0.3860000, &
  0.2070000,0.2070000,0.3860000,0.6210000,0.9100000,1.2550000,0.0780000, &
  1.6600000,2.1100000,2.6200000,3.1900000,3.8100000,4.4800000,5.2200000, &
  6.0000000,6.8400000,7.7400000,8.6900000,9.6900000,10.7200000,11.8300000, &
  0.0000000,0.0200000,0.0110000,0.0110000,0.0890000,0.0790000,0.0790000/
  data a3/0.0083000,0.0085000,0.0086000,0.0087000,0.0089000,0.0092000, &
  0.0094000,0.0097000,0.0100000,0.0102000,0.0105000,0.0107900,0.0111000, &
  0.0164600,0.0114400,0.0118100,0.0122100,0.0126600,0.0144900,0.0131900, &
  0.0136000,0.0138200,0.0129700,0.0124800,0.0120700,0.0117100,0.0146800, &
  0.0113900,0.0110800,0.0107800,0.0105000,0.0102000,0.0100000,0.0097000, &
  0.0094000,0.0092000,0.0089000,0.0087000,0.0086000,0.0085000,0.0084000, &
  0.0159200,0.0192000,0.0191600,0.0192000,0.0181000,0.0181000,0.0181000/
  data a4/0.0000000,0.0000000,0.0000000,0.0000000,0.0000000,0.0000000, &
  0.0000000,0.0000000,0.0000000,0.0000000,0.0000000,0.0000000,0.0000000, &
  0.0000000,0.0000000,0.0000000,0.0000000,0.0000000,0.0000000,0.0000000, &
  0.0000000,0.0000000,0.0000000,0.0000000,0.0000000,0.0000000,0.0000000, &
  0.0000000,0.0000000,0.0000000,0.0000000,0.0000000,0.0000000,0.0000000, &
  0.0000000,0.0000000,0.0000000,0.0000000,0.0000000,0.0000000,0.0000000, &
  0.0000000,0.6000000,0.6000000,0.6000000,0.6000000,0.6000000,0.6000000/
  data a5/0.0056000,0.0056000,0.0056000,0.0055000,0.0056000,0.0055000, &
  0.0057000,0.0053000,0.0054000,0.0048000,0.0048000,0.0041700,0.0037500, &
  0.0077400,0.0029700,0.0021200,0.0009400,-0.0005500,0.0059700,-0.0024400, &
  0.0034400,-0.0041300,0.0013200,-0.0003600,-0.0015900,-0.0026600, &
  -0.0047700,-0.0033400,-0.0041700,-0.0044800,-0.0051000,-0.0051000, &
  -0.0057000,-0.0055000,-0.0059000,-0.0056000,-0.0058000,-0.0057000, &
  -0.0056000,-0.0056000,-0.0056000,-0.0004400,0.0000000,0.0000000, &
  0.0000000,0.0000000,0.0000000,0.0000000/
  data a6/1.7000000,1.7000000,1.7000000,1.7000000,1.8000000,1.8000000,&
  1.8000000,1.9000000,1.8000000,2.0000000,1.9000000,2.1000000,2.1000000, &
  0.9000000,2.3000000,2.5000000,3.7000000,-3.1000000,0.8000000,0.1000000, &
  0.5000000,0.7000000,-1.0000000,5.8000000,2.9000000,2.3000000,0.9000000, &
  2.2000000,2.0000000,2.0000000,1.8000000,1.9000000,1.8000000,1.8000000, &
  1.7000000,1.8000000,1.7000000,1.7000000,1.7000000,1.7000000,1.7000000, &
  0.9000000,1.0000000,1.0000000,1.0000000,1.0000000,1.0000000,1.0000000/

! // table2 parameters  v1, b1, b2, b3
  data v1/22.2350800,67.8139600,119.9959400,183.3101170,321.2256440, &
  325.1529190,336.1870000,380.1973720,390.1345080,437.3466670,439.1508120, &
  443.0182950,448.0010750,470.8889740,474.6891270,488.4911330,503.5685320, &
  504.4826920,556.9360020,620.7008070,658.0065000,752.0332270,841.0735950, &
  859.8650000,899.4070000,902.5550000,906.2055240,916.1715820,970.3150220, &
  987.9267640/
  data b1/0.1090000,0.0011000,0.0007000,2.3000000,0.0464000,1.5400000, &
  0.0010000,11.9000000,0.0044000,0.0637000,0.9210000,0.1940000,10.6000000, &
  0.3300000,1.2800000,0.2530000,0.0374000,0.0125000,510.0000000,5.0900000, &
  0.2740000,250.0000000,0.0130000,0.1330000,0.0550000,0.0380000,0.1830000, &
  8.5600000,9.1600000,138.0000000/
  data b2/2.1430000,8.7300000,8.3470000,0.6530000,6.1560000,1.5150000, &
  9.8020000,1.0180000,7.3180000,5.0150000,3.5610000,5.0150000,1.3700000, &
  3.5610000,2.3420000,2.8140000,6.6930000,6.6930000,0.1140000,2.1500000, &
  7.7670000,0.3360000,8.1130000,7.9890000,7.8450000,8.3600000,5.0390000, &
  1.3690000,1.8420000,0.1780000/
  data b3/0.0278400,0.0276000,0.0270000,0.0283500,0.0214000,0.0270000, &
  0.0265000,0.0276000,0.0190000,0.0137000,0.0164000,0.0144000,0.0238000, &
  0.0182000,0.0198000,0.0249000,0.0115000,0.0119000,0.0300000,0.0223000, &
  0.0300000,0.0286000,0.0141000,0.0286000,0.0286000,0.0264000,0.0234000, &
  0.0253000,0.0240000,0.0286000/
  
! // conversions
  th = 300./T		! unitless
  e = (RH*th**5)/(41.45*10**(9.834*th-10))	! kPa
  p = PRES_mb/10.-e	! kPa

! // term1
  sumo = 0.
  do i=1,nbands_o2
    sumo = sumo + fpp_o2(p,th,e,a3(i),a4(i),a5(i),a6(i),f,v0(i)) &
           * s_o2(p,th,a1(i),a2(i))
  enddo
  term1 = sumo

! // term2
  gm0 = 5.6E-3*(p+1.1*e)*th**(0.8)
  a0 = 3.07E-4
  ap = 1.4*(1-1.2*f**(1.5)*1E-5)*1E-10
  term2 = (2*a0*(gm0*(1+(f/gm0)**2)*(1+(f/60.)**2))**(-1) + ap*p*th**(2.5)) &
          * f*p*th**2

! // term3
  sumo = 0.
  do i=1,nbands_h2o
    sumo = sumo + fpp_h2o(p,th,e,b3(i),f,v1(i)) &
           * s_h2o(th,e,b1(i),b2(i))
  enddo
  term3 = sumo

! // term4
  bf = 1.4E-6
  be = 5.41E-5
  term4 = (bf*p+be*e*th**3)*f*e*th**(2.5)

! // summation and result
  npp = term1 + term2 + term3 + term4
  gases = 0.182*f*npp

! ----- SUB FUNCTIONS -----
    
  contains
  
  function fpp_o2(p,th,e,a3,a4,a5,a6,f,v0)
  real*8 :: fpp_o2,p,th,e,a3,a4,a5,a6,f,v0
  real*8 :: gm, delt, x, y
  gm = a3*(p*th**(0.8-a4)+1.1*e*th)
  delt = a5*p*th**(a6)
  x = (v0-f)**2+gm**2
  y = (v0+f)**2+gm**2
  fpp_o2 = ((1./x)+(1./y))*(gm*f/v0) - (delt*f/v0)*(((v0-f)/(x))-((v0+f)/(x)))  
  end function fpp_o2
  
  function fpp_h2o(p,th,e,b3,f,v0)
  real*8 :: fpp_h2o,p,th,e,b3,f,v0
  real*8 :: gm, delt, x, y
  gm = b3*(p*th**(0.8)+4.8*e*th)
  delt = 0.
  x = (v0-f)**2+gm**2
  y = (v0+f)**2+gm**2
  fpp_h2o = ((1./x)+(1./y))*(gm*f/v0) - (delt*f/v0)*(((v0-f)/(x))-((v0+f)/(x)))
  end function fpp_h2o
  
  function s_o2(p,th,a1,a2)
  real*8 :: s_o2,p,th,a1,a2
  s_o2 = a1*p*th**(3)*exp(a2*(1-th))
  end function s_o2

  function s_h2o(th,e,b1,b2)
  real*8 :: s_h2o,th,e,b1,b2
  s_h2o = b1*e*th**(3.5)*exp(b2*(1-th))
  end function s_h2o
  
  end function gases
