NB. scl.ijs
NB. Scale
NB.
NB. scl  Try to scale without overflow or underflow
NB.
NB. Copyright (C) 2010 Igor Zhuravlov
NB. For license terms, see the file COPYING in this distribution
NB. Version: 1.0.0 2010-06-01

coclass 'mt'

NB. =========================================================
NB. Local definitions

NB. =========================================================
NB. Interface

NB. ---------------------------------------------------------
NB. scl
NB.
NB. Description:
NB.   Try to scale a noun without overflow or underflow
NB.
NB. Syntax:
NB.   Ascl=. (f,t) scl A
NB. where
NB.   A    - r-rank array
NB.   f    ≠ 0, atom
NB.   t    - atom
NB.   Ascl - r-rank array, being A scaled by ratio (t/f)
NB.          without under- or overflow, if possible
NB.   r    ≥ 0, integer
NB.
NB. Formula:
NB.   if |(f*FP_SFMIN)*FP_SFMIN| > |t|
NB.     A := (t/((f*FP_SFMIN)*FP_SFMIN))*((A*FP_SFMIN)*FP_SFMIN)
NB.   elseif |f*FP_SFMIN| > |t|
NB.     A := (t/(f*FP_SFMIN))*(A*FP_SFMIN)
NB.   elseif |(t/FP_SFMAX)/FP_SFMAX| > |f|
NB.     A := (((t/FP_SFMAX)/FP_SFMAX)/f)*((A*FP_SFMAX)*FP_SFMAX)
NB.   elseif |t/FP_SFMAX| > |f|
NB.     A := ((t/FP_SFMAX)/f)*(A*FP_SFMAX)
NB.   else
NB.     A := (t/f)*A
NB.   endif
NB. where
NB.   FP_SFMAX := 1/FP_SFMIN
NB.
NB. Algorithm:
NB.   In: A f t
NB.   Out: Ascl
NB.   1) find lIOS |f| and |t| in scale vector (1,1,FP_SFMIN)
NB.      1.1) form vector (|f|,|t|)
NB.      1.2) form matrix:
NB.             ( |t|*FP_SFMIN*FP_SFMIN  |t|*FP_SFMIN )
NB.             ( |f|*FP_SFMIN*FP_SFMIN  |f|*FP_SFMIN )
NB.      1.3) form 2-vector ioft, where
NB.             ioft[0] := (|t|*FP_SFMIN*FP_SFMIN,|t|*FP_SFMIN) I. |f|
NB.             ioft[1] := (|f|*FP_SFMIN*FP_SFMIN,|f|*FP_SFMIN) I. |t|
NB.   2) find io:
NB.        io := ioft[0]-ioft[1]
NB.   3) scale A
NB.      3.1) find scaled ratio (f/t)
NB.           3.1.1) form scaling vector
NB.                    ftscl := ioft { (1,1,FP_SFMIN)
NB.           3.1.2) scale (f,t) down by ftscl
NB.                    (f,t) := ftscl (* ^: |io|) (f,t)
NB.           3.1.3) find scaled ratio
NB.                    ft := f/t
NB.      3.2) scale A up or down
NB.             Ascl := FP_SFMIN (* ^: io) A
NB.      3.3) scale A by ratio
NB.             Ascl := ft * Ascl
NB.
NB. Notes:
NB. - models LAPACK's xLASCL('G'), when A is a matrix
NB. - models LAPACK's xDRSCL, when A is a vector and t=1

scl=: 4 : 0
  ioft=. ((FP_SFMIN |:@:(*^:2 1) |.) I."1 0 ])@:| x
  io=. -/ ioft
  (%~/ (({&(1 1,FP_SFMIN)) ioft) *^:(| io) x) * (FP_SFMIN&* ^: io y)
)