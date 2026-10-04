// Funciones
#import "/math_functions.typ": *
#import "/notalmar.typ": *
#include "/notalmar.typ"


== DreamCoder
<dream_coder>
#notat[Fuente][
  Contenido estudiado de _"DreamCoder: Bootstrapping Inductive Program Synthesis with Wake-Sleep Library Learning"_ de K. Ellis et al. (2021).
  #fuente_link("https://arxiv.org/abs/2006.08381", "arXiv:2006.08381")
]

#nota[No confundir con *@dreamer*.]


DreamCoder es un modelo de síntesis de programas. Es decir, a partir de un conjunto de pares input-output, se busca generar un programa que permita realizar esos mismos cálculos y luego generalizar. El algoritmo, a grandes rasgos, itera creando código y luego factorizando el código en funciones que busca reutilizar.


=== Síntesis Inductiva de Programas

Dado un conjunto de tareas $cal(X) = {x_1,...,x_n}$, cada una especificada por un pequeño número de pares input-output de ejemplo, buscamos encontrar programas ${rho.alt_x_i}$ que satisfacen todos los ejemplos para cada tarea, respectivamente. 

El problema tiene tres retos esenciales:
1. Explosión combinatorial: el número de programas válidos sintácticamente crece exponencialmente.
2. Generalización, no interpolación: se busca que el programa sea correcto incluso con inputs fuera del training set.
3. Interpretabilidad y reuso: idealmente el programa debe ser interpretable por un humano y deseablemente reutilizable a futuro.

==== Fundación en el MDL

#def[
  Para una librería $L$ y programas ${rho.alt_i}$ que resuelven tareas en  $cal(X)$, el *joint description length* es
  $
    "DL"(L, {rho.alt}, cal(X)) := abs(L) + sum_(x in cal(X)) abs(rho.alt_x)_L.
  $
]

El objetivo MDL aquí es encontrar $(L^*, {rho.alt_x^*})$ que minimiza el joint description length sujeto a que $rho.alt_x$ resuelve $x in cal(X)$.

Después de un poco de desarrollo, se obtiene que el objetivo de DreamCoder corresponde justamente al del MDL. Sin embargo, el objetivo obtenido es intratable por la explosión combinatorial. Para ello, se introduce el *amortised recognition model* $Q_theta (rho.alt|x)$, una red neuronal que permite aproximar una distribución que era intratable. El rol de $Q_theta$ es guiar la búsqueda de programas, prediciendo qué programas son más probables de resolver las tareas dadas.




==== Domain-Specific Languages (DSL)
Los Domain-Specific Languages permiten resolver el problema de la explosión combinatorial. Sin embargo, hasta antes de esta investigación, estos se daban desde un inicio. En este paper es el mismo modelo el que crea su DSL.


=== Wake-Sleep Algorithm

DreamCoder realiza inferencia bayesiana aproximada por medio un proceso iterativo que tiene tres fases:
- *Wake:* actualiza ${rho.alt_x}$ manteniendo $L$ y $theta$ fijas. 
  Busca programas usando $Q_theta$ y $L$.
- *Sleep (Abstraction):* actualiza $L$, manteniendo ${rho.alt_x}$ y $theta$ fijas.
  Comprime los programas en $L$.
- *Sleep (Dreaming):* actualiza $theta$ manteniendo ${rho.alt_x}$ y $L$ fijas.
  Entrena $Q_theta$ en replays y fantasías.

==== Wake phase
Se busca para cada tarea $x in cal(X)$ el programa con mayor puntuación, dada por el modelo de reconocimiento $Q_theta$ y la prior $P$:
$
  "score"(rho.alt, x) = log Q_theta (rho.alt|x) + underbrace(log P(rho.alt, L), -abs(rho.alt)_L).
$
La implementación usa beam-first-search. Los programas que no son correctos para todos los ejemplos de la tarea son descartados. Además, se tiene un presupuesto de tiempo de entrenamiento. Pasado el presupuesto, se detiene la búsqueda. (Si no se encontró un programa, la tarea simplemente permanece no resuelta.)

==== Sleep Abstraction Phase

Se busca una librería $L^*$ que introduce nuevo vocabulario sólo si extender $L^*$ tiene mayor beneficio en compresión que el perjuicio en longitud. Para esto se hace
$
  L^* = arg max_L [log P(L) + sum_(x in cal(X)) log P(rho.alt_x^*|L)], 
$
donde $log P(L) = -beta "size"(L)$ es un regularizador que permite aplicar el MDL.

==== Sleep Dreaming Phase

Aquí se mejora la predicción de $Q_theta$ sobre $P(rho.alt|x,L)$. El objetivo de entrenamiento es
$
  theta^* = arg max_theta E_((rho.alt, x) ~ P_"train") [log Q_theta (rho.alt|x)],
$
donde $P_"train"$ es una mezcla de:
- Replays: pares $(x, rho.alt_x^*)$. Permiten que $Q_theta$ no olvide cómo resolver tareas que ya ha resuelto.
- Fantasías: pares $(x, rho.alt)$, donde $rho.alt ~ P(rho.alt|L)$ y $x$ se induce ejecutando $rho.alt$ en inputs random. Ellas permiten tener un suministro ilimitado de datos sintéticos para el entrenamiento y permiten que $Q_theta$ generalice más allá del pequeño training set. 

#notat[Conexión con DreamerV3][
  El rol de las fantasías es similar al del modelo de mundo que usas DreamerV3. Ambos permiten experimentar ilimitadamente y ensayar con datos que no ha obtenido de la fuente original, basándose en la experiencia pasada.
]

#pagebreak()
Los dos papers siguientes intentan obtener lo mejor de dos mundos de síntesis de programas, el enfoque simbólico (o inductivo) y el enfoque neuronal (o transductivo). 

== Searching Latent Program Spaces
#notat[Fuente][
  Contenido estudiado de _"Searching Latent Program Spaces"_ de M. V. Macfarlane et al. (2024).
  #fuente_link("https://arxiv.org/abs/2411.08706", "arXiv:2411.08706")
]

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
  "Encoder" qquad --> qquad "Optimización en el\nespacio latente" qquad --> qquad "Decoder"
$

El encoder generará una primera "intuición", la optimización en el espacio latente buscará refinar dicha intuición y el decoder ejecutará el programa refinado sobre el nuevo ejemplo.

==== El Espacio Latente de Programas

Un *espacio latente* es un espacio vectorial de dimensión reducida donde una red neuronal representa de forma comprimida y abstracta la información relevante de una entrada mucho más compleja.

==== Autoencoder Variacionales (VAE) y LPN

Un *autoencoder variacional (VAE)* es una red neuronal generativa que toma datos de entrada, los transforma a un espacio latente continuo según una distribución de probabilidad (lo que permitirá generar nuevos datos) y toma los puntos de dicho espacio para reconstruirlos o transformarlos en nuevos datos.

Más formalmente, un VAE tiene:
- Un *encoder* $q_phia (z|x, y)$: dado un dato $(x,y)$ de entrada, produce parámetros de media $mu$ y varianza $Sigma$ de una distribución de probabilidad Normal multivariada sobre los posibles valores de un vector $z$ en el espacio latente de programas. Además, el encoder procesa cada par por separado y luego los promedia, de modo que el LPN sea invariante a la _permutación de ejemplos_. $phi.alt$ corresponde a los pesos de la red neuronal del encoder.  
- Un *decoder* $p_theta (y|x, z)$: dado un programa latente $z$ y un input nuevo $x$, reconstruye los datos de salida $y$. Se construye maximizando la verosimilitud de reconstruir bien los datos. $theta$ corresponde a los pesos de la red neuronal del decoder.

El VAE permitirá modelar la ambigüedad de los muchos programas posibles con la distribución de probabilidad.

#nota[
  Puedes aprender más sobre VAEs en @vaes.
]

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
    forall k in [1, K], qquad z'_k = z'_(k-1) + alpha dot nabla_z lr(sum_(i=1)^n log p_theta (y_i | x_i, z)|, size: #90%)_(z=z'_(k-1)).
  $
  El ascenso de gradiente aquí se realiza en el espacio latente de programas. Como el espacio es de menor dimensión que el de los parámetros de la red, la optimización es mucho más barata.
]

==== Fase de Entrenamiento Offline

Aquí se trata cómo se obtienen los valores de $phi.alt$ (parámetros del encoder) y de $theta$ (parámetros del decoder).

Durante el entrenamiento se utiliza la estrategia "*leave-one-out*" (LOO), donde, para reconstruir cada $y_i$:
1. Con cada $j!=i$, se muestrea $z_j ~ q_phi.alt (z |x_j, y_j)$ con el encoder. La distribución es una $cal(N)(mu_j, Sigma_j)$, cuyos parámetros produce el encoder.
2. Se agregan promediándolos: $overline(z) = 1/(n-1) sum_(j!=i) z_j$.
3. Se obtiene un $z'_i$ con optimización en el espacio latente (e.g. con ascenso de gradiente [¡Por esto se diferencia $cal(L)_"total"$ respecto a $phia$!]).
4. Se calcula la log-verosimilitud de predecir correctamente $y_i$ dado $x_i$ y $z'_i$ con el decoder ($theta$ fijo en este instante).

Además, la función objetivo a entrenar es
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
- Factor $beta$: Regula qué tanta importancia tiene un término por sobre otro. (Este parámetro hace que esta investigación se considere un $beta$-VAE, aunque en los experimentos usan $beta approx 10^(-4) < 1$, y muchas veces en los $beta$-VAE se una $beta > 1$.) 

Además, para diferenciar $cal(L)_"rec"$ se menciona el *truco de reparametrización*, donde en vez de muestrear un $z ~ "Normal"(mu, Sigma)$, se muestrea ruido $epsilon.alt ~ "Normal"(0, I)$ y luego se transforma linealmente 
$
  z = mu + epsilon.alt dot Sigma,
$
de modo que dicho $z$ sea diferenciable.

#nota[Puedes aprender más sobre el truco de reparametrización en @reparameterization.]


El entrenamiento total se puede expresar como el siguiente pseudocódigo:
```
----------------------------
Inicializar φ, θ al azar

Repetir S veces:                     # S = número de pasos de entrenamiento
    Tomar un batch de B tareas

    Para cada tarea del batch:
        Para cada par i:                  # LOO
            Codificar los pares j ≠ i y promediar → z
            Repetir K veces:              # bucle interno: solo se mueve z
                z ← z + α ∇_z Σ_{j≠i} log p_θ(y_j | x_j, z)
            NLL_i = −log p_θ(y_i | x_i, z)
        pérdida de la tarea = Σ_i NLL_i + β Σ_i KL_i

    L_total = Promedio de las pérdidas del batch
    φ ← φ − η ∇_φ L_total                 # bucle externo: 1 actualización
    θ ← θ − η ∇_θ L_total
----------------------------
```

Aquí, los batches son conjuntos colecciones de conjuntos $X_m$ (esto es, pares de ejemplos input-output).

Al terminar estos entrenamientos para $phia$ y $theta$, ambos se dejan fijos durante el funcionamiento del programa (fase de prueba).

==== Fase de Prueba

Se reciben $n$ pares de ejemplos input-output (los que aparecen en $P_m$). Pasan por el encoder y sus resultados se promedian para generar $z'_0$. Luego, se aplica Ascenso de Gradiente para llegar a $z'_K$ (donde $K$ puede ser más grande que en entrenamiento) maximizando la verosimilitud sobre los $n$ ejemplos. Por último, el decoder recibe $x_(n+1)$ (el nuevo input) y $z'_K$ para producir su respuesta. 


=== Experimentos y Resultados
// Para desarrollar esta sección me apoyé de una redacción creada con un LLM

Los experimentos buscan responder tres preguntas: 
1. ¿Puede LPN _mejorar en test-time_ buscando en su espacio latente?
2. ¿Cómo afecta la manera de entrenarlo a esa búsqueda?
3. ¿Generaliza fuera de la distribución de entrenamiento? 


#notat[Notación de los experimentos][
  - *Grad $N$*: se hacen $N$ pasos de ascenso de gradiente en el espacio latente. *Grad 0* significa usar directamente el promedio de los latentes del encoder (sin búsqueda).
  - *Sample $N$*: se muestrean $N$ latentes del encoder y se elige el de mayor log-verosimilitud (búsqueda sin gradientes).
  - La misma notación se usa para el *entrenamiento* (cuántos pasos hay en el bucle interno del pseudocódigo) y para la *inferencia* (cuántos pasos se hacen en la fase de prueba). Pueden ser distintos.
  - *Grad $N$ $star.op star.op$*: durante el entrenamiento se deja que el gradiente de $theta$ fluya _a través_ del paso de optimización latente (derivadas de segundo orden, como en meta-learning). En la versión normal, el término $alpha nabla_z (dots)$ se trata como una constante (_stop gradient_).
  - La métrica es *exact match accuracy*: la predicción cuenta sólo si la grilla (o secuencia) completa es correcta.
]

==== Tarea Pattern (tarea de juguete)

Antes de ARC-AGI, los autores estudian la dinámica de LPN en una tarea simple: inputs de $10 times 10$ completamente negros con un pixel azul, que indica dónde el output debe "pegar" un patrón de $4 times 4$. El patrón es el mismo en todos los pares de una especificación (es "el programa"), pero cambia entre especificaciones. Se entrena un modelo de $1$M de parámetros por $20$k pasos, con 3 semillas.

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
  caption: [Accuracy (%) en la tarea Pattern. Filas: método de entrenamiento. Columnas: método de inferencia.],
)

Lo que se concluye de la tabla:
1. *Sin búsqueda en inferencia, todo falla.* Con Grad 0 en inferencia ninguna variante supera el $9%$.
2. *Más búsqueda $=>$ mejor desempeño.* 
3. *Entrenar sabiendo que habrá búsqueda importa.* 
4. *El gradiente le gana ampliamente al muestreo.* 

==== ¿Importa partir la búsqueda desde el encoder?

En la tarea Pattern se compara iniciar la búsqueda latente desde el encoder ($z ~ q_phia (z|x,y)$) contra iniciarla desde la prior ($z ~ p(z) = "Normal"(0, I)$). Iniciar desde el encoder es *crítico* en todos los métodos de entrenamiento.

#notat[Sistema 1 y Sistema 2][
  Los autores interpretan esto con la analogía de los dos sistemas de pensamiento (de Kahneman): el encoder hace un razonamiento rápido e intuitivo (*Sistema 1*) que acerca a una buena región del espacio, y la optimización latente hace un razonamiento lento y deliberado (*Sistema 2*) que refina la respuesta. Ninguno de los dos basta por sí solo.
]

==== Generalización Fuera de Distribución (OOD)

En la tarea Pattern, los modelos se entrenan con patrones de densidad $50%$ (mitad negros, mitad de color) y se evalúan con patrones de densidad $100%$ (_fuertemente OOD_).

#figure(
  table(
    columns: 4,
    align: center,
    table.header([*Entrenamiento*], [*Grad 0*], [*Grad 10*], [*Grad 100*]),
    [In-Context], [0.0], [—], [—],
    [TTT], [0.0], [1.8], [0.3],
    [LPN Grad 0], [0.3], [18.8], [41.1],
    [LPN Grad 1], [0.0], [59.9], [*88.0*],
  ),
  caption: [Accuracy (%) en la tarea Pattern fuertemente OOD.],
)

Ni in-context learning ni TTT (_Test Time Training_, ajustes de los parámetros $theta$ de una red durante el funcionamiento) logran recuperar el patrón correcto. LPN, sin búsqueda, tampoco ($0%$), pero con 100 pasos de gradiente llega al $88%$. Es decir, *la búsqueda en test-time es lo que permite adaptarse a tareas nuevas*. 

==== Composición de Programas

Por último, los autores prueban si la búsqueda permite *componer* operaciones que el modelo sólo vio por separado durante el entrenamiento:
- *Dos operaciones* (extraer el patrón dentro de un recuadro + pintar de rosado los pixeles negros): el encoder sólo extrae el patrón, sin cambiar el color (se sobreajusta a las operaciones aisladas que vio). Con ascenso de gradiente, el latente se ajusta y el decoder produce la composición correcta. 
- *Tres operaciones* (una de tipo "gravedad", un relleno y un patrón de tablero de ajedrez para ese relleno): LPN aplica la gravedad y el relleno, pero se queda con el relleno que vio en entrenamiento y, ni siquiera con búsqueda, logra aplicar el patrón de tablero.

Lo anterior muestra que la búsqueda latente _a veces_ permite componer programas en combinaciones nuevas, pero esta capacidad *no es robusta*.

=== Limitaciones

/*+ *Poca diversidad de programas en el entrenamiento.* LPN se entrena sólo con re-arc. Aunque se usan aumentaciones, la distribución de programas es estrecha, lo que limita qué tan expresivo y complejo puede ser el espacio latente. Los autores creen que esto explica por qué TTT lo alcanza en ARC OOD con mucho cómputo: si un programa nuevo no está "cerca" de nada que el espacio latente represente, la búsqueda no tiene a dónde llegar.*/

+ *Generalización composicional limitada.* Como se vio en los experimentos de composición, LPN logra (a veces) componer dos operaciones, pero falla con tres. Cada programa es un *único vector continuo* $z$, y nada en la arquitectura obliga a que ese vector se pueda descomponer en "partes" reutilizables. Los mismos autores proponen explorar *representaciones discretas* de programas para mejorar esto, que es justamente lo que harán más adelante con NLI (ver la sección _El Aporte de la Discretización_).


+ *Depende del cómputo en test-time.* Sin búsqueda (Grad 0), LPN rinde mal tanto en Pattern como OOD. Es decir, el modelo no "resuelve" la tarea en una pasada: su buen desempeño requiere gastar cómputo en inferencia. 

+ *Lejos del estado del arte en ARC.* Su $15.5%$ OOD está muy por debajo del $75.7%$ de o3-preview (aunque con costos incomparablemente menores). (Queda abierto cómo escala LPN con más datos, parámetros y cómputo.)

=== Preguntas
- ¿Cómo evita el sobreajuste?
- No entiendo del todo el flujo al entrenar. ¿Cuándo se usa LOO y cuándo ascenso de gradiente? ¿Se entrenan el encoder y el decoder una sola vez al principio y ya, o se vuelven a entrenar luego de hacer ascenso de grandiente con un ejemplo?
- ¿El promedio en LOO es el que introduce el término de invariante ante permutaciones?
- ¿Qué es el _early stopping_? ¿Por qué ayuda a no sobreajustar?
- ¿Cómo se ahorra costos el modelo?



=== Glosario
- *Fine-tuning*: Proceso de adaptar los parámetros de una red una vez esta ya ha sido entrenada.
- *Test-time training*: Capacidad de los modelos de aprender (optimizar o hacer búsqueda temporal) luego de ya haber sido "entrenados" (i.e. durante la fase de inferencia), pudiendo ajustarse a los ejemplos de una tarea nueva para resolverla momentáneamente. 
- *Few-shot learning*: aprendizaje con pocos casos.


== Gradient-Based Program Synthesis with Neurally Interpreted Languages
#notat[Fuente][
  Contenido estudiado de _"Gradient-Based Program Synthesis with Neurally Interpreted Languages"_ de M. V. Macfarlane et al. (2026).
  #fuente_link("https://arxiv.org/abs/2604.18907", "arXiv:2604.18907")
]

Introducen el concepto de *Latent Adaptation Networks (LANs)*, que son redes con encoder y decoder que aprenden un espacio latente para representar el espacio de modelos (o programas). Una característica esencial es que en test-time se busca en el espacio latente para adaptarse y mejorar los resultados. 

Los autores presentan la arquitectura *Neural Language Interpreter (NLI)* que justamente es del tipo LAN, pero a diferencia del paper anterior, este aprovechará tokens para construir el programa en el espacio latente (y no representarlo como un único vector), de modo que se tenga mayor poder de generalización. Además, esta característica permite que el modelo pueda resolver problemas más difíciles (que requieren más tokens) que los que se le presentaron durante el entrenamiento.

=== Formalización

Se formaliza la tarea como un *program induction*. Dado un programa $p$ que genera los pares $S = {(x_i, y_i)}_(i=1)^n$ (es decir, $p(x_i) = y_i$), buscamos un modelo $M$ que prediga con $M(S, x_(n+1))$, para un nuevo input $x_(n+1)$, el valor de $p(x_(n+1))$. Se denotará con $cal(P)$ el espacio de posibles programas y se definen distribuciones $P_"train"$ y $P_"test"$ para entrenar y testear, respectivamente, la arquitectura, de modo que se pueda verificar su generalización.

=== Inferencia Discreta Secuencial

NLI aprende, de los pares input-output, un lenguaje de programación discreto (una especie de propio DSL, que llamaremos *codebook*) y "simbólico" (_symbolic-like_, no definido por humanos) para representar programas como secuencias de tokens (de longitud variable) que son ejecutadas por un ejecutor neuronal _diferenciable_, que también aprendió. (¡Importa mucho que sea diferenciable para la optimización que se realizará!) 

==== Objetivo de Entrenamiento

Para aprender el espacio latente con el que representar problemas, se usa una arquitectura encoder-decoder.
- El encoder, *inductor de programa* $q_phi.alt$, infiere una representación latente de programas desde unos pares input-outputs.
- El decoder, *interpretador neuronal* $p_theta$, ejecuta los programas del espacio latente para predecir outputs dado un input.

Durante el entrenamiento también se usa la estrategia de _leave-one-out_ (LOO) sobre _mini-batches_ de tamaño $B$, donde cada especificación contiene $m$ pares input-output. Así, $q_phi.alt$ induce un espacio latente usando $m-1$ pares y el error de predicción se calcula con aquel par dejado fuera. Definimos, para la $b$-ésima especificación y el $i$-ésimo par, $SSS_(b,i) := SSS_b without {(x_(b,i), y_(b,i))}$. Para cada $SSS_(b,i)$ buscamos maximizar la verosimilitud de predecir $y_(b,i)$ a partir de $x_(b,i)$, mientras se regulariza para reutilizar tokens. Así, la función de pérdida a minimizar es
$
  cal(L)(phi.alt, theta; SSS) = 1/B sum_(b=1)^B (1/m sum_(i=1)^m cal(L)_"recon" (phi.alt, theta; x_(b,i), y_(b,i), SSS_(b,i)) + lambda_"reg" dot cal(L)_"reg" (phi.alt; SSS_b))
$

donde
- $cal(L)_"recon"$ es la *pérdida de reconstrucción*: asegura que el programa sea lo suficientemente expresivo. $ cal(L)_"recon" (phi.alt, theta; x, y, S) := -log p_theta (y | x, q_phi.alt (S)). $
- $cal(L)_"reg"$ es la *pérdida de regularización del encoder*: motiva la reutilización de tokens ya descubiertos en el vocabulario de tamaño $K$ (¡esto motiva la composicionalidad!). $ cal(L)_"reg" (phi.alt; SSS) := sum_(k=1)^K sum_(j = 1)^T [1 - exp(sum_(b=1)^B sum_(i=1)^m log(1 - q_phi.alt^((k,j)) (SSS_(b,i))))] $
  - $N$: número de posiciones de tokens en el programa.
  - $q_phi.alt^((k,j)) (SSS_(b,i))$: probabilidad asignada al token $k$ en la posición $j$ por el encoder.
  El $1 - exp$ consiste en la probabilidad de que el token sea usado al menos una vez en el batch. 


==== El Inductor $q_phia$

El inductor $q_phia$ (encoder) se encarga de recibir un elemento de $S$ (un par $(x, y)$) y mapearlo a $(Delta^(K-1))^T$, donde
$
  Delta^(K-1) := {x in RR^K: x_i >= 0, sum_(i=1)^K x_i = 1}
$
es el símplex, que consiste en todos aquellos vectores $x in RR^K$ cuyas entradas determinan una distribución de probabilidad. Es decir, $q_phia$ recibe un par $(x, y)$ y lo mapea en un
$
  z = (z_1, ..., z_T), qquad "donde cada" z_t in Delta^(K-1).
$
Aquí, cada $z$ es una distribución sobre el _codebook_ que ha aprendido el algoritmo.

#figure(caption: [Gráfico del símplex $Delta^2$.])[
  #image("../figures/simplex.svg")
]

#nota[En el paper además consideran un *skip token* que permite tener programas de largo variable aun teniendo $T$ fijo.]

En el entrenamiento, 
$
  z_t = "Softmax"((f_phia (macron(e)_t) + g_t) slash tau_e),
$
definiendo
$
  macron(e)_t = 1/abs(S) sum_i e_t^((i))
$
y $"Softmax"$ es la Gumbel-Softmax con temperatura $tau_e$ en annealing.


==== El  Intérprete $p_theta$

Para entender cómo funciona el intérprete, es necesaria la siguietne definición.

#deft[Embedder][
  Un *embedder* es un algoritmo que transforma datos u objetos discretos a vectores, llamados *embeddings*, y que puede agrupar en una matriz llamada *embedding matrix*.
]



El intérprete $p_theta$ contiene en $theta$ sus parámetros:
- El *code embedder* $E_v$ (una _embedding matrix_): en su fila $k$ contiende al vector del token número $k$ del _codebook_. Esto permite que la operación $E_v^T z_t$ traduzca la instrucción del paso $t$ a un vector que la red puede leer. Esto es, $E_v^T z_t$ "busca en el codebook".
- El *input-output embedder* $E_("io")$ (otra _embedding matrix_):  en su fila $k$ contiene al vector que representa el valor $k$ que puede tomar un elemento de los datos (input y output)
- La red de ejecución $d$:

Por lo tanto, el intérprete aprende dos matrices de embedding.

La idea del intérprete es que empieza con un estado inicial $s_0 = "Embed"(x)$ (el input mismo) y con $pi_0 = "OneHot"(x)$ y en cada paso $t$ actualiza $pi_t$ de modo que, de manera muy resumida,
$
  s_t = E_"io"^T pi_t.
$
Es decir, en cada paso actualiza el estado actual del programa.

==== Búsqueda en test-time

El objetivo de esta parte es optimizar los embeddings continuos $e$, no los tokens. Esto es, obtener
$
  e^* = arg max_e EE_(g,h) [sum_((x_j,y_j) in S) log p_theta (y_j | x_j, z(e, tau_e, g), tau_d, h)].
$
Para esto, se parte con temperaturas $tau_e, tau_d$ altas para explorar y se van bajando conforme avanza el tiempo para converger a embeddings discretos.


==== Resultados

#pagebreak()
==== Pseudocódigo del Entrenamiento
```
----------------------------
Inicializar φ, θ al azar

Repetir S veces:                     # S = número de pasos de entrenamiento
    Actualizar τ_e, τ_d              # annealing: τ_e 8 → 0.5, τ_d 2 → 0.5
    Tomar un batch de B tareas (m pares cada una)

    Para cada tarea b del batch:
        Para cada par i:                  # LOO
            # Inductor (encoder)
            Para cada par j ≠ i:
                h_φ(x_j, y_j) → (e_1^(j), ..., e_T^(j))
            Promediar por posición → (ē_1, ..., ē_T)
            Para t = 1, ..., T:
                l_t ← f_φ(ē_t)                     # logits sobre K tokens
                z_t ← Softmax((l_t + g_t) / τ_e)       # g_t ~ Gumbel(0,1)

            # Intérprete (decoder): lee el programa token a token
            s_0 ← Embed(x_i),  π_0 ← OneHot(x_i)
            Para t = 1, ..., T:
                n_t ← d(s_{t-1}, E_vᵀ z_t)
                π̃_t ← Softmax((n_t + h_t) / τ_d)       # h_t ~ Gumbel(0,1)
                π_t ← z_{t,skip} · π_{t-1} + (1 − z_{t,skip}) · π̃_t
                s_t ← E_ioᵀ π_t

            NLL_{b,i} = −log π_T(y_i)

    # Regularizador de reuso: nº esperado de tokens distintos en el batch
    L_reg = Σ_k Σ_t [ 1 − Π_{b,i} (1 − q_φ^(k,t)(S_{b,i})) ]

    L_total = (1/B) Σ_b (1/m) Σ_i NLL_{b,i} + λ_reg · L_reg
    φ ← φ − η ∇_φ L_total                 # una sola actualización
    θ ← θ − η ∇_θ L_total
----------------------------
```


#pagebreak()

=== Preguntas
- ¿*Test-time* y *tiempo de inferencia* son lo mismo? En este contexto sí. Van contrarios al *training-time*.
- ¿Qué es una *ablación*? Es un experimento del modelo, donde se remueve un componente de él para entender qué tan necesario es. 
- ¿Aquí no se usa un muestreo desde una Normal con media $mu$ y varianza $Sigma$?
- ¿$SSS_B subset S$? ¡Sí!
- ¿Qué es un *batch*? Es una porción al azar de datos.

=== Glosario
- *Transformer*: Arquitectura de red neuronal diseñada específicamente para procesar y generar datos secuenciales, como el lenguaje natural. Consisten en un _encoder_ (que convierte la entrada en una matriz) y en un _decoder_ (que genera una secuencia final en base a lo que generó el encoder y escogiendo aquella con mayor probabilidad de aparición).

== El Aporte de la Discretización

Aquí discutimos el avance que se realiza desde el LPN al NLI (de, prácticamente, los mismos autores).

Primero, un resumen de las arquitecturas LPN y NLI:

#figure(
  caption: [Relación entre el funcionamiento de entrenamiento y producción de LPN y NLI]
)[
  #image("../figures/fases_nli_lpn.svg", width: 120%)
]

El LPN consistía en un encoder y en un decoder. Cuando un ejemplo nuevo $x_(n+1)$ se codificaba, luego se optimizaba por ascenso de gradiente el resultado para mejorarlo (esto dependía del parámetro $theta$ del decoder, por lo que era un proceso determinista una vez ya se había entrenado el $theta$).

La limitación del LPN era que tenía capacidades limitadas para la generalización composicional. En particular, al componer dos acciones, LPN falla parcialmente, pero al componer tres o más acciones, ya no se logran resultados complacientes. Ante este problema de la composicionalidad, los autores propusieron explorar representaciones latentes discretas para mejorar la generalización composicional, que es lo que justamente hacen en NLI.

En NLI se tiene un encoder que produce tokens discretos usando la Gumbel-Softmax (esto permite extraer muestras "discretas", pero poder seguir realizando _backpropagation_) a la cual se le bajando la temperatura $tau$ con el tiempo. Además, el decoder que usan es especial, pues va leyendo token a token y actualiza un *estado interno* $s_t$ a partir de ellos. Esto permite la *generalización de longitud*: no importa qué tan largo sea el programa, si se sabe interpretar los tokens, cualquier largo finito es ejecutable. 

#nota[NLI también usa ascenso de gradiente luego de que el encoder genere los tokens, sólo que en la Gumbel-Softmax.]

En los resultados, se muestra que efectivamente, tanto la discretización como la presencia del estado interno del intérprete permite muchos mejores resultados que LPN.


=== Hipótesis

La discretización en problemas donde se busca la composicionalidad pareciera ser una mejora natural, pues el pensamiento humano funciona esencialmente en "bloques", en el sentido de que razonamos secuencialmente y en base a conexiones (y muy importante, _composiciones_) entre _ideas_ aislada, algo que justamente se puede simbolizar en los computadores por medio de representaciones discretas. Por el contrario, los espacios latentes continuos son más difíciles de relacionar de esta manera con el pensamiento humano. 


