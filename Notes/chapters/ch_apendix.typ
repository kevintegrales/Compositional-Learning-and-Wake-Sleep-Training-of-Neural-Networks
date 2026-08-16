// Funciones
#import "/math_functions.typ": *
#import "/notalmar.typ": *
#include "/notalmar.typ"
#let uu = $union$
#let yy = $inter$
#let XXX = $cal(X)$
#let YYY = $cal(Y)$
#let HHH = $cal(H)$
#let DDD = $cal(D)$
#let AAA = $cal(A)$
#let lll = $cal(l)$
#let vacuum = $text(font: "STIX Two Math", nothing)$
#let qquad = $space.quad$
#let alg = $cal(B)$
#let rangoX = $cal(X)$
#let rangoY = $cal(Y)$
#let Var(xx) = $"Var"(xx)$
#let Normal(aa, bb) = $"Normal"(aa, bb)$

== Matriz Hessiana
Sea $f: RR^d -> RR$ dos veces diferenciable. Luego, su *matriz Hessiana* $nabla^2 f$ está dada por
$
  (nabla^2 f(x))_(i j) := (partial^2 f(x))/(partial x_i partial x_j) qquad (forall i,j in [d], forall x in RR^d).
$

== Expansión de Taylor

Sea $f: RR^d -> RR$ diferenciable. Luego, su *expansión de Taylor* en torno a $y in RR^d$ es
$
  f(x) = f(y) + chevron nabla f (y), x - y chevron.r + 1/2 (x-y) nabla^2 f(xi) (y - x) qquad (forall x in RR^d)
$
donde $xi = x + t (y - x)$ para un $t in (0,1)$.

- Cuando se quiere aproximar, basta con hacer $xi = y$.

== Desigualdades de Cálculo

#propt[Bernoulli I][
  Si $x >= -1$ y $n in NN$, entonces
  $
    1+n x <= (1 + x)^n.
  $
]

#propt[Bernoulli II][
  Para todo $x in RR$ se tiene que $ 1 + x <= e^x. $
]

#prop[
  Cuando $x in (0, 1 slash 2)$,
  $
    1 - x >= e^(-2x).
  $
]

== Desigualdades de Probabilidades

=== Uniones e Intersecciones
Para eventos ${A_x}_(x in X) subset.eq Omega$, tendremos que
$
  P(union.big_(x in X) A_x) <= sum_(x in X) P(A_x).
$
y
$
  P(inter.big_(x in X) A_x) <= min_(x in X) P(A_x).
$

Si los $A_x$ son independientes,
$
  P(inter.big_(x in X) A_x) = product_(x in X) P(A_x)
$

=== Desigualdad de Hoeffding

#propt[Hoeffding][
  Sea $(theta_1,...,theta_m)$ una secuencia iid de variables aleatorias con soporte en un intervalo $[a,b]$ y tales que $E(theta_j) = mu$ para todo $j in [m].$ Entonces, para todo $epsilon > 0$, $ P(abs(mu - 1/m sum_(j=1)^m theta_i) > epsilon) <= 2 exp(- 2m epsilon^2/(b-a)^2). $
]

=== Desigualdad de Markov

#propt[Markov][
  Sea $X$ una variable aleatoria no-negativa y sea $a > 0$. Luego,
  $
    P(X >= a) <= E(X) / a.
  $
]