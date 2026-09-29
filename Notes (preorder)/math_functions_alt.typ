// ***********************************************
// Funciones persolanizadas
// ***********************************************

#import "config.typ" as cf

// Estas funciones permiten escribir las diferenciales como 'dx' en el modo matemática en vez de 'dif x'
#let dy = $dif y$
#let dx = $dif x$
#let dt = $dif t$

// Definiciones de colores
#let dark_color = rgb(cf.your_principal_color)
#let gray_color = dark_color.lighten(40%)
#let light_color = rgb(cf.your_secondary_color)
#let light_gray_color = light_color.darken(20%)

// -----------------------------------------------
// Funciones de contenido
// -----------------------------------------------

#let c = counter("theorems")

// Template
#let math_block_template(
  color: dark_color, 
  title: "", 
  subtitle: "",
  body
) = block(
  width:100%, 
  inset: 0pt, 
  radius: 0pt, 
  below: 1.2em, 
  above: 1.2em, 
  breakable: true
)[
  #set par(
    justify: true, 
    first-line-indent: 1em, 
    linebreaks: "optimized", 
    spacing: 0.6em
  )
  
  #set text(
    fill: color, 
    font: cf.your_title_font
  )
  
  #block(inset: (y: -3pt))[
    *#title #c.step()
    #box()[
      *#context {
        counter(heading).display() 
        c.display()
      } *
    ]* #h(1em) #subtitle 
  ]
  
  #align(center)[
    #block(
      stroke: (left: color + 1pt), 
      outset: 4.5pt, 
      width: 97%, 
      fill: color.lighten(90%), 
      radius: 0pt, 
      inset: 1pt
    )[
      #align(left)[
        #set text(
          fill: color.darken(70%), 
          font: cf.your_body_font
        )
        #set par(spacing: 0.6em)
        
        #body
      ]
    ]
  ]
]

// Definición
#let def_color = dark_color
#let def(body) = math_block_template(
  color: def_color, 
  title: "Definición",
  subtitle: "",
  body
)

#let deft(title, body) = math_block_template(
  color: def_color, 
  title: "Definición",
  subtitle: title,
  body
)

// Teoremas
#let teo_color = gray_color
#let teo(body) = math_block_template(
  color: teo_color, 
  title: "Teorema",
  subtitle: "",
  body
)

#let teot(title, body) = math_block_template(
  color: teo_color, 
  title: "Teorema",
  subtitle: title,
  body
)

// Proposición
#let prop_color = gray_color
#let prop(body) = math_block_template(
  color: prop_color, 
  title: "Proposición",
  subtitle: "",
  body
)

#let propt(title, body) = math_block_template(
  color: prop_color, 
  title: "Proposición",
  subtitle: title,
  body
)

// Lema
#let lema_color = gray_color
#let lema(body) = math_block_template(
  color: lema_color, 
  title: "Lema",
  subtitle: "",
  body
)

#let lemat(title, body) = math_block_template(
  color: lema_color, 
  title: "Lema",
  subtitle: title,
  body
)

// Corolario
#let cor_color = gray_color
#let cor(body) = math_block_template(
  color: cor_color, 
  title: "Corolario",
  subtitle: "",
  body
)

#let cort(title, body) = math_block_template(
  color: cor_color, 
  title: "Corolario",
  subtitle: title,
  body
)

// Nota
#let nota_color = light_color
#let nota(body) = math_block_template(
  color: nota_color,
  title: "Nota",
  subtitle: "",
  body
)

#let notat(title, body) = math_block_template(
  color: nota_color,
  title: "Nota",
  subtitle: title,
  body
)

// Ejemplo
#let ex_color = light_color
#let ex(body) = math_block_template(
  color: nota_color,
  title: "Ejemplo",
  subtitle: "",
  body
)

#let ext(title, body) = math_block_template(
  color: nota_color,
  title: "Ejemplo",
  subtitle: title,
  body
)

// Demostración
#let proof(body) = {
  block(
    width: 100%,
    fill: none,
  )[
    _Demostración._
    #body
    #h(1fr) #h(5pt)
    #box()[#square(fill: gray_color, size: 7pt)]
  ]
}


//--------- Desc -------------
#let desc(body) = block(width: 100%)[#body]
#let todo() = box(fill: yellow, inset: 5pt, width: 100%)[#set align(center)
TO-DO]

// ***********************************************
// Funciones persolanizadas
// ***********************************************

#import "config.typ" as cf

// Estas funciones permiten escribir las diferenciales como 'dx' en el modo matemática en vez de 'dif x'
#let dy = $dif y$
#let dx = $dif x$
#let dt = $dif t$

// Definiciones de colores
#let dark_color = rgb(cf.your_principal_color)
#let gray_color = dark_color.lighten(40%)
#let light_color = rgb(cf.your_secondary_color)
#let light_gray_color = light_color.darken(20%)

// -----------------------------------------------
// Funciones de contenido
// -----------------------------------------------

#let c = counter("theorems")

// Template
#let math_block_template(
  color: dark_color, 
  title: "", 
  subtitle: "",
  body
) = block(
  width:100%, 
  inset: 0pt, 
  radius: 0pt, 
  below: 1.2em, 
  above: 1.2em, 
  breakable: false
)[
  #set par(
    justify: true, 
    first-line-indent: 1em, 
    linebreaks: "optimized", 
    spacing: 1.2em
  )
  
  #set text(
    fill: color, 
    font: cf.your_title_font
  )
  
  #block(inset: (y: -3pt))[
    *#title #c.step()
    #box()[
      *#context {
        counter(heading).display() 
        c.display()
      } *
    ]* #h(1em) #subtitle 
  ]
  
  #align(center)[
    #block(
      stroke: (left: color + 1pt), 
      outset: 4.5pt, 
      width: 97%, 
      fill: color.lighten(90%), 
      radius: 0pt, 
      inset: 1pt
    )[
      #align(left)[
        #set text(
          fill: color.darken(70%), 
          font: cf.your_body_font
        )
        #set par(spacing: 0.6em)
        
        #body
      ]
    ]
  ]
]

// Definición
#let def_color = dark_color
#let def(body) = math_block_template(
  color: def_color, 
  title: "Definición",
  subtitle: "",
  body
)

#let deft(title, body) = math_block_template(
  color: def_color, 
  title: "Definición",
  subtitle: title,
  body
)

// Teoremas
#let teo_color = gray_color
#let teo(body) = math_block_template(
  color: teo_color, 
  title: "Teorema",
  subtitle: "",
  body
)

#let teot(title, body) = math_block_template(
  color: teo_color, 
  title: "Teorema",
  subtitle: title,
  body
)

// Proposición
#let prop_color = gray_color
#let prop(body) = math_block_template(
  color: prop_color, 
  title: "Proposición",
  subtitle: "",
  body
)

#let propt(title, body) = math_block_template(
  color: prop_color, 
  title: "Proposición",
  subtitle: title,
  body
)

// Lema
#let lema_color = gray_color
#let lema(body) = math_block_template(
  color: lema_color, 
  title: "Lema",
  subtitle: "",
  body
)

#let lemat(title, body) = math_block_template(
  color: lema_color, 
  title: "Lema",
  subtitle: title,
  body
)

// Corolario
#let cor_color = gray_color
#let cor(body) = math_block_template(
  color: cor_color, 
  title: "Corolario",
  subtitle: "",
  body
)

#let cort(title, body) = math_block_template(
  color: cor_color, 
  title: "Corolario",
  subtitle: title,
  body
)

// Nota
#let nota_color = light_color
#let nota(body) = math_block_template(
  color: nota_color,
  title: "Nota",
  subtitle: "",
  body
)

#let notat(title, body) = math_block_template(
  color: nota_color,
  title: "Nota",
  subtitle: title,
  body
)

// Ejemplo
#let ex_color = light_color
#let ex(body) = math_block_template(
  color: nota_color,
  title: "Ejemplo",
  subtitle: "",
  body
)

#let ext(title, body) = math_block_template(
  color: nota_color,
  title: "Ejemplo",
  subtitle: title,
  body
)

// Demostración
#let proof(body) = {
  block(
    width: 100%,
    fill: none,
  )[
    _Demostración._
    #body
    #h(1fr) #h(5pt)
    #box()[#square(fill: gray_color, size: 7pt)]
  ]
}


//--------- Desc -------------
#let desc(body) = block(width: 100%)[#body]
#let todo() = box(fill: yellow, inset: 5pt, width: 100%)[#set align(center)
TO-DO]
