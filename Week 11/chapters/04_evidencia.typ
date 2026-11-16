#import "/math_functions.typ": *
#import "/bloques.typ": *

#frase[La idea de que discretizar ayuda nació en los modelos del mundo para aprendizaje por refuerzo; los experimentos más cuidadosos muestran que la ventaja es real pero condicional (a la capacidad, a la estocasticidad, a la geometría), y hay dominios donde lo continuo gana con claridad.]

Este capítulo responde a P2. Recorre los resultados que construyeron la idea de que "lo discreto es mejor", en orden aproximadamente cronológico, y termina con los casos donde lo continuo gana. Cada modelo se presenta con el mismo formato: qué hace, qué discretiza, qué mejora y qué empeora, y a qué pieza del paquete se puede atribuir el efecto.

== La línea de Dreamer: de gaussiano a categórico

=== PlaNet y el modelo de estado recurrente

#notat[Fuente][
  _"Learning Latent Dynamics for Planning from Pixels"_ de D. Hafner et al. (2019).
  #fuente_link("https://arxiv.org/abs/1811.04551", "arXiv:1811.04551")
]

PlaNet #ct(<hafner2019>) aprende un modelo del mundo a partir de imágenes y planifica dentro de él. Su pieza central, que heredan todos los Dreamer, es el *modelo de estado recurrente* (RSSM, @fig:rssm). El estado del mundo en el instante $t$ tiene dos partes:
- una parte *determinista* $h_t$, que es la memoria de una red recurrente y se actualiza con el estado y la acción anteriores;
- una parte *estocástica* $z_t$, que se muestrea de una distribución que depende de $h_t$ y que absorbe lo impredecible.

Durante el entrenamiento, $z_t$ se calcula mirando la imagen actual (la _posterior_). Durante la imaginación no hay imagen, así que se usa una predicción de $z_t$ hecha solo desde $h_t$ (la _prior_). El entrenamiento empuja la prior hacia la posterior con una pérdida KL, igual que en un VAE.

PlaNet mostró que ambas partes son necesarias: un modelo puramente determinista y uno puramente estocástico planifican peor que el RSSM. Es un primer dato para la pregunta A1. *La memoria continua y la elección aleatoria cumplen funciones distintas*, y el diseño que funciona tiene las dos.

#fig("f10_rssm.svg")[El modelo de estado recurrente (RSSM). Arriba, la cadena en el tiempo: $h$ es la memoria determinista y $z$ la parte estocástica. Abajo, lo único que cambió de PlaNet a DreamerV2: $z$ pasó de ser una gaussiana a ser 32 variables categóricas de 32 clases.] <fig:rssm>

=== DreamerV2: el cambio a categóricas

#notat[Fuente][
  _"Mastering Atari with Discrete World Models"_ de D. Hafner et al. (2021).
  #fuente_link("https://arxiv.org/abs/2010.02193", "arXiv:2010.02193")
]

DreamerV2 #ct(<hafner2021>) fue el primer agente que alcanzó nivel humano en Atari (55 juegos, 200 millones de cuadros) aprendiendo su comportamiento *solo dentro de su modelo del mundo*, con una sola GPU. Respecto de su antecesor, hizo pocos cambios. El más visible fue reemplazar la $z_t$ gaussiana por un vector de 32 variables categóricas de 32 clases, entrenadas con el estimador _straight-through_. El otro fue el *KL balancing*: la pérdida KL se reparte de modo que la prior se mueva hacia la posterior más rápido (con peso 0,8) que la posterior hacia la prior (con peso 0,2). Así se evita que las representaciones se regularicen hacia una prior que todavía es mala.

La ablación es clara: las variables categóricas superan a las gaussianas en 42 juegos, pierden en 8 y empatan en 5 (empate significa una diferencia menor al 5 %) #est. En la mediana del puntaje normalizado por humanos, el agente completo obtiene 1,64 y la versión sin latentes discretos, 1,08. El KL balancing gana en 44 juegos, pierde en 6 y empata en 5.

Lo más valioso para nosotros es lo que los autores dicen *no saber*. Escriben que desconocen por qué las categóricas ayudan, y proponen cuatro hipótesis para investigar:
+ Una prior categórica puede ajustar exactamente la "posterior agregada" (el promedio de las posteriores de todas las imágenes), porque una mezcla de categóricas sigue siendo categórica. Una gaussiana no puede imitar una mezcla de gaussianas. Esto sería la pieza #pieza(4), *elegir entre modos*.
+ La esparsidad: el latente es un vector binario de 1024 posiciones con solo 32 unos, lo que podría ayudar a generalizar. Esto sería la pieza #pieza(2), *geometría*.
+ Las categóricas con _straight-through_ podrían ser *más fáciles de optimizar*, porque el estimador ignora un término que de otro modo escalaría el gradiente y podría hacerlo explotar o desvanecerse. Esto no es una ventaja de la representación, sino del estimador.
+ Las categóricas podrían ser un mejor sesgo inductivo para los aspectos *no suaves* de Atari: entrar a una habitación nueva, o que un objeto desaparezca al recogerlo. El mundo de Atari tiene "saltos", y una representación con saltos los modela mejor.

#pensar[¿Qué experimento separaría la hipótesis 1 de la 2? Pista: una de ellas debería desaparecer en un juego sin azar.]

La ablación de DreamerV2 cambia a la vez la discreción, la esparsidad, el estimador del gradiente y la capacidad de modelar varios modos. Por eso no permite elegir entre las cuatro hipótesis. Es un ejemplo perfecto de evidencia de que *el paquete* ayuda.

=== DreamerV3: discretizar también la pérdida

DreamerV3 #ct(<hafner2025>) generalizó Dreamer a más de 150 tareas con un único conjunto de hiperparámetros. Conservó las categóricas y les agregó ajustes que conviene conocer, porque cada uno ataca un problema concreto:
- *Unimix*: cada distribución categórica se mezcla con un 1 % de distribución uniforme. Así ninguna probabilidad llega a ser exactamente cero, y el KL no explota cuando la posterior elige una clase que la prior consideraba imposible.
- *Free bits*: la pérdida KL no se penaliza por debajo de 1 nat. Esto impide que el modelo "apague" el latente para ahorrarse el KL, que es una forma de colapso posterior (capítulo VII).
- *Symlog y two-hot*: las recompensas y los valores se predicen por *clasificación* sobre 255 intervalos, con objetivos _two-hot_, en vez de por regresión. Es la pieza #pieza(3) aplicada a la pérdida, sin tocar el estado.

#ficha(
  discretiza: [La parte estocástica del estado, $z_t$ (32 × 32 categóricas). En V3, además, el objetivo de recompensas y valores (two-hot).],
  mejora: [Puntaje en Atari: 42 de 55 juegos mejoran respecto de $z_t$ gaussiana #est.],
  empeora: [Necesita _straight-through_, unimix y free bits para entrenar de forma estable.],
  pieza: [No identificada. Los autores proponen #pieza(4), #pieza(2), el estimador y los "saltos" del mundo, sin poder separarlos.],
)

== El experimento más limpio: Meyer et al.

#notat[Fuente][
  _"Harnessing Discrete Representations for Continual Reinforcement Learning"_ de E. Meyer, A. White y M. C. Machado (2024).
  #fuente_link("https://arxiv.org/abs/2312.01203", "arXiv:2312.01203")
]

Si hubiera que leer un solo paper sobre nuestra pregunta, sería este #ct(<meyer2024>). Ya está en la carpeta `Additional` del repositorio. Su valor no está en un gran resultado, sino en el diseño: cambia *una cosa a la vez*.

#idea[Minigrid y aprendizaje continuo][
  *Minigrid* es una colección de laberintos en grilla. El agente (un triángulo rojo) ve una imagen pequeña del laberinto y puede girar, avanzar y, en algunas versiones, recoger una llave y abrir una puerta. En el *aprendizaje por refuerzo continuo* (_continual RL_), el entorno cambia cada cierto tiempo (aquí, la posición de las paredes y objetos), y lo que importa es cuán rápido se *readapta* el agente, no cuán bien juega en un entorno fijo.
]

=== El diseño

El modelo del mundo se divide en dos partes: un *codificador* que transforma la imagen en un latente, y un *modelo de transición* (una red pequeña, fija) que predice el latente siguiente a partir del actual y de la acción. Los autores cambian solo el codificador y comparan tres tipos de latente (@fig:codificaciones):
- *continuo denso*, de un autoencoder común;
- *continuo esparso*, del mismo autoencoder con una activación (FTA, #ctp(<pan2021>)) que deja casi todas las coordenadas en cero;
- *discreto multi-one-hot*, de un VQ-VAE cuyos códigos se entregan como varios vectores _one-hot_.

#fig("f11_codificaciones.svg")[El mismo estado de un laberinto, representado de cuatro formas. Las dos últimas salen del mismo VQ-VAE y llevan exactamente la misma información, pero una la entrega como índices _one-hot_ y la otra como los vectores del diccionario.] <fig:codificaciones>

Los entornos tienen un 10 % de probabilidad de que la acción elegida se reemplace por otra al azar, así que el futuro es estocástico. Para medir la calidad del modelo no se compara un estado predicho con el real (puede haber varios futuros válidos), sino la *distribución* de estados que el modelo genera en rollouts de 30 pasos con la que genera el entorno real, mediante una divergencia KL.

=== Los resultados

*Primero*, el modelo discreto es más preciso, y la diferencia crece con la complejidad del entorno. En el laberinto vacío no hay diferencia. En los laberintos con una abertura en la pared o con llave y puerta, los modelos continuos casi nunca predicen que el agente cruce la abertura o recoja la llave. Son las transiciones *raras* en los datos de entrenamiento #est.

*Segundo*, la ventaja depende de la capacidad. Al agrandar el modelo de transición, las curvas de todos los métodos se juntan: con un modelo suficientemente grande, la representación da igual (@fig:capacidad) #est. Lo discreto ayuda cuando *el mundo es más grande que el modelo*.

#fig("f12_capacidad.svg")[Esquema cualitativo del resultado de escalamiento de Meyer et al.: la ventaja de la representación discreta aparece solo cuando el modelo del mundo tiene poca capacidad en relación con la complejidad del entorno.] <fig:capacidad>

*Tercero*, y es el resultado clave: los autores toman el *mismo* VQ-VAE y entregan sus códigos de dos formas: como índices _one-hot_ o como los vectores del diccionario ("cuantizados"). Ambas representaciones son discretas y llevan exactamente la misma información. Aun así, la versión _one-hot_ es *mucho* mejor. Su conclusión es que el éxito se debe a la naturaleza *binaria y esparsa* de la representación, y no a que sea discreta #est.

Hay un matiz que conviene notar. En ese experimento, el modelo sobre vectores se entrenó con error cuadrático y el modelo _one-hot_ con entropía cruzada, así que también cambió la pieza #pieza(3). Los autores reportan en una nota que entrenar el modelo discreto con error cuadrático "hizo poca diferencia", lo que reduce la preocupación, pero no la elimina.

*Cuarto*, en aprendizaje continuo, donde el laberinto se reordena cada 40 000 pasos (o cada 100 000 en el de llave y puerta), la recompensa promedio por configuración es:

#align(center)[
  #table(
    columns: 3,
    stroke: none,
    inset: (x: 8pt, y: 3pt),
    align: (left, center, center),
    table.hline(stroke: 0.6pt),
    table.header([*Latente*], [*Abertura en la pared*], [*Llave y puerta*]),
    table.hline(stroke: 0.4pt),
    [De extremo a extremo (sin autoencoder)], [28 ± 5], [14 ± 2],
    [Continuo denso], [382 ± 33], [866 ± 94],
    [Continuo esparso (FTA)], [574 ± 57], [1033 ± 130],
    [Discreto (VQ-VAE, _one-hot_)], [*674 ± 21*], [*1324 ± 64*],
    table.hline(stroke: 0.6pt),
  )
]

El orden es discreto, después esparso continuo y después denso continuo #est. Cuando el entorno cambia, el error de reconstrucción del VQ-VAE sube mucho menos que el de los demás: su representación *generaliza mejor a la configuración nueva*.

Un detalle honesto: en el aprendizaje por refuerzo episódico, sin cambios de entorno, el VQ-VAE fue al principio el *peor*, porque su autoencoder aprende más lento. Cuando se espera a que todos los autoencoders estén igual de entrenados, el VQ-VAE y el esparso convergen con dos a tres veces menos actualizaciones de la política que el denso. La ventaja discreta tiene un costo inicial.

#ficha(
  discretiza: [Los valores del latente (VQ-VAE), entregados como multi-one-hot.],
  mejora: [Modelos del mundo más precisos con poca capacidad, sobre todo en transiciones raras; readaptación más rápida en aprendizaje continuo #est.],
  empeora: [Aprendizaje inicial más lento. La ventaja desaparece con modelos grandes.],
  pieza: [#pieza(2) (geometría binaria y esparsa: el mismo código como vector rinde mucho peor) y #pieza(1) (la ventaja solo aparece con poca capacidad).],
)

== Control continuo: DCWM

#notat[Fuente][
  _"Discrete Codebook World Models for Continuous Control"_ de A. Scannell et al. (2025).
  #fuente_link("https://arxiv.org/abs/2503.00653", "arXiv:2503.00653")
]

El resultado de Meyer es en laberintos, un mundo naturalmente discreto. ¿Qué pasa en control continuo, donde el estado es una lista de ángulos y velocidades?

#idea[Control predictivo y MPPI][
  En el *control predictivo por modelo* (MPC), en cada instante el agente simula en su modelo del mundo muchas secuencias de acciones posibles, evalúa cuánta recompensa daría cada una, ejecuta *solo la primera acción* de la mejor y repite todo en el instante siguiente. *MPPI* es una forma de hacer esa búsqueda: muestrea secuencias al azar, las promedia ponderándolas por su recompensa y vuelve a muestrear alrededor del promedio. *TD-MPC2* #ct(<hansen2024>) es un modelo del mundo de referencia para control continuo: no reconstruye imágenes, predice su propio latente siguiente con error cuadrático y planifica con MPPI.
]

DCWM #ct(<scannell2025>) es, en esencia, un TD-MPC2 con el latente discretizado. El codificador usa FSQ, con niveles pequeños (5 × 3 = 15 códigos por símbolo). El modelo de transición *clasifica* el código siguiente con entropía cruzada, en vez de regresionar un vector. No reconstruye observaciones. Se evalúa en 30 tareas de DMControl (incluidos humanoides y perros simulados), 45 de Meta-World (manipulación con un brazo robótico) y 5 de MyoSuite (control de músculos), y es competitivo con TD-MPC2 y DreamerV3.

Lo más útil son sus ablaciones, porque *desarman el paquete* en parte:
- Los latentes discretos superan con claridad a los continuos en eficiencia de muestras #est.
- Un latente discreto *determinista* entrenado con MSE no alcanza al discreto estocástico entrenado con entropía cruzada. Si el discreto determinista se entrena por clasificación, mejora respecto del MSE. Los autores concluyen que parte de la ganancia viene de la *estocasticidad* (muestrear el código siguiente) y parte de la *clasificación* #est. Son las piezas #pieza(4) y #pieza(3), separadas.
- Los latentes continuos estocásticos (gaussianos o mezclas de gaussianas) ayudan a veces en DMControl, pero rinden mucho peor en Meta-World.
- Sobre la geometría: entregar los códigos como *vectores del diccionario* funciona mejor que como _one-hot_ o como etiquetas enteras. La etiqueta entera "no puede modelar la estructura ordinal multidimensional del diccionario", según los autores. El _one-hot_ alcanza una eficiencia parecida, pero entrena más lento y, usado dentro del modelo de transición, hace que el entrenamiento se estanque.

El contraste con Meyer es instructivo. En un laberinto, las posiciones de la llave o la puerta son *categorías sin orden*, y gana _one-hot_. En control continuo, los códigos de FSQ son niveles *ordenados* de ángulos y velocidades, y gana el vector, que conserva el orden. La pieza #pieza(2) no tiene un ganador universal: *gana la geometría que coincide con la del mundo*.

#ficha(
  discretiza: [Los valores del latente (FSQ), con transición por clasificación.],
  mejora: [Eficiencia de muestras frente a latentes continuos; competitivo con TD-MPC2 y DreamerV3.],
  empeora: [_One-hot_ y etiquetas enteras rinden peor que vectores; hay que elegir la codificación.],
  pieza: [#pieza(4) (estocasticidad) y #pieza(3) (clasificación), separadas por ablación; #pieza(2) a favor de vectores ordenados.],
)

== Ramificaciones: elegir en vez de promediar

Volvamos al ejemplo de la @fig:mse-ce: si el futuro puede ser $A$ o $B$, un predictor por regresión entrega su promedio. Dos trabajos atacan ese problema directamente, y los dos discretizan *la elección*, no el estado.

=== Stochastic MuZero

#idea[MCTS y MuZero][
  La *búsqueda en árbol de Monte Carlo* (MCTS) planifica construyendo un árbol de posibles jugadas: desde el estado actual prueba acciones, simula, evalúa y concentra la búsqueda en las ramas prometedoras. *MuZero* #ct(<schrittwieser2020>) hace MCTS dentro de un modelo aprendido: no conoce las reglas del juego, sino que aprende a predecir el siguiente estado latente, la recompensa y el valor. Su modelo es *determinista*, así que en juegos con azar no tiene cómo representar que una misma jugada puede llevar a resultados distintos.
]

Stochastic MuZero #ct(<antonoglou2022>) separa cada paso en dos. Primero, la acción del agente lleva a un *estado posterior* (_afterstate_): cómo queda el tablero antes de que actúe el azar. Después, el azar elige un *resultado*, que se representa con un *código discreto* aprendido con un codificador al estilo VQ-VAE. El árbol de búsqueda alterna nodos de decisión y nodos de azar, y en los nodos de azar se ramifica por cada código posible.

En 2048 y en backgammon, juegos con azar, alcanza o supera el estado del arte y supera claramente a MuZero. En Go, que no tiene azar, rinde igual que MuZero #est. Esta última observación es justamente la que pedía el recuadro anterior: *la ventaja aparece donde hay azar y desaparece donde no lo hay*. Es la firma de la pieza #pieza(4).

=== MoP-JEPA

#notat[Fuente][
  _"MoP-JEPA: Hard-Assigned Predictor Mixtures for Stochastic JEPA World Models"_ de Z. Song et al. (2026).
  #fuente_link("https://arxiv.org/abs/2607.05238", "arXiv:2607.05238")
]

MoP-JEPA #ct(<song2026>) lleva el mismo argumento a los modelos del mundo tipo JEPA (capítulo VIII). Parte de un diagnóstico: con un solo predictor entrenado por regresión, en una bifurcación el predictor óptimo entrega la media condicional de los estados siguientes posibles, que no corresponde a ninguno. Los autores llaman *colapso* a este fenómeno (volveremos sobre esta palabra en el capítulo VII). La solución es tener $K$ cabezas predictoras y asignar cada ejemplo de entrenamiento *solo a la cabeza que mejor lo predice* (asignación dura), con un enrutador que mira solo el contexto. Las cabezas terminan especializando, una por cada modo del futuro (@fig:promediar-elegir).

#fig("f13_promediar_elegir.svg")[En una bifurcación, un predictor entrenado con MSE apunta al promedio de los futuros, que no es un estado real. Con varias cabezas y asignación dura, cada cabeza se queda con un futuro.] <fig:promediar-elegir>

En laberintos de OGBench, planificar sobre los futuros que proponen las cabezas alcanza una tasa de éxito cercana a 0,85, frente a 0,02–0,09 de las variantes con una sola salida (según el resumen del paper) #est.

#pensar[¿Hace falta que el *estado* sea discreto para elegir entre futuros? En Stochastic MuZero y en MoP-JEPA, ¿qué es exactamente lo discreto?]

#ficha(
  discretiza: [La elección entre futuros (un código de azar, o qué cabeza usar). El estado sigue siendo continuo.],
  mejora: [Planificación en entornos estocásticos #est; sin efecto donde no hay azar (Go).],
  empeora: [Hay que fijar cuántos modos ($K$); el número de ramas crece con cada paso de azar.],
  pieza: [#pieza(4), de forma casi pura.],
)

== Robustez

#notat[Fuente][
  _"Discrete Representations Strengthen Vision Transformer Robustness"_ de C. Mao et al. (2022).
  #fuente_link("https://arxiv.org/abs/2111.10493", "arXiv:2111.10493")
]

#ctp(<mao2022>) agregan a la entrada de un _vision transformer_ (ViT), junto a los parches de píxeles habituales, *tokens discretos* producidos por un codificador VQ. La robustez mejora hasta en un 12 % en siete benchmarks de ImageNet con imágenes alteradas (ruido, desenfoque, estilos artísticos, objetos fuera de contexto), sin perder precisión en las imágenes limpias #est. La explicación que proponen es que los tokens discretos capturan la *forma* global y son insensibles a cambios pequeños de textura, porque un cambio pequeño no alcanza a mover un parche a otro código. Es la pieza #pieza(5), el redondeo, usada para ganar invarianza #sug.

== Dónde gana lo continuo

La evidencia anterior podría dejar la impresión de que discretizar siempre ayuda. Dos líneas de trabajo muestran lo contrario, y son tan informativas como las anteriores.

=== Generación de imágenes sin cuantización

#idea[Tokenizadores y pérdida de difusión][
  Los generadores de imágenes *autorregresivos* (como los modelos de lenguaje, pero con imágenes) trabajan sobre una secuencia de *tokens*: un *tokenizador* comprime la imagen en una grilla de latentes, y un transformer aprende a predecir cada token a partir de los anteriores. Si los tokens son discretos (VQ), la predicción es una clasificación con entropía cruzada. Si son continuos, hace falta otra forma de predecir una distribución. Una *pérdida de difusión* entrena una red pequeña para quitarle ruido a un token, condicionada en lo que dice el transformer. Al generar, se parte de ruido puro y se lo va limpiando hasta obtener un token: así se muestrea de una distribución continua que puede tener varios modos.
]

MAR #ct(<li2024>) compara directamente ambas opciones sobre ImageNet (@fig:mar). Hay dos resultados:
- *El tokenizador discreto pierde información.* El tokenizador VQ reconstruye peor que uno continuo de la misma resolución (rFID 5,87 frente a 1,43), y la generación lo arrastra: FID 7,82 frente a 3,50 #est. Es el costo de la pieza #pieza(1).
- *La discreción no es necesaria para modelar.* Con el *mismo* tokenizador VQ, predecir con pérdida de difusión da mejor FID (7,82) que predecir con entropía cruzada (8,79) #est. Lo que el modelo autorregresivo necesitaba era una pérdida que represente una distribución con varios modos (pieza #pieza(4)), y la entropía cruzada sobre códigos era solo una forma de conseguirla.

#fig("f14_mar.svg")[(a) El esquema clásico: el transformer clasifica cuál código viene, y el token es un vector del diccionario. (b) MAR: el transformer produce una condición, y una red pequeña de difusión genera un token continuo a partir de ella.] <fig:mar>

=== Acciones latentes en video real

#notat[Fuente][
  _"Learning Latent Action World Models In The Wild"_ de Q. Garrido et al. (2026).
  #fuente_link("https://arxiv.org/abs/2601.05230", "arXiv:2601.05230")
]

Un *modelo de acciones latentes* aprende un modelo del mundo a partir de videos que no traen las acciones anotadas. Para eso, un módulo mira dos cuadros consecutivos e infiere una "acción latente" que explica el cambio, y otro módulo predice el cuadro siguiente a partir del actual y de esa acción. Hay una trampa: si la acción latente puede llevar mucha información, el modelo simplemente copia el cuadro siguiente dentro de ella. Por eso hay que *limitar su capacidad*. Genie #ct(<bruce2024>) lo hizo con un diccionario VQ de pocos códigos.

#ctp(<garrido2026>) entrenan estos modelos con video "en la naturaleza" (videos de internet, sin una única encarnación ni un conjunto fijo de acciones). Encuentran que las acciones VQ *no logran capturar* la complejidad de las acciones reales, mientras que acciones *continuas* limitadas con esparsidad o con ruido sí lo logran #est. Lo que importaba era limitar la información (pieza #pieza(1)), y la discretización era una forma demasiado tosca de hacerlo cuando el espacio de acciones es rico.

== Resumen del capítulo

#figure(
  table(
    columns: (auto, auto, auto, auto),
    stroke: none,
    inset: (x: 5pt, y: 3.5pt),
    align: (left, left, left, center),
    table.hline(stroke: 0.6pt),
    table.header([*Caso*], [*Qué se discretiza*], [*Resultado*], [*Pieza*]),
    table.hline(stroke: 0.4pt),
    [DreamerV2], [estado estocástico], [mejora en 42/55 juegos], [sin separar],
    [Meyer et al.], [estado (multi-one-hot)], [mejora con poca capacidad y en cambios], [#pieza(2) #pieza(1)],
    [Meyer et al.], [mismo código, como vector], [mucho peor que _one-hot_], [#pieza(2)],
    [DCWM], [estado (FSQ) + clasificación], [mejora; vectores > _one-hot_], [#pieza(4) #pieza(3) #pieza(2)],
    [Stochastic MuZero], [resultado del azar], [mejora con azar, igual sin azar], [#pieza(4)],
    [MoP-JEPA], [elección de cabeza], [0,85 frente a 0,02–0,09], [#pieza(4)],
    [Mao et al.], [tokens extra de entrada], [hasta +12 % de robustez], [#pieza(5)],
    [MAR], [tokens de imagen], [*continuo gana*], [#pieza(1) #pieza(4)],
    [Garrido et al.], [acciones latentes], [*continuo gana*], [#pieza(1)],
    table.hline(stroke: 0.6pt),
  ),
  caption: [Evidencia del capítulo, atribuida a piezas del paquete.],
  kind: table,
) <tab:evidencia>

#llevamos[
  - La creencia de que "lo discreto es mejor" nació de DreamerV2, cuya ablación no separa causas. Los propios autores no saben por qué funciona.
  - Los experimentos que sí separan causas muestran efectos *condicionales*: la ventaja aparece con poca capacidad (Meyer), con azar (Stochastic MuZero, MoP-JEPA) o con geometría adecuada (_one-hot_ en laberintos, vectores en control).
  - Mismo código, distinta codificación, resultados muy distintos: lo que importa no es solo que sea discreto.
  - Lo continuo gana cuando el espacio es rico (acciones reales, texturas de imágenes) y cuando se dispone de otra forma de modelar varios modos (difusión).
  - Casi todos los éxitos discretizan *una* cosa (la elección, la pérdida, el estado estocástico) y conservan una parte continua. El diseño con mejor respaldo es híbrido.
]
