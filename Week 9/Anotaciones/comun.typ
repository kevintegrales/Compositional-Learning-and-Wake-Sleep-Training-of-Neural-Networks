// Elementos compartidos por las anotaciones de I-JEPA y JEPA-Anything.
#import "/Plantilla de anotaciones/motor.typ": *

// Tipos de nota, pensados para la lectura con las dos preguntas del proyecto.
#let tipos-jepa = (
  clave: (color: rgb("#5b2a86"), rotulo: "CLAVE", desc: [Idea esencial: lo que conviene recordar del paper.]),
  pregunta: (color: rgb("#be185d"), rotulo: "PREGUNTA", desc: [Conexión con P1, P2, los mecanismos M1–M6 o las preguntas C1–C10 del .epub.]),
  profundizar: (color: rgb("#0f766e"), rotulo: "PROFUNDIZAR", desc: [Para más adelante: lecturas, experimentos que faltan, extensiones posibles.]),
  cuidado: (color: rgb("#b5530f"), rotulo: "CUIDADO", desc: [Límites de la evidencia, comparaciones dudosas, erratas.]),
  apunte: (color: rgb("#1f4e79"), rotulo: "APUNTE", desc: [Concepto previo o notación que el paper da por sabida.]),
  ejercicio: (color: rgb("#2e6b30"), rotulo: "EJERCICIO", desc: [Algo que conviene verificar a mano.]),
  extra: (color: rgb("#5a5a5a"), rotulo: "EXTRA", desc: [Detalle que se puede saltar en una primera lectura.]),
)

// Atajo para notas del margen izquierdo (columna izquierda en papers a dos columnas).
#let ni(y0, y1, tipo, cuerpo, r: none) = n(y0, y1, tipo, cuerpo, r: r, lado: "izq")

// Tabla de etiquetas del material de apoyo (Discretizar, conjeturar, refinar).
#let etiquetas = [
  *Etiquetas usadas en las notas*
  #v(2pt)
  Remiten a _Discretizar, conjeturar, refinar_ (abreviado *ep.*), y las sesiones a la planificación de lectura.
  #v(4pt)
  #set text(size: 7.8pt)
  #table(
    columns: (auto, 1fr), stroke: 0.4pt + luma(80%), inset: 3.6pt,
    [*P1*], [¿Por qué, al discretizar, mejoran los algoritmos? ¿Qué principios son comunes?],
    [*P2*], [¿Cómo se modelan las reglas? ¿Qué genera las hipótesis? ¿Cuándo refinar y cuándo ampliar?],
    table.cell(colspan: 2, fill: luma(95%))[*Mecanismos* (ep. §3)],
    [*M1*], [Compresión y navaja de Occam (§3.1)],
    [*M2*], [Corrección de errores y estabilidad (§3.2)],
    [*M3*], [Multimodalidad: elegir en vez de promediar (§3.3)],
    [*M4*], [Combinatoria sin mezcla, principio particulado (§3.4)],
    [*M5*], [Búsqueda y enumeración (§3.5)],
    [*M6*], [Comunicación y transmisión (§3.6)],
    [*§3.7*], [Lo que se pierde al discretizar],
    table.cell(colspan: 2, fill: luma(95%))[*Preguntas concretas* (ep. §7)],
    [*C1*], [¿Discretización, cuello de botella o largo variable?],
    [*C2*], [¿Qué mecanismo actúa en cada caso?],
    [*C3*], [¿Dónde está el nivel básico?],
    [*C4*], [¿Cuántos factores necesita un mundo?],
    [*C5*], [¿Es un factor una regla?],
    [*C6*], [¿De dónde salen las hipótesis en cada modelo?],
    [*C7*], [¿Cuándo pasar de refinar a reemplazar?],
    [*C8*], [Varias tareas: ¿reutilizar o crear?],
    [*C9*], [¿Qué parte es innata?],
    [*C10*], [¿Qué hace el sueño con las reglas?],
  )
]
