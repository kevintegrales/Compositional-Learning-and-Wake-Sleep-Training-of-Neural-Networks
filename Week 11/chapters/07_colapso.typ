#import "/math_functions.typ": *
#import "/bloques.typ": *

#frase[Hay varios colapsos, y en casi todos el gradiente encuentra una solución barata en la que el latente deja de llevar información; lo discreto no elimina el colapso, sino que lo transforma en uno que se puede contar y corregir, y el colapso y el error acumulado resultan ser los dos desenlaces de un mismo bucle.]

Este capítulo trata los costos. Responde a P1 (¿es más difícil el colapso con lo discreto?), a P5 (¿dónde ocurre el colapso del diccionario?) y a la nota del profesor (_"accumulated errors =?= collapse"_).

== Una familia de colapsos

La palabra "colapso" se usa en la literatura para cosas distintas. Conviene separarlas antes de preguntar si lo discreto las evita (@fig:colapsos).

#fig("f23_colapsos.svg")[Cinco colapsos, más una referencia sana. En los cuatro del centro, el latente deja de distinguir entradas que debería distinguir. El colapso neuronal es distinto: deja de distinguir lo que *no* importa (las variaciones dentro de una clase) y conserva exactamente lo que importa.] <fig:colapsos>

- *Colapso posterior* (semana 4): en un VAE, la posterior deja de depender de la entrada, $q(z|x) = p(z)$ para todo $x$, y el decodificador aprende a reconstruir sin mirar $z$.
- *Colapso completo*: el codificador entrega el mismo vector para toda entrada. Es el riesgo central de los métodos predictivos autosupervisados como BYOL o JEPA (capítulo II).
- *Colapso dimensional* #ct(<jing2022>): los vectores no son todos iguales, pero viven en un subespacio de pocas dimensiones. Se detecta porque muchos valores propios de su matriz de covarianza son casi cero. Es más sutil que el completo y aparece incluso en métodos contrastivos.
- *Colapso del diccionario*: de los $K$ códigos, solo se usan unos pocos.
- *Colapso neuronal* #ct(<papyan2020>): al entrenar un clasificador mucho tiempo, las representaciones de cada clase se concentran en su promedio, y los promedios se ubican en los vértices de un símplex regular, todos a la misma distancia. Es el colapso "útil": máxima invarianza dentro de cada clase y máximo margen entre clases.

=== Por qué el gradiente cae ahí

Los cuatro colapsos dañinos tienen un hilo común: existe una solución en la que el latente *no lleva información* y que, sin embargo, hace bajar la pérdida. El descenso de gradiente la encuentra por tres vías:
+ *Una solución trivial con pérdida baja.* Si el objetivo es predecir una representación que el propio modelo produce, una constante la predice perfecto. En un VAE, apagar el latente anula el término KL.
+ *Una preferencia por soluciones simples.* El entrenamiento por gradiente tiende a usar pocas direcciones del espacio; Jing et al. muestran que eso, combinado con aumentos de datos fuertes, produce colapso dimensional.
+ *"El rico se hace más rico".* En VQ, cada punto solo actualiza el código más cercano. Un código que gana atrae más puntos, y uno que nunca gana nunca se mueve (lo vemos en detalle más abajo).

Los remedios continuos atacan estas vías. Los *negativos* del aprendizaje contrastivo castigan que dos imágenes distintas queden juntas. *EMA y stop-gradient* impiden que el modelo arrastre su propio objetivo hacia la constante. *VICReg* #ct(<bardes2022>) agrega términos explícitos: uno de *varianza*, que exige que cada coordenada varíe al menos $gamma$ entre ejemplos,
$ v(Z) = 1 / d sum_(j=1)^d max(0, gamma - sqrt("Var"(z_j) + epsilon)), $
y uno de *covarianza*, que penaliza que dos coordenadas estén correlacionadas, para evitar el colapso dimensional. JEPA-Anything usa un "piso de actividad" por factor con la misma lógica.

== ¿Hace más difícil el colapso posterior lo discreto? (P1)

=== VQ-VAE: no colapsa, pero no por ser discreto

En un VAE, el término KL de la ELBO, $D_"KL" (q(z|x) || p(z))$, empuja la posterior hacia la prior. Si el decodificador es lo bastante potente para reconstruir sin ayuda, la solución más barata es igualarlas: eso es el colapso posterior.

En VQ-VAE, la posterior es *determinista* (toda la masa en el código más cercano) y la prior es *uniforme y fija* sobre $K$ códigos. Entonces
$ D_"KL" (q(z|x) || p(z)) = log K quad "para todo" x, $
una constante que no depende de los parámetros. *No hay ninguna fuerza que empuje hacia el colapso* #est. Así lo plantean van den Oord et al. y lo anotamos en los apuntes de la semana 4.

Pero hay que mirar con cuidado qué produjo ese efecto. No fue la discreción, sino la combinación de *posterior determinista* y *prior fija*. La prueba es que un VAE *categórico* con posterior aprendida y estocástica (por ejemplo, con Gumbel-Softmax) sí puede colapsar: basta con que la posterior se vuelva uniforme, igual a la prior, para que el KL valga cero. DreamerV2 y V3 usan latentes categóricos y aun así necesitan defensas explícitas: el _KL balancing_ y los _free bits_, que dejan de penalizar el KL por debajo de 1 nat para que el modelo no gane nada apagando el latente #est.

=== "Partir con elementos bien separados"

La segunda parte de P1 pregunta si ayuda que los códigos estén bien separados desde el inicio. Los dos papers de la semana 4 permiten responder con precisión.

*Identificabilidad.* #ctp(<wang2021>) muestran que el colapso posterior ocurre *si y solo si* el latente no es *identificable*: si valores distintos de $z$ producen la misma distribución de datos, los datos no pueden decir cuál $z$ se usó, y el modelo puede ignorarlo. Con códigos bien separados *que el decodificador traduce a salidas distintas*, ver $x$ revela $z$, y el colapso deja de ser una solución (@fig:identificabilidad).

#fig("f24_identificabilidad.svg")[Identificabilidad. Si cada código produce datos claramente distintos (izquierda), los datos revelan el código y el decodificador no puede ignorarlo. Si los códigos producen datos casi iguales (derecha), el código no es identificable y el colapso posterior es una solución válida.] <fig:identificabilidad>

*Transición de fase.* #ctp(<li2025>) encuentran, para VAEs gaussianos, que el colapso ocurre cuando el ruido del decodificador supera la mayor varianza de los datos: $sigma'^2 > max_i xi_i^2$, donde los $xi_i^2$ son los valores propios de la covarianza de los datos. Cuando los datos forman grupos bien separados, la varianza *entre grupos* es grande, y el sistema queda lejos del umbral.

#rel("Respuesta a P1")[
  Sí, con lo discreto el colapso posterior suele ser más difícil, pero no por la discreción en sí. En VQ-VAE desaparece la fuerza que empuja al colapso, porque el KL es constante; en un VAE categórico estocástico esa fuerza sigue ahí. Partir con códigos bien separados ayuda por *identificabilidad* y porque aleja el umbral de la transición de fase, con dos condiciones:
  + la separación tiene que *mantenerse* durante el entrenamiento: con un diccionario aprendido los códigos derivan y algunos mueren, mientras que con una grilla fija (FSQ) no;
  + la separación tiene que corresponder a *diferencias reales en los datos*: códigos separados que el decodificador traduce a lo mismo no sirven.
]

== Colapso del diccionario (P5)

=== El mecanismo

En VQ, cada salida del codificador actualiza *solo* al código más cercano. Si un código se inicializa lejos de los datos, nunca es el más cercano a nada, nunca recibe gradiente y nunca se mueve: es un *código muerto* (@fig:diccionario, izquierda). Al revés, los códigos que ganan al principio atraen más puntos y se acomodan mejor, lo que los hace ganar más. Esta dinámica de "el rico se hace más rico" produce el colapso sin que nada lo empuje explícitamente.

#fig("f25_diccionario.svg")[Izquierda: códigos vivos (naranjos) dentro de la nube de datos y códigos muertos (vacíos) fuera de ella. Derecha: esquema del uso del diccionario según su tamaño, a partir de lo que reportan Mentzer et al.: VQ no logra usar más de unos $2^10$ códigos, mientras que FSQ usa casi todos hasta $2^14$.] <fig:diccionario>

FSQ ofrece la comparación más clara. #ctp(<mentzer2024>) reportan que el uso de VQ cae bajo el 50 % para diccionarios de más de $2^11$ códigos y que, en diccionarios grandes, no logra usar más de unos $2^10$. FSQ, en cambio, usa casi todos sus códigos en $2^14$ y más de la mitad en $2^16$, sin pérdidas auxiliares ni trucos #est. La razón es estructural: en una grilla fija no hay códigos que puedan quedar lejos de los datos, porque nadie los mueve.

=== Dónde se ha documentado

#figure(
  table(
    columns: (1.25fr, 0.85fr, 2.9fr),
    stroke: none,
    inset: (x: 5pt, y: 3.5pt),
    align: left,
    table.hline(stroke: 0.6pt),
    table.header([*Modelo*], [*Dominio*], [*Qué ocurre y cómo se combate*]),
    table.hline(stroke: 0.4pt),
    [VQ-VAE #ct(<vandenoord2017>)], [imagen, audio], [Propone actualizar los códigos con EMA (promedio de los puntos asignados) como alternativa a la pérdida del diccionario; el bajo uso se documentó en los trabajos siguientes.],
    [Jukebox #ct(<dhariwal2020>)], [música], [Códigos poco usados; *reinicio aleatorio*: se reemplazan por salidas recientes del codificador.],
    [VQGAN #ct(<esser2021>)], [imagen], [Solo el 2 % de 16.384 códigos en uso; el _rotation trick_ lo sube al 27 % #ct(<fifty2025>).],
    [ViT-VQGAN #ct(<yu2022>)], [imagen], [Bajo uso; se mejora buscando el código en un espacio de *baja dimensión* y con vectores *normalizados*.],
    [SoundStream #ct(<zeghidour2021>)], [audio], [Códigos muertos en cuantización residual; inicialización con k-means y reemplazo de códigos sin uso.],
    [wav2vec 2.0 #ct(<baevski2020>)], [habla], [Diccionarios aprendidos con Gumbel; *pérdida de diversidad* que premia usar los códigos por igual.],
    [SwAV, DINO #ct(<caron2020>) #ct(<caron2021>)], [autosupervisado], [Todas las imágenes asignadas al mismo prototipo; *reparto equitativo* (Sinkhorn) en SwAV, *centrado y afilado* en DINO.],
    [Mezcla de expertos #ct(<shazeer2017>)], [lenguaje], [El enrutador elige siempre a los mismos pocos expertos; pérdida de *balance de carga*.],
    table.hline(stroke: 0.6pt),
  ),
  caption: [Modelos donde se ha documentado el colapso del diccionario (o su equivalente).],
  kind: table,
) <tab:diccionario>

Las dos últimas filas son las más interesantes. SwAV y DINO no son modelos "discretos": discretizan *la salida* en una distribución sobre prototipos. La mezcla de expertos discretiza *la elección de una subred*. El colapso aparece en todas partes donde hay una elección entre $K$ opciones y la elección ganadora recibe más señal. Por eso MoP-JEPA, que asigna cada ejemplo a una sola cabeza, enfrenta en principio el mismo riesgo.

=== Lo discreto transforma el colapso

Con esto se puede responder la versión general de P1. Lo discreto *no elimina* el colapso, *lo transforma*. Un colapso geométrico en continuo (puntos que se acercan de a poco, o un subespacio que se achica) se vuelve, en discreto, un colapso de *asignación*: muchas entradas caen en el mismo código. Este segundo tipo tiene dos ventajas prácticas:
- *se puede contar*: basta con medir la perplejidad o la fracción de códigos en uso;
- *tiene remedios directos*: reinicios, reparto equitativo o grillas fijas.

El colapso dimensional, en cambio, exige mirar el espectro de una matriz de covarianza para detectarlo. Es la misma idea del capítulo V aplicada al entrenamiento: *lo discreto hace visible el problema*.

== ¿Errores acumulados = colapso? (N)

Llegamos a la nota del profesor. En el capítulo V vimos cómo se acumulan los errores en un rollout; ahora tenemos los colapsos. ¿Son lo mismo?

=== Tres bucles

Hay tres situaciones en las que la salida de un modelo vuelve a entrar al mismo modelo, y en las tres aparecen *tanto* errores acumulados *como* colapsos:
+ *Rollouts.* La predicción es la entrada del paso siguiente. Con un predictor MSE, cada paso tira hacia el promedio condicional (capítulo II), y tras muchos pasos las predicciones se vuelven borrosas y parecidas entre sí. Es lo que MoP-JEPA llama "colapso" en las bifurcaciones.
+ *Bootstrapping.* En BYOL y JEPA, el objetivo lo produce (una copia lenta de) el propio codificador. Si el objetivo siguiera al codificador sin freno, el sistema podría deslizarse hacia la constante. EMA y _stop-gradient_ frenan ese bucle.
+ *Entrenar con datos generados.* #ctp(<shumailov2024>) muestran que si cada generación de un modelo se entrena con textos o imágenes producidos por la anterior, los errores de estimación se acumulan generación tras generación. Las colas de la distribución se pierden, y el modelo termina produciendo una versión cada vez más estrecha de los datos: el "colapso de modelos".

=== La misma dinámica, dos desenlaces

Las tres situaciones son un *sistema dinámico*: aplicar una y otra vez una misma función. La @fig:mapa-iterado muestra los tres comportamientos posibles.

#fig("f26_mapa_iterado.svg")[Iterar una función. (a) Si la función contrae, todos los estados convergen a un punto: los errores se apagan, pero también las diferencias reales (colapso). (b) Si expande, las diferencias crecen: los errores se amplifican (divergencia). (c) Con redondeo, cada celda contrae hacia su código, pero las celdas no se mezclan: los errores dentro de una celda se borran y las diferencias entre celdas se conservan.] <fig:mapa-iterado>

- *Si el bucle contrae* (pendiente menor que 1), dos estados distintos se acercan en cada vuelta. Los errores desaparecen, *y con ellos la información*. Ese es el colapso.
- *Si el bucle expande*, dos estados cercanos se alejan. Las diferencias espurias crecen. Ese es el error acumulado, con su forma extrema, la divergencia.
- *Con redondeo*, el bucle contrae *dentro* de cada celda y deja intactas las diferencias *entre* celdas.

#rel("Respuesta a la nota del profesor")[
  No son lo mismo: el *error acumulado* es el crecimiento de diferencias que no deberían existir, y el *colapso* es la desaparición de diferencias que sí deberían existir. Pero son los *dos desenlaces de un mismo bucle* en el que la salida de un modelo vuelve a ser su entrada o su objetivo: el bucle expande (error acumulado) o contrae (colapso).

  La discretización contrae solo dentro de cada celda, y por eso corrige errores sin colapsar. Sus dos modos de falla son las versiones discretas de los dos continuos:
  - el *error silencioso* (un salto a otra celda) es el error acumulado del mundo discreto;
  - el *colapso del diccionario* (todo cae en pocas celdas) es su colapso.
]

#pensar[Con esta mirada, ¿qué hace exactamente la EMA del codificador objetivo en I-JEPA: contrae, expande o frena el bucle?]

#llevamos[
  - Hay cinco colapsos: posterior, completo, dimensional, del diccionario y neuronal. En los cuatro primeros, el latente deja de llevar información porque eso abarata la pérdida.
  - P1: en VQ-VAE no hay fuerza hacia el colapso posterior porque el KL es constante; eso se debe a la posterior determinista y la prior fija, no a la discreción. Los códigos separados ayudan por identificabilidad, si la separación se mantiene y corresponde a diferencias reales.
  - P5: el colapso del diccionario aparece en VQ-VAE, Jukebox, VQGAN, ViT-VQGAN, SoundStream, wav2vec 2.0, SwAV/DINO y en las mezclas de expertos; FSQ lo evita por construcción.
  - Lo discreto transforma el colapso en uno contable y corregible.
  - N: el error acumulado y el colapso son los dos desenlaces de un bucle de retroalimentación; el redondeo contrae dentro de las celdas y separa entre ellas.
]
