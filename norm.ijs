NB. Norms
NB.
NB. Interface:
NB.   norm1   Magnitude-based 1-norm of vector (matrix)
NB.   normi   Magnitude-based ∞-norm of vector (matrix)
NB.   norm1t  Taxicab-based 1-norm of vector (matrix)
NB.   normit  Taxicab-based ∞-norm of vector (matrix)
NB.   norms   Square-based Euclidean (Frobenius) norm of
NB.           vector (matrix)
NB.
NB. Requisites:
NB.   Copyright (C) 2010 Igor Zhuravlov
NB.   For license terms, see the file COPYING in this distribution
NB.   Version: 1.0.0 2010-06-01

coclass 'mt'

NB. =========================================================
NB. Local definitions

mocs=: >./ @ (+/   ) @:  NB. vector: sum of, matrix: max of column sums
mors=: >./ @ (+/"_1) @:  NB. vector: max of, matrix: max of row sums

NB. =========================================================
NB. Interface

NB. ---------------------------------------------------------
NB. Magnitude-based norms |y|

norm1=: | mocs           NB. 1-norm of vector (matrix), implements LAPACK's DZSUM1,xLANGE('1'),xLANHE('1'),xLANHS('1'),xLANHT('1'),xLANST('1'),xLANTR('1')
normi=: | mors           NB. ∞-norm of vector (matrix), implements LAPACK's xLANGE('i'),xLANHE('i'),xLANHS('i'),xLANHT('i'),xLANST('i'),xLANTR('i')

NB. ---------------------------------------------------------
NB. Taxicab-based norms |Re(y)| + |Im(y)|

norm1t=: sorim mocs      NB. 1-norm of vector (matrix), implements BLAS's DASUM,DZASUM
normit=: sorim mors      NB. ∞-norm of vector (matrix)

NB. ---------------------------------------------------------
NB. Square-based Euclidean (Frobenius) norm of vector
NB. (matrix)
NB.
NB. Note:
NB. - implements BLAS's DZNRM2 and partially xLASSQ
NB. - implements LAPACK's xLANGE('f'),xLANHE('f'),xLANHS('f'),xLANHT('f'),xLANST('f'),xLANTR('f')

norms=: (((((+/^:_) &.: *:) @: %) * ]) (>./^:_)) @: | @: +.
