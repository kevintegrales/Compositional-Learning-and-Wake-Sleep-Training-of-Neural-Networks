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

== Variational Autoencoders

Superaremos las intratabilidades de los DLMVs con los VAEs.

=== Encoder

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

=== Evidence Lower Bound (ELBO)

Para cada elección de encoder $q_pphia (zz|xx)$ (con $pphia$ ya fijo),
$
  log p_ttheta (xx) &= integral  q_pphia (zz|xx) dot log p_ttheta (xx) dif zz \ 
  &= E_(zz ~ q_pphia (zz|xx)) [log p_ttheta (xx)] \
  &= E_(zz ~ q_pphia (zz|xx)) [log ((p_ttheta (xx,zz)) / (p_ttheta (zz|xx)))] \
  &= E_(zz ~ q_pphia (zz|xx)) [log ((p_ttheta (xx,zz)) / (q_pphia (zz|xx)) dot (q_pphia (zz|xx))/ (p_ttheta (zz|xx)))] \
  &= E_(zz ~ q_pphia (zz|xx)) [log ((p_ttheta (xx,zz)) / (q_pphia (zz|xx)))] 
  + E_(zz ~ q_pphia (zz|xx)) [log ((q_pphia (zz|xx))/ (p_ttheta (zz|xx)))].
$

Definimos *Evidence Lower Bound (ELBO)*
$
  elbo (xx) &:= E_(zz ~ q_pphia (zz|xx)) [log ((p_ttheta (xx,zz)) / (q_pphia (zz|xx)))] \
  &= E_(zz ~ q_pphia (zz|xx)) [log p_ttheta (xx,zz) - log q_pphia (zz|xx)]
$
y la *divergencia de Kullback-Leibler (KL)* entre $q_phia (zz|xx)$ y $p_ttheta (zz|xx)$ como
$
  KL &:= E_(zz ~ q_pphia (zz|xx)) [log ((q_pphia (zz|xx))/ (p_ttheta (zz|xx)))] \
  &= E_(zz ~ q_pphia (zz|xx)) [log q_pphia (zz|xx) - log p_ttheta (zz|xx)].
$

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


=== Stochastic Gradient-Based Optimization for ELBO

La ELBO permite SGD sobre sus parámetros. 

Dado un dataset $cal(D) = xx^((1:N))$, la ELBO objetivo es 
$
  elbo (cal(D)) := sum_(i=1)^N elbo(xx^((i))).
$
El gradiente individual $nabla_(ttheta, pphia) elbo (xx^((i)))$ es en general intratable, pero existen buenos estimados insesgados $tilde(nabla)_(ttheta, pphia) elbo (xx^((i)))$.

Respecto a $ttheta$, es directo:
$
  nabla_ttheta elbo (xx) &= nabla_ttheta E_(z ~ q_pphia (zz|xx)) [log p_ttheta (zz|xx) - log q_pphia (zz|xx)] \
  &= nabla_ttheta integral q_pphia (zz|xx) [log p_ttheta (zz|xx) - log q_pphia (zz|xx)] dif zz \
  -->^"Leibniz" qquad&=  integral nabla_ttheta {q_pphia (zz|xx) [log p_ttheta (zz|xx) - log q_pphia (zz|xx)]} dif zz \
  &=   integral q_pphia (zz|xx) dot nabla_ttheta [log p_ttheta (zz|xx) - log q_pphia (zz|xx)] dif zz  \
  &= E_(z ~ q_pphia (zz|xx)) [nabla_ttheta (log p_ttheta (zz|xx) - log q_pphia (zz|xx))].
$
Tomando un $zz ~ q_pphia (zz|xx)$, se obtiene un estimador simple de Monte Carlo
$
  nabla_ttheta elbo (xx) tilde.eq nabla_ttheta (log p_ttheta (zz|xx) - log q_pphia (zz|xx)) = nabla_ttheta log p_ttheta (zz|xx).
$

Respecto a $pphia$ es más difícil, pues $q_pphia$ depende justamente de $pphia$. Es decir, 
$
  nabla_ttheta elbo (xx) &= nabla_ttheta E_(z ~ q_pphia (zz|xx)) [log p_ttheta (zz|xx) - log q_pphia (zz|xx)] \
  &!= E_(z ~ q_pphia (zz|xx)) [nabla_ttheta (log p_ttheta (zz|xx) - log q_pphia (zz|xx))].
$

Para esto, usaremos el _truco de reparametrización_.

=== Reparametrization Trick

Expresaremos $zz ~ q_pphia (zz|xx)$ como una transformación $g$ diferenciable e invertible de otra va $eeps$, independiente de $xx$ y de $pphia$, y con densidad $p(eeps)$:
$
  zz = g(eeps, pphia, xx).
$ 
Con esto, para cualquier función $f$,
$
  E_(z ~ q_pphia (zz|xx)) [f (zz)] &= integral q_pphia (zz|xx) f(zz) dif zz.
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
  E_(z ~ q_pphia (zz|xx)) [f (zz)] &= integral q_pphia (zz|xx) f(zz) dif zz \ 
  &= integral f(g(eeps, pphia, xx)) p(eeps) dif eeps \ 
  &= E_(eeps ~ p(eeps)) [f(zz)].  
$
Ahora se puede hacer 
$
  nabla_pphia  E_(z ~ q_pphia (zz|xx)) [f (zz)] &= nabla_pphia E_(eeps ~ p(eeps)) [f(zz)] \
  &= integral nabla_pphia {f(g(eeps, pphia, xx)) p(eeps)} dif eeps \
  &= integral p(eeps) nabla_pphia f(g(eeps, pphia, xx)) dif eeps \
  &= E_(eeps ~ p(eeps)) [nabla_pphia f(zz)].  
$
Finalmente, tenemos un estimador simple de Monte Carlo
$
  nabla_pphia E_(z ~ q_pphia (zz|xx)) [f (zz)] tilde.eq nabla_pphia f(zz).
$
De esta manera, reparametrizamos al aleatoriedad de $zz$ y ahora podremos hacer _backpropagation_ por $zz$ y calcular los gradientes $nabla_pphia f(zz)$.



== Glosario
- *Inferencia Variacional:*
- *Estimador de Monte-Carlo:*