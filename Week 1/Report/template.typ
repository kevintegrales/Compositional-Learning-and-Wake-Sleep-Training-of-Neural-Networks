
#let project(
  title: "", 
  subtitle: "",
  authors: (), 
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
    author: authors.map(a => a.name), 
    title: title
  )
  
  set page(
    numbering: "1", 
    number-align: center, 
    margin: 90pt,
    footer: context [
      //#line(length: 100%, stroke: 0.5pt)
      #set align(center)
      #set text(8pt, fill: dark_color, font: "PT Sans")
      #counter(page).display(
        "1"
      )
    ],
    header: [
      #set text(size: 9pt, fill: dark_color, font: "PT Sans")
      #grid(columns: (50%, 50%), inset: 0pt)[
        *#course_name \ (#course_code, #course_semester)*
      ][
        #align(right)[
          *#title*
        ]
      ][
        #v(6pt)
        #line(length: 200%, stroke: 0.5pt + dark_color)
      ]
    ]
  )
  
  set text(
    font: "New C", 
    lang: "es", 
    size: 12pt
  )

  // Title row.
  align(center)[
    #block(
      text(
        weight: 700, 
        1.75em, 
        title, 
        fill: dark_color, 
        font: "PT Sans"
      )
    )
  ]

  // Author information.
  pad(
    top: 0.5em,
    bottom: 0.5em,
    x: 2em,
    grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(center)[
        #set text(
          fill: dark_color, 
          font: "PT Sans"
        )
        *#author.name* \
        #author.email
      ]),
    ),
  )

  // -----------------------------------------------
  // Configuración de los encabezados
  // -----------------------------------------------
  // Headings
  
  show heading.where(level: 1): it => block[
    #set text(
      font: "PT Sans", 
      fill: dark_color, 
      size: 18pt
    )
    
    #smallcaps(it)
  ]

  show heading.where(level: 2): it => block[
    #set text(
      font: "PT Sans", 
      fill: dark_color, 
      size: 14pt,
      style: "italic"
    )
    
    #smallcaps(it)
  ]

  // Saco la numeración del tercer nivel de heading en adelante
  let niveles_sin_numeracion = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
  
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
      size: 13pt
    )
    #set heading(numbering: none)
    
    #smallcaps(it)
    
  ]

  // Main body.
  set par(
    justify: true, 
    first-line-indent: 2em, 
    linebreaks: "optimized", 
    spacing: 0.6em
  )

  // Referencias
  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      // Override equation references.
      numbering(
        el.numbering,
        ..counter(eq).at(el.location())
      )
    } else {
      // Other references as usual.
      it
    }
  }

  // -----------------------------------------------
  // Configuración avanzada de los encabezados (NO mover arriba)
  // -----------------------------------------------
  
  show heading.where(level: 1): smallcaps
  set heading(numbering: (..args) => numbering("1.", ..args.pos().slice(0)))

  show heading.where(level: 1): set block(below: 0.2em)

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
    spacing: 0.7em,
    first-line-indent: 1em
  )
  
  // -----------------------------------------------
  // Configuración de las listas y enumeraciones
  // -----------------------------------------------
  
  set list(body-indent: .7em, marker: $circle.filled.small$, spacing: .9em, tight: true, indent: 1em)
  show list: set block(above: 1em, below: 1em)

  set enum(body-indent: .7em, spacing: .9em, tight: true, indent: 1em)
  show enum: set block(above: 1em, below: 1em)

  
  // -----------------------------------------------
  // Configuraciones misceláneas
  // -----------------------------------------------
  
  // Borrar estas dos líneas hace que las matrices y los vectores tengan bordes redondeados.
  set math.mat(delim: "[")
  set math.vec(delim: "[")

  body
}