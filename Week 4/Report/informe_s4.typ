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

*Fecha*: 09.06.2026
= (a) Avance de la Semana
#v(10pt)

- Leí los papers:
  - "Posterior Collapse and Latent Variable Non-identifiability".
  - "Posterior Collapse as a Phase Transition in Variational Autoencoders"
  Ambos muestran causas y caracterizaciones del _posterior collapse_.
- Repasé VQ-VAE y entendí la mejora que realizan sobre los VAEs para evitar el _posterior collapse_.
- Revisé el progreso que se realiza desde "Searching Latent Program Spaces" hacia "Gradient-Based Program Synthesis" gracias a la discretización (es decir, revisé qué mejoras permite la discretización).

= (b) Dudas

#v(10pt)



= (c) Propuesta para Próxima Semana

#v(10pt)

- Terminar de escribir el apunte (reorganizarlo y terminar los capítulos pendientes, como escribir comparaciones).
- Empezar a repasar los contenidos para preparar la presentación.