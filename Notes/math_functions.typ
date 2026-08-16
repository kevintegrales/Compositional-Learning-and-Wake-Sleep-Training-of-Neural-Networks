// ***********************************************
// Funciones persolanizadas
// ***********************************************

#import "config.typ" as cf

// Estas funciones permiten escribir las diferenciales como 'dx' en el modo matemática en vez de 'dif x'
#let dy = $dif y$
#let dx = $dif x$
#let dt = $dif t$

// -----------------------------------------------
// Funciones de contenido
// -----------------------------------------------
#let c = counter("theorem")

// Template
#let math_block_template(
  title: "", 
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
    first-line-indent: 2em, 
    linebreaks: "simple", 
    spacing: 0.6em
  )
  
  #set text(
    fill: black 
  )

  #c.step()
  #box()[
    *#title #context {
      counter(heading).display() 
      c.display()
    }.*
  ]
  #body
  
  #v(-13pt)  #h(1fr) #h(5pt) #sym.space.nobreak 
  #box()[#rect(fill: black, width: 4pt, height: 7pt)]
]

#let math_block_template_t(
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
    first-line-indent: 2em, 
    linebreaks: "simple", 
    spacing: 0.6em
  )
  
  #set text(
    fill: black 
  )

  #c.step()
  #box()[
    *#title #context {
      counter(heading).display() 
      c.display()
    }.* (#subtitle).
  ]
  #body
  
  #v(-13pt) #h(1fr) #h(5pt) #sym.space.nobreak 
  #box()[#rect(fill: black, width: 4pt, height: 7pt)]
]

// Definición
#let def(body) = math_block_template(
  title: "Definición",
  body
)

#let deft(title, body) = math_block_template_t(
  title: "Definición",
  subtitle: title,
  body
)

// Teoremas
#let teo(body) = math_block_template(
  title: "Teorema",
  body
)

#let teot(title, body) = math_block_template_t(
  title: "Teorema",
  subtitle: title,
  body
)

// Proposición
#let prop(body) = math_block_template(
  title: "Proposición",
  body
)

#let propt(title, body) = math_block_template_t( 
  title: "Proposición",
  subtitle: title,
  body
)

// Corolario
#let cor(body) = math_block_template(
  title: "Corolario",
  body
)

#let cort(title, body) = math_block_template_t( 
  title: "Corolario",
  subtitle: title,
  body
)

// Lema
#let lema(body) = math_block_template(
  title: "Lema",
  body
)

#let lemat(title, body) = math_block_template_t(
  title: "Lema",
  subtitle: title,
  body
)

// Nota
#let nota(body) = math_block_template(
  title: "Nota",
  body
)

#let notat(title, body) = math_block_template_t(
  title: "Nota",
  subtitle: title,
  body
)

// Ejemplo
#let ex(body) = math_block_template(
  title: "Ejemplo",
  body
)

#let ext(title, body) = math_block_template_t(
  title: "Ejemplo",
  subtitle: title,
  body
)

// Algoritmo
#let algo(body) = math_block_template(
  title: "Algoritmo",
  body
)

#let algot(title, body) = math_block_template_t(
  title: "Algoritmo",
  subtitle: title,
  body
)

//--------- Desc -------------
#let desc(body) = box(width: 100%)[#body]
#let todo() = box(fill: yellow, inset: 5pt, width: 100%)[#set align(center)
TO-DO]

// Demostración
#let proof(titulo: "Demostración", cuerpo) = {
  // Muestra el título, p. ej., "Prueba." en negrita, y un salto de línea.
  emph(titulo + ".")

  // Inserta el contenido de la prueba.
  cuerpo

  // 1. Retrocede verticalmente para compensar el espacio extra
  //    después de listas o ecuaciones en bloque.
  v(-1.1em)

  // 2. AGREGA UN ESPACIO NO SEPARABLE como búfer.
  sym.space.nobreak 

  // 2. Inserta un espacio horizontal que se expande para llenar
  //    la línea.
  h(1fr)

  // 3. Dibuja el símbolo de fin de prueba (Q.E.D.).
  sym.qed
}