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

Esta semana la dediqué casi por completo al documento *"¿Qué gana y qué pierde un modelo al discretizar?"*, un libro de diez capítulos (más guía de lectura y glosario) que reúne lo que se sabe sobre la pregunta que nos acompaña desde la semana 9. Lo destacable del trabajo fue:

- *Creación del documento.* Armé el texto con una plantilla propia, figuras generadas para cada idea central y una versión EPUB para poder leerlo en Kindle. Lo he casi terminado de estudiar: leí con detalle los capítulos I (Introducción), II (Fundamentos), III (Cómo se discretiza), IV (Evidencia), V (Seguir el error), VI (¿Es la discretización?), IX (¿Cuándo conviene discretizar?) y X (Conclusiones). Me quedan pendientes de profundizar el VII (Colapso y error acumulado) y el VIII (JEPA y discretización).

- *Organización y entendimiento de las preguntas.* Ordené en una sola tabla todas las preguntas abiertas: las suyas (P1 a P5 y la nota _"accumulated errors =?= collapse"_) y las dos que yo había dejado planteadas (A1 y A2), asignando a cada una el capítulo que la responde y el grado de certeza de la respuesta. Esto me permitió reformular algunas que estaban ambiguas y separar las que tienen respuesta en la literatura de las que solo admiten una conjetura.

- *¿Es en verdad la discretización o es alguna idea que viene implicada con ella? (A1).* Profundicé en la idea de que "discretizar" no es un cambio único, sino un _paquete_ de piezas que suelen venir juntas (menor capacidad, geometría _one-hot_ o esparsa, cambio de MSE a entropía cruzada, corrección de errores por márgenes, identidad exacta de los estados, entre otras). La conclusión tentativa es que casi todos los beneficios documentados se pueden reproducir sin discretizar, atacando directamente la propiedad responsable, y que lo propio de lo discreto parece ser la *identidad exacta*: poder decir que dos estados son _el mismo_ símbolo, lo que permite enumerar, reutilizar y componer. Como principio candidato quedó: _invarianza dentro de una clase y margen entre clases, con clases que coincidan con la estructura del mundo_.

- *Relación con Meyer et al. (2024).* Revisé en detalle _"Harnessing Discrete Representations for Continual Reinforcement Learning"_, que es el experimento más limpio que encontré: compara el mismo código como _one-hot_ y como vector, y muestra que la ventaja de lo discreto aparece sobre todo cuando el modelo del mundo tiene poca capacidad y cuando el entorno cambia, y que buena parte de ella se explica por la geometría (_one-hot_) más que por la discreción misma.

- *Experimentos de NLI frente a LPN.* Revisé las ablaciones de ambos trabajos para entender por qué NLI generaliza mejor composicionalmente. NLI no cambia solo la discreción: también introduce programas de largo variable y un intérprete que lee símbolo por símbolo. A partir de eso quedó planteado un diseño de cuatro variantes (LPN con largo variable, NLI con largo fijo, NLI con tokens continuos con ruido calibrado y NLI con tokens como vectores) que separaría estas causas.

- *La evolución de Dreamer.* Estudié los cambios de DreamerV1 a V2 (latente gaussiano a 32 categóricas de 32 clases, _KL balancing_) y de V2 a V3 (discretización de la pérdida con objetivos _two-hot_, _free bits_ y otros ajustes para un único conjunto de hiperparámetros), para ubicar dónde entra la discretización como fuente de mejora. La conclusión es que la ablación de DreamerV2 cambia varias piezas a la vez y, por lo tanto, muestra que _el paquete_ ayuda, pero no permite atribuir la mejora a la discreción en sí.

- *¿Cuándo conviene discretizar? (A2).* Planteé y avancé en una respuesta que busca principios generales: criterios a favor (mundos con "huecos" o categorías, predicciones encadenadas muchas veces, poca capacidad frente a la complejidad del mundo, entornos que cambian, tareas que requieren buscar o componer) y en contra (variables continuas ricas que exigen precisión fina, necesidad de interpolar, optimización por gradiente dentro del latente), cada uno acompañado de un diagnóstico medible para decidir _antes_ de discretizar.

= (b) Dudas
#v(10pt)

Esta semana no tengo dudas concretas, ya que el trabajo lo fui guiando en buena parte con apoyo de IA y las preguntas que surgieron quedaron incorporadas y discutidas en el documento.

= (c) Propuesta para Próxima Semana
#v(10pt)

- Terminar de profundizar los capítulos VII (Colapso y error acumulado) y VIII (JEPA y discretización).
- En la línea de lo que veíamos hace algunas semanas, buscar una relación entre lo trabajado y el paper *"Human-like systematic generalization through a meta-learning neural network"* de Lake y Baroni (2023, _Nature_), buscando indicios de discretización que expliquen su mejora, o de mecanismos que, sin discretizar explícitamente, produzcan los mismos efectos que la discretización.
