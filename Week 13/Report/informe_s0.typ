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

- Profundicé la interpretación y los resultados de la revisión bibliográfica que buscaba evidenciar el efecto de ciertas piezas discretas en distintos modelos.
- Actualicé el apunte con los contenidos de las últimas semanas para preparar el informe final.
- Revisé el experimento del árbol de decisión, pero decidí no continuarlo para priorizar las otras dos tareas. 

= (b) Dudas
#v(10pt)

- Para el informe final, ¿debería intentar abarcar la gran mayoría de arquitecturas que revisamos aunque no tengan una conexión directa, o es mejor buscar un hilo conductor para alguna de las preguntas que profundizamos (como el efecto de la discretización)? ¿O quedará a criterio mío?

= (c) Propuesta para Próxima Semana
#v(10pt)
- Realizar un informe preliminar para cerrar el semestre.
- Revisar de qué manera se podría ver la efectividad de la *igualdad exacta*, que no ha sido estudiada en ningún _paper_, según el resultado preliminar de la tarea de la semana pasada.