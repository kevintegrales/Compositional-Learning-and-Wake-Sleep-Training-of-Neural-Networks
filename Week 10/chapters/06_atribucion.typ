#import "/math_functions.typ": *
#import "/bloques.typ": *

#frase[Cada pieza del paquete predice una "firma" distinta en los experimentos; casi todos los beneficios documentados se pueden reproducir sin discretizar, atacando la pieza responsable, y lo único que no tiene sustituto continuo claro es la identidad exacta.]

Este capítulo responde a P3 (¿qué experimento comprueba o desmiente que la discretización es la causa?) y a la pregunta abierta A1 (¿hay un principio más allá de la discreción?). La estrategia es la misma de todo el texto. Si "discretizar" es un paquete, la pregunta "¿ayuda discretizar?" se reemplaza por seis preguntas más pequeñas, una por pieza, y cada una se puede poner a prueba por separado.

== Desarmar el paquete

=== La firma de cada pieza

Cada pieza, si fuera la responsable de una mejora, dejaría una huella distinta en los experimentos. La tabla resume qué habría que observar.

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    stroke: none,
    inset: (x: 5pt, y: 4pt),
    align: left,
    table.hline(stroke: 0.6pt),
    table.header([*Pieza*], [*Si fuera la responsable, veríamos que…*], [*Experimento que lo distingue*]),
    table.hline(stroke: 0.4pt),
    [#pieza(1) Capacidad], [la ventaja desaparece al darle al continuo el mismo número de bits (con ruido o esparsidad)], [discreto frente a continuo con capacidad igualada],
    [#pieza(2) Geometría], [el mismo código rinde distinto según cómo se entregue], [_one-hot_ frente a vector, con la misma información],
    [#pieza(3) Pérdida], [clasificar ayuda aunque el estado siga siendo continuo], [MSE frente a CE sobre el mismo latente],
    [#pieza(4) Modos], [la ventaja aparece solo con azar y desaparece en entornos deterministas], [mismo método en un entorno con azar y en otro sin azar],
    [#pieza(5) Redondeo], [la ventaja crece con el largo del rollout y depende del cociente ruido/margen], [error a 1 paso frente a error a 30 pasos],
    [#pieza(6) Identidad], [la ventaja aparece al buscar, reutilizar o componer, y no en predicción de un paso], [tareas con y sin búsqueda o composición],
    table.hline(stroke: 0.6pt),
  ),
  caption: [La "firma" de cada pieza: qué observación la delataría.],
  kind: table,
) <tab:firmas>

=== Los confusores

Un *confusor* es algo que cambia junto con la variable que nos interesa y que podría explicar el efecto por sí solo. En los experimentos de discretización aparecen siempre los mismos:
- *La pérdida.* Pasar a códigos suele traer consigo pasar de MSE a entropía cruzada. #ctp(<farebrother2024>) muestran que predecir valores por clasificación (con HL-Gauss) en vez de regresión mejora el aprendizaje por refuerzo profundo en muchos dominios, *sin discretizar ningún estado*. DreamerV3 hace lo mismo con sus objetivos _two-hot_.
- *La capacidad.* Un diccionario de $K$ códigos lleva $log_2 K$ bits; un vector continuo del mismo tamaño puede llevar muchísimos más. Si no se igualan, se compara un modelo con cuello de botella contra uno sin él.
- *El tamaño del modelo.* En Meyer et al., el efecto depende de la capacidad del modelo de transición y desaparece con modelos grandes.
- *La arquitectura que acompaña a lo discreto.* En NLI, los tokens discretos vienen con largo variable y con un intérprete secuencial; en LPN, el latente continuo tiene largo fijo.
- *El estimador del gradiente.* El _rotation trick_ mejora mucho un VQ sin cambiar la representación, solo cambiando cómo pasa el gradiente.
- *Los hiperparámetros.* Discrete-JEPA #ct(<baek2025>) compara su versión discreta con I-JEPA usando dimensiones de token distintas (96 frente a 768) y tasas de aprendizaje distintas.

=== ¿Qué experimentos ya existen?

La @fig:matriz cruza las piezas con los experimentos que vimos y marca cuáles aíslan cada pieza y cuáles solo la tocan.

#fig("f20_matriz.svg")[Qué experimentos publicados aíslan cada pieza del paquete. Un círculo lleno significa que el experimento cambia esa pieza y nada más (o casi nada más). Un círculo vacío significa que la cambia junto con otras. La fila de la identidad exacta está vacía.] <fig:matriz>

Tres observaciones:
+ Las piezas #pieza(2), #pieza(3) y #pieza(4) están bien cubiertas. Hay experimentos limpios que muestran que la geometría, la pérdida y la capacidad de elegir entre modos importan *cada una por separado*.
+ La pieza #pieza(1) (capacidad) está cubierta desde el lado continuo. Garrido et al. muestran que un continuo con capacidad limitada supera al VQ, y la tabla 14 de I-JEPA muestra que estrechar el predictor (de 1024 a 384 canales) *mejora* el resultado (de 68,4 a 70,7) #est. Es un cuello de botella que ayuda sin discretizar nada.
+ La pieza #pieza(5) solo tiene evidencia parcial, y la #pieza(6) ninguna. Discrete-JEPA es sugerente: I-JEPA gana en los primeros pasos y Discrete-JEPA gana a largo plazo (en el paso 1000, el LPIPS es 0,0242 frente a 0,1554). Es justo la firma del redondeo, pero con hiperparámetros distintos #sug.

== Un experimento para desarmar el paquete (P3)

La matriz muestra dónde faltan experimentos. Esta sección propone uno que llena esos huecos y que se podría montar con los modelos del curso. La idea es un *diseño factorial*: en vez de cambiar todo a la vez, se cruzan todas las combinaciones de unos pocos factores (@fig:cubo).

#fig("f21_cubo.svg")[El diseño propuesto. Cada vértice del cubo es una variante del modelo; azul es continuo y naranjo es discreto. Cada variante se evalúa en entornos con y sin azar y con horizontes corto y largo. Dentro de lo discreto, se cruza además la geometría.] <fig:cubo>

Los factores son:
- *Representación*: latente continuo o discreto.
- *Capacidad*: libre, o igualada. Para igualarla, al latente continuo se le suma ruido gaussiano calibrado para que lleve aproximadamente $log_2 K$ bits por código, como el discreto.
- *Pérdida*: MSE o entropía cruzada. Para el continuo, la entropía cruzada se aplica discretizando *solo el objetivo* (HL-Gauss), sin tocar el estado.
- *Entorno*: determinista o estocástico.
- *Horizonte*: error a un paso y a treinta pasos.
- *Geometría* (solo para el discreto): _one-hot_ o vector.

Lo valioso del diseño es que cada hipótesis predice un patrón distinto:
- Si la causa es la *capacidad*, la diferencia entre continuo y discreto desaparece en las variantes con capacidad igualada.
- Si es la *pérdida*, desaparece cuando ambos usan entropía cruzada.
- Si es *elegir entre modos*, aparece solo en el entorno estocástico.
- Si es el *redondeo*, es pequeña a un paso y grande a treinta.
- Si es la *geometría*, la variante discreta con vectores pierde parte de la ventaja.
- Si después de controlar todo lo anterior queda una diferencia, hay algo propio de la discreción que nuestras piezas no capturan.

*Aplicado a LPN y NLI.* La pregunta del inicio (¿por qué NLI generaliza mejor que LPN?) se presta para este diseño, con cuatro variantes concretas:
+ Un LPN con *largo variable*: una secuencia de latentes continuos leída por el intérprete de NLI. Separa la discreción del largo variable.
+ Un NLI con *largo fijo*. Es la misma separación, en sentido contrario.
+ Un NLI con *tokens continuos* y ruido calibrado. Separa la discreción de la capacidad.
+ Un NLI que entrega sus tokens como *vectores* en vez de _one-hot_. Mide la geometría.

La métrica sería la generalización composicional: el éxito al componer 2, 3 y 4 o más primitivas, que es donde LPN fallaba. Una predicción concreta, que el experimento podría desmentir: si la ventaja de NLI viene sobre todo del largo variable y del intérprete secuencial, las variantes 1 y 3 deberían recuperar buena parte de ella; si viene de la identidad exacta (pieza #pieza(6)), no deberían recuperarla #conj.

#pensar[Si en este experimento la variante 3 (tokens continuos con ruido calibrado) rindiera igual que NLI, ¿qué concluirías sobre la pregunta del reporte de la semana 9?]

== ¿Hay un principio más allá de la discreción? (A1)

=== Qué se pudo reproducir sin discretizar

La forma más directa de responder A1 es revisar, beneficio por beneficio, si alguien lo obtuvo *sin* discretizar.

#figure(
  table(
    columns: (1.15fr, 0.75fr, 2.6fr),
    stroke: none,
    inset: (x: 5pt, y: 4pt),
    align: left,
    table.hline(stroke: 0.6pt),
    table.header([*Beneficio*], [*¿Sin discretizar?*], [*Cómo*]),
    table.hline(stroke: 0.4pt),
    [Elegir entre modos #pieza(4)], [sí], [pérdida de difusión sobre tokens continuos (MAR); mezclas de gaussianas, aunque estas rinden peor en Meta-World (DCWM)],
    [Limitar capacidad #pieza(1)], [sí], [acciones continuas con ruido o esparsidad (Garrido); predictor angosto en I-JEPA],
    [Clasificar #pieza(3)], [sí], [objetivo discretizado, estado continuo (HL-Gauss, _two-hot_)],
    [Esparsidad #pieza(2)], [en parte], [la activación esparsa FTA recupera parte de la brecha: 574 frente a 382 y 674 (Meyer)],
    [Estabilidad #pieza(5)], [en parte], [ortogonalidad de factores en JEPA-Anything (controla la amplificación del error al recomponer); atractores; proyección a restricciones],
    [Identidad exacta #pieza(6)], [no], [no hay un sustituto continuo claro para enumerar, comparar exactamente o reutilizar],
    table.hline(stroke: 0.6pt),
  ),
  caption: [Beneficios de la discretización y si se obtuvieron por otra vía.],
  kind: table,
) <tab:sin-discretizar>

La respuesta, entonces, es: *casi siempre sí*. Para cuatro de los seis beneficios hay una vía continua documentada; para uno hay vías parciales; y para uno no la hay.

=== El principio candidato

¿Qué tienen en común las vías continuas que funcionan? Todas imponen alguna de estas dos propiedades:

#idea[Invarianza y margen][
  Una representación es *invariante* a un cambio si ese cambio no la mueve. Por ejemplo, la representación de "gato" debería ser invariante a la iluminación. Tiene *margen* entre dos cosas que deben distinguirse si sus representaciones están lejos en comparación con el ruido. Una representación útil es invariante a lo que no importa para la tarea y tiene margen entre lo que sí importa. El aprendizaje contrastivo hace exactamente eso: junta las vistas de una misma imagen (invarianza) y separa las de imágenes distintas (margen).
]

La discretización es la forma *extrema* de imponer ambas cosas. Dentro de una celda, la invarianza es total: todos los puntos se vuelven el mismo código. Entre celdas, el margen es fijo e igual a la separación. Por eso proponemos el siguiente principio #conj:

#rel("Principio candidato (respuesta tentativa a A1)")[
  Lo que mejora los resultados no es la discreción, sino una representación con *invarianza dentro de cada clase*, *margen entre clases* y *cortes que coinciden con la estructura del mundo*. La discretización es la manera más barata y extrema de conseguir las dos primeras. Ayuda cuando sus cortes coinciden con los del mundo y perjudica cuando no coinciden, porque entonces la invarianza borra diferencias que importaban.
]

La @fig:principio lo ilustra. Los mismos datos pueden representarse sin margen (el ruido cruza la frontera), con margen e invarianza en un espacio continuo (el ruido no alcanza a cruzar) o de forma discreta (el ruido, además, se borra al redondear). Las dos últimas resuelven la tarea; la discreta, además, permite seguir el error (capítulo V).

#fig("f22_principio.svg")[El principio en dos dimensiones. Dos clases (círculos y triángulos) separadas por una frontera (línea punteada). Lo que importa no es si la representación es discreta, sino si tiene margen frente al ruido; la discretización es el caso extremo.] <fig:principio>

El principio explica los casos del capítulo IV:
- En los laberintos (Meyer), los cortes naturales son categorías sin orden, y _one-hot_ da margen máximo entre ellas.
- En control continuo (DCWM), los cortes tienen orden, y los vectores del diccionario conservan ese orden.
- En imágenes (MAR) y en acciones reales (Garrido), no hay cortes naturales gruesos: la invarianza de VQ borra detalle útil, y gana el continuo con capacidad limitada.

Además, conecta con un fenómeno del capítulo VII. Cuando una red se entrena con etiquetas por mucho tiempo, el descenso de gradiente lleva por sí solo las representaciones de cada clase a puntos casi idénticos, ubicados en los vértices de un símplex: el *colapso neuronal*. Es invarianza máxima y margen máximo, una *discretización que emerge* sin que nadie la imponga.

=== Lo que sí parece propio de lo discreto

La única fila sin sustituto continuo en la @tab:sin-discretizar es la identidad exacta. Poder decir "este estado es *el mismo* que aquel" permite tres cosas:
- *enumerar* hipótesis y saltar de una a otra sin pasar por las intermedias, como en el juego de los números de Tenenbaum o en DreamCoder;
- *reutilizar* una pieza en contextos distintos, sabiendo que es la misma;
- *componer* piezas sin que se mezclen.

Es lo que el .epub llamaba "combinatoria sin mezcla" y "búsqueda". Es también el ingrediente que diferencia a NLI de LPN. Que no exista un experimento que lo aísle (la fila vacía de la @fig:matriz) es, quizás, la mejor oportunidad de trabajo que deja este capítulo.

=== Qué desmentiría el principio

Un principio que no se puede desmentir no sirve. Este quedaría en problemas si se encontrara un caso donde lo discreto gane con capacidad, pérdida, esparsidad y margen igualados, y en una tarea que no requiera búsqueda ni composición. El experimento factorial de la sección anterior es justamente la forma de buscarlo.

#llevamos[
  - Cada pieza deja una firma distinta: la capacidad se borra al igualar bits, los modos solo aparecen con azar, el redondeo crece con el horizonte, la identidad exacta aparece al buscar o componer.
  - Los confusores típicos son la pérdida, la capacidad, el tamaño del modelo, la arquitectura y el estimador del gradiente.
  - Para P3: un diseño factorial (representación × capacidad × pérdida × entorno × horizonte, y geometría) separa las piezas. Aplicado a LPN y NLI, separa la discreción del largo variable.
  - Para A1: casi todos los beneficios se reprodujeron sin discretizar. El principio candidato es *invarianza dentro, margen entre, cortes que coinciden con el mundo* #conj. Lo único sin sustituto continuo claro es la identidad exacta.
]
