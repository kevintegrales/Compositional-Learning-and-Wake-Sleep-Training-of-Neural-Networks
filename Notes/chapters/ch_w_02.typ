// Funciones
#import "/math_functions.typ": *
#import "/notalmar.typ": *
#include "/notalmar.typ"


Los dos papers de esta semana intentan obtener lo mejor de dos mundos de síntesis de programas, el enfoque simbólico (o inductivo) y el enfoque neuronal (o transductivo). 

== Searching Latent Program Spaces

El paper presenta la arquitectura *Latent Program Network (LPN)* que busca sintetizar programas a partir de pocos ejemplos y ajustarlos en caso de que la primera intuición no alcance. Para ello, toma elementos de dos acercamientos a la resolución de ARC-AGI (que los autores defienden como una buena manera de medir la inteligencia por medir la capacidad de adaptarse a nuevas tareas):
- *Acercamiento inductivo* / _Síntesis de programas simbólica_: Se produce un programa explícito, pero el espacio de búsqueda es demasiado grande, por lo que requiere un lenguaje de dominio específico (DSL) diseñado a mano que limite las opciones, algo poco escalable a tareas del mundo real. LPN de aquí usa la capacidad de búsqueda durante el momento de prueba.
- *In-context/transductivo * / _Aprendizaje profundo_: Las redes neuronales son muy escalables, pero luego de entrenarse fijan sus pesos, por lo que suele ser necesario reentrenar y, con pocos datos, suelen overfittear. Además, tienden a ser inconsistentes en reproducir los ejemplos que se les dieron. LPN de aquí toma la predicción principal.

LPN representará los programas implícitos en un espacio continuo latente de programas y usará backpropagation en su fase de _fine-tunning_ con una fracción del total de parámetros.

El paper propone realizar test-time training, que por lo general es muy costoso pues implica la actualización de millones de parámetros, en un _espacio latente continuo y compacto_ que la propia red aprendió (en vez de hacerlo en el espacio de parámetros de la red neuronal o en el espacio de programas de un DSL).

=== Background

Se define el *espacio de programas* $Y$ formulados a partir de un DSL. Cada tarea está definida por un *conjunto de especificación* $X$, donde cada *especificación* $X_m in X$ se describe como un conjunto de pares input-output,
$
  X_m = {(x^m_1, y^m_1), ..., (x^m_n, y^m_n)}.
$
Un programa $f in Y$ resuelve la tarea asociada a $X_m$ si
$
  forall j in [n], qquad f(x^m_j) = y^m _j.
$
Denotaremos con $F_m$ a la función verdadera que generó $X_m$, es decir, $F_m (x_j^m) = y^m_j$ para cada $j in [n].$

El problema de generalización se define a partir del conjunto
$
  P_m = {(x^m_1, y^m_1), ..., (x^m_n, y^m_n), x_(n+1)^m},
$
donde se buscará predecir el output correspondiente de $x^m_(n+1)$.

El paper menciona que, de no limitar la complejidad de Kolmogorov del programa, podemos potencialmente encontrar un programa para cualquier especificación, aun si corresponde o no al programa original $F_m$. (¡Esto es una gran puerta al overfitting!)

=== Arquitectura LPN

El proceso de inferencia de LPN ocurre en tres etapas:
$ \
  "Encoder" --> "Optimización en el\nespacio latente" --> "Decoder"
$

El encoder generará una primera "intuición", la optimización en el espacio latente buscará refinar dicha intuición y el decoder ejecutará el programa refinado sobre el nuevo ejemplo.

==== El Espacio Latente de Programas

Un *espacio latente* es un espacio vectorial de dimensión reducida donde una red neuronal representa de forma comprimida y abstracta la información relevante de una entrada mucho más compleja.

==== Autoencoder Variacionales (VAE) y LPN

Un *autoencoder variacional (VAE)* es una red neuronal generativa que toma datos de entrada, los transforma a un espacio latente cotinuo según una distribución de probabilidad (lo que permitirá generar nuevos datos) y toma los puntos de dicho espacio para reconstruirlos o transformarlos en nuevos datos.

Más formalmente, un VAE tiene:
- Un *encoder* $q_phia (z|x, y)$: dado un dato $(x,y)$ de entrada, produce parámetros de media $mu$ y varianza $Sigma$ de una distribución de probabilidad Normal multivariada sobre los posibles valores de un vector $z$ en el espacio latente de programas. Además, el encoder procesa cada par por separado y luego los promedia, de modo que el LPN sea invariante a la _permutación de ejemplos_. $phi.alt$ corresponde a los pesos de la red neuronal del encoder.  
- Un *decoder* $p_theta (y|x, z)$: dado un programa latente $z$ y un input nuevo $x$, reconstruye los datos de salida $y$. Se construye maximizando la verosimilitud de reconstruir bien los datos. $theta$ corresponde a los pesos de la red neuronal de decoder.

El VAE permitirá modelar la ambigüedad de los muchos programas posibles con la distribución de probabilidad.

Puedes aprender más sobre VAEs en @vaes.

==== La Optimización en el Espacio Latente

Tendremos
$
  underbrace(z ~ q_phi.alt (z | x,y), "Encoder") qquad qquad underbrace(z' = f(p_theta, z, x, y), "Optimización latente") qquad qquad underbrace(hat(y) ~ p_theta (y | x, z), "Decoder")
$

El paso intermedio parte desde $z$, donde se busca un mejor programa $z'$ que explique, bajo el actual decoder, de mejor manera los datos observados.

Dados datos ${(x_i, y_i)}_(i=1)^n$, el proceso de búsqueda $z' = f(p_theta, z, x, y)$ consiste en encontrar un $z'$ que satisfaga
$
  z' in arg max_z sum_(i=1)^n log p_theta (y_i | x_i, z),
$
esto es, se busca el programa que más probabilidades tenga de producir resultados correctos bajo el decoder actual y los datos que se tienen.

Se proponen dos maneras de encontrar $z'$:
- Por *muestreo*: se generan $K$ programas $z_k$ muestreados (de alguna distribución, ya sea $p(z)$ o la posteriori $q_phi.alt (z|x_i, y_i)$) y se elige el que tenga mayor log-verosimilitud. Su eficiencia decrece exponencialmente respecto a la dimensión del espacio latente.
- Por *Ascenso de Gradiente*: el decoder es una red neuronal diferenciable y, en particular, también su log-verosimilitud respecto a $z$. Se inicializa en $z'_0$ (promedio de todos los pares latentes sampleados del encoder) y se itera con #desc[
  $
    
    forall k in [1, K], qquad z'_k = z'_(k-1) + alpha dot limits(nabla_z sum_(i=1)^n log p_theta (y_i | x_i, z))|_(z=z'_(k-1)).
  $
  El ascenso de gradiente aquí se realiza en el espacio latente de programas. Como el espacio es de menor dimensión que el de los parámetros de la red, la optimización es mucho más barata.
]

==== Entrenamiento del Encoder y del Decoder

Aquí se trata cómo se obtienen los valores de $phi.alt$ y de $theta$.

Primero, para entrenar al encoder se utiliza la estrategia "*leave-one-out*" (LOO), donde, para reconstruir cada $y_i$:
1. Con cada $j!=i$, se muestrea $z_j ~ q_phi.alt (z |x_j, y_j)$ con el encoder.
2. Se agregan promediándolos: $overline(z) = 1/(n-1) sum_(j!=i) z_j$.
3. Se obtiene un $z'_i$ con optimización en el espacio latente (e.g. con ascenso de gradiente).
4. Se calcula la log-verosimilitud de predecir correctamente $y_i$ dado $x_i$ y $z'_i$ con el decoder (fijo en este instante).

La función objetivo a entrenar
$
  cal(L)_"total" (phi.alt, theta) = cal(L)_"rec" (phi.alt, theta) + beta cal(L)_"KL" (phi.alt)
$
se subdivide en:
- #desc[
  *Pérdida de reconstrucción* $cal(L)_"rec"$:
  $
    cal(L)_"rec" (phi.alt, theta) = sum_(i=1)^n - log p_theta (y_i | x_i, z'_i)
  $

  Mide qué tan mal predice el _decoder_ las salidas correctas.
]
- #desc[
  *Pérdida de regularización* $cal(L)_"KL" (phi.alt)$:
  $
    cal(L)_"KL" (phi.alt) = sum_(i=1)^n D_"KL" (q_phi.alt (z | x_i, y_i) || "Normal"(0,I))
  $
  Mide qué tan lejos está la distribución que produjo el _encoder_ de una distribución Normal (gracias a la *divergencia de Kullback-Leibler*), ayudando a que esta sea lo suficientemente suave para poder ser diferenciada.
]
- Factor $beta$: Regula qué tanta importancia tiene un término por sobre otro.

Se menciona un *truco de reparametrización*, donde en vez de muestrear un $z ~ "Normal"(mu, Sigma)$, se muestrea ruido $epsilon.alt ~ "Normal"(0, I)$ y luego se transforma linealmente 
$
  z = mu + epsilon.alt dot Sigma,
$
de modo que dicho $z$ sea diferenciable#footnote[¿Porque vamos a diferenciar $cal(L)_"total"$ respecto a $phi.alt$?].


=== Experimentos y Resultados

_PENDIENTE_

=== Limitaciones

_PENDIENTE_

Se sabe que tienen problemas para generalización composicional.

=== Preguntas
- ¿Cómo evita el sobreajuste?
- No entiendo del todo el flujo al entrenar. ¿Cuándo se usa LOO y cuándo ascenso de gradiente? ¿Se entrenan el encoder y el decoder una sola vez al principio y ya, o se vuelven a entrenar luego de hacer ascenso de grandiente con un ejemplo?
- ¿El promedio en LOO es el que introduce el término de invariante ante permutaciones?
- ¿Qué es el _early stopping_? ¿Por qué ayuda a no sobreajustar?
- ¿Cómo se ahorra costos el modelo?



=== Glosario
- *Fine-tunning*: Proceso de adaptar los parámetros de una red una vez esta ya ha sido entrenada.
- *Test-time training*: Capacidad de los modelos de aprender (optimizar o hacer búsqueda temporal) luego de ya haber sido "entrenados" (i.e. durante la fase de inferencia), pudiendo ajustarse a los ejemplos de una tarea nueva para resolverla momentáneamente. 
- *Few-shot learning*: aprendizaje con pocos casos.


== Gradient-Based Program Synthesis with Neurally Interpreted Languages

Introducen el concepto de *Latent Adaptation Networks (LANs)*, que son redes con encoder y decoder que aprenden un espacio latente para representar el espacio de modelos (o programas). Una característica esencial es que en test-time se busca en el espacio latente para adaptarse y mejorar los resultados. 

Los autores presentan la arquitectura *Neural Language Interpreter (NLI)* que justamente es del tipo LAN, pero a diferencia del paper anterior, este aprovechará tokens para construir el programa en el espacio latente (y no representarlo como un único vector), de modo que se tenga mayor poder de generalización. Además, esta característica permite que el modelo pueda resolver problemas más difíciles (que requieren más tokens) que los que se le presentaron durante el entrenamiento.

=== Formalización

Se formaliza la tarea como un *program induction*. Dado un programa $p$ que genera los pares $S = {(x_i, y_i)}_(i=1)^n$ (es decir, $p(x_i) = y_i$), buscamos un modelo $M$ que prediga con $M(S, x_(n+1))$, para un nuevo input $x_(n+1)$, el valor de $p(x_(n+1))$. Se denotará con $cal(P)$ el espacio de posibles programas y se definen distribuciones $P_"train"$ y $P_"test"$ para entrenar y testear, respectivamente, la arquitectura, de modo que se pueda verificar su generalización.

=== Inferencia Discreta Secuencial

NLI aprende un lenguaje de programación discreto y "simbólico" (_symbolic-like_) para representar programas como secuencias de tokens (de longitud variable) que son ejecutadas por un ejecutor neuronal diferenciable. (¡Importa mucho que sea diferenciable para la optimización que se realizará!) 

==== Objetivo de Entrenamiento

Para aprender el espacio latente con el que representar problemas, se usa una arquitectura encoder-decoder. El encoder, *inductor de programa* $q_phi.alt$, infiere una representación latente de programas desde unos pares input-outputs, la cual el decoder, *interpretador neuronal* $p_theta$, ejecuta para predecir outputs dado un input.

Nuevamente se usa la estrategia de _leave-one-out_ sobre _mini-batches_ de tamaño $B$, donde cada especificación contiene $m$ pares input-output. Así, $q_phi.alt$ induce un espacio latente usando $m-1$ pares y el error de predicción se calcula con aquel par dejado fuera. Definimos, para la $b$-ésima especificación y el $i$-ésimo par, $SSS_(b,i) := SSS_b without {(x_(b,i), y_(b,i))}$. Para cada $SSS_(b,i)$ buscamos maximizar la verosimilitud de predecir $y_(b,i)$ a partir de $x_(b,i)$, mientras se regulariza para reutilizar tokens. Así, la función de pérdida a minimizar es
$
  cal(L)(phi.alt, theta; SSS) = 1/B sum_(b=1)^B (1/m sum_(i=1)^m cal(L)_"recon" (phi.alt, theta; x_(b,i), y_(b,i), SSS_(b,i)) + lambda_"reg" dot cal(L)_"reg" (phi.alt; SSS_b))
$

donde
- $cal(L)_"recon"$ es la *pérdida de reconstrucción*: asegura que el programa sea lo suficientemente expresivo. $ cal(L)_"recon" (phi.alt, theta; x, y, S) := -log p_theta (y | x, q_phi.alt (S)). $
- $cal(L)_"reg"$ es la *pérdida de regularización del encoder*: motiva la reutilización de tokens ya descubiertos en el vocabulario de tamaño $K$ (¡esto motiva la composicionalidad!). $ cal(L)_"reg" (phi.alt; SSS) := sum_(k=1)^K sum_(j = 1)^N [1 - exp(sum_(b=1)^B sum_(i=1)^m log(1 - q_phi.alt^((k,j)) (SSS_(b,i))))] $
  - $N$: número de posiciones de tokens en el programa.
  - $q_phi.alt^((k,j)) (SSS_(b,i))$: probabilidad asignada al token $k$ en la posición $j$ por el encoder.
  El $1 - exp$ consiste en la probabilidad de que el token sea usado al menos una vez en el batch. 


=== Preguntas
- ¿*Test-time* y *tiempo de inferencia* son lo mismo? En este contexto sí. Van contrarios al *training-time*.
- ¿Qué es una *ablación*? Es un experimento del modelo, donde se remueve un componente de él para entender qué tan necesario es. 
- ¿Aquí no se usa un muestreo desde una Normal con media $mu$ y varianza $Sigma$?
- ¿$SSS_B subset S$?
- ¿Qué es un *batch*?

#pagebreak()
=== Glosario
- *Transformer*: Arquitectura de red neuronal diseñada específicamente para procesar y generar datos secuenciales, como el lenguaje natural. Consisten en un _encoder_ (que convierte la entrada en una matriz) y en un _decoder_ (que genera una secuencia final en base a lo que generó el decoder y escogiendo aquella con mayor probabilidad de aparición).

== Diferencias entre ambas investigaciones

_PENDIENTE: MUY IMPORTANTE_