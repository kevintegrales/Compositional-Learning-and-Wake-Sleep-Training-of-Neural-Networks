# Planificación de lectura: I-JEPA y JEPA-Anything

**Presupuesto:** 10 horas en dos semanas (19 de octubre al 1 de noviembre de 2026).
**Papers:**
- **I-JEPA:** Assran et al. (2023), *Self-Supervised Learning from Images with a Joint-Embedding Predictive Architecture*, arXiv:2301.08243 (17 págs.; 8 de cuerpo y 9 de apéndice).
- **JEPA-Anything:** Cui et al. (2026), *JEPA-Anything: Learning Predictive Models across Different Worlds*, arXiv:2609.20800 (31 págs.; 24 de cuerpo).

**Enfoque (tomado de *Discretizar, conjeturar, refinar*):** no se trata de dominar cada ecuación ni cada benchmark, sino de leer ambos papers con las dos preguntas del proyecto en mente:
1. ¿Por qué ayuda discretizar? Hay que distinguir entre los seis mecanismos: compresión, corrección de errores, multimodalidad, combinatoria, búsqueda y comunicación.
2. ¿De dónde vienen las reglas y las hipótesis, y cuándo conviene refinar y cuándo ampliar?

La regla general, como dice el .epub, es preguntarse ante cada resultado *qué mecanismo podría explicar la mejora y si el paper ofrece un experimento que permita distinguirlo*. Si no lo ofrece, eso también se anota.

---

## Resumen del reparto

| Bloque | Sesión | Contenido | Horas |
|---|---|---|---|
| **Semana 1: I-JEPA** | S1 | Orientación, prerrequisitos, idea y método | 1,5 |
| | S2 | Resultados y ablaciones (lo central para nuestras preguntas) | 1,5 |
| | S3 | Visualizaciones, contexto y ficha de I-JEPA | 1,5 |
| **Semana 2: JEPA-Anything** | S4 | Marco general: interfaz, qué es fijo y qué depende del dominio | 1,5 |
| | S5 | El núcleo matemático de OPF y su auditoría empírica | 1,5 |
| | S6 | Experimentos seleccionados, trabajo relacionado y ficha | 1,5 |
| **Cierre** | S7 | Síntesis comparativa y preparación de la reunión | 1,0 |
| | | **Total** | **10,0** |

El reparto es casi parejo a propósito. JEPA-Anything es el doble de largo, pero gran parte de su extensión son siete dominios experimentales que basta con hojear. I-JEPA, en cambio, es corto y denso en ablaciones, que es justo donde están las pistas para la pregunta 1.

**Papers anotados:** ambos papers ya están anotados en la carpeta `Anotaciones` (`I-JEPA_anotado.pdf` y `JEPA-Anything_anotado.pdf`). Cada portada trae las cinco ideas para quedarse y la ruta de páginas por sesión. Léelos con las notas al lado.

**Cómo marcar mientras lees** (para lo que agregues tú): lleva una lista simple de `página, párrafo o tabla, tipo, una línea de comentario`, usando los tipos de la plantilla:
- `IDEA`: conexión con el .epub o con otro paper del curso.
- `CUIDADO`: afirmación fuerte con poca evidencia, notación confusa o comparación injusta.
- `EJERCICIO`: algo que conviene verificar a mano.
- `APUNTE`: dónde está explicado un concepto que el paper da por sabido.
- `EXTRA`: detalle técnico que se puede saltar.

---

## Semana 1: I-JEPA (4,5 h)

### S1. Orientación y método (1,5 h)

| Min. | Qué hacer |
|---|---|
| 15 | Releer del .epub la §1 (qué proponen los papers), la §3.8 (síntesis tentativa y tabla 2) y la **Guía A** de la §6. Tenerla a mano durante toda la semana. |
| 20 | **Prerrequisitos mínimos** (solo si no los tienes frescos): ViT y *patches*; *encoder* objetivo actualizado por EMA, al estilo de BYOL; colapso de representaciones; MAE, que reconstruye píxeles enmascarados; métodos de invarianza a vistas, como DINO o iBOT; y evaluación por *linear probe* y *low-shot*. Basta con una definición de una línea de cada uno. |
| 25 | Abstract, §1 Introduction, figuras 1 y 2, §2 Background. Las tres arquitecturas de la figura 2 (*joint-embedding*, generativa y predictiva en espacio de representaciones) son la idea más importante del paper. |
| 30 | §3 Method con las figuras 3 y 4: *context encoder*, *target encoder* (EMA), *predictor* y la estrategia de enmascarado *multi-block* (tamaño y razón de aspecto de los bloques objetivo, tamaño del contexto). |

**Producto:** un diagrama propio del flujo contexto, predictor y objetivo, más una respuesta de 3 o 4 líneas a la pregunta *¿qué decide no explicar cada una de las tres arquitecturas?* (conecta con los mecanismos 3.1 y 3.3 del .epub).

### S2. Resultados y ablaciones (1,5 h)

| Min. | Qué hacer |
|---|---|
| 25 | §5 a §7 en lectura rápida: tablas 1 a 5 y figura 5. Solo hay que retener **qué se afirma**: buen rendimiento semántico *sin aumentos de datos hechos a mano*, mejor que MAE en tareas de bajo nivel y más eficiente en cómputo. No hace falta memorizar números. |
| 25 | §9 Ablations: **tabla 6** (estrategia de enmascarado) y **tabla 7** (predecir píxeles o representaciones). Esta última es la evidencia directa de que predecir en espacio abstracto importa. |
| 40 | Apéndice C, en este orden: **tablas 8, 9 y 10** (tamaño de bloque objetivo, tamaño de contexto y número de objetivos), que corresponden a la pregunta del *nivel básico* y de *quién elige la escala*; **tabla 14** (ancho del predictor), que es la pista de *¿discreción o cuello de botella?*; y luego las tablas 11 a 13 en lectura rápida. |

**Producto:** para cada tabla clave, una línea con el formato *resultado / mecanismo del .epub que podría explicarlo / ¿el experimento permite distinguirlo?*

### S3. Visualizaciones, contexto y ficha (1,5 h)

| Min. | Qué hacer |
|---|---|
| 25 | §8 y figura 6, más el apéndice E (figuras 7 y 8, RCDM): qué conserva la predicción (forma, pose, posición) y qué descarta (detalles finos, textura). Conecta con la §3.7 del .epub, *lo que se pierde*. |
| 15 | §4 Related Work y §10 Conclusion. Hojear el apéndice B solo si alguna referencia te llama la atención. |
| 50 | **Ficha de I-JEPA** (1 página): tesis, 3 resultados con su evidencia, 2 o 3 afirmaciones que no quedan bien respaldadas, conexiones con las preguntas 1 y 3 del .epub y la lista de pasajes marcados para anotar. |

**Se puede saltar:** el apéndice A (hiperparámetros) y el apéndice D (*fine-tuning* completo).

---

## Semana 2: JEPA-Anything (4,5 h)

### S4. Marco general (1,5 h)

| Min. | Qué hacer |
|---|---|
| 10 | Releer la **Guía B** del .epub y repasar tu ficha de I-JEPA. |
| 30 | Abstract, figura 1 y §1 Introduction. Lo que hay que identificar es el diagnóstico central: un objetivo "monolítico" mezcla modos predictivos y eso se plantea como un **problema de asignación de capacidad predictiva** (pág. 3). |
| 25 | §2.1 y **tabla 1**: qué depende del dominio (adaptador, *view sampler*, *encoder*) y qué es común (núcleo OPF). Conecta con *lo innato y lo adquirido* (.epub §4.3): ¿qué hace aquí de conocimiento "de fábrica"? |
| 25 | §2.4: los tres modos de uso (modo representación, modo operacional de modelo del mundo y análisis por factores) y la figura 2. Hojear la tabla 2 solo para ver que *K* es casi siempre 4 o 5. |

**Producto:** un diagrama propio de JEPA-Anything que muestre qué pieza agrega respecto de I-JEPA. Debería caber en una línea: proyectar el objetivo en *K* subespacios ortogonales, usar un predictor por factor y recomponer con la pseudoinversa.

### S5. El núcleo matemático de OPF (1,5 h)

El .epub sugiere quedarse con la idea y no con las ecuaciones. Aun así, esta parte es álgebra lineal elemental y es justo donde vive el argumento de **estabilidad** (mecanismo 3.2), así que vale la pena hacerla a mano.

| Min. | Qué hacer |
|---|---|
| 35 | §2.2, ecuaciones (3) a (7): proyectores, predictores por factor, síntesis por pseudoinversa (5) y pérdida de ortogonalidad dentro de cada factor y entre factores (7). |
| 25 | **Proposición 1 y corolario 1**, más la **proposición 2** del apéndice A. `EJERCICIO`: con *d* = 4 y *K* = 2, construye un ejemplo con direcciones repetidas y otro con direcciones casi repetidas, y comprueba cómo crece el número de condición y cómo se amplifica el error de los factores. |
| 15 | §2.3, ecuaciones (9) y (10): el piso de actividad por factor y la varianza del *encoder*. Compáralos con VICReg y Barlow Twins, que conectan con Barlow y la redundancia (.epub §3.1). |
| 15 | §3.3.1, **tabla 5** (auditoría del mecanismo): la contraparte empírica de la proposición 1. Pregunta del .epub: ¿esta vía, sin discretizar valores, es una alternativa a discretizar o *otra forma de lo mismo*? |

**Producto:** una explicación propia de media página sobre por qué la ortogonalidad garantiza una recomposición estable, y qué tendría que pasar para que esa garantía se perdiera.

### S6. Experimentos seleccionados y ficha (1,5 h)

Los experimentos no merecen todos la misma atención. Para nuestras preguntas, el orden de prioridad es este:

| Min. | Qué hacer | Por qué |
|---|---|---|
| 20 | §3.1 (lógica de evaluación con *baselines* pareados) y el resto de **§3.3.1, CITRIS Pong**, con la figura 4: predecir **combinaciones de intervenciones nunca vistas**. | Es la prueba más cercana a la generalización composicional. |
| 20 | **§3.3.3 y §3.3.4**, figuras 6 y 7: *K* ∈ {1, 2, 4, 8}, Hopper como contraejemplo, sondas por factor (R² ≈ 0,3–0,4) y enmascarar un factor. Revisa también la **tabla 10** del apéndice B. | Corresponde a la pregunta 4 (*¿cuántos factores necesita un mundo?*) y a la pregunta 5 (*¿es un factor una regla?*). |
| 15 | **§3.4**, el uso científico: IL-18 + CD73 y la ley de Kepler (pendiente −1,4991). | Sirve para preguntarse si esto es *abducción* (descubrir) o *reconocimiento* (recuperar algo ya conocido), como en la §2.2 del .epub. |
| 10 | Lectura rápida: §3.2.1–3.2.3, §3.3.2 y §3.3.5. De cada una, solo el párrafo **Question** y la frase final con el resultado. | Fíjate en el **tamaño** de las mejoras (por ejemplo, en la tabla 3: .572 → .581). |
| 10 | §4 Related Work, sobre todo el párrafo de *structured and factorized representations* (Locatello: el *disentanglement* no supervisado no es identificable), más §5 y §6. | |
| 15 | **Ficha de JEPA-Anything**, con el mismo formato que la de I-JEPA. | |

`CUIDADO`: la Guía B del .epub remite a la "sección 6" para buscar las limitaciones que reconocen los autores. La §6 es *Future Work* y no hay una sección de limitaciones como tal, pero su último párrafo (pág. 25) sí reconoce varias: calibrar la incertidumbre, saber cuándo el modelo es confiable, revisar los factores cuando falte estructura, que los factores no establecen causalidad y que una arquitectura común no garantiza representaciones alineadas entre dominios. Además admiten que en Hopper gana el JEPA estándar (§3.3.3 y §5). Otras limitaciones, como que nunca se comparan valores de *K*, hay que reconstruirlas leyendo los resultados.

---

## S7. Cierre: síntesis y reunión (1,0 h)

| Min. | Qué hacer |
|---|---|
| 20 | **Tabla comparativa** de I-JEPA frente a JEPA-Anything: qué se predice, qué se discretiza (la tarea en I-JEPA, la estructura en OPF), quién decide los cortes (los diseñadores, o el aprendizaje con *K* fijo) y qué mecanismo del .epub queda mejor respaldado en cada caso. |
| 25 | Responder en 3 a 5 líneas cada una de las preguntas 1, 3, 4, 5 y 6 de la §7 del .epub, con referencias a página y tabla. |
| 15 | Elegir **2 o 3 preguntas para el profesor** y dejar lista la lista de pasajes marcados para la anotación en Typst. |

---

## Si te atrasas

Recorta en este orden. Ninguno de estos puntos afecta lo esencial:
1. Las tablas 1 a 5 de I-JEPA (basta con saber qué afirman).
2. Los experimentos de lectura rápida de JEPA-Anything (§3.2 y §3.3.2, §3.3.5).
3. El apéndice E de I-JEPA (con la figura 6 basta).
4. El ejercicio a mano de S5 (se reduce a leer bien el corolario 1 y la tabla 5).

**Nunca recortes:** la figura 2 y las tablas 7, 8 a 10 y 14 de I-JEPA, ni las §2.2, la tabla 5 y las §3.3.1, §3.3.3 y §3.3.4 de JEPA-Anything.

## Calendario sugerido

| Semana | Sesiones |
|---|---|
| 19 al 25 de octubre | S1 (lun), S2 (mié), S3 (vie) |
| 26 de octubre al 1 de noviembre | S4 (lun), S5 (mié), S6 (vie), S7 (antes de la reunión) |
