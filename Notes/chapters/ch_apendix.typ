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

FUT

== Relaciones entre Papers
#move(dy: 170pt)[
  #rotate(90deg)[
    #figure(caption: [Mapa de lecturas])[
      #image("../figures/mapa_papers.svg", width: 150%)
    ]
  ]
]
#pagebreak()
== Métodos para Entrenar una Red Neuronal
<metodos_para_entrenar_red_neuronal>
#move(dy: 80pt)[
  #rotate(90deg)[
    #figure(caption: [Mapa de lecturas])[
      #image("../figures/mapa_entrenamiento.svg", width: 150%)
    ]
  ]
]