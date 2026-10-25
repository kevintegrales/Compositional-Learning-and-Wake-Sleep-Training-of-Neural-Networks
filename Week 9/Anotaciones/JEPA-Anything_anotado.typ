// JEPA-Anything (Cui et al., 2026), anotado.
// Compilar desde la carpeta Week 9:
//   tinymist compile --root . Anotaciones/JEPA-Anything_anotado.typ Anotaciones/JEPA-Anything_anotado.pdf
// Convención: margen derecho = CLAVE, PREGUNTA, CUIDADO; margen izquierdo = APUNTE, EJERCICIO, PROFUNDIZAR, EXTRA.
#import "comun.typ": *

#set document(title: "JEPA-Anything anotado")

#let src = "/2609.20800v1.pdf"
#let W = 595.28
#let H = 841.89
#let pag = anotador(src, W: W, H: H, xr: 507, M: 240, ML: 180, xl: 90, tipos: tipos-jepa)

#portada(
  [JEPA-Anything, anotado],
  [_JEPA-Anything: Learning Predictive Models across Different Worlds_ · T. Cui et al. (2026) · arXiv:2609.20800],
  [
    *Para qué son estas notas.* Acompañan la semana 2 de la planificación (sesiones S4 a S6). Supone leído I-JEPA. Como el paper es a una columna, el *margen derecho* lleva lo esencial y lo crítico (CLAVE, PREGUNTA, CUIDADO) y el *izquierdo*, el apoyo (APUNTE, EJERCICIO, PROFUNDIZAR, EXTRA).

    #v(4pt)
    *Si te quedas con cinco ideas*
    + OPF rota el espacio objetivo, lo parte en $K$ subespacios ortogonales con un predictor cada uno y recompone el estado con la pseudoinversa. En el límite ortogonal exacto, la pérdida de predicción es *la misma* que la del JEPA monolítico (pág. 7): lo que cambia es la arquitectura por ramas y los regularizadores.
    + La ortogonalidad garantiza que recomponer no amplifica errores ($kappa = 1$), pero no los corrige: no es el mecanismo M2 de un latente discreto. En los rollouts, el error crece igual o más rápido que en el JEPA estándar (tabla 6).
    + En lo composicional (Pong, combinaciones de intervenciones nunca vistas) la mejora es menor que en lo ya visto: 12.9 % frente a 34.8 % (figura 4).
    + $K = 4$ casi siempre y nunca se comparan valores de $K$ (§3.3.3, tabla 10). "Refinar o ampliar" queda fuera; los autores lo dejan como trabajo futuro (pág. 25).
    + Un factor todavía no es una regla: es continuo, se lee con $R^2 approx 0.3$–$0.4$ y no tiene nombre. Las aplicaciones "científicas" (fármaco, Kepler) son las menos documentadas.

    #v(4pt)
    *Ruta por sesión.* S4: págs. 1–6 y 9. S5: págs. 6–8, 16 y 29. S6: págs. 10–25 (prioridad: 14–16, 18–19, 21–22 y 25) y 30. Las páginas 25–28 son referencias.
  ],
  W: W, H: H, M: 240, ML: 180, tipos: tipos-jepa,
  encabezado: [Anotaciones al margen · Semana 9 · IPRE Aprendizaje Composicional],
  derecha: etiquetas,
)

// ---------------------------------------------------------------- Página 1
#pag(1, (
  n(361, 400, "clave")[Pregunta del paper: ¿un *mismo principio* de aprendizaje predictivo sirve para mundos tan distintos como imágenes, células, pacientes y clima?],
  n(404, 457, "clave")[La pieza nueva es *OPF*: partir el objetivo latente en factores *ortogonales*, uno por predictor, y recomponerlos. JEPA-Anything = JEPA + OPF + un adaptador por dominio.],
  ni(461, 528, "extra")[Siete dominios y tres grupos de experimentos. No hace falta leerlos todos: la ruta está en la portada.],
  n(532, 571, "cuidado")["Mejora en las 10 tareas": varias mejoras son mínimas (DMC píxeles, 0.4 %, figura 5) o están dentro del ruido (control en CausalWorld). Lee los números, no el resumen.],
  n(575, 614, "cuidado")[Los resultados "científicos" (fármaco, Kepler) son los más llamativos y los menos documentados: no se describe el método de nominación y Kepler es una sola corrida (§3.4).],
  n(618, 656, "pregunta")[Partir el espacio en piezas es discretizar *la estructura*, no los valores (ep. §1 y tabla 2). Lee el paper preguntando qué gana eso (P1).],
))

// ---------------------------------------------------------------- Página 2
#pag(2, (
  ni(270, 300, "apunte")[Los recuadros rojos son los problemas que atribuyen al JEPA estándar: un embedding mezcla modos predictivos, lo fácil domina y lo débil recibe gradientes en conflicto (pág. 3).],
  n(395, 422, "cuidado", r: (115, 395, 310, 422))[El esquema sugiere factores limpios ("forma", "posición"). Los experimentos no muestran esa nitidez: en locomoción cada factor explica $R^2 approx 0.3$–$0.4$ de una variable (§3.3.4). La figura es una idealización.],
  n(540, 595, "cuidado", r: (320, 540, 500, 595))["$R^2 = 1.000$" para Kepler: viene de una sola corrida y sin comparación con un JEPA estándar (§3.4.2).],
  n(606, 687, "clave", r: (93, 178, 503, 305))[*La figura 1 lo resume todo.* Arriba: JEPA estándar (un predictor y un embedding "monolítico") frente a JEPA-Anything (4 predictores, 4 factores y un estado completo recompuesto).],
  n(691, 736, "pregunta")[Grupo III: la promesa de usar factores para *descubrir* (abducción, ep. §2.2). Pregunta para S6: ¿descubren algo nuevo o reconocen algo ya sabido? (C5, C6).],
))

// ---------------------------------------------------------------- Página 3
#pag(3, (
  ni(108, 193, "apunte")[Modelo del mundo: un estado interno que permite anticipar consecuencias (Craik, ep. §2.5). Cita a World Models y a DreamerV3, que ya viste en el curso.],
  n(264, 334, "clave")[Definición operativa amplia: un modelo que construye un estado latente desde un contexto y predice *otro estado del mismo mundo* (futuro, región oculta u otra vista).],
  n(345, 475, "clave")[Hipótesis de partida: cada dominio tiene su propia *estructura predictiva* (lugar, objeto y transformación; identidad celular y respuesta…), con componentes de distinta escala y dificultad.],
  n(390, 416, "pregunta")["El número, escala y dificultad de estos componentes varía entre dominios"… y aun así usan $K = 4$ casi siempre (tabla 10). La motivación pide un $K$ adaptativo que el método no tiene (C4).],
  ni(486, 556, "apunte")[JEPA en cuatro líneas: context encoder, target encoder y predictor; predecir en latente abstrae el ruido y la textura. Es lo que viste en I-JEPA.],
  ni(560, 601, "profundizar")[Ref. 5, Balestriero y LeCun (2024): por qué reconstruir píxeles da rasgos poco útiles (prioriza direcciones de alta varianza). Buena lectura para M1 y P1.],
  n(642, 757, "clave")[*Diagnóstico central (S4).* Con un objetivo monolítico, lo fácil o de alta varianza domina el gradiente, varias direcciones cumplen el mismo papel y la estructura débil recibe gradientes en conflicto. Lo plantean como un *problema de asignación de capacidad*.],
  n(686, 757, "cuidado")[Este diagnóstico se *afirma*, pero no se mide en un JEPA estándar (con el espectro de la representación o con gradientes en conflicto). Se infiere de que OPF mejora.],
))

// ---------------------------------------------------------------- Página 4
#pag(4, (
  n(124, 239, "clave")[Receta completa: bases aprendidas $P_k$ que proyectan el objetivo, una rama que predice cada componente, ortogonalidad dentro de cada factor y entre factores, un piso de actividad por factor, varianza del encoder contra el colapso y síntesis del estado completo.],
  n(243, 269, "pregunta")["Las identidades de los factores emergen de la predictibilidad": no se nombran de antemano. Eso los acerca a conceptos aprendidos, pero no garantiza que sean *reglas* (discretas, nombrables, componibles; C5).],
  n(288, 329, "pregunta")["El número y el ancho de los bloques se configuran": $K$ es un hiperparámetro *fijo*. Nunca se decide crear o fusionar factores según los datos; "refinar o ampliar" queda fuera (ep. §4.4; C4, C7).],
  n(339, 440, "pregunta")[Lo "de fábrica" en cada dominio: tokenización, descriptores, qué es contexto y qué es objetivo, y la arquitectura del encoder. El núcleo OPF es lo único común (ep. §4.3, C9).],
  ni(450, 610, "extra")[Mapa de los experimentos: el grupo I lee el encoder, el grupo II reutiliza el estado predicho en bucle y el grupo III analiza los factores. Para nuestras preguntas, pesa más el grupo II.],
))

// ---------------------------------------------------------------- Página 5
#pag(5, (
  ni(383, 454, "apunte")[Notación. $H$: tokens de contenido; $S$: descriptores estructurales (posición, tiempo, identidad); $C$ y $T$: índices de contexto y objetivo.],
  n(466, 483, "clave", r: (220, 464, 375, 484))[*Ecuación (1).* Todo lo específico del dominio vive aquí: el adaptador $cal(A)_delta$ produce tokens y descriptores, y el muestreador $cal(V)_delta$ elige contexto y objetivo. Lo demás es un solo algoritmo.],
  ni(533, 590, "apunte")[$z_c = f_theta (H_C, S_C)$ es el contexto. $z_t$ se calcula con *toda* la observación y se recorta después, igual que en I-JEPA (su tabla 11).],
  ni(603, 616, "extra")[EMA, igual que en I-JEPA.],
  n(652, 693, "cuidado")["Hiperparámetros como el número de factores pueden elegirse por escala computacional": admiten que $K$ es una perilla de ingeniería, no algo inferido de los datos.],
))

// ---------------------------------------------------------------- Página 6
#pag(6, (
  n(86, 208, "pregunta", r: (93, 104, 503, 209))[*Tabla 1 = la frontera entre lo innato y lo común.* Columna central: lo que el diseñador aporta por dominio. Columna derecha: el principio general (ep. §4.3, C9).],
  n(235, 291, "clave")[Condición de uso: el objetivo debe depender estadísticamente del contexto y ser otro estado del *mismo* sistema. Sin relación predictiva no hay nada que aprender.],
  n(330, 385, "clave")[$K$ proyectores $P_k in RR^(d times r)$ con $K r = d$: los $K$ subespacios ortogonales *particionan* todo el espacio objetivo en piezas que no se solapan.],
  ni(391, 413, "apunte", r: (190, 389, 325, 414))[$z_t^((k)) = P_k^top tilde(z)_t$: las coordenadas del objetivo en la base del factor $k$. $tilde(z)_t$ lleva *stop-gradient*: el objetivo no se mueve con esta pérdida.],
  ni(415, 455, "apunte")[Los $P_k$ sí reciben gradiente: el modelo elige *qué direcciones* van a cada factor según lo que logra predecir. Ese es el sentido de "emergen de la predictibilidad".],
  ni(458, 513, "apunte")[Un predictor $q_k$ por factor, que puede ser una red independiente o una cabeza sobre un tronco común.],
  n(511, 578, "clave", r: (200, 555, 400, 578))[*Síntesis (5):* $hat(z)_t = (P^top)^dagger hat(u)_t$. Si $P$ es ortogonal, $(P^top)^dagger = P$ y el estado completo es $sum_k P_k hat(z)_t^((k))$: sumar cada pieza en sus direcciones.],
  ni(540, 600, "ejercicio")[Comprueba que si $P^top P = I_d$, entonces $(P^top)^dagger = P$. Pista: la pseudoinversa de una matriz invertible es su inversa.],
  n(637, 663, "cuidado")["Un tronco común seguido de cabezas por rama": si las cabezas fueran *lineales*, $P [q_1; dots; q_K]$ sería otra capa lineal y la factorización no cambiaría la clase de funciones, solo la parametrización. El paper no dice qué variante usa en cada caso.],
  n(673, 773, "clave")[*Modo dinámico:* el siguiente estado se predice por factores, se sintetiza y se vuelve a alimentar. Aquí importa la estabilidad (M2): el error de un paso entra al siguiente.],
))

// ---------------------------------------------------------------- Página 7
#pag(7, (
  ni(87, 128, "extra")[Planificación: un planificador (CEM) puntúa trayectorias imaginadas con una recompensa. OPF solo aporta el modelo.],
  ni(139, 232, "ejercicio", r: (210, 174, 385, 212))[*Ejercicio clave (S5).* Con $P$ ortogonal: $sum_k norm(hat(z)^((k)) - P_k^top z)^2 = norm(hat(u) - P^top z)^2 = norm(P hat(u) - z)^2 = norm(hat(z) - z)^2$. Es decir, salvo la constante $1 slash (K|T|r)$, $cal(L)_"pred"$ es *exactamente* la pérdida L2 del JEPA monolítico sobre el estado sintetizado.],
  n(154, 232, "pregunta")[Consecuencia del ejercicio: en el límite ortogonal la pérdida de predicción no cambia. La ganancia de OPF tiene que venir de (i) la arquitectura por ramas, (ii) los regularizadores de actividad y varianza o (iii) la dinámica de optimización. El paper no separa estas tres (C2).],
  n(243, 375, "clave", r: (230, 308, 365, 376))[*$cal(L)_"orth"$ (7).* Primer término: cada base es ortonormal ($P_k^top P_k approx I_r$). Segundo término: bases distintas son ortogonales entre sí ($P_i^top P_j approx 0$), lo que impide que dos factores aprendan la misma dirección.],
  n(387, 457, "pregunta")[Pariente de Barlow Twins y VICReg: reducción de redundancia (Barlow, 1961; ep. §3.1). La diferencia es que aquí la no redundancia se impone a *subespacios del objetivo*, no a las dimensiones de un embedding.],
  ni(468, 539, "extra")[La descomposición QR exacta solo se usa para el análisis geométrico. Los modelos entrenados usan proyectores casi ortogonales y la pseudoinversa.],
  n(547, 652, "clave", r: (180, 606, 505, 645))[*Proposición 1.* Si las bases son ortonormales y mutuamente ortogonales, $P$ es una matriz ortogonal $d times d$: los factores son un cambio de base y no se pierde nada ($norm(P^top z) = norm(z)$).],
  ni(569, 700, "ejercicio")[Demuéstrala: $P_i^top P_j = delta_(i j) I_r$ implica $P^top P = I_d$; como $P$ es cuadrada ($K r = d$), también $P P^top = I_d$. Luego expande $norm(P^top z)^2$ por bloques.],
  n(653, 695, "pregunta")[Lectura crítica: aquí "factorizar" es *rotar* el espacio y agrupar coordenadas en $K$ bloques. No se discretizan valores ni identidades; se parte la geometría (ep. tabla 2, fila "estructura").],
))

// ---------------------------------------------------------------- Página 8
#pag(8, (
  n(85, 209, "clave", r: (180, 129, 415, 152))[*Corolario 1.* Con $P$ ortogonal, un error $e$ en los factores produce *el mismo* error en el estado: $norm(hat(z) - z) = norm(e)$ y $kappa_2(P) = 1$. Sin ortogonalidad, $P$ puede ser casi singular y amplificar los errores sin cota.],
  n(154, 209, "pregunta")[Responde la pregunta del .epub (§3.2): esto *no* es corrección de errores. Un estado discreto se "redondea" y vuelve a la categoría correcta; aquí el error ni crece ni se corrige (es una isometría). Evita amplificar, pero no restaura.],
  ni(154, 281, "ejercicio")[Toma $d = 2$, $K = 2$, $r = 1$, $p_1 = (1, 0)$ y $p_2 = (cos epsilon, sin epsilon)$. Muestra que $sigma = sqrt(1 plus.minus cos epsilon)$ y que $kappa_2 = cot(epsilon slash 2) -> infinity$ cuando $epsilon -> 0$: el caso de "direcciones casi repetidas".],
  n(298, 339, "cuidado")[La garantía es solo para el paso *lineal* de síntesis. En un rollout, el error se compone a través de predictores no lineales, y eso la proposición no lo controla.],
  n(378, 544, "clave")[*Dos pisos de varianza* (tipo bisagra). $cal(L)_"fac"$ obliga a que cada coordenada de cada factor varíe entre muestras (que ningún factor "se apague"). $cal(L)_"enc"$ hace lo mismo con el encoder online, contra el colapso.],
  ni(553, 584, "apunte")[$cal(L)_"enc"$ es el término de varianza de VICReg. I-JEPA no lo tenía: evitaba el colapso solo con el EMA y el predictor.],
  n(592, 697, "cuidado", r: (185, 658, 412, 697))[*Ojo con la ecuación (10).* Según §3.1, el JEPA estándar de comparación *no* recibe estos regularizadores. Cada comparación mezcla factorización con anticolapso explícito. Falta el control obvio: JEPA estándar más $cal(L)_"enc"$.],
  n(705, 731, "pregunta")[¿Qué explica la mejora? Candidatos: capacidad por ramas (M1), no redundancia (Barlow), varianza anticolapso o estabilidad de la síntesis (M2). Este paper solo audita la geometría (tabla 5); no separa los mecanismos (C2).],
))

// ---------------------------------------------------------------- Página 9
#pag(9, (
  ni(106, 191, "extra")[El bucle de entrenamiento: seis pasos, idénticos en todos los dominios.],
  n(206, 357, "clave")[*Modo representación:* se descartan los proyectores y los predictores; queda solo el encoder online. OPF actúa como *principio de entrenamiento* que moldea ese encoder.],
  n(371, 456, "clave")[*Modo operacional:* se conservan predictores y proyectores para hacer rollouts. Es el modo "modelo del mundo" en el sentido de Dreamer.],
  n(467, 601, "pregunta")[*Modo análisis:* $u_k (x) = P_k^top z_delta (x)$ son las coordenadas del factor $k$. Es lo más parecido a una "variable" que ofrece el sistema, pero es continua y de dimensión $r$, no un símbolo (C5).],
))

// ---------------------------------------------------------------- Página 10
#pag(10, (
  ni(359, 404, "extra")[El atlas de escenarios sirve como mapa; no hace falta detenerse.],
  n(428, 562, "clave")[*Control experimental:* mismo adaptador, encoder, muestreo, presupuesto, datos y readout. Solo cambia la pérdida: monolítica frente a $cal(L)_"OPF"$.],
  n(491, 532, "cuidado")["Solo cambia la pérdida", pero esa pérdida trae cuatro cosas a la vez (ecuación 10). La comparación aísla OPF *completo*, no la factorización.],
  ni(648, 753, "apunte")[El grupo I termina en un readout. El grupo II reutiliza el estado predicho en bucle, que es donde se pone a prueba un modelo del mundo.],
))

// ---------------------------------------------------------------- Página 11
#pag(11, (
  ni(107, 152, "extra")[Tabla 2: hojéala solo para ver que $K$ es 4 en casi todo (5 en Pong) y que las semillas van de 3 a 10.],
  n(356, 422, "pregunta", r: (94, 354, 500, 423))[Pong usa $K = 5$, el único distinto. ¿Coincide con el número de variables causales conocidas del entorno? Si es así, $K$ codifica conocimiento previo del dominio. Verificar en Lippe et al. (2022).],
  n(648, 692, "cuidado")[La validación biológica no se compara con ningún otro método para proponer intervenciones.],
  n(694, 737, "cuidado")["One analyzed run": el resultado de Kepler viene de una sola corrida.],
))

// ---------------------------------------------------------------- Página 12
#pag(12, (
  n(165, 305, "cuidado", r: (129, 199, 466, 230))[Diferencias pequeñas: INJ .572 → .581 (DINOv3) y .483 → .490 (SigLIP2), sin desviaciones estándar aunque hay 10 semillas.],
  n(351, 407, "pregunta")[Esta tarea sí es composicional: *dónde* ocurre un cambio × *qué* operación, con combinaciones nunca vistas por el readout (ep. §3.4, M4). La mejora existe, pero es chica.],
  ni(551, 696, "extra")[Detalles del protocolo (alineación húngara, leave-one-cell-out): se pueden saltar.],
))

// ---------------------------------------------------------------- Página 13
#pag(13, (
  n(86, 192, "cuidado", r: (95, 150, 500, 193))[Sin desviaciones (5 semillas). La mayor diferencia viene de *predecir en latente*: de scGPT a Cell-JEPA, 0.529 → 0.719 en zero-shot. OPF agrega menos (→ 0.775).],
  n(237, 308, "pregunta")[El argumento de I-JEPA en otro dominio: reconstruir genes gasta capacidad en ruido técnico (dropout), y predecir en latente lo evita (M1, ep. §3.1).],
  ni(635, 763, "extra")[Dominio clínico: lectura rápida. Mira solo la conclusión.],
))

// ---------------------------------------------------------------- Página 14
#pag(14, (
  ni(266, 287, "extra")[Figura 3: ranking por PRAUC medio. No muestra el tamaño de la diferencia con el JEPA monolítico ni su variabilidad.],
  n(508, 598, "clave")[*El grupo II es el corazón para P1:* el estado predicho se reutiliza en bucle, así que los errores de representación se vuelven errores *dinámicos* (M2).],
  n(632, 732, "clave")[*CITRIS Pong:* se interviene una o varias variables del juego y el modelo recibe la etiqueta de qué cambió. Debe predecir el estado siguiente.],
))

// ---------------------------------------------------------------- Página 15
#pag(15, (
  n(80, 272, "cuidado", r: (94, 80, 500, 237))[*Mira los dos primeros renglones.* El JEPA estándar tiene casi el mismo error en intervenciones simples y combinadas (0.00954 y 0.00944). JEPA-Anything mejora mucho las simples (0.00622) y menos las combinadas (0.00822): *la brecha composicional crece con OPF*.],
  n(296, 426, "clave")[Dos niveles de generalización: (1) una intervención vista; (2) una *combinación nunca vista* de intervenciones vistas por separado. El segundo es generalización composicional en sentido estricto (ep. §3.4; Lake y Baroni).],
  n(356, 382, "pregunta")["Recombinar reglas de cambio aprendidas": si cada factor capturara una variable, intervenir dos variables sería cambiar dos factores. Es la promesa de "factor = regla"; revisa si la evidencia alcanza (C5).],
  ni(577, 677, "apunte")[Auditoría: misma capacidad, pero con cabezas sin restricción de ortogonalidad. Ojo: solo mide *geometría*, no error de predicción.],
))

// ---------------------------------------------------------------- Página 16
#pag(16, (
  n(86, 202, "clave", r: (120, 140, 476, 203))[*Tabla 5.* Con OPF, el solapamiento es casi 0, $sigma_"min" approx 1$, $kappa_2 approx 1$ y la reconstrucción es exacta. Sin restricción, $kappa_2 approx 439$. Es la proposición 1 confirmada en un modelo entrenado.],
  n(233, 363, "cuidado")[Pero es casi una tautología: si se *penaliza* la falta de ortogonalidad, el resultado es ortogonal. Falta lo importante: ¿predicen peor las cabezas sin restricción, en un paso y en rollout? No se reporta.],
  n(397, 512, "clave")[Dos pruebas de modelo del mundo: fuera de distribución (¿aprendió una regla de transición reutilizable o memorizó?) y rollout de 6 pasos (¿se acumula el error?).],
  n(472, 512, "pregunta")[Aquí debería verse el mecanismo M2. Para verlo, compara cuánto *crece* el error del paso 1 al 6, no solo su nivel (tabla 6, pág. 17).],
  ni(638, 760, "extra")[Protocolo: 10 tareas, 5 semillas, mismo backbone y presupuesto.],
))

// ---------------------------------------------------------------- Página 17
#pag(17, (
  n(234, 280, "cuidado", r: (94, 80, 500, 232))[Figura 5a: de 39.7 % (Burgers) a 0.4 % (DMC píxeles); cuatro de las nueve tareas mejoran menos de 10 %. Figura 5b: en control, ambos retornos son negativos y los intervalos se solapan, así que no hay mejora clara.],
  n(359, 385, "pregunta")[OPF no "redondea" estados como un latente discreto (los categóricos de DreamerV3). Un experimento interesante: el mismo rollout con latentes categóricos (M2, P1).],
  n(399, 535, "cuidado", r: (128, 476, 467, 536))[*Revisa el crecimiento del error.* Burgers: ×3.48 (estándar) frente a ×3.65 (OPF). Aguas someras: ×1.48 frente a ×1.63. CausalWorld: ×1.00 frente a ×1.04. OPF parte con menos error, pero el error *crece igual o más rápido*: la ventaja es de precisión a un paso, no de estabilidad.],
  ni(476, 535, "ejercicio")[Calcula las razones paso 6 / paso 1 de cada fila. ¿Qué esperarías ver si OPF realmente frenara la acumulación de error?],
  n(665, 752, "clave")[APEBench: mejoras grandes y consistentes (Burgers, 45–50 %; KS, 13 %), con desviaciones reportadas y en todas las semillas. Es de los resultados más sólidos del paper.],
))

// ---------------------------------------------------------------- Página 18
#pag(18, (
  n(287, 434, "cuidado", r: (94, 338, 502, 365))[La ventaja se *reduce* con el horizonte: −5.8 % a H20 y −3.2 % a H50. Además, el error a H50 es menor que a H20 en ambos modelos; quizá porque Burgers viscoso se disipa hacia un estado suave (hipótesis: verifícala).],
  n(445, 486, "pregunta")[3.78 factores efectivos de 4, sin uno dominante (0.32). Es la única medida de *cuántos* factores usa el modelo. Si con $K = 8$ siguieran todos activos, ¿hay 8 "cosas" que predecir o es solo capacidad repartida? (C4).],
  n(520, 746, "clave")[Planificación con CEM: se imaginan muchas secuencias de acciones y se ejecuta la primera de la mejor. Un error latente pequeño puede invertir el orden de las acciones.],
))

// ---------------------------------------------------------------- Página 19
#pag(19, (
  n(80, 265, "cuidado", r: (94, 80, 500, 228))[Figura 6. En Hopper gana el JEPA estándar, con un intervalo que no cruza el 0. En Walker2d el intervalo cruza el 0 (no hay diferencia). Solo HalfCheetah favorece a OPF, con un intervalo muy ancho: 1 de 3.],
  n(369, 425, "cuidado")[*Calibran anchos para $K in {1, 2, 4, 8}$, pero no reportan resultados para esos $K$.* Es exactamente el experimento que pide C4 (¿cuántos factores?), y no está.],
  ni(369, 425, "profundizar")[Experimento que valdría la pena: barrer $K$ y elegirlo con un criterio (MDL, verosimilitud marginal, ganancia predictiva marginal). Sería OPF "a lo DreamCoder": ampliar solo si la nueva pieza paga su costo (ep. §4.4).],
  n(509, 641, "clave")[Prueba en tres partes: ¿cada factor está activo? (varianza), ¿es legible? (sonda lineal) y ¿se usa? (reemplazarlo por su media y ver cuánto empeora).],
  n(656, 726, "pregunta")[$R^2$ de 0.29 a 0.42: cada factor se *inclina* hacia una variable (pie, torso…) pero no la captura. No es discreto ni se puede nombrar con nitidez: un factor *no* es todavía una regla (C5).],
))

// ---------------------------------------------------------------- Página 20
#pag(20, (
  n(80, 255, "cuidado", r: (94, 80, 500, 220))[Falta una línea de base: borrar 8 de 32 dimensiones de *cualquier* estado aprendido empeoraría el rollout. Habría que hacer lo mismo con 8 direcciones al azar, o con un subespacio del JEPA estándar.],
  n(420, 476, "clave")[La cadena activo → legible → usado muestra que los 4 canales no son decorativos, pero no que correspondan a "partes del mundo".],
  ni(492, 741, "extra")[Moléculas: lectura rápida. Detalle técnico: OPF se aplica respetando la equivariancia $O(3)$, con $P_k times.o I_3$.],
))

// ---------------------------------------------------------------- Página 21
#pag(21, (
  n(86, 274, "cuidado", r: (144, 155, 452, 182))[Mejoras consistentes pero pequeñas frente a TrajCast-JEPA (agua: RMSD 2.536 → 2.459), sin desviaciones. La mayor ganancia vuelve a ser *pasar de cero a JEPA* (3.331 → 2.536).],
  n(429, 504, "pregunta")[Grupo III: los factores como "generador de hipótesis". Es lo más cercano a la abducción de Peirce en el paper (ep. §2.2, C6).],
  n(521, 638, "cuidado")[*No se describe cómo* el análisis de factores nominó IL-18 + CD73, ni cuántos candidatos se evaluaron, ni si otro método (o la literatura) lo habría propuesto. Sin eso, no se puede atribuir el hallazgo a los factores.],
))

// ---------------------------------------------------------------- Página 22
#pag(22, (
  ni(297, 354, "extra")[Resultados de laboratorio: no hace falta evaluarlos. Lo relevante es la nota anterior sobre el método de nominación.],
  n(379, 482, "pregunta")[¿Descubrir o reconocer? La ley de Kepler ya se conocía: el análisis *comprueba* que una ley sabida aparece en el latente. Es validación, no descubrimiento. Aun así, muestra que los factores capturan algo físico (C5, C6).],
  n(493, 548, "cuidado")[Falta el control: ¿un JEPA monolítico, o un análisis espectral de las trayectorias crudas, también recupera la pendiente −3/2? La frecuencia orbital ya está en la periodicidad de los datos.],
))

// ---------------------------------------------------------------- Página 23
#pag(23, (
  ni(363, 508, "profundizar")[Línea de modelos del mundo: Dreamer (ya visto), TD-MPC2, DINO-WM y V-JEPA 2. Para seguir de JEPA a planificación: V-JEPA 2 (ref. 4).],
  ni(522, 608, "profundizar")[Ref. 28, Sobal et al. (2022): los JEPA se enfocan en *rasgos lentos*, lo que cambia poco entre contexto y objetivo. Útil para entender qué decide no explicar un JEPA.],
  n(622, 693, "clave")[La diferencia con β-VAE, Slot Attention o CITRIS: esos buscan factores *semánticos* (variables generativas, objetos, causas). OPF no promete semántica; solo reparte capacidad.],
  ni(652, 678, "profundizar")[Ref. 17, Kipf et al. (2020): modelos del mundo con objetos y relaciones explícitas. Buen contraste para P1: estructura discreta explícita frente a factores continuos.],
  n(697, 723, "cuidado")[Locatello et al. (2019): sin sesgos inductivos ni supervisión, el *disentanglement* no supervisado no es identificable. Por eso los factores de OPF no tienen por qué coincidir con variables reales (ep. Guía B).],
))

// ---------------------------------------------------------------- Página 24
#pag(24, (
  n(87, 143, "clave")[Posicionamiento honesto: OPF reparte capacidad "sin suponer identidades de objeto, causa o semántica". Tenlo presente al leer las secciones "científicas".],
  n(191, 402, "cuidado")[El resumen admite lo de Hopper, pero repite que el método respalda los "rollouts repetidos", algo que la tabla 6 no respalda del todo (el error crece igual).],
  n(450, 595, "pregunta")[Las discrepancias entre lo esperado y lo observado deberían "motivar revisiones de las variables o hipótesis": es el ciclo conjeturar–refinar de P2 (ep. §4.4), pero solo como plan futuro.],
  ni(606, 736, "extra")[ScienceIDE, ScienceBuddy y DFM son proyectos de los mismos autores (PhAI Labs). Se puede saltar.],
))

// ---------------------------------------------------------------- Página 25
#pag(25, (
  n(124, 269, "clave")[*Las limitaciones que reconocen los autores* (las que busca la Guía B): calibrar la incertidumbre bajo cambio de distribución; saber cuándo el modelo es confiable; *revisar los factores* cuando aparece estructura faltante; los factores no establecen mecanismos causales; y una arquitectura común no garantiza representaciones alineadas entre dominios.],
  n(154, 179, "pregunta")["Revisar los factores predictivos cuando nueva evidencia revela estructura faltante" es exactamente refinar o ampliar (C4, C7). Los autores lo dejan abierto: es un hueco que podemos tomar.],
))

// ---------------------------------------------------------------- Páginas 26–28 (referencias)
#pag(26, ())
#pag(27, ())
#pag(28, ())

// ---------------------------------------------------------------- Página 29 (apéndice A, B)
#pag(29, (
  n(157, 212, "clave", r: (180, 182, 410, 212))[*Proposición 2.* Si $norm(P^top P - I)_2 <= epsilon$, la amplificación del error está acotada por $1 slash sqrt(1 - epsilon)$. Con la tabla 5 ($kappa_2 approx 1.00005$), en la práctica no hay amplificación.],
  ni(293, 337, "ejercicio")[Deriva (12): los valores propios de $P^top P$ están en $[1 - epsilon, 1 + epsilon]$ y $sigma_i (P) = sqrt(lambda_i (P^top P))$. Luego, $kappa_2 = sigma_max slash sigma_min$.],
  ni(442, 597, "extra")[Detalles de implementación: se pueden saltar.],
))

// ---------------------------------------------------------------- Página 30
#pag(30, (
  n(86, 262, "pregunta", r: (158, 120, 440, 263))[*Tabla 10:* $K = 4$ en todos los experimentos salvo Pong ($K = 5$), con los mismos coeficientes en casi todos. El número de factores no se adapta al dominio, contra lo que sugiere la introducción (C4).],
))
#pag(31, ())
