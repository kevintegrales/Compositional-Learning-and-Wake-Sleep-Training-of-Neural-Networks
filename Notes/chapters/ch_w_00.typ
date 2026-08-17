// Funciones
#import "/math_functions.typ": *
#import "/notalmar.typ": *
#include "/notalmar.typ"

== Introducción y Definiciones Básicas

=== Lenguaje Formal
/*Un *lenguaje formal* es un conjunto de cadenas formadas a partir de un conjunto finito de símbolos, estructuradas de acuerdo a reglas específicas.

- *Notación:* Sea un alfabeto $Sigma$ (un conjunto finito de símbolos, por ejemplo, ${0, 1}$). El cierre de Kleene, $Sigma^*$, denota el conjunto de todas las cadenas finitas posibles formadas con símbolos de $Sigma$. Un lenguaje formal $L$ es cualquier subconjunto de $Sigma^*$, es decir, $L subset.eq Sigma^*$. Si $x$ es una cadena que pertenece al lenguaje, se escribe $x in L$.

Para investigar la complejidad de Kolmogorov con aplicaciones en el aprendizaje composicional y el algoritmo wake-sleep, los siguientes conceptos son fundamentales:*/



=== Entropía de Shannon (Teoría de la Información)
/*Mide la incertidumbre o la cantidad de información esperada de una variable aleatoria que sigue una distribución de probabilidad. A diferencia de la complejidad de Kolmogorov, que mide la información contenida en un objeto algorítmico individual, la entropía de Shannon asume un modelo probabilístico subyacente. El aprendizaje wake-sleep busca codificar información acercándose a este límite.

- *Notación:* $H(X) = - sum_(x in cal(X)) P(x) log_2 P(x)$, donde $X$ es una variable aleatoria con un conjunto de posibles resultados $cal(X)$ y función de masa de probabilidad $P(x)$.
*/

=== Principio de Longitud de Descripción Mínima (MDL)
/*Es un método de inferencia estadística que postula que la mejor hipótesis (o modelo) para un conjunto de datos es la que permite la compresión de esos datos. Constituye un puente práctico entre la complejidad de Kolmogorov (incomputable) y el aprendizaje automático, útil en el aprendizaje composicional para seleccionar representaciones compactas y modulares.

- *Notación:* El objetivo es encontrar una hipótesis $H$ dentro de un espacio de hipótesis $cal(H)$ que minimice $L(H) + L(D|H)$. Aquí, $L(H)$ es la longitud en bits para describir el modelo, y $L(D|H)$ es la longitud para describir los datos $D$ dado el modelo $H$.
*/

=== Encoders y Autoencoders

VAEs

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

Una *política* (_policy_) es una función que el agente aprenderá y que define la manera en que el learner se comporta en determinado instante. Corresponde a una especie de reglas estímulo-respuesta. En general, estas funciones son estocásticas.

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


#pagebreak()
== DreamerV3

== Notas de Composicionalidad

=== ¿Qué no entendí?


#pagebreak()
== Computabilidad

=== Máquinas de Turing







#pagebreak()
== Referencias Semana 0
- *S0 - Notas-ApprComposicional*. (Una pasada para ver qué no conozco, otra para entender todo.)
- Paper DreamCoder: *Mastering Diverse Domains through World Models* (Sólo hasta Sección 2).
- *Li, M. & Vitányi, P. (2008). An Introduction to Kolmogorov Complexity and Its Applications*, 3ª ed. Springer. (C1 y C2)
- *Sipser, M. (2012). Introduction to the Theory of Computation*, 3ª ed. — Capítulos 3 (máquinas de Turing) y 4 (decidibilidad, problema de la parada).
- *Grünwald, P. D. (2007). The Minimum Description Length Principle. MIT Press* (C1) 

