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
== DreamerV3
<dreamer>
#notat[Fuente][
  Contenido estudiado de _"Mastering Diverse Domains through World Models"_ de D. Hafner et al. (2023).
  #fuente_link("https://arxiv.org/abs/2301.04104", "arXiv:2301.04104")
]

#nota[No confundir con *@dream_coder*.]


DreamerV3 consiste en un algoritmo de RL que aprende un modelo de mundo y le permite al agente imaginar el futuro, escogiendo las acciones que mejores resultados le dan. El modelo supera a otros algoritmos de RL con gran conocimiento de dominio y permite reducir el ajuste especial que se suele tener que hacer a los algoritmos de RL al aplicarlos a una nueva tarea, reduciendo la interacción necesaria.

Los autores afirman que el reto es grande, pues se busca aprender en distintos dominios y con hiperparámetros fijados.

=== Algoritmo de Aprendizaje

Consiste en tres redes neuronales: 
1. El modelo de mundo que predice los resultados de las acciones potenciales.
2. Un juez crítico del valor de cada resultado.
3. Agente que decide los resultados más valiosos.

Estos tres componentes se entrenan de manera concurrente desde experiencia mientras que el agente interactúa con el ambiente. 

==== Aprendizaje del Modelo de Mundo 

El modelo aprende representaciones compactas de las entradas sensoriales por medio de _autoencoding_. Se implementa un modelo de mundo como un *Modelo de Estado-Espacio Recurrente* (_Recurrent State-Space Model, RSSM_). En cada paso $t$:
- Se calcula la _memoria_ acumulada de los pasos anteriores, $ h_t = f_phia (h_(t-1), z_(t-1), a_(t-1)), $ por medio de un modelo de secuencia (GRU).

- Un encoder mapea los inputs sensoriales $x_t$ a representaciones estocásticas $ z_t ~ q_phia (z_t | h_t, x_t). $ 
- Un predictor intenta reproducir esa misma representación usando sólo la memoria (sin $x_t$), produciendo $ hat(z) _t ~ p_phia (hat(z)_t | h_t). $
- La concatenación de $h_t$ y $z_t$ produce el estado del modelo, $ s_t = {h_t, z_t}, $ a partir del cual predecimos las recompensas $r_t$ y las _episode continuation flags_ $c_t in {0,1}$, y reconstruimos los inputs $x_t$ para asegurar representaciones informativas.

==== Aprendizaje del Crítico

Tanto el actor como el crítico aprenden su comportamiento únicamente a partir del modelo de mundo. Ambos operan en los estados del modelo $s_t$. El actor apunta a maximizar el retorno
$
  R_t = sum_(tau = 0)^infinity gamma^tau r_(t+tau).
$
Para _rewards_ más allá de $T = 16$, el crítico aprende a aproximar la distribución de los retornos para cada estado $s_t$:
$
  "Actor:" qquad a_t tilde pi_theta (a_t | s_t) qquad qquad "Crítico:" qquad v_psi (R_t | s_t).
$
Naturalmente, se leen los valores esperados como los valores predichos por el crítico: $ v_t = E[v_psi (dot | s_t)] qquad (= E_(R tilde v_psi (dot|s_t)) [R]). $

Para estimar los retornos que consideran _rewards_ más allá del horizonte de predicción, se calculan *boostrapped $lambda$-returns* $ R^(lambda)_t = r_t + gamma c_t ((1-lambda) v_t + lambda R^lambda_(t+1)) $ que integran los _rewards_ predichos por el crítico con los valores de reward reales, y corresponden al objetivo del crítico.


#notat[On-policy, off-policy][
  En RL, los datos pueden ser generados:
  - por la misma política que actúa, lo que se conoce como que estos son generados *on-policy*;
  - por una política distinta a la que actúa, lo que se conoce como *off-policy* (e.g. una política antigua, datasets ya creados [como caso extremo, conocido como *offline RL*])
]



==== Aprendizaje del Actor

Queremos que el agente explore más si las recompensas son ralas y explotar más si las recompensas son cercanas. Al mimso tiempo, la cantidad de exploración no debería verse influenciada por escalamientos arbitrarios en recompensas del ambiente. Esto requiere que se normalice la escala de los retornos, mientras se preserva información sobre la frecuencia de las recompensas. Para esto, se normalizan los retornos para que estén aproximadamente en $[0,1]$ con la cantidad
$
  S = "EMA"("Per"(R^lambda_t, 95) - "Per"(R^lambda_t,5), 0.99),
$
donde $"EMA"$ corresponde a un "Exponential Moving Average", una función que permite promediar distintos valores, pero dando mayor peso a los valores recientes, y $alpha = 0.99$ es su decaimiento.


==== Ciclo de aprendizaje

Como se mencionó, las tres redes aprenden al mismo tiempo aprovechando la experiencia del *replay buffer*.

1. Actuar. El actor juega en el ambiente real y las trayectorias se guardan en el _replay buffer_.
2. Entrenar. En cada paso de gradiente:
  - Se toma un batch de trayectorias reales del buffer.
  - Se actualiza el modelo de mundo con ese batch (pérdidas, etc.).
  - Desde los estados latentes del batch, se imagina con el modelo de mundo actual y el actor actual.
  - Se actualiza el actor y el crítico con las trayectorias imaginadas.
3. Iterar.

#nota[El *replay buffer* no es más que la memoria que tiene un modelo para poder almacenar datos (especialmente cuando estos son caros).]


=== Resultados

El resultado más destacado es el de lograr obtener diamantes en Minecraft (un entorno muy difícil, por ser grande y aleatorio) en menos de 30 minutos de juego por primera vez sin datos humanos (no como VPT de OpenAI, que usó miles de horas de juego e imitaba el comportamiento humano).


*Propiedades de escalamiento.* Se mostró en Crafter y DMLab que, con distintas cantidades de parámetros y distintos _replay ratios_ (número de veces que se aprovecha una experiencia), hay aprendizaje robusto. Además, aumentar el tamaño del modelo (el número de parámetros) directamente aumenta el rendimiento por tarea y reduce la cantidad de datos requeridos. Asimismo, aumentar el número de pasos de gradiente reduce la interacción necesaria para aprender comportamientos exitosos.


