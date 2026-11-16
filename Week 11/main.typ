#import "plantilla.typ": libro

#show: libro.with(
  titulo: [¿Qué gana y qué pierde un modelo al discretizar?],
  subtitulo: [Discretización de espacios continuos: evidencia, mecanismos y límites],
  autor: "Kevin Cardemil Ulloa",
  correo: "kevin.cardemil@uc.cl",
  contexto: [IPre Sueño-Vigilia y Aprendizaje Composicional · IMT2985],
  fecha: [Octubre de 2026],
)

#import "/bloques.typ": *

#set cite(style: "apa")

#include "capitulos.typ"

#pagebreak()
#heading(numbering: none)[Referencias]
#bibliography("refs.bib", title: none, style: "apa")
