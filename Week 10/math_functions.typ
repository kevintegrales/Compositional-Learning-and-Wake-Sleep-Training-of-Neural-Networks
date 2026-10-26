// ***********************************************
// Funciones personalizadas
// ***********************************************

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
#let azul = rgb("B600BD")
#let gris = rgb("5800BD")
#let rosa = rgb("BD0065")
#let verde = rgb("5800BD")

// Parámetros visuales comunes a todos los bloques
#let estilo_bloque = (
  aclarado_fondo: 95%, // qué tanto se aclara el color para el fondo
  oscurecido_texto: 50%, // qué tanto se oscurece el color para el texto del cuerpo
  grosor_borde: 1pt,
  relleno: (left: 8pt, right: 6pt, y: 6pt),
  espacio: 1.2em, // espacio antes y después del bloque
  sangria_listas: 0em, // sangría izquierda de listas y enumeraciones dentro del bloque (fuera es 1em, ver template.typ)
)

// -----------------------------------------------
// Funciones de contenido
// -----------------------------------------------
// Contador de los bloques numerados (se reinicia en cada capítulo, ver template.typ)
#let c = counter("theorem")

// Bloque base: título coloreado sobre una caja con borde izquierdo y fondo claro.
//   nombre:     "Teorema", "Definición", ...
//   color:      color principal del bloque
//   subtitulo:  título opcional que aparece junto al nombre
//   numerado:   si el bloque lleva número (capítulo.sección.n)
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

    // Título: nunca queda solo al final de una página (sticky)
    #block(sticky: true, below: 0.6em)[
      #set text(font: cf.your_title_font, fill: color)
      #strong(nombre)
      #if numerado {
        context strong(counter(heading).display() + c.display())
      }
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
      #set text(font: cf.your_body_font, fill: color_texto.darken(50%))
      #set par(
        justify: true,
        first-line-indent: 0em,
        linebreaks: "optimized",
        spacing: 1em,
      )
      #set list(indent: estilo_bloque.sangria_listas)
      #set enum(indent: estilo_bloque.sangria_listas)
      // El relleno inferior de las listas (template.typ) pasa a ser espacio 'below',
      // que se descarta al final de la caja: así una lista al final no deja un hueco.
      #show list: set block(inset: (top: 2pt, bottom: 0pt), below: 0.5em + 5pt)
      #show enum: set block(inset: (top: 5pt, bottom: 0pt), below: 0.5em + 5pt)
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
// ahora `#teo[Título][...]` y `#teot[Título][...]` son equivalentes.
#let teo = entorno("Teorema", azul)
#let prop = entorno("Proposición", azul)
#let cor = entorno("Corolario", azul)
#let lema = entorno("Lema", azul)
#let def = entorno("Definición", gris, color_texto: gris.darken(60%))
#let ex = entorno("Ejemplo", gris, color_texto: gris.darken(60%))
#let algo = entorno("Algoritmo", gris)
#let nota = entorno("Nota", rosa)

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
#let qep = box(square(fill: verde, size: 5pt))

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

// Funciones short
#let qquad = $space.quad$

#let SSS = $cal(S)$
#let AAA = $cal(A)$
#let RRR = $cal(R)$
#let BBB = $cal(B)$

#let phia = $phi.alt$
