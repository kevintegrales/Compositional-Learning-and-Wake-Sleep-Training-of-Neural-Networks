// Funciones
#import "/math_functions.typ": *
#import "/notalmar.typ": *
#include "/notalmar.typ"


== Flat Minima
#notat[Fuente][
  Contenido estudiado de _"Flat Minima"_ de S. Hochreiter y J. Schmidhuber (1997).
  #fuente_link("https://doi.org/10.1162/neco.1997.9.1.1", "DOI:10.1162/neco.1997.9.1.1")
]

TODO

En el paper se presenta un modelo que, además de hacer _backpropagation_ para encontrar pesos de una red neuronal, busca mínimos planos que, apoyándose del principio MDL (a partir de robustez), generalicen mejor.

=== Tarea y Arquitectura

Queremos aproximar una función desconocida $f: X->Y$, donde $X subset RR^N$ y $Y subset RR^K$. Suponga que tenemos un conjunto de datos $D subset X times Y$ que se divide en los datos de entrenamiento $D_0$ y en los datos de test $D without D_0$. Para aproximar $f$, ajustaremos los pesos $w in W subset RR^L$ de la red
$
  "net"(w): x |-> o(w; x),
$
donde $o(w;x) = (o^1 (w; x), ..., o^K (w; x)) in RR^K$ es la salida de la red con pesos $w$ e input $x$ (es decir, $"net"(w) (x) = o(w;x)$).

En el espacio de pesos $W subset RR^L$ definimos, dado un peso $w$, la *caja* $M_w$ como un hipercuboide de $L$ dimensiones centrado en $w$. Además, definimos el *error tolerable* $E_"tol" > 0$ como el máximo error que aceptaremos respecto a parte de la función de pérdida. Así, un peso $w$ será un *mínimo aceptable* si  se satisface que
$
  E("net"(w), D_0) := sum_((x_p, y_p) in D_0) norm(y_p - o(w, x_p))^2 <= E_"tol",
$
donde $E(dot, dot)$ es el error cuadrático sumado. (En caso de que la desigualdad sea en sentido contrario hablamos de *underfitting*.) Diremos que un *mínimo plano* es una región conexa de mínimos aceptables. El objetivo del algoritmo será encontrar mínimos aceptables con cajas de gran volumen.


=== Algoritmo FMS

Se presenta el algoritmo *Flat Minimum Search* (FMS). Este algoritmo no sólo mimiza $E("net"(w), D_0)$ respecto a $w$, sino que considera
$
  E(w, D_0) := E("net"(w), D_0) + lambda B(w, X_0),
$
donde:
- $X_0 = {x_p: (x_p, y_p) in D_0}$, 
- $lambda >= 0$ es un hiperparámetro que controla la importancia que se da a que el mínimo sea plano, y
- $B(w, X_0)$ es un término que permite aumentar el volumen de la caja $M_w$ (minimizarlo maximiza el volumen de ella), donde $ B(w, X_0) = sum_(x_p in X_0) B(w, x_p) $ y $
    B(w, x_p) = 1/2 (
      - L log epsilon
      + sum_(i, j) log sum_(k=1)^K ((partial o^k (w, x_p)) / (partial w_(i j)))^2
      + L log sum_(k=1)^K (
          sum_(i, j)
          abs((partial o^k (w, x_p)) / (partial w_(i j)))
          / sqrt(sum_(k'=1)^K ((partial o^(k') (w, x_p)) / (partial w_(i j)))^2)
        )^2
    ).
  $

En el siguiente algoritmo, considere 
$
  E("net"(w), D_0) = sum_(p) E_p (w), qquad "donde" qquad E_p (w) = norm(y_p - o(w;x_p))^2.
$

#algot[FMS][
  Defina un criterio de parada (e.g. un número determinado de épocas, como 400.000). Luego, itere:

  -  Para cada ejemplo $(x_p, y_p) in D_0$:
    1. *Pasada forward:* se calcula $o(w; x_p)$.
    2. *Pasada backward:* se hace backpropagation normal, lo que permite obtener $
      nabla E_p qquad "y" qquad (partial o^k) / (partial w_(i j)) (w, x_p) qquad (forall k, w_(i j)).
    $
    3. *Gradiente de $B$.* Se necesitan las segundas derivadas de $o^k$, $ (partial B)/(partial w_(u v)) (w, x_p)  qquad "y" qquad (partial^2 o^k) / (partial w_(i j) partial w_(u v)) (w, x_p) $ y se construye $nabla B (w, x_p).$
    4. Se actualizan los pesos $ w <- w - alpha nabla E_p - lambda dot "escala" dot nabla B, $ donde el factor $"escala"$ fuerza que $nabla B$ y $nabla E_p$ tengan la misma norma.
  - Actualice $lambda$ según la regla de Weigend et al. (1991) (más grande si el error está bajo $E_"tol"$ o si bajó respecto a la época anterior y más pequeño si el error empeora). 
]

#nota[
  En el paper, a pesar de que pareciera necesitarse calcular la hessiana (segundas derivadas) de $o^k$, se usa el truco de Pearlmutter para sólo calcular un producto matriz-vector que reduce el costo computacional de $cal(O)(L^2)$ a $cal(O)(L)$.
]

=== Notas Adicionales
==== ¿Por qué los mínimos planos generalizan?
Cuando los pesos admiten poca precisión, se describen con pocos bits (esto es, bajo valor de $B$). Eso define una red "simple" y, por el principio MDL, un bajo overfitting esperado.

> (?) Desde la vista bayesiana, los mínimos planos son máximos "gordos" de la posterior.


==== Las dos condiciones de planitud
Se definen dos condiciones para la planitud y que definen la fórmula de $B$:

- *Condición 1 (robustez a las perturbaciones):* se define una medida $E D(w; tilde(w))$ que mide cupandi tambia la salida bajo perturbaciones dentro de la caja $M_w$. Se exige que esta perturbación sea como máximo $epsilon$.
- *Condición 2 (igual planitud en todas las direcciones):*  se busca que la planitud (el cambio de la salida ante perturbaciones) sea igual para todos los pesos.


==== Diferencia con Backpropagation


