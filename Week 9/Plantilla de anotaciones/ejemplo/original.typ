// "Paper" de juguete para probar el motor. Se compila a original.pdf.
#set page(paper: "us-letter", margin: (x: 1in, y: 1in), numbering: "1")
#set text(font: "New Computer Modern", size: 10.5pt)
#set par(justify: true)
#set math.equation(numbering: "(1)")

#align(center)[
  #text(size: 15pt, weight: "bold")[A Short Note on Energy Decay for the Heat Equation]
  #v(4pt)
  A. Author · _Journal of Toy Examples_ *1* (2026)
]
#v(10pt)

*Abstract.* We show that solutions of the heat equation on a bounded interval with homogeneous Dirichlet data lose energy exponentially fast. The proof only uses integration by parts and the Poincaré inequality.

= Setting

Let $u(x, t)$ solve
$ partial_t u = nu partial_x^2 u, quad 0 < x < L, quad u(0, t) = u(L, t) = 0, $ <heat>
with $nu > 0$. We define the energy
$ E(t) = 1/2 integral_0^L u(x, t)^2 dif x . $ <energy>

= The energy identity

Multiplying @heat by $u$ and integrating in $x$ gives
$ (dif E)/(dif t) = nu integral_0^L u thin partial_x^2 u dif x = - nu integral_0^L (partial_x u)^2 dif x, $ <identity>
where the boundary term $[u thin partial_x u]_0^L$ vanishes because of the Dirichlet data.

= Exponential decay

The Poincaré inequality $integral_0^L (partial_x u)^2 >= (pi slash L)^2 integral_0^L u^2$ turns @identity into $dif E slash dif t <= -2 nu (pi slash L)^2 E$, hence
$ E(t) <= E(0) exp(-2 nu pi^2 t slash L^2) . $ <decay>

#pagebreak()

#columns(2, gutter: 18pt)[
  = Remarks

  The rate in @decay is sharp: it is attained by $u = e^(-nu pi^2 t slash L^2) sin(pi x slash L)$, the first eigenfunction of $-partial_x^2$ with Dirichlet conditions.

  The same argument works in several dimensions, replacing $partial_x^2$ by the Laplacian and integrating by parts with the divergence theorem.

  #colbreak()

  = Nonlinear terms

  If one adds a transport term $w partial_x u$ with $partial_x w = 0$, the identity @identity is unchanged, because
  $ integral_0^L u thin w partial_x u dif x = w/2 [u^2]_0^L = 0 . $
  Transport moves energy around but does not create it.
]
