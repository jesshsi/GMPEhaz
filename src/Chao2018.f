c ------------------------------------------------------------------            
C *** Chao2018 (Crustal and Subduction - Model) Horizontal ***********
c ------------------------------------------------------------------            
      subroutine S04_Chao2018 ( mag, dist, ftype, lnY, sigma, specT, vs, Ztor, Z10,           
     1            vs30_class, attenName, period2, iflag, sourcetype, phi, tau, msasflag )         

      implicit none
C    2020/08/30 revised
      real mag, dip, fType, dist, vs, SA1180,
     1      Z10,  ZTOR, fltWidth, lnSa, sigma, lnY, vs30_rock, sourcetype
      real Fn, Frv, specT, period2, CRjb, phi, tau, z10_rock, SA_rock
      integer hwflag, iflag, vs30_class, regionflag, msasflag
      character*80 attenName                                                    

C     Set the reference spectrum.                
c     sourcetype = 0 for crustal
c                  1 for Subduction 
c     Vs30_class = 0 for estimated
c     Vs30_class = 1 for measured 
C     Mainshock and Aftershocks included based on MSASFlag
C         0 = Mainshocks
C         1 = Aftershocks

c     Compute SA1180
      vs30_rock = 1180.
      z10_rock = 0.004541444
      SA_rock = 0.
      
         call S04_Chaoetal2018 ( mag, dist, ftype, sigma, specT, vs30_rock, Ztor, z10_rock,
     1             SA_rock, vs30_class, attenName, iflag, sourcetype, phi, tau, lnSa, msasflag)
      Sa1180 = exp(lnSa)

c     Compute Sa at spectral period for given Vs30

         call S04_Chaoetal2018 ( mag, dist, ftype, sigma, specT, vs, Ztor, Z10,
     1             sa1180, vs30_class, attenName, iflag, sourcetype, phi, tau, lnSa, msasflag )

C     Convert ground motion to units of gals.
      lnY = lnSa + 6.89

      period2 = specT

      return
      end
c -------------------------------------------------------------------           
C **** Chao et al. 2018 (SSHAC model) *************
c -------------------------------------------------------------------           

      subroutine S04_Chaoetal2018 ( mag, dist, ftype, sigma, specT, vs, Ztor, Z10,           
     1            sa1180, vs30_class, attenName, iflag, sourcetype, phi, tau, lnSa, msasflag )                                   

      implicit none
      
      integer MAXPER                                                                            
      parameter (MAXPER=20)                                                     
      real ftype, dist, mag, lnSa, sigma, specT, lnYref, vs, Ztor, Z10, period1
      real period(MAXPER), c1(MAXPER), c2(MAXPER), c3(MAXPER), c4(MAXPER), c5(MAXPER)
      real c6(MAXPER), c7(MAXPER), c8(MAXPER), c9(MAXPER), c10(MAXPER), c11(MAXPER)
      real c12(MAXPER), c13(MAXPER), c14(MAXPER), c15(MAXPER), c16(MAXPER), c17(MAXPER)
      real c18(MAXPER), c19(MAXPER), c20(MAXPER), c21(MAXPER), c22(MAXPER), c23(MAXPER)
      real c24(MAXPER), c25(MAXPER), c26(MAXPER), c27(MAXPER), taucr1(MAXPER), taucr2(MAXPER)
      real tausb1(MAXPER), tausb2(MAXPER), phisscr1(MAXPER), phisscr2(MAXPER), phisssb1(MAXPER)
      real phisssb2(MAXPER), arfacr(MAXPER), arfasb(MAXPER), phis2s(MAXPER)
      character*80 attenName                                                    
      integer nper, count1, count2, C11flag, C23flag, C29flag, iflag, C10flag, C13flag
      integer vs30_class, n, i, msasflag
      integer Fcr, Fsb, Fcrss, Fcrno, Fcrro, Fsbintra, Fsbinter, Fas, Fkuo17, Fks17, Frf, Fmanila 
      real Mc, Mref, Mmax, Rrupref, Vs30ref, Zref, sourcetype
      real c1T, c2T, c3T, c4T, c5T, c6T, c7T, c8T, c9T, c10T, c11T, c12T, c13T, c14T, c15T
      real c16T, c17T, c18T, c19T, c20T, c21T, c22T, c23T, c24T, c25T, c26T, c27T
      real taucr1T, taucr2T, tausb1T, tausb2T, phisscr1T, phisscr2T, phisssb1T, phisssb2T
      real arfacrT, arfasbT, phis2sT, phi, tau, fm, SA1180, Z10ref
      real Ssource, Spath, Ssite, Ssitelin, Ssitenon, Sztor, Smag, Sgeom, Sanel
      real taucr, tausb, phisscr, phisssb, phiss, sigmass
      real c28(MAXPER), c29(MAXPER), c28T, c29T, c30(MAXPER), c30T, h
                                                                                
      data Period / 0, 0.01, 0.02, 0.03, 0.05, 0.075, 0.1, 0.15, 0.2, 0.25, 0.3, 0.4, 0.5, 0.75,
     1              1, 1.5, 2, 3, 4, 5 / 
      data c1 / -0.519289254712884, -0.518543529227763, -0.492593519338286, -0.477343613743583, -0.438422647347958, -0.347768047298708, -0.246441964148246, -0.077175127229613, 
     1          0.0405594808831559 , 0.116136007938687, 0.165919126145074, 0.214205666612737, 0.223625427021247, 0.152803930353289, 0.0183554539383078, -0.292640649397136,  
     1          -0.616489663751218, -1.21202179137219, -1.71876207853025,  -2.25241244815645 / 
      data c2 / -0.6150055029113330, -0.6139978370809050, -0.5849494939894080, -0.5646500549184690, -0.5082028496350560, -0.3945396148772630, -0.2774153233972800, -0.1082252757155910,  
     1          -0.0077282823725784, 0.0455512686241350, 0.0725370613365805, 0.0871536549688902, 0.0737703256835049, -0.0248167903571809, -0.1591378376284470, -0.4394400484356270,  
     1          -0.7252715132235520, -1.2593110926431200, -1.7255326287093000, -2.2233337887420500 / 
      data c3 / -0.6487900726643910, -0.6485291075803880, -0.6149768931486030, -0.5823569579995780, -0.4996495791530560, -0.3644851574401720, -0.2419849681859750, -0.0939554515669245,  
     1          -0.0329357162076816, -0.0218646332100325, -0.0359674153322261, -0.0785690467168578, -0.1248626176144320, -0.2511392119124840, -0.3854397008591480, -0.6634745672889770,  
     1          -0.9386642110776790, -1.4636739356095600, -1.9157987949568300, -2.3988731729506100 / 
      data c4 / -0.5859618870941580, -0.5838899830711630, -0.5994558769715950, -0.6229871080555090, -0.5509927916841400, -0.3788975825498850, -0.2159572988522690, -0.0188559515947778,  
     1          0.0977204826995843, 0.1828656137015420, 0.2295701498524820, 0.2764151479005750, 0.2932144086137190, 0.1388909993170780, -0.0815004332093187, -0.5698164868777540,  
     1          -1.0016397597173700, -1.6980520879594500, -2.2378527680411400, -2.7681880158076700 / 
      data c5 / 0.2995078226527580, 0.3025167286045810, 0.2896423927820520, 0.2895352598530250, 0.4201424505033270, 0.6660790354369400, 0.8837635057027910, 1.1045574548438600, 1.1425790790134700,  
     1          1.1166678356454500, 1.0576588366467200, 0.9207449431454760, 0.8027962857692040, 0.4519964034477110, 0.1288852589717840, -0.4777414376471740, -0.9827809560644520, -1.7669432223057700,  
     1          -2.3717405638272600, -2.9912308138027000 / 
      data c6 / -0.1252895878217900, -0.1244749736423930, -0.1255022048822760, -0.1281741601414120, -0.1278113776092280, -0.1257199250776420, -0.1221833768730910, -0.1151312333331240,  
     1          -0.1057191168540270, -0.0959115648679502, -0.0882656506919790, -0.0817387187650157, -0.0840244330603874, -0.1046230174209790, -0.1246837038142780, -0.1367512471546550,  
     1          -0.1204851699381740, -0.0595654650319802, 0.0060780094038531, 0.1087794828940540 / 
      data c7 / 0.1860213693406720, 0.1818440946548220, 0.1913815871815020, 0.1959394907475940, 0.2242032272922090, 0.2590114609066670, 0.2890209915658740, 0.3489251001067520, 0.3722539227241170,  
     1          0.3639273275607390, 0.3427750060884890, 0.2621885450896460, 0.1721136232246120, 0.0270194376114289, -0.0535877846749373, -0.1185422683336340, -0.1574596881853990, -0.2204723665783100,  
     1          -0.2907358910284120, -0.2475264997327470 / 
      data c8 / 0.4128529204313240, 0.4133627969553290, 0.3989282252665750, 0.3700049726661150, 0.3277716179853340, 0.3280509470422620, 0.3609773912176570, 0.4435666368994170, 0.5259387014440060,  
     1          0.5926458211482060, 0.6483788027762600, 0.7417540614842620, 0.8151053466925040, 0.9406307668392510, 1.0248278846159400, 1.1535846852560400, 1.2561590239982100, 1.3973296744797800,  
     1          1.4863934712127500, 1.5711476167331400 / 
      data c9 / 0.6654099729223670, 0.6662082185566420, 0.6316076153041100, 0.5722615232020440, 0.5335838412677030, 0.5915580071627310, 0.6796403235589960, 0.8206717947215570, 0.8944652896530820,  
     1          0.9514471984717970, 0.9819984405493800, 1.0112737345534200, 1.0356710065186700, 1.0243375273572300, 0.9984729722811390, 0.9228592531769220, 0.9157149198331690, 0.9588403924773120,  
     1          1.0614239334825600, 1.0248966641608600 / 
      data c10 / -0.1376176044286790, -0.1377874122648280, -0.1329759746961010, -0.1233348788754380, -0.1092566090939630, -0.1093481802115360, -0.1203234194869740, -0.1478533042267330,  
     1          -0.1753118327644590, -0.1975481854813300, -0.2161260130183380, -0.2472511509254110, -0.2717014152455810, -0.3135419875863270, -0.3393133894939400, -0.3551593410006160,  
     1          -0.3487315863272320, -0.3233624830738870, -0.3008016678137440, -0.2757023074987770 / 
      data c11 / -0.0000003768045793, -0.0000016455914614, -0.0010277552092071, -0.0013400986538279, -0.0009524028343619, -0.0010601014177568, -0.0095781938365105, -0.0797000195466235,  
     1          -0.1628405724059960, -0.2376907309394700, -0.2965674398979590, -0.3436334917221890, -0.3293921568751970, -0.2250006281710770, -0.1276588419069730, -0.0316373719436222,  
     1          -0.0067392342056503, -0.0000028831797237, -0.0000002303764802, -0.0000002893187016 / 
      data c12 / -0.0000002632651801, -0.0000010168484829, -0.0000007415198554, -0.0000008780800013, -0.0000009362783788, -0.0000014458228879, -0.0091311877263691, -0.1061400711142910,  
     1          -0.1905540130924890, -0.2386263420394340, -0.2665884284153660, -0.2565078736132940, -0.1956967186201360, -0.0911523105914097, -0.0409136585181734, -0.0058305420526171,  
     1          -0.0008274455605290, -0.0000043740923315, -0.0000003167873542, -0.0000007071111743 / 
      data c13 / -0.0000003479033210, -0.0000015396189431, -0.0000009243529219, -0.0000010741358947, -0.0000012076824503, -0.0000014938956048, -0.0000017618182496, -0.0116149978331732,  
     1          -0.0703516281536629, -0.1392336794544470, -0.2169703936280970, -0.3586252797911450, -0.4758435322483390, -0.6780831702704660, -0.7992367966752370, -0.9286080973093520,  
     1          -0.8998831651883260, -0.7774992929692280, -0.5992793127354700, -0.6712278770777070 / 
      data c14 / 0.0325013808122898, 0.0325478379384533, 0.0330191056515263, 0.0343101384872960, 0.0374313441023976, 0.0400261494009523, 0.0406923890414978, 0.0385365803750634, 0.0344218267917848,  
     1          0.0301984485118963, 0.0263787728828427, 0.0205765954005230, 0.0165224891710283, 0.0110013901513618, 0.0086318100105947, 0.0062127909966995, 0.0045185743588915, 0.0001846487026116,  
     1          -0.0045086409598014, -0.0080289129978441 / 
      data c15 / 0.0188003326071965, 0.0187424764459864, 0.0184348278192339, 0.0183116904998815, 0.0179647463512188, 0.0180580974419972, 0.0187576968592212, 0.0208403778461626, 0.0220145357833909,  
     1          0.0220498416898711, 0.0216264161548529, 0.0202875364431140, 0.0187963908607794, 0.0160522319622777, 0.0146222483242542, 0.0114205875168941, 0.0076239354167913, 0.0015942173971129,  
     1          -0.0033339971710007, -0.0055089260712685 / 
      data c16 / 0.0066214814780273, 0.0065978989650052, 0.0069331416349393, 0.0075119701817267, 0.0086002417698971, 0.0092132504242451, 0.0091770608487944, 0.0084255538167330, 0.0074084568455730,  
     1          0.0063660608238311, 0.0053861646702039, 0.0038382219060837, 0.0026597132484042, 0.0012402638358105, 0.0009003395366128, 0.0006726268670384, 0.0004849758370595, -0.0000443776256955,  
     1          -0.0004426514054550, 0.0002598589919845 / 
      data c17 / -1.3033352051553600, -1.3050707375477800, -1.3381199569179700, -1.3673880371344400, -1.4043378692826500, -1.4072088973593200, -1.3775350561906300, -1.3047454734934800,  
     1          -1.2525154396822100, -1.2210171934017700, -1.2047472906024600, -1.1921038099281000, -1.1860778618169400, -1.1698623108011400, -1.1508125147275900, -1.1172685240682800,  
     1          -1.0938451612547300, -1.0585068691241300, -1.0347965137315500, -0.9844367319831440 / 
      data c18 / -1.4222150700864700, -1.4244518028964800, -1.4144452691294700, -1.4049670408467200, -1.4529353769070100, -1.5212012494801500, -1.5588146355752500, -1.5546509544985100,  
     1          -1.5299381829848600, -1.5075909330134600, -1.4854043484828200, -1.4558697162866900, -1.4381584618490300, -1.3625787842858000, -1.3000691876438900, -1.1760450613418900,  
     1          -1.0683876519211600, -0.9286291899300890, -0.8267625726198150, -0.7634431186144020 / 
      data c19 / 0.3874353293578060, 0.3865358127626830, 0.3918303510961290, 0.4087284138519370, 0.4227955124257500, 0.4079055422317920, 0.3826772642202150, 0.3387081858027680, 0.2988014581902580,  
     1          0.2681747226996620, 0.2441324298126210, 0.2098186797110940, 0.1912179053378480, 0.1791792655901220, 0.1832396128840250, 0.1958900128843000, 0.2093417950110930, 0.2337544609389410,  
     1          0.2561912331555940, 0.2732908377032170 / 
      data c20 / 0.1816390684494260, 0.1799727376957520, 0.1909212976216070, 0.2120199290459480, 0.2059482358996180, 0.1599483130475640, 0.1180456788835990, 0.0762391834452875, 0.0598123873775724,  
     1          0.0472484189561765, 0.0419492390586564, 0.0408684583105697, 0.0410520296595116, 0.0659622332730993, 0.0943261823256111, 0.1499938137415910, 0.1991110124549130, 0.2596941009305470,  
     1          0.2946206159118700, 0.3203152022108220 / 
      data c21 / -0.0034295741595448, -0.0034138067537784, -0.0031761225955272, -0.0031597614295051, -0.0037038172429266, -0.0046735359569929, -0.0054981782655166, -0.0060699037646678,  
     1          -0.0057279870130134, -0.0050865192380324, -0.0043698926044844, -0.0031642937062858, -0.0023448358088493, -0.0013043059118461, -0.0008735093977044, -0.0005279011472397,  
     1          -0.0003935827881709, -0.0003265684501350, -0.0002970204994493, -0.0006897102389096 / 
      data c22 / -0.0034489780547407, -0.0034249196892139, -0.0036500842576487, -0.0039690305196895, -0.0042767503271602, -0.0044253262161005, -0.0044752635101850, -0.0043559591434871,  
     1          -0.0038467366062087, -0.0032636166820230, -0.0027135380939124, -0.0017940043857435, -0.0011582034067666, -0.0005882173264089, -0.0003997330115688, -0.0005031399510306,  
     1          -0.0008887392881376, -0.0016673660346856, -0.0024918478847597, -0.0030925027294924 / 
      data c23 / -2.5525572055834000, -2.5491215932210800, -2.5020049297189400, -2.3679999172581600, -2.0984569938797400, -1.8571475913759100, -1.6933015535378400, -1.4739793205860400,  
     1          -1.3537154633193600, -1.3112990269528600, -1.3252507728285300, -1.4077075423307700, -1.5070859378876100, -1.5844202517297500, -1.4244083078078700, -0.8544827391292060,  
     1          -0.4424325390151640, -0.0238666422441761, 0.0000000000000000, 0.0000000000000000 / 
      data c24 / -0.4820755783830470, -0.4817847143782920, -0.4722757215196650, -0.4533571902303470, -0.4174769587709540, -0.4031497826702400, -0.4106809740578840, -0.4462238803701860,  
     1          -0.4806650787981650, -0.5135409274151990, -0.5429162086543740, -0.5972162270181300, -0.6493752154999540, -0.7429284095282450, -0.7989976385952170, -0.8438703395779730,  
     1          -0.8536333300862120, -0.8486298188632920, -0.8369401809898650, -0.8223177494406110 / 
      data c25 / 0.0636111092153052, 0.0637979244436324, 0.0649888427251637, 0.0688570330004100, 0.0796477449779514, 0.0849015681692710, 0.0822852228887146, 0.0708425313555023, 0.0627269858251427,  
     1          0.0616544496255378, 0.0645387790445636, 0.0741639723226930, 0.0836822599658712, 0.1035767308819100, 0.1185000096002400, 0.1413533804677000, 0.1558153259573340, 0.1646442443399270, 
     1           0.1609560550301920, 0.1455355246584370 / 
      data c26 / -0.5680621936097360, -0.5671019863928200, -0.5300330753401030, -0.4674371210038970, -0.3278239226800660, -0.2257128580612920, -0.1971657286502670, -0.2504635484625670,  
     1          -0.3514329644238130, -0.4563389214185420, -0.5550263121051320, -0.7281908574894840, -0.8748820619897430, -1.1534790724423800, -1.3487217771603600, -1.5948082564095300,  
     1          -1.7120254817165000, -1.7746560709922100, -1.7432239926968500, -1.6392650516693500 / 
      data c27 / -0.6441908224323110, -0.6430624549208040, -0.6092543141804070, -0.5547847971008720, -0.4273786543769590, -0.3307477951183650, -0.3034342387568920, -0.3579852182163120, 
     1           -0.4494836594136780, -0.5390065111345010, -0.6210404997811030, -0.7628684799249960, -0.8876408712201270, -1.1395651591115200, -1.3270174440744400, -1.5616885373157400,  
     1          -1.6704563706071200, -1.7136221908604800, -1.6657097551617700, -1.5448698990426400 / 
      data c28 / -0.6148407238174470, -0.6134855454872920, -0.5783932279622350, -0.5162080030607480, -0.3669057022159870, -0.2557559184395190, -0.2273780092606650, -0.2973613635520170,  
     1          -0.4211846625506190, -0.5398009092490380, -0.6445535318562390, -0.8199077697170760, -0.9615402715827100, -1.2323996821315000, -1.4337289163009600, -1.6940289391677400,  
     1          -1.8185653745450900, -1.8823684494043700, -1.8532526872794200, -1.7280816734851900 / 
      data c29  / -0.4944663117848010, -0.4962061562087430, -0.4567832202723850, -0.3909967282502120, -0.3673342531461080, -0.4531985082804610, -0.5595380222575010,   
     1          -0.7066557777245760, -0.7761270389945640, -0.8288006277909410, -0.8538221721074140, -0.8746936616440970, -0.8939061858589470, -0.8389026019711570,   
     1          -0.7382346855789400, -0.5338216528196720, -0.4237829724483130, -0.3206735394784300, -0.3155245227823960, -0.1970906573510090 /
      data c30  / -0.4948250053327020, -0.5019638690208290, -0.4843335992997120, -0.4568941706767360, -0.4926026405594960, -0.5341761350472270, -0.5995654008335480,   
     1          -0.6646730464270010, -0.6765718066660800, -0.6846682992304260, -0.6735161372595090, -0.6381631348609450, -0.6160880182479380, -0.5147492098368240,   
     1          -0.4287560627663270, -0.2734691164270120, -0.2166062958480880, -0.2094181559654280, -0.2880704899694910, -0.2362019597302050 /
      data taucr1 / 0.3674988948492440, 0.3672959719907850, 0.3672096025203770, 0.3659401986651120, 0.3613130559351250, 0.3646238141279680, 0.3773149612260230, 0.4205159985547740,  
     1          0.4710484094826400, 0.5148599316146770, 0.5463002600989580, 0.5808849727025450, 0.5949464334180670, 0.5850050231740750, 0.5652851427812200, 0.5400623156625950, 0.5306044642337280,  
     1          0.5341895930662030, 0.5512683175278550, 0.5684528701196870 / 
      data taucr2 / 0.3156766103555770, 0.3154146574183840, 0.3193604175283950, 0.3269487169641220, 0.3457148557860690, 0.3603139641158800, 0.3622412109534710, 0.3393429192383280, 0.3078985636442060,  
     1          0.2855216261744740, 0.2736557189233880, 0.2713662162845130, 0.2871764340948960, 0.3462884754383560, 0.3922029871907690, 0.4389989898505710, 0.4525458066815850, 0.4630363429223910,  
     1          0.4723731595661930, 0.4816961813462040 / 
      data tausb1 / 0.2747114934261350, 0.2733100640145130, 0.2727371846461310, 0.2754713073378610, 0.2827051741664680, 0.2932224947572630, 0.3058662966967730, 0.3335166881059750, 0.3678152527072530,  
     1          0.3995944962541640, 0.4272231091987260, 0.4653458134731120, 0.4832505926756100, 0.4785627709562630, 0.4481274157753080, 0.3998380606154830, 0.3651681953582200, 0.3632239046532420,  
     1          0.3842160013347000, 0.4683567199764780 / 
      data tausb2 / 0.5404436414423900, 0.5413688232186000, 0.5590662841638730, 0.5782229669599770, 0.6026422039770350, 0.6001445469340250, 0.5804476608541280, 0.5289137551348660, 0.4963277349205770,  
     1          0.4770587925609880, 0.4656311763164020, 0.4672831153779370, 0.4803914686955640, 0.5185233324163180, 0.5644306606646860, 0.6147869472762440, 0.6249992145898750, 0.5759362561116940,  
     1          0.5005221059354860, 0.4119013474002300 / 
      data phisscr1 / 0.5284243730959070, 0.5279530156395120, 0.5212490565944880, 0.5138814813317350, 0.5030028370059200, 0.5039997875438060, 0.5174927775766600, 0.5530955106299720, 0.5816461579655670,  
     1          0.5994129051899660, 0.6091651025639550, 0.6113503193815050, 0.6007190809790290, 0.5620391824549910, 0.5259679896173710, 0.4771405443244140, 0.4491015982391830, 0.4215979819838170,  
     1          0.4088763842852300, 0.4034142608449920 / 
      data phisscr2 / 0.4400249261948010, 0.4402345932395540, 0.4457229793375830, 0.4562412368820710, 0.4708951658491060, 0.4668928640936500, 0.4518314029734340, 0.4276458197094800,  
     1          0.4175140424711400, 0.4166683191773280, 0.4221564137529650, 0.4361192706099510, 0.4486042327739210, 0.4718500465503010, 0.4845488048918390, 0.4911661512017220, 0.4851846396569770,  
     1          0.4631745228225680, 0.4389155701811710, 0.4200274542874700 / 
      data phisssb1 / 0.4358918335042310, 0.4366852410606870, 0.4284446929672800, 0.4231963576524820, 0.4104373460235670, 0.4088583646551290, 0.4208300424568200, 0.4552933469697380,  
     1          0.4781484644913840, 0.4900244567390270, 0.4957367311495720, 0.4955634501806600, 0.4926763166550150, 0.4894503194326150, 0.4855760478703810, 0.4858319625974600, 0.4819819680840680,  
     1          0.4732577539251810, 0.4595536649184570, 0.4420885624015020 / 
      data phisssb2 / 0.4982604989025690, 0.4979773327789170, 0.4997055429236690, 0.5062146219159800, 0.5195083771826150, 0.5248133353055360, 0.5207449309209680, 0.5112791219012840, 
     1           0.5035988500569350, 0.4964417374025240, 0.4906316632512320, 0.4867080815561310, 0.4858212403211350, 0.4871171137374260, 0.4913162411271670, 0.4862020347407820, 0.4774435589161110, 
     1           0.4497578024830470, 0.4197110255834490, 0.3737143966344340 / 
      data phis2s / 0.3435860891378130, 0.3437466383316600, 0.3492753254041860, 0.3642070292163550, 0.4080959377619060, 0.4440557923094290, 0.4560381766578650, 0.4393051343517960,  
     1          0.4117968194252760, 0.3893046381000030, 0.3720915588780540, 0.3527750902276900, 0.3446261711175850, 0.3419011444574020, 0.3475742684982780, 0.3584781550167080, 0.3657798632961100, 
     1           0.3748448621655020, 0.3802459556632600, 0.3884066340183610 / 

c Set attenuation name                                                            
c     Sourcetype = 0 Crustal
c     Sourcetype = 1 Subduction 
                                                                       
C Find the requested spectral period and corresponding coefficients
      nper = 20

C First check for the PGA case (i.e., specT=0.0) 
      if (specT .eq. 0.0) then
        c1T = c1(1)
        c2T = c2(1)
        c3T = c3(1)
        c4T = c4(1)
        c5T = c5(1)
        c6T = c6(1)
        c7T = c7(1)
        c8T = c8(1)
        c9T = c9(1)
        c10T = c10(1)
        c11T = c11(1)
        c12T = c12(1)
        c13T = c13(1)
        c14T = c14(1)
        c15T = c15(1)
        c16T = c16(1)
        c17T = c17(1)
        c18T = c18(1)
        c19T = c19(1)
        c20T = c20(1)
        c21T = c21(1)
        c22T = c22(1)
        c23T = c23(1)
        c24T = c24(1)
        c25T = c25(1)
        c26T = c26(1)
        c27T = c27(1)
        c28T = c28(1)
        c29T = c29(1)        
        c30T = c30(1)        
        taucr1T = taucr1(1)
        taucr2T = taucr2(1)
        tausb1T = tausb1(1)
        tausb2T = tausb2(1)
        phisscr1T = phisscr1(1)
        phisscr2T = phisscr2(1)
        phisssb1T = phisssb1(1)
        phisssb2T = phisssb2(1)
        phis2sT = phis2s(1)
       goto 1011
C   Function Form for PGV Regression     
       elseif (specT .eq. -2.0) then
         period1 = period(2)
         c1T = c1(2)
         c2T = c2(2)
         c3T = c3(2)
         c4T = c4(2)
         c5T = c5(2)
         c6T = c6(2)
         c7T = c7(2)
         c8T = c8(2)
         c9T = c9(2)
         c10T = c10(2)
         c11T = c11(2)
         c12T = c12(2)
         c13T = c13(2)
         c14T = c14(2)
         c15T = c15(2)
         c16T = c16(2)
         c17T = c17(2)
         c18T = c18(2)
         c19T = c19(2)
         c20T = c20(2)
         c21T = c21(2)
         c22T = c22(2)
         c23T = c23(2)
         c24T = c24(2)
         c25T = c25(2)
         c26T = c26(2)
         c27T = c27(2)
         c28T = c28(2)
         c29T = c29(2)        
         c30T = c30(2)        
         taucr1T = taucr1(2)
         taucr2T = taucr2(2)
         tausb1T = tausb1(2)
         tausb2T = tausb2(2)
         phisscr1T = phisscr1(2)
         phisscr2T = phisscr2(2)
         phisssb1T = phisssb1(2)
         phisssb2T = phisssb2(2)
         phis2sT = phis2s(2)
         goto 1011      
       endif
C Now loop over the spectral period range of the attenuation relationship.
         do i=3,nper-1
            if (specT .ge. period(i) .and. specT .le. period(i+1) ) then
               count1 = i
               count2 = i+1
               goto 1010 
            endif
         enddo
        
      write (*,*) 
      write (*,*) 'Chao et al. (2018) Horizontal atttenuation model'
      write (*,*) 'is not defined for a spectral period of: '
      write (*,'(a10,f10.5)') ' Period = ',specT
      write (*,*) 'This spectral period is outside the defined'
      write (*,*) 'period range in the code or beyond the range'
      write (*,*) 'of spectral periods for interpolation.'
      write (*,*) 'Please check the input file.'
      write (*,*) 
      stop 99

C Interpolate the coefficients for the requested spectral period.
 1010    call S24_interp (period(count1),period(count2),c1(count1),c1(count2), 
     +                specT,c1T,iflag)
         call S24_interp (period(count1),period(count2),c2(count1),c2(count2), 
     +                specT,c2T,iflag)
         call S24_interp (period(count1),period(count2),c3(count1),c3(count2), 
     +                specT,c3T,iflag)
         call S24_interp (period(count1),period(count2),c4(count1),c4(count2), 
     +                specT,c4T,iflag)
         call S24_interp (period(count1),period(count2),c5(count1),c5(count2), 
     +                specT,c5T,iflag)
         call S24_interp (period(count1),period(count2),c6(count1),c6(count2), 
     +                specT,c6T,iflag)
         call S24_interp (period(count1),period(count2),c7(count1),c7(count2), 
     +                 specT,c7T,iflag)
         call S24_interp (period(count1),period(count2),c8(count1),c8(count2), 
     +                 specT,c8T,iflag)
         call S24_interp (period(count1),period(count2),c9(count1),c9(count2), 
     +                 specT,c9T,iflag)
         call S24_interp (period(count1),period(count2),c10(count1),c10(count2), 
     +                 specT,c10T,iflag)
         call S24_interp (period(count1),period(count2),c11(count1),c11(count2), 
     +                 specT,c11T,iflag)
         call S24_interp (period(count1),period(count2),c12(count1),c12(count2), 
     +                 specT,c12T,iflag)
         call S24_interp (period(count1),period(count2),c13(count1),c13(count2), 
     +                 specT,c13T,iflag)
         call S24_interp (period(count1),period(count2),c14(count1),c14(count2), 
     +                 specT,c14T,iflag)
         call S24_interp (period(count1),period(count2),c15(count1),c15(count2), 
     +                 specT,c15T,iflag)
         call S24_interp (period(count1),period(count2),c16(count1),c16(count2), 
     +                 specT,c16T,iflag)
         call S24_interp (period(count1),period(count2),c17(count1),c17(count2), 
     +                 specT,c17T,iflag)
         call S24_interp (period(count1),period(count2),c18(count1),c18(count2), 
     +                 specT,c18T,iflag)
         call S24_interp (period(count1),period(count2),c19(count1),c19(count2), 
     +                 specT,c19T,iflag)
         call S24_interp (period(count1),period(count2),c20(count1),c20(count2), 
     +                 specT,c20T,iflag)
         call S24_interp (period(count1),period(count2),c21(count1),c21(count2), 
     +                 specT,c21T,iflag)
         call S24_interp (period(count1),period(count2),c22(count1),c22(count2), 
     +                 specT,c22T,iflag)
         call S24_interp (period(count1),period(count2),c23(count1),c23(count2), 
     +                 specT,c23T,iflag)
         call S24_interp (period(count1),period(count2),c24(count1),c24(count2), 
     +                 specT,c24T,iflag)
         call S24_interp (period(count1),period(count2),c25(count1),c25(count2), 
     +                 specT,c25T,iflag)
         call S24_interp (period(count1),period(count2),c26(count1),c26(count2), 
     +                 specT,c26T,iflag)
         call S24_interp (period(count1),period(count2),c27(count1),c27(count2), 
     +                 specT,c27T,iflag)
         call S24_interp (period(count1),period(count2),taucr1(count1),taucr1(count2), 
     +                 specT,taucr1T,iflag)
         call S24_interp (period(count1),period(count2),taucr2(count1),taucr2(count2), 
     +                 specT,taucr2T,iflag)
         call S24_interp (period(count1),period(count2),tausb1(count1),tausb1(count2), 
     +                 specT,tausb1T,iflag)
         call S24_interp (period(count1),period(count2),tausb2(count1),tausb2(count2), 
     +                 specT,tausb2T,iflag)
         call S24_interp (period(count1),period(count2),phisscr1(count1),phisscr1(count2), 
     +                 specT,phisscr1T,iflag)
         call S24_interp (period(count1),period(count2),phisscr2(count1),phisscr2(count2), 
     +                 specT,phisscr2T,iflag)
         call S24_interp (period(count1),period(count2),phisssb1(count1),phisssb1(count2), 
     +                 specT,phisssb1T,iflag)
         call S24_interp (period(count1),period(count2),phisssb2(count1),phisssb2(count2), 
     +                 specT,phisssb2T,iflag)
         call S24_interp (period(count1),period(count2),phis2s(count1),phis2s(count2), 
     +                specT,phis2sT,iflag)
         call S24_interp (period(count1),period(count2),c28(count1),c28(count2), 
     +                 specT,c28T,iflag)
         call S24_interp (period(count1),period(count2),c29(count1),c29(count2), 
     +                 specT,c29T,iflag)
         call S24_interp (period(count1),period(count2),c30(count1),c30(count2), 
     +                 specT,c30T,iflag)

  
 1011 period1 = specT

C      h = 10.0
      n = 2.0
      Mc = 7.1
      Mref = 6.5
      Mmax = 8
      Rrupref = 0.0
      Vs30ref = 760.0
    
C     Set the reference spectrum.                
c     sourcetype = 0 for crustal
c                  1 for Subduction 
c     Vs30_class = 0 for estimated
c     Vs30_class = 1 for measured 

      Fcr=0
      Fsb=0
      Fcrss = 0
      Fcrno = 0
      Fcrro = 0
      Fsbintra = 0
      Fsbinter = 0
      Fas = 0
      Fkuo17 = 0
      Fks17 = 0
      Frf = 0
      Fmanila = 0
      C11flag = 0
      C23flag = 0
      C29flag = 0
      C13flag = 0 
      C10flag = 0
   
      if (sourcetype .eq. 0.0 ) then
       Fcr = 1
       Zref = 0
         if(ftype .gt. 0) then
              Fcrro = 1
           elseif(ftype .lt. 0) then
              Fcrno = 1
           else
              Fcrss = 1
         endif
      elseif (sourcetype .eq. 1.0 ) then
        Fsb = 1
         if(ftype .eq. 0) then
              Fsbinter = 1
              Zref = 0
         elseif(ftype .eq. 1) then
              Fsbintra = 1
              Zref = 35
         endif
      endif
   
C     Add aftershock factor 
      if (msasflag .eq. 1) then
           Fas = 1
      endif 

C     choose Site ref by Vs30 class
        if (vs30_class .eq. 0 ) then
         Fks17 = 1
        elseif (vs30_class .eq. 1) then
         Fkuo17 = 1
        endif

      lnYref = c1T*Fcrro + c2T*Fcrss + c3T*Fcrno + c4T*Fsbinter + c5T*Fsbintra +
     &         c6T*Fas + c7T*Fmanila + c26T*Fkuo17 + c27T*Fks17 + c28T*Frf

C     Set Source scaling term 
     
      if(mag .LE. 5 ) then  
       C11flag=1
      endif
      if(mag .GE. Mc ) then  
       C29flag=1
      endif
      if(mag .GE. 7.6 ) then  
       C10flag=1
      endif   
      if(mag .LE. 6 ) then  
       C13flag=1
      endif   
      if (sourcetype .eq. 0.0 ) then
        Smag = c8T*(mag - Mref) + c10T*(mag - Mref)**2 
     1         - c10T*(mag-7.6)**2*C10flag + c11T*(5.0-mag)*C11flag  
      elseif (sourcetype .eq. 1.0 ) then
        Smag = c9T*(mag - Mref) + c29T*Fsbinter*(Mag-Mc)*c29flag + c30T*Fsbintra*(Mag-Mc)*c29flag 
     1        + c12T*(5.0-mag)*C11flag + c13T*(6.0-mag)*C13flag
      endif

      Sztor = c14T * Fcr *(Ztor-Zref) + c15T * Fsbinter * (Ztor-Zref) + c16T * Fsbintra * (Ztor-Zref)    
      Ssource = Smag + Sztor

C     Set Path scaling term

      h = 10.0*Fcr +10.0*Fsbinter*exp(0.3*(mag-7.1)*C29flag) + 10.0*Fsbintra*exp(0.2*(mag-7.1)*C29flag)
   
      if (sourcetype .eq. 0.0 ) then
          Sgeom = (c17T + c19T*(min(mag,Mmax)- Mref )) * alog(SQRT(dist**2 + h**2)/SQRT(Rrupref**2 + h**2))
      elseif (sourcetype .eq. 1.0 ) then
          Sgeom = (c18T + c20T*(min(mag, Mc )- Mref )) * alog(SQRT(dist**2 + h**2)/SQRT(Rrupref**2 + h**2))
      endif

      Sanel = c21T*Fcr*(dist-Rrupref) + c22T*Fsb*(dist-Rrupref)
      Spath = Sgeom + Sanel 
    
C     Set Site scaling term 
    
      Z10ref = exp((-4.08/2.0)*alog((vs**2.0+355.4**2.0)/(1750**2.0+355.4**2.0)))
      Ssitelin = c24T * alog(vs/vs30ref) + c25T*alog(Z10*1000/Z10ref)

      if(vs .LT. vs30ref ) then  
           C23flag=1
      endif
     
      Ssitenon = c23T * C23flag * (-1.5*alog(vs/vs30ref)-alog(SA1180+2.4)+alog(SA1180+2.4*(vs/vs30ref)**1.5))  
      Ssite = Ssitenon + Ssitelin

      lnSa =  lnYref + Ssource + Spath + Ssite                                        
   
c     write(*,*) "lnYref = ", lnYref
c     write(*,*) "Ssource = ", Ssource
c     write(*,*) "--Smag = ", Smag
c     write(*,*) "--Sztor = ", Sztor
c     write(*,*) "Spath = ", Spath
c     write(*,*) "--Sgeom = ", Sgeom
c     write(*,*) "--Sanel = ", Sanel
c     write(*,*) "Ssite = ", Ssite
c     write(*,*) "--Ssitelin = ", Ssitelin
c     write(*,*) "--Ssitenon = ", Ssitenon
c     write(*,*) "lnSa = ", lnSa
c    write(*,*) "Sa = ", exp(lnSa)

   
C     Set the event-specific residual term
 
      fm = 0.5*(min(6.5, max(4.5, mag))-4.5)
      
      taucr = taucr1T + (taucr2T - taucr1T)*fm
      tausb = tausb1T + (tausb2T - tausb1T)*fm 
      
      tau = taucr*Fcr + tausb*Fsb   
   
C     Set Site-specific residual term

      

C     Set Recoed-specific residual term

      phisscr = phisscr1T + (phisscr2T -phisscr1T)*fm
      phisssb = phisssb1T + (phisssb2T -phisssb1T)*fm

      phiss = phisscr*Fcr + phisssb*Fsb
      
      phi=(phis2sT**2+phiss**2)**0.5
      sigma=(tau**2+phi**2)**0.5
      sigmass=(tau**2+phiss**2)**0.5



c       write(*,*) "Y(gal) = ", exp(lnSa)

      return                                                                    
      end
