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

*Fecha*: 09.08.2026
= (a) Avance de la Semana
#v(10pt)
Esta semana quise considerarla como una introducción, por lo que revisé en una primera lectura todos los primeros documentos:
- *Aprendizaje Composicional y Generalización OOD (_Notas de Clase MAT2320, Clase 16_).*
- *Paper Mastering Diverse Domains through World Models.*

Para poder crear una base sólida sobre la que empezar a revisar investigaciones, me percaté del primer documento que requeriría aprender un poco sobre Teoría de la Computación, en particular sobre Máquinas de Turing y la Complejidad de Kolmogorov. Para ello, decidí leer el libro *"An Introduction to Kolmogorov Complexity and Its Applications" de Ming Li y Paul Vitànyi*, que vi citado en sus notas de clase. Hasta el momento, he leído las secciones 1.1, 1.2, 1.4 y 1.7 (las que se encuentran entremedio decidí omitirlas dado que ya conocía el contenido). Justamente alcancé a revisar la materia correspondiente a _Máquinas de Turing, computabilidad, Halting Problem, Oráculos y Richard-Berry paradox_, que eran conceptos que aparecían mencionados en las notas y creo ahora entenderlos bastante bien. _NO alcancé a revisar la Complejidad de Kolmogorov_, aunque ya tengo una noción de qué corresponde, gracias a las notas de clase y a la sección 1.1 del libro de Li.

Por el segundo documento, decidí además repasar las nociones de Reinforcement Learning en el libro *"Reinforcement Learning: An Introduction" de Richard Sutton y Andrew Barto*. De él leí las secciones 1.1, 1.2, 1.3, 1.4, 1.6, 3.1, 3.2, 3.3, 3.4 y 3.6. Así, comprendo mejor el funcionamiento de los Markov Decision Processes.


= (b) Dudas
- Revisando con IA las fuentes que me entregó usted, se me indicó que existen áreas de literatura vinculadas con el sueño-vigilia:
  1. Wake-Sleep bayesiano clásico (que pareciera ser el que usa DreamCoder).
  2. "Dreaming" como imaginación latente en RL (que pareciera ser el que usa Dreamer)
  3. El sleep-replay biológico para aprendizaje continuo.
  Mi consulta es, ¿nos centraremos específicamente en uno de ellos o trabajaremos viéndolos de manera general?
- Respecto a lo que realizaré en el semestre, ¿revisaré únicamente literatura o también implementaré algún algoritmo? ¿O tengo libertad para decidirlo yo?
- Mi otra duda tiene relación con cuánto trabajo semanal se espera que realice. ¿Debería avanzar al menos trabajando con un paper semanal una vez tenga las bases de la teoría o es muy poco?


= (c) Propuesta para Próxima Semana
- Aprender a profundidad qué es la *Complejidad de Kolmogorov y el Teorema de Invarianza* en el libro de Ming Li.
- Aprender sobre el MDL en el libro *"The Minimum Description Length Principle" de Grünwald* o en el de Ming Li.
- Revisar con detenimiento las notas *"DreamCoder and Wake-Sleep Library Learning"*.
- Si me llegase a sobrar tiempo, leer el paper *"The wake-sleep algorithm for unsupervised neural networks" de Hinton, Dayan, Frey & Neal (1995)*, que entiendo ser la base del proyecto.