// Funciones de contenido
#let dark_col = rgb("3F88C5")
#let gray = rgb("#393E41")
#let mypink = rgb("E7684B")
#let mygreen = rgb("318776")
  
// Q.E.P.
#let qep() = align(square(fill: mygreen, size: 5pt), right)

// Teoremas
#let theo(title, body) = block(width:100%, inset: 0pt, radius: 0pt, below: 1.2em, above: 1.2em, breakable: false)[
  #set par(justify: true, first-line-indent: 2em, linebreaks: "optimized", spacing: 1.2em)
  #set text(fill: dark_col, font: "PT Sans")
  #block(inset: (y: -3pt))[
    *Teorema* #h(1em) #title 
  ] 
  #align(center)[
    #block(stroke: (left: dark_col + 1pt), outset: 4.5pt, width: 97%, fill: dark_col.lighten(95%), radius: 0pt)[
      #align(left)[
        #set text(fill: dark_col.darken(50%), font: "Libertinus Serif")
        #body
      ]
    ]
  ]
]

// Demostraciones
#let demo(title, body) = block(width:100%, inset: 0pt, radius: 0pt, below: 1.2em, above: 1.2em, breakable: false)[
  #set par(justify: true, first-line-indent: 2em, linebreaks: "optimized", spacing: 1.2em)
  #set text(fill: mygreen, font: "PT Sans")
  #block(inset: (y: -3pt))[
    *Demostración* #h(1em) #title 
  ] 
  #align(center)[
    #block(stroke: (left: mygreen + 1pt), outset: 4.5pt, width: 97%, fill: mygreen.lighten(95%), radius: 0pt)[
      #align(left)[
        #set text(fill: mygreen.darken(50%), font: "Libertinus Serif")
        #body
      ]
    ]
  ]
]


// Definición
#let def(title, body) = block(width:100%, inset: 0pt, radius: 0pt, below: 1.2em, above: 1.2em, breakable: false)[
  #set par(justify: true, first-line-indent: 2em, linebreaks: "optimized", spacing: 1.2em)
  #set text(fill: gray, font: "PT Sans")
  #block(inset: (y: -3pt))[
    *Definición* #h(1em) #title 
  ] 
  #align(center)[
    #block(stroke: (left: gray + 1pt), outset: 4.5pt, width: 97%, fill: gray.lighten(95%), radius: 0pt)[
      #align(left)[
        #set text(fill: gray.darken(60%), font: "Libertinus Serif")
        #body
      ]
    ]
  ]
]


// Nota
#let nota(title, body) = block(width:100%, inset: 0pt, radius: 0pt, below: 1.2em, above: 1.2em, breakable: false)[
  #set par(justify: true, first-line-indent: 2em, linebreaks: "optimized", spacing: 1.2em)
  #set text(fill: mypink, font: "PT Sans")
  #block(inset: (y: -3pt))[
    *Nota* #h(1em) #title 
  ] 
  #align(center)[
    #block(stroke: (left: mypink + 1pt), outset: 4.5pt, width: 97%, fill: mypink.lighten(95%), radius: 0pt)[
      #align(left)[
        #set text(fill: mypink.darken(50%), font: "Libertinus Serif")
        #body
      ]
    ]
  ]
]



// Recomendación
#let rec(body) = block(width:100%, inset: 0pt, radius: 0pt, below: 1.2em, above: 1.2em, breakable: false)[
  #set par(justify: true, first-line-indent: 2em, linebreaks: "optimized", spacing: 1.2em)
  #set text(fill: mygreen, font: "PT Sans")
  #block(inset: (y: -3pt))[
    *Recomendación* 
  ] 
  #align(center)[
    #block(stroke: (left: mygreen + 1pt), outset: 4.5pt, width: 97%, fill: mygreen.lighten(95%), radius: 0pt)[
      #align(left)[
        #set text(fill: mygreen.darken(50%), font: "Libertinus Serif")
        #body
      ]
    ]
  ]
]




// Relevante
#let rel(title, body) = block(width:100%, inset: 0pt, radius: 0pt, below: 1.2em, above: 1.2em, breakable: false)[
  #set par(justify: true, first-line-indent: 2em, linebreaks: "optimized", spacing: 1.2em)
  #set text(fill: dark_col, font: "PT Sans")
  #block(inset: (y: -3pt))[
    *#title* 
  ] 
  #align(center)[
    #block(stroke: (left: dark_col + 1pt), outset: 4.5pt, width: 97%, fill: dark_col.lighten(95%), radius: 0pt)[
      #align(left)[
        #set text(fill: black, font: "Libertinus Serif")
        #body
      ]
    ]
  ]
]

// Ejemplos
#let ex(body) = block(width:100%, inset: 0pt, radius: 0pt, below: 1.2em, above: 1.2em, breakable: false)[
  #set par(justify: true, first-line-indent: 2em, linebreaks: "optimized", spacing: 1.2em)
  #set text(fill: gray, font: "PT Sans")
  #block(inset: (y: -3pt))[
    *Ejemplo* #h(1em) 
  ] 
  #align(center)[
    #block(stroke: (left: gray + 1pt), outset: 4.5pt, width: 97%, fill: gray.lighten(95%), radius: 0pt)[
      #align(left)[
        #set text(fill: gray.darken(60%), font: "Libertinus Serif")
        #body
      ]
    ]
  ]
]

//--------- Desc -------------
#let desc(body) = block(width: 100%)[#body]



//------------ Estilo ----------
#let headstyle(body) = [
  #set text(fill: dark_col, font: "PT Sans") 
  #strong(body)
]