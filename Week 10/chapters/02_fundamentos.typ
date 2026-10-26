#import "/math_functions.typ": *
#import "/bloques.typ": *

#frase[Seis ideas bastan para leer el resto: qué es un espacio latente, cuánta información cabe en un código, por qué la regresión promedia, qué es un modelo del mundo, cómo se aprende sin etiquetas y cómo se lee un experimento.]

== Espacio latente

Casi todos los modelos de este capítulo tienen la misma forma (@fig:autoencoder). Un *codificador* (_encoder_) toma una observación $x$ (una imagen, un estado de un juego) y la resume en un vector $z$, llamado *latente*. Un *decodificador* (_decoder_) intenta reconstruir $x$ a partir de $z$, o bien un *predictor* intenta adivinar el $z$ del instante siguiente. Como $z$ es mucho más pequeño que $x$, el codificador está obligado a quedarse con lo importante. A esa restricción se le llama *cuello de botella*.

#fig("f03_autoencoder.svg", flota: false)[Un autoencoder. La pregunta de este capítulo es qué ocurre cuando el latente $z$ deja de ser un vector cualquiera de $RR^d$ y pasa a ser uno de $K$ códigos.] <fig:autoencoder>

El VAE #ct(<kingma2014>) agrega una capa probabilística: el codificador entrega una distribución $q_phi (z|x)$ en vez de un punto, y una pérdida (la divergencia KL con una distribución _a priori_ $p(z)$) evita que esa distribución se vuelva arbitrariamente precisa. Lo vimos en detalle en los apuntes. Aquí basta recordar que el KL actúa como un "impuesto" sobre la información que el latente transporta. Volveremos a esto al hablar de colapso posterior (capítulo VII).

== Información: cuánto cabe en un código

#idea[Bits y entropía][
  Un *bit* es la información necesaria para distinguir entre dos alternativas igual de probables. Para distinguir entre $K$ alternativas igual de probables hacen falta $log_2 K$ bits: un diccionario de 512 códigos lleva como máximo 9 bits por código.

  Si las alternativas no son igual de probables, la información promedio es la *entropía*,
  $ H = - sum_(k=1)^K p_k log_2 p_k, $
  que vale $log_2 K$ cuando todos los códigos se usan por igual y $0$ cuando siempre se usa el mismo. La *perplejidad* $2^H$ se interpreta como el "número efectivo de códigos usados". Un diccionario de 512 códigos con perplejidad 20 se comporta como si tuviera solo 20.
]

¿Y un vector continuo? En teoría, un solo número real puede codificar infinitos bits (basta con escribirlos en sus decimales). En la práctica, el ruido lo impide: si cada coordenada se transmite con un error de tamaño $sigma$, solo se pueden distinguir de forma confiable unos $A slash sigma$ niveles en un rango de amplitud $A$. Shannon #ct(<shannon1948>) formalizó esto: la capacidad de un canal con ruido es finita y crece con el logaritmo de la razón entre señal y ruido.

Esto importa por una razón concreta. Cuando un paper compara un latente discreto con uno continuo "del mismo tamaño", casi nunca compara la misma cantidad de información. El discreto tiene un techo explícito ($log_2 K$ bits por código) y el continuo tiene un techo implícito, que depende del ruido, la precisión numérica y la regularización. Es la pieza #pieza(1) del paquete, y es el primer confusor que hay que controlar.

== Regresión frente a clasificación

Esta es quizás la idea más importante del capítulo, porque explica de un golpe por qué las predicciones continuas "se ven borrosas" y por qué muchos modelos del mundo pasaron a predecir categorías.

Supongamos que el estado siguiente $Y$ es aleatorio: con probabilidad $1 slash 2$ el agente gira a la izquierda (estado $A$) y con probabilidad $1 slash 2$ gira a la derecha (estado $B$). Un predictor entrenado con *error cuadrático medio* (MSE) busca la constante $c$ que minimiza
$ bb(E) [(Y - c)^2] quad arrow.r.double quad c^* = bb(E)[Y] = (A + B) / 2. $
Es decir, el predictor óptimo entrega el *promedio* de los futuros posibles. Si $A$ y $B$ son dos imágenes, el promedio es una superposición borrosa de ambas. Si son dos posiciones, es un punto intermedio que quizás es una pared. En ningún caso es un futuro que pueda ocurrir (@fig:mse-ce, izquierda).

Un predictor entrenado con *entropía cruzada* (CE) no entrega un punto, sino una distribución $hat(p)$ sobre categorías, y minimiza
$ bb(E) [- log hat(p)(Y)] quad arrow.r.double quad hat(p)^* = p, $
o sea, la distribución verdadera completa. Si los futuros son $A$ y $B$ con probabilidad $1 slash 2$ cada uno, aprende exactamente eso (@fig:mse-ce, derecha). Después se puede muestrear un futuro concreto, o planificar considerando ambos.

#fig("f04_mse_vs_ce.svg")[El mismo problema, dos pérdidas. Con MSE, el óptimo es el promedio de los futuros; con entropía cruzada, el óptimo es la distribución completa.] <fig:mse-ce>

Esto no tiene nada que ver con que el *estado* sea discreto: tiene que ver con lo que el predictor está autorizado a entregar. Un predictor de vectores continuos también puede entregar una distribución con varios modos (una mezcla de gaussianas, o un modelo de difusión, como veremos en el capítulo IV). La entropía cruzada sobre categorías es simplemente la forma más barata de conseguirlo. Por eso separamos dos piezas: la #pieza(3) (la pérdida) y la #pieza(4) (poder elegir entre modos).

#pensar[Si $A$ ocurre con probabilidad $0,9$ y $B$ con $0,1$, ¿el predictor MSE entrega un futuro real? ¿Qué entrega?]

== Aprendizaje por refuerzo y modelos del mundo

#idea[Aprendizaje por refuerzo en un párrafo][
  Un *agente* observa el estado del *entorno*, elige una *acción*, y recibe una *recompensa* y un nuevo estado. Su objetivo es aprender una *política* (una regla para elegir acciones) que maximice la suma de recompensas futuras, llamada *retorno*. Los métodos _sin modelo_ (_model-free_) aprenden la política directamente de la experiencia. Los métodos _basados en modelo_ (_model-based_) aprenden además un *modelo del mundo*: un simulador aprendido que predice qué estado y qué recompensa vendrán después de cada acción.
]

Un modelo del mundo permite *imaginar*: partir del estado actual, aplicar acciones en la cabeza y ver qué pasaría, sin tocar el entorno real (@fig:modelo-mundo). A una secuencia imaginada se le llama *rollout*. Dreamer, por ejemplo, entrena su política casi exclusivamente con rollouts imaginados en su espacio latente.

#fig("f05_modelo_mundo.svg")[Arriba, el ciclo agente-entorno. Abajo, un rollout imaginado: cada estado predicho $hat(z)_t$ se usa como entrada para predecir el siguiente, así que los errores se arrastran y crecen.] <fig:modelo-mundo>

El detalle crucial es que en un rollout *la salida de cada paso es la entrada del siguiente*. Un error pequeño en $hat(z)_1$ se convierte en la entrada de $hat(z)_2$, que agrega su propio error, y así sucesivamente. Este fenómeno, el *error compuesto*, es la razón por la que la pieza #pieza(5) (redondeo) importa tanto en modelos del mundo, y es el tema del capítulo V.

== Aprender sin etiquetas

#idea[Aprendizaje autosupervisado][
  En el aprendizaje *autosupervisado* el modelo se inventa su propia tarea a partir de datos sin etiquetar. Hay dos familias principales.
  - *Contrastiva:* se generan dos versiones de una misma imagen (por ejemplo, recortes distintos) y se entrena para que sus representaciones queden cerca entre sí y lejos de las de otras imágenes.
  - *Predictiva:* se oculta una parte de la entrada y se entrena para predecir la parte oculta, ya sea en píxeles (MAE) o en el espacio de representaciones (JEPA).
]

El riesgo central de la familia predictiva en espacio de representaciones es una solución trampa: si el codificador entrega *el mismo vector para todo*, predecir la representación de la parte oculta es trivial y la pérdida vale cero. A esto se le llama *colapso de representaciones*. BYOL #ct(<grill2020>) e I-JEPA #ct(<assran2023>) lo evitan con dos trucos. El primero es que el objetivo lo calcula un *segundo codificador* que no se entrena por gradiente, sino que se actualiza como un promedio móvil exponencial (_EMA_) del primero. El segundo es que el gradiente no fluye hacia ese codificador objetivo (_stop-gradient_). Así, el objetivo cambia lentamente y el modelo no puede "moverlo" hacia la solución trivial. Volveremos a esto en los capítulos VII y VIII, porque el colapso es uno de los costos que la discretización transforma.

== Cómo leer un resultado experimental

#idea[Vocabulario experimental][
  - *Baseline:* el método con el que se compara.
  - *Ablación:* quitar o cambiar una sola pieza del método y medir cuánto empeora. Es la herramienta principal para atribuir mejoras a piezas.
  - *Benchmark:* conjunto estándar de tareas. Atari son 55 videojuegos; DMControl y Meta-World son tareas de control de robots simulados; Minigrid son laberintos en grilla.
  - *Puntaje normalizado por humanos (Atari):* $("agente" - "azar") slash ("humano" - "azar")$. Vale 1 si el agente juega como un jugador humano de referencia.
  - *FID* #ct(<heusel2017>): distancia entre la distribución de imágenes generadas y la de imágenes reales, medida con las características de una red preentrenada. *Menor es mejor*. El *rFID* aplica la misma medida a imágenes reconstruidas por un autoencoder: mide cuánto se pierde al comprimir.
  - *Uso del diccionario:* fracción de los códigos que efectivamente se usan, o su perplejidad.
]

Un consejo general, que el .epub ya daba y que aquí se vuelve operativo: ante cada resultado, preguntarse *qué cambió además de la discretización*. Si la respuesta es "varias cosas", el resultado es evidencia de que el paquete ayuda, no de que la discreción ayude.

#llevamos[
  - Un código de $K$ entradas lleva como máximo $log_2 K$ bits; un vector continuo tiene un techo implícito que depende del ruido. Comparar "a igual tamaño" no es comparar a igual información.
  - Con MSE, el predictor óptimo es el *promedio* de los futuros; con entropía cruzada, es la *distribución*. Esto es independiente de que el estado sea discreto.
  - En un rollout, la salida de cada paso es la entrada del siguiente, así que los errores se arrastran.
  - Los métodos predictivos autosupervisados pueden colapsar a una constante; EMA y _stop-gradient_ son las defensas estándar.
]
