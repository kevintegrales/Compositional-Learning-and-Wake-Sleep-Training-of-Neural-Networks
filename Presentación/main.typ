#import "template.typ": *
#import "math_functions.typ": *
#import "notalmar.typ": notalmarr, notalmarl
#import "config.typ" as cf

// Portada (los datos se leen de config.typ, igual que en Notes/main.typ)
#show: project.with(
  title: cf.your_title,
  subtitle: cf.your_subtitle,
  author: (name: cf.author_name, email: cf.author_email),
  course_code: cf.your_course_code,
  course_name: cf.your_course_name,
  course_semester: cf.your_course_semester,
  title_font: cf.your_title_font,
  body_font: cf.your_body_font,
  math_font: cf.your_math_font,
  principal_color: cf.your_principal_color,
  secondary_color: cf.your_secondary_color,
  painting: cf.your_painting,
)

== Contenidos
#v(40pt)
#outline(title: none, depth: 1)

// ===============================================
= Contenidos Preliminares
// ===============================================

== Reinforcement Learning
#fuente[_Reinforcement Learning: An Introduction_, R. S. Sutton y A. G. Barto, caps. 1 y 3.]

#columnas(proporcion: (1.15fr, 1fr))[
  - Aprendizaje *por interacción* guiado por retornos a largo plazo: un tercer paradigma junto al supervisado y al no supervisado.
  - Un *agente* actúa, el *ambiente* responde con una *recompensa* y un nuevo *estado*.
  - Componentes: *política* $pi_t (a|s)$, *señal de recompensa*, *función de valor* y (opcional) *modelo del ambiente*.
  - Tradeoff *explorar* vs. *explotar*.
][
  #figure(image("images/rl_relation.png", width: 100%))
]

== Procesos de Decisión de Markov Finitos

En cada instante $t$: estado $S_t in SSS$, acción $A_t in AAA(S_t)$, recompensa $R_(t+1) in RRR subset RR$.

Las *dinámicas del ambiente* quedan determinadas por
$
  p(s', r|s, a) = Pr{S_(t+1) = s', R_(t+1) = r | S_t = s, A_t = a}.
$

El agente busca maximizar el *retorno descontado* esperado, con $0 <= gamma <= 1$:
$
  G_t = sum_(k=0)^infinity gamma^k R_(t+k+1).
$

#nota[La frontera agente-ambiente es el límite de _control_ del agente, no de su conocimiento.]

== Complejidad de Kolmogorov
Sea $cal(U)$ una máquina de Turing universal fija.

#deft[Complejidad de Kolmogorov][
  Para $x, y in {0,1}^*$, $quad K(x|y) := min{|p|: cal(U)(p,y) = x}$ y $K(x) := K(x|epsilon)$.
]

#teot[Invarianza][
  Para máquinas universales $cal(U), cal(V)$ existe $c_(cal(U), cal(V)) >= 0$ tal que
  $abs(K_cal(U) (x) - K_cal(V) (x)) <= c_(cal(U), cal(V))$ para todo $x in {0,1}^*$.
]

#teo[La función $x |-> K(x)$ es no computable.]

== Minimum Description Length (MDL)

#deft[Minimum Description Length][
  Dada una clase de hipótesis $cal(H)$ y datos $D$, se escoge
  $
    h^* = arg min_(h in cal(H)) (L(h) + L(D|h)).
  $
]

Formaliza la *navaja de Occam*:
- Hipótesis muy simple: $L(h)$ pequeño, pero $L(D|h)$ grande.
- Hipótesis muy compleja: $L(h)$ grande, pero $L(D|h)$ pequeño (sobreajuste).

#nota[Este es el MDL "de dos partes"; el MDL "refinado" usa códigos universales.]

== Conceptos Bayesianos

$
  underbrace(p(zz|xx), "posterior") = (overbrace(p(xx|zz), "verosimilitud") space overbrace(p(zz), "prior")) / underbrace(p(xx), "evidencia")
  qquad qquad
  p(xx) = integral p(zz) p_theta (xx|zz) dif zz.
$

#columnas[
  *Máxima verosimilitud (EMV)*
  $ hat(zz)_"EMV" = arg max_zz log p(xx|zz) $
][
  *Máximo a posteriori (MAP)*
  $ hat(zz)_"MAP" = arg max_zz [log p(xx|zz) + log p(zz)] $
]

#notat[Posterior collapse][
  Si $xx$ no informa nada, $p(xx|zz) = p(xx)$ y la posterior coincide con la prior.
]

== Variational Autoencoders
#fuente(url: "https://arxiv.org/abs/1906.02691", texto: "arXiv:1906.02691")[_An Introduction to Variational Autoencoders_, D. P. Kingma y M. Welling (2019).]

- Queremos aproximar una distribución desconocida $p^*(xx)$ con un modelo $p_ttheta (xx) approx p^*(xx)$.
- *Modelo profundo de variable latente* (DLVM): $p_ttheta (xx, zz)$ parametrizado por una red neuronal,
  $
    p_ttheta (xx) = integral p_ttheta (xx|zz) p_ttheta (zz) dif zz.
  $
- *Problema:* esa integral es intratable, y por lo tanto también la posterior $p_ttheta (zz|xx)$.
- *Solución:* un *encoder* (inferencia variacional amortizada) $q_pphia (zz|xx) approx p_ttheta (zz|xx)$.

== ELBO

#eqn[ELBO][$ elbo (xx) := EE_(zz ~ q_pphia (zz|xx)) [log p_ttheta (xx, zz) - log q_pphia (zz|xx)] $]

Se cumple que
$
  log p_ttheta (xx) = elbo (xx) + KL >= elbo (xx).
$

La divergencia KL mide simultáneamente:
1. la distancia entre la posterior real $p_ttheta (zz|xx)$ y su aproximación $q_pphia (zz|xx)$;
2. el _gap_ entre $log p_ttheta (xx)$ y la ELBO.

Por eso se maximiza $elbo$ respecto a $ttheta$ y $pphia$ a la vez.

== Truco de Reparametrización

El gradiente respecto a $pphia$ no entra en la esperanza, pues $q_pphia$ depende de $pphia$. Escribimos
$
  zz = g(eeps, pphia, xx), qquad eeps ~ p(eeps) "independiente de" xx, pphia,
$
de modo que
$
  nabla_pphia EE_(zz ~ q_pphia (zz|xx)) [f(zz)] = EE_(eeps ~ p(eeps)) [nabla_pphia f(zz)] tilde.eq nabla_pphia f(zz).
$

#ex[
  $q_pphia (zz|xx) = "Normal"(zz; bold(mu), "diag"(bold(sigma)))$ con $(bold(mu), log bold(sigma)) = "EncoderNeuralNet"_pphia (xx)$ y $zz = bold(mu) + bold(sigma) dot.o eeps$, $eeps ~ "Normal"(0, I)$.
]

== Algoritmo AEVB

#algot[AEVB][
  *Data:* dataset $cal(D)$, modelo de inferencia $q_pphia (zz|xx)$, modelo generativo $p_ttheta (xx, zz)$.

  1. $(ttheta, pphia) <-$ inicializar parámetros.
  2. *while* SGD _no ha convergido_ *do*:
  3. |#qquad $cal(M) ~ cal(D)$ (minibatch) y $eeps ~ p(eeps)$ (ruido para cada punto de $cal(M)$).
  4. |#qquad Calcular $tilde(cal(L))_(ttheta, pphia) (cal(M), eeps)$ y sus gradientes $nabla_(ttheta, pphia) tilde(cal(L))_(ttheta, pphia)$.
  5. |#qquad Actualizar $ttheta, pphia$ con un optimizador SGD.
]

#columnas[
  *Generar:* $zz' ~ p_ttheta (zz)$, luego $xx ~ p_ttheta (xx|zz')$.
][
  *Reconstruir:* $zz' ~ q_pphia (zz|xx)$, luego $xx' ~ p_ttheta (xx|zz')$.
]

// ===============================================
= Representaciones Latentes
// ===============================================

== VQ-VAE
#fuente(url: "https://arxiv.org/abs/1711.00937", texto: "arXiv:1711.00937")[_Neural Discrete Representation Learning_, A. van den Oord et al. (2017).]

Combina VAEs con *cuantización vectorial* para obtener un espacio latente *discreto*: un codebook $e_1, ..., e_K in RR^D$ y una posterior categórica determinista
$
  q(z = k|x) = cases(
    1 qquad &"si" k = arg min_j norm(z_e (x) - e_j)_2,
    0 qquad &"e.o.c.",
  )
  qquad qquad z_q (x) = e_k.
$

#figure(image("images/vq_vae_pipeline.png", height: 46%))

== VQ-VAE: Aprendizaje

$
  L = underbrace(log p(x|z_q (x)), "reconstrucción") + underbrace(norm("sg"[z_e (x)] - e)^2_2, "VQ") + underbrace(beta norm(z_e (x) - "sg"[e])^2_2, "compromiso").
$

- $"sg"$ es el operador _stop-gradient_ (identidad hacia adelante, derivada nula).
- El $arg min$ no tiene gradiente: se *copia* el gradiente de $z_q (x)$ a $z_e (x)$.
- Robusto a $beta in [0.1, 2.0]$.
- Con prior uniforme, la KL es constante ($= log K$). Al final, la prior se ajusta a una distribución *autorregresiva* (PixelCNN, WaveNet):
  $
    p(zz) = product_(t=1)^T p(z_t|z_1, ..., z_(t-1)).
  $

== Gumbel-Softmax
#fuente(url: "https://arxiv.org/abs/1611.01144", texto: "arXiv:1611.01144")[_Categorical Reparameterization with Gumbel-Softmax_, E. Jang et al. (2016).]

*Gumbel-Max trick:* para muestrear $z$ con probabilidades de clase $pi$,
$
  z = "one_hot"(arg max_i [g_i + log pi_i]), qquad g_i ~ "Gumbel"(0, 1).
$

Se relaja el $arg max$ con un softmax de *temperatura* $tau > 0$:
$
  y_i = exp((g_i + log pi_i) slash tau) / (sum_(j=1)^k exp((g_j + log pi_j) slash tau)) in Delta^(k-1).
$

Si $tau -> 0^+$, las muestras se vuelven one-hot y se recupera la categórica.

== Estimadores Gumbel-Softmax

- *Gumbel-Softmax:* reemplaza las muestras categóricas por $y$, que es diferenciable respecto a $pi$, y permite _backpropagation_.
- *Tradeoff:* $tau$ pequeño da muestras casi one-hot pero gradientes de alta varianza. En la práctica se parte con $tau$ alto y se va reduciendo (_annealing_).
- *Straight-Through (ST):* usa $z = "one_hot"(arg max)$ en el _forward pass_ y la relajación en el _backward pass_:
  $
    nabla_theta z approx nabla_theta y.
  $
  Sirve cuando se *necesita* una muestra discreta (p. ej., acciones en RL).

#nota[En VAEs con variables categóricas, ambos estimadores superan a los demás estimadores comparados.]

== Posterior Collapse

El *colapso posterior* ocurre cuando el encoder ignora (parte de) el espacio latente:
$
  q_phia (zz|xx) = p_theta (zz).
$

Se ha atribuido históricamente al término KL de la ELBO (de ahí propuestas como el $beta$-VAE), pero la explicación es más fina.

#fuente(url: "https://arxiv.org/abs/2510.01621", texto: "arXiv:2510.01621")[_Posterior Collapse as a Phase Transition in VAEs_, Z. Li et al. (2025).]

En _deep Gaussian VAEs_ el colapso aparece como una *transición de fase*, aproximadamente cuando
$
  sigma'^2 > max[xi_1^2, ..., xi_N^2],
$
con $xi_i^2$ los valores propios de la covarianza de los datos: si hay demasiado ruido, el modelo ignora los datos.

== Colapso y No-Identificabilidad
#fuente(url: "https://arxiv.org/abs/2301.00537", texto: "arXiv:2301.00537")[_Posterior Collapse and Latent Variable Non-identifiability_, Y. Wang et al. (2021).]

#deft[Variable latente no-identificable][
  $zz$ es *no-identificable* en $hat(theta)$ si $p(xx|zz = tilde(zz)'; hat(theta)) = p(xx|zz = tilde(zz); hat(theta))$ para todo $tilde(zz)', tilde(zz) in cal(Z)$.
]

#teot[Caracterización del colapso posterior][
  Las variables latentes $zz$ son no-identificables en $hat(theta)$ si, y sólo si, la posterior de $zz$ colapsa: $p(zz|xx; hat(theta)) = p(zz)$.
]

== Colapso y No-Identificabilidad (cont.)

#proof[
  $(==>)$ Por Bayes y la no-identificabilidad,
  $
    p(zz|xx; hat(theta)) proport p(zz) p(xx|zz; hat(theta)) = p(zz) p(xx; hat(theta)) proport p(zz).
  $
  $(<==)$ Si colapsa, $p(zz) = p(zz|xx; hat(theta)) proport p(zz) p(xx|zz; hat(theta))$, así que $p(xx|zz; hat(theta))$ es constante en $zz$.
]

- La caracterización vale más allá de los VAEs (p. ej., PPCA).
- Proponen el *LIDVAE*, que usa mapeos de Brenier para tener una verosimilitud inyectiva en $zz$ y así no colapsar.

#notat[VQ-VAE y colapso][
  Con prior uniforme la KL es constante ($log K$): ya no se empuja $q_phia (zz|xx)$ hacia la prior, lo que *evita el colapso*.
]

// -----------------------------------------------
// Preguntas 2, 3 y 4 (posterior collapse)
// -----------------------------------------------

== Pregunta 2: Ejemplos de Posterior Collapse

#pregunta(2)[Ejemplos pequeños e intuición][
  Construye uno o más ejemplos *pequeños* (pocas dimensiones, calculables a mano) de modelos de variable latente en los que ocurra colapso posterior, y explica *intuitivamente* por qué ocurre en cada uno.
]

#guia[
  - ¿Qué pasa si el decoder $p_theta (xx|zz)$ es tan expresivo que puede modelar $xx$ sin mirar $zz$?
  - ¿Qué pasa si los datos tienen mucho ruido respecto a su estructura? (Criterio $sigma'^2 > max xi_i^2$.)
  - Usando la caracterización de Wang et al.: ¿qué modelo concreto hace que $p(xx|zz; hat(theta))$ *no dependa* de $zz$?
  - Para cada ejemplo, ¿qué partes del latente colapsan: todo $zz$ o sólo algunas coordenadas?
]

== Pregunta 2: Propuesta de Respuesta
#respuesta()[]

== Pregunta 3: VQ-VAE y Posterior Collapse

#pregunta(3)[Casos donde falla VQ-VAE][
  Se dice que VQ-VAE *evita* el colapso posterior. ¿En qué casos un VQ-VAE igualmente termina ignorando (todo o parte de) su espacio latente?
]

#guia[
  - ¿Qué ocurre si sólo unos pocos vectores $e_k$ del codebook se usan y el resto nunca se activa (_codebook collapse_ o códigos muertos)?
  - ¿Qué ocurre si el decoder es autorregresivo y muy potente (PixelCNN, WaveNet)?
  - ¿Qué rol juegan $beta$ y la inicialización del codebook?
  - ¿Es ese fenómeno *lo mismo* que el colapso posterior según la definición $q(zz|xx) = p(zz)$? ¿O es otro tipo de colapso?
]

== Pregunta 3: Propuesta de Respuesta
#respuesta()

== Pregunta 4: ¿Por qué Deja de Importar la KL?

#pregunta(4)[Fórmula y teoría][
  + Muestra con una *fórmula* por qué, en VQ-VAE, la divergencia KL deja de influir en el entrenamiento.
  + Explica *teóricamente y a fondo* (no sólo conceptualmente) por qué ocurre, y por qué en un VAE gaussiano la KL sí empuja hacia el colapso.
]

#guia[
  - Calcula $D_"KL" (q(z|x) || p(z))$ con $q(z|x)$ one-hot y $p(z)$ uniforme sobre $K$ clases. ¿De qué parámetros depende? ¿Cuál es su gradiente?
  - En un VAE gaussiano, ¿cuál es el mínimo de $D_"KL" (q_phia (zz|xx) || p(zz))$ y cuándo se alcanza? ¿Qué le "cuesta" al modelo usar $zz$?
  - Punto de partida sugerido: promediando sobre los datos, $EE_xx [D_"KL" (q(zz|xx) || p(zz))]$ se descompone en una *información mutua* $I_q (xx; zz)$ más una KL entre la posterior agregada $q(zz)$ y la prior. Demuéstralo e interprétalo.
  - Si la KL es constante, ¿cuánta información sobre $xx$ puede transportar $zz$ como máximo?
]

== Pregunta 4: Propuesta de Respuesta
#respuesta()

// ===============================================
= Síntesis de Programas
// ===============================================

== DreamCoder
#fuente(url: "https://arxiv.org/abs/2006.08381", texto: "arXiv:2006.08381")[_DreamCoder: Bootstrapping Inductive Program Synthesis with Wake-Sleep Library Learning_, K. Ellis et al. (2021).]

Dado un conjunto de tareas $cal(X)$ (pares input-output), busca programas ${rho.alt_x}$ que las resuelvan, *construyendo su propio DSL* (librería $L$). Retos: explosión combinatorial, generalización e interpretabilidad.

#def[
  El *joint description length* de una librería $L$ y programas ${rho.alt_x}$ es
  $
    "DL"(L, {rho.alt}, cal(X)) := abs(L) + sum_(x in cal(X)) abs(rho.alt_x)_L.
  $
]

El objetivo es el del MDL, pero es intratable: se introduce un *modelo de reconocimiento* $Q_theta (rho.alt|x)$ que guía la búsqueda.

== DreamCoder: Ciclo Wake-Sleep

#table(
  columns: (auto, auto, 1fr),
  align: (left, center, left),
  table.header([*Fase*], [*Actualiza*], [*Qué hace*]),
  [*Wake*], [${rho.alt_x}$], [Busca, para cada tarea, el programa que maximiza $log Q_theta (rho.alt|x) + log P(rho.alt|L)$.],
  [*Sleep: abstracción*], [$L$], [$L^* = arg max_L [log P(L) + sum_x log P(rho.alt_x^*|L)]$: comprime los programas en nuevas funciones.],
  [*Sleep: sueños*], [$theta$], [Entrena $Q_theta$ con *replays* $(x, rho.alt_x^*)$ y *fantasías* $(x, rho.alt)$ con $rho.alt ~ P(rho.alt|L)$.],
)

#notat[Conexión con DreamerV3][
  Las fantasías cumplen un rol parecido al modelo de mundo de DreamerV3: permiten ensayar con datos que no vienen de la fuente original.
]

== Searching Latent Program Spaces (LPN)
#fuente(url: "https://arxiv.org/abs/2411.08706", texto: "arXiv:2411.08706")[_Searching Latent Program Spaces_, M. V. Macfarlane et al. (2024).]

Toma lo mejor de los dos enfoques para resolver ARC-AGI:
- *Inductivo* (síntesis simbólica): programa explícito y búsqueda en test-time, pero necesita un DSL hecho a mano.
- *Transductivo* (aprendizaje profundo): escalable, pero con pesos fijos tras entrenar y propenso al sobreajuste.

La *Latent Program Network* representa programas en un *espacio latente continuo* y hace la búsqueda en test-time *ahí*, no en los parámetros de la red.

$
  underbrace(z ~ q_phia (z|x, y), "Encoder") qquad --> qquad underbrace(z' = f(p_theta, z, x, y), "Optimización latente") qquad --> qquad underbrace(hat(y) ~ p_theta (y|x, z'), "Decoder")
$

== LPN: Optimización en el Espacio Latente

Se busca el programa latente que mejor explica los ejemplos bajo el decoder actual:
$
  z' in arg max_z sum_(i=1)^n log p_theta (y_i|x_i, z).
$

- *Muestreo:* se toman $K$ latentes y se escoge el de mayor log-verosimilitud. Escala mal con la dimensión.
- *Ascenso de gradiente:* se parte del promedio de los latentes del encoder,
  $
    z'_k = z'_(k-1) + alpha dot nabla_z lr(sum_(i=1)^n log p_theta (y_i|x_i, z)|)_(z = z'_(k-1)).
  $

#notat[Sistema 1 y Sistema 2][
  El encoder da una intuición rápida (Sistema 1) y la optimización latente la refina deliberadamente (Sistema 2). Ninguno basta por sí solo.
]

== LPN: Entrenamiento

Estrategia *leave-one-out*: para reconstruir $y_i$ se codifican y promedian los pares $j != i$, se optimiza el latente y se evalúa en $(x_i, y_i)$.
$
  cal(L)_"total" (phia, theta) = underbrace(sum_(i=1)^n - log p_theta (y_i|x_i, z'_i), cal(L)_"rec") + beta underbrace(sum_(i=1)^n D_"KL" (q_phia (z|x_i, y_i) || "Normal"(0, I)), cal(L)_"KL").
$

- $cal(L)_"rec"$ mide qué tan mal predice el decoder; $cal(L)_"KL"$ mantiene suave el espacio latente.
- Se usa el truco de reparametrización $z = mu + epsilon.alt dot Sigma$.
- En test-time, $phia$ y $theta$ quedan fijos: sólo se mueve $z$.

== LPN: Resultados en la Tarea Pattern

#figure(
  table(
    columns: 7,
    align: center,
    table.header([*Entrenamiento*], [*Grad 0*], [*Grad 1*], [*Grad 5*], [*Grad 20*], [*Grad 100*], [*Sample 250*]),
    [Grad 0], [3.2], [3.6], [18.8], [52.5], [67.5], [3.2],
    [Grad 1], [8.6], [44.6], [85.4], [98.4], [*99.5*], [10.2],
    [Grad 1 $star.op star.op$], [0.6], [13.7], [60.2], [88.9], [94.1], [0.7],
    [Grad 5], [0.0], [0.4], [31.9], [88.5], [98.1], [0.5],
    [Sample 5], [6.1], [8.2], [27.7], [56.3], [72.2], [6.1],
  ),
  caption: [Accuracy (%). Filas: entrenamiento. Columnas: inferencia.],
)

#columnas(proporcion: (0.8fr, 1fr))[
  1. Sin búsqueda en inferencia, todo falla.
  2. Más búsqueda $=>$ mejor desempeño.
][
  3. Entrenar sabiendo que habrá búsqueda importa.
  4. El gradiente supera ampliamente al muestreo.
]

== LPN: Generalización y Limitaciones

#columnas(proporcion: (1fr, 1.2fr))[
  #figure(
    table(
      columns: 4,
      align: center,
      table.header([], [*Grad 0*], [*Grad 10*], [*Grad 100*]),
      [In-Context], [0.0], [—], [—],
      [TTT], [0.0], [1.8], [0.3],
      [LPN Grad 0], [0.3], [18.8], [41.1],
      [LPN Grad 1], [0.0], [59.9], [*88.0*],
    ),
    caption: [Accuracy (%) en Pattern fuertemente OOD.],
  )
][
  - *La búsqueda en test-time permite adaptarse a tareas nuevas.*
  - *Composición limitada:* compone dos operaciones vistas por separado, pero falla con tres. Cada programa es un *único vector* $z$, sin "partes" reutilizables.
  - Depende del cómputo en inferencia.
  - Lejos del estado del arte en ARC.
]

== Neural Language Interpreter (NLI)
#fuente(url: "https://arxiv.org/abs/2604.18907", texto: "arXiv:2604.18907")[_Gradient-Based Program Synthesis with Neurally Interpreted Languages_, M. V. Macfarlane et al. (2026).]

- *Latent Adaptation Networks (LANs):* encoder-decoder que aprende un espacio latente de programas y busca en él en test-time. LPN y NLI son LANs.
- NLI aprende de los pares input-output su *propio lenguaje discreto*, un *codebook* de $K$ tokens "simbólicos" (no definidos por humanos): una especie de DSL aprendido.
- Un programa es una *secuencia de tokens* de largo variable, en vez de un único vector:
  - el *inductor de programa* $q_phia$ (encoder) infiere el programa desde los pares;
  - el *intérprete neuronal* $p_theta$ (decoder) lo ejecuta token a token sobre un input.
- El intérprete es *diferenciable*: eso permite buscar programas con ascenso de gradiente.
- Puede resolver problemas que requieren *más tokens* de los vistos en entrenamiento.

== NLI: El Inductor $q_phia$

#columnas(proporcion: (1.5fr, 1fr))[
  El inductor mapea cada par $(x, y)$ a una secuencia de distribuciones sobre el codebook:
  $
    z = (z_1, ..., z_T) in (Delta^(K-1))^T,
  $
  $
    Delta^(K-1) := {x in RR^K : x_i >= 0, sum_(i=1)^K x_i = 1}.
  $
  Se promedian por posición los embeddings de los pares, $macron(e)_t = 1/abs(S) sum_i e_t^((i))$, y se muestrea con Gumbel-Softmax:
  $
    z_t = "Softmax"((f_phia (macron(e)_t) + g_t) slash tau_e), qquad g_t ~ "Gumbel"(0, 1),
  $
  con la temperatura $tau_e$ bajando durante el entrenamiento (_annealing_).
][
  #figure(image("images/simplex.svg", width: 80%), caption: [El símplex $Delta^2$.])
  #nota[Un *skip token* permite programas de largo variable aun con $T$ fijo.]
]

== NLI: El Intérprete $p_theta$

El intérprete aprende dos *embedding matrices* y una red de ejecución $d$:
- *Code embedder* $E_v$: su fila $k$ es el vector del token $k$; $E_v^T z_t$ "busca en el codebook" la instrucción del paso $t$.
- *Input-output embedder* $E_"io"$: su fila $k$ representa el valor $k$ que puede tomar una celda de los datos.

Parte de $s_0 = "Embed"(x)$, $pi_0 = "OneHot"(x)$ y en cada paso $t = 1, ..., T$:
$
  n_t = d(s_(t-1), E_v^T z_t), qquad tilde(pi)_t = "Softmax"((n_t + h_t) slash tau_d), qquad h_t ~ "Gumbel"(0, 1),
$
$
  pi_t = z_(t,"skip") dot pi_(t-1) + (1 - z_(t,"skip")) dot tilde(pi)_t, qquad s_t = E_"io"^T pi_t.
$
La predicción es $pi_T$: el *estado interno* $s_t$ se actualiza instrucción a instrucción.

== NLI: Entrenamiento

Leave-one-out sobre batches de $B$ especificaciones con $m$ pares, donde $SSS_(b,i) := SSS_b without {(x_(b,i), y_(b,i))}$:
$
  cal(L)(phia, theta; SSS) = 1/B sum_(b=1)^B (1/m sum_(i=1)^m cal(L)_"recon" (phia, theta; x_(b,i), y_(b,i), SSS_(b,i)) + lambda_"reg" dot cal(L)_"reg" (phia; SSS_b)).
$

- *Reconstrucción:* $cal(L)_"recon" (phia, theta; x, y, S) := -log p_theta (y|x, q_phia (S))$ asegura que el lenguaje sea expresivo.
- *Regularización:* premia *reutilizar tokens* (¡composicionalidad!):
  $
    cal(L)_"reg" (phia; SSS) := sum_(k=1)^K sum_(j=1)^T [1 - product_(b=1)^B product_(i=1)^m (1 - q_phia^((k,j)) (SSS_(b,i)))],
  $
  el número esperado de tokens distintos usados en el batch.
- *Annealing:* $tau_e: 8 -> 0.5$ y $tau_d: 2 -> 0.5$. A diferencia de LPN, *no* hay bucle interno de búsqueda al entrenar.

== NLI: Búsqueda en Test-Time

Se optimizan los *embeddings continuos* $e$ del inductor, no los tokens directamente:
$
  e^* = arg max_e EE_(g, h) [sum_((x_j, y_j) in S) log p_theta (y_j|x_j, z(e, tau_e, g), tau_d, h)].
$

- Se inicializan $s$ puntos de partida $~ cal(N)(macron(e), sigma_s)$ y se hacen $L$ pasos de ascenso de gradiente *en paralelo*.
- Las temperaturas $tau_e, tau_d$ parten *altas* (explorar) y bajan (_annealing_) hasta converger a *programas discretos*.
- Finalmente, el intérprete ejecuta el programa optimizado sobre $x_(n+1)$.

#notat[Comparación con LPN][
  LPN busca en un vector continuo $z$; NLI busca en un espacio continuo *relajado* que, al bajar la temperatura, termina en una secuencia de tokens.
]

== LPN vs NLI: Entrenamiento, Test-Time y Producción
#align(center, image("images/fases_nli_lpn.svg", height: 295pt))

== El Aporte de la Discretización

#columnas[
  *LPN*
  - Programa = un vector continuo $z$.
  - Ascenso de gradiente en $z$.
  - Compone 2 operaciones; falla con 3.
][
  *NLI*
  - Programa = secuencia de tokens (Gumbel-Softmax con $tau$ decreciente).
  - Ascenso de gradiente sobre los embeddings $e$, con annealing de $tau_e, tau_d$.
  - El intérprete actualiza un *estado interno* $s_t$ token a token: *generalización de longitud*.
]

#rel[Hipótesis][
  El pensamiento humano funciona en "bloques": razonamos secuencialmente componiendo _ideas_ aisladas, algo que las representaciones discretas simbolizan mejor que los espacios latentes continuos.
]

== Pregunta 6: ¿NLI en un Espacio Continuo?

#pregunta(6)[NLI continuo y composicional][
  ¿Por qué NLI *no* podría adaptarse a un espacio latente continuo manteniendo la composicionalidad?
]

#guia[
  - ¿Qué piezas de NLI dependen de que los tokens sean discretos: $cal(L)_"reg"$, el intérprete que lee token a token, el largo variable?
  - ¿Qué significaría "reutilizar un token" si los tokens fueran vectores continuos? ¿Seguiría teniendo sentido $cal(L)_"reg"$?
  - Una *secuencia* de vectores continuos (sin cuantizar): ¿qué impide que dos "tokens" cercanos se mezclen o signifiquen cosas distintas?
  - ¿La pregunta es "no se podría" o "sería más difícil"? Compáralo con LPN, que es justamente el caso continuo.
]

== Pregunta 6: Propuesta de Respuesta
#respuesta()

// ===============================================
= Algoritmos para Redes Neuronales
// ===============================================

== Flat Minima
#fuente(url: "https://doi.org/10.1162/neco.1997.9.1.1", texto: "DOI:10.1162/neco.1997.9.1.1")[_Flat Minima_, S. Hochreiter y J. Schmidhuber (1997).]

Para una red $"net"(w): x |-> o(w; x)$ con pesos $w in RR^L$:
- $w$ es un *mínimo aceptable* si $E("net"(w), D_0) = sum_p norm(y_p - o(w; x_p))^2 <= E_"tol"$.
- Un *mínimo plano* es una región conexa de mínimos aceptables.
- Se busca un mínimo aceptable cuya *caja* $M_w$ (hipercuboide centrado en $w$) tenga gran volumen.

*Flat Minimum Search (FMS)* minimiza
$
  E(w, D_0) := E("net"(w), D_0) + lambda B(w, X_0),
$
donde minimizar $B$ maximiza el volumen de la caja.

== FMS: ¿Por qué Generalizan los Mínimos Planos?

#algot[FMS (un paso por ejemplo $(x_p, y_p)$)][
  1. *Forward:* calcular $o(w; x_p)$.
  2. *Backward:* obtener $nabla E_p$ y $partial o^k slash partial w_(i j)$.
  3. Calcular $nabla B$ (con el operador $cal(R)$ de Pearlmutter: costo $cal(O)(L)$).
  4. $w <- w - alpha nabla E_p - lambda dot "escala" dot nabla B$.
]

#notat[MDL][
  En una caja el error se mantiene acotado, así que los pesos necesitan poca precisión: pocos bits. Un error bajo corresponde a $L(D|h)$ y un $B$ bajo a $L(h)$.
]

#nota[El backprop convencional prefiere las direcciones más empinadas; con batches pequeños, el ruido del SGD favorece implícitamente mínimos planos (Keskar et al., 2017). FMS lo hace explícito.]

// ===============================================
= Misceláneos
// ===============================================

== DreamerV3
#fuente(url: "https://arxiv.org/abs/2301.04104", texto: "arXiv:2301.04104")[_Mastering Diverse Domains through World Models_, D. Hafner et al. (2023).]

Algoritmo de RL que aprende un *modelo de mundo* y deja que el agente *imagine* el futuro. Tres redes entrenadas a la vez:

#columnas(proporcion: (1.1fr, 1fr))[
  *Modelo de mundo (RSSM)*
  - Memoria: $h_t = f_phia (h_(t-1), z_(t-1), a_(t-1))$.
  - Encoder: $z_t ~ q_phia (z_t|h_t, x_t)$.
  - Predictor: $hat(z)_t ~ p_phia (hat(z)_t|h_t)$.
  - Estado: $s_t = {h_t, z_t}$, desde el que se predicen $r_t$, $c_t$ y se reconstruye $x_t$.
][
  *Actor y crítico* (sólo sobre $s_t$)
  $
    a_t ~ pi_theta (a_t|s_t), qquad v_psi (R_t|s_t).
  $
  El crítico aprende los _$lambda$-returns_
  $
    R^lambda_t = r_t + gamma c_t ((1 - lambda) v_t + lambda R^lambda_(t+1)).
  $
]

== DreamerV3: Ciclo de Aprendizaje

1. *Actuar:* el actor juega en el ambiente real y guarda las trayectorias en el _replay buffer_.
2. *Entrenar*, en cada paso de gradiente:
  - tomar un batch de trayectorias reales y actualizar el modelo de mundo;
  - *imaginar* trayectorias desde esos estados latentes con el modelo y el actor actuales;
  - actualizar actor y crítico con las trayectorias imaginadas.
3. *Iterar.*

Los retornos se normalizan con $S = "EMA"("Per"(R^lambda_t, 95) - "Per"(R^lambda_t, 5), 0.99)$, así la exploración no depende de la escala de las recompensas.

#rel[Resultado][
  Primer algoritmo en conseguir diamantes en Minecraft sin datos humanos, con hiperparámetros fijos entre dominios. Más parámetros $=>$ mejor rendimiento y menos datos.
]

== Pregunta 1: DreamerV3 y Latentes Discretos

#pregunta(1)[¿Por qué mejora con latentes discretos?][
  En el modelo de mundo de DreamerV3 (heredado de DreamerV2), las representaciones $z_t$ son *discretas*: vectores de variables categóricas entrenadas con gradientes _straight-through_. ¿Qué es lo que hace que un modelo de mundo con latentes discretos funcione mejor que uno con latentes gaussianos continuos?
]

#guia[
  - Verifica en el paper cómo es exactamente $z_t$ (número de categóricas y de clases) y cómo se le pasan gradientes.
  - ¿Qué ventaja tiene una categórica para representar transiciones *multimodales* o saltos bruscos del ambiente?
  - ¿Cómo afecta al predictor $p_phia (hat(z)_t|h_t)$, que debe "adivinar" $z_t$ sin ver $x_t$?
  - ¿Se conecta con lo que vimos de Gumbel-Softmax, VQ-VAE y NLI?
]

== Pregunta 1: Propuesta de Respuesta
#respuesta()

// ===============================================
= Síntesis: Aprendizaje Composicional
// ===============================================

== Pregunta 5: Comparación de los Modelos

#pregunta(5)[Ventajas, fenómenos y principios][
  Para los modelos de wake-sleep (DreamCoder, DreamerV3) y para LPN y NLI, anota:
  + sus *ventajas*;
  + los *fenómenos a tener en cuenta*: el posterior collapse y su rol, y el rol de pasar a representaciones discretas;
  + los *principios más importantes* que comparten (3 o 4 interesantes).
]

#guia[
  - ¿Dónde hay un espacio latente o una distribución posterior en cada modelo? ¿Podría colapsar?
  - ¿Qué es "discreto" en cada uno? (Programas simbólicos, latentes categóricos, tokens, un vector continuo.)
  - Posibles ejes para los principios: compresión/MDL, búsqueda en test-time, datos "soñados", reutilización.
]

== Pregunta 5: Ventajas y Fenómenos

#table(
  columns: (auto, 1fr, 1fr, 1fr),
  rows: (auto, 62pt, 62pt, 62pt, 62pt),
  align: (left + horizon, left, left, left),
  table.header([*Modelo*], [*Ventajas*], [*Posterior collapse*], [*Rol de lo discreto*]),
  [*DreamCoder*], [], [], [],
  [*DreamerV3*], [], [], [],
  [*LPN*], [], [], [],
  [*NLI*], [], [], [],
)

== Pregunta 5: Principios Más Importantes

#respuesta[
  + *Principio 1:*
  + *Principio 2:*
  + *Principio 3:*
  + *Principio 4:*
]

// ===============================================
= Apéndice
// ===============================================

== Relaciones entre Papers
#align(center + horizon, image("images/mapa_papers.svg", width: 100%))

== Métodos para Entrenar una Red Neuronal
#align(center + horizon, image("images/mapa_entrenamiento.svg", height: 90%))
