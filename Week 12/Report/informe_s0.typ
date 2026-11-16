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

Esta semana intenté realizar 2 experimentos:

- *Revisar comparaciones y mejoras de resultados (Tarea 1).* La realicé completa. Ahí pretendimos buscar empíricamente en la literatura qué combinaciones de las seis piezas del paquete de discretización han sido evaluadas y cuáles valen la pena, construyendo un hipercubo de comparaciones. (Le enviaré un resumen de resultados a su Telegram.)
- *Poner a prueba el árbol de decisión (Tarea 2).* Se me ocurrió construir un mundo de juguete sintético con una "perilla" por cada pregunta del árbol de decisión propuesto, para comprobar de manera empírica cada nodo y su orden. (La terminaré de realizar mañana lunes 9 de noviembre, porque agoté repetidas veces los tokens de las sesiones, así que no pude seguir avanzando con esa idea.)

Además, revisé la arquitectura de los Transformers para poder entender _papers_ que los involucren en caso de ser necesarios.

= (b) Dudas
#v(10pt)

Esta semana nuevamente no tengo preguntas concretas.

= (c) Propuesta para Próxima Semana
#v(10pt)

- Pretendo condensar y terminar de entender los resultados obtenidos.
- Avanzar con más experimentos, por ejemplo, pensando de qué manera se podría ver la efectividad de la *igualdad exacta*, que no ha sido estudiada en ningún _paper_, según el resultado preliminar de la Tarea 1.