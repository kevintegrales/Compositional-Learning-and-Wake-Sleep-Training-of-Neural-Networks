// Funciones
#import "/math_functions.typ": *
#import "/notalmar.typ": *
#include "/notalmar.typ"

== Complejidad de Kolmogorov
<kolmogorov>

Buscamos describir un objeto en una string binaria. Un objeto podría tener muchas descripciones, pero una descripción sólo puede corresponder a un único objeto. Además, podríamos tomar el largo de la descripción más corta y considerarla como la _complejidad_ del objeto. 

Pero en ese caso podríamos caer en una trampa descrita en la *Richard-Berry paradox*, donde definimos un número natural como "el menor natural que no puede ser descrito en menos de veinte palabras". Si ese número existe, lo acabamos de describir en 13 palabras, contradiciendo la frase que lo define. Si tal número no existe, todos los números pueden describirse en menos de veinte palabras. Este resultado aparece por la _ambigüedad_ sistemática de la palabra "descrito" (o, en otros casos, de "definible"). Resolver este tipo de paradojas requiere indicar dónde exactamente nuestro lenguaje "anduvo mal" e indicar restricciones para evitarlas.

Asuma que cada descripción describe a lo sumo un objeto. Así, existe un *método de especificación* $D: Y->X$ que asocia, con una descripción $y in Y$, a lo sumo un objeto $x in X$. Además, para que las descripciones sean útiles, las asumiremos finitas, así que existe una cantidad numerable de descripciones y, por tanto, a lo sumo una cantidad numerable de objetos descriptibles.

Para medir la complejidad de un objeto $x in X$, podríamos escoger aquel que tenga menor costo de transmisión, esto es, el menor largo de $y$ tal que $D(y) = x$. Sin embargo, la complejidad de un objeto dependería directamente de $D$. Es por esto que, para poder comparar la complejidad de objetos, haremos que la complejidad de $x$ dependa únicamente de él. 

Además, para que las especificaciones $D$ sean útiles, será necesario que $D(y)$ sea ejecutable en una *manera efectiva*, es decir, que al menos puede ser ejecutable por humanos o por máquinas.

Asumiremos como resultado que el conjunto de funciones parciales computables contiene una función óptima que minimiza el largo de descripción de cualquier otra función. Denotaremos dicha función con $D_0$. Y para cualquier otra función computable $D$, para cualquier objeto $x$, existe una descripción de $x$ bajo $D_0$ que es más corta ---hasta una constante aditiva independiente de $x$--- que cualquier otra descripción de $x$ bajo $D$.

Identificaremos el largo de descripción de $x$ con respecto a una función de especificación fijada $D_0$ como la *complejidad algorítmica* de $x$. La optimalidad de $D_0$ en este sentido quiere decir que la complejidad de un objeto es *invariante* (hasta una constante aditiva independiente de $x$) bajo la transición de un método de especificación a otro. Este resultado se conoce como 


#teot[de Invarianza][
  Existe una máquina de Turing universal (o función parcial computable universal) $U$ tal que, para cualquier otra máquina de Turing (o función computable) $F$, existe una constante $c_F$ que depende exclusivamente de $F$ y de la elección de $U$, de modo que para cualquier cadena $x$,
  $
    C_U (x) <= C_F (x) + c_F,
  $
  donde
  - $C_M (x) = min{l(y): D(y) = x}$ denota la complejidad de Kolmogorov en la máquina o función $D: Y -> X$,
  - $y$ es la descripción,
  - $l(y)$ es la longitud de la descripción.
]

De esta manera, la complejidad de un objeto es un atributo objetivo e inherente a él.

==== Notación

#let phia = $phi.alt$

Si $phia$ es una *función parcial* de $A$ a $B$, entonces para cada $x in A$, o bien $phia(x) in B$, o bien $phia(x)$ está indefinida. Si $phia(x) < infinity$, diremos que $phia$ *converge*. Por el contrario, si $phia(x) = infinity$, diremos que $phia$ *diverge* o que está *indefinida* en $x$. Si $phia$ converge para cada $x in A$, entonces diremos que es una *función total*, de otro modo diremos que es una *función estrictamente parcial*. Si cada miembro de $B$ está también en el rango de $phia$, entonces diremos que $phia$ *mapea sobre (_onto_) $B$*, si no *mapea a (_into_) $B$*. Además, si para cada $x != y$, $phia$ converge y $phia(x) != phia(y)$, entonces llamamos a $phi$ un *mapeo uno-a-uno*, de otro modo la llamamos un *mapeo muchos-a-uno*.

Tendremos los siguientes cuantificadores:
- $exists$: Existe al menos un elemento.
- $forall$: Para todo elemento.
- $exists^infinity$: Existen infinitos elementos.
- $forall^infinity$: Para todo elemento, excepto para finitos.
$
    not exists^infinity x. phia(x) <==> forall^infinity x.not phia(x).  
$

Nota que podemos hacer el símil entre $exists^infinity$ con _infinitely often_ y entre $forall^infinity$ con _almost always_.

==== Strings Binarias

Tendremos nuestro conjunto no vacío $BBB$ de *elementos básicos*. Usualmente, $BBB = {0,1}$. El conjunto de todas las strings finitas sobre $BBB$ es
$
  BBB^* := {epsilon.alt, 0, 1,00,01,10,11,...},
$
donde $epsilon.alt$ denota la *string vacía*. 

La *concatenación* es una operación binaria de elementos en $BBB^*$ que toma dos elementos $x, y in BBB^*$ y los lleva a $x y in BBB^*$. Algunas propiedades son:
1. $BBB^*$ es cerrada bajo concatenación.
2. La concatenación es asociativa.
3. La concatenación tiene un elemento _unitario_ $epsilon.alt$: $ epsilon.alt x = x epsilon.alt = x. $

Definiremos una *correspondencia* esencial entre los naturales $NN$ y las strings binarias finitas $BBB^*$. Es de notar que no usaremos la representación binaria estándar, pues tiene la desventaja de que, o bien hay strings que no representan números naturales, o bien hay números naturales con múltiples representaciones. Por ejemplo, es bastante conocido que los ceros como prefijos no tienen significado en este sistema: ¡$010, 10$ y $0010$ representan al mismo número! Por ello, definimos un mapeo uno-a-uno de $BBB^*$ sobre $NN$ asociando cada string con su índice en el *orden lexicográfico por longitud creciente (_shortlex_)*
$
\
  epsilon.alt &<--> 0 \
  0 &<--> 1 \
  1 &<--> 2 \
  00 &<--> 3 \
  01 &<--> 4 \
  10 &<--> 5 \
  11 &<--> 6 \
  & space space dots.v
$ 
De esta manera, representamos a
$
  x = 2^(n+1) - 1 + sum_(i=0)^n a_i 2^i
$
como $a_n dots.c space a_1 a_0$. Además, consideraremos al string en $BBB^*$ y al número con que se corresponde como exactamente el mismo objeto.

Para una string $x$, $x_i$ denota el $i$-ésimo bit y $x_(i:j)$ denota el segmento $x_i x_(i+1) dots.c x_j$ de largo $j - i + 1$. El *reverso* lo denotaremos por $x^R$. El *largo* $l(x)$ de la string finita lo definimos como el número de bits que contiene. En particular, $l(epsilon.alt) = 0$, $l(x^R) = l(x)$ y $l(x y) = l(x) + l(y).$


Sea $D$ una función $D: {0,1}^* -> NN$. Diremos que el dominio de $D$ serán las *palabras código* (_code words_) y su rango el conjunto de *palabras fuente* (_source words_). De esta manera, $D(y) = x$ se interpreta como que $y$ es una code word de la source word $x$ y $D$ es una *función de decodificación*. Al revés, podemos definir una *sustitución de codificación* $E = D^(-1)$ (que no necesariamente una función).

Diremos que una string $x$ es prefijo de $z$ si es que existe una string $y$ tal que $z = x y$. Diremos que $A subset {0,1}^*$ es *libre de prefijos* (_prefix-free_) si ningún elemento de $A$ es prefijo de otro elemento en $A$. 

#ex[
  Si $A = {101, 010, 11,00}$ es un conjunto libre de prefijos.
]

Una función $D : {0,1}^* -> NN$ define un *código prefijo* (_prefix-code_) si su dominio es libre de prefijos. 

#ex[
  Un código prefijo muy utilizado es aquel obtenido al reservar el cero como punto de detenimiento y codificando $x in NN$ como $1^x 0$. Así, $D: A -> NN$ tiene
  $
    A = {0,10,110,1110,11110,...}
  $
  que claramente es libre de prefijos. Además, podemos prefijar un objeto con su largo e iterar la idea para obtener códigos incluso más cortos. Para esto se define
  $
    E_i (x) = cases(
      1^x 0 qquad &"para" i = 0,
      E_(i-1) (l(x)) x qquad &"para" i >= 1.
    )
  $
  Así, $E_0 (x) = 1^x 0$ (que tiene largo $x + 1$), y $E_1 (x) = 1^(l(x)) 0 x$ (que tiene largo $2 l(x) + 1$). [Recuerde que $l(x) approx ln x$, así que asintóticamente los $E_i$ tienen largo más corto que los anteriores.] En particular, $E_1$ tiene una notación especial:
  $
    overline(x) &:= E_1 (x) =  1^(l(x)) 0 x \
    l(overline(x)) &= 2 l(x) + 1.
  $
  Llamamos a $overline(x)$ la versión *auto-limitante* (_self-limiting_) de la string $x$.
]



==== Computabilidad y Máquinas de Turing

Estudiaremos que todo lo que puede ser razonablemente considerado computable por un _computador humano_ (un calculista) usando un procedimiento fijo puede ser computado por una máquina hipotética, una máquina de Turing. Y, como Turing indicó, cualquier proceso que puede ser naturalmente llamado _procedimiento efectivo_ es realizado por una máquina de Turing. Esto último se conoce como la *tesis de Turing*. De hecho, todos los intentos de dar una precisa aunque intuitiva definición de la noción de lo que es un "procedimiento efectivo" (en el sentido más amplio) han resultado ser equivalentes. En este sentido, la *tesis de Church* establece que existe una noción de lo que es la _computabilidad efectiva_ independiente de la formalización particular.

Una *máquina de Turing* consiste en un programa finito, llamado *control finito*, capaz de manipular una *cinta*, esto es, una lista lineal de *celdas*, usando un puntero de un acceso, llamado *cabeza*. La cinta tiene dos lados, derecha e izquierda. Además, el control finito tiene un *conjunto de estados* $Q$ finito y cada celda puede contener un $0$, un $1$ y un *blanco* $B$. El tiempo se asume discreto, partiendo con la máquina desde el instante cero. En cualquier instante la cabeza está posicionada sobre una celda y la *escanea*. En el instante cero la cabeza está sobre una *celda inicial* y el control finito está en un estado distinguido $q_0 in Q$ y, además, todas las celdas contienen 0's, excepto por una secuencia finita y contigua de celdas, que se extienden desde la celda inicial, las cuales contienen una secuencia binaria ingresada, llamada *input*.

El aparato puede realizar las siguientes operaciones (sólo una por instante):
1. Escribir un elemento de $A = {0, 1, B}$ en la celda que escanea.
2. Mover la cabeza una celda a la derecha o a la izquierda.  
Al finalizar cada paso, el control finito toma un estado de $Q$. Además, el aparato está construido de modo que se comporte de acuerdo a una *lista de reglas* finita, las cuales indican, según el símbolo leído y el estado actual, la operación a realizar _en el siguiente instante_ y el estado en que ponerse al terminar la siguiente operación. Cada regla tiene la forma
$
  (p,s,a,q),
$
donde:
- $p$ es el estado actual.
- $s$ es el símbolo siendo escaneado.
- $a$ es la acción a ejecutar en el siguiente paso, pudiendo escoger de $S = {0,1,B, L, R}$ (esto es, la máquina o se mueve o escribe, pero no las dos al mismo tiempo).
- $q$ es el estado a tomar al finalizar este instante.

La máquina de Turing es determinista: no pueden haber dos reglas que compartan los mismos dos elementos (es decir, $p, s$). Además, puede ocurrir que un estado $p$ y un símbolo $s$ no tengan una regla definida. En ese caso, el aparato *para* (_halts_). De esta manera, podemos definir la máquina de Turing mediante un mapeo (o bien, una función parcial) de $Q times A$ hacia $S times Q$.

Podemos asociar una función parcial con cada máquina de Turing:
- El input $x = x_1...x_n$ a la máquina se representa mediante una $n$-tupla $(x_1,...,x_n)$, donde cada $x_i in {0,1}$. (En caso de que $x in NN$ sea un número, primero se transforma mediante _shortlex_.)
- Se escribe el input en la cinta hacia la derecha partiendo desde la celda inicial.
- El instante en que la máquina para, el output corresponde a la secuencia de símbolos que queda escrita en la cinta. (En caso de que la máquina nunca se detenga, no se produce ninguna salida.)

Así, se ha asociado una máquina de Turing con una función parcial $f$ en el sentido de que $f(x) = y$ siempre que se ingresa $x$ a la máquina y esta tiene como output $y$ y, cuando la máquina no se detiene, entonces $f(x)$ es indefinido. Por tanto, podemos decir que _toda máquina de Turing computa (o induce) una función parcial_. 

Llamaremos a aquella $f$ *función parcial computable*. Si la máquina se detiene para todos los inputs posibles, entonces diremos que $f$ es *total y computable*, o simplemente *computable*.

#deft[Tesis de Church][
  La clase de funciones numéricas algorítmicamente computables (en el sentido intuitivo) coincide con la clase de funciones parcialmente computables.
]

La tesis de Church se piensa intuitivamente como que "dada una descripción de un procedimiento en términos de un conjunto informal de instrucciones, nosotros podemos derivar un procedimiento formal en términos de máquinas de Turing".



#deft[Máquina de Turing Universal][
  Una  máquina de Turing $U$ es *universal* si puede imitar el comportamiento de cualquier otra máquina de Turing $T$.
]

Está demostrado que dichas máquinas existen (de hecho, son infinitas) y que pueden ser efectivamente construidas. Bastaría con una descripción del programa finito de $T$ y el input a ingresar a ella, para ingresarlos en la cinta inicial de $U$. Para ejecutar las aacciones que haría $T$, $U$ iría leyendo el programa de $T$ y las ejecutaría en su propia cinta. 



Existe un emparejamiento (efectivo computable) uno-a-uno entre los naturales y las máquinas de Turing llamado *enumeración efectiva*, $T_1, T_2, ...$. De hecho, esta enumeración (efectiva) permite crear una enumeración efectiva de funciones parciales computables (¿Por qué?) $phia_1, phia_2,...$.

Existe una diferencia entre el _nombre_ para $psi$ y una _función_ $psi$. Un nombre para $psi$ puede ser un algoritmo que la calcule con una máquina  de Turing, o puede ser un *índice* $i in NN$ tal que $psi$ es igual a $phia_i$ es la enumeración efectiva. [Cada función parcial computable $psi$ ocurre muchas veces dada una enumeración efectiva, pues podemos construir distintas máquinas de Turing que para el mismo input produzcan el mismo output.]

#def[
  La función parcial computable $nu^((2)) (i, x)$ computada por la máquina universal $U$ se llama la *función parcial universal computable*.
]

Un conjunto $A subset.eq NN$ es *computablemente enumerable* (c.e.) si es vacío o es el rango de alguna función $f$ total computable. En ese caso, diremos que $f$ *enumera* a $A$. Diremos además que un conjunto $B subset.eq NN$ es *co-computablemente enumerable* (co-c.e.) si su complemento $A = overline(B)$ es c.e.. Un conjunto $C subset.eq NN$ es *computable* ssi su función característica es total computable, esto es, $f = bb(1)_A$ es total computable. Así que todos los conjuntos computables son c.e. y co-c.e..




== Minimum Description Length (MDL)


_El material de este capítulo está inspirado en las notas Aprendizaje Composicional y Generalización OOD de MAT2320 que me compartió el profesor Petrache_.

A continuación, profundizamos de una manera más rigurosa la @kolmogorov y presentamos el Minimum Description Length (MDL).

Sea $cal(U)$ una máquina de Turing universal fija. 
#deft[Complejidad de Kolmogorov][
  Sean $x,y in {0,1}^*$ cadenas binarias. Luego, la *complejidad de Kolmogorov de $x$ dado $y$* se define como
  $
    K(x|y) := min{|p|: cal(U)(p,y) = x},
  $
  donde $p$ es un programa (finito, como siempre) que produce $x$ a partir de $y$ en $cal(U)$ y $abs(p)$ denota su longitud en bits.

  La *complejidad incondicional de $x$* es
  $
    K(x) := K(x|epsilon),
  $
  donde $epsilon$ es la cadena vacía en ${0,1}^*$.
]

Intuitivamente, $K(x|y)$ mide cuánta información de $x$ falta dado que se conoce $y$, mientras que $K(x)$ mide el tamaño de la descripción más corta de $x$ (si no conozco nada de $x$...).

El teorema de invarianza indica que la complejidad de un $x$ _esencialmente_ no depende la elección de $cal(U)$.

#teot[Teorema de Invarianza][
  Para cualesquiera dos máquinas de Turing universales $cal(U)$ y $cal(V)$, existe una constante $c_(cal(U), cal(V)) >= 0$ tal que
  $
    abs(K_(cal(U)) (x) - K_cal(V) (x)) <= c_(cal(U), cal(V)), qquad forall x in {0,1}^*.
  $ 
]

Otro teorema interesante.
#teo[La función $x |-> K(x)$ es no computable.]

Ahora presentamos una aplicación práctica de la complejidad de Kolmogorov.

#deft[Minimum Description Length (MDL)][
  Sea $cal(H)$ una clase de hipótesis y $D$ un conjunto de datos. El *principio de Longitud Mínima de Descripción* indica que se seleccione la hipótesis
  $
    h^* = arg min_(h in cal(H)) (L(h) + L(D|h)),
  $
  donde $L(h)$ es la longitud en bits de la descripción de $h$ y $L(D|h)$ es la longitud de la descripción de $D$ dado $h$.
]




== DreamCoder
<dream_coder>
#notat[Fuente][
  Contenido estudiado de _"DreamCoder: Bootstrapping Inductive Program Synthesis with Wake-Sleep Library Learning"_ de K. Ellis et al. (2021).
  #fuente_link("https://arxiv.org/abs/2006.08381", "arXiv:2006.08381")
]

#nota[No confundir con *@dreamer*.]


DreamCoder es un modelo de síntesis de programas. Es decir, a partir de un conjunto de pares input-output, se busca generar un programa que permita realizar esos mismos cálculos y luego generalizar. El algoritmo, a grandes rasgos, itera creando código y luego factorizando el código en funciones que busca reutilizar.


=== Síntesis Inductiva de Programas

Dado un conjunto de tareas $cal(X) = {x_1,...,x_n}$, cada una especificada por un pequeño número de pares input-output de ejemplo, buscamos encontrar programas ${rho.alt_x_i}$ que satisfacen todos los ejemplos para cada tarea, respectivamente. 

El problema tiene tres retos esenciales:
1. Explosión combinatorial: el número de programas válidos sintácticamente crece exponencialmente.
2. Generalización, no interpolación: se busca que el programa sea correcto incluso con inputs fuera del training set.
3. Interpretabilidad y reuso: idealmente el programa debe ser interpretable por un humano y deseablemente reutilizable a futuro.

==== Fundación en el MDL

#def[
  Para una librería $L$ y programas ${rho.alt_i}$ que resuelven tareas en  $cal(X)$, el *joint description length* es
  $
    "DL"(L, {rho.alt}, cal(X)) := abs(L) + sum_(x in cal(X)) abs(rho.alt_x)_L.
  $
]

El objetivo MDL aquí es encontrar $(L^*, {rho.alt_x^*})$ que minimiza el joint description length sujeto a que $rho.alt_x$ resuelve $x in cal(X)$.

Después de un poco de desarrollo, se obtiene que el objetivo de DreamCoder corresponde justamente al del MDL. Sin embargo, el objetivo obtenido es intratable por la explosión combinatorial. Para ello, se introduce el *amortised recognition model* $Q_theta (rho.alt|x)$, una red neuronal que permite aproximar una distribución que era intratable. El rol de $Q_theta$ es guiar la búsqueda de programas, prediciendo qué programas son más probables de resolver las tareas dadas.




==== Domain-Specific Languages (DSL)
Los Domain-Specific Languages permiten resolver el problema de la explosión combinatorial. Sin embargo, hasta antes de esta investigación, estos se daban desde un inicio. En este paper es el mismo modelo el que crea su DSL.


=== Wake-Sleep Algorithm

DreamCoder realiza inferencia bayesiana aproximada por medio un proceso iterativo que tiene tres fases:
- *Wake:* actualiza ${rho.alt_x}$ manteniendo $L$ y $theta$ fijas. 
  Busca programas usando $Q_theta$ y $L$.
- *Sleep (Abstraction):* actualiza $L$, manteniendo ${rho.alt_x}$ y $theta$ fijas.
  Comprime los programas en $L$.
- *Sleep (Dreaming):* actualiza $theta$ manteniendo ${rho.alt_x}$ y $L$ fijas.
  Entrena $Q_theta$ en replays y fantasías.

==== Wake phase
Se busca para cada tarea $x in cal(X)$ el programa con mayor puntuación, dada por el modelo de reconocimiento $Q_theta$ y la prior $P$:
$
  "score"(rho.alt, x) = log Q_theta (rho.alt|x) + underbrace(log P(rho.alt, L), -abs(rho.alt)_L).
$
La implementación usa beam-first-search. Los programas que no son correctos para todos los ejemplos de la tarea son descartados. Además, se tiene un presupuesto de tiempo de entrenamiento. Pasado el presupuesto, se detiene la búsqueda. (Si no se encontró un programa, la tarea simplemente permanece no resuelta.)

==== Sleep Abstraction Phase

Se busca una librería $L^*$ que introduce nuevo vocabulario sólo si extender $L^*$ tiene mayor beneficio en compresión que el perjuicio en longitud. Para esto se hace
$
  L^* = arg max_L [log P(L) + sum_(x in cal(X)) log P(rho.alt_x^*|L)], 
$
donde $log P(L) = -beta "size"(L)$ es un regularizador que permite aplicar el MDL.

==== Sleep Dreaming Phase

Aquí se mejora la predicción de $Q_theta$ sobre $P(rho.alt|x,L)$. El objetivo de entrenamiento es
$
  theta^* = arg max_theta E_((rho.alt, x) ~ P_"train") [log Q_theta (rho.alt|x)],
$
donde $P_"train"$ es una mezcla de:
- Replays: pares $(x, rho.alt_x^*)$. Permiten que $Q_theta$ no olvide cómo resolver tareas que ya ha resuelto.
- Fantasías: pares $(x, rho.alt)$, donde $rho.alt ~ P(rho.alt|L)$ y $x$ se induce ejecutando $rho.alt$ en inputs random. Ellas permiten tener un suministro ilimitado de datos sintéticos para el entrenamiento y permiten que $Q_theta$ generalice más allá del pequeño training set. 

#notat[Conexión con DreamerV3][
  El rol de las fantasías es similar al del modelo de mundo que usas DreamerV3. Ambos permiten experimentar ilimitadamente y ensayar con datos que no ha obtenido de la fuente original, basándose en la experiencia pasada.
]

== Flat Minima
#notat[Fuente][
  Contenido estudiado de _"Flat Minima"_ de S. Hochreiter y J. Schmidhuber (1997).
  #fuente_link("https://doi.org/10.1162/neco.1997.9.1.1", "DOI:10.1162/neco.1997.9.1.1")
]

TODO

En el paper se presenta un modelo que, además de hacer _backpropagation_ para encontrar pesos de una red neuronal, busca mínimos planos que, apoyándose del principio MDL (a partir de robustez), generalicen mejor.

=== Tarea y Arquitectura

Queremos aproximar una función desconocida $f: X->Y$, donde $X subset RR^N$ y $Y subset RR^K$. Suponga que tenemos un conjunto de datos $D subset X times Y$ que se divide en los datos de entrenamiento $D_0$ y en los datos de test $D without D_0$. Para aproximar $f$, ajustaremos los pesos $w in W subset RR^L$ de la red
$
  "net"(w): x |-> o(w; x),
$
donde $o(w;x) = (o^1 (w; x), ..., o^K (w; x)) in RR^K$ es la salida de la red con pesos $w$ e input $x$ (es decir, $"net"(w) (x) = o(w;x)$).

En el espacio de pesos $W subset RR^L$ definimos, dado un peso $w$, la *caja* $M_w$ como un hipercuboide de $L$ dimensiones centrado en $w$. Además, definimos el *error tolerable* $E_"tol" > 0$ como el máximo error que aceptaremos respecto a parte de la función de pérdida. Así, un peso $w$ será un *mínimo aceptable* si  se satisface que
$
  E("net"(w), D_0) := sum_((x_p, y_p) in D_0) norm(y_p - o(w, x_p))^2 <= E_"tol",
$
donde $E(dot, dot)$ es el error cuadrático sumado. (En caso de que la desigualdad sea en sentido contrario hablamos de *underfitting*.) Diremos que un *mínimo plano* es una región conexa de mínimos aceptables. El objetivo del algoritmo será encontrar mínimos aceptables con cajas de gran volumen.


=== Algoritmo FMS

Se presenta el algoritmo *Flat Minimum Search* (FMS). Este algoritmo no sólo mimiza $E("net"(w), D_0)$ respecto a $w$, sino que considera
$
  E(w, D_0) := E("net"(w), D_0) + lambda B(w, X_0),
$
donde:
- $X_0 = {x_p: (x_p, y_p) in D_0}$, 
- $lambda >= 0$ es un hiperparámetro que controla la importancia que se da a que el mínimo sea plano, y
- $B(w, X_0)$ es un término que permite aumentar el volumen de la caja $M_w$ (minimizarlo maximiza el volumen de ella), donde $ B(w, X_0) = sum_(x_p in X_0) B(w, x_p) $ y $
    B(w, x_p) = 1/2 (
      - L log epsilon
      + sum_(i, j) log sum_(k=1)^K ((partial o^k (w, x_p)) / (partial w_(i j)))^2
      + L log sum_(k=1)^K (
          sum_(i, j)
          abs((partial o^k (w, x_p)) / (partial w_(i j)))
          / sqrt(sum_(k'=1)^K ((partial o^(k') (w, x_p)) / (partial w_(i j)))^2)
        )^2
    ).
  $

En el siguiente algoritmo, considere 
$
  E("net"(w), D_0) = sum_(p) E_p (w), qquad "donde" qquad E_p (w) = norm(y_p - o(w;x_p))^2.
$

#algot[FMS][
  Defina un criterio de parada (e.g. un número determinado de épocas, como 400.000). Luego, itere:

  -  Para cada ejemplo $(x_p, y_p) in D_0$:
    1. *Pasada forward:* se calcula $o(w; x_p)$.
    2. *Pasada backward:* se hace backpropagation normal, lo que permite obtener $
      nabla E_p qquad "y" qquad (partial o^k) / (partial w_(i j)) (w, x_p) qquad (forall k, w_(i j)).
    $
    3. *Gradiente de $B$.* Se necesitan las segundas derivadas de $o^k$, $ (partial B)/(partial w_(u v)) (w, x_p)  qquad "y" qquad (partial^2 o^k) / (partial w_(i j) partial w_(u v)) (w, x_p) $ y se construye $nabla B (w, x_p).$
    4. Se actualizan los pesos $ w <- w - alpha nabla E_p - lambda dot "escala" dot nabla B, $ donde el factor $"escala"$ fuerza que $nabla B$ y $nabla E_p$ tengan la misma norma.
  - Actualice $lambda$ según la regla de Weigend et al. (1991) (más grande si el error está bajo $E_"tol"$ o si bajó respecto a la época anterior y más pequeño si el error empeora). 
]

#nota[
  En el paper, a pesar de que pareciera necesitarse calcular la hessiana (segundas derivadas) de $o^k$, se usa el truco de Pearlmutter para sólo calcular un producto matriz-vector que reduce el costo computacional de $cal(O)(L^2)$ a $cal(O)(L)$.
]

=== Notas Adicionales
==== ¿Por qué los mínimos planos generalizan?
Cuando los pesos admiten poca precisión, se describen con pocos bits (esto es, bajo valor de $B$). Eso define una red "simple" y, por el principio MDL, un bajo overfitting esperado.

> (?) Desde la vista bayesiana, los mínimos planos son máximos "gordos" de la posterior.


==== Las dos condiciones de planitud
Se definen dos condiciones para la planitud y que definen la fórmula de $B$:

- *Condición 1 (robustez a las perturbaciones):* se define una medida $E D(w; tilde(w))$ que mide cupandi tambia la salida bajo perturbaciones dentro de la caja $M_w$. Se exige que esta perturbación sea como máximo $epsilon$.
- *Condición 2 (igual planitud en todas las direcciones):*  se busca que la planitud (el cambio de la salida ante perturbaciones) sea igual para todos los pesos.


==== Diferencia con Backpropagation




