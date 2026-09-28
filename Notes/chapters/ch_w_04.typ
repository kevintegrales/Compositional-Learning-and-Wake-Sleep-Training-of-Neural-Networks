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


== El Aporte de la Discretización

Aquí discutimos el avance que se realiza desde el LPN al NLI (de, prácticamente, los mismos autores). 

El LPN consistía en un encoder y en un decoder. Cuando un ejemplo nuevo $x_(n+1)$ se codificaba, luego se optimizaba por ascenso de gradiente el resultado para mejorarlo (esto dependía del parámetro $theta$ del decoder, por lo que era un proceso determinista una vez ya se había entrenado el $theta$).

La limitación del LPN era que tenía capacidades limitadas para la generalización composicional. En particular, al componer dos acciones, LPN falla parcialmente. Pero componer tres o más acciones, ya no se logran resultados complacientes. Ante este problema de la composicionalidad, los autores propusieron explorar representaciones latentes discretas para mejorar la generalización composicional, que es lo que justamente hacen en NLI.

En NLI se tiene un encoder que produce tokens discretos usando la Gumbel-Softmax (esto permite extraer muestras "discretas", pero poder seguir realizando _backpropagation_) a la cual se le bajando la temperatura $tau$ con el tiempo. Además, el decoder que usan es especial, pues va leyendo token a token y actualiza un *estado interno* $s_t$ a partir de ellos. Esto permite la *generalización de longitud*: no importa qué tan largo sea el programa, si se sabe interpretar los tokens, cualquier largo finito es ejecutable. 

#nota[NLI también usa ascenso de gradiente luego de que el encoder genere los tokens, sólo que en la Gumbel-Softmax.]

En los resultados, se muestra que efectivamente, tanto la discretización como la presencia del estado interno del intérprete permite muchos mejores resultados que LPN.


=== Hipótesis

La discretización en problemas donde se busca la composicionalidad pareciera ser una mejora natural, pues el pensamiento humano funciona esencialmente en "bloques", en el sentido de que razonamos secuencialmente y en base a conexiones (y muy importante, _composiciones_) entre _ideas_ aislada, algo que justamente se puede simbolizar en los computadores por medio de representaciones discretas. Por el contrario, los espacios latentes continuos son más difíciles de relacionar de esta manera con el pensamiento humano. 


// El cambio de un modelo a otro radica en la discretización del espacio latente.