#import "/math_functions.typ": *
#import "/bloques.typ": *

#frase[En la familia JEPA casi nadie discretiza los valores del estado: se discretiza la elección entre futuros, unos tokens semánticos, las acciones o la estructura, cada vez por una razón distinta, y todavía no existe una comparación limpia entre un JEPA discreto y uno continuo.]

Este capítulo responde a P4: ¿alguien discretiza en JEPA? ¿Por qué?

== Recordatorio: qué hace un JEPA

I-JEPA #ct(<assran2023>) aprende representaciones de imágenes con una tarea simple (@fig:jepa, arriba):
+ Se toma una parte visible de la imagen (el contexto) y se codifica.
+ Un predictor intenta adivinar la *representación* de otras partes ocultas (los objetivos).
+ La representación de los objetivos la calcula un segundo codificador, actualizado por EMA, con _stop-gradient_.

La pérdida es la distancia cuadrática entre lo predicho y el objetivo, en el espacio de representaciones y no en píxeles. Sus ablaciones aportan dos datos útiles para nosotros. Predecir en espacio de representaciones en vez de píxeles sube la precisión en ImageNet con 1 % de etiquetas de 40,7 a 66,9 (tabla 7, aunque con 800 y 500 épocas de entrenamiento, respectivamente). Y un predictor *más angosto* rinde mejor que uno ancho, 70,7 frente a 68,4 (tabla 14) #est. Ninguna de las dos mejoras discretiza nada: la primera es abstracción y la segunda es un cuello de botella continuo.

JEPA-Anything #ct(<cui2026>) agrega la factorización predictiva ortogonal (OPF). El objetivo se proyecta en $K$ subespacios ortogonales (normalmente $K = 4$ o $5$), cada factor tiene su propio predictor y el estado completo se recompone con una pseudoinversa. La ortogonalidad controla el número de condición de esa recomposición, y con ello *cuánto se amplifican* los errores de los factores. Es una vía para la estabilidad (pieza #pieza(5)) que no discretiza valores, sino la estructura.

#fig("f27_jepa.svg")[(a) I-JEPA: un predictor entrenado con distancia cuadrática, que en una bifurcación apunta al promedio. (b) MoP-JEPA: $K$ cabezas, y cada ejemplo entrena solo a la que mejor lo predice.] <fig:jepa>

== Quién discretiza qué, y por qué

#figure(
  table(
    columns: (0.85fr, 1.15fr, 1.5fr, 1.3fr),
    stroke: none,
    inset: (x: 4pt, y: 4pt),
    align: left,
    table.hline(stroke: 0.6pt),
    table.header([*Trabajo*], [*Qué discretiza*], [*Por qué*], [*Resultado*]),
    table.hline(stroke: 0.4pt),
    [LeCun (2022)], [la variable latente $z$ del predictor (propuesta)], [representar futuros múltiples y limitar cuánta información lleva $z$ #pieza(4) #pieza(1)], [propuesta conceptual, sin experimento],
    [MoP-JEPA], [qué cabeza predice], [no promediar en bifurcaciones #pieza(4)], [éxito de 0,85 frente a 0,02–0,09 en laberintos],
    [Discrete-JEPA], [tokens semánticos (VQ)], [razonamiento simbólico; evitar error acumulado #pieza(5) #pieza(6)], [peor al inicio y mejor a 1000 pasos; hiperparámetros distintos],
    [DCWM], [el latente (FSQ), sin reconstrucción], [estocasticidad y clasificación #pieza(4) #pieza(3)], [competitivo con TD-MPC2],
    [Garrido et al.], [acciones latentes (VQ, como baseline)], [limitar la capacidad de la acción #pieza(1)], [VQ falla; continuo con ruido o esparsidad funciona],
    [JEPA-Anything], [la estructura ($K$ factores)], [repartir la capacidad predictiva; estabilidad #pieza(5)], [mejoras pequeñas y auditoría de estabilidad],
    [DINO, SwAV], [la salida: distribución sobre prototipos], [evitar el colapso, con reparto equitativo o centrado], [métodos de referencia en autosupervisado],
    table.hline(stroke: 0.6pt),
  ),
  caption: [Discretización en la familia JEPA y en métodos cercanos.],
  kind: table,
) <tab:jepa>

=== LeCun (2022): la variable latente

En la propuesta original de LeCun #ct(<lecun2022>), un JEPA para modelos del mundo tiene, además del predictor, una *variable latente* $z$ que representa lo que no se puede predecir desde el contexto, por ejemplo cuál de varios futuros ocurrirá. Para que $z$ no termine llevando *toda* la respuesta (que el predictor haga trampa copiando el objetivo en $z$), hay que limitar su información. Entre las formas que se discuten están hacerla discreta con pocos valores, de baja dimensión, esparsa o ruidosa. Con una $z$ discreta, además, se pueden recorrer todos sus valores para planificar #sug. Son las piezas #pieza(4) y #pieza(1), y también las mismas opciones que Garrido et al. compararon años después para las acciones: allí ganaron las versiones continuas ruidosas o esparsas.

=== MoP-JEPA y Discrete-JEPA

MoP-JEPA (capítulo IV) discretiza *la elección*, con un predictor por modo. Es la implementación más directa de la $z$ discreta de LeCun.

Discrete-JEPA #ct(<baek2025>) es el trabajo más cercano a un "JEPA discreto". Discretiza con VQ *solo* unas representaciones semánticas globales y mantiene continuas las de los parches. Lo motivan dos argumentos que ya conocemos: las tareas simbólicas requieren estructura discreta, y "las representaciones continuas sufren de errores acumulados en la predicción secuencial". Lo evalúan como modelo del mundo autorregresivo en secuencias sintéticas con patrones (colores que se repiten, pelotas que parpadean). El resultado tiene exactamente la firma del redondeo del capítulo V:
- en los primeros pasos, I-JEPA es *mejor*: en el paso 10, LPIPS de 0,0001 frente a 0,0028;
- a largo plazo, Discrete-JEPA es mucho mejor: en el paso 1000, LPIPS de 0,0242 frente a 0,1554;
- I-JEPA pierde la consistencia del patrón cerca del paso 600 #sug.

La etiqueta es #sug y no #est porque los dos modelos usan dimensiones de token y tasas de aprendizaje distintas. Además, los autores reconocen que comparan casi solo contra I-JEPA.

=== DINO y SwAV: discretizar la salida para no colapsar

Los métodos de la familia _joint-embedding_ más usados discretizan "en blando" su salida. Cada imagen se representa como una distribución (un softmax) sobre $K$ prototipos aprendidos, y se pide que dos vistas de la imagen tengan distribuciones parecidas. Esto reaparece en el capítulo VII como colapso del diccionario: todas las imágenes podrían ir al mismo prototipo. SwAV #ct(<caron2020>) lo impide exigiendo que, en cada lote, las imágenes se repartan por igual entre prototipos; DINO #ct(<caron2021>), centrando y afilando las distribuciones. Aquí la estructura discreta no es la meta, sino la herramienta que hace *visible y controlable* el colapso.

== Por qué discretizan, en resumen

Las razones se agrupan en cuatro, y cada una corresponde a una pieza:
- *Futuros múltiples* (pieza #pieza(4)): LeCun, MoP-JEPA y DCWM.
- *Limitar información* (pieza #pieza(1)): la $z$ de LeCun y las acciones latentes. Aquí la evidencia favorece las vías continuas.
- *Horizontes largos y símbolos* (piezas #pieza(5) y #pieza(6)): Discrete-JEPA.
- *Controlar el colapso*: DINO y SwAV.

Lo que *no* existe todavía es una comparación entre un JEPA con estado completamente discreto y uno continuo en igualdad de condiciones. El documento del profesor lo afirma, y tras revisar Discrete-JEPA lo mantenemos con un matiz: Discrete-JEPA se acerca, pero no iguala capacidad ni hiperparámetros. El experimento factorial del capítulo VI, aplicado a un JEPA, llenaría ese hueco.

#llevamos[
  - P4: sí se discretiza en JEPA, pero casi nunca el estado completo. Se discretizan la elección entre futuros (MoP-JEPA), tokens semánticos (Discrete-JEPA), el latente de un modelo sin reconstrucción (DCWM), las acciones (Garrido, donde lo discreto pierde), la estructura (JEPA-Anything) y la salida (DINO, SwAV).
  - Las razones son cuatro: futuros múltiples, limitar información, horizontes largos o símbolos, y controlar el colapso.
  - Las dos mejoras más claras de I-JEPA (predecir representaciones y estrechar el predictor) no discretizan nada.
  - Discrete-JEPA muestra la firma del redondeo (peor al inicio, mejor a largo plazo), pero sin igualar condiciones #sug.
]
