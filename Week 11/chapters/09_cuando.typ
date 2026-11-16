#import "/math_functions.typ": *
#import "/bloques.typ": *

#frase[Conviene discretizar cuando la estructura relevante del problema es ella misma discreta (o se usa como si lo fuera) y cuando el sistema reutiliza sus propias salidas; no conviene cuando la información relevante vive en diferencias finas y continuas.]

Este capítulo responde a la pregunta abierta A2: ¿qué características comparten los espacios donde conviene discretizar, y aquellos donde no conviene? Como A1, no tiene una respuesta establecida. Lo que sigue es una síntesis de la evidencia en forma de criterios, cada uno con su pieza, su respaldo y, sobre todo, un *diagnóstico*: algo que se puede medir *antes* de decidir.

== Criterios a favor

#figure(
  table(
    columns: (1.2fr, 1fr, auto, 1.3fr),
    stroke: none,
    inset: (x: 4pt, y: 4pt),
    align: left,
    table.hline(stroke: 0.6pt),
    table.header([*El problema…*], [*Evidencia*], [*Pieza*], [*Diagnóstico medible*]),
    table.hline(stroke: 0.4pt),
    [requiere buscar, enumerar, reutilizar o componer hipótesis], [DreamCoder, NLI frente a LPN], [#pieza(6)], [¿la tarea pide comparar candidatos exactamente o recombinar piezas?],
    [tiene futuros que se ramifican], [St. MuZero (2048 frente a Go), MoP-JEPA, DCWM], [#pieza(4)], [ajustar una mezcla a $p(z'|z)$: ¿mejora la verosimilitud con más de un componente?],
    [encadena muchas predicciones, con ruido por paso pequeño frente al margen], [capítulo V, Discrete-JEPA, Meyer], [#pieza(5)], [estimar $sigma slash d$ (error de un paso frente a la separación entre estados) y el horizonte; conviene si $sigma slash d lt.tilde 0,2$],
    [vive en un mundo con "huecos": estados agrupados, categorías, saltos], [Meyer (laberintos), DreamerV2 (hipótesis 4)], [#pieza(2) #pieza(1)], [separabilidad de grupos en los estados: distancia entre grupos frente a la dispersión dentro de ellos],
    [tiene poca capacidad frente a la complejidad del mundo], [Meyer (escalamiento)], [#pieza(1) #pieza(2)], [curva de error según el tamaño del modelo: ¿sigue bajando?],
    [enfrenta un mundo que cambia], [Meyer (aprendizaje continuo)], [#pieza(2)], [frecuencia y tamaño de los cambios del entorno],
    table.hline(stroke: 0.6pt),
  ),
  caption: [Características compartidas por los casos en que discretizar ayudó.],
  kind: table,
) <tab:a-favor>

== Criterios en contra

#figure(
  table(
    columns: (1.2fr, 1fr, 1.4fr),
    stroke: none,
    inset: (x: 4pt, y: 4pt),
    align: left,
    table.hline(stroke: 0.6pt),
    table.header([*El problema…*], [*Evidencia*], [*Qué hacer en su lugar*]),
    table.hline(stroke: 0.4pt),
    [necesita precisión fina en una variable continua y rica], [MAR (texturas), Garrido (acciones reales)], [continuo con capacidad limitada por ruido o esparsidad; difusión si hay varios modos],
    [depende del orden o de interpolar], [DCWM (_one-hot_ y etiquetas fallan)], [si se discretiza, entregar vectores del diccionario, no _one-hot_],
    [optimiza por gradiente dentro del latente en tiempo de prueba], [LPN], [continuo, o discreto con relajación (Gumbel, como NLI)],
    [tiene ruido por paso comparable al margen], [capítulo V ($sigma gt.tilde 0,29 d$)], [mejorar el modelo antes de redondear; o no redondear],
    [necesita muchos bits por paso], [colapso del diccionario en VQ grandes], [FSQ o cuantización residual, si se insiste en discretizar],
    table.hline(stroke: 0.6pt),
  ),
  caption: [Características compartidas por los casos en que discretizar perjudicó.],
  kind: table,
) <tab:en-contra>

== Un árbol de decisión

La @fig:arbol ordena los criterios como preguntas sucesivas. El orden no es arbitrario: va de lo que solo lo discreto ofrece (la identidad exacta) a lo que tiene alternativas continuas. Además, cada rama recomienda discretizar *lo mínimo necesario*: la elección y no el estado, el objetivo y no el latente, cuando eso basta.

#fig("f28_arbol.svg")[Árbol de decisión para discretizar. Cada "sí" recomienda qué discretizar (o qué no), y qué pieza se busca.] <fig:arbol>

== Un mapa

La @fig:mapa-ejes ubica los casos del texto en dos ejes que resumen los criterios. El horizontal mide cuán "agrupado" es el mundo, desde suave y sin huecos hasta categórico y con saltos. El vertical mide cuánta precisión exige la tarea. Lo discreto gana a la derecha y abajo; lo continuo, a la izquierda y arriba. La ubicación es nuestro juicio y no una medición #conj.

#fig("f29_mapa_ejes.svg")[Los casos del capítulo en dos ejes. La franja naranja marca la región donde la evidencia favorece discretizar.] <fig:mapa-ejes>

#rel("Respuesta tentativa a A2")[
  Los espacios donde conviene discretizar comparten una propiedad: su estructura relevante es *discreta o casi discreta* (categorías, ramas, objetos, reglas) y el sistema *reutiliza sus propias salidas* (rollouts largos, búsqueda, composición), de modo que el margen y la identidad exacta rinden una y otra vez. Los espacios donde no conviene comparten la propiedad opuesta: la información que importa vive en *diferencias finas y continuas* que ningún corte grueso respeta. En el medio, lo que mejor funciona es *híbrido*: un estado continuo con una elección discreta (Dreamer, MoP-JEPA) o con un objetivo discretizado (_two-hot_) #conj.
]

== Límites del marco

Tres advertencias:
- Los criterios son *correlaciones* entre la estructura del problema y el resultado en una docena de casos, no leyes. Varios casos tienen un solo paper detrás.
- Los diagnósticos suponen que ya se tiene alguna representación del problema para medir. Hay un círculo: para saber si el mundo tiene huecos, hay que haber elegido cómo mirarlo.
- El marco trata los cortes como fijos. Como dice el .epub, lo que distingue a la cognición humana quizás no es discretizar, sino *mover los cortes*: crear una categoría nueva cuando una vieja falla, o cambiar de escala. Ninguno de los modelos de este capítulo lo hace, salvo DreamCoder.

#llevamos[
  - A favor de discretizar: búsqueda o composición, futuros ramificados, cadenas largas con ruido pequeño frente al margen, mundos agrupados, poca capacidad y entornos cambiantes. Cada criterio tiene un diagnóstico medible.
  - En contra: precisión fina en variables ricas, orden o interpolación (usar vectores, no _one-hot_), optimización por gradiente en el latente y ruido por paso comparable al margen.
  - Regla práctica: discretizar *lo mínimo* que entregue la pieza necesaria; los diseños híbridos son los que tienen más respaldo.
]
