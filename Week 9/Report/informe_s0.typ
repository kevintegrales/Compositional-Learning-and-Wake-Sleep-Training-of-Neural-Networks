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
  authors: (
    (name: cf.author_name, email: cf.author_email),
  ),
  course_code: cf.your_course_code,
  course_name: cf.your_course_name,
  course_semester: cf.your_course_semester,
  title_font: cf.your_title_font,
  body_font: cf.your_body_font,
  math_font: cf.your_math_font,
  principal_color: cf.your_principal_color,
  secondary_color: cf.your_secondary_color,
)

// Funciones (NO mover este bloque)
#import "/math_functions.typ": *
#import "/notalmar.typ": *
#include "/notalmar.typ"

// Cuerpo

= (a) Avance de la Semana
#v(10pt)

Durante esta semana revisé el paper I-JEPA e hice y leí un documento que reunía ideas sobre los papers que hemos leído hasta el momento, centrándose en las siguientes dos preguntas. 

Además, a modo de tener un registro, redacté las preguntas que estamos abordando:
1. ¿Por qué, al discretizar ciertos espacios, las respuestas de los algoritmos mejoran? ¿Qué principios parecen ser comunes a este comportamiento?
2. ¿Cómo se modelan las reglas que tienen los humanos, ya sean innatas o adquiridas? ¿Qué es lo que genera las hipótesis sobre los datos en los humanos? Y, cuando se busca hipótesis, ¿cuándo se profundiza una regla y cuándo se transiciona hacia otra?


= (b) Dudas
#v(10pt)

Respecto a la primera pregunta, ¿necesariamente es el discretizar lo que mejora los algoritmos o es algún principio subyacente el que, gracias a la discretización, se pone en práctica?

= (c) Propuesta para Próxima Semana
#v(10pt)

- Continuar con el análisis de I-JEPA y ver completo JEPA-Anything.
- Avanzar el apunte añadiendo las ideas de las dos últimas semanas.