// ***********************************************
// Funciones personalizadas
// ***********************************************
// Versión para diapositivas de Notes/math_functions.typ: los entornos tienen la
// misma sintaxis (`#teo[cuerpo]`, `#teo[Título][cuerpo]`, `#nota`, `#rel`, ...),
// así que se puede copiar contenido de las notas directamente a las diapositivas.

#import "config.typ" as cf

// Estas funciones permiten escribir las diferenciales como 'dx' en el modo matemática en vez de 'dif x'
#let dy = $dif y$
#let dx = $dif x$
#let dt = $dif t$
#let proport = $prop$

// -----------------------------------------------
// Paleta de colores de los bloques
// -----------------------------------------------
// Cambiar un color aquí lo cambia en todos los bloques que lo usan.
#let azul = rgb("BD0065")
#let gris = rgb("#400089")
#let rosa = rgb("BD0065")
#let verde = rgb("#400089")

// Parámetros visuales comunes a todos los bloques
#let estilo_bloque = (
  aclarado_fondo: 92%, // qué tanto se aclara el color para el fondo
  oscurecido_texto: 50%, // qué tanto se oscurece el color para el texto del cuerpo
  grosor_borde: 2pt,
  relleno: (left: 10pt, right: 8pt, y: 8pt),
  espacio: 0.9em, // espacio antes y después del bloque
  sangria_listas: 0em, // sangría izquierda de listas y enumeraciones dentro del bloque
  tamano_texto: 0.92em, // tamaño del texto del cuerpo respecto al de la diapositiva
)

// -----------------------------------------------
// Funciones de contenido
// -----------------------------------------------
// Contador de los bloques numerados (se reinicia en cada sección, ver template.typ)
#let c = counter("theorem")

// Número de un bloque: "II.3" (sección en romanos + contador del bloque)
#let numero_bloque() = {
  let seccion = counter(heading).get().first()
  if seccion > 0 [#numbering("I", seccion).#c.display()] else [#c.display()]
}

// Bloque base: título coloreado sobre una caja con borde izquierdo y fondo claro.
//   nombre:     "Teorema", "Definición", ...
//   color:      color principal del bloque
//   subtitulo:  título opcional que aparece junto al nombre
//   numerado:   si el bloque lleva número (sección.n)
//   color_texto: color del cuerpo; auto = el color oscurecido
//   marca_final: símbolo al final del cuerpo (p. ej. ∎ en demostraciones)
#let bloque_matematico(
  nombre: "",
  color: gris,
  subtitulo: none,
  numerado: true,
  color_texto: auto,
  marca_final: none,
  cuerpo,
) = {
  let color_texto = if color_texto == auto {
    color.darken(estilo_bloque.oscurecido_texto)
  } else { color_texto }

  block(
    width: 100%,
    above: estilo_bloque.espacio,
    below: estilo_bloque.espacio,
    breakable: true,
  )[
    #if numerado { c.step() }

    // Título: nunca queda solo al final de una diapositiva (sticky)
    #block(sticky: true, below: 0.5em)[
      #set text(font: cf.your_title_font, fill: color)
      #strong(nombre)
      #if numerado { context strong(numero_bloque()) }
      #if subtitulo != none [#h(0.8em) #subtitulo]
    ]

    // Caja del cuerpo
    #block(
      width: 100%,
      fill: color.lighten(estilo_bloque.aclarado_fondo),
      stroke: (left: color + estilo_bloque.grosor_borde),
      inset: estilo_bloque.relleno,
      breakable: true,
    )[
      #set text(
        font: cf.your_body_font,
        fill: color_texto.darken(50%),
        size: estilo_bloque.tamano_texto,
      )
      #set par(
        justify: true,
        first-line-indent: 0em,
        linebreaks: "optimized",
        spacing: 0.8em,
      )
      #set list(indent: estilo_bloque.sangria_listas)
      #set enum(indent: estilo_bloque.sangria_listas)
      #show list: set block(above: 0.6em, below: 0.6em)
      #show enum: set block(above: 0.6em, below: 0.6em)
      #cuerpo
      #if marca_final != none [#h(1fr) #marca_final]
    ]
  ]
}

// Crea una función de bloque que acepta tanto `#f[cuerpo]` como `#f[título][cuerpo]`.
#let entorno(nombre, color, ..opciones) = (..args) => {
  let pos = args.pos()
  assert(
    pos.len() in (1, 2),
    message: nombre + ": se esperaba [cuerpo] o [título][cuerpo]",
  )
  let (subtitulo, cuerpo) = if pos.len() == 2 { pos } else { (none, pos.first()) }
  bloque_matematico(
    nombre: nombre,
    color: color,
    subtitulo: subtitulo,
    ..opciones.named(),
    ..args.named(),
    cuerpo,
  )
}

// Entornos numerados. Las versiones terminadas en 't' se mantienen por compatibilidad:
// `#teo[Título][...]` y `#teot[Título][...]` son equivalentes.
#let teo = entorno("Teorema", azul)
#let prop = entorno("Proposición", azul)
#let cor = entorno("Corolario", azul)
#let lema = entorno("Lema", azul)
#let def = entorno("Definición", gris, color_texto: gris.darken(60%))
#let ex = entorno("Ejemplo", gris, color_texto: gris.darken(60%))
#let algo = entorno("Algoritmo", gris)
// En las diapositivas las notas no se numeran (son comentarios al margen del contenido)
#let nota = entorno("Nota", rosa, numerado: false)

#let teot = teo
#let propt = prop
#let cort = cor
#let lemat = lema
#let deft = def
#let ext = ex
#let algot = algo
#let notat = nota

// Link de fuente: se muestra como [texto] en rosa
#let fuente_link(url, texto) = text(fill: rosa)[#link(url)[\[#texto\]]]

// Entornos sin numeración
#let rec = entorno("Recomendación", verde, numerado: false)

// Relevante: el título reemplaza al nombre del bloque
#let rel(titulo, cuerpo) = bloque_matematico(
  nombre: titulo,
  color: azul,
  numerado: false,
  color_texto: black,
  cuerpo,
)

// Q.E.D.: cuadrado verde al final de las demostraciones
#let qep = box(square(fill: verde, size: 6pt))

// Demostración
#let proof(titulo: "Demostración", cuerpo) = bloque_matematico(
  nombre: titulo,
  color: verde,
  numerado: false,
  marca_final: qep,
  cuerpo,
)

//--------- Desc -------------
#let desc(body) = box(width: 100%)[#body]
#let todo() = box(fill: yellow, inset: 5pt, width: 100%)[#set align(center)
TO-DO]

//------------ Estilo ----------
#let headstyle(body) = [
  #set text(fill: azul, font: cf.your_title_font)
  #strong(body)
]

// -----------------------------------------------
// Funciones exclusivas de las diapositivas
// -----------------------------------------------

// Ecuación destacada: caja centrada con un rótulo a la derecha.
//   #eqn[ELBO][$ log p(x) >= cal(L) $]
#let eqn(titulo, contenido) = align(center, block(breakable: false)[
  #grid(
    columns: 2,
    column-gutter: 10pt,
    align: horizon,
    block(
      stroke: rosa + 0.5pt,
      inset: 8pt,
      fill: rosa.lighten(92%),
      radius: 5pt
    )[
      #set text(fill: rosa.darken(70%))
      #contenido
    ],
    text(font: cf.your_title_font, fill: rosa, size: 0.85em, strong(smallcaps(titulo))),
  )
])

// Fuente de un paper en una línea (versión compacta de `#notat[Fuente][...]`).
//   #fuente(url: "https://arxiv.org/abs/...", texto: "arXiv:...")[_Título_, A. Autor et al. (2024).]
//   #fuente[_Libro_, A. Autor.]   (sin enlace)
#let fuente(url: none, texto: none, referencia) = block(
  width: 100%,
  above: 0.4em,
  below: 0.9em,
  stroke: (left: rosa + 2pt),
  inset: (left: 10pt, y: 4pt),
)[
  #set text(size: 0.75em, fill: rosa.darken(50%))
  #text(font: cf.your_title_font, fill: rosa, weight: "bold")[Fuente] #h(0.6em)
  #referencia
  #if url != none [#h(0.4em) #fuente_link(url, if texto == none { url } else { texto })]
]

// Dos columnas con separación estándar: #columnas[izquierda][derecha]
#let columnas(proporcion: (1fr, 1fr), izquierda, derecha) = grid(
  columns: proporcion,
  column-gutter: 24pt,
  izquierda, derecha,
)

// -----------------------------------------------
// Preguntas para la discusión
// -----------------------------------------------

// Enunciado de una pregunta del profesor, numerada como en su lista.
//   #pregunta(4)[Título][Enunciado]
#let pregunta(numero, titulo, cuerpo) = bloque_matematico(
  nombre: "Pregunta " + str(numero),
  color: rosa,
  subtitulo: titulo,
  numerado: false,
  color_texto: black,
  cuerpo,
)

// Guía de estudio: sub-preguntas para orientar la respuesta (no son la respuesta).
#let guia(cuerpo) = block(width: 100%, above: 0.6em, below: 0.6em)[
  #set text(size: 0.85em)
  #text(font: cf.your_title_font, fill: gris, weight: "bold")[Para pensar] \
  #cuerpo
]

// Recuadro para la propuesta de respuesta.
//   #respuesta()          -> recuadro vacío "por completar" que ocupa el resto de la diapositiva
//   #respuesta[Mi texto]  -> recuadro con la respuesta ya escrita
#let respuesta(alto: 1fr, ..cuerpo) = {
  let contenido = cuerpo.pos()
  let vacia = contenido.len() == 0 or contenido.first() == []
  block(
    width: 100%,
    height: if vacia { alto } else { auto },
    stroke: (paint: gris.lighten(30%), thickness: 1pt, dash: "dashed"),
    fill: white.transparentize(30%),
    inset: 10pt,
    breakable: true,
  )[
    #text(font: cf.your_title_font, fill: gris, weight: "bold")[Propuesta de respuesta]
    #if vacia [
      #h(0.5em) #text(size: 0.8em, fill: gray, style: "italic")[(por completar)]
    ] else [
      \ #contenido.first()
    ]
  ]
}

// Funciones short
#let qquad = $space.quad$

#let SSS = $cal(S)$
#let AAA = $cal(A)$
#let RRR = $cal(R)$
#let BBB = $cal(B)$

#let phia = $phi.alt$

// Notación de VAEs (en las notas se define al inicio de cada capítulo)
#let xx = $bold(x)$
#let yy = $bold(y)$
#let zz = $bold(z)$
#let neunet = $"NeuralNet"$
#let ttheta = $bold(theta)$
#let pphia = $bold(phia)$
#let elbo = $cal(L)_(ttheta, pphia)$
#let KL = $D_"KL" (q_pphia (zz|xx) || p_ttheta (zz|xx))$
#let eeps = $bold(epsilon.alt)$
