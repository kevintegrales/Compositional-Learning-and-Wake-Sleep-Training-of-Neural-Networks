#import "/math_functions.typ": *
#import "/bloques.typ": *

#frase[Discretizar no es una causa sino un paquete; casi todo lo que ofrece se puede conseguir por otras vías, salvo la identidad exacta, y la ventaja aparece cuando los cortes coinciden con el mundo y el sistema reutiliza sus propias salidas.]

== Respuestas cortas

#respuesta("P1", [¿Es más difícil el colapso con lo discreto? ¿Ayuda partir con códigos separados?])[
  Más difícil, sí, pero no por la discreción. En VQ-VAE el KL es constante y no empuja al colapso posterior, gracias a la posterior determinista y la prior fija; un VAE categórico estocástico sí puede colapsar, y Dreamer necesita _free bits_. Los códigos separados ayudan por identificabilidad, si la separación se mantiene (grilla fija) y corresponde a diferencias reales en los datos. En general, lo discreto transforma el colapso en uno de asignación, que se puede contar y corregir. (Capítulo VII.) #est para el KL constante; #sug para el resto.
]

#respuesta("P2", [¿Qué evidencia hizo creer que discretizar ayuda? ¿Dónde gana lo continuo?])[
  Nació de DreamerV2 (mejor en 42 de 55 juegos con latentes categóricos), cuya ablación no separa causas. Los experimentos más limpios muestran ventajas condicionales: con poca capacidad y en mundos cambiantes (Meyer), con azar (Stochastic MuZero, MoP-JEPA) y con la geometría adecuada (DCWM). Lo continuo gana en generación de imágenes (MAR) y en acciones reales (Garrido). (Capítulo IV.) #est
]

#respuesta("P3", [¿Qué experimento comprueba o desmiente que la causa es la discretización?])[
  Uno que cambie una pieza a la vez. Proponemos un diseño factorial que cruza representación, capacidad igualada o libre, pérdida, entorno con o sin azar y horizonte. Aplicado a LPN y NLI, separa la discreción del largo variable. Cada pieza predice un patrón distinto de resultados. (Capítulo VI.)
]

#respuesta("P4", [¿Alguien discretiza en JEPA? ¿Por qué?])[
  Sí, pero casi nunca el estado completo. Se discretizan la elección entre futuros (MoP-JEPA), tokens semánticos (Discrete-JEPA), el latente sin reconstrucción (DCWM), las acciones (Garrido, donde pierde lo discreto), la estructura (JEPA-Anything) y la salida (DINO, SwAV). Las razones son futuros múltiples, limitar información, horizontes largos o símbolos, y controlar el colapso. (Capítulo VIII.)
]

#respuesta("P5", [¿Dónde ocurre el colapso del diccionario?])[
  Donde haya una elección entre $K$ opciones en la que el ganador recibe más señal: VQ-VAE, Jukebox, VQGAN (2 % de uso), ViT-VQGAN, SoundStream, wav2vec 2.0, SwAV y DINO, y las mezclas de expertos. FSQ lo evita por construcción. (Capítulo VII.) #est
]

#respuesta("N", [¿Errores acumulados = colapso?])[
  No son lo mismo, pero son los dos desenlaces de un mismo bucle de retroalimentación. Si el bucle expande, el error se acumula; si contrae, el sistema colapsa. El redondeo contrae dentro de cada celda y separa entre ellas, y sus fallas (error silencioso y colapso del diccionario) son las versiones discretas de las dos continuas. (Capítulos V y VII.) #conj
]

#respuesta("E", [¿Qué significa que la discretización permite seguir el error?])[
  Que los estados válidos son pocos y separados, y entonces el error se puede *detectar* (caer entre estados), *corregir* (volver al más cercano), *localizar* (el primer paso que no coincide exactamente) y *contar*. Solo conviene si el ruido por paso es claramente menor que la mitad de la separación; desde $sigma approx 0,29 d$, redondear empeora las cosas. (Capítulo V.)
]

#respuesta("A1", [¿Es la discreción o un principio más allá?])[
  Casi todos los beneficios se reprodujeron sin discretizar. El principio candidato es *invarianza dentro de cada clase, margen entre clases y cortes que coinciden con el mundo*; la discretización es su forma extrema. Lo único sin sustituto continuo claro es la identidad exacta: enumerar, reutilizar y componer. (Capítulo VI.) #conj
]

#respuesta("A2", [¿Qué comparten los espacios donde conviene discretizar?])[
  Estructura relevante discreta o casi discreta, y un sistema que reutiliza sus propias salidas. No conviene cuando lo que importa vive en diferencias finas y continuas. En el medio, los diseños híbridos son los que tienen más respaldo. (Capítulo IX.) #conj
]

== Qué significa para nuestro proyecto

- *LPN y NLI.* El salto de LPN a NLI cambia al menos tres cosas: la discreción, el largo variable y el intérprete secuencial. Según este capítulo, la pieza que mejor explicaría una ventaja en *composición* es la identidad exacta #pieza(6), justo la que ningún experimento publicado aísla. Las variantes del capítulo VI (LPN con largo variable, NLI con tokens continuos de capacidad igualada) son un experimento factible y nuevo.
- *DreamerV3.* Su diseño (memoria continua, elección categórica, objetivos _two-hot_, free bits) es el híbrido con más respaldo. Combina las piezas #pieza(4) y #pieza(3) sin discretizar lo que necesita precisión.
- *JEPA-Anything.* La ortogonalidad de sus factores es una vía continua para la estabilidad (#pieza(5)) y el margen entre factores. Pero fija $K$ y no se pregunta cuándo crear un factor nuevo: es una discretización de la estructura con cortes que no se mueven.
- *La segunda pregunta del .epub.* El .epub cerraba con la idea de que la ventaja humana quizás no está en discretizar, sino en *saber cuándo volver a discretizar*. Este capítulo le da una forma más concreta. Si el beneficio viene de que los cortes coincidan con el mundo, entonces mover los cortes cuando dejan de coincidir es la habilidad central. Esa es la pregunta sobre refinar o ampliar.

== Preguntas para la reunión

+ ¿Vale la pena montar el experimento factorial sobre LPN y NLI, o una versión reducida (solo NLI con tokens continuos de capacidad igualada)?
+ El colapso neuronal es una discretización que *emerge* del gradiente. ¿Es un buen punto de entrada para la segunda pregunta (de dónde salen las reglas)?
+ ¿Cómo se podría aislar la identidad exacta (pieza #pieza(6)) sin cambiar a la vez la capacidad ni la arquitectura?
+ ¿Discrete-JEPA, o su repetición con condiciones igualadas, como próxima lectura o experimento?
