// Funciones
#import "/math_functions.typ": *
#import "/notalmar.typ": *
#include "/notalmar.typ"

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
- Un *encoder* $q_phi.alt (z | x, y)$: dado un dato $(x,y)$ de entrada, produce parámetros de media $mu$ y varianza $Sigma$ de una distribución de probabilidad Normal multivariada sobre los posibles valores de un vector $z$ en el espacio latente de programas. Además, el encoder procesa cada par por separado y luego los promedia, de modo que el LPN sea invariante a la _permutación de ejemplos_. $phi.alt$ corresponde a los pesos de la red neuronal del encoder.  
- Un *decoder* $p_theta (y | x, z)$: dado un programa latente $z$ y un input nuevo $x$, reconstruye los datos de salida $y$. Se construye maximizando la verosimilitud de reconstruir bien los datos. $theta$ corresponde a los pesos de la red neuronal de decoder.

El VAE permitirá modelar la ambigüedad de los muchos programas posibles con la distribución de probabilidad.

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

==== Entrenamiento









#pagebreak()
=== Glosario
- *Fine-tunning*: Proceso de adaptar los parámetros de una red una vez esta ya ha sido entrenada.
- *Test-time training*: Capacidad de los modelos de aprender (optimizar o hacer búsqueda temporal) luego de ya haber sido "entrenados" (i.e. durante la fase de inferencia), pudiendo ajustarse a los ejemplos de una tarea nueva para resolverla momentáneamente. 
- *Few-shot learning*: aprendizaje con pocos casos.

== Gradient-Based Program Synthesis