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

// Cuerpo

*Fecha*: 30.08.2026
= (a) Avance de la Semana
#v(10pt)

Leí:
- Los primeros capítulos del documento "*An Introduction to Variational Encoders*", donde se explicaba el marco y funcionamiento de los VAEs.
- El paper "*Categorical Reparametrization with Gumbel-Softmax*" (completo), donde se presentaba la distribución Gumbel-Softmax y un estimador adecuado, que volvía continuas distribuciones discretas (conforme a un parámetro de temperatura $tau$) para poder diferenciarlas y ser capaces de aplicar backpropagation.
- El paper "*Discrete Representation Learning*" (completo).

Escribí el apunte de las tres partes, para no añadir más material pendiente.

= (b) Dudas
#v(10pt)
- En el paper "Discrete Representation Learning", usan como estimador del gradiente el mismo estimador de gradiente que ya tenían (es decir, lo copian y lo pegan para el backpropagation). ¿Podrían aquí haber aplicado Gumbel-Softmax de alguna manera para tener un sustento teórico de backpropagation o aplicar alguna otra herramienta para estimar el gradiente y que fuera igual o mejor?  (Sé que muchas veces da igual la teoría si los resultados son mejores con otra técnica práctica, pero me generaba curiosidad.)






= (c) Propuesta para Próxima Semana
#v(10pt)
- Hacer un repaso de Backpropagation para incluirlo en el apunte.
- Aprender sobre estimadores de Monte Carlo (en caso de que no me desvíe tanto del material).
- Aprender sobre los *Score function estimator* y sobre los algoritmos *NVIL* y *REINFORCE* (que son mencionados en el paper de Gumbel-Softmax).