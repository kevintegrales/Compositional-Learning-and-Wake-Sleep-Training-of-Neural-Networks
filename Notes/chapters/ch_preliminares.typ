// Funciones
#import "/math_functions.typ": *
#import "/notalmar.typ": *
#include "/notalmar.typ"


== Reinforcement Learning
Esta sección está basada en los capítulos 1 y 3 del libro  _Reinforcement Learning: An Introduction_ de Richard S. Sutton  y  Andrew G. Barto (2014-2015).

=== Una Introducción al Reinforcement Learning
El *Reinforcement Learning* (RL) es un acercamiento _computacional_ al _aprendizaje por interacción_, el cual pareciera subyacer a cualquier teoría del aprendizaje e inteligencia. La guía de este tipo de aprendizaje son las metas o retornos que, por lo general, son a largo plazo.

Por un lado, es diferente al *Aprendizaje Supervisado* (_Supervised Learning_), el cual consiste en aprender, a partir de un conjunto de entrenamiento etiquetado, la manera de clasificar o regresionar los nuevos ejemplos, sin embargo, no se basa en la interacción con el ambiente, como sí lo hace el RL. 

Por otro lado, el RL es diferente al *Aprendizaje No Supervisado* (_Unsupervised Learning_), el cual consiste ---en esencia--- en encontrar patrones o _estructura_ en un conjunto de entrenamiento sin etiquetas, no obstante, el RL no busca una estructura, sino que maximizar el retorno.

De esta manera, este modelo de aprendizaje lo asumiremos como un tercer paradigma del *Aprendizaje de Máquina* (_Machine Learning_). 

Un reto que aparece en el RL es el tradeoff entre _explorar_ y _explotar_: explorar para realizar mejores acciones a futuro; explotar decisiones que se sabe que son provechosas.

Finalmente, el RL es parte de una tendencia en la IA de retorno a principios generales y simples. Los métodos basados en principios generales se conocen como *métodos débiles* ("_weak methods_"), mientras que aquellos basados en conocimiento específico se denominan *métodos fuertes* ("_strong methods_").

=== Elementos del Reinforcement Learning

El ciclo de aprendizaje en el RL tiene dos actores principales: el *agente* y el *ambiente*. En esencia, el agente toma decisiones buscando una manera de actuar dado cierto estado y el ambiente, el objeto con el que el agente interactúa, se encarga de indicarle una recompensa dado su actuar y el siguiente estado en que estará. 

De manera más técnica, un sistema de RL se compone de: una _política_, una _señal de recompensa_, una _función de valor_ y, opcionalmente, un _modelo del ambiente_.

Una *política* (_policy_) es un mapeo (que denota una probabilidad) que el agente aprenderá y que define la manera en que el learner se comporta en determinado instante. Corresponde a una especie de reglas estímulo-respuesta. En general, estos mapeos son estocásticos.

Una *señal de recompensa* (_reward signal_) es el _reward_ que entrega el ambiente al agente en cada paso de tiempo. Ella afecta directamente la manera en que el agente se comportará. Por lo general, el objetivo del agente es _maximizar la recompensa total_, a largo plazo.

La *función de valor* (_value function_) especifica qué es lo bueno a largo plazo, indicando el monto total que puede esperar el agente a largo plazo. Es justamente parte de lo que queremos aprender.

El *modelo del ambiente* es un objeto que imita el comportamiento del ambiente y que permite realizar inferencias de cómo el ambiente se comportará. En el RL podemos encontrar métodos *basados en modelos* (_model-based_), que son justamente aquellos que tienen un modelo del ambiente, y otros métodos más simples, denominados métodos *libres de modelo* (_model-free_).

=== Procesos de Decisión de Markov Finitos
Este problema define el campo del RL.

Una especificación completa de un ambiente define una *tarea*, esto es, una instancia de RL.

A continuación se empieza a introducir notación.
El agente y el ambiente interactúan en instantes de tiempo discretos, $t = 0,1,2,...$ (aunque existen ideas que consideran el tiempo continuo). En cada instante, el agente recibe una *representación del estado del ambiente*, $S_t in SSS$, donde $SSS$ es el *espacio de estados* (_state space_). En esa situación, escoge una *acción* $A_t in AAA(S_t)$, donde $AAA(S_t)$ corresponde al conjunto de acciones posibles dado el estado $S_t$. Como consecuencia, un instante de tiempo después, el ambiente retorna una *recompensa* $R_(t+1) in RRR$, donde $RRR subset RR$ es un conjunto de posibles recompensas. Además, el ambiente le indica el nuevo estado $S_(t+1)$ al agente.

#figure[
  #image("../images/rl_relation.png", width: 60%)
]
La política del agente la denotamos como $pi_t (a|s)$, entendida como la probabilidad de que $A_t = a$ dado el estado $S_t = s$. Así, los métodos de RL consistirán en especificar cómo el agente modifica su política a partir de los resultados que obtiene.

#nota[ 
  La frontera entre agente y ambiente suele estar más cerca al agente de lo que se cree. Por ejemplo, los motores y sensores de un robot se consideran parte del ambiente (pues pueden entenderse como estados y recompensas), no del agente. Normalmente, basta con preguntarse si el agente _no_ puede cambiar algo arbitrariamente. De ser así, entonces ese algo no pertenece al agente. De esta manera, la frontera agente-ambiente corresponde al límite de control del agente, no de su conocimiento.

]

La recomenpensa es la manera en que comunicamos _qué_ es lo que queremos, no _cómo_ lo queremos.

En general, buscamos maximizar el *retorno esperado*, esto es, la esperanza de $G_t$, una función de los retornos. Por ejemplo,
$
  G_t = sum_(j = t+1)^T R_j,
$
donde $T$ es el último paso, si es que tiene sentido que haya un útlimo paso. En dicho caso, cada *episodio* (o _intentos_) termina en un estado especial llamado *estado terminal*. Denotaremos con $SSS$ los estados no-terminales y con $SSS^+$ todos los estados, incluyendo a los terminales. 

Cuando la interacción agente-ambiente no se puede separar en episodios identificables, es decir, no tenemos la noción de "último paso", llamamos a estas tareas _continuing tasks_. En este caso, tendríamos $T = infinity$ para $G_t$, por lo que podría diverger.

Para que $G_t$ tenga un valor finito, se introduce el factor $0<=gamma<=1$ conocido como *tasa de descuento* para definir el *retorno descontado*
$
  G_t = sum_(k=0)^infinity gamma^k R_(t+k+1).
$

==== Unificación de Notación entre Tareas Episódicas y Continuas

Para tareas episódicas, el estado que se tiene en el instante $t$ y episodio $i$ se denota $S_(t, i)$. Similarmente ocurre con $A_(t,i)$, $R_(t,i)$, $pi_(t,i)$, $T_i$. Como muchas veces estamos trabajando dentro de un episodio, se suele omitir el subdíndice $i$. 

Además, para unificar la notación del retorno, se pensará que las tareas episódicas tienen infinitos pasos, pero que al llegar al estado terminal se quedan en un _estado absorbente_ que transiciona sólo a si mismo con retorno cero.

==== Procesos de Decisión de Markov

Si el espacio de estados y el de acciones son finitos, entonces estamos ante un *finite MDP*. Un finite MDP se definte completamente a partir de: el espacio de estados, el espacio de acciones y por las dinámicas paso a paso del ambiente. 

Dado un estado $s$ y una acción $a$, la probabilidad de llegar al estado $s'$ y obtener una recompensa $r$ se denota por
$
  p(s',r|s,a) = Pr{S_(t+1) = s', R_(t+1) = r | S_t = s, A_t = a}.
$
Al tener todos los valores de $p$ dadas las posibles combinaciones de $s', t, s, a$, se tienen definidas las _dinámicas del ambiente_.

Dadas estas dinámicas, se puede calcular lo que sea. Por ejemplo, los _retornos esperados de un par estado-acción_,
$
  r(s,a) &= EE(R_(t+1) | S_t = s, A_t = a) \ 
    &= sum_(r in RRR) r dot Pr(R_(t+1) = r|S_t = s, A_t = a) \
    &= sum_(r in RRR) r sum_(s' in SSS) p(s', r|s,a).
$

Así también se pueden tener las _probabilidades estado-transición_ (es decir, la probabilidad de pasar de un estado a otro tomando cierta acción),
$
  p(s'|s,a) = Pr(S_(t+1) = s' | S_t = S, A_t = a) = sum_(r in RRR) p(s', r|s,a).
$

Finalmente, también se pueden obtener los _retornos esperados para un triple estado-acción-siguiente estado_,
$
    r(s,a,s') &= EE(R_(t+1) | S_t = s, A_t = a, S_(t+1) = s') \ 
    &= sum_(r in RRR) r dot Pr(R_(t+1) = r | S_t = s, A_t = a, S_(t+1) = s') \
    &= sum_(r in RRR) r dot Pr(R_(t+1) = r, S_t = s, A_t = a, S_(t+1) = s') / Pr(S_t = s, A_t = a, S_(t+1) = s') \
    &= sum_(r in RRR) r dot (Pr(R_(t+1) = r,  S_(t+1) = s' | A_t = a, S_t = s) cancel(Pr(A_t = a, S_(t) = s))) / (Pr(S_(t+1) = s' |A_t = a, S_(t) = s) cancel(Pr(A_t = a, S_(t) = s))) \
    &= sum_(r in RRR) r dot p(s', r|s,a)/p(s'|a,s).
$

Para los MDP finitos podemos construir un *grafo de transición* que permiten resumir las dinámicas visualmente. En ellos existen dos tipos de nodos: los *nodos de estado*, de los cuales se construye uno por cada estado $S in SSS$; y los *nodos de acción*, de los cuales se construye uno por cada par estado-acción. Los nodos de acción tienen entrante una arista dirigida desde un nodo de estado y tienen saliente una (o más) arista(s) dirigida(s) a otro nodo(s) de estado, donde este tipo de aristas presentas anotada la probabilidad y recompensa correspondiente de la transición estado-acción-estado siguiente.

==== Funciones de Valor

FUT 

#pagebreak()
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



#pagebreak()
== Minimum Description Length (MDL)
<mdl>

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

Este teorema, en nuestro enfoque, implica que, como $K(x)$ no es computable, en general no podamos asegurar haber encontrado la representación óptima de $x$, puesto que cualquier método computable entregará un largo para el que, en algunos casos, $K(x)$ será menor (si no, $K$ sería computable).




Ahora presentamos una aplicación práctica de la complejidad de Kolmogorov.

#deft[Minimum Description Length (MDL)][
  Sea $cal(H)$ una clase de hipótesis y $D$ un conjunto de datos. El *principio de Longitud Mínima de Descripción* indica que se seleccione la hipótesis
  $
    h^* = arg min_(h in cal(H)) (L(h) + L(D|h)),
  $
  donde $L(h)$ es la longitud en bits de la descripción de $h$ y $L(D|h)$ es la longitud de la descripción de $D$ dado $h$.
]

El MDL, esencialmente, formaliza la navaja de Occam, indicando que el criterio para escoger una hipótesis consiste en elegir aquella que minimiza la longitud de la hipótesis sumada a la de los datos codificados/descritos desde nuestra hipótesis:
- Una hipótesis muy simple, tiene $L(h)$ pequeño, pero $L(D|h)$ grande.
- Una hipótesis muy compleja, tiene $L(h)$ grande, pero $L(D|h)$ pequeño (en caso de que sea sobreajustada).



#nota[El MDL descrito anteriormente se conoce como MDL "crudo" o "de dos partes". Existe otro MDL, llamado "refinado", que utiliza códigos universales en vez de dos longitudes por separado. ]


#pagebreak()
== Backpropagation
<backprop>

FUT

Backpropagation es un algoritmo para calcular gradientes de manera eficiente y se suele ocupar para entrenar redes neuronales, parametrizadas por $f(x; w)$, donde $w$ son los pesos, pues muchas veces se encuentran los pesos usando descenso de gradiente sobre el error $E(w)$ (que suele depender de una función de pérdia $cal(l)(x; w)$), iterando
$
  w <- w - eta gradient_w E(w),
$
donde $eta > 0$ es el *learning rate*.

El Backpropagation es una aplicación de programación dinámica.

#nota[En el Apéndice, en @metodos_para_entrenar_red_neuronal,
 se encuentra un mapa conceptual que muestra más métodos con los que se puede entrenar una red neuronal.]


#pagebreak()
== Conceptos Bayesianos


A lo largo de diversas investigaciones se usan conceptos bayesianos, como prior y posterior, por lo que consideré importante repasarlos como una base para el aprendizaje composicional.

Sea $bold(z)$ una cantidad desconocida (como podría una variable latente o un programa) y sea $bold(x)$ un dato. El teorema de Bayes establece una igualdad para la distribución condicional de $bold(z)|bold(x)$:

#block(width: 100%)[
  #set math.equation(numbering: "(1)")
  $
    p(bold(z)|bold(x)) = (p(bold(x)|bold(z)) p(bold(z)))/(p(bold(x))),
  $ <eq_bayes>
  donde: 
  - $p(bold(z)|bold(x))$ es lo que se conoce como *posterior*. 
    Corresponde a, dado los datos, qué tan probable creemos que es cierto valor de $bold(z)$ (o, más rigurosamente, cierto rango de valores).
  - $p(bold(x)|bold(z))$ es la *verosimilitud*. 
    Corresponde a qué tan probable es el dato que se tiene asumiendo cierto valor de $bold(z)$.
  - $p(bold(z))$ es la *prior*. 
    Corresponde a la distribución, previo a la experiencia, esto es, previo a tener $bold(x)$, que creemos que tienen los valores de $bold(z)$. Cuando no tenemos una creencia previa para $bold(z)$, se deja como una uniforme.
  - $p(bold(x))$ es la *evidencia*. 
    Corresponde a la distribución que creemos que tienen los datos.
]

#notat[La posterior es una mezcla][
  Observa cómo es que en la ecuación @eq_bayes $p(bold(z)|bold(x)) proport p(bold(x)|bold(z)) p(bold(z))$, así que la posterior es una mezcla de lo que creíamos que valdría $bold(z)$ (con la prior) y la información que nos entregó $bold(x)$. 
]

#notat[Relación con el _posterior collapse_][
  En caso de que $bold(x)$ no nos informe nada en nuestro modelo, la posterior y la prior se vuelven idénticas, que es justo el caso del _posterior collapse_. De hecho, en ese caso, $p(bold(x)|bold(z)) = p(bold(x))$ y $bold(x)$ y $bold(z)$ se vuelven independientes.
]

Muchas veces convendrá además tener en mente el modelo generativo, que aprovecha la siguiente igualdad:
$
  p(bold(x), bold(z)) = p(bold(z)) p_theta (bold(x)|bold(z)),
$
donde $theta$ es un parámetro del modelo generativo. Se entiende como que:
1. Se muestrea un $bold(z) ~ p(bold(z))$.
2. Se genera un $bold(x) ~ p_theta (bold(x)|bold(z))$.

A partir de esta ecuación, se obtiene que
$
  p(bold(x)) =^"distribución\nmarginal" integral p(bold(x), bold(z)) dif bold(z) = integral p(bold(z)) p_theta (bold(x)|bold(z)) dif bold(z).
$
Por lo tanto, la distribución de los datos no depende de $bold(z).$ 


=== Aplicación de la Prior y la Posterior

El método de *Estimadores Máximo-Verosímiles* (EMV, o MLE en inglés) se escoge aquel $hat(bold(z))_"EMV"$ tal que
$
  hat(bold(z))_"EMV" = arg max_z p(bold(x)|bold(z)) = arg max_z [log p(bold(x)|bold(z))],
$
es decir, aquel que maximiza la verosimilitud de los datos observados.

Un método similar es *máximo a posteriori* (MAP, _Maximum A Posteriori_), que consiste en escoger aquel $hat(bold(z))_"MAP"$ tal que
$
  hat(bold(z))_"MAP" = arg max_z [log p(bold(x)|bold(z)) + log p(bold(z))],
$
esto es, es similar al EMV, sólo que también considera la creencia que tenemos sobre los $bold(z)$ previo a la experiencia. (Si $p(bold(z))$ es uniforme, el método se convierte en MLE.) 







#pagebreak()
#let xx = $bold(x)$
#let yy = $bold(y)$
#let zz = $bold(z)$
#let neunet = $"NeuralNet"$
#let ttheta = $bold(theta)$
#let pphia = $bold(phia)$
#let elbo = $cal(L)_(ttheta, pphia)$
#let KL = $D_"KL" (q_pphia (zz|xx) || p_ttheta (zz|xx))$
#let eeps = $bold(epsilon.alt)$


== An Introduction to Variational Autoencoders
<vaes>
#notat[Fuente][
  Contenido estudiado de _"An Introduction to Variational Autoencoders"_ de D. P. Kingma y M. Welling (2019).
  #fuente_link("https://arxiv.org/abs/1906.02691", "arXiv:1906.02691")
]

=== Introducción
Los Variational Autoencoders (VAE) entregan un framework para aprender modelos profundos de variables latentes y los modelos de inferencia correspondientes.

Suponga que queremos modelar la distribución conjunta de unas variables observadas. Sea $xx$ un vector de estas variables. De hecho, asumiremos que $xx$ es una muestra de un _proceso desconocido y subyacente_, con distribución real $p^* (xx)$ desconocida. Así, lo que buscamos es aproximar esta $p^*$. 

Para aproximar $p^*$, partimos de un modelo $p_ttheta$, cuyos parámetros en $ttheta$ ajustaremos de modo que
$
  p_ttheta (xx) approx p^*(xx).
$

De esta manera, tendremos un modelo generativo tal que
$
  xx ~ p_ttheta (xx).
$


==== Modelos Condicionales

A veces tendremos conocimiento sobre la distribución de los datos, lo que prodremos incluir con una distribución _a priori_. Los modelos que involucren este tipo de conocimiento se conocen como *Modelos Condicionales*. Asuma que queremos aproximar una distribución sobre los valores de una variable $yy$, dados unos datos $xx$ (observados, el *input*). Es decir, queremos aproximar $p^* (yy|xx)$ ajustando $p_ttheta (yy|xx)$.

#ex[Un ejemplo clásico es la clasificación de imágenes. Una imagen se toma como input, $xx$, y su clase se piensa como valor de $yy$.]


==== Redes Neuronales

Asumiremos que las *redes neuronales* son redes feed-forward diferenciables. Dos características de ellas son que:
#enum(numbering: "(1)")[
  Permiten _aproximar funciones_, en particular, densidades.
][
  Son _escalables_ a grandes modelos y grandes datasets, pues admiten optimización con SGD.
]

Cuando estas redes neuronales tienen muchas capas ocultas, decimos que estamos ante un problema de *deep learning*.  Denotaremos estas redes como la función vectorial (e.g. un vector de probabilidades de cada clase)
$
  neunet(dot).
$

#ex[
  La clasificación de imágenes con redes neuronales (LeCun _et al._, 2016) se ha realizado parametrizando una distribución categórica $p_ttheta (y|xx)$ sobre una clase de etiquetas $y$, condicionado a una imagen $xx$. (Los pesos de la red neuronal corresponden a $ttheta$.) Se define
  $
    bold(p) = neunet(xx),
  $
  esto es, la salida que produce la red neuronal que, en este caso, corresponde a un vector de probabilidades de clases (ergo $sum_i p_i = 1$ y $p_i >= 0$). Luego, se piensa
  $
    p_ttheta (y|xx) = "Categorical"(y; bold(p)),
  $
  donde $"Categorical"$ es una distribución categórica parametrizada por $bold(p)$. 
]


==== Modelos Gráficos Dirigidos

Los *modelos probabilísticos dirigidos*, *modelos gráficos probabilísticos* o *redes bayesianas* son modelos donde todas las variables están organizadas en un digrafo acíclico:
- Los nodos representan a las variables.
- Las aristas representan relaciones de independencia.

Denotaremos con $"Pa"(xx_j)$ los padres de la variable $xx_j$). Aquí, la distribución sobre las variables resulta en
$
  p_ttheta (xx_1,...,xx_M) = product_(j=1)^M p_ttheta (xx_j|"Pa"(xx_j)).
$
#nota[
  Si $xx_j$ no tiene padres, i.e. es una raíz, $"Pa"(xx_j) = emptyset$, pero la distribución se piensa incondicional simplemente.
]


==== Dataset y Verosimilitud
Nuestro *dataset* es
$
  cal(D) &= {xx^((i))}_(i=1)^N =: xx^((1:N)). \
$

Dado un datates $cal(D)$, denotamos con $N_cal(D)$ su tamaño. Muchas veces asumimos las observaciones $xx^((i))$ i.i.d. Así, podemos calcular la probabilidad (densidad) de los datos según el modelo. En particular, podemos obtener la log-probabilidad asociada
$
  log p_ttheta (cal(D)) = sum_(i=1)^N log p_ttheta (xx^((i))).
$
El criterio más común para los modelos es el de la *Máxima Verosimilitud (ML)*, esto es, encontrar el $ttheta$ que maximiza la verosimilitud (o la log-verosimilitud). (Que es equivalente a la minimización de la divergencia de Kullback-Leibler). Para ello, se usa *Stochastic Gradient Descent (SGD)*#footnote[Podríamos usar *Batch Gradient Descent* considerando al maximizar siempre todo $cal(D)$, pero el costo sería muy alto para datasets grandes (lineal).] que usa minibatches $cal(M) subset cal(D)$ y define el estimador
$
  1 / (N_cal(M)) log p_ttheta (cal(M)) tilde.eq 1 / (N_cal(D)) log p_ttheta (cal(D))
$ 
("$tilde.eq$" indica que un miembro de la ecuación es un estimador insesgado del otro). Este estimador es diferenciable, por lo que podemos estimar
$
  1 / (N_cal(M)) nabla_ttheta log p_ttheta (cal(M)) tilde.eq 1 / (N_cal(D)) nabla_ttheta log p_ttheta (cal(D)).
$


==== Variables Latentes y Modelos Profundos Latentes (DLVMs)

El método presentado en la sección anterior es válido cuando las variables del modelo dirigido son _totalmente observadas_, pero podemos extenderlo a modelos dirigidos con variables latentes. Las *variables latentes* (denotadas con $zz$) son variables que son parte del modelo, pero que no observamos, por tanto, no forman parte del dataset. 

En modelamiento incondicional, la distribución conjunta es $p_ttheta (xx, zz)$. Para conocer $p_ttheta (xx)$, 
$
  p_ttheta (xx) = integral p_ttheta (xx, zz) dif zz = integral p_ttheta (xx|zz) p_ttheta (zz) dif zz.
$
(Recuerda que $p_theta (xx, zz) = p_theta (zz|xx) p_theta (xx) = p_ttheta (xx|zz) p_theta (zz).$)

Cuando la distribución de un modelo de variable latente, $p_ttheta (xx, zz)$, está parametrizada por una red neuronal, usamos el término *Modelo Profundo de Variable Latente* (_deep latent variable model, DLVM_). Una ventaja de los DLVMs es su expresividad: la distribución marginal de $xx$ puede ser muy compleja, aun cuando la distribución condicional $p_ttheta (xx|zz)$ o la _a priori_ $p_ttheta (zz)$ son simples.


==== Intratabilidades

La principal dificultad de los DLVMs es que la marginal $p_ttheta (xx) = integral p_ttheta (xx,zz) dif zz$ es intratable, pues no tiene una fórmula analítica ni un estimador eficiente. Por esto, no podemos diferenciar respecto a $ttheta$ para optimizarla (que es nuestro objetivo), esto es, no podemos aplicar SGD. 

La intratabilidad de $p_ttheta (xx)$, recordando que
$
  p_ttheta (xx,zz) =  p_ttheta (zz|xx) p_ttheta (xx),
$
Provoca que $p(zz|xx)$ sea intratable, en principio. Es decir, ambas densidades son intratables en DLVMs.

Para resolver esto, las _técnicas aproximadas de inferencia_ nos permitirán aproximar $p_ttheta (zz|xx)$ y $p_ttheta (xx)$ en los DLVMs. Los métodos tradicionales son relativamente caros.

=== Variational Autoencoders

Superaremos las intratabilidades de los DLMVs con los VAEs.

==== Encoder

Definimos el *encoder*, *modelo de reconocimiento* o *modelo de inferencia* $q_pphia (zz|xx)$. Aquí $pphia$ indica los parámetros del modelo, llamados *parámetros variacionales*. Buscaremos que esta distribución sea lo más parecida a la posteriori $p_ttheta (zz|xx)$, es decir,
$
  q_pphia (zz|xx) approx p_ttheta (zz|xx).
$
Con ella podremos más adelante optimizar $p_ttheta (xx)$.

El modelo de inferencia puede ser prácticamente cualquier modelo gráfico dirigido,
$
  q_pphia (zz|xx) = q_pphia (zz_1,...,zz_M|xx) = product_(j=1)^M q_pphia (zz_j|"Pa"(zz_j), xx).
$
Además, $q_pphia$ puede ser parametrizada por una red neuronal profunda.

#ex[
  Podríamos tener
  $
    q_pphia (zz|xx) = "Normal"(zz; bold(mu), "diag"(bold(sigma))),
  $
  donde
  $
    (bold(mu), log bold(sigma)) = "EncoderNeuralNet"_pphia (xx).
  $
]

Usaremos un único encoder neuronal para realizar inferencia posterior sobre _todos_ los puntos del dataset, a diferencia de lo que ocurre con otros métodos de inferencia variacional, donde los parámetros de $pphia$ se optimizan separadamente _para cada punto_ del dataset. Nuestra técnica se conoce como *inferencia variacional amortizada*. Esto nos permitirá ser más eficientes y aprovechar el SGD.

==== Evidence Lower Bound (ELBO)

Para cada elección de encoder $q_pphia (zz|xx)$ (con $pphia$ ya fijo),
*REVISAR*
$
  EE(log p_ttheta (xx)) &= integral  q_pphia (zz|xx) dot log p_ttheta (xx) dif zz \ 
  &= EE_(zz ~ q_pphia (zz|xx)) [log p_ttheta (xx)] \
  &= EE_(zz ~ q_pphia (zz|xx)) [log ((p_ttheta (xx,zz)) / (p_ttheta (zz|xx)))] \
  &= EE_(zz ~ q_pphia (zz|xx)) [log ((p_ttheta (xx,zz)) / (q_pphia (zz|xx)) dot (q_pphia (zz|xx))/ (p_ttheta (zz|xx)))] \
  &= EE_(zz ~ q_pphia (zz|xx)) [log ((p_ttheta (xx,zz)) / (q_pphia (zz|xx)))] 
  + EE_(zz ~ q_pphia (zz|xx)) [log ((q_pphia (zz|xx))/ (p_ttheta (zz|xx)))].
$

Definimos *Evidence Lower Bound (ELBO)*
$
  elbo (xx) &:= EE_(zz ~ q_pphia (zz|xx)) [log ((p_ttheta (xx,zz)) / (q_pphia (zz|xx)))] \
  &= EE_(zz ~ q_pphia (zz|xx)) [log p_ttheta (xx,zz) - log q_pphia (zz|xx)]
$
y la *divergencia de Kullback-Leibler (KL)* entre $q_phia (zz|xx)$ y $p_ttheta (zz|xx)$ como
$
  KL &:= EE_(zz ~ q_pphia (zz|xx)) [log ((q_pphia (zz|xx))/ (p_ttheta (zz|xx)))] \
  &= EE_(zz ~ q_pphia (zz|xx)) [log q_pphia (zz|xx) - log p_ttheta (zz|xx)].
$

#nota[El término $EE_(z ~ q_pphia (zz|xx)) [log p_ttheta (xx|zz)]$ en $elbo(xx)$ se conoce como *error de reconstrucción*.]

De esta manera,
$
  log p_ttheta (xx) = elbo (xx) - KL.
$

Nótese que 
$
  D_"KL" >= 0,
$
por lo que
$
  log p_ttheta (xx) >= elbo (xx).
$
Además, observe que la divergencia KL determina dos distancias:
1. La distancia entre la posterior real, $p_ttheta (zz|xx)$, y su aproximación, $q_pphia (zz|xx)$, por la definición que tiene.
2. El _gap_ entre la verosimilitud marginal $log p_ttheta (xx)$ y la ELBO $elbo$. (Llamado *ajuste de la cota*.)

Es por esto que intentaremos maximizar $elbo$ con respecto a sus parámetros $ttheta, pphia$, de modo que ambas distancias se hagan lo más pequeñas posibles, de manera aproxima.


==== Stochastic Gradient-Based Optimization for ELBO

La ELBO permite SGD sobre sus parámetros. 

Dado un dataset $cal(D) = xx^((1:N))$, la ELBO objetivo es 
$
  elbo (cal(D)) := sum_(i=1)^N elbo(xx^((i))).
$
El gradiente individual $nabla_(ttheta, pphia) elbo (xx^((i)))$ es en general intratable, pero existen buenos estimados insesgados $tilde(nabla)_(ttheta, pphia) elbo (xx^((i)))$.

Respecto a $ttheta$, es directo:
$
  nabla_ttheta elbo (xx) &= nabla_ttheta EE_(z ~ q_pphia (zz|xx)) [log p_ttheta (zz|xx) - log q_pphia (zz|xx)] \
  &= nabla_ttheta integral q_pphia (zz|xx) [log p_ttheta (zz|xx) - log q_pphia (zz|xx)] dif zz \
  -->^"Leibniz" qquad&=  integral nabla_ttheta {q_pphia (zz|xx) [log p_ttheta (zz|xx) - log q_pphia (zz|xx)]} dif zz \
  &=   integral q_pphia (zz|xx) dot nabla_ttheta [log p_ttheta (zz|xx) - log q_pphia (zz|xx)] dif zz  \
  &= EE_(z ~ q_pphia (zz|xx)) [nabla_ttheta (log p_ttheta (zz|xx) - log q_pphia (zz|xx))].
$
Tomando un $zz ~ q_pphia (zz|xx)$, se obtiene un estimador simple de Monte Carlo
$
  nabla_ttheta elbo (xx) tilde.eq nabla_ttheta (log p_ttheta (zz|xx) - log q_pphia (zz|xx)) = nabla_ttheta log p_ttheta (zz|xx).
$

Respecto a $pphia$ es más difícil, pues $q_pphia$ depende justamente de $pphia$. Es decir, 
$
  nabla_ttheta elbo (xx) &= nabla_ttheta EE_(z ~ q_pphia (zz|xx)) [log p_ttheta (zz|xx) - log q_pphia (zz|xx)] \
  &!= EE_(z ~ q_pphia (zz|xx)) [nabla_ttheta (log p_ttheta (zz|xx) - log q_pphia (zz|xx))].
$

Para esto, usaremos el _truco de reparametrización_.

==== Reparametrization Trick

Expresaremos $zz ~ q_pphia (zz|xx)$ como una transformación $g$ diferenciable e invertible de otra va $eeps$, independiente de $xx$ y de $pphia$, y con densidad $p(eeps)$:
$
  zz = g(eeps, pphia, xx).
$ 
Con esto, para cualquier función $f$,
$
  EE_(z ~ q_pphia (zz|xx)) [f (zz)] &= integral q_pphia (zz|xx) f(zz) dif zz.
$
Pero,
$
  dif zz = abs(det((partial g)/(partial eeps))) dif eeps
$
y 
$
  q(zz|xx) = abs(det((partial g)/(partial eeps)))^(-1) p(eeps),
$
así que
$
  q(zz|xx) dif zz = p (eeps) dif eeps.
$
Por lo tanto,
$
  EE_(z ~ q_pphia (zz|xx)) [f (zz)] &= integral q_pphia (zz|xx) f(zz) dif zz \ 
  &= integral f(g(eeps, pphia, xx)) p(eeps) dif eeps \ 
  &= EE_(eeps ~ p(eeps)) [f(zz)].  
$
Ahora se puede hacer 
$
  nabla_pphia  EE_(z ~ q_pphia (zz|xx)) [f (zz)] &= nabla_pphia EE_(eeps ~ p(eeps)) [f(zz)] \
  &= integral nabla_pphia {f(g(eeps, pphia, xx)) p(eeps)} dif eeps \
  &= integral p(eeps) nabla_pphia f(g(eeps, pphia, xx)) dif eeps \
  &= EE_(eeps ~ p(eeps)) [nabla_pphia f(zz)].  
$
Finalmente, tenemos un estimador simple de Monte Carlo
$
  nabla_pphia EE_(z ~ q_pphia (zz|xx)) [f (zz)] tilde.eq nabla_pphia f(zz).
$
De esta manera, reparametrizamos al aleatoriedad de $zz$ y ahora podremos hacer _backpropagation_ por $zz$ y calcular los gradientes $nabla_pphia f(zz)$.

#nota[En este capítulo se enseña el _reparametrization trick_ para una $f$ cualquiera. En la sección que viene se usa una $f$ del problema.]

==== Gradiente de ELBO

Con el _reparametrization trick_, podemos escribir
$
  elbo (xx) &= EE_(z ~ q_pphia (zz|xx)) [log p_ttheta (xx, zz) - log q_pphia (zz|xx)] \
  &= EE_(eeps ~ p(eeps)) [log p_ttheta (xx,zz) - log q_pphia (zz|xx)].
$
Luego, podemos obtener un estimador simple de Monte Carlo, $tilde(cal(L))_(ttheta, pphia) (xx)$, de $elbo(xx)$ para cada $xx in cal(D)$ (o $cal(M)$):
$
  eeps &~ p(eeps) \
  zz &= g(pphia, xx, eeps) \
  tilde(cal(L))_(ttheta, pphia) (xx) &= log p_ttheta (xx,zz) - log q_pphia (zz|xx).
$
Finalmente, para optimizar el ELBO se ocupan los gradientes $nabla_(ttheta, pphia) tilde(cal(L))_(ttheta, pphia) (xx)$.

==== Algoritmo Auto-Encoding Variational Bayes (AEVB)

Por último, el algoritmo estocástico para optimizar el ELBO es

#algot[AEVB][
  
  *Data:*
  - $cal(D)$: Dataset.
  - $q_pphia (zz|xx)$: Modelo de inferencia.
  - $p_ttheta (xx, zz)$: Modelo generativo.

  *Resultado:*
  - $ttheta, pphia$: Parámetros aprendidos

  1. $(ttheta, pphia) <- "Inicializar parámetros."$

  2. *while* SGD _no ha convergido_ *do*:
  3. |#qquad $cal(M) ~ cal(D)$ (extraer un minibatch random).
  4. |#qquad $eeps ~ p(eeps)$ (extraer sonido random para cada punto en $cal(M)$).
  5. |#qquad Calcular $tilde(cal(L))_(ttheta, pphia) (cal(M), eeps)$ y sus gradientes $nabla_(ttheta, pphia) tilde(cal(L))_(ttheta, pphia) (cal(M), eeps)$.
  6. |#qquad Actualizar $ttheta, pphia$ usando un optimizador SGD.
]

==== Notas Adicionales

Ya sabemos que denotamos con $q_pphia (zz|xx)$ el encoder (o distribución posterior), con $p_ttheta (xx|zz)$ el decoder y $p_ttheta (zz)$ para el prior.

Una vez optimizado el ELBO con el algoritmo, ya tenemos $ttheta, pphia$ "óptimos", por lo que el encoder y el decoder ya están listos para ser usados. Con ellos, la _generación de datos nuevos_ funciona del siguiente modo:
1. Samplee $zz' ~ p_ttheta (zz)$ (prior).
2. Genere $xx ~p_ttheta (xx|zz')$ (decoder).

#nota[
  Generar datos nuevos podría usarse, por ejemplo, para aumentar conjuntos pequeños de datos, o crear imágenes, sonidos, videos, etc.
]

Pero también se podría querer _reconstruir un dato_. Para ello, dado un dato $xx$:
1. Samplee $zz' ~ q_pphia (zz|xx)$ (encoder).
2. Genere $xx' ~ p_ttheta (xx|zz')$ (decoder).

#nota[
  Reconstruir un dato permite, por ejemplo, comprimir datos (guardando solamente $zz'$), eliminar ruido (guardando $xx'$ en vez de $xx$) o comprobar anomalías en el modelo (comparando $xx'$ con $xx$).
]

=== Glosario
FUT

- *Inferencia Variacional:*
- *Estimador de Monte-Carlo:*
