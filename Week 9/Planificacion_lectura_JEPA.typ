#set document(title: "Planificación de lectura: I-JEPA y JEPA-Anything")
#set page(paper: "a4", margin: (x: 2.1cm, y: 2.1cm), numbering: "1")
#set text(font: "New Computer Modern", size: 10.5pt, lang: "es")
#set par(justify: true, leading: 0.6em, spacing: 0.9em)
#let azul = rgb("#1f4e79")
#let naranjo = rgb("#b5530f")
#show heading.where(level: 1): it => { v(0.7em); text(size: 14pt, fill: azul)[#it]; v(0.15em) }
#show heading.where(level: 2): it => { v(0.4em); text(size: 11.5pt, fill: azul)[#it]; v(0.05em) }
#set table(stroke: 0.4pt + luma(78%), inset: 5pt)
#show table.cell.where(y: 0): set text(weight: "bold")

#let tipo(t, c) = box(fill: c.lighten(88%), inset: (x: 3pt), outset: (y: 2pt), radius: 2pt, text(size: 8.5pt, fill: c, weight: "bold", t))
#let caja(c, body) = block(width: 100%, inset: 8pt, radius: 2pt, fill: c.lighten(92%), stroke: (left: 2.5pt + c), body)
#let producto(body) = caja(azul)[*Producto.* #body]

#align(center)[
  #text(size: 19pt, weight: "bold")[Planificación de lectura]
  #v(1pt)
  #text(size: 13pt)[I-JEPA y JEPA-Anything]
  #v(1pt)
  #text(size: 9.5pt, fill: luma(40%))[10 horas · del 19 de octubre al 1 de noviembre de 2026]
]
#v(6pt)

*Papers.*
- *I-JEPA:* Assran et al. (2023), _Self-Supervised Learning from Images with a Joint-Embedding Predictive Architecture_, arXiv:2301.08243 (17 págs.; 8 de cuerpo y 9 de apéndice).
- *JEPA-Anything:* Cui et al. (2026), _JEPA-Anything: Learning Predictive Models across Different Worlds_, arXiv:2609.20800 (31 págs.; 24 de cuerpo).

*Enfoque* (tomado de _Discretizar, conjeturar, refinar_). No se trata de dominar cada ecuación ni cada benchmark, sino de leer ambos papers con las dos preguntas del proyecto en mente:
+ ¿Por qué ayuda discretizar? Hay que distinguir entre los seis mecanismos: compresión, corrección de errores, multimodalidad, combinatoria, búsqueda y comunicación.
+ ¿De dónde vienen las reglas y las hipótesis, y cuándo conviene refinar y cuándo ampliar?

La regla general, como dice el .epub, es preguntarse ante cada resultado _qué mecanismo podría explicar la mejora y si el paper ofrece un experimento que permita distinguirlo_. Si no lo ofrece, eso también se anota.

= Resumen del reparto

#table(
  columns: (auto, auto, 1fr, auto),
  align: (left, center, left, right),
  table.header([Bloque], [Sesión], [Contenido], [Horas]),
  table.cell(rowspan: 3)[*Semana 1:* I-JEPA], [S1], [Orientación, prerrequisitos, idea y método], [1,5],
  [S2], [Resultados y ablaciones (lo central para nuestras preguntas)], [1,5],
  [S3], [Visualizaciones, contexto y ficha de I-JEPA], [1,5],
  table.cell(rowspan: 3)[*Semana 2:* JEPA-Anything], [S4], [Marco general: interfaz, qué es fijo y qué depende del dominio], [1,5],
  [S5], [El núcleo matemático de OPF y su auditoría empírica], [1,5],
  [S6], [Experimentos seleccionados, trabajo relacionado y ficha], [1,5],
  [*Cierre*], [S7], [Síntesis comparativa y preparación de la reunión], [1,0],
  table.cell(colspan: 3, align: right)[*Total*], [*10,0*],
)

El reparto es casi parejo a propósito. JEPA-Anything es el doble de largo, pero gran parte de su extensión son siete dominios experimentales que basta con hojear. I-JEPA, en cambio, es corto y denso en ablaciones, que es justo donde están las pistas para la pregunta 1.

*Papers anotados.* Ambos papers ya están anotados en la carpeta `Anotaciones` (`I-JEPA_anotado.pdf` y `JEPA-Anything_anotado.pdf`). Cada portada trae las cinco ideas para quedarse y la ruta de páginas por sesión. Léelos con las notas al lado.

*Cómo marcar mientras lees.* Para lo que agregues tú, lleva una lista simple de `página, párrafo o tabla, tipo, una línea de comentario`, usando los tipos de la plantilla:
- #tipo("IDEA", rgb("#5b2a86")) conexión con el .epub o con otro paper del curso.
- #tipo("CUIDADO", naranjo) afirmación fuerte con poca evidencia, notación confusa o comparación injusta.
- #tipo("EJERCICIO", rgb("#2e6b30")) algo que conviene verificar a mano.
- #tipo("APUNTE", azul) dónde está explicado un concepto que el paper da por sabido.
- #tipo("EXTRA", rgb("#5a5a5a")) detalle técnico que se puede saltar.

= Semana 1: I-JEPA (4,5 h)

== S1. Orientación y método (1,5 h)

#table(
  columns: (auto, 1fr), align: (right, left),
  table.header([Min.], [Qué hacer]),
  [15], [Releer del .epub la §1 (qué proponen los papers), la §3.8 (síntesis tentativa y tabla 2) y la *Guía A* de la §6. Tenerla a mano durante toda la semana.],
  [20], [*Prerrequisitos mínimos* (solo si no los tienes frescos): ViT y _patches_; _encoder_ objetivo actualizado por EMA, al estilo de BYOL; colapso de representaciones; MAE, que reconstruye píxeles enmascarados; métodos de invarianza a vistas, como DINO o iBOT; y evaluación por _linear probe_ y _low-shot_. Basta con una definición de una línea de cada uno.],
  [25], [Abstract, §1 Introduction, figuras 1 y 2, §2 Background. Las tres arquitecturas de la figura 2 (_joint-embedding_, generativa y predictiva en espacio de representaciones) son la idea más importante del paper.],
  [30], [§3 Method con las figuras 3 y 4: _context encoder_, _target encoder_ (EMA), _predictor_ y la estrategia de enmascarado _multi-block_ (tamaño y razón de aspecto de los bloques objetivo, tamaño del contexto).],
)
#producto[Un diagrama propio del flujo contexto, predictor y objetivo, más una respuesta de 3 o 4 líneas a la pregunta _¿qué decide no explicar cada una de las tres arquitecturas?_ (conecta con los mecanismos 3.1 y 3.3 del .epub).]

== S2. Resultados y ablaciones (1,5 h)

#table(
  columns: (auto, 1fr), align: (right, left),
  table.header([Min.], [Qué hacer]),
  [25], [§5 a §7 en lectura rápida: tablas 1 a 5 y figura 5. Solo hay que retener *qué se afirma*: buen rendimiento semántico _sin aumentos de datos hechos a mano_, mejor que MAE en tareas de bajo nivel y más eficiente en cómputo. No hace falta memorizar números.],
  [25], [§9 Ablations: *tabla 6* (estrategia de enmascarado) y *tabla 7* (predecir píxeles o representaciones). Esta última es la evidencia directa de que predecir en espacio abstracto importa.],
  [40], [Apéndice C, en este orden: *tablas 8, 9 y 10* (tamaño de bloque objetivo, tamaño de contexto y número de objetivos), que corresponden a la pregunta del _nivel básico_ y de _quién elige la escala_; *tabla 14* (ancho del predictor), que es la pista de _¿discreción o cuello de botella?_; y luego las tablas 11 a 13 en lectura rápida.],
)
#producto[Para cada tabla clave, una línea con el formato _resultado / mecanismo del .epub que podría explicarlo / ¿el experimento permite distinguirlo?_]

== S3. Visualizaciones, contexto y ficha (1,5 h)

#table(
  columns: (auto, 1fr), align: (right, left),
  table.header([Min.], [Qué hacer]),
  [25], [§8 y figura 6, más el apéndice E (figuras 7 y 8, RCDM): qué conserva la predicción (forma, pose, posición) y qué descarta (detalles finos, textura). Conecta con la §3.7 del .epub, _lo que se pierde_.],
  [15], [§4 Related Work y §10 Conclusion. Hojear el apéndice B solo si alguna referencia te llama la atención.],
  [50], [*Ficha de I-JEPA* (1 página): tesis, 3 resultados con su evidencia, 2 o 3 afirmaciones que no quedan bien respaldadas, conexiones con las preguntas 1 y 3 del .epub y la lista de pasajes marcados para anotar.],
)
*Se puede saltar:* el apéndice A (hiperparámetros) y el apéndice D (_fine-tuning_ completo).

= Semana 2: JEPA-Anything (4,5 h)

== S4. Marco general (1,5 h)

#table(
  columns: (auto, 1fr), align: (right, left),
  table.header([Min.], [Qué hacer]),
  [10], [Releer la *Guía B* del .epub y repasar tu ficha de I-JEPA.],
  [30], [Abstract, figura 1 y §1 Introduction. Lo que hay que identificar es el diagnóstico central: un objetivo "monolítico" mezcla modos predictivos y eso se plantea como un *problema de asignación de capacidad predictiva* (pág. 3).],
  [25], [§2.1 y *tabla 1*: qué depende del dominio (adaptador, _view sampler_, _encoder_) y qué es común (núcleo OPF). Conecta con _lo innato y lo adquirido_ (.epub §4.3): ¿qué hace aquí de conocimiento "de fábrica"?],
  [25], [§2.4: los tres modos de uso (modo representación, modo operacional de modelo del mundo y análisis por factores) y la figura 2. Hojear la tabla 2 solo para ver que $K$ es casi siempre 4 o 5.],
)
#producto[Un diagrama propio de JEPA-Anything que muestre qué pieza agrega respecto de I-JEPA. Debería caber en una línea: proyectar el objetivo en $K$ subespacios ortogonales, usar un predictor por factor y recomponer con la pseudoinversa.]

== S5. El núcleo matemático de OPF (1,5 h)

El .epub sugiere quedarse con la idea y no con las ecuaciones. Aun así, esta parte es álgebra lineal elemental y es justo donde vive el argumento de *estabilidad* (mecanismo 3.2), así que vale la pena hacerla a mano.

#table(
  columns: (auto, 1fr), align: (right, left),
  table.header([Min.], [Qué hacer]),
  [35], [§2.2, ecuaciones (3) a (7): proyectores, predictores por factor, síntesis por pseudoinversa (5) y pérdida de ortogonalidad dentro de cada factor y entre factores (7).],
  [25], [*Proposición 1 y corolario 1*, más la *proposición 2* del apéndice A. #tipo("EJERCICIO", rgb("#2e6b30")) con $d = 4$ y $K = 2$, construye un ejemplo con direcciones repetidas y otro con direcciones casi repetidas, y comprueba cómo crece el número de condición y cómo se amplifica el error de los factores.],
  [15], [§2.3, ecuaciones (9) y (10): el piso de actividad por factor y la varianza del _encoder_. Compáralos con VICReg y Barlow Twins, que conectan con Barlow y la redundancia (.epub §3.1).],
  [15], [§3.3.1, *tabla 5* (auditoría del mecanismo): la contraparte empírica de la proposición 1. Pregunta del .epub: ¿esta vía, sin discretizar valores, es una alternativa a discretizar o _otra forma de lo mismo_?],
)
#producto[Una explicación propia de media página sobre por qué la ortogonalidad garantiza una recomposición estable, y qué tendría que pasar para que esa garantía se perdiera.]

== S6. Experimentos seleccionados y ficha (1,5 h)

Los experimentos no merecen todos la misma atención. Para nuestras preguntas, el orden de prioridad es este:

#table(
  columns: (auto, 1.4fr, 1fr), align: (right, left, left),
  table.header([Min.], [Qué hacer], [Por qué]),
  [20], [§3.1 (lógica de evaluación con _baselines_ pareados) y el resto de *§3.3.1, CITRIS Pong*, con la figura 4: predecir *combinaciones de intervenciones nunca vistas*.], [Es la prueba más cercana a la generalización composicional.],
  [20], [*§3.3.3 y §3.3.4*, figuras 6 y 7: $K in {1, 2, 4, 8}$, Hopper como contraejemplo, sondas por factor ($R^2 approx 0.3$–$0.4$) y enmascarar un factor. Revisa también la *tabla 10* del apéndice B.], [Corresponde a la pregunta 4 (_¿cuántos factores necesita un mundo?_) y a la pregunta 5 (_¿es un factor una regla?_).],
  [15], [*§3.4*, el uso científico: IL-18 + CD73 y la ley de Kepler (pendiente $-1.4991$).], [Sirve para preguntarse si esto es _abducción_ (descubrir) o _reconocimiento_ (recuperar algo ya conocido), como en la §2.2 del .epub.],
  [10], [Lectura rápida: §3.2.1–3.2.3, §3.3.2 y §3.3.5. De cada una, solo el párrafo *Question* y la frase final con el resultado.], [Fíjate en el *tamaño* de las mejoras (por ejemplo, en la tabla 3: .572 → .581).],
  [10], [§4 Related Work, sobre todo el párrafo de _structured and factorized representations_ (Locatello: el _disentanglement_ no supervisado no es identificable), más §5 y §6.], [],
  [15], [*Ficha de JEPA-Anything*, con el mismo formato que la de I-JEPA.], [],
)

#caja(naranjo)[#tipo("CUIDADO", naranjo) La Guía B del .epub remite a la "sección 6" para buscar las limitaciones que reconocen los autores. La §6 es _Future Work_ y no hay una sección de limitaciones como tal, pero su último párrafo (pág. 25) sí reconoce varias: calibrar la incertidumbre, saber cuándo el modelo es confiable, revisar los factores cuando falte estructura, que los factores no establecen causalidad y que una arquitectura común no garantiza representaciones alineadas entre dominios. Además admiten que en Hopper gana el JEPA estándar (§3.3.3 y §5). Otras limitaciones, como que nunca se comparan valores de $K$, hay que reconstruirlas leyendo los resultados.]

= S7. Cierre: síntesis y reunión (1,0 h)

#table(
  columns: (auto, 1fr), align: (right, left),
  table.header([Min.], [Qué hacer]),
  [20], [*Tabla comparativa* de I-JEPA frente a JEPA-Anything: qué se predice, qué se discretiza (la tarea en I-JEPA, la estructura en OPF), quién decide los cortes (los diseñadores, o el aprendizaje con $K$ fijo) y qué mecanismo del .epub queda mejor respaldado en cada caso.],
  [25], [Responder en 3 a 5 líneas cada una de las preguntas 1, 3, 4, 5 y 6 de la §7 del .epub, con referencias a página y tabla.],
  [15], [Elegir *2 o 3 preguntas para el profesor* y dejar lista la lista de pasajes marcados para la anotación en Typst.],
)

= Si te atrasas

Recorta en este orden. Ninguno de estos puntos afecta lo esencial:
+ Las tablas 1 a 5 de I-JEPA (basta con saber qué afirman).
+ Los experimentos de lectura rápida de JEPA-Anything (§3.2 y §3.3.2, §3.3.5).
+ El apéndice E de I-JEPA (con la figura 6 basta).
+ El ejercicio a mano de S5 (se reduce a leer bien el corolario 1 y la tabla 5).

*Nunca recortes:* la figura 2 y las tablas 7, 8 a 10 y 14 de I-JEPA, ni las §2.2, la tabla 5 y las §3.3.1, §3.3.3 y §3.3.4 de JEPA-Anything.

= Calendario sugerido

#table(
  columns: (auto, 1fr),
  table.header([Semana], [Sesiones]),
  [19 al 25 de octubre], [S1 (lun), S2 (mié), S3 (vie)],
  [26 de octubre al 1 de noviembre], [S4 (lun), S5 (mié), S6 (vie), S7 (antes de la reunión)],
)
