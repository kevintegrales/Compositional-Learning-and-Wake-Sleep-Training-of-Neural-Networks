# Plan del capítulo: *¿Qué gana y qué pierde un modelo al discretizar?*

**Formato:** documento Typst tipo capítulo de libro, de unas 53 páginas y con unas 22 figuras, en `Week 10/`.
**Foco:** la Pregunta 1 del .epub (*¿por qué, al discretizar ciertos espacios, mejoran los algoritmos?*), vista a través de las preguntas del profesor y de tus dos preguntas abiertas.
**Redacción:** en dos tandas (ver §5).
**Lectura:** una semana, en sesiones de unas 10 páginas.

---

## Estado (25 de octubre)

**La tanda 1 está escrita** y compila en `main.pdf`: 42 páginas en total, de las cuales unas 35 son contenido, más portada, índice, guía y referencias. Hay un archivo por capítulo en `chapters/`:

| Cap. | Archivo | Contenido | Págs. |
|---|---|---|---|
| — | `00_guia.typ` | Guía de lectura, tabla de preguntas, convenciones | 2 |
| I | `01_introduccion.typ` | El paquete de seis piezas, cómo usamos el documento de IA | 3 |
| II | `02_fundamentos.typ` | Latente, bits, MSE frente a CE, RL, autosupervisado, vocabulario | 5 |
| III | `03_como_se_discretiza.typ` | One-hot, VQ, FSQ, RVQ, LFQ; niveles; geometría; STE | 6 |
| IV | `04_evidencia.typ` | Dreamer, Meyer, DCWM, Stochastic MuZero, MoP-JEPA, Mao, MAR, Garrido | 12 |
| V | `05_seguir_el_error.typ` | **Nuevo:** detectar, corregir, localizar y contar errores | 8 |

**Cambios respecto del plan original:**
- Se agregó el capítulo V, *Seguir el error*, a pedido. Incluye un modelo simple con cálculos exactos: la variabilidad por paso en discreto es $2\bar\Phi(d/2\sigma)\cdot d^2$ frente a $\sigma^2$ en continuo, y el cruce está en $\sigma \approx 0{,}29\,d$.
- La sección "Desarmar el paquete" pasa a la tanda 2, como primera parte del capítulo VI.
- Todas las figuras (19 por ahora) se generan con `figures/generar.py` (matplotlib → SVG), no con CeTZ.
- Las figuras flotan al inicio o al final de la página para no dejar huecos.
- **Corrección al documento de IA:** el *rotation trick* lleva el rFID de VQGAN de 5,0 a **1,1**, no a 1,6, y el uso del diccionario de 2 % a 27 %. Los demás números revisados (DreamerV2, Meyer, MAR, Mao, MoP-JEPA) coinciden.

**La tanda 2 también está escrita.** El documento completo tiene 68 páginas: unas 22 000 palabras de lectura, más portada, índice, glosario y referencias.

| Cap. | Archivo | Contenido | Págs. |
|---|---|---|---|
| VI | `06_atribucion.typ` | Firma de cada pieza, confusores, matriz de experimentos, diseño factorial (P3), principio candidato (A1) | 7 |
| VII | `07_colapso.typ` | Cinco colapsos; colapso posterior y discreción (P1); colapso del diccionario (P5); errores acumulados y colapso (N) | 9 |
| VIII | `08_jepa.typ` | Inventario de discretización en la familia JEPA (P4) | 5 |
| IX | `09_cuando.typ` | Criterios a favor y en contra con diagnósticos, árbol de decisión y mapa (A2) | 4 |
| X | `10_conclusiones.typ` | Respuestas cortas, vínculo con el proyecto, preguntas para la reunión | 3 |
| — | `11_glosario.typ` | Glosario | 1 |

**Datos nuevos verificados en la tanda 2:**
- FSQ: VQ no usa más de ~2^10 códigos y cae bajo el 50 % desde 2^11; FSQ usa casi todos en 2^14.
- Discrete-JEPA: peor que I-JEPA al inicio y mejor en el paso 1000 (LPIPS 0,0242 frente a 0,1554), pero con hiperparámetros distintos.
- I-JEPA: tabla 7 (66,9 frente a 40,7) y tabla 14 (predictor angosto: 70,7 frente a 68,4).
- Los papers de la semana 4 (Wang et al., 2021; Li et al., 2025), según los apuntes.

---

## 0. Las preguntas que responde el capítulo

### Preguntas del profesor

| # | Pregunta original (resumida) | Lo que pide | Dónde |
|---|---|---|---|
| P1 | Colapso con descenso de gradiente. ¿Es más difícil con una representación discreta? ¿Y si se parte con elementos bien separados? | Sobre todo el **colapso posterior** de la semana 4: el *decoder* aprende a ignorar el latente. ¿Lo hace más difícil un latente discreto? ¿Ayuda partir con códigos bien separados? | §11 |
| P2 | ¿Qué ha influido en la idea de que discretizar es mejor? Espacios latentes para tareas difíciles como RL. ¿Dónde gana lo continuo? | La evidencia que hizo que la comunidad creyera que discretizar ayuda (modelos del mundo, RL) y los casos documentados donde gana lo continuo. | §4 a §7 |
| P3 | Si la discretización resuelve un problema, ¿qué experimento lo comprueba o lo desmiente? ¿Qué produce la mejora? "¿Dado que…?" (frase cortada) | Diseñar experimentos que separen *qué parte* de la discretización produce la mejora. | §8 |
| P4 | En JEPA, ¿alguien discretiza? ¿Por qué? | Inventario de la familia JEPA: qué se discretiza, con qué motivo y con qué resultado. | §14 |
| P5 | *Codebook collapse*: ¿en qué modelos o métodos ocurre? | Catálogo de dónde aparece el colapso del diccionario y cómo se combate. | §12 |
| N | *"accumulated errors =?= collapse"* (nota nueva) | ¿Son lo mismo el error que se acumula al encadenar predicciones y el colapso? Si no lo son, ¿qué relación tienen? | §13 |

### Tus dos preguntas abiertas

El profesor dice que no tienen respuesta establecida. El capítulo no las cierra, pero llega a una **conjetura respaldada** por la evidencia y propone cómo ponerla a prueba.

| # | Pregunta | Dónde |
|---|---|---|
| A1 | ¿Es realmente la discreción lo que da ventajas, o alguna característica que viene implicada por ella? ¿Hay un principio más allá de la discreción? | §9 |
| A2 | ¿Qué características comparten los espacios (o instancias) donde conviene discretizar, y aquellos donde no conviene? | §15 |

**Respuesta que se va a defender (adelanto):**
- **A1:** En casi todos los casos documentados, el beneficio se puede reproducir *sin* discretizar, atacando directamente la propiedad responsable: multimodalidad, capacidad limitada, esparsidad u ortogonalidad, o una pérdida de clasificación. Lo que la discreción aporta de forma propia es la **identidad exacta**: dos estados son *el mismo* símbolo, lo que permite enumerar, reutilizar, componer y corregir errores hasta cero. El principio candidato que agrupa los casos es **"invarianza dentro de una clase, margen entre clases, con clases que coinciden con la estructura del mundo"**. La discretización es la forma más extrema y barata de imponerlo, pero no la única.
- **A2:** Discretizar conviene cuando el mundo tiene "huecos" (estados agrupados, ramificaciones, objetos, reglas), cuando la predicción se encadena muchas veces o se comunica entre módulos, cuando el modelo tiene poca capacidad para el mundo que debe modelar y cuando hay que buscar o componer. No conviene cuando la variable es continua y rica y la tarea exige precisión fina, cuando importa interpolar y cuando hay que optimizar por gradiente dentro del latente. Cada criterio se acompaña de un **diagnóstico medible** para decidir *antes* de discretizar.
- **N:** No son lo mismo, pero son **dos desenlaces del mismo bucle**: cuando la salida de un modelo vuelve a ser su entrada (en predicciones encadenadas) o su objetivo (*bootstrapping* en BYOL/JEPA, o entrenar con datos generados). Si el bucle *contrae*, los errores se apagan junto con la información y aparece el colapso. Si *expande*, los errores crecen. Discretizar contrae dentro de cada celda y preserva la separación entre celdas, como los atractores de Hopfield. Por eso corrige errores sin colapsar, salvo cuando el error es tan grande que el estado salta a la celda equivocada.

---

## 1. Hilo conductor

> **Discretizar no es una sola intervención, sino un paquete de cambios simultáneos.** Al pasar de un vector continuo a un código discreto cambian, a la vez:
> 1. la **capacidad**: cuánta información cabe;
> 2. la **geometría** de la codificación: *one-hot* (todos los códigos equidistantes) frente a vectores de un diccionario (con una noción de cercanía);
> 3. la **pérdida**: clasificación con entropía cruzada frente a regresión con MSE;
> 4. la **elección entre modos**: escoger un futuro en vez de promediarlos;
> 5. el **redondeo**: los errores pequeños se borran;
> 6. la **identidad exacta**: se puede enumerar, reutilizar y componer.
>
> El capítulo atribuye cada beneficio y cada costo documentado a una pieza concreta del paquete.

Las Partes II a V van reuniendo evidencia. La Parte VI la condensa en criterios (A2), y el cierre responde cada pregunta en un recuadro.

---

## 2. Reglas de estilo (por tu comentario sobre el .epub)

1. **Ningún concepto se usa antes de explicarlo.** Las ideas base van en recuadros *Idea base* de entre 5 y 15 líneas, situados justo antes de usarlas. Ejemplos: entropía y bits, por qué MSE predice la media, qué es un *rollout*, qué es MCTS, qué es una pérdida de difusión, qué es FID.
2. **No hay nombres sueltos.** Si se menciona un autor o un modelo, se dice qué hizo y por qué importa aquí. Si no aporta a una conclusión, no se menciona. Habrá poca historia y poca filosofía: solo cuando ayudan a concluir.
3. **Cada modelo se presenta con el mismo formato:**
   1. qué problema resuelve y cómo funciona, desde cero;
   2. qué se discretiza;
   3. qué mejora y qué empeora;
   4. qué pieza del paquete lo explica.
4. **Cada sección se abre con *En una frase*** (la idea central) **y se cierra con *Qué nos llevamos*** (la conclusión, en 3 a 5 viñetas). Leídos seguidos, los recuadros de cierre forman un resumen del capítulo.
5. **Cada afirmación lleva su grado de certeza:** *establecido* (hay un experimento controlado), *sugerido* (hay evidencia indirecta) o *conjetura* (propuesta nuestra).
6. **Todos los números se verifican contra el paper original.** Ninguna figura muestra datos inventados: las que no reproducen números reportados se marcan como *esquema cualitativo*.
7. Los modelos del curso (LPN, NLI, VQ-VAE, Gumbel-Softmax, DreamerV3, colapso posterior, I-JEPA y JEPA-Anything) se recuerdan en 3 a 6 líneas, remitiendo a tus apuntes.

---

## 3. Estructura y presupuesto de páginas

### Portada y guía de lectura (1 p.)
- La tabla de preguntas y secciones en versión corta, más el calendario de lectura.

### Introducción: el paquete de la discretización (2,5 p.)
- La Pregunta 1 del .epub, tu pregunta A1 (que ya aparecía en el reporte de la semana 9) y por qué la pregunta "¿discreto o continuo?" está mal planteada.
- Cómo encaja el documento de IA del profesor: es un catálogo de evidencia, y aquí cada pro o contra se lee como una pieza del paquete.
- **Fig. 1 — El paquete:** un vector entra al cuantizador y salen seis flechas, una por pieza.
- **Fig. 2 — Mapa del capítulo:** las preguntas, las partes y sus conexiones.

### Parte 0. Fundamentos (5 p.)
*Todo lo que el resto del texto da por sabido, explicado en simple.*

**§1. Las ideas base**
- **1.1 Espacio latente.** *Encoder*, *decoder* y autoencoder, más el recordatorio del VAE en media página.
  - **Fig. 3:** un autoencoder con su cuello de botella.
- **1.2 Información y bits.**
  - Cuántos bits lleva un código de *K* entradas (log₂ *K*).
  - Por qué un vector continuo "sin ruido" podría llevar infinitos bits, y por qué en la práctica el ruido lo limita.
  - Entropía y perplejidad (para medir el uso del diccionario).
- **1.3 Regresión frente a clasificación.**
  - Por qué minimizar el MSE da la *media* de los futuros posibles, y por qué la entropía cruzada da una *distribución*.
  - Es una ecuación clave que se usa en casi todo el capítulo.
  - **Fig. 4:** dos futuros posibles, A y B. MSE responde "en medio"; la entropía cruzada reparte probabilidad entre A y B.
- **1.4 RL y modelos del mundo en una página.**
  - Agente, recompensa, política y *rollout* imaginado.
  - El error compuesto al encadenar predicciones (se usa en §13).
  - **Fig. 5:** el agente con su modelo del mundo, imaginando trayectorias.
- **1.5 Aprendizaje autosupervisado en una página.**
  - Aprender sin etiquetas, contrastivo frente a predictivo, y la idea de *EMA* y *stop-gradient*.
  - Se usa en §10 y §14.
- **1.6 Cómo leer un resultado.**
  - *Baseline*, ablación y *benchmark*.
  - Las métricas que aparecen después: tasa de éxito, puntaje de Atari normalizado por humanos, FID y uso del diccionario.

### Parte I. Cómo se discretiza (5,5 p.)

**§2. Formas de discretizar (3,5 p.)**
- **Discretizar valores:**
  - *One-hot* categórico con Gumbel-Softmax (recordatorio).
  - VQ: el vecino más cercano en un diccionario, explicado desde *k-means*.
  - FSQ: redondear cada coordenada a una grilla fija.
  - RVQ (cuantización residual): cuantizar el error de la cuantización anterior. Hace falta para los modelos de audio de §12.
  - LFQ/binario, en una nota.
- **Discretizar otros niveles:** la estructura (factores de OPF), el objetivo (*two-hot*, HL-Gauss) y la elección de predictor (*K* cabezas).
- **Fig. 6 — Geometría en 2D:** celdas de Voronoi de VQ, grilla de FSQ y vértices del símplex de *one-hot*.
- **Fig. 7 — Dónde se puede discretizar:** la tubería *encoder* → latente → predictor → objetivo/pérdida, marcando dónde discretiza cada paper.
- **Fig. 8 — *One-hot* frente a vector del diccionario:** la misma información con distinta geometría.

**§3. Cómo pasar el gradiente (2 p.)**
- STE, la pérdida de *commitment*, Gumbel con temperatura y el *rotation trick* como medida de lo que cuesta el STE.
- **Fig. 9 — STE:** se redondea hacia adelante y se copia el gradiente hacia atrás; dónde queda el sesgo.

### Parte II. Evidencia: dónde ayuda y dónde no (P2, 10 p.)

**§4. La línea de Dreamer (3 p.)**
- PlaNet y el RSSM: un estado determinista *h* más un estado estocástico *z*. Quitar cualquiera de los dos empeora.
- DreamerV2: *z* pasa de gaussiana a 32 categóricas de 32 clases, con una mejora en Atari.
  - Las hipótesis de los autores, sin confirmar.
  - *KL balancing*.
- DreamerV3: qué conservó (*unimix*, *two-hot*, *symlog*), cada cosa explicada.
- **Fig. 10 — RSSM** con *z* gaussiana frente a *z* categórica.

**§5. El experimento más limpio: Meyer, White y Machado, y DCWM (3 p.)**
- **Meyer et al.:**
  - Recuadro *Idea base* con el *gridworld* y el aprendizaje por refuerzo continuo (*continual RL*).
  - Diseño: se cambia solo el *encoder* y el modelo de transición queda fijo.
  - Las codificaciones comparadas, los resultados y la conclusión de los autores: **lo que importa es lo binario y esparso, no la discreción en sí**.
  - Además, la ventaja desaparece con un modelo del mundo grande.
- **DCWM:**
  - Recuadro *Idea base* con control continuo, planificación MPPI y TD-MPC2.
  - Códigos FSQ entrenados con entropía cruzada. Aquí los vectores del diccionario **superan** a *one-hot*.
- **Fig. 11 — Las codificaciones del mismo estado**, una al lado de la otra.
- **Fig. 12 — Esquema cualitativo:** la ventaja de lo discreto en función del tamaño del modelo del mundo.

**§6. Ramificaciones y robustez (2 p.)**
- Recuadro *Idea base*: MCTS y MuZero en media página.
- Stochastic MuZero: códigos de azar en 2048 y *backgammon*.
- MoP-JEPA: *K* cabezas que eligen un futuro en vez de promediarlos.
- Mao et al.: *tokens* VQ que hacen a un ViT más robusto.
- **Fig. 13 — Promediar o elegir:** el predictor MSE cae entre dos futuros; *K* cabezas eligen. Es la versión en espacio latente de la Fig. 4.

**§7. Dónde gana lo continuo (2 p.)**
- Recuadro *Idea base*: tokenizadores de imagen y pérdida de difusión.
- Tokenizador VQ frente a KL, y MAR (*tokens* continuos con difusión superan a los discretos, incluso con el mismo tokenizador).
- Garrido et al.: acciones latentes VQ frente a continuas con ruido o esparsidad en video "real". Incluye un recuadro sobre qué es un modelo de acciones latentes, con Genie como ejemplo.
- **Fig. 14 — MAR:** *token* discreto con entropía cruzada frente a *token* continuo con difusión.
- **Tabla-resumen de la Parte II:** caso / qué se discretiza / gana o pierde / pieza del paquete / grado de certeza.

### Parte III. ¿Es la discretización? (P3 y A1, 7 p.)

**§8. Desarmar el paquete (3,5 p.)**
- **Mecanismos y su predicción observable:**
  - capacidad: el efecto desaparece al igualar los bits;
  - multimodalidad: solo aparece en entornos estocásticos;
  - estabilidad: crece con el horizonte de predicción;
  - interferencia: aparece en aprendizaje continuo;
  - composición: aparece en combinaciones nunca vistas;
  - identidad exacta: aparece en búsqueda y reutilización.
- **Confusores:** la pérdida (Farebrother et al., 2024: clasificar ayuda incluso sin un latente discreto), la capacidad, el tamaño del modelo y el largo variable (LPN frente a NLI).
- Los experimentos publicados que ya separan piezas.
- **Fig. 15 — Matriz mecanismo × experimento,** con los huecos marcados.
- **Experimento propuesto:** un diseño factorial (discreto/continuo × capacidad igualada o libre × pérdida CE/MSE), probado en un entorno determinista y otro estocástico, con horizonte corto y largo. Incluye una tabla de lo que predice cada mecanismo y su aplicación a LPN frente a NLI.
- **Fig. 16 — El cubo factorial.**

**§9. ¿Hay un principio más allá de la discreción? (A1, 3,5 p.)**
- **Tabla central:** para cada beneficio documentado, *¿se reprodujo sin discretizar?*
  - multimodalidad → sí (MAR, mezclas de predictores);
  - capacidad → sí (acciones continuas con ruido en Garrido);
  - pérdida → sí (HL-Gauss);
  - esparsidad → parcialmente (Meyer);
  - estabilidad → abierto;
  - identidad exacta, enumeración y búsqueda → no hay sustituto continuo claro.
- **El principio candidato:** *invarianza dentro, margen entre, cortes que coinciden con el mundo*.
  - Recuadro *Idea base*: qué son invarianza y margen.
  - Ejemplos continuos que lo cumplen: el aprendizaje contrastivo, la ortogonalidad de OPF y el colapso neuronal.
- **Qué sería evidencia en contra:** un caso donde la discreción gane incluso con capacidad, pérdida, esparsidad y margen igualados.
- Grado de certeza: **conjetura respaldada**.
- **Fig. 17 — El principio en 2D:** los mismos datos con tres representaciones. Una continua sin margen, una continua con margen e invarianza, y una discreta. Las dos últimas resuelven la tarea.

### Parte IV. Colapso y errores acumulados (P1, P5 y N, 9 p.)

**§10. Qué es el colapso y por qué el gradiente lo encuentra (2,5 p.)**
- **Taxonomía:** colapso posterior, completo (JEPA/BYOL), dimensional, del diccionario y neuronal (el "bueno").
- **Hilo común:** el gradiente encuentra una solución barata en la que el latente deja de llevar información.
- **Por qué cae ahí:**
  - la solución trivial (predecir una constante da pérdida cero);
  - el sesgo hacia soluciones de bajo rango;
  - "el rico se hace más rico" en VQ.
- **Remedios continuos:** negativos contrastivos, EMA con *stop-gradient* y VICReg (varianza y covarianza, cada término explicado).
- **Fig. 18 — Cinco paneles** de colapso en 2D.

**§11. ¿Hace más difícil el colapso posterior lo discreto? (P1, 2 p.)**
- VQ-VAE no tiene colapso posterior porque la KL es constante (log *K*). Eso **no** se debe a la discreción, sino a que la posterior es determinista y la *prior* uniforme fija. Un VAE categórico **sí** puede colapsar.
- Por eso Dreamer necesita *free bits* y *KL balancing* (explicados).
- **"Partir bien separados":**
  - Recordatorio de los dos papers de la semana 4 en tres líneas cada uno: el colapso como transición de fase y el colapso como no identificabilidad.
  - Unos códigos separados hacen el latente más identificable y alejan el umbral de colapso. Pero, con un diccionario aprendido, la separación inicial no se conserva.
- **Fig. 19 — Identificabilidad:** una mezcla con componentes bien separados frente a una con componentes solapados, y qué puede "ignorar" el *decoder* en cada caso.

**§12. Colapso del diccionario (P5, 2 p.)**
- **Mecanismo:** los códigos muertos.
- **Tabla de modelos** donde está documentado: VQ-VAE/VQ-VAE-2, Jukebox, VQGAN, ViT-VQGAN, SoundStream/EnCodec, wav2vec 2.0, el dVAE de DALL·E, los prototipos de DINO/SwAV, el enrutamiento en *mixture of experts* y las cabezas de MoP-JEPA.
- **Remedios:** *k-means*, EMA, reinicio de códigos muertos, códigos de baja dimensión y normalizados, reparto equitativo (Sinkhorn o centrado), FSQ y el *rotation trick*.
- **Lo discreto no elimina el colapso, lo transforma:** de geométrico (puntos que se acercan, difícil de ver) pasa a colapso de asignación (pocos códigos usados, fácil de contar y de corregir).
- **Fig. 20 — Uso del diccionario:** "el rico se hace más rico" y la curva de uso de VQ frente a FSQ según el tamaño del diccionario.

**§13. ¿Errores acumulados = colapso? (N, 2,5 p.)**
- **Tres bucles donde la salida vuelve a entrar:**
  1. *Rollouts*: la predicción se usa como siguiente entrada.
  2. *Bootstrapping*: BYOL y JEPA usan su propia representación como objetivo.
  3. "Colapso de modelos" (Shumailov et al., 2024): entrenar con datos generados por el propio modelo pierde las colas de la distribución.
- **Vista de sistemas dinámicos:** aplicar la misma función muchas veces. Si contrae, aparece un punto fijo y el colapso; si expande, la divergencia. El MSE en *rollouts* largos tiende a la media, que es colapso por acumulación (lo que MoP-JEPA también llama *collapse*).
- **La discretización como función "escalera":**
  - contrae dentro de cada celda y conserva la separación entre celdas, como los atractores de Hopfield (explicados);
  - borra errores pequeños, pero un error grande hace saltar el estado a la celda equivocada.
- **Respuesta:** no son lo mismo, pero son dos desenlaces del mismo bucle.
- **Fig. 21 — Función iterada en 1D:** contractiva, expansiva y en escalera (cuantizada), con la trayectoria de un error en cada caso.

### Parte V. JEPA y discretización (P4, 4 p.)

**§14. ¿Discretiza alguien en JEPA? ¿Por qué?**
- Recordatorio de I-JEPA y JEPA-Anything, y por qué el colapso es su riesgo central (conecta con §10).
- **Inventario por *qué* se discretiza:**
  - el futuro: la *z* de LeCun (2022) y MoP-JEPA;
  - los *tokens*: Discrete-JEPA;
  - el latente sin reconstrucción: DCWM;
  - las acciones: Garrido, donde lo discreto falla;
  - la estructura: OPF;
  - la salida, de forma "blanda": prototipos de DINO e iBOT, y BEiT frente a I-JEPA.
- **Por qué discretizan:** multimodalidad, planificación, interfaz simbólica y control del colapso.
- **Hueco abierto:** no hay una comparación limpia entre un JEPA discreto y uno continuo en igualdad de condiciones.
- **Fig. 22 — I-JEPA frente a MoP-JEPA.**

### Parte VI. ¿Cuándo conviene discretizar? (A2, 4,5 p.)

**§15. Las características compartidas**
- **Criterios a favor**, cada uno con su evidencia, su grado de certeza y un **diagnóstico medible**:
  1. Huecos en los datos (agrupamientos), medidos con una estadística de brecha o la separabilidad de *k-means*.
  2. Futuro multimodal, medido con el número de modos de *p(x′|x)* (si se ajusta una mezcla).
  3. Uso recursivo o largo horizonte, medido con el horizonte del *rollout* y la sensibilidad del error.
  4. Poca capacidad para la complejidad del mundo, medida con la cantidad de bits necesarios frente a los disponibles.
  5. Necesidad de componer, buscar o reutilizar, que depende de la tarea.
  6. Mundo que cambia (aprendizaje continuo).
- **Criterios en contra:**
  - variable continua y rica, con precisión fina;
  - necesidad de interpolar;
  - optimización por gradiente en el latente en tiempo de prueba (el caso de LPN);
  - muchos bits necesarios, con riesgo de colapso del diccionario.
- **Fig. 23 — Árbol de decisión:** *¿discretizar, y qué?*
- **Fig. 24 — Mapa de dos ejes:** cuán agrupado está el mundo × cuánta precisión exige la tarea, con los casos del capítulo ubicados en él.
- Contraejemplos y límites del marco.

### Conclusiones (2,5 p.)
- Un recuadro por pregunta (P1 a P5, N, A1 y A2), con la respuesta corta y su grado de certeza.
- Vínculo con el proyecto: LPN y NLI, DreamerV3 y JEPA-Anything. Cierre con el .epub (§5): saber cuándo volver a discretizar.
- Tres o cuatro preguntas para la reunión.

### Apéndices (2,5 p.)
- Glosario ampliado, porque hay más conceptos base.
- Referencias con el formato `#notat[Fuente]`.

### Presupuesto

| Bloque | Págs. |
|---|---|
| Portada y guía | 1 |
| Introducción | 2,5 |
| Parte 0. Fundamentos | 5 |
| Parte I. Cómo se discretiza | 5,5 |
| Parte II. Evidencia | 10 |
| Parte III. Atribución | 7 |
| Parte IV. Colapso y errores | 9 |
| Parte V. JEPA | 4 |
| Parte VI. Cuándo discretizar | 4,5 |
| Conclusiones | 2,5 |
| Apéndices | 2,5 |
| **Total** | **≈ 53,5** |

---

## 4. Figuras y herramientas

Son unas 24 figuras.
- **Diagramas** (arquitecturas, tuberías, el paquete, la matriz, el cubo, el árbol de decisión): se dibujan en Typst con **CeTZ** y **fletcher**, sin LaTeX.
- **Figuras geométricas o numéricas** (Voronoi, grilla de FSQ, paneles de colapso, identificabilidad, función iterada, mapa de dos ejes): se generan con Python/matplotlib como SVG en `Week 10/figures/`, con un script `figures/generar.py` que las regenera.
- **Formato del documento:** `Week 10/main.typ`, con copias de `template.typ`, `config.typ`, `math_functions.typ` y `notalmar.typ` de `Notes/`, y un archivo por parte en `Week 10/chapters/`. La matemática es intuitiva, con las ecuaciones clave en recuadros.

## 5. División en dos tandas

| Tanda | Contenido | Págs. | Figuras |
|---|---|---|---|
| **1** | Infraestructura (template, script de figuras), portada, introducción, Partes 0, I y II, y §8 | ≈ 27 | 1–16 |
| **2** | §9, Partes IV, V y VI, conclusiones y apéndices | ≈ 26,5 | 17–24 |

- Las referencias y el glosario se van agregando en ambas tandas.
- La tanda 2 parte releyendo los recuadros *Qué nos llevamos* de la tanda 1, para mantener la coherencia.

## 6. Calendario de lectura sugerido

| Día | Contenido | Págs. |
|---|---|---|
| 1 | Guía, introducción y Parte 0 | ~8,5 |
| 2 | Parte I y §4 | ~8,5 |
| 3 | §5 a §8 | ~10,5 |
| 4 | §9 y Parte IV | ~12,5 |
| 5 | Partes V y VI, y conclusiones | ~11 |
