#import "template.typ": *
#import "@preview/hydra:0.4.0": hydra
#import "@preview/tablex:0.0.9": tablex, cellx, colspanx, rowspanx, vlinex

#import "template.typ": *
#import "math_functions.typ": *
#import "config.typ" as cf

// Portada
#show: project.with(
  title: cf.your_title,
  subtitle: cf.your_subtitle,
  author: (name: cf.author_name, email: cf.author_email),
  course_code: cf.your_course_code,
  course_name: cf.your_course_name,
  course_semester: cf.your_course_semester,
  title_font: cf.your_title_font,
  body_font: cf.your_body_font,
  math_font: cf.your_math_font,
  principal_color: cf.your_principal_color,
  secondary_color: cf.your_secondary_color,
)

// Funciones (NO mover este blo@que)
#import "/math_functions.typ": *
#import "/notalmar.typ": *
#include "/notalmar.typ"

#show "FUT": box(fill: red, inset: 10pt, width: 100%)[#set align(center)
Por hacer en el futuro]


#show "POR": box(fill: orange, inset: 10pt, width: 100%)[#set align(center)
Por hacer: Domingo]

#show "TODO": box(fill: yellow, inset: 10pt, width: 100%)[#set align(center)
Por hacer: Sábado]

= Contenidos Preliminares
#include "chapters/ch_preliminares.typ"

#pagebreak()
= Representaciones Latentes
#include "chapters/ch_discretas.typ"

#pagebreak()
= Síntesis de Programas
#include "chapters/ch_sintesis.typ"

#pagebreak()
= Algoritmos para Redes Neuronales
#include "chapters/ch_algoritmos.typ"

#pagebreak()
= Misceláneos
#include "chapters/ch_miscelaneos.typ"

#pagebreak()
= Apéndice
#include "chapters/ch_apendix.typ"

//#pagebreak()
//= Referencias
//#include "chapters/ch_references.typ"