// ***********************************************
// Plantilla "libro": negro y rosa pastel, fuente Libertinus Serif (la de Typst)
// ***********************************************

// Paleta
#let negro = rgb("1a1a1a")
#let gris-tinta = rgb("5c5c5c")
#let gris-claro = rgb("d9d9d9")
#let rosa = rgb("f4c2d4")        // rosa pastel: líneas, rellenos y acentos
#let rosa-claro = rgb("fdf1f5")  // fondo de recuadros
#let rosa-tinta = rgb("b5467a")  // rosa oscuro, solo para texto que debe leerse

#let fuente = "Libertinus Serif"
#let fuente-mate = "New Computer Modern Math"

#let libro(
  titulo: "",
  subtitulo: "",
  autor: "",
  correo: "",
  contexto: "",
  fecha: "",
  cuerpo,
) = {
  set document(title: titulo, author: autor)
  set text(font: fuente, size: 11pt, lang: "es", fill: negro)
  show math.equation: set text(font: fuente-mate)
  set par(justify: true, leading: 0.68em, spacing: 1.05em)

  // ---------------- Portada ----------------
  set page(paper: "us-letter", margin: (x: 3cm, top: 3cm, bottom: 2.8cm))
  page(margin: 0pt)[
    #place(left + top, rect(width: 1.1cm, height: 100%, fill: rosa))
    #pad(left: 3.4cm, right: 2.6cm, top: 5.5cm)[
      #text(size: 10pt, tracking: 0.18em, fill: gris-tinta)[#smallcaps(contexto)]
      #v(1.8cm)
      #par(justify: false, leading: 0.5em)[#text(size: 30pt)[#titulo]]
      #v(0.6cm)
      #line(length: 3.5cm, stroke: 2pt + rosa)
      #v(0.6cm)
      #par(justify: false)[#text(size: 14pt, style: "italic", fill: gris-tinta)[#subtitulo]]
      #v(1fr)
      #text(size: 12pt)[#autor] \
      #text(size: 10pt, fill: gris-tinta)[#correo] \
      #v(0.3cm)
      #text(size: 10pt, fill: gris-tinta)[#fecha]
      #v(3cm)
    ]
  ]

  // ---------------- Encabezados ----------------
  set heading(numbering: (..n) => {
    let n = n.pos()
    if n.len() == 1 { numbering("I", ..n) } else if n.len() == 2 { numbering("I.1", ..n) }
  })

  show heading.where(level: 1): it => {
    set par(justify: false)
    v(1.5cm)
    if it.numbering != none {
      text(size: 10.5pt, tracking: 0.2em, fill: rosa-tinta)[
        #smallcaps[Capítulo #context counter(heading).display("I")]
      ]
      v(0.35em)
    }
    block(text(size: 25pt, it.body))
    v(0.2em)
    line(length: 2.8cm, stroke: 1.5pt + rosa)
    v(1.2em)
  }

  show heading.where(level: 2): it => block(above: 1.7em, below: 0.85em, sticky: true)[
    #set par(justify: false)
    #if it.numbering != none [
      #text(fill: rosa-tinta)[#context counter(heading).display()]
      #h(0.55em)
    ]
    #text(size: 14.5pt, weight: "semibold", it.body)
  ]

  show heading.where(level: 3): it => block(above: 1.4em, below: 0.7em, sticky: true)[
    #set par(justify: false)
    #text(size: 12pt, style: "italic", it.body)
  ]

  // ---------------- Páginas interiores ----------------
  set page(
    header: context {
      let aqui = here().page()
      let empieza = query(heading.where(level: 1)).any(h => h.location().page() == aqui)
      let previos = query(heading.where(level: 1).before(here()))
      if not empieza and previos.len() > 0 {
        let cab = previos.last()
        set text(size: 9pt, fill: gris-tinta)
        if cab.numbering != none [
          #smallcaps[#numbering("I", ..counter(heading).at(cab.location())) · #cab.body]
        ] else [#smallcaps(cab.body)]
        h(1fr)
        v(-0.5em)
        line(length: 100%, stroke: 0.4pt + rosa)
      }
    },
    footer: context {
      set align(center)
      text(size: 9pt, fill: gris-tinta)[#counter(page).display()]
    },
  )
  counter(page).update(1)

  // ---------------- Índice ----------------
  show outline.entry.where(level: 1): it => {
    v(0.9em, weak: true)
    strong(it)
  }
  outline(title: [Contenidos], depth: 2, indent: 1.5em)
  pagebreak()

  // ---------------- Elementos ----------------
  set list(marker: text(fill: rosa-tinta)[•], indent: 0.6em, body-indent: 0.6em)
  set enum(indent: 0.6em, body-indent: 0.6em, numbering: n => text(fill: rosa-tinta)[#n.])
  show link: set text(fill: rosa-tinta)

  set figure.caption(separator: [. ])
  show figure.caption: it => {
    set text(size: 9.5pt)
    set par(justify: true)
    block(width: 92%)[
      #text(fill: rosa-tinta, weight: "bold")[#it.supplement #context it.counter.display(it.numbering)]#it.separator#it.body
    ]
  }
  show figure: set block(spacing: 1.6em)

  set table(stroke: none)
  show table: set text(size: 9.5pt)
  show figure.where(kind: table): set block(breakable: true)

  set math.mat(delim: "[")
  set math.vec(delim: "[")

  cuerpo
}
