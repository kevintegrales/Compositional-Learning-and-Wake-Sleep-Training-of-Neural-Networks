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


== An Introduction to Variational Autoencoders
<vaes>

El siguiente contenido está basado en el documento "_An Introduction to Variational Autoencoders_" de Diederik P. Kingma y Max Welling (2019).

=== Introducción
Los Variational Autoencoders (VAE) entregan un framework para aprender modelos profundos de variables latentes y los modelos de inferencia correspondientes.

Suponga que queremos modelar la distribución conjunta de unas variables observadas. Sea $xx$ un vector de estas variables. De hecho, asumiremos que $xx$ es una muestra de un _proceso desconocido y subyacente_, con distribución real $p^* (xx)$ desconocida. Así, lo que buscamos es aproximar esta $p^*$. 

Para aproximar $p^*$, partimos de un modelo $p_ttheta$, cuyos parámetros en $ttheta$ ajustaremos de modo que
$
  p_ttheta (xx) approx p^*(xx).
$

De esta manera, tendremos un modelo generativo tal que
$
  xx ~ p_ttheta (xx).
$


==== Modelos Condicionales

A veces tendremos conocimiento sobre la distribución de los datos, lo que prodremos incluir con una distribución _a priori_. Los modelos que involucren este tipo de conocimiento se conocen como *Modelos Condicionales*. Asuma que queremos aproximar una distribución sobre los valores de una variable $yy$, dados unos datos $xx$ (observados, el *input*). Es decir, queremos aproximar $p^* (yy|xx)$ ajustando $p_ttheta (yy|xx)$.

#ex[Un ejemplo clásico es la clasificación de imágenes. Una imagen se toma como input, $xx$, y su clase se piensa como valor de $yy$.]


==== Redes Neuronales

Asumiremos que las *redes neuronales* son redes feed-forward diferenciables. Dos características de ellas son que:
#enum(numbering: "(1)")[
  Permiten _aproximar funciones_, en particular, densidades.
][
  Son _escalables_ a grandes modelos y grandes datasets, pues admiten optimización con SGD.
]

Cuando estas redes neuronales tienen muchas capas ocultas, decimos que estamos ante un problema de *deep learning*.  Denotaremos estas redes como la función vectorial (e.g. un vector de probabilidades de cada clase)
$
  neunet(dot).
$

#ex[
  La clasificación de imágenes con redes neuronales (LeCun _et al._, 2016) se ha realizado parametrizando una distribución categórica $p_ttheta (y|xx)$ sobre una clase de etiquetas $y$, condicionado a una imagen $xx$. (Los pesos de la red neuronal corresponden a $ttheta$.) Se define
  $
    bold(p) = neunet(xx),
  $
  esto es, la salida que produce la red neuronal que, en este caso, corresponde a un vector de probabilidades de clases (ergo $sum_i p_i = 1$ y $p_i >= 0$). Luego, se piensa
  $
    p_ttheta (y|xx) = "Categorical"(y; bold(p)),
  $
  donde $"Categorical"$ es una distribución categórica parametrizada por $bold(p)$. 
]


==== Modelos Gráficos Dirigidos

Los *modelos probabilísticos dirigidos*, *modelos gráficos probabilísticos* o *redes bayesianas* son modelos donde todas las variables están organizadas en un digrafo acíclico:
- Los nodos representan a las variables.
- Las aristas representan relaciones de independencia.

Denotaremos con $"Pa"(xx_j)$ los padres de la variable $xx_j$). Aquí, la distribución sobre las variables resulta en
$
  p_ttheta (xx_1,...,xx_M) = product_(j=1)^M p_ttheta (xx_j|"Pa"(xx_j)).
$
#nota[
  Si $xx_j$ no tiene padres, i.e. es una raíz, $"Pa"(xx_j) = emptyset$, pero la distribución se piensa incondicional simplemente.
]


==== Dataset y Verosimilitud
Nuestro *dataset* es
$
  cal(D) &= {xx^((i))}_(i=1)^N =: xx^((1:N)). \
$

Dado un datates $cal(D)$, denotamos con $N_cal(D)$ su tamaño. Muchas veces asumimos las observaciones $xx^((i))$ i.i.d. Así, podemos calcular la probabilidad (densidad) de los datos según el modelo. En particular, podemos obtener la log-probabilidad asociada
$
  log p_ttheta (cal(D)) = sum_(i=1)^N log p_ttheta (xx^((i))).
$
El criterio más común para los modelos es el de la *Máxima Verosimilitud (ML)*, esto es, encontrar el $ttheta$ que maximiza la verosimilitud (o la log-verosimilitud). (Que es equivalente a la minimización de la divergencia de Kullback-Leibler). Para ello, se usa *Stochastic Gradient Descent (SGD)*#footnote[Podríamos usar *Batch Gradient Descent* considerando al maximizar siempre todo $cal(D)$, pero el costo sería muy alto para datasets grandes (lineal).] que usa minibatches $cal(M) subset cal(D)$ y define el estimador
$
  1 / (N_cal(M)) log p_ttheta (cal(M)) tilde.eq 1 / (N_cal(D)) log p_ttheta (cal(D))
$ 
("$tilde.eq$" indica que un miembro de la ecuación es un estimador insesgado del otro). Este estimador es diferenciable, por lo que podemos estimar
$
  1 / (N_cal(M)) nabla_ttheta log p_ttheta (cal(M)) tilde.eq 1 / (N_cal(D)) nabla_ttheta log p_ttheta (cal(D)).
$


==== Variables Latentes y Modelos Profundos Latentes (DLVMs)

El método presentado en la sección anterior es válido cuando las variables del modelo dirigido son _totalmente observadas_, pero podemos extenderlo a modelos dirigidos con variables latentes. Las *variables latentes* (denotadas con $zz$) son variables que son parte del modelo, pero que no observamos, por tanto, no forman parte del dataset. 

En modelamiento incondicional, la distribución conjunta es $p_ttheta (xx, zz)$. Para conocer $p_ttheta (xx)$, 
$
  p_ttheta (xx) = integral p_ttheta (xx, zz) dif zz = integral p_ttheta (xx|zz) p_ttheta (zz) dif zz.
$
(Recuerda que $p_theta (xx, zz) = p_theta (zz|xx) p_theta (xx) = p_ttheta (xx|zz) p_theta (zz).$)

Cuando la distribución de un modelo de variable latente, $p_ttheta (xx, zz)$, está parametrizada por una red neuronal, usamos el término *Modelo Profundo de Variable Latente* (_deep latent variable model, DLVM_). Una ventaja de los DLVMs es su expresividad: la distribución marginal de $xx$ puede ser muy compleja, aun cuando la distribución condicional $p_ttheta (xx|zz)$ o la _a priori_ $p_ttheta (zz)$ son simples.


==== Intratabilidades

La principal dificultad de los DLVMs es que la marginal $p_ttheta (xx) = integral p_ttheta (xx,zz) dif zz$ es intratable, pues no tiene una fórmula analítica ni un estimador eficiente. Por esto, no podemos diferenciar respecto a $ttheta$ para optimizarla (que es nuestro objetivo), esto es, no podemos aplicar SGD. 

La intratabilidad de $p_ttheta (xx)$, recordando que
$
  p_ttheta (xx,zz) =  p_ttheta (zz|xx) p_ttheta (xx),
$
Provoca que $p(zz|xx)$ sea intratable, en principio. Es decir, ambas densidades son intratables en DLVMs.

Para resolver esto, las _técnicas aproximadas de inferencia_ nos permitirán aproximar $p_ttheta (zz|xx)$ y $p_ttheta (xx)$ en los DLVMs. Los métodos tradicionales son relativamente caros.

=== Variational Autoencoders

Superaremos las intratabilidades de los DLMVs con los VAEs.

==== Encoder

Definimos el *encoder*, *modelo de reconocimiento* o *modelo de inferencia* $q_pphia (zz|xx)$. Aquí $pphia$ indica los parámetros del modelo, llamados *parámetros variacionales*. Buscaremos que esta distribución sea lo más parecida a la posteriori $p_ttheta (zz|xx)$, es decir,
$
  q_pphia (zz|xx) approx p_ttheta (zz|xx).
$
Con ella podremos más adelante optimizar $p_ttheta (xx)$.

El modelo de inferencia puede ser prácticamente cualquier modelo gráfico dirigido,
$
  q_pphia (zz|xx) = q_pphia (zz_1,...,zz_M|xx) = product_(j=1)^M q_pphia (zz_j|"Pa"(zz_j), xx).
$
Además, $q_pphia$ puede ser parametrizada por una red neuronal profunda.

#ex[
  Podríamos tener
  $
    q_pphia (zz|xx) = "Normal"(zz; bold(mu), "diag"(bold(sigma))),
  $
  donde
  $
    (bold(mu), log bold(sigma)) = "EncoderNeuralNet"_pphia (xx).
  $
]

Usaremos un único encoder neuronal para realizar inferencia posterior sobre _todos_ los puntos del dataset, a diferencia de lo que ocurre con otros métodos de inferencia variacional, donde los parámetros de $pphia$ se optimizan separadamente _para cada punto_ del dataset. Nuestra técnica se conoce como *inferencia variacional amortizada*. Esto nos permitirá ser más eficientes y aprovechar el SGD.

==== Evidence Lower Bound (ELBO)

Para cada elección de encoder $q_pphia (zz|xx)$ (con $pphia$ ya fijo),
*REVISAR*
$
  EE(log p_ttheta (xx)) &= integral  q_pphia (zz|xx) dot log p_ttheta (xx) dif zz \ 
  &= EE_(zz ~ q_pphia (zz|xx)) [log p_ttheta (xx)] \
  &= EE_(zz ~ q_pphia (zz|xx)) [log ((p_ttheta (xx,zz)) / (p_ttheta (zz|xx)))] \
  &= EE_(zz ~ q_pphia (zz|xx)) [log ((p_ttheta (xx,zz)) / (q_pphia (zz|xx)) dot (q_pphia (zz|xx))/ (p_ttheta (zz|xx)))] \
  &= EE_(zz ~ q_pphia (zz|xx)) [log ((p_ttheta (xx,zz)) / (q_pphia (zz|xx)))] 
  + EE_(zz ~ q_pphia (zz|xx)) [log ((q_pphia (zz|xx))/ (p_ttheta (zz|xx)))].
$

Definimos *Evidence Lower Bound (ELBO)*
$
  elbo (xx) &:= EE_(zz ~ q_pphia (zz|xx)) [log ((p_ttheta (xx,zz)) / (q_pphia (zz|xx)))] \
  &= EE_(zz ~ q_pphia (zz|xx)) [log p_ttheta (xx,zz) - log q_pphia (zz|xx)]
$
y la *divergencia de Kullback-Leibler (KL)* entre $q_phia (zz|xx)$ y $p_ttheta (zz|xx)$ como
$
  KL &:= EE_(zz ~ q_pphia (zz|xx)) [log ((q_pphia (zz|xx))/ (p_ttheta (zz|xx)))] \
  &= EE_(zz ~ q_pphia (zz|xx)) [log q_pphia (zz|xx) - log p_ttheta (zz|xx)].
$

#nota[El término $EE_(z ~ q_pphia (zz|xx)) [log p_ttheta (xx|zz)]$ en $elbo(xx)$ se conoce como *error de reconstrucción*.]

De esta manera,
$
  log p_ttheta (xx) = elbo (xx) - KL.
$

Nótese que 
$
  D_"KL" >= 0,
$
por lo que
$
  log p_ttheta (xx) >= elbo (xx).
$
Además, observe que la divergencia KL determina dos distancias:
1. La distancia entre la posterior real, $p_ttheta (zz|xx)$, y su aproximación, $q_pphia (zz|xx)$, por la definición que tiene.
2. El _gap_ entre la verosimilitud marginal $log p_ttheta (xx)$ y la ELBO $elbo$. (Llamado *ajuste de la cota*.)

Es por esto que intentaremos maximizar $elbo$ con respecto a sus parámetros $ttheta, pphia$, de modo que ambas distancias se hagan lo más pequeñas posibles, de manera aproxima.


==== Stochastic Gradient-Based Optimization for ELBO

La ELBO permite SGD sobre sus parámetros. 

Dado un dataset $cal(D) = xx^((1:N))$, la ELBO objetivo es 
$
  elbo (cal(D)) := sum_(i=1)^N elbo(xx^((i))).
$
El gradiente individual $nabla_(ttheta, pphia) elbo (xx^((i)))$ es en general intratable, pero existen buenos estimados insesgados $tilde(nabla)_(ttheta, pphia) elbo (xx^((i)))$.

Respecto a $ttheta$, es directo:
$
  nabla_ttheta elbo (xx) &= nabla_ttheta EE_(z ~ q_pphia (zz|xx)) [log p_ttheta (zz|xx) - log q_pphia (zz|xx)] \
  &= nabla_ttheta integral q_pphia (zz|xx) [log p_ttheta (zz|xx) - log q_pphia (zz|xx)] dif zz \
  -->^"Leibniz" qquad&=  integral nabla_ttheta {q_pphia (zz|xx) [log p_ttheta (zz|xx) - log q_pphia (zz|xx)]} dif zz \
  &=   integral q_pphia (zz|xx) dot nabla_ttheta [log p_ttheta (zz|xx) - log q_pphia (zz|xx)] dif zz  \
  &= EE_(z ~ q_pphia (zz|xx)) [nabla_ttheta (log p_ttheta (zz|xx) - log q_pphia (zz|xx))].
$
Tomando un $zz ~ q_pphia (zz|xx)$, se obtiene un estimador simple de Monte Carlo
$
  nabla_ttheta elbo (xx) tilde.eq nabla_ttheta (log p_ttheta (zz|xx) - log q_pphia (zz|xx)) = nabla_ttheta log p_ttheta (zz|xx).
$

Respecto a $pphia$ es más difícil, pues $q_pphia$ depende justamente de $pphia$. Es decir, 
$
  nabla_ttheta elbo (xx) &= nabla_ttheta EE_(z ~ q_pphia (zz|xx)) [log p_ttheta (zz|xx) - log q_pphia (zz|xx)] \
  &!= EE_(z ~ q_pphia (zz|xx)) [nabla_ttheta (log p_ttheta (zz|xx) - log q_pphia (zz|xx))].
$

Para esto, usaremos el _truco de reparametrización_.

==== Reparametrization Trick

Expresaremos $zz ~ q_pphia (zz|xx)$ como una transformación $g$ diferenciable e invertible de otra va $eeps$, independiente de $xx$ y de $pphia$, y con densidad $p(eeps)$:
$
  zz = g(eeps, pphia, xx).
$ 
Con esto, para cualquier función $f$,
$
  EE_(z ~ q_pphia (zz|xx)) [f (zz)] &= integral q_pphia (zz|xx) f(zz) dif zz.
$
Pero,
$
  dif zz = abs(det((partial g)/(partial eeps))) dif eeps
$
y 
$
  q(zz|xx) = abs(det((partial g)/(partial eeps)))^(-1) p(eeps),
$
así que
$
  q(zz|xx) dif zz = p (eeps) dif eeps.
$
Por lo tanto,
$
  EE_(z ~ q_pphia (zz|xx)) [f (zz)] &= integral q_pphia (zz|xx) f(zz) dif zz \ 
  &= integral f(g(eeps, pphia, xx)) p(eeps) dif eeps \ 
  &= EE_(eeps ~ p(eeps)) [f(zz)].  
$
Ahora se puede hacer 
$
  nabla_pphia  EE_(z ~ q_pphia (zz|xx)) [f (zz)] &= nabla_pphia EE_(eeps ~ p(eeps)) [f(zz)] \
  &= integral nabla_pphia {f(g(eeps, pphia, xx)) p(eeps)} dif eeps \
  &= integral p(eeps) nabla_pphia f(g(eeps, pphia, xx)) dif eeps \
  &= EE_(eeps ~ p(eeps)) [nabla_pphia f(zz)].  
$
Finalmente, tenemos un estimador simple de Monte Carlo
$
  nabla_pphia EE_(z ~ q_pphia (zz|xx)) [f (zz)] tilde.eq nabla_pphia f(zz).
$
De esta manera, reparametrizamos al aleatoriedad de $zz$ y ahora podremos hacer _backpropagation_ por $zz$ y calcular los gradientes $nabla_pphia f(zz)$.

#nota[En este capítulo se enseña el _reparametrization trick_ para una $f$ cualquiera. En la sección que viene se usa una $f$ del problema.]

==== Gradiente de ELBO

Con el _reparametrization trick_, podemos escribir
$
  elbo (xx) &= EE_(z ~ q_pphia (zz|xx)) [log p_ttheta (xx, zz) - log q_pphia (zz|xx)] \
  &= EE_(eeps ~ p(eeps)) [log p_ttheta (xx,zz) - log q_pphia (zz|xx)].
$
Luego, podemos obtener un estimador simple de Monte Carlo, $tilde(cal(L))_(ttheta, pphia) (xx)$, de $elbo(xx)$ para cada $xx in cal(D)$ (o $cal(M)$):
$
  eeps &~ p(eeps) \
  zz &= g(pphia, xx, eeps) \
  tilde(cal(L))_(ttheta, pphia) (xx) &= log p_ttheta (xx,zz) - log q_pphia (zz|xx).
$
Finalmente, para optimizar el ELBO se ocupan los gradientes $nabla_(ttheta, pphia) tilde(cal(L))_(ttheta, pphia) (xx)$.

==== Algoritmo Auto-Encoding Variational Bayes (AEVB)

Por último, el algoritmo estocástico para optimizar el ELBO es

#algot[AEVB][
  \
  *Data:*
  - $cal(D)$: Dataset.
  - $q_pphia (zz|xx)$: Modelo de inferencia.
  - $p_ttheta (xx, zz)$: Modelo generativo.

  *Resultado:*
  - $ttheta, pphia$: Parámetros aprendidos

  1. $(ttheta, pphia) <- "Inicializar parámetros."$

  2. *while* SGD _no ha convergido_ *do*:
  3. |#qquad $cal(M) ~ cal(D)$ (extraer un minibatch random).
  4. |#qquad $eeps ~ p(eeps)$ (extraer sonido random para cada punto en $cal(M)$).
  5. |#qquad Calcular $tilde(cal(L))_(ttheta, pphia) (cal(M), eeps)$ y sus gradientes $nabla_(ttheta, pphia) tilde(cal(L))_(ttheta, pphia) (cal(M), eeps)$.
  6. |#qquad Actualizar $ttheta, pphia$ usando un optimizador SGD.
]

==== Notas Adicionales

Ya sabemos que denotamos con $q_pphia (zz|xx)$ el encoder (o distribución posterior), con $p_ttheta (xx|zz)$ el decoder y $p_ttheta (zz)$ para el prior.

Una vez optimizado el ELBO con el algoritmo, ya tenemos $ttheta, pphia$ "óptimos", por lo que el encoder y el decoder ya están listos para ser usados. Con ellos, la _generación de datos nuevos_ funciona del siguiente modo:
1. Samplee $zz' ~ p_ttheta (zz)$ (prior).
2. Genere $xx ~p_ttheta (xx|zz')$ (decoder).

#nota[
  Generar datos nuevos podría usarse, por ejemplo, para aumentar conjuntos pequeños de datos, o crear imágenes, sonidos, videos, etc.
]

Pero también se podría querer _reconstruir un dato_. Para ello, dado un dato $xx$:
1. Samplee $zz' ~ q_pphia (zz|xx)$ (encoder).
2. Genere $xx' ~ p_ttheta (xx|zz')$ (decoder).

#nota[
  Reconstruir un dato permite, por ejemplo, comprimir datos (guardando solamente $zz'$), eliminar ruido (guardando $xx'$ en vez de $xx$) o comprobar anomalías en el modelo (comparando $xx'$ con $xx$).
]

=== Glosario
- *Inferencia Variacional:*
- *Estimador de Monte-Carlo:*

#pagebreak()
== Neural Discrete Representation

El siguiente contenido está basado en el paper "_Neural Discrete Representation_" de Aaron van den Oord, Oriol Vinyals y Koray Kavukcuoglu (2018).


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
Esta sección está basada en el paper "Categorical Reparametrization with Gumbel-Softmax" de Eric Jang, Shixiang Gu y Ben Poole.

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

Además, el estimador Gumbel-Softmax el 2 veces más rápido para modelos de 10 clases y 9.9 veces más rápido para modelos de 100 clases, respecto a la marginalización.