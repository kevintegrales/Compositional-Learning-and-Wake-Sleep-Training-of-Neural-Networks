#import "/math_functions.typ": *
#import "/bloques.typ": *

#frase[Hay varias formas de discretizar los valores de un latente (one-hot, VQ, FSQ, residual, binaria) y varios niveles en los que se puede discretizar (el latente, su estructura, el predictor, la pérdida, las acciones); todas pagan el mismo precio: el gradiente no atraviesa un redondeo.]

== Cuatro maneras de discretizar un vector

Partimos de un vector continuo $z_e in RR^d$, la salida del codificador. Discretizar es elegir una función $q$ que lo lleve a un conjunto finito de valores. La @fig:geometria muestra las tres geometrías principales en dos dimensiones.

#fig("f06_geometria.svg", flota: false)[Tres formas de partir el plano. En VQ, los centros (naranjos) se aprenden y cada uno se queda con la región de puntos más cercanos (celdas de Voronoi). En FSQ, la grilla es fija y no se aprende nada. En _one-hot_, los códigos son los vértices de un símplex: el modelo produce una distribución (un punto interior, en azul) y se queda con el vértice más probable.] <fig:geometria>

=== One-hot categórico

El codificador produce $K$ números (_logits_), los convierte en probabilidades con un _softmax_ y se queda con la categoría más probable, o muestrea una. El resultado se representa como un vector _one-hot_: ceros en todas partes y un 1 en la posición elegida. Para muestrear y aun así propagar gradientes se usa la Gumbel-Softmax #ct(<jang2017>), que vimos en los apuntes: se agrega ruido de Gumbel a los logits y se aplica un softmax con temperatura $tau$, que al bajar hace la muestra cada vez más parecida a un _one-hot_.

Una sola variable categórica de $K$ clases lleva poca información. Por eso DreamerV2 usa *32 variables categóricas de 32 clases cada una*: el latente es un vector binario de largo 1024 con exactamente 32 unos. Esa estructura, muchas categorías pequeñas en paralelo, aparece una y otra vez.

=== VQ: el vecino más cercano en un diccionario

#idea[k-means][
  Dado un conjunto de puntos, el algoritmo *k-means* busca $K$ centros que los representen bien. Alterna dos pasos: asignar cada punto a su centro más cercano y mover cada centro al promedio de sus puntos. La región de puntos que quedan más cerca de un centro que de cualquier otro se llama su *celda de Voronoi*.
]

La cuantización vectorial (VQ) del VQ-VAE #ct(<vandenoord2017>) es un k-means que se aprende junto con la red. Hay un *diccionario* (_codebook_) de $K$ vectores $e_1, dots, e_K in RR^d$, y cada salida del codificador se reemplaza por el más cercano:
$ z_q = e_k, quad k = op("arg min")_j norm(z_e - e_j). $
La pérdida tiene tres términos:
$ cal(L) = underbrace(- log p(x | z_q), "reconstruir") + underbrace(norm("sg"[z_e] - e_k)^2, "mover el código") + beta underbrace(norm(z_e - "sg"[e_k])^2, "compromiso"), $
donde $"sg"[dot]$ (_stop-gradient_) significa "trata esto como constante". El segundo término acerca el código elegido a la salida del codificador, como el paso de promedio de k-means. El tercero, la pérdida de *compromiso* (_commitment_), impide que el codificador se aleje indefinidamente de los códigos.

=== FSQ: redondear cada coordenada

FSQ (_finite scalar quantization_, #ctp(<mentzer2024>)) elimina el diccionario aprendido. Cada coordenada de $z_e$ se acota con una función como $tanh$ y se redondea a uno de $L_i$ niveles fijos:
$ hat(z)_i = "round"(floor(L_i slash 2) dot tanh(z_i)) $
(esta es la versión para $L_i$ impar; para $L_i$ par se agrega un pequeño desplazamiento). El redondeo se atraviesa con el estimador _straight-through_ que veremos en la @sec:ste. El conjunto de códigos es la grilla producto, con $K = product_i L_i$ elementos. Por ejemplo, con niveles $(8, 5, 5, 5)$ hay $8 dot 5 dot 5 dot 5 = 1000$ códigos. No hay términos de pérdida extra ni códigos que aprender: todos los códigos existen desde el principio y están igual de separados. Veremos en el capítulo VII que eso cambia radicalmente el problema del colapso del diccionario.

=== Cuantización residual y binaria

Dos variantes completan el panorama.
- *Cuantización residual (RVQ)*: se cuantiza $z$, se calcula el error que quedó (el residuo), se cuantiza ese residuo con un segundo diccionario, y así $M$ veces. El código final es la suma $e^((1))_(k_1) + dots + e^((M))_(k_M)$. Con $M$ diccionarios de $K$ entradas se obtienen $K^M$ combinaciones guardando solo $M K$ vectores. Es el estándar en compresión de audio, por ejemplo en SoundStream #ct(<zeghidour2021>).
- *Cuantización binaria (LFQ)*: cada coordenada se reemplaza por su signo, así que un vector de $d$ coordenadas da $2^d$ códigos sin diccionario #ct(<yu2024>). Es el caso extremo de FSQ, con dos niveles por coordenada.

== Otros niveles donde se puede discretizar

Hasta aquí discretizamos los *valores* del latente. Pero los papers discretizan cosas muy distintas, y conviene tenerlas separadas desde ya (@fig:donde).

#fig("f07_donde.svg")[Cinco lugares de un modelo del mundo donde se puede discretizar. Los números se usan en el resto del capítulo para ubicar cada paper.] <fig:donde>

- *La estructura del latente*. JEPA-Anything #ct(<cui2026>) no discretiza valores: parte el espacio de representación en $K$ factores que no se solapan, cada uno con su predictor. Lo que se vuelve discreto es *cuántas piezas hay y cuál es cuál*.
- *La elección del predictor*. Un modelo puede tener $K$ predictores continuos y elegir uno, como MoP-JEPA, o predecir un "código de azar" discreto que indica qué rama del futuro ocurrió, como Stochastic MuZero. El estado sigue siendo continuo; lo discreto es la decisión.
- *El objetivo de la pérdida*. Un número real $y$ (una recompensa, un valor) se puede predecir por regresión o representar como una distribución sobre intervalos y predecir por clasificación. La versión más simple es *two-hot*: si $y$ cae entre dos intervalos vecinos $b_i$ y $b_(i+1)$, se reparte el peso entre ambos en proporción a la cercanía, y la predicción es el promedio ponderado. DreamerV3 lo usa para recompensas y valores #ct(<hafner2025>); HL-Gauss #ct(<imani2018>) suaviza el objetivo con una gaussiana. #ctp(<farebrother2024>) muestran que entrenar funciones de valor por clasificación en vez de regresión mejora el aprendizaje por refuerzo profundo en muchos dominios. *El estado no se discretiza; solo la pérdida.*
- *Las acciones*. Los modelos que aprenden acciones a partir de videos sin etiquetar deben inventar un "vocabulario" de acciones. Pueden hacerlo discreto (Genie) o continuo (Garrido et al.). Lo vemos en el capítulo IV.

Esta lista ya responde parte de P4 (¿alguien discretiza en JEPA?): sí, pero casi nunca los valores del estado. Lo retomamos en el capítulo VIII.

== One-hot o vector: la misma información, distinta geometría

Supongamos que ya tenemos un código $k$. ¿Cómo se lo entregamos a la red siguiente? Hay dos opciones, y la @fig:onehot-vector muestra por qué no son equivalentes.

#fig("f08_onehot_vs_vector.svg")[Tres posiciones de un robot (izquierda, centro, derecha). Como _one-hot_, las tres quedan a la misma distancia ($sqrt(2)$) y el modelo no sabe que "centro" está entre las otras dos. Como vectores del diccionario, la cercanía conserva el orden.] <fig:onehot-vector>

- Como *one-hot*, todos los códigos quedan a la misma distancia y son ortogonales entre sí. No hay noción de parecido. Eso es malo si las categorías tienen un orden natural (posiciones, intensidades), pero tiene una ventaja poco obvia: como los vectores son ortogonales, ajustar lo que la red hace con el código 3 *no afecta* lo que hace con el código 7. Hay muy poca *interferencia* entre categorías.
- Como *vector del diccionario* $e_k$, los códigos parecidos quedan cerca. La red puede generalizar de un código a sus vecinos, pero también puede confundirlos, y los cambios en uno afectan a los cercanos.

Esta es la pieza #pieza(2). En el capítulo IV veremos dos papers que la miden directamente y llegan a conclusiones opuestas: en laberintos, gana _one-hot_; en control continuo, ganan los vectores. No hay contradicción. Gana la geometría que coincide con la estructura del problema.

#pensar[Las letras de un alfabeto, ¿se parecen más a un _one-hot_ o a vectores con distancia? ¿Y los colores?]

== El precio: cómo pasar el gradiente <sec:ste>

La función de redondeo es una escalera: es plana en casi todas partes y salta en los bordes. Su derivada es cero en casi todas partes. Si se aplica la regla de la cadena tal cual, el codificador no recibe ninguna señal de entrenamiento (@fig:ste).

#fig("f09_ste.svg")[El estimador _straight-through_ (STE). Hacia adelante se usa el valor redondeado (naranjo). Hacia atrás se finge que la función era la identidad (azul) y se copia el gradiente sin cambios.] <fig:ste>

La solución estándar es el *estimador straight-through* (STE, #ctp(<bengio2013>)), que en código se escribe con un truco:
$ z_q = z_e + "sg"[q(z_e) - z_e]. $
Hacia adelante, $z_q = q(z_e)$, el valor redondeado. Hacia atrás, el término con $"sg"$ no aporta gradiente, así que $partial z_q slash partial z_e = 1$: el gradiente pasa intacto. El problema es que ese gradiente es *el que habría tenido el punto sin redondear*, no el del código que realmente se usó. La diferencia entre ambos es un sesgo que nadie corrige.

¿Cuánto cuesta ese sesgo? El _rotation trick_ #ct(<fifty2025>) da una medida. En vez de copiar el gradiente, transforma $z_e$ en $e_k$ con una rotación y un cambio de escala que se tratan como constantes al derivar, de modo que el gradiente que recibe el codificador "sabe" en qué ángulo y a qué distancia estaba del código. Sin cambiar nada más, mejora la reconstrucción, el uso del diccionario y el error de cuantización en los 11 esquemas de entrenamiento de VQ-VAE que prueban. En el caso más llamativo, un VQGAN #ct(<esser2021>) con 16.384 códigos sobre ImageNet, el rFID baja de 5,0 a 1,1 y el uso del diccionario sube del 2 % al 27 % #est. (El documento del profesor reporta 1,6; la versión actual del paper dice 1,1.)

La Gumbel-Softmax enfrenta el mismo problema con otro compromiso. A temperatura alta, el gradiente es poco sesgado pero la muestra es poco discreta; a temperatura baja, la muestra es casi _one-hot_ pero el gradiente es muy ruidoso. Por eso NLI va bajando $tau$ durante el entrenamiento.

Este costo de optimización no es una pieza del paquete en el sentido de la @fig:paquete, porque no explica ninguna ventaja. Es el precio de entrada que todo método discreto paga, y la razón por la que muchos resultados discretos mejoran solo con cambiar el estimador.

#llevamos[
  - Las formas principales de discretizar valores son _one-hot_ (DreamerV2), VQ (VQ-VAE), FSQ (grilla fija), RVQ (residual) y LFQ (binaria). Difieren en si el diccionario se aprende y en su geometría.
  - Además de los valores, se puede discretizar la estructura, la elección de predictor, la pérdida o las acciones. Muchos "modelos discretos" solo discretizan una de estas cosas.
  - _One-hot_ y vector del diccionario llevan la misma información con distinta geometría: _one-hot_ evita la interferencia, el vector conserva la cercanía.
  - El gradiente no atraviesa un redondeo. El STE lo copia con sesgo, y ese sesgo cuesta: el _rotation trick_ baja el rFID de un VQGAN de 5,0 a 1,1 sin tocar nada más #est.
]
