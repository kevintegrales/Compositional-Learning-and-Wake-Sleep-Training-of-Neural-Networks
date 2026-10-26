// Entrada para la versión EPUB. Se compila a HTML con
//   tinymist compile --root . --input formato=html epub.typ epub/libro.html
// y después `epub/construir_epub.py` arma el .epub.

#set document(title: [¿Qué gana y qué pierde un modelo al discretizar?], author: "Kevin Cardemil Ulloa")
#set text(lang: "es", size: 11pt, font: "Libertinus Serif")
#show math.equation: set text(font: "New Computer Modern Math")

// Cada ecuación se exporta como imagen (SVG que después se rasteriza a PNG).
// Las inline llevan un "puntal" invisible de ancho cero: 0,72em sobre la línea base y
// 0,22em bajo ella. Así el centro de la imagen queda 0,25em sobre la línea base (la mitad
// de la altura de las minúsculas) y `vertical-align: middle` (Kindle) la alinea con el
// texto; en lectores que ignoran vertical-align, el desfase queda en solo 0,22em.
#show math.equation: it => {
  if it.block {
    html.elem("div", attrs: (class: "eq-bloque"), html.frame(pad(y: 2pt, it)))
  } else {
    html.elem("span", attrs: (class: "eq"),
      html.frame([#box(width: 0pt, height: 0.94em, baseline: 0.22em)#it]))
  }
}

#set heading(numbering: (..n) => {
  let n = n.pos()
  if n.len() == 1 { numbering("I", ..n) } else if n.len() == 2 { numbering("I.1", ..n) }
})

#import "/bloques.typ": *
#set cite(style: "apa")

#include "capitulos.typ"

#heading(numbering: none)[Referencias]
#bibliography("refs.bib", title: none, style: "apa")
