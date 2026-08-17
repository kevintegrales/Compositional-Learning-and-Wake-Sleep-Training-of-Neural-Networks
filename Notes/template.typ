#import "@preview/hydra:0.4.0": hydra
#import "math_functions.typ": c

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
  body
) = {
  
  // Definiciones de colores
  let dark_color = rgb(principal_color)
  let gray_color = dark_color.lighten(50%)
  let light_color = rgb(secondary_color)
  let light_gray_color = light_color.darken(20%)

  set document(
    author: author.name, 
    title: title
  )

  // -----------------------------------------------
  // Configuración de la portada
  // -----------------------------------------------
  
  set page(
    number-align: center,
    margin: 90pt,
    fill: light_gray_color.lighten(80%),
    "us-letter"
  )

  // Texto
  set text(
    font: body_font, 
    lang: "es", 
    fill: gray.darken(90%)
  )
  
  show math.equation: set text(
    font: math_font
  )

  // Portada
  // Título y subtítulo
  pad([
      #par(leading: 15pt)[
        #align(center)[
        #set text(font: "PT Sans", weight: 550, size: 36pt, style: "normal", fill: dark_color)
          #title
        ]
        \
        #set text(size: 19pt, style: "oblique", font: "PT Sans", fill: dark_color)
        #subtitle
      ]
  ], top: 80%, bottom: 2%)

  // Información de autor
  pad(
    align(left)[
        #set text(
          font: "PT Sans", 
          fill: dark_color
        )
        
        *#author.name* \
        #author.email       
    ],
    top: 0%
  )


  // -----------------------------------------------
  // Configuración de las páginas
  // -----------------------------------------------
  
  set page(
    fill: white,
    // Línea inferior de la página
    footer: context [
      #set align(center)
      #set text(
        8pt, 
        font: title_font, 
        fill: gray_color
      )
      #counter(page).display(
        "1"
      )
    ],
    numbering: "1"  
  )

  set text(size: 10pt)

  // -----------------------------------------------
  // Configuración de los encabezados
  // -----------------------------------------------
  // Headings
  set heading(numbering: "I.1.")
  
  show heading.where(level: 1): it => block[
    #set text(
      font: title_font, 
      fill: dark_color, 
      size: 18pt
    )

    #c.update(c => 0)
    
    #smallcaps(it)
  ]

  show heading.where(level: 2): it => block[
    #set text(
      font: title_font, 
      fill: dark_color, 
      size: 16pt
    )

    #c.update(c => 0)
    
    #smallcaps(it)
  ]

  // Saco la numeración del tercer nivel de heading en adelante
  let niveles_sin_numeracion = (3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
  
  show selector.or(
    ..niveles_sin_numeracion.map(n => heading.where(level: n))
  ): set heading(numbering: none) 
  
  show heading.where(level: 3): it => block[
    
    #set text(
      font: title_font, 
      fill: dark_color, 
      size: 14pt
    )
    #set heading(numbering: none)
    
    #smallcaps(it)
    
  ]

  // Hago que el nivel 4 en adelante de heading sea idéntico
  show heading.where(level: 4)
    .or(heading.where(level: 5))
    .or(heading.where(level: 6))
    .or(heading.where(level: 7))
    .or(heading.where(level: 8))
    .or(heading.where(level: 9))
    .or(heading.where(level: 10))
    .or(heading.where(level: 11))
    .or(heading.where(level: 12)): it => block[
      
    #set text(
      font: title_font, 
      fill: gray_color, 
      style: "italic", 
      size: 12pt
    )
    #set heading(numbering: none)
    
    #smallcaps(it)
    
  ]

  // -----------------------------------------------
  // Configuración del outline de contenidos
  // -----------------------------------------------
  
  show outline.entry.where(
    level: 1
  ): it => {
    v(
      15pt, 
      weak: true
    )
    set text(
      font: title_font, 
      size: 12pt, 
      fill: dark_color
    )
    strong(it)
  }

  show outline.entry.where(
    level: 2
  ): it => {
    v(
      6pt, 
      weak: true
    )
    set text(
      font: title_font, 
      size: 11pt, 
      fill: light_gray_color
    )
    h(20pt)
    it 
  }

  show outline.entry.where(
    level: 3
  ): it => {
    v(
      6pt, 
      weak: true
    )
    set text(
      font: title_font, 
      size: 10pt, 
      fill: light_gray_color
    )
    it 
  }

  outline(title: "Contenidos", depth: 3)
  
  // Main body.
  set par(
    justify: true, 
    first-line-indent: 2em, 
    linebreaks: "simple", 
    spacing: 0.6em
  )

  // Referencias
  show ref: it => {
    let eq = math.equation
    let el = it.element

    // Ecuaciones
    if el != none and el.func() == eq {
      // Override equation references.
      numbering(
        el.numbering,
        ..counter(eq).at(el.location())
      )
      
    // Encabezados
    } else if el.func() == heading {

      set text(fill: dark_color)
      // Prepara el contenido a mostrar.
      let display_content = el.body
  
      // Si el encabezado tiene numeración (no es 'none')...
      if el.numbering != none {
        // 1. Obtiene el número formateado del encabezado en su ubicación.
        let num = numbering(
          el.numbering,
          ..counter(heading).at(el.location())
        )
        // 2. Compone el nuevo contenido: "Número + Espacio + Título".
        display_content = [#num #el.body]
      }
  
      // 3. Crea el enlace con el contenido (numerado o no).
      link(el.location(), display_content)
      
    } else {
      it
    }
  }

  // -----------------------------------------------
  // Configuración avanzada de los encabezados (NO mover arriba)
  // -----------------------------------------------
  
  show heading.where(level: 1): smallcaps
  set heading(numbering: (..args) => numbering("1.", ..args.pos().slice(0)))
  
  show heading.where(level: 1): set heading(
    numbering: (..args) => box(width: 1.5em, align(left, numbering("I", ..args))),
    supplement: [Chapter],
  )

  show heading: set block(below: 1em)

  set page(margin: (x: 120pt))

  // -----------------------------------------------
  // Configuración de las figuras
  // -----------------------------------------------
  
  set figure.caption(separator: [ --- ])
  show figure.caption: it => context box(
    inset: (left: 1em, right: 1em),
    align(left)[
      #box[
        #set text(fill: gray)
        *#it.supplement~#it.counter.display()*
        #it.separator
      ] #it.body
    ]
  )
  
  show figure: set block(spacing: 1.5em)
  
  set par(
    linebreaks: "optimized",
    spacing: .5em,
    first-line-indent: 1em
  )
  
  // -----------------------------------------------
  // Configuración de las listas y enumeraciones
  // -----------------------------------------------
  
  set list(body-indent: .7em, marker: $circle.filled.small$, spacing: .9em, tight: false, indent: 1em)
  show list: set block(above: 0.5em, below: 0.5em, inset: (bottom: 5pt, top: 2pt))

  set enum(body-indent: .7em, spacing: .9em, tight: false, indent: 1em)
  show enum: set block(above: 0.5em, below: 0.5em, inset: (bottom: 5pt, top: 5pt))


  // -----------------------------------------------
  // Configuraciones misceláneas
  // -----------------------------------------------
  
  // Borrar estas dos líneas hace que las matrices y los vectores tengan bordes redondeados.
  set math.mat(delim: "[")
  set math.vec(delim: "[")
  show math.equation: set block(breakable: true)

  pagebreak()
  
  body
}

