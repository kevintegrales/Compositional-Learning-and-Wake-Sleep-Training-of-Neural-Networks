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

*Fecha*: 16.08.2026
= (a) Avance de la Semana
#v(10pt)

Estudié la sección *1.8. The Roots of Kolmogorov Complexity*, donde se introducía la noción de _compresión_ y de _complejidad_, entendida como la información intrínseca y objetiva de un objeto, a partir de la Teoría de Información. Además, se mencionaba que la _regularidad_ es un atributo que facilita la compresión de información.

Leí en su totalidad las *Notas de clase sobre DreamCoder*. Aquí se introducía el concepto de sueño-vigilia tratado para la síntesis de programas usando Cálculo Lambda. Primero, el algoritmo en su fase de vigilia busca el programa que mejor resuelva la tarea. Segundo, el algoritmo entra en la fase de sueño, que está subdividida en dos partes: la primera, llamada _abstracción_, consiste en la búsqueda de una librería que refactorice el código, escogiendo aquella abstracción que tenga mejor (más negativo) _compression gain_; la segunda, llamada _ensoñación_, consistía en imaginar escenarios basados en una distribución a priori que permite obtener data sintética ilimitada. Los resultados muestran que aprende funciones típicas de programación e incluso leyes físicas, como las leyes de Kepler. Además, se asegura que cada una de las fases del modelo es útil en cuanto a su rendimiento.

Por último, estudié el paper *Flat Minima* de Hochreiter y Schmidhuber (1997), en donde se planteaba el algoritmo _Flat Minimum Search (FMS)_ que, basado en el Minimum Description Length Principle, encontraba mínimos _flat_, donde la función de pérdida con que se entrenaba una red neuronal tenía pesos simples y estables. Este algoritmo _outperformeaba_ a otros como Backpropagation o Weight Decay en experimentos como la predicción de la bolsa. 

= (b) Dudas




= (c) Propuesta para Próxima Semana
