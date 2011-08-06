NB. Eigenvectors
NB.
NB. tgevcxx     Some or all of the right and/or left
NB.             eigenvectors of generalized Schur form
NB. tgevcxxb    Backtransformed right and/or left
NB.             eigenvectors of generalized Schur form
NB.
NB. testtgevc   Test tgevcxx by general matrices given
NB. testtgevcb  Test tgevcxxb by general matrices given
NB. testevc     Adv. to make verb to test tgevcxxx by
NB.             matrices of generator and shape given
NB.
NB. Version: 0.6.8 2010-11-30
NB.
NB. Copyright 2010 Igor Zhuravlov
NB.
NB. This file is part of mt
NB.
NB. mt is free software: you can redistribute it and/or
NB. modify it under the terms of the GNU Lesser General
NB. Public License as published by the Free Software
NB. Foundation, either version 3 of the License, or (at your
NB. option) any later version.
NB.
NB. mt is distributed in the hope that it will be useful, but
NB. WITHOUT ANY WARRANTY; without even the implied warranty
NB. of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
NB. See the GNU Lesser General Public License for more
NB. details.
NB.
NB. You should have received a copy of the GNU Lesser General
NB. Public License along with mt. If not, see
NB. <http://www.gnu.org/licenses/>.

coclass 'mt'

NB. =========================================================
NB. Local definitions

NB. ---------------------------------------------------------
NB. tgevcli
NB. tgevcui
NB.
NB. Description:
NB.   Calculate initial parameters for tgevcxxx
NB.
NB. Syntax:
NB.   'small big bignum d0 d1 d2 abnorm abrwork abscale'=. tgevcxi SP
NB. where
NB.   abrwork - x-vector
NB.   SP    - 2×n×n-matrix, Schur form, output of hgexxsxx
NB.   ...

tgevcui=: 3 : 0
  bignum=. % FP_SFMIN * c y
  small=. % FP_PREC * bignum
  big=. % small
  d0=. diag"2 y
  d1=. (]`(9&o.) ag) d0
  d2=. (sorim`| ag) d1
  abnorm=. norm1tc SP
  abrwork=. abnorm - sorim d0
  abscale=. % FP_SFMIN >. abnorm
  small ; big ; bignum ; d0 ; d1 ; d2 ; abnorm ; abrwork ; abscale
)

NB. ---------------------------------------------------------
NB. tgevclii
NB. tgevcuii
NB.
NB. Description:
NB.   Calculate initial parameters for particular iteration
NB.   of tgevcx
NB.
NB. Syntax:
NB.   'cond1 cond2 abcoeff abcoeffa d bigd'=. i tgevcxii init
NB. where
NB.   i     ≥ 0, integer, the iteration
NB.   init  - 9-vector of boxes, the output of tgevcxi
NB.   cond1 - 2×n×n-matrix, Schur form, output of hgexxsxx
NB.   ...

tgevcuii=: 4 : 0
  'small big bignum d0 d1 d2 abnorm abrwork abscale'=. y
  temp=. % (>./) FP_SFMIN , abscale * x {"1 d2
  sab=. abscale * temp * x {"1 d1
  abcoeff=. abscale * |. sab
  NB. scale
  lsab=. *./ ((>:&FP_SFMIN)`(<&small) ag) (|`sorim ag"1) (|. sab) ,: abcoeff
  scale=. >./ (-. lsab) (1:^:[)"0 (big <. abnorm) * small % (|`sorim ag) |. lsab
  if. +./ lsab do.
    scale=. scale <. % FP_SFMIN * >./ 1 , (|`sorim ag) abcoeff
    abcoeff=. lsab {"0 1 (abcoeff * scale) ,. (abscale * scale * |. sab)
  end.
  abcoeffa=. |`sorim ag abcoeff
  cond1=. +/ abcoeffa * abrwork
  dmin=. >./ FP_SFMIN , FP_PREC * abcoeffa * abnorm
  d=. + (+/) (1 _1 * abcoeff) * d0
  d=. (dmin >: sorim d) } d ,: dmin
  abs1d=. sorim d
  cond2=. 1 > abs1d
  bigd=. bignum * abs1d
  cond1 ; cond2 ; abcoeff ; abcoeffa ; d ; bigd
)

NB. ---------------------------------------------------------
NB. tgevcux
NB.
NB. Description:
NB.   Calculate right eigenvectors
NB.
NB. Syntax:
NB.   vapp=. vbt tgevcux
NB.   X=. (ios ; init) tgevcux SP
NB. where
NB.   ios  - k-vector, 
NB.   init - 9-vector of boxes, the output of tgevcxi
NB.   SP   - 2×n×n-matrix, Schur form, output of hgexxsxx
NB.   ...

tgevcux=: 1 : 0
:
  'ios small big bignum d0 d1 d2 abnorm abrwork abscale'=. x
  n=. c y
  X=. (n , 0) $ 0
  je=. <: # ios
  while. je >: 0 do.
    if. *./ FP_SFMIN >: (je { x) { d2 do.
      X=. (1 (c X) } n $ 0) ,. X
    else.
      'cond1 cond2 abcoeff abcoeffa d bigd'=. (je { x) tgevcuii }. x
      NB. triang solver
      work=. 1 ,~ +/ (1 _1 * abcoeff) * (((0 0,]),:(2,],1:)) je { x) ({.@(2 0 1&|:)) ,. 0 y
      j=. <: je { x
      while. j >: 0 do.
        NB. form x[j]
        if. ((sorim j { work) >: (j { bigd)) *. (j { cond2) do.
          work=. work % sorim j { work
        end.
        work=. j (-@(%&(j{d))) upd work
        if. j > 0 do.
          if. ((abcoeffa mp j{"1 abrwork) >: (bignum % sorim j { work)) *. (1 < sorim j { work) do.
            work=. work % sorim j { work
          end.
          workadd=. (1 _1 * abcoeff * j { work) * (((0 0,]),:(2,],1:)) j) ] ;. 0 y
          work=. (i. j) (+/@(,&workadd)) upd work
        end.
        j=. <: j
      end.
      NB. back transform
      work=. ((je { x) ({."1) _1 { y) u work
      NB. copy and scale eigenvector into X
      xmax=. normit work
      if. FP_SFMIN < xmax do.
        X=. (work % xmax) stitcht X
      else.
        X=. 0 ,. X
      end.
    end.
    je=. <: je
  end.
  X
)

NB. ---------------------------------------------------------
NB. tgevcuy
NB.
NB. Description:
NB.   Calculate left eigenvectors
NB.
NB. Syntax:
NB.   vapp=. vbt tgevcuy
NB.   X=. (ios ; init) tgevcuy SP
NB. where
NB.   ios  - k-vector, 
NB.   init - 9-vector of boxes, the output of tgevcxi
NB.   SP   - 2×n×n-matrix, Schur form, output of hgexxsxx
NB.   ...

tgevcuy=: 1 : 0
:
  'ios small big bignum d0 d1 d2 abnorm abrwork abscale'=. x
  n=. c y
  Y=. (n , 0) $ 0
  je=. 0
  while. je < # ios do.
    if. *./ FP_SFMIN >: (je { x) { d2 do.
      Y=. Y ,. (1 (c Y) } n $ 0)
    else.
      'cond1 cond2 abcoeff abcoeffa d bigd'=. (je { x) tgevcuii }. x
      NB. triang solver
      work=. 1
      xmax=. 1
      j=. >: je { x
      while. j < n do.
        NB. compute sum, scale if necessary
        if. (j { cond1) > (bignum % xmax) do.
          work=. work % xmax
          xmax=. 1
        end.
        sum=. +/ (1 _1 * abcoeff) * work mp"1 (j ((0,,~),:(2,-,1:)) je { x) (+@{.@(2 0 1&|:)) ,. 0 y
        NB. form x[j]
        if. ((sorim sum) >: (j { bigd)) *. (j { cond2) do.
          abs1sum=. sorim sum
          work=. work % abs1sum
          xmax=. xmax % abs1sum
          sum=. sum % abs1sum
        end.
        workj=. - sum % j { d
        work=. work , workj
        xmax=. xmax >. sorim workj
        j=. >: j
      end.
      NB. back transform
      work=. ((je { x) (}."1) 2 ({ :: 0:) y) u work
      NB. copy and scale eigenvector into Y
      xmax=. normit work
      if. FP_SFMIN < xmax do.
        Y=. Y stitchb work % xmax
      else.
        Y=. Y ,. 0
      end.
    end.
    je=. >: je
  end.
  Y
)

NB. =========================================================
NB. Interface

NB. ---------------------------------------------------------
NB.   Y=.  tgevcll  S ,: P
NB.   X=.  tgevclr  S ,: P
NB.   XY=. tgevclb  S ,: P
NB.   Y=.  tgevcllb S , P ,: Q
NB.   X=.  tgevclrb S , P ,: Z
NB.   XY=. tgevclbb S , P , Q ,: Z

tgevcll=: ($:~ (i.@c)) : ((; tgevcli) (] tgevcly) ])
tgevclr=: ($:~ (i.@c)) : ((; tgevcli) (] tgevclx) ])
tgevclb=: ($:~ (i.@c)) : ((; tgevcli) ((] tgevcly) ,: (] tgevclx)) ])

tgevcllb=: ($:~ (i.@c)) : ((; tgevcli) (mp tgevcly) ])
tgevclrb=: ($:~ (i.@c)) : ((; tgevcli) (mp tgevclx) ])
tgevclbb=: ($:~ (i.@c)) : ((; tgevcli) ((mp tgevcly) ,: (mp tgevclx)) ])

NB. ---------------------------------------------------------
NB.   Y=.  tgevcul  S ,: P
NB.   X=.  tgevcur  S ,: P
NB.   XY=. tgevcub  S ,: P
NB.   Y=.  tgevculb S , P ,: Q
NB.   X=.  tgevcurb S , P ,: Z
NB.   XY=. tgevcubb S , P , Q ,: Z

tgevcul=: ($:~ (i.@c)) : ((; tgevcui) (] tgevcuy) ])
tgevcur=: ($:~ (i.@c)) : ((; tgevcui) (] tgevcux) ])
tgevcub=: ($:~ (i.@c)) : ((; tgevcui) ((] tgevcuy) ,: (] tgevcux)) ])

tgevculb=: ($:~ (i.@c)) : ((; tgevcui) (mp tgevcuy) ])
tgevcurb=: ($:~ (i.@c)) : ((; tgevcui) (mp tgevcux) ])
tgevcubb=: ($:~ (i.@c)) : ((; tgevcui) ((mp tgevcuy) ,: (mp tgevcux)) ])

NB. =========================================================
NB. Test suite
