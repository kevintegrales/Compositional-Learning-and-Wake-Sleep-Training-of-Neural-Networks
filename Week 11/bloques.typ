// ***********************************************
// Recuadros del capítulo (PDF y EPUB)
// ***********************************************
// Con `--input formato=html` cada recuadro se emite como un elemento HTML con
// una clase, que el CSS del EPUB dibuja. En el PDF se dibujan aquí mismo.

#import "plantilla.typ": negro, gris-tinta, gris-claro, rosa, rosa-claro, rosa-tinta

#let es-html = sys.inputs.at("formato", default: "pdf") == "html"

#let caja-html(clase, titulo, cuerpo) = html.elem("div", attrs: (class: clase))[
  #if titulo != none { html.elem("p", attrs: (class: "titulo-caja"))[#titulo] }
  #cuerpo
]

#let rotulo(t, color: rosa-tinta) = text(fill: color, weight: "semibold", tracking: 0.04em)[#smallcaps(t)]

// Idea base: concepto que se explica justo antes de usarlo
#let idea(titulo, cuerpo) = if es-html {
  caja-html("idea", [Idea base · #titulo], cuerpo)
} else {
  block(width: 100%, fill: rgb("f6f6f6"), stroke: (left: 2pt + negro), inset: (x: 11pt, y: 9pt),
    above: 1.3em, below: 1.3em, breakable: true)[
    #rotulo([Idea base], color: negro) #h(0.4em) #text(style: "italic")[#titulo]
    #v(0.2em)
    #set text(size: 10.5pt)
    #cuerpo
  ]
}

// Cierre de cada capítulo
#let llevamos(cuerpo) = if es-html {
  caja-html("llevamos", [Qué nos llevamos], cuerpo)
} else {
  block(width: 100%, fill: rosa-claro, stroke: 0.8pt + rosa, radius: 3pt, inset: (x: 12pt, y: 10pt),
    above: 1.5em, below: 1.2em, breakable: false)[
    #rotulo[Qué nos llevamos]
    #v(0.15em)
    #cuerpo
  ]
}

// Apertura de cada capítulo
#let frase(cuerpo) = if es-html {
  caja-html("frase", [En una frase], emph(cuerpo))
} else {
  block(width: 100%, stroke: (top: 0.8pt + rosa, bottom: 0.8pt + rosa), inset: (x: 4pt, y: 10pt),
    above: 0.6em, below: 1.6em)[
    #rotulo[En una frase] #h(0.3em) #text(size: 11.5pt, style: "italic")[#cuerpo]
  ]
}

// Pregunta corta para el lector
#let pensar(cuerpo) = if es-html {
  caja-html("pensar", [Para pensar], emph(cuerpo))
} else {
  block(width: 100%, stroke: (left: 2.5pt + rosa), inset: (left: 11pt, right: 4pt, y: 6pt),
    above: 1.2em, below: 1.2em)[
    #rotulo[Para pensar] #h(0.3em) #emph(cuerpo)
  ]
}

// Recuadro destacado (respuestas, principios)
#let rel(titulo, cuerpo) = if es-html {
  caja-html("destacado", titulo, cuerpo)
} else {
  block(width: 100%, stroke: 0.9pt + negro, radius: 2pt, clip: true, above: 1.4em, below: 1.4em,
    breakable: true)[
    #block(width: 100%, fill: rosa, inset: (x: 11pt, y: 6pt), below: 0pt)[#text(weight: "semibold")[#titulo]]
    #block(inset: (x: 11pt, y: 9pt))[#cuerpo]
  ]
}

// Respuesta corta de las conclusiones
#let respuesta(id, pregunta, cuerpo) = if es-html {
  caja-html("respuesta", [#id. #emph(pregunta)], cuerpo)
} else {
  block(width: 100%, stroke: (left: 2pt + rosa), inset: (x: 11pt, y: 7pt), above: 1em,
    below: 1em, breakable: false)[
    #text(weight: "bold")[#id.] #emph(pregunta) \
    #cuerpo
  ]
}

// Nota de fuente bajo el título de cada paper
#let notat(titulo, cuerpo) = if es-html {
  caja-html("fuente", none, [#rotulo(titulo). #cuerpo])
} else {
  block(width: 100%, stroke: (left: 0.6pt + gris-claro), inset: (left: 9pt, y: 3pt),
    above: 0.6em, below: 1.1em)[
    #set text(size: 9.5pt, fill: gris-tinta)
    #rotulo(titulo). #cuerpo
  ]
}

#let fuente_link(url, texto) = link(url)[\[#texto\]]

// Etiquetas de grado de certeza
#let etiqueta(texto, relleno, tinta, borde) = if es-html {
  html.elem("span", attrs: (class: "etiqueta " + texto))[#texto]
} else {
  box(fill: relleno, stroke: 0.6pt + borde, inset: (x: 4pt, y: 1.6pt), outset: (y: 1pt),
    radius: 6pt)[#text(size: 8pt, fill: tinta, tracking: 0.03em)[#smallcaps(texto)]]
}

#let est = etiqueta("establecido", negro, white, negro)
#let sug = etiqueta("sugerido", rosa, negro, rosa)
#let conj = etiqueta("conjetura", white, rosa-tinta, rosa-tinta)

// Ficha con la que termina la presentación de cada modelo
#let ficha(discretiza: none, mejora: none, empeora: none, pieza: none) = {
  let filas = (
    ([Qué se discretiza], discretiza),
    ([Qué mejora], mejora),
    ([Qué empeora o cuesta], empeora),
    ([Pieza del paquete], pieza),
  )
  if es-html {
    caja-html("ficha", none, table(columns: 2, ..filas.map(((a, b)) => (strong(a), b)).flatten()))
  } else {
    block(width: 100%, stroke: (top: 0.8pt + negro, bottom: 0.8pt + negro), inset: (x: 2pt, y: 9pt),
      above: 1.3em, below: 1.3em, breakable: false)[
      #set text(size: 10pt)
      #grid(columns: (auto, 1fr), column-gutter: 14pt, row-gutter: 8pt,
        ..filas.map(((a, b)) => (rotulo(a), b)).flatten())
    ]
  }
}

// Pieza del paquete: número en un círculo negro
#let pieza(n) = if es-html {
  html.elem("span", attrs: (class: "pieza"))[#str(n)]
} else {
  box(width: 10.5pt, height: 10.5pt, radius: 5.25pt, fill: negro, baseline: 1.8pt,
    align(center + horizon, text(size: 7pt, fill: white, weight: "bold", str(n))))
}

// Figuras: SVG en el PDF; PNG en el EPUB (los lectores Kindle no muestran bien SVG)
#let fig(archivo, ancho: 100%, flota: true, caption) = figure(
  if es-html {
    html.elem("img", attrs: (src: "figuras/" + archivo.replace(".svg", ".png"), class: "figura"))
  } else {
    image("/figures/" + archivo, width: ancho)
  },
  caption: caption,
  placement: if flota and not es-html { auto } else { none },
)

// Citas: se usa cite() y no @clave para no depender de reglas de `ref`.
#let ct(clave) = cite(clave)
#let ctp(clave) = cite(clave, form: "prose")
