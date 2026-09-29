// Funciones
#import "/math_functions.typ": *
#import "/notalmar.typ": *
#include "/notalmar.typ"


#let xx = $bold(x)$
#let yy = $bold(y)$
#let zz = $bold(z)$
#let neunet = $"NeuralNet"$
#let ttheta = $bold(theta)$
#let pphia = $bold(phia)$
#let elbo = $cal(L)_(ttheta, pphia)$
#let KL = $D_"KL" (q_pphia (zz|xx) || p_ttheta (zz|xx))$
#let eeps = $bold(epsilon.alt)$


== Neural Discrete Representation
#notat[Fuente][
  Contenido estudiado de _"Neural Discrete Representation Learning"_ de A. van den Oord et al. (2017).
  #fuente_link("https://arxiv.org/abs/1711.00937", "arXiv:1711.00937")
]


VQ-VAE es una familia de modelos que combina VAEs con cuantización de vectores (VQ) para obtener una representación latente discreta. 

El paper busca aprender representaciones discretas útiles. Menciona que, en teoría, el mejor modelo (respecto a la logverosimilitud) es aquel que no usa variables latentes, sin embargo, estos modelos tienden a aprender ruido y pierden poder de cómputo con ello.

=== VQ-VAE

En los VAEs se suele tener que la distribución posterior $q(z|x)$ y la prior $p(z)$ son normales, por lo que se realiza el truco de reparametrización gaussiano. En el caso de VQ-VAE, estos espacios tienen _distribuciones categóricas_.

==== Variables Latentes Discretas

Definiremos nuestro espacio latente. Suponga que tendrá $K in NN$ categorías o características importantes (estas irán creciendo con el entrenamiento). Para cada categoría $i in {1,...,K}$ definimos un *vector de _embedding_* $e_i in RR^D$. Con ellos se define el *espacio latente de _embedding_* $e in RR^(K times D)$:
$
  e = mat(|, ,|; e_1, dots.c, e_K; |, , |).
$

Seguidamente, describimos el pipeline general. Sea $x$ un input. El modelo tomará dicho input y lo pasará por medio del encoder, produciendo $z_e (x)$. Aquí, definimos la *distribución categórica posterior* $q(z|x)$ como
$
  q(z = k|x) = cases(
    1 qquad &"para" k = arg min_j norm(z_e (x) - e_j)_2,
    0 qquad &"e.o.c."
  )
$
Por tanto, para un $x$ particular, sólo existirá un $k in {1,...,K}$ tal que $q(z = k|x) = 1.$

A continuación, se le ingresa al decoder el vector de _embedding_ $e_k$ correspondiente:
$
  z_q (x) = e_k.
$ 

#nota[
- El modelo se puede pensar como VAE acotando $log p(x)$ con la ELBO.
- La distribución $q(z=k|x)$ es determinista (dados los vectores $e_i$ y el $x$).
- Definiendo una prior $p(z)$ uniforme, se obtiene la divergencia KL constante e igual a $log K$. 
]

#figure(
  caption: [A la izquierda, el pipeline de VQ-VAE. A la derecha, una representación del espacio de _embedding_]
)[
  #image("../images/vq_vae_pipeline.png", width: 100%)
]

==== Aprendizaje

Se define la *función total de pérdida*
$
  L = log p(x|z_q (x)) + norm("sg"[z_e (x)] - e)^2_2 + beta norm(z_e (x) - "sg"[e])^2_2.
$

Descomposición:
- $log p(x|z_q (x))$: es la *pérdida de reconstrucción*. Permite optimizar el encoder y el decoder. Los _embeddings_ $e_i$ no reciben información de aquí.
- $norm("sg"[z_e (x)] - e)^2_2$: es el uso de *Vector Quantization (VQ)*. Se usa un algoritmo de aprendizaje de diccionario que mueve los vectores $e_i$ hacia las salidas del encoder $z_e (x)$. La función $"sg"$ corresponde al *operador _stopgradient_*, que se define como una identidad en tiempo computacional hacia adelante (?) y tiene derivadas parciales nulas.
- $beta norm(z_e (x) - "sg"[e])^2_2$: es la *pérdida de compromiso*. Penaliza la creación ilimitada de vectores de _embedding_, esto es, regula el crecimiento de $K in NN$. 

Se ajustarán algunos pesos por medio de _backpropagation_. Sin embargo, para pasar del decoder al encoder no hay un gradiente real (por la operación $k = arg min (dots.c)$). Aproximaremos el gradiente simplemente copiando el gradiente del input del decoder, $z_q (x)$, a la salida del encoder, $z_e (x)$.

Además, el algoritmo parece ser robusto a valores de $beta in [0.1, 2.0]$.

La logverosimilitud del modelo completo se puede evaluar como
$
  log p(x) = log sum_k p(x|z_k) p(z_k)
$
y se puede aproximar como $log p(x|z_q (x)) p(z_k (x))$.

==== Prior y Distribuciones Autorregresivas

Diremos que una distribución es *autorregresiva* si la densidad en un punto/vector se puede representar como un producto condicionado a las variables/entradas anteriores. Esto es, para un $xx = (x_1,...,x_T),$ 
$ 
  p(xx) = product_(t=1)^T p(x_t|x_1,...,x_(t-1)). 
$ 
Ellas permiten generación de datos secuenciados. PixelCNN y WaveNet basan su funcionamiento en este tipo de distribuciones.

Por último, la prior $p(z)$ es una distribución categórica que se asume constante y uniforme durante el entrenamiento. Al terminar el entrenamiento se ajusta a una distribución autorregresiva sobre $z$, lo que permite generar $x$ por medio de sampleo ancestral. El *sampleo ancestral* (_ancestral sampling_) muestrea una variable condicionada a todas las anteriores. En nuestro contexto, 
$
  z_1 &~ p(z_1) \
  z_2 &~ p(z_2|z_1) \
  &space dots.v \
  z_T &~ p(z_T|z_1,...,z_(T-1)).
$
Así, se termina formando el vector $zz = (z_1,...,z_T)$. Por lo tanto,
$ 
  p(zz) = product_(t=1)^T p(z_t|z_1,...,z_(t-1)). 
$ 

=== Glosario
- *Embedding*: Transformación de un espacio categórico a uno continuo. Su función es aprender una representación de un espacio en otro. Pueden reducir, mantener o aumentar la dimensionalidad del espacio. La transformación se realiza mediante una matriz de pesos.
- *Codificación*: Similar al _embedding_, pero la transformación va de un espacio continuo a otro continuo.

#pagebreak()

== Categorical Reparametrization with Gumbel-Softmax
#notat[Fuente][
  Contenido estudiado de _"Categorical Reparameterization with Gumbel-Softmax"_ de E. Jang et al. (2016).
  #fuente_link("https://arxiv.org/abs/1611.01144", "arXiv:1611.01144")
]

El paper presenta un estimador de gradiente eficiente que reemplaza las muestras no diferenciables a partir de una nueva distribución Gumbel-Softmax, la cual puede ser _annealed_ en una distribución categórica.


=== La Distribución Gumbel-Softmax

La distribución Gumbel-Softmax es una distribución continua sobre un símplex que puede aproximar muestras de una distribución categórica. Un *símplex* de dimensión $k-1$, $Delta^(k-1)$, es un espacio (NO vectorial) que contiene vectores $k$-dimensionales con entradas no negativas y cuya suma es $1$, es decir,
$
  Delta^(k-1) := {(x_1,...,x_k) in RR^k : x_i >= 0 " y " sum_(i=1)^k x_i = 1}.
$

Note que cada elemento $x in Delta^(k-1)$ induce una distribución de probabilidad.

Sea $z$ una variable categórica con probabilidades de clase $pi_1,...,pi_k$ (es decir, $z$ tiene probabilidad $pi_i$ de pertenecer a la clase $i in [k]$). 

#nota[El paper asume que las muestras categóricas son vectores one-hot en $Delta^(k-1)$.]

Con esto, tenemos $z = e_i$, para algún $i in [k]$ y donde $e_i$ representa al $i$-ésimo vector canónico. Por lo tanto,
$
  EE_p [z] = sum_(j=1)^k e_j P(z = e_j) = sum_(j=1)^k e_j p(e_j) = sum_(j=1)^k e_j pi_j  =  [pi_1,...,pi_k].
$


El *Gumbel-Softmax trick* es un método para obtener muestras $z$ de una distribución con probabilidades de clase $pi$:
$
  z = "one_hot"(arg max_i [g_i + log pi_i]),
$
donde $g_1,...,g_k$ son muestras i.i.d. de una $"Gumbel"(0,1)$ (una muestra de esta $"Gumbel"(0,1)$ se obtiene generando una muestra $u ~ "Uniforme"(0,1)$ y luego aplicándole $-log(-log(u))$). 

Para solucionar la falta de diferenciabilidad del $arg max$ en el Gumbel-Softmax trick, usaremos la función softmax, que es continua y diferenciable. La *función softmax* $sigma:RR^k -> [0,1]^k$ sobre un vector $z = (z_1,...,z_k)$ se define como
$
  (sigma(z))_i = (e^(z_i)) / (sum_(J=1)^k e^(z_j)) qquad "para todo" i = 1,...,k.
$
#footnote[Una propiedad muy útil es que conserva el orden relativo $(<=)$ de las entradas, así que el máximo de $z$ se encuentra en la misma entrada que la misma entrada de $sigma(z)$.] Sabiendo esto, podremos generar vectores $y = (y_1,...,y_k) in RR^k$ tales que
$
  y_i = (exp((g_i + log pi_i) slash tau)) / (sum_(j=1)^k exp((g_j + log pi_j) slash tau)),
$
donde $tau in RR^+$ es un parámetro denominado *temperatura*. Para estos vectores $y$ (generados por este proceso de muestrear de una $"Gumbel"(0,1)$), podemos calcular la densidad, llamada *densidad de la distribución Gumbel-Softmax*,
$
  p_(pi, tau) (y_1,...,y_k) = Gamma(k) tau^(k-1) (sum_(i=1)^k pi_i slash y_i^tau)^(-k) product_(i=1)^k (pi_i slash y_i^(tau + 1)).
$

#nota[Esta distribución fue descubierta independientemente por Maddison _et al._ y a veces se le conoce como *Concrete Distribution*.]

Conforme $tau -> 0^+$, las muestras de la distribución se convierten en one-hot y la distribución se convierte en la distribución categórica $p(z)$.

==== El Estimador Gumbel-Softmax

La distribución Gumbel-Softmax es suave para $tau > 0$, por tanto, tiene un gradiente bien definido
$
  (partial y) / (partial pi),
$
con respecto a los parámetros $pi$. Por tanto, si reemplazamos muestras de la distribución categórica $p(z)$ por muestras de la Gumbel-Softmax $p_(pi, tau)$, podemos usar _backpropagation_. Este proceso de reemplazar muestras no diferenciables con una aproximación diferenciable como el *estimador Gumbel-Softmax*.

En el aprendizaje hay un _tradeoff_ entre valores de $tau$ pequeños, con muestras cercanas a muestras one-hot, pero valores de varianza grandes, contra muestras más suaves, pero con menor varianza. En la práctica se recomienda partir con alta temperatura e ir haciendo cada vez más pequeño el $tau > 0$ (pudiendo seguir una gran variedad de rutinas de actualización de su valor).

==== Estimador Gumbel-Softmax Straight-Through

Las relajaciones continuas de los vectores one-hot (i.e. de las muestras) pueden ser adecuados para ciertos problemas. Sin embargo, habrá situaciones donde esto no sea posible porque necesariamente se deberá muestrar de un espacio discreto (e.g. un espacio discreto de acciones en RL). En esos caso, se discretiza $y$ usando $arg max$ (esto es, se ocupa la definición que dimos de $z$ con el Gumbel-Softmax trick), pero se usa la aproximación continua en el _backward pass_, de modo que se aproxime el gradiente discreto por su relajación continua, 
$
  nabla_theta z approx nabla_theta y. 
$ Este procedimiento lo denominamos *Estimador Gumbel Straight-Through (ST)*. Este estimador permite que las muestras sean dispersas (con muchos ceros, ergo "cercanas" a ser one-hot) incluso con temperaturas $tau$ grandes. 

=== Resultados Experimentales

En los experimentos se prueban los dos estimadores: el Gumbel-Softmax estándar (que siempre aproxima el $arg max$ con la función softmax) y el ST Gumbel-Softmax (que sólo aproxima $arg max$ en el _backward pass_).

==== Modelos de Predicción de Salidas Estructuradas

En redes binarias estocásticas, ST Gumbel-Softmax obtiene resultados similares a otros estimadores en variables Bernoulli y los supera en variables categóricas. 

El estimador Gumbel-Softmax estándar supera al resto de estimadores tanto en variables Bernoulli como en variables categóricas.


==== Modelos Generativos (VAEs)

El estimador ST Gumbel-Softmax supera a otros estimadores en el uso de variables categóricas.  

El estimador Gumbel-Softmax supera a todos los demás estimadores tanto en variables de Bernoulli como en variables categóricas.


==== Clasificación Semisupervisada Generativa

El *aprendizaje semisupervisado* consiste en aprender de un conjunto que mezcla datos etiquetados como datos no etiquetados.

Para una sola muestra, Gumbel-Softmax mantiene un rendimiento generativo y de clasificación equivalente al método de marginalización. El *método de marginalización* consiste en calcular la probabilidad sobre todas las clases posibles de una variable categórica $y$, permitiendo entrenar también con datos no etiquetados, donde $y$ no fue observada.


#pagebreak()
== Posterior Collapse

Los VAEs son redes neuronales generativas que consisten en:
- Un *prior* $p_theta (zz)$.
- Un *encoder* $q_phia (zz|xx)$.
- Un *decoder* $p_theta (xx|zz)$.

En @vaes probamos que $EE(log p_ttheta (xx))$ se puede expresar como una suma de la ELBO y la divergencia KL. Esta esperanza indica qué tan bien se reconstruye un $xx$ es particular y la divergencia KL mide qué tan distintas son dos distribuciones, en particular, las distribuciones del prior y del encoder. Se ha propuesto muchas veces que el _posterior collapse_ surge por este último término.

=== Posterior Collapse as a Phase Transition in Variational Autoencoders
#notat[Fuente][
  Contenido estudiado de _"Posterior Collapse as a Phase Transition in Variational Autoencoders"_ de Z. Li et al. (2025).
  #fuente_link("https://arxiv.org/abs/2510.01621", "arXiv:2510.01621")
]

Aquí se estudia el _posterior collapse_ como un problema de física estadística, proponiendo que existe un punto crítico (una _transición de fase_) en los VAEs, debido a la estructura y al dataset utilizado, que marca el cambio a un _posterior collapse_. 

El *colapso posterior* (_posterior collapse_) ocurre cuando la posterior $q_phia (zz|xx)$ ignora un subconjunto del espacio latente. Es decir, para vectores $zz$ en un subconjunto $Z$, 
$
  q_phia (zz|xx) = p_theta (zz).
$

Se ha propuesto anteriormente que esto surge de la divergencia KL, por lo que se han propuesto ajustes como el $beta$-VAE, que pondera la divergencia KL en la maximización de la logverosimilitud. Sin embargo, otros enfoques analíticos (en especial los linealizados) han mostrado que PARTE (?) de las causas pueden venir de otros lados. Esto ha llevado a los autores a tomar un enfoque analítico, pero fuera del caso exclusivamente lineal.

El paper estudia la maximización del ELBO por medio de cálculo de variaciones (y multiplicadores de Lagrange) imponiendo ciertas restricciones sobre $p_theta (xx|zz)$ y $q_phia (zz|xx)$. Con esto, obtienen que los puntos óptimos son aquellos donde
$
  p_theta (xx|zz) = p(xx|zz) qquad "y" qquad q_phia (zz|xx) = p(zz|xx).
$
Es decir, donde el decoder y el encoder parametrizados son iguales a las distribuciones que aproximan.

Se hace énfasis en que hay múltiples valores extremos y que, un punto especial es el _posterior collapse_:
$
  p_theta (xx|zz) = p_"data" (xx) qquad "y" qquad q_phia (zz|xx) = p_"lat" (zz).
$
Aquí, ocurren dos colapsos:
- El encoder ignora a los vectores $xx$.
- La única solución del modelo es aprender la distribución marginal (el promedio) sobre el conjunto de entrenamiento, esto es, la distribución real de los datos, lo que fuerza a que la reconstrucción no tenga nada de información real respecto al dato original.

El paper a continuación le da una forma particular a $p_theta (xx|zz), q_phia (zz|xx)$ y a $p_"lat" (zz)$, haciéndolas normales. (Esto se conoce como *deep Gaussian VAEs*.) Resolviendo, se obtiene un punto extremo trivial,
$
  f_i (zz) &= E_(p_"data" (x)) [x_i]\
  mu_j (xx) &=0 \
  sigma_j (xx) &= 1,
$
que corresponde al colapso posterior. Luego, se obtiene el valor extremo
$
  cal(L)_"VAE"^(G*) = - N/2 ln 2 pi sigma´^2 - 1/(2 sigma'^2) "Tr"(bold(Sigma)),
$
donde $bold(Sigma)$ es matriz de covarianza de los datos $xx$ y $sigma'^2$ un hiperparámetro (la varianza de $p_theta (xx|zz)$).

En el paper se demuestra que el criterio
$
  sigma'^2 > max[xi_1^2, ..., xi_N^2],
$
donde los $xi_i^2$ son los valores propios de la matriz de covarianza de los datos, aproxima si ocurre o no el colapso posterior. Esto se puede interpretar como que, si los datos tienen demasiado ruido, el modelo termina decidiendo ignorarlos y simplemente reconstruir la distribución real.


==== Notas sobre Notación
// Este resumen de notación fue creado con Gemini 3.1 Pro

*Distribuciones Teóricas (Verdaderas)*

- $p_"data" (xx)$: La distribución marginal real de los datos. Describe la probabilidad de observar los datos en el mundo real y es matemáticamente intratable.


- $p(zz|xx)$: La distribución posterior verdadera. Describe los factores latentes $z$ que generaron un dato específico $x$. Es intratable y representa el punto óptimo analítico que el modelo intenta alcanzar (Eq. 7).


- $p(xx|zz)$: La distribución condicional verdadera de los datos. Describe cómo se generan los datos a partir de factores latentes exactos. Es el punto óptimo analítico exigido para lograr una reconstrucción perfecta (Eq. 6).



*Distribuciones Parametrizadas (El Modelo)*

- $q_phia (zz|xx)$: La distribución posterior aproximada, implementada mediante el *encoder*. Utiliza parámetros $phia$ (pesos de una red neuronal) para aproximarse a la intratable $p(zz|xx)$.


- $p_theta (xx|zz)$: La distribución de reconstrucción, implementada mediante el *decoder*. Utiliza parámetros $theta$ para generar o reconstruir datos $xx$ a partir de los latentes $zz$.



*Distribuciones Previas (Priors)*

- $p_"lat" (zz)$: La distribución a priori estática sobre las variables latentes. Establece la estructura matemática deseada del espacio latente antes de observar cualquier dato (típicamente Gaussiana estándar).


- $p_theta (zz)$: Una distribución a priori alternativa donde sus parámetros $theta$ se optimizan durante el entrenamiento del modelo (no utilizada en las formulaciones del documento analizado).



=== Posterior Collapse and Latent Variable Non-identifiability
#notat[Fuente][
  Contenido estudiado de _"Posterior Collapse and Latent Variable Non-identifiability"_ de Y. Wang et al. (2021).
  #fuente_link("https://arxiv.org/abs/2301.00537", "arXiv:2301.00537")
]

El paper demuestra que un VAE sufre de _posterior collapse_ si, y sólo si, la variable latente del modelo es no-identificable. Además, proponen un nuevo tipo de VAE, el _latent-identifiable VAE_, el cual resuelve el colapso posterior sin sacrificar fidelidad (información relevante) a los datos.

#deft[Colapso posterior][
  Dado un modelo de probabilidad $p(xx,zz; theta)$, un valor de parámetro $theta = hat(theta)$ y un dataset $xx = (x_1,...,x_n)$, la posterior de las variables latentes $zz$ *colapsa* si
  $
    p(zz|xx; hat(theta)) = p(zz).
  $
]

El colapso posterior no permite que la variable latente dé un resumen significativo del dataset.

#deft[Variable latente no-identificable][
  Dada una función de verosimilitud $p(xx|zz; theta)$, un valor de parámetro $theta = hat(theta)$ y un dataset $xx = (x_1,...,x_n)$, la variable latente $zz$ es *no-identificable* si
  $
    p(xx|zz = tilde(zz)'; hat(theta)) = p(xx|zz = tilde(zz); hat(theta)) qquad "para cualesquiera" tilde(z)', tilde(z) in cal(Z). 
  $
]

Como consecuencia de la no-identificabilidad, tenemos que 
$
  p(xx|zz = tilde(zz); hat(theta)) = p(xx; hat(theta)) qquad "para todo" tilde(z) in cal(Z).
$

Para asegurar que la variable latente será identificable, basta con asegurar que la verosimilitud $p(xx|zz, theta)$ es inyectiva en $zz$, para todo $theta$ y $xx$ fijo. 

#nota[La identificabilidad depende del dataset $xx$, por lo que una variable latente podría ser identificable en un modelo, pero no en otro.]

#teot[Caracterización del colapso posterior][
  Considere un modelo de probabilidad $p(xx, zz; theta)$, un dataset $xx$ y un valor de parámetro $theta = hat(theta)$. Luego, las variables latentes locales $zz$ son no-identificables en $hat(theta)$ si, y sólo si, la posterior de la variable latente $zz$ colapsa.
]

#proof[
  $(==>)$ Por regla de Bayes,
  $
    p(zz|xx; hat(theta)) proport p(zz) p(xx|zz; hat(theta)) = p(zz) p(xx|hat(theta)) proport p(zz),
  $
  donde la igualdad se obtiene de la no-identificabilidad.

  $(<==)$ El colapso implica, por Bayes,
  $
    p(zz) = p(zz|xx; hat(theta)) proport p(zz) p(xx|zz; hat(theta)),
  $
  por lo que $p(xx|zz; hat(theta))$ debe ser constante en $zz$ y, por tanto, hay no-identificabilidad. 
]

Es de notar que la naturaleza de la caracterización entregada puede ser aplicada a modelos más allá de las VAEs, por ejemplo, en el Probabilistic Principal Component Analysis (PPCA).

A continuación, el paper presenta algunos ejemplos de variables no-identificables y colapso posterior (lo omití por honor al tiempo).

Luego, se presenta el *latent-identifiable VAE (LIDVAE)* via Brenier maps, un modelo VAE que garantiza ser identificable y, por tanto, no colapsar. Aquí, se construyen verosimilitudes usando mapeos de Brenir y una aplicación matricial inyectiva, resultando en un mapeo inyectivo.

==== Resultados

Al aplicar el LIDVAE a texto e imágenes, se evita el posterior collapse


==== ¿Cómo se compara este paper con el anterior?

Los papers son distintos en objetivos:
- "Posterior Collapse as a Phase Transition in Variational Autoencoders" busca obtener un criterio para predecir el colapso posterior basándose en métodos de física estadística y, en particular, obtiene uno especial para el caso donde las distribuciones son normales.
- "Posterior Collapse and Latent Variable Non-identifiability" busca una caracterización del colapso posterior, probando una equivalencia con la no-identificabilidad. Además, muestra que esta caracterización es más general a sólo los VAEs y propone un modelo que evita la no-identificabilidad con mapeos de Brenier.


=== VQ-VAE y Posterior Collapse

El VQ-VAE se distingue en dos aspectos del VAE original:
1. Produce códigos discretos, no continuos (es decir, $zz$ es un vector continuo).
2. Aprende durante el entrenamiento.

Como recordatorio, el VQ-VAE parte desde un *codebook* de $K$ vectores aprendibles $e_1,...,e_K in RR^D$, toma un ejemplo $xx$ y el encoder produce un vector $z_e (xx)$ que se reemplazará por el vector más cercano del codebook, formando $z_q (xx)$ (así que la posterior $q_phia (zz|xx)$ es determinista). Finalmente, el $z_q (xx)$ se pasa al decodificador $p_theta (xx|zz)$.

La ventaja del VQ-VAE es que, al definir uniforme la distribución sobre los $zz$, la divergencia KL se hace constante (igual a $log K$) respecto a los parámetros $theta, phia$, por lo que *ya no se empuja* a $q_phia (zz|xx)$ al prior, lo que *evita el colapso posterior*. 
