// -----------------------------------------------
// Portada (y contraportada) de la presentación
// -----------------------------------------------
// La llama template.typ con los mismos datos que recibe `project`.

// Texto claro con una sombra negra desplazada, para que se lea sobre el cuadro.
#let con_sombra(desplazamiento: 2pt, alineacion: left, cuerpo) = block(width: 100%, {
  place(top + left, dx: desplazamiento, dy: desplazamiento,
    block(width: 100%, align(alineacion, text(fill: black, cuerpo))))
  align(alineacion, cuerpo)
})

#let portada(
  title: "",
  subtitle: "",
  author: (),
  course_code: "",
  course_name: "",
  course_semester: "",
  title_font: "",
  painting: (:),
  ancho: 853pt,
  alto: 480pt,
) = {
  let claro = rgb("FFF9F5")

  page(
    width: ancho,
    height: alto,
    margin: (x: 90pt, top: 90pt, bottom: 60pt),
    fill: black,
    background: image(painting.image, width: 100%, height: 100%, fit: "cover"),
    header: [
      #set text(size: 12pt, fill: claro, font: title_font)
      #con_sombra(desplazamiento: 1pt)[*#course_name \ (#course_code, #course_semester)*]
      #v(-4pt)
      #line(length: 100%, stroke: 0.5pt + claro)
    ],
    footer: none,
    numbering: none,
  )[
    #set text(font: title_font, fill: claro)
    #set par(justify: false)
    #v(1fr)
    #grid(
      columns: (62%, 1fr),
      align: (left + bottom, right + bottom),
      [
        #set par(leading: 0.45em)
        #text(size: 26pt, weight: 700, con_sombra(desplazamiento: 2.5pt, title))
        #v(0pt)
        #text(size: 14pt, con_sombra(desplazamiento: 1pt)[*#author.name* \ #raw(author.email)])
      ],
      [
        /*#text(size: 22pt, weight: 700, con_sombra(desplazamiento: 2.5pt, alineacion: right, painting.title))
        #v(2pt)
        #text(size: 14pt, con_sombra(desplazamiento: 1pt, alineacion: right)[*#painting.author, #painting.date*])*/
      ],
    )
  ]
}
