#import "/math_functions.typ": *
#import "/bloques.typ": *

#heading(numbering: none)[Cómo leer este capítulo]
#set heading(numbering: none)

Este texto reúne, en forma de capítulo de libro, lo que se sabe hoy sobre una pregunta que nos acompaña desde hace varias semanas: *¿por qué, al discretizar ciertos espacios, mejoran los algoritmos?* No intenta resumir todos los papers del área. Intenta que, al terminar, se pueda responder con argumentos a las preguntas que nos dejó el profesor y a dos preguntas que quedaron abiertas.

== Las preguntas que responde

#table(
  columns: (auto, 1fr, auto),
  stroke: none,
  inset: (x: 5pt, y: 4pt),
  table.hline(stroke: 0.6pt),
  table.header([*Id*], [*Pregunta*], [*Capítulo*]),
  table.hline(stroke: 0.4pt),
  [P1], [Al entrenar por gradiente aparece el colapso (en especial, el colapso posterior). ¿Es más difícil que ocurra con una representación discreta? ¿Ayuda partir con códigos bien separados?], [VII],
  [P2], [¿Qué evidencia hizo pensar que discretizar ayuda, sobre todo en aprendizaje por refuerzo? ¿Dónde gana lo continuo?], [IV],
  [P3], [Si la discretización resuelve un problema, ¿qué experimento lo comprueba o lo desmiente? ¿Qué produce la mejora?], [VI],
  [P4], [En la familia JEPA, ¿alguien discretiza? ¿Por qué?], [VIII],
  [P5], [¿En qué modelos ocurre el colapso del diccionario (_codebook collapse_)?], [VII],
  [N], [Nota del profesor: _"accumulated errors =?= collapse"_.], [V y VII],
  [A1], [¿Es la discreción misma la que da ventajas, o alguna propiedad que viene con ella? ¿Hay un principio más allá?], [VI],
  [A2], [¿Qué comparten los espacios donde conviene discretizar, y aquellos donde no conviene?], [IX],
  [E], [¿Qué significa que la discretización "permite seguir el error"?], [V],
  table.hline(stroke: 0.6pt),
)

Las preguntas A1 y A2 no tienen una respuesta establecida en la literatura. Para ellas, el capítulo llega a una conjetura respaldada por la evidencia y propone cómo ponerla a prueba.

== Qué se da por sabido

Se da por conocido lo que está en nuestros apuntes: el VAE, el VQ-VAE, la Gumbel-Softmax, el colapso posterior, DreamerV3, LPN, NLI e I-JEPA. Cada uno se recuerda en pocas líneas cuando aparece. Todo lo demás se explica antes de usarse, en recuadros como este:

#idea[Ejemplo][Una _idea base_ explica en pocas líneas un concepto que el texto necesita y que no vimos en el curso. Si ya se conoce, se puede saltar.]

== Convenciones

- *Color.* En todas las figuras, #text(fill: rgb("2a78d6"))[*azul*] es continuo y #text(fill: rgb("eb6834"))[*naranjo*] es discreto.
- *Certeza.* Las afirmaciones importantes llevan una etiqueta. #est significa que hay un experimento controlado que la respalda. #sug, que hay evidencia indirecta. #conj, que es una propuesta nuestra.
- *Piezas.* La introducción define seis "piezas" de la discretización, numeradas del #pieza(1) al #pieza(6). Cuando un resultado se atribuye a una pieza, se marca con su número.
- *Recuadros.* Cada capítulo abre con *En una frase* y cierra con *Qué nos llevamos*. Leídos seguidos, los cierres forman un resumen. Los recuadros *Para pensar* son preguntas cortas para detenerse un momento; responderlas no es necesario para seguir.

== Calendario sugerido (una semana)

#table(
  columns: (auto, 1fr),
  stroke: none,
  inset: (x: 5pt, y: 3pt),
  table.hline(stroke: 0.6pt),
  [*Día 1*], [Introducción y capítulo II (Fundamentos).],
  [*Día 2*], [Capítulos III (Cómo se discretiza) y IV, hasta Meyer et al.],
  [*Día 3*], [Resto del capítulo IV y capítulo V (Seguir el error).],
  [*Día 4*], [Capítulos VI y VII.],
  [*Día 5*], [Capítulos VIII, IX y X.],
  table.hline(stroke: 0.6pt),
)
