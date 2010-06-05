NB. expm.ijs
NB. Calculate matrix exponent and Cauchy integral
NB.
NB. prexpm  prepare time-invariant parts for expm
NB. expm    calculate matrix exponent and Cauchy integral
NB.
NB. References:
NB. - Podchukaev V.A. Theory of informational processes and systems. - M.,
NB.   2006. (Подчукаев В. А. Теория информационных процессов и систем. -
NB.   М.: Гардарики, 2006 - 209 с.)
NB.   URL: http://www.sgau.ru/uit/Book3.htm
NB. - Andrievskiy B.R., Fradkov A.L. Selected chapters of automatic
NB.   control theory with MATLAB examples. - SPb., 2000 (Андриевский Б.
NB.   Р., Фрадков А. Л. Избранные главы теории автоматического управления
NB.   с примерами на языке MATLAB. - СПб.: Наука, 2000. - 475 с., ил. 86)
NB.
NB. Resources:
NB. - http://www.jsoftware.com/jwiki/...
NB. - http://www.dvgu.ru/forum/...
NB.
NB. Test:
NB.    A=. 4 4 $ _0.0069 0.0558 0 _2.4525 _0.0226 _0.3149 3.6858 0 0.0062 _0.2151 _0.4282 0 0 0 0.2500 0
NB.    B=. 4 1 $ 0
NB.    Ts=. 0.1486
NB.    MVPN=. prexpm_tau_ A;B
NB.    ] 'Ad Bd'=. MVPN expm_tau_ Ts
NB. ┌─────────────────────────────────────────────────┬─┐
NB. │   0.998809   0.00806035 _0.00409042    _0.361715│0│
NB. │_0.00303186     0.946446    0.516207  0.000551852│0│
NB. │0.000936048   _0.0301219     0.93059 _0.000153388│0│
NB. │ 1.56358e_5 _0.000537876   0.0358006      0.99984│0│
NB. └─────────────────────────────────────────────────┴─┘
NB.
NB. TODO:
NB. - consider s/@:/@/g when possible
NB. - consider complex A or B => non-self-adjoined eigenvalues
NB. - consider B is vector
NB.
NB. 2008-02-02 0.0.0 Igor Zhuravlov |.'ur.ugvd.ciu@rogi'

require '~user/projects/lapack/lapack.ijs'     NB. '~addons/math/lapack/lapack.ijs'
NB. need_jlapack_ 'geev gels'
require '~user/projects/lapack/geev.ijs'       NB. '~addons/math/lapack/geev.ijs'
require '~user/projects/lapack/gels.ijs'       NB. '~addons/math/lapack/gels.ijs'

coclass 'tau'

NB. ===========================================================================
NB. prexpm
NB. Prepare time-invariant parts for expm
NB.
NB. Syntax:
NB.   'M V P Nx'=. A;B
NB. where:
NB.   A - Nx-by-Nx state matrix of LTI system
NB.   B - Nx-by-Nu control input matrix of LTI system
NB.   M - Nm-by-Ng matrix for equation M*A(t)=L(t), output of makeLtM
NB.   V - (#vm)-by-5 matrix, prepared eigenvalues of G, output of prepV
NB.   P - Ng-by-Ng-by-Ng matrix, powers 0..(Ng-1) of G, output of makeP
NB.   G - Ng-by-Ng matrix, augmented LTI system, output of makeG
NB.   Nm = +/ vm * (ic+1), see prepV
NB.   Ng = Nx + Nu
NB.   Nx >= 0
NB.   Nu >= 0

prexpm=: (((0 & makeLtM ; ]) @ prepV @ (2b010 & geev_jlapack_)) , (< @ makeP)) @ makeG , (< @ getCols @ getA)

NB. ---------------------------------------------------------
NB. expm
NB. Calculate matrix exponent
NB.   exp(A*T)
NB. and Cauchy integral
NB.   Integral(exp(A*(T-t))*dt,t=0..T)*B
NB. for sampling period T via Lagrange-Sylvester interpolation
NB. polynome
NB.
NB. Syntax:
NB.   'EA IE'=. MVPN expm T
NB. where:
NB.   MVPN - output of prexpm, being (M;V;P;Nx)
NB.   T    - sampling period, T>0
NB.   EA   - Nx-by-Nx matrix, matrix exponent
NB.   IE   - Nx-by-Nu matrix, Cauchy intergal
NB.   Nu   = (#P)-Nx

splitbyx=: {."1 ; }."1         NB. split table y at column x
extract=: [ splitbyx {.        NB. extract 1st x rows from table y
augsys=: +/ @ (getP * makeAt)  NB. find exponent of augmented system
expm=: getNx extract augsys

NB. ===========================================================================
NB. makeG
NB. Build G matrix of augmented LTI system: G = ( A  B ) Nx
NB.                                             ( 0  0 ) Nu
NB.                                               Nx Nu
NB. Syntax: G=: makeG A;B

makeG=: getA ((+ & getCols) {. ,.) getB

NB. ---------------------------------------------------------
NB. makeP
NB. Make report of G powers
NB.
NB. Syntax:
NB.   P=. makeP G
NB. where
NB.   G - Ng-by-Ng matrix, augmented LTI system, output of makeG
NB.   P - Ng-by-Ng-by-Ng matrix, powers 0..(Ng-1) of G
NB.
NB. Test:
NB.    ;/ makeP_tau_ ? 3 3 $ 10
NB. ┌─────┬─────┬────────┐
NB. │1 0 0│5 5 0│70 25 25│
NB. │0 1 0│9 0 5│50 75 35│
NB. │0 0 1│1 6 7│66 47 79│
NB. └─────┴─────┴────────┘
NB.
NB. Notes:
NB. - powers are calculated via repeated squaring to
NB.   reduce operations from O(Ng*Ng) to O(Ng*log Ng), see
NB.   http://www.jsoftware.com/jwiki/Essays/Linear_Recurrences
NB. - 0-th power (identity matrix) is substituted directly
NB.   without calculation

p2b=: < @ I. @ |.               NB. cvt bits of y to powers, then box it
pows=: p2b"1 @ #: @ i.          NB. call p2b for each power y represented binary
topow=: mp/ @ (mp~ @ ] ^: [)    NB. produce table y to powers from list x, then product all
topows=: > @ (topow &. >)       NB. apply dyad topow under boxes, then open
prepP=: (pows @ [) topows ]     NB. form boxed list of y ^ i. x
repl0=: (idmat @ [)`0:`prepP }  NB. replace 0-th element in y by identity matrix of size x
makeP=: # repl0 <               NB. call: (#G) repl0 (<G)

NB. ---------------------------------------------------------
NB. makeLtM
NB. Calculate matrix M or vector L(t) for equation M*A(t)=L(t)
NB.
NB. Syntax:
NB.   Lt=. T makeLtM V
NB.   M=. 0 makeLtM V
NB. where:
NB.   V  - (#vm)-by-5 matrix, prepared eigenvalues of G, output of prepV
NB.   T  - sampling period, T>0
NB.   M  - Nm-by-Ng matrix for equation M*A(t)=L(t)
NB.   Lt - Nm-vector, RHS L(t) for equation M*A(t)=L(t)
NB.   Nm = +/ vm * (ic+1), see prepV
NB.   Ng = #G
NB.
NB. Test:
NB.    1.1 makeLtM prepV 4 4 3 2j2 2j_2 1j1 1j_1 1j1 1j_1
NB. 81.4509 89.596 27.1126 _5.31123 _5.84235 7.29669 8.02636 1.36268 1.49895 1.64884 1.81372 2.67733 2.94507 3.23958 3.56353
NB.    0 makeLtM prepV 4 4 3 2j2 2j_2 1j1 1j_1 1j1 1j_1
NB. 1 4 16  64 256 1024 4096 16384  65536
NB. 0 1  8  48 256 1280 6144 28672 131072
NB. 1 3  9  27  81  243  729  2187   6561
NB. 1 2  0 _16 _64 _128    0  1024   4096
NB. 0 1  4   0 _64 _320 _768     0   8192
NB. 0 2  8  16   0 _128 _512 _1024      0
NB. 0 0  4  24  64    0 _768 _3584  _8192
NB. 1 1  0  _2  _4   _4    0     8     16
NB. 0 1  2   0  _8  _20  _24     0     64
NB. 0 0  2   6   0  _40 _120  _168      0
NB. 0 0  0   6  24    0 _240  _840  _1344
NB. 0 1  2   2   0   _4   _8    _8      0
NB. 0 0  2   6   8    0  _24   _56    _64
NB. 0 0  0   6  24   40    0  _168   _448
NB. 0 0  0   0  24  120  240     0  _1344

Tpows=: [ (^ i.) getmi                NB. T ^ i. mi
prepMi=: makeGi * makeTi              NB. prepare Mi=. Gi*Ti
prepLti=: (^ @ ([ * getli)) * Tpows   NB. prepare L[i](t)
prepLtMi=: prepLti`prepMi @. (0 = [)  NB. choose L[i](t) or M[i] to prepare
makeLtMi=: getic (c2r ^: [) prepLtMi  NB. complete L[i](t) or M[i], realificate if required
makeLtM=: ; @: (< @: makeLtMi " 1)    NB. make and merge all L[i](t) or M[i]

NB. ---------------------------------------------------------
NB. makeAt
NB. Solve equation M*A(t)=L(t) for A(t)
NB.
NB. Syntax:
NB.   At=. MVPN makeAt T
NB. where:
NB.   T    - sampling period, T>0
NB.   MVPN - output of prexpm, being (M;V;P;Nx)
NB.   At   - Nm-vector, solution A(t) of equation M*A(t)=L(t)
NB.   Nm = +/ vm * (ic+1), see prepV
NB.
NB. Test:
NB.    MVPN makeAt_tau_ Ts
NB. 0.999842 0.147562 0.0104619 0.00040034 0.000429799

makeAt=: gels_jlapack_ @: (getM ; ] makeLtM getV)

NB. ---------------------------------------------------------
NB. makeGi
NB. Calculate G[i] for M[i]
NB.
NB. Syntax:
NB.   Gi=. makeGi lambdai , ic , mi , IOs , Nm , k
NB. where:
NB.   k       - matrix G minimal polynom's order, k = Ng
NB.   Nm      = # M
NB.   IOs     - IO 1st row (atom) of corresp. M[i] (L[i](t)) in M (L(t))
NB.   mi      - multiplicity, taking self-adjoiners into account
NB.   ic      - datatype flag: 0 for real, 1 for complex
NB.   lambdai - i-th eigenvalue of G
NB.   Gi      - mi-by-k matrix, G[i]
NB.
NB. Test:
NB.    makeGi 1j1 1 4 7 15 9
NB. 1 1 1 1  1  1   1   1   1
NB. 0 1 2 3  4  5   6   7   8
NB. 0 0 2 6 12 20  30  42  56
NB. 0 0 0 6 24 60 120 210 336

xIO=: i. @ x:
xIOk=: xIO @ getk               NB. i. x: k
xIOmi=: xIO @ getmi             NB. i. x: mi
makeRji=: ! * ! @ [             NB. (!y)%(!y-x)
makeGi=: xIOmi makeRji"0/ xIOk  NB. call (mi makeRji k) for each pair (mi,k)

NB. ---------------------------------------------------------
NB. makeTi
NB. Calculate T1[i] or T2[i] and T3[i] for M[i]
NB.
NB. Syntax:
NB.   T1i=. makeTi lambdai , ic , mi , IOs , Nm , k
NB.   'T2i T3i'=. reim makeTi lambdai , ic , mi , IOs , Nm , k
NB. where:
NB.   k           - matrix G minimal polynom's order, k = Ng
NB.   Nm          = # M
NB.   IOs         - IO 1st row (atom) of corresp. M[i] (L[i](t)) in M (L(t))
NB.   mi          - multiplicity, taking self-adjoiners into account
NB.   ic          - datatype flag: 0 for real, 1 for complex
NB.   lambdai     - i-th eigenvalue of G
NB.   T1i,T2i,T3i - mi-by-k matrix, T1[i], T2[i] or T3[i] respectively
NB.
NB. Tests:
NB.    makeTi 4 0 2 0 15 9
NB. 1 4 16 64 256 1024 4096 16384 65536
NB. 0 1  4 16  64  256 1024  4096 16384
NB.
NB.    x: reim makeTi 1j1 1 4 7 15 9
NB. 1 1 0 _2 _4 _4  0  8 16
NB. 0 1 1  0 _2 _4 _4  0  8
NB. 0 0 1  1  0 _2 _4 _4  0
NB. 0 0 0  1  1  0 _2 _4 _4
NB.
NB. 0 1 2  2  0 _4 _8 _8  0
NB. 0 0 1  2  2  0 _4 _8 _8
NB. 0 0 0  1  2  2  0 _4 _8
NB. 0 0 0  0  1  2  2  0 _4

lipows=: getli (^ i.) getk    NB. lambdai ^ i. k
IOnmi=: - @ i. @ getmi        NB. 0 _1 _2 ... -(mi-1)
makeTi=: IOnmi shybyx lipows  NB. form mi-by-k table from vector's shifts

NB. ---------------------------------------------------------
NB. prepV
NB. Prepare eigenvalues: remove dups and self-adjoiners,
NB. classify and count. Outputs 5 columns:
NB. - lambdai, i-th eigenvalue
NB. - ic, datatype flag: 0 for real, 1 for complex
NB. - mi, multiplicity, taking self-adjoiners into account
NB. - IOs, IO 1st row (atom) of corresp. M[i] (L[i](t)) in M (L(t))
NB. - Nm = # M
NB. - k, matrix G minimal polynom's order, k = Ng
NB.
NB. If:
NB.       'vlambda vic vm vIOs vNm vk' =. |: prepV eigenvalues_of_G
NB. then
NB.       vk -: (# vm) $ k
NB.       vNm -: (# vm) $ Nm
NB.       (+/ vm) = k
NB.       (# vm) = (# vlambda) = (r - C)
NB.       ic -: ((0 ~: im) vlambda)
NB. where r - quantity of unique eigenvalues
NB.       C - quantity of unique complex eigenvalues without
NB.           self-adjoiners
NB.
NB. Test:
NB.    prepV 4 4 3 2j2 2j_2 1j1 1j_1 1j1 1j_1   NB. r=6, C=2
NB.   4 0 2 0 15 9
NB.   3 0 1 2 15 9
NB. 2j2 1 2 3 15 9
NB. 1j1 1 4 7 15 9

cnt=: 1: #. =                   NB. count atoms
IOs=: _1 & shybyx @ (+/\) @: *  NB. IO 1st row (atom) of corresponding M[i] (L[i](t)) in M (L(t))
ic=: (0 < im) @ ~.              NB. datatype flag
im=: 11 o. ]                    NB. take imaginary part
nnegim=: ] #~ 0 <: im           NB. filter out atoms with negative imaginary part
prepV=: (~. ,. (cnt (] ,. ([ (* ([ ,. (IOs ,. (+/ @: *))) ]) (>: @ ]))) ic)) @ nnegim ,. #

NB. ---------------------------------------------------------
NB. Utilities

getA=: 0 {:: ]        NB. extract A
getB=: 1 {:: ]        NB. extract B

getM=: 0 {:: [        NB. extract M
getV=: 1 {:: [        NB. extract V
getP=: 2 {:: [        NB. extract P
getNx=: 3 {:: [       NB. extract Nx

getli=: 0 { ]         NB. extract lambdai
getic=: 1 { ]         NB. extract ic
getmi=: 2 { ]         NB. extract mi
getIOs=: 3 { ]        NB. extract IOs
getNm=: 4 { ]         NB. extract Nm
getk=: 5 { ]          NB. extract k

getCols=: {: @ $      NB. get columns count of table y
reim=: 9 11 o."0 _ ]  NB. extract Re(y) and Im(y) from complex y
c2r=: ,/ @ reim       NB. realificate complex y
idmat=: =@i.          NB. identity matrix of size y
mp=: +/ .*            NB. matrix product of x and y
shybyx=: (|.!.0)"0 1  NB. shift y with step x
