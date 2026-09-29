// Funciones
#import "/math_functions.typ": *
#import "/notalmar.typ": *
#include "/notalmar.typ"


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


