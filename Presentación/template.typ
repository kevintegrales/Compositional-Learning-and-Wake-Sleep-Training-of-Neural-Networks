#import "math_functions.typ": c
#import "portada.typ": portada

// Recibe los mismos parámetros que `project` de Notes/template.typ, más el cuadro de la portada.
//   = Sección      -> diapositiva separadora (numerada en romanos, como los capítulos de las notas)
//   == Título      -> empieza una diapositiva nueva
//   === Subtítulo  -> subtítulo dentro de la diapositiva
// Para continuar un mismo tema en otra diapositiva, usa #pagebreak().
#let project(
  title: "",
  subtitle: "",
  author: (),
  course_code: "",
  course_name: "",
  course_semester: "",
  title_font: "",
  body_font: "",
  math_font: "",
  principal_color: "",
  secondary_color: "",
  painting: (:),
  contraportada: true,
  body,
) = {
  // Definiciones de colores
  let dark_color = rgb(principal_color)
  let light_color = rgb(secondary_color)
  let gray_color = light_color
  let fondo = dark_color.lighten(96%)

  // Tamaño 16:9
  let ancho = 853pt
  let alto = 480pt

  set document(author: author.name, title: title)

  set text(font: body_font, lang: "es", size: 16pt, fill: gray.darken(90%))
  show math.equation: set text(font: math_font)

  let datos_portada = (
    title: title,
    subtitle: subtitle,
    author: author,
    course_code: course_code,
    course_name: course_name,
    course_semester: course_semester,
    title_font: title_font,
    painting: painting,
    ancho: ancho,
    alto: alto,
  )

  // -----------------------------------------------
  // Portada
  // -----------------------------------------------
  portada(..datos_portada)

  // -----------------------------------------------
  // Configuración de las diapositivas
  // -----------------------------------------------
  set page(
    width: ancho,
    height: alto,
    margin: (x: 70pt, top: 85pt, bottom: 45pt),
    fill: white,
    header: context {
      set text(size: 12pt, fill: dark_color, font: title_font)
      // A la derecha: la sección actual (incluida la que empieza en esta diapositiva)
      let en_pagina = query(heading.where(level: 1)).filter(h => h.location().page() == here().page())
      let previas = query(heading.where(level: 1).before(here()))
      let seccion = if en_pagina.len() > 0 { en_pagina.first().body } else if previas.len() > 0 { previas.last().body }
      grid(
        columns: (1fr, auto),
        align: (left + bottom, right + bottom),
        [*#course_name \ (#course_code, #course_semester)*],
        if seccion != none [*#seccion*],
      )
      v(-4pt)
      line(length: 100%, stroke: 0.5pt + dark_color)
    },
    footer: context {
      set align(center)
      set text(size: 10pt, font: title_font, fill: gray_color)
      counter(page).display("1")
    },
    numbering: "1",
  )

  // -----------------------------------------------
  // Configuración de los encabezados
  // -----------------------------------------------
  set heading(numbering: (..n) => if n.pos().len() == 1 { numbering("I", ..n.pos()) })

  // Sección: diapositiva separadora
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    
    //----------------------
    set page(
      width: ancho,
      height: alto,
      margin: (x: 70pt, top: 85pt, bottom: 45pt),
      fill: dark_color,
      header: context {
        set text(size: 12pt, fill: white, font: title_font)
        // A la derecha: la sección actual (incluida la que empieza en esta diapositiva)
        let en_pagina = query(heading.where(level: 1)).filter(h => h.location().page() == here().page())
        let previas = query(heading.where(level: 1).before(here()))
        let seccion = if en_pagina.len() > 0 { en_pagina.first().body } else if previas.len() > 0 { previas.last().body }
        grid(
          columns: (1fr, auto),
          align: (left + bottom, right + bottom),
          [*#course_name \ (#course_code, #course_semester)*],
          if seccion != none [*#seccion*],
        )
        v(-4pt)
        line(length: 100%, stroke: 0.5pt + white)
      },
      footer: context {
        set align(center)
        set text(size: 10pt, font: title_font, fill: white)
        counter(page).display("1")
      },
      numbering: "1",
    )
    //----------------------

    c.update(0)
    v(3fr)
    block(width: 100%)[
      #set text(font: title_font, fill: white)
      #text(size: 25pt, fill: white.lighten((20%)), weight: 700, counter(heading).display("I"))
      #v(-6pt)
      #text(size: 34pt, weight: 700, smallcaps(it.body))
      #v(-10pt)
      #line(length: 40%, stroke: 1.5pt + white.lighten(20%))
    ]
    v(1fr)
    pagebreak(weak: true)
  }

  // Título de diapositiva
  show heading.where(level: 2): it => {
    pagebreak(weak: true)
    block(below: 0.8em)[
      #set text(font: title_font, fill: dark_color, size: 24pt, weight: 700)
      #smallcaps(it.body)
    ]
  }

  show heading.where(level: 3): it => block(above: 1em, below: 0.6em)[
    #set text(font: title_font, fill: gray_color, size: 18pt, weight: 700)
    #smallcaps(it.body)
  ]

  show heading.where(level: 4): it => block(above: 0.8em, below: 0.5em)[
    #set text(font: title_font, fill: gray_color, style: "italic", size: 14pt)
    #smallcaps(it.body)
  ]

  // -----------------------------------------------
  // Configuración del outline de contenidos
  // -----------------------------------------------
  show outline.entry.where(level: 1): it => {
    v(18pt, weak: true)
    set text(font: title_font, size: 16pt, fill: dark_color)
    link(it.element.location(), strong[#it.prefix() #h(0.5em) #it.body()])
  }

  // -----------------------------------------------
  // Configuración de las figuras
  // -----------------------------------------------
  set figure.caption(separator: [ --- ])
  show figure.caption: it => context box(
    inset: (left: 1em, right: 1em),
    align(left)[
      #set text(size: 12pt)
      #box[
        #set text(fill: gray)
        *#it.supplement~#it.counter.display()*
        #it.separator
      ] #it.body
    ],
  )
  show figure: set block(spacing: 1em)

  // Referencias a secciones: se muestran como enlace con el nombre de la sección
  show ref: it => {
    let el = it.element
    if el != none and el.func() == heading {
      set text(fill: dark_color)
      link(el.location(), el.body)
    } else { it }
  }

  // -----------------------------------------------
  // Configuración de las listas y enumeraciones
  // -----------------------------------------------
  set list(body-indent: .7em, marker: text(fill: dark_color, $circle.filled.small$), spacing: .8em, tight: false, indent: 1em)
  show list: set block(above: 0.7em, below: 0.7em)

  set enum(body-indent: .7em, spacing: .8em, tight: false, indent: 1em)
  show enum: set block(above: 0.7em, below: 0.7em)

  // Main body.
  set par(justify: true, first-line-indent: 0em, linebreaks: "optimized", spacing: 0.9em)

  // -----------------------------------------------
  // Configuraciones misceláneas
  // -----------------------------------------------
  set math.mat(delim: "[")
  set math.vec(delim: "[")
  set table(stroke: 0.5pt + dark_color.lighten(50%), inset: 6pt)
  show table: set text(size: 13pt)

  body

  // -----------------------------------------------
  // Contraportada
  // -----------------------------------------------
  if contraportada { portada(..datos_portada) }
}
