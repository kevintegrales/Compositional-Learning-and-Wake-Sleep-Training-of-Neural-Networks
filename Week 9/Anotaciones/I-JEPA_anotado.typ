// I-JEPA (Assran et al., 2023), anotado.
// Compilar desde la carpeta Week 9:
//   tinymist compile --root . Anotaciones/I-JEPA_anotado.typ Anotaciones/I-JEPA_anotado.pdf
#import "comun.typ": *

#set document(title: "I-JEPA anotado")

#let src = "/2301.08243v3.pdf"
#let W = 612
#let H = 792
#let pag = anotador(src, W: W, H: H, xr: 549, M: 230, ML: 190, xl: 47, tipos: tipos-jepa)

#portada(
  [I-JEPA, anotado],
  [_Self-Supervised Learning from Images with a Joint-Embedding Predictive Architecture_ · M. Assran et al. (2023) · arXiv:2301.08243],
  [
    *Para qué son estas notas.* Acompañan la semana 1 de la planificación (sesiones S1 a S3). Señalan lo esencial, lo conectan con las dos preguntas del proyecto y con _Discretizar, conjeturar, refinar_, y marcan qué dejar para después. El paper es a dos columnas: las notas de la columna izquierda van en el margen izquierdo y las de la derecha, en el derecho.

    #v(4pt)
    *Si te quedas con cinco ideas*
    + Predecir *representaciones* y no píxeles es el ingrediente principal (tabla 7: 66.9 frente a 40.7).
    + La máscara es el sesgo inductivo: objetivos medianos (15–20 % del área), varios (4) y un contexto amplio (tablas 6 y 8–10). Esa escala la elige el diseñador, no el modelo.
    + Lo abstracto conserva forma, pose y posición, y descarta textura y detalle fino (figuras 6–8). Por eso MAE, que reconstruye píxeles, todavía gana en contar objetos (tabla 4).
    + Un predictor estrecho, es decir, un cuello de botella, rinde mejor que uno ancho (tabla 14): restringir capacidad ayuda sin discretizar nada.
    + El aporte de I-JEPA a nuestras preguntas está en P1 (lo que se discretiza es *la tarea*) y en C3 (la escala). Sobre P2 casi no dice nada.

    #v(4pt)
    *Ruta por sesión.* S1: págs. 1–4. S2: págs. 5–8 y 14–15. S3: págs. 7–8, 12–13 y 16–17. Las páginas 9–11 son referencias; solo se marcan las que vale la pena buscar.
  ],
  W: W, H: H, M: 230, ML: 190, tipos: tipos-jepa,
  encabezado: [Anotaciones al margen · Semana 9 · IPRE Aprendizaje Composicional],
  derecha: etiquetas,
)

// ---------------------------------------------------------------- Página 1
#pag(1, (
  ni(270, 340, "clave")[*Tesis:* desde un bloque de contexto, predecir la *representación* (no los píxeles) de otros bloques de la misma imagen, sin aumentos de datos hechos a mano.],
  ni(354, 412, "clave")[Las dos condiciones del método: objetivos *grandes* (semánticos) y un contexto *informativo* y repartido en el espacio. Ambas son decisiones de diseño (tablas 6 y 8–10).],
  ni(378, 412, "pregunta")[La escala de los objetivos la fija el diseñador. Es la pista para C3 y para la pregunta "¿quién decide los cortes?" (ep. tabla 2, fila "la tarea").],
  ni(529, 575, "apunte")[Dos familias previas. *Invarianza* (DINO, iBOT, SimCLR): dos versiones aumentadas de una imagen deben dar el mismo embedding. *Generativas* (MAE): reconstruir los píxeles ocultos.],
  ni(578, 671, "clave")[Crítica a la invarianza: recortes, cambios de color, etc. son *sesgos inductivos hechos a mano*. Sirven para clasificar, pero pueden dañar tareas que necesitan otra invarianza, como contar o segmentar.],
  ni(661, 695, "pregunta")[Los aumentos son conocimiento "de fábrica" (ep. §4.3, Kant y Spelke). I-JEPA no elimina el sesgo: lo *traslada* al diseño de la máscara (C9).],
  n(423, 475, "cuidado")[La figura 1 mide eficiencia (horas-GPU), no solo exactitud. El empate con iBOT (81.1 frente a 81.0, tabla 1) exige un modelo más grande y resolución 448.],
  n(496, 556, "pregunta")["Tareas que requieren distintos niveles de abstracción": cada tarea pide una granularidad distinta. Es la idea del nivel básico de Rosch (ep. §3.8, C3).],
  n(572, 618, "apunte")[Las refs. 31 y 59 son Friston y Rao y Ballard: codificación predictiva. Percibir como predecir, en la línea de Helmholtz y Craik (ep. §2.5). JEPA es esa idea en un espacio abstracto.],
  n(680, 713, "clave")[Ventaja de enmascarar: pide menos conocimiento previo que la invarianza y sirve en cualquier modalidad. Por eso JEPA-Anything puede aplicarlo a células, clima o moléculas.],
))

// ---------------------------------------------------------------- Página 2
#pag(2, (
  n(75, 163, "clave", r: (50, 70, 545, 165))[*La figura más importante del paper.* (a) JEA: embeddings parecidos para entradas compatibles; riesgo de colapso. (b) Generativa: reconstruir $y$ en el espacio de entrada. (c) JEPA: predecir el *embedding* de $y$ desde el de $x$, condicionado en $z$.],
  ni(175, 249, "pregunta")[Pregunta de S1: ¿qué decide *no explicar* cada una? (a) Todo lo que cambian los aumentos. (b) Nada: debe explicar cada píxel. (c) Lo que el target encoder descarte. Conecta con M1 y M3.],
  ni(275, 333, "apunte")[*Linear probing*: congelar el encoder y entrenar solo un clasificador lineal encima. Mide qué tan "legible" es la representación sin adaptarla. El *fine-tuning*, en cambio, la ajusta entera.],
  ni(418, 536, "clave")[La apuesta: el objetivo es abstracto porque lo produce un encoder *aprendido*, y los detalles de píxel innecesarios "se eliminan potencialmente". Fíjate en el "potencialmente": no está garantizado.],
  ni(490, 536, "pregunta")[¿Por qué ayuda? Hay dos lecturas posibles en el ep.: M1 (el objetivo lleva menos información que el píxel) o M3 (queda menos incertidumbre que promediar). El paper no separa ambas.],
  n(263, 311, "cuidado")["Mejor en tareas de bajo nivel" se dice *respecto de los métodos de invarianza*. En la tabla 4, MAE (píxeles) gana en Clevr/Count: 90.5 frente a 86.7. Lo abstracto pierde detalle (ep. §3.7).],
  n(332, 414, "extra")[Eficiencia: ViT-H/14 en menos de 1200 horas-GPU, unas 10 veces menos que MAE. Es un argumento práctico más que conceptual.],
  n(484, 553, "apunte")[*Modelos basados en energía* (LeCun et al., 2006): la energía mide incompatibilidad. Aprender es bajar la energía de los pares compatibles y evitar que baje para los incompatibles.],
  n(668, 713, "apunte")[*Colapso*: el encoder entrega la misma salida para todo, la energía queda plana y la pérdida es mínima sin aprender nada. Todo método no generativo necesita un mecanismo anticolapso.],
))

// ---------------------------------------------------------------- Página 3
#pag(3, (
  ni(74, 180, "profundizar")[Formas de evitar el colapso: contrastiva (negativos), reducción de redundancia (VICReg, Barlow Twins: ep. §3.1, Barlow 1961), *clustering* o una arquitectura asimétrica (EMA). JEPA-Anything usará *además* un término de varianza tipo VICReg.],
  ni(318, 388, "pregunta")[Idea fina: en lo generativo no hay colapso *si $z$ lleva poca información* comparada con $y$. Es un argumento de cuello de botella (M1): limitar $z$ obliga a usar $x$.],
  ni(455, 501, "apunte")[En I-JEPA, $z$ son los *tokens de posición* de los bloques objetivo. Le dicen al predictor *dónde* predecir, nunca *qué*.],
  ni(539, 633, "cuidado")[La prevención del colapso es *empírica* (EMA y predictor). El paper no da garantías; solo "una arquitectura asimétrica".],
  ni(587, 633, "profundizar")[Para entender por qué no colapsa: BYOL (Grill et al., 2020) y la ref. 62, Tian, Chen y Ganguli (2021), sobre la dinámica del aprendizaje sin pares negativos.],
  n(74, 305, "clave", r: (309, 70, 545, 300))[Tres redes. *Context encoder* $f_theta$: solo ve los parches visibles. *Target encoder* $f_(macron(theta))$: ve la imagen completa y es un promedio exponencial (EMA) del primero. *Predictor* $g_phi$: un ViT estrecho condicionado en posiciones.],
  n(310, 419, "apunte")[El contexto solo procesa los parches visibles: es barato. El target encoder procesa la imagen completa, pero sin gradiente.],
  n(584, 716, "clave")[Los objetivos se recortan de la *salida* del target encoder, que vio la imagen entera: cada parche objetivo trae contexto global. Por eso es "semántico" (tabla 11: 67.3 frente a 56.1).],
))

// ---------------------------------------------------------------- Página 4
#pag(4, (
  ni(251, 325, "clave", r: (50, 70, 286, 249))[*Receta de la máscara.* 4 bloques objetivo de escala 15–20 % del área y razón de aspecto 0.75–1.5. Un contexto de 85–100 % *sin* las zonas objetivo. Estos números son el sesgo inductivo del método.],
  ni(283, 325, "pregunta")[Las escalas no salen del modelo: se buscaron a mano (tabla 8). ¿Podría el modelo inferir su propia escala, como el nivel básico de Rosch? (C3).],
  ni(520, 566, "apunte")[Se quita del contexto lo que se va a predecir. Si no, la tarea sería copiar.],
  ni(620, 716, "apunte")[El predictor recibe $s_x$ y un *mask token* por parche objetivo: un vector aprendido compartido más el embedding posicional. Se aplica $M$ veces, una por bloque.],
  ni(655, 716, "pregunta")[Hay *una sola* conjetura determinista por bloque: no existe una variable latente para muestrear alternativas. Es lo opuesto a generar hipótesis por muestreo (Dasgupta et al., ep. §4.3; C6).],
  n(160, 235, "clave", r: (330, 201, 545, 236))[*Pérdida (1)*: promedio sobre los $M$ bloques de $sum_(j in B_i) norm(hat(s)_(y_j) - s_(y_j))_2^2$. Es una distancia L2 *entre representaciones*, nunca entre píxeles.],
  n(172, 235, "pregunta")[L2 con un predictor determinista ⇒ se predice la *media condicional* del embedding. Si el contenido oculto es ambiguo, se promedia. I-JEPA lo esquiva porque en espacio abstracto queda menos incertidumbre (ep. §3.3, M3).],
  n(243, 325, "apunte")[EMA: $macron(theta) <- m macron(theta) + (1 - m) theta$, con $m$ de 0.996 a 1.0 (apéndice A). El target encoder no recibe gradiente; esta asimetría, junto con el predictor, evita el colapso en la práctica.],
  n(357, 534, "extra")[§4 se lee rápido. El pariente más cercano es data2vec (también predice representaciones de parches ocultos); la diferencia práctica es la máscara multibloque y el costo.],
  n(536, 594, "pregunta")[BEiT discretiza *el objetivo*: tokens de un dVAE, pariente de VQ-VAE. Aquí discretizar no ganó: MAE con píxeles lo supera en fine-tuning. Dato para P1: discretizar el objetivo, por sí solo, no basta.],
))

// ---------------------------------------------------------------- Página 5
#pag(5, (
  ni(296, 371, "cuidado", r: (70, 70, 286, 285))[Tabla 1. Sin aumentos, I-JEPA gana claramente: 79.3 frente a 77.2 de MAE con ViT-H/14, y con 300 épocas en vez de 1600. Frente a métodos *con* aumentos, solo empata usando ViT-H a 448 px (81.1 frente a 81.0 de iBOT).],
  ni(548, 713, "extra")[Comparación de costo: DINO, MSN e iBOT procesan varias vistas por imagen; I-JEPA, una sola. Se puede pasar rápido.],
  n(268, 364, "pregunta", r: (330, 70, 545, 262))[Tabla 2: 1 % de las etiquetas, unas 12 imágenes por clase. Es el régimen de pocos ejemplos del juego de los números (ep. §4.1): ¿qué hace que una representación generalice con tan pocos datos?],
  n(536, 713, "extra")[§5 en lectura rápida (S2): basta con retener *qué* se afirma.],
))

// ---------------------------------------------------------------- Página 6
#pag(6, (
  ni(124, 175, "pregunta", r: (56, 123, 286, 134))[En iNat18 (especies, categorías muy finas), I-JEPA logra 47.6 frente a 57.3 de iBOT: la brecha mayor está en lo más fino. ¿Pierde la abstracción el nivel subordinado ("labrador" frente a "perro")? Es una hipótesis para C3, no un resultado.],
  ni(187, 251, "clave")[Tabla 3: I-JEPA supera a los métodos sin aumentos y achica la distancia con los que sí los usan. En CIFAR100 y Places205 incluso supera a DINO.],
  n(100, 175, "cuidado", r: (326, 99, 530, 134))[Tabla 4. Clevr/Count: MAE 90.5, I-JEPA 86.7. Clevr/Dist: empate en 72.4. I-JEPA gana a DINO e iBOT, no a MAE. Contar y medir distancias exige detalle que lo abstracto puede descartar (ep. §3.7).],
  n(573, 674, "extra")[§7: 7 % más lento por iteración, pero converge en unas 5 veces menos iteraciones.],
))

// ---------------------------------------------------------------- Página 7
#pag(7, (
  n(134, 187, "cuidado", r: (130, 70, 466, 123))[Tabla 5: ViT-G/16 mejora lo semántico pero *no* las tareas de bajo nivel; los autores lo atribuyen a parches más grandes (16 frente a 14 px). Otra vez: más abstracción no es mejor en todo.],
  ni(394, 480, "extra")[Figura 5: la eficiencia es un argumento práctico. Se puede pasar rápido.],
  ni(620, 713, "apunte")[Lo mismo en datos y modelo: entrenar con ImageNet-22k y modelos más grandes ayuda en lo semántico.],
  n(229, 335, "apunte")[§8 responde si el predictor captura la *incertidumbre posicional*: no sabe exactamente dónde está cada parte, pero sí qué parte va ahí.],
  n(337, 419, "clave")[Truco metodológico: entrenar un decodificador generativo (RCDM) que convierte la salida del predictor en imágenes. Lo que se repite entre muestras está en la representación; lo que varía, no.],
  n(421, 455, "clave")[Resultado: el predictor captura partes de objetos con la *pose correcta* (el lomo del pájaro, el techo del auto).],
  n(486, 604, "pregunta")["We conjecture": es una *conjetura*. La tabla 7 muestra que predecir píxeles es mucho peor, pero no dice *por qué* (¿M1, compresión? ¿M3, menos multimodalidad?). Un experimento que lo separaría: predecir píxeles a través de un cuello de botella (C1).],
  n(619, 713, "apunte")[Variantes de la tabla 6. *Rasterized*: un cuadrante predice los otros tres. *Block*: un solo bloque grande. *Random*: parches sueltos, como en MAE.],
))

// ---------------------------------------------------------------- Página 8
#pag(8, (
  n(263, 338, "clave")[Figura 6: imagen, contexto (la caja verde es la zona a predecir) y muestras decodificadas. *Conserva* forma y pose; *descarta* detalle fino, textura y fondo. Es "lo que se pierde" (ep. §3.7) hecho visible.],
  ni(263, 338, "pregunta")[¿Es esto un "nivel básico"? El predictor entrega "un pájaro de espaldas en esta posición", no "este pájaro con estas plumas" (C3).],
  n(384, 430, "clave", r: (103, 383, 492, 431))[*Tabla 6: la máscara lo es todo.* Multibloque 54.2; rasterizado 15.5; bloque 20.2; aleatorio 17.6. Cambiar *qué* se pide predecir cambia la semántica aprendida.],
  n(457, 509, "pregunta")[Esto es discretizar *la tarea* (ep. tabla 2): los cortes los decide el diseñador. ¿Qué principio explica que ganen varios bloques medianos? El paper no lo dice; solo lo mide.],
  ni(532, 570, "clave", r: (68, 545, 270, 570))[*Tabla 7:* objetivos = salida del target encoder, 66.9; píxeles, 40.7. Es la diferencia más grande del paper: predecir en espacio abstracto es *el* ingrediente.],
  ni(581, 634, "cuidado")[No es una comparación pareada: píxeles con 800 épocas frente a 500. Como píxeles pierde aun con más entrenamiento, la conclusión resiste; pero es un solo modelo y sin barras de error.],
  n(608, 713, "clave")[Mensaje final: un camino para aprender representaciones generales *sin* aumentos de vista. JEPA-Anything toma esta idea y la lleva a otros "mundos".],
))

// ---------------------------------------------------------------- Páginas 9–11 (referencias)
#pag(9, (
  ni(526, 568, "profundizar")[VICReg (varianza, invarianza y covarianza). JEPA-Anything reutiliza su término de varianza.],
  ni(649, 691, "extra")[RCDM: el decodificador usado en §8 y en el apéndice E.],
))
#pag(10, (
  ni(185, 230, "profundizar")[Friston: la teoría de la respuesta cortical como predicción (ep. §2.5).],
  n(300, 322, "profundizar")[LeCun (2022): el programa de investigación detrás de JEPA. Léelo si quieres el porqué de fondo de los modelos del mundo (ep. §2.5).],
))
#pag(11, (
  ni(109, 140, "profundizar")[Rao y Ballard (1999): codificación predictiva en la corteza visual. Es el origen de la idea de "predecir la entrada sensorial".],
  ni(267, 300, "profundizar")[Tian, Chen y Ganguli (2021): por qué los métodos sin negativos (BYOL, SimSiam) no colapsan. Es la teoría que falta en §2.],
))

// ---------------------------------------------------------------- Página 12 (apéndice A)
#pag(12, (
  n(126, 172, "pregunta")[El predictor es *a propósito* estrecho: 384 canales, con encoders de 768 a 1280. Es un cuello de botella de diseño (ver la tabla 14 y C1).],
  ni(185, 208, "apunte")[Para evaluar se usa el *target encoder* con el promedio de los parches; no hay token [cls].],
  n(279, 302, "extra")[Momentum del EMA de 0.996 a 1.0: al final del entrenamiento, el target encoder casi se congela.],
  ni(325, 431, "extra")[Detalles de implementación de la máscara: se pueden saltar.],
  n(465, 713, "extra")[Protocolos de evaluación: solo hacen falta si quieres replicar los números.],
))

// ---------------------------------------------------------------- Página 13 (apéndice B)
#pag(13, (
  ni(74, 156, "extra")[Protocolo del 1 %: fine-tuning al estilo de MAE. Se puede saltar.],
  n(302, 431, "pregunta")[La tensión de fondo: *InfoMax* (conservar toda la información) frente a restricciones de *simplicidad* (parsimonia). Es el cuello de botella informacional de Tishby dicho de otra forma (ep. §3.1, M1).],
  n(433, 467, "clave")[La crítica a InfoMax: no distingue el ruido de la semántica, y lo que queremos capturar no es lo de máxima entropía. Por eso conviene predecir solo lo *predecible*.],
  ni(473, 543, "apunte")[La otra línea, la reconstrucción en píxeles o tokens, escala bien pero aprende rasgos de bajo nivel semántico.],
  n(548, 713, "extra")[Comparación con métodos de pérdida local: se puede saltar.],
))

// ---------------------------------------------------------------- Página 14 (apéndice C)
#pag(14, (
  n(105, 175, "pregunta", r: (218, 141, 377, 152))[*Tabla 8: hay un óptimo intermedio de escala.* (0.075, 0.2) da 19.2; (0.15, 0.2), 54.2; (0.2, 0.3), 33.6. Ni muy chico ni muy grande: es la analogía con el nivel básico de Rosch (ep. §3.8, C3).],
  n(187, 218, "cuidado")[El pico es muy agudo (42.4 → 54.2 → 38.9) con una sola corrida, ViT-B, 300 épocas y sin barras de error. Probablemente la escala óptima depende del dominio y del modelo.],
  ni(105, 218, "profundizar")[Experimento natural: *aprender* la escala, por ejemplo adaptando la distribución de escalas según la pérdida. Sería pasar de "el diseñador corta" a "el modelo corta" (ep. §5).],
  n(264, 353, "clave")[*Tabla 9:* más contexto, mejor (31.2 → 54.2). Aquí no hay óptimo intermedio: la información disponible siempre ayuda.],
  n(399, 488, "pregunta", r: (218, 398, 377, 446))[*Tabla 10:* más objetivos, mejor (1 → 9.0; 4 → 54.2), y *no se prueba más de 4*. El barrido se detiene justo donde "¿cuántas piezas?" se vuelve interesante (C4).],
  ni(399, 488, "clave")[Con un solo objetivo el método casi no aprende (9.0). Predecir *varias* partes desde un mismo contexto es lo que obliga a representar la escena.],
  n(569, 627, "apunte")[Resumen de los autores: objetivos grandes (semánticos) y contexto informativo (repartido). Coincide con lo que dice el resumen del paper.],
))

// ---------------------------------------------------------------- Página 15 (apéndice C, D)
#pag(15, (
  n(88, 153, "clave", r: (205, 87, 390, 111))[*Tabla 11:* recortar a la *salida* del target encoder da 67.3; a la *entrada*, 56.1. El objetivo útil es un parche *visto en contexto*, no un parche aislado.],
  n(248, 313, "extra", r: (205, 247, 390, 271))[Un predictor más profundo (de 6 a 12 capas) ayuda: 64.0 → 66.9. Profundidad sí, ancho no (tabla 14).],
  n(427, 492, "cuidado", r: (140, 426, 456, 450))[Tabla 13: un weight decay fijo mejora el 1 % (70.7 frente a 69.4) pero empeora la evaluación lineal completa (76.4 frente a 77.8). Las cifras dependen de qué se mida.],
  n(521, 604, "pregunta", r: (205, 581, 390, 605))[*Tabla 14:* predictor de 384 canales (con cuello de botella), 70.7; de 1024 (sin cuello), 68.4. *Restringir capacidad ayuda sin discretizar nada.* Es una pista directa para C1: parte de lo que se atribuye a discretizar podría ser capacidad (M1).],
  ni(521, 560, "cuidado")[Errata: el texto dice "386 channels" y la tabla, 384. La diferencia es de 2.3 puntos con una sola corrida.],
  ni(567, 647, "profundizar")[Experimento para P1: comparar un cuello de botella continuo (ancho, ruido) con uno discreto (VQ) *con la misma capacidad en bits*. Si rinden igual, la ventaja era de compresión, no de discreción (C1).],
  n(671, 715, "extra")[Apéndice D (fine-tuning completo): se puede saltar. Dato: 87.1 frente a 87.8 de MAE, con 5.3 veces menos épocas.],
))

// ---------------------------------------------------------------- Página 16 (apéndice E)
#pag(16, (
  n(129, 259, "extra")[Tabla 15: fine-tuning completo; no aporta a nuestras preguntas.],
  n(348, 454, "apunte")[Cómo leer las figuras 6 a 8: se fija la representación y se varía el ruido del difusor. Lo *constante* entre muestras está codificado; lo que *varía*, no.],
  n(565, 623, "clave")[Figura 7 (target encoder): conserva objetos y su pose; descarta el detalle fino y el fondo.],
  n(632, 713, "pregunta")[Contraste revelador: MSN (invarianza a aumentos) conserva la clase pero *pierde la pose e incluso el número de objetos*; I-JEPA los conserva. Coincide con la tabla 4 (Clevr/Dist: DINO 53.4, I-JEPA 72.4). Cada objetivo decide qué se descarta (ep. §3.7).],
))

// ---------------------------------------------------------------- Página 17
#pag(17, (
  n(306, 359, "clave")[I-JEPA: las muestras varían en detalles, pero *mantienen* la pose y la posición del objeto.],
  n(619, 672, "cuidado")[MSN: las muestras varían incluso en pose y número de objetos. Es evidencia cualitativa con ejemplos elegidos: sirve para la intuición, no como prueba.],
))
