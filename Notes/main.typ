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

= Semana 0
#include "chapters/ch_w_00.typ"

#pagebreak()
= Semana 1
#include "chapters/ch_w_01.typ"


//#pagebreak()
//= Referencias
//#include "chapters/ch_references.typ"