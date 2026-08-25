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

*Fecha*: 23.08.2026
= (a) Avance de la Semana
#v(10pt)

Avancé por completo la escritura de las notas sobre Complejidad de Kolmogorov (todo lo que leí del libro "*An Introduction to Kolmogorov Complexity*"). 

Leí ambos papers, *"Searching Latent Program Spaces"* y *"Gradient-Based Program Synthesis with Neurally Interpreted Languages"*. Para ambos creé las notas correspondientes, aunque me falta todavía completar los resultados y conclusiones (y ojalá una comparación a detalle entre ambos).


= (b) Dudas
1. En Searching Latent Program Spaces: No entiendo del todo el flujo al entrenar. ¿Cuándo se usa leave-one-out y cuándo ascenso de gradiente? ¿Se entrenan el encoder y el decoder una sola vez al principio y ya, o se vuelven a entrenar luego de hacer ascenso de grandiente con un ejemplo? (Creo que es la segunda opción)

2. Al comparar a ambos papers, ¿por qué en Gradient-Bases Program Synthesis no se usa una distribución de los programas $z$ Normal con media $mu$ y varianza $Sigma$?



= (c) Propuesta para Próxima Semana

#v(10pt)
Mi propuesta para la semana que viene consiste en:
1. Resolver las dudas que tengo respecto a los dos papers.
2. Poder hacer una comparación entre los papers.
3. Continuar las notas (y continuar desarrollando las notas para incluir la materia de las semanas pasadas).
4. Lectura y estudio de un paper recomendado por usted.