require 'math/lapack2'

NB. Description:
NB.   Reduce a pair of square matrices (A,B) to generalized
NB.   upper Hessenberg form using orthogonal (unitary)
NB.   transformations, where A is a general matrix and B is
NB.   upper triangular
NB.
NB. Syntax:
NB.   'H T Q Z'=. (compQ , compZ) xgghrd ilo ; ihi ; A ; B ; Q1 ; Z1
NB. where
NB.   compQ - scalar, character, case-insensitive:
NB.             'N' - do not compute Q
NB.             'I' - to compute Q
NB.             'V' - to compute Q1*Q
NB.   compZ - scalar, character, case-insensitive:
NB.             'N' - do not compute Z
NB.             'I' - to compute Z
NB.             'V' - to compute Z1*Z
NB.   ilo   ∈ [1,n], IO starting column, 1-based
NB.   ihi   ∈ [1,n], IO ending column, 1-based
NB.   A     - n×n-matrix, numeric, upper triangular in
NB.           columns outside ilo:ihi
NB.   B     - n×n-matrix, numeric, upper triangular
NB.   Q1    - matrix, numeric:
NB.             n×n-matrix, orthogonal (unitary) if compQ='V'
NB.             0×0-matrix otherwise
NB.   Z1    - matrix, numeric:
NB.             n×n-matrix, orthogonal (unitary) if compZ='V'
NB.             0×0-matrix otherwise
NB.   H     - n×n-matrix, the upper Hessenberg in the upper
NB.           triangle and the first subdiagonal, and zeros
NB.           outside
NB.   T     - n×n-matrix, the upper triangular:
NB.             T = Q^H B Z
NB.   Q     - matrix:
NB.             0×0-matrix if compQ='N'
NB.             n×n-matrix, orthogonal (unitary):
NB.               Q    if compQ='I'
NB.               Q1*Q if compQ='V'
NB.   Z     - matrix:
NB.             0×0-matrix if compZ='N'
NB.             n×n-matrix, orthogonal (unitary):
NB.               Z    if compZ='I'
NB.               Z1*Z if compZ='V'
NB.   n     ≥ 0
NB.
NB. Notes:
NB. - the verbs below are loaded into the current locale

dgghrd=: 4 : 0
  assert. *./ (2 = # x) , x e. 'nNiIvV'
  'compQ compZ'=. x
  'ilo ihi A B Q1 Z1'=. y
  n=. {. sh=. $ A
  assert. 1 0&=`((0 , n)&I. , <:/)@.(* n) ilo , ihi
  assert.                      (ismatrix_jlapack2_ *. issquare_jlapack2_ *. isreal_jlapack2_                                   ) A
  assert.                      (ismatrix_jlapack2_ *. issquare_jlapack2_ *. isreal_jlapack2_ *. (-: utri_jlapack2_)    *. n = #) B
  assert. (compQ e. 'nNiI') +. (ismatrix_jlapack2_ *. issquare_jlapack2_ *. isreal_jlapack2_ *. isorthogonal_jlapack2_ *. n = #) Q1
  assert. (compZ e. 'nNiI') +. (ismatrix_jlapack2_ *. issquare_jlapack2_ *. isreal_jlapack2_ *. isorthogonal_jlapack2_ *. n = #) Z1
  select. 3!:0 A
    case. JCMPX do. A=. 9 o. A
    case. JFL   do.
    case.       do. A=. A + 0.0
  end.
  select. 3!:0 B
    case. JCMPX do. B=. 9 o. B
    case. JFL   do.
    case.       do. B=. B + 0.0
  end.
  if. compQ e. 'vV' do.
    select. 3!:0 Q1
      case. JCMPX do. Q1=. 9 o. Q1
      case. JFL   do.
      case.       do. Q1=. Q1 + 0.0
    end.
  end.
  if. compZ e. 'vV' do.
    select. 3!:0 Z1
      case. JCMPX do. Z1=. 9 o. Z1
      case. JFL   do.
      case.       do. Z1=. Z1 + 0.0
    end.
  end.
  Q1=. sh (0 0 $ 0.0)"_`(0.0 $~ [)`(|:@])@.(1 3 5 I. 'nNiIvV' i. compQ) Q1
  Z1=. sh (0 0 $ 0.0)"_`(0.0 $~ [)`(|:@])@.(1 3 5 I. 'nNiIvV' i. compZ) Z1
  ldAB=. , 1 >. n
  ldQ=.  , 1 >. 0:^:(compQ e. 'nN') n
  ldZ=.  , 1 >. 0:^:(compZ e. 'nN') n
  cdrc=. dgghrd_jlapack2_ (, compQ) ; (, compZ) ; (, n) ; (, ilo) ; (, ihi) ; (|: A) ; ldAB ; (|: B) ; ldAB ; Q1 ; ldQ ; Z1 ; ldZ ; , _1
  assert. 0 = _1 {:: cdrc
  (|: L: 0) 6 8 10 12 { cdrc
)

zgghrd=: 4 : 0
  assert. *./ (2 = # x) , x e. 'nNiIvV'
  'compQ compZ'=. x
  'ilo ihi A B Q1 Z1'=. y
  n=. {. sh=. $ A
  assert. 1 0&=`((0 , n)&I. , <:/)@.(* n) ilo , ihi
  assert.                      (ismatrix_jlapack2_ *. issquare_jlapack2_                                  ) A
  assert.                      (ismatrix_jlapack2_ *. issquare_jlapack2_ *. (-: utri_jlapack2_) *. (n = #)) B
  assert. (compQ e. 'iInN') +. (ismatrix_jlapack2_ *. issquare_jlapack2_ *. isunitary_jlapack2_ *. (n = #)) Q1
  assert. (compZ e. 'iInN') +. (ismatrix_jlapack2_ *. issquare_jlapack2_ *. isunitary_jlapack2_ *. (n = #)) Z1
  if.                    JCMPX ~: 3!:0 A  do. A=.  A  + 0j0 end.
  if.                    JCMPX ~: 3!:0 B  do. B=.  B  + 0j0 end.
  if. (compQ e. 'vV') *. JCMPX ~: 3!:0 Q1 do. Q1=. Q1 + 0j0 end.
  if. (compZ e. 'vV') *. JCMPX ~: 3!:0 Z1 do. Z1=. Z1 + 0j0 end.
  Q1=. sh (0 0 $ 0j0)"_`(0j0 $~ [)`(|:@])@.(1 3 5 I. 'nNiIvV' i. compQ) Q1
  Z1=. sh (0 0 $ 0j0)"_`(0j0 $~ [)`(|:@])@.(1 3 5 I. 'nNiIvV' i. compZ) Z1
  ldAB=. , 1 >. n
  ldQ=.  , 1 >. 0:^:(compQ e. 'nN') n
  ldZ=.  , 1 >. 0:^:(compZ e. 'nN') n
  cdrc=. zgghrd_jlapack2_ (, compQ) ; (, compZ) ; (, n) ; (, ilo) ; (, ihi) ; (|: A) ; ldAB ; (|: B) ; ldAB ; Q1 ; ldQ ; Z1 ; ldZ ; , _1
  assert. 0 = _1 {:: cdrc
  (|: L: 0) 6 8 10 12 { cdrc
)