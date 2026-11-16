#import "/math_functions.typ": *
#import "/bloques.typ": *

#frase[En un espacio continuo todo punto es un estado posible, así que un error se ve igual que un estado legítimo; en un espacio discreto, los estados válidos son pocos y están separados, y eso convierte el error en algo que se puede detectar, borrar, ubicar en el tiempo y contar.]

Se repite a menudo que la discretización "permite seguir el error" (_track errors_). La frase es correcta, pero suele quedarse en una intuición. Este capítulo la desarma en cuatro capacidades distintas: *detectar* que hubo un error, *corregirlo*, *localizar* en qué paso ocurrió y *contar* cuántos hubo. Para cada una veremos qué la hace posible, cuánto rinde y cuándo deja de funcionar. Es el desarrollo de la pieza #pieza(5) (redondeo), con apoyo de la #pieza(6) (identidad exacta).

== El problema: en continuo, el error es invisible

Pensemos en un modelo del mundo que predice la posición de un robot sobre una línea. La posición real es 1,00 y el modelo predice 1,27. ¿Puede el modelo, mirando solo su propia predicción, darse cuenta de que se equivocó?

No puede. En un espacio continuo, 1,27 es una posición tan válida como 1,00 (@fig:error-estado, arriba). Nada en el valor delata el error. El error existe, pero es invisible desde dentro.

Ahora supongamos que el robot solo puede estar en posiciones enteras: 0, 1, 2, 3 o 4. Entonces 1,27 *no es un estado posible* (@fig:error-estado, abajo). El solo hecho de caer entre dos estados válidos dice "aquí hubo un error". Además, el estado válido más cercano, 1, es una buena apuesta de cuál debía ser.

#fig("f15_error_o_estado.svg")[(a) En un espacio continuo, el valor con error es indistinguible de un estado legítimo. (b) Si solo los enteros son estados válidos, caer entre ellos revela el error (detección), y redondear al más cercano lo elimina (corrección).] <fig:error-estado>

Es lo mismo que pasa al leer. Si alguien escribe "gaot", sabemos que hubo un error, porque "gaot" no es una palabra, y podemos adivinar que quiso decir "gato". El idioma tiene muchas menos palabras que combinaciones de letras, y esa *redundancia* es la que permite detectar y corregir. Un espacio continuo no tiene redundancia de este tipo: cada combinación de valores "es una palabra".

#idea[Códigos correctores de errores][
  #ctp(<shannon1948>) y #ctp(<hamming1950>) fundaron la teoría de cómo transmitir información sin errores por un canal con ruido. La idea central es usar solo un subconjunto de los mensajes posibles (las *palabras de código*) y elegirlas *lejos* unas de otras. Si dos palabras de código válidas difieren en al menos $d$ posiciones (su *distancia mínima*), entonces:
  - se pueden *detectar* hasta $d - 1$ errores, porque con menos de $d$ cambios no se alcanza otra palabra válida;
  - se pueden *corregir* hasta $floor((d-1) slash 2)$ errores, porque con esos cambios la palabra original sigue siendo la más cercana.
  Hoy, toda la memoria de un computador, los discos y las comunicaciones móviles usan este principio.
]

== Detectar y corregir: la geometría de los márgenes

La misma idea funciona en un espacio latente continuo donde los códigos válidos son unos pocos puntos $e_1, dots, e_K$, como el diccionario de un VQ-VAE. Llamemos $d$ a la distancia entre dos códigos vecinos. Supongamos que el modelo debía producir el código $A$, pero su salida tiene ruido. La @fig:zonas muestra qué puede pasar.

#fig("f16_zonas.svg")[Izquierda: códigos válidos (naranjos) separados por $d$, con un disco de radio $r$ alrededor de cada uno. Se envía $A$ y se recibe un punto con ruido. Si cae en el disco de $A$, se corrige (✓). Si cae lejos de todo código, se detecta el error (?). Si cae en el disco de otro código, se produce un error silencioso (✗). Derecha: el mismo análisis sobre el segmento de $A$ a $B$, con una distribución de ruido centrada en $A$.] <fig:zonas>

Si el sistema acepta un punto cuando está a menos de $r$ de algún código, y lo reemplaza por ese código, aparecen tres zonas:
- *Se corrige:* el error mide menos que $r$. El punto vuelve a $A$ y el error desaparece por completo.
- *Se detecta:* el punto queda a más de $r$ de todos los códigos. El sistema no sabe cuál era, pero *sabe que algo anda mal* y puede pedir otra observación, marcar la predicción como poco confiable o detenerse.
- *Error silencioso:* el error es tan grande (más que $d - r$) que el punto cae cerca de *otro* código. El sistema lo corrige hacia el código equivocado y no se entera.

El umbral $r$ reparte el espacio entre las tres zonas. Con $r = d slash 2$ no hay zona de detección: todo se corrige, bien o mal, que es lo que hace un VQ-VAE al tomar siempre el vecino más cercano. Con $r$ más pequeño se corrige menos, pero se detecta más y se cometen menos errores silenciosos.

Hay un segundo compromiso, más profundo. Para que los errores frecuentes caigan en la zona de corrección, los códigos tienen que estar lejos entre sí. Pero en una región de tamaño fijo, *cuanto más separados estén los códigos, menos caben*. En $n$ dimensiones, con separación $d$ en una región de lado $A$, caben del orden de $(A slash d)^n$ códigos. Más margen significa más robustez y menos capacidad. La pieza #pieza(5) (redondeo) y la pieza #pieza(1) (capacidad) son dos caras del mismo diseño.

#pensar[En un VQ-VAE, ¿qué pasa con la capacidad de corregir errores si dos códigos del diccionario terminan muy cerca uno del otro?]

== Corregir en cadena: errores que no se acumulan

La corrección se vuelve decisiva cuando la salida de un paso es la entrada del siguiente, como en los rollouts de un modelo del mundo (@fig:modelo-mundo). Veamos un modelo mínimo que permite calcular todo.

Supongamos que el estado verdadero avanza de forma determinista y que, en cada paso, el modelo agrega un error aleatorio $epsilon_t$ con distribución normal de desviación $sigma$. Midamos todo en unidades de la separación $d$ entre códigos.

*En continuo*, los errores se suman:
$ e_T = epsilon_1 + epsilon_2 + dots + epsilon_T, quad "Var"(e_T) = T sigma^2. $
El error típico crece como $sigma sqrt(T)$, sin límite. Y esto es el caso optimista. Si la dinámica amplifica las diferencias (si dos estados cercanos se separan con el tiempo, con un factor $L > 1$ por paso), el error crece como $L^T$, es decir, exponencialmente.

*En discreto*, después de cada paso se redondea al código más cercano. Si el error acumulado es cero y el ruido de este paso mide menos que $d slash 2$, el redondeo lo borra y el error *sigue siendo exactamente cero*. Solo cuando un ruido supera la mitad de la separación el estado salta a un código vecino. La probabilidad de que eso pase en un paso es
$ p = P(|epsilon| > d slash 2) = 2 overline(Phi)(d / (2 sigma)), $
donde $overline(Phi)$ es la cola de la distribución normal. Así, el error discreto no es una suma de ruidos pequeños, sino una sucesión de ceros interrumpida, de vez en cuando, por un salto completo. La @fig:trayectorias lo muestra con una simulación.

#fig("f17_trayectorias.svg")[Simulación con 30 rollouts de 60 pasos y ruido $sigma = 0,18 d$ por paso (semilla fija; el código está en `figures/generar.py`). En continuo, el error de todos los rollouts se dispersa como $sigma sqrt(t)$. En discreto, 24 de los 30 rollouts terminan sin *ningún* error, y los demás tienen uno o dos saltos.] <fig:trayectorias>

¿Cuánto mejor es? Una forma limpia de compararlos es mirar la *variabilidad que se agrega en cada paso*. En continuo es $sigma^2$. En discreto es la varianza de un salto, que para ruido pequeño es aproximadamente $p dot d^2$. La tabla muestra ambas para distintos niveles de ruido (en unidades de $d^2$):

#align(center)[
  #table(
    columns: 4,
    stroke: none,
    inset: (x: 9pt, y: 3pt),
    align: center,
    table.hline(stroke: 0.6pt),
    table.header([*Ruido $sigma$*], [*Continuo: $sigma^2$*], [*Discreto: varianza del salto*], [*Razón*]),
    table.hline(stroke: 0.4pt),
    [$0,10 d$], [$0,0100$], [$0,00000057$], [$approx 1 slash 17 000$],
    [$0,15 d$], [$0,0225$], [$0,00086$], [$approx 1 slash 26$],
    [$0,20 d$], [$0,0400$], [$0,0124$], [$approx 1 slash 3$],
    [$0,25 d$], [$0,0625$], [$0,0455$], [$approx 0,7$],
    [$0,35 d$], [$0,1225$], [$0,153$], [$approx 1,25$],
    table.hline(stroke: 0.6pt),
  )
]

La tabla tiene dos lecturas, y las dos importan:

+ *Cuando el ruido por paso es pequeño frente al margen, el redondeo es enormemente eficaz.* Con $sigma = 0,1 d$, el error discreto crece unas 17 000 veces más lento que el continuo. Es un efecto de *umbral*: la probabilidad de salto cae como la cola de una gaussiana, mucho más rápido que $sigma^2$.
+ *Cuando el ruido es comparable al margen, el redondeo empeora las cosas.* Desde $sigma approx 0,29 d$ (el cruce exacto), un salto discreto cuesta más que el ruido que reemplaza. Redondear convierte errores pequeños en saltos de un código completo.

La @fig:prob-exacta muestra la consecuencia sobre rollouts largos: la probabilidad de que el estado siga siendo correcto después de $T$ pasos.

#fig("f18_prob_exacta.svg")[Probabilidad de que el error después de $T$ pasos sea menor que $d slash 2$, calculada de forma exacta para el modelo del texto. En discreto, eso equivale a que el error sea exactamente cero. Con $sigma = 0,15 d$, el rollout discreto sigue siendo exacto con probabilidad cercana a 1 durante cientos de pasos; el continuo la pierde en decenas. Con $sigma = 0,25 d$, la ventaja casi desaparece.] <fig:prob-exacta>

Este modelo es deliberadamente simple, pero explica tres observaciones del capítulo IV:
- En Meyer et al., los modelos continuos fallan justamente en las transiciones *raras*, donde el modelo es menos preciso y el error se arrastra por los 30 pasos del rollout.
- La ventaja discreta *desaparece con modelos grandes*: un modelo grande tiene $sigma$ pequeño, y ambos rollouts se vuelven precisos.
- La cuarta hipótesis de DreamerV2, la de los aspectos "no suaves" del mundo: donde el mundo tiene saltos (entrar a una habitación), un estado continuo tiende a quedar "a medio camino", y el redondeo lo empuja a un lado o al otro.

#idea[Atractores de Hopfield][
  Una *red de Hopfield* #ct(<hopfield1982>) es una red neuronal cuya dinámica tiene unos pocos estados estables, los *atractores*, que funcionan como memorias. Si se la inicia con una versión ruidosa o incompleta de una memoria, la dinámica la lleva al atractor más cercano: la memoria completa. Es el redondeo implementado por una dinámica continua, y muestra que la corrección de errores no exige que todo el sistema sea discreto, sino que tenga *estados preferidos separados entre sí*.
]

Hay un detalle del modelo que conviene notar: con redondeo, la amplificación $L^T$ de la dinámica deja de importar mientras el error sea cero, porque un error nulo amplificado sigue siendo nulo. El redondeo *corta la cadena de amplificación* en cada paso. Solo cuando ocurre un salto la dinámica vuelve a jugar en contra.

Esta discusión es la primera mitad de la respuesta a la nota del profesor (_"accumulated errors =?= collapse"_). Aquí vimos cómo se acumula el error y cómo el redondeo lo detiene. En el capítulo VII veremos que el colapso aparece en el mismo tipo de bucle (una salida que vuelve a ser entrada u objetivo), pero en el régimen opuesto: cuando el bucle *contrae* demasiado.

== Localizar y contar: el error como evento

Las secciones anteriores trataban de *borrar* el error. Pero "seguir el error" también significa poder *decir dónde ocurrió*. Aquí la pieza que trabaja es la #pieza(6): en un espacio discreto, dos estados son iguales o no lo son.

Consideremos una cadena de pasos, como un programa que se ejecuta instrucción por instrucción o un rollout que avanza. Si cada estado intermedio es un código, se puede comparar *exactamente* con el estado correcto (@fig:localizar, arriba). El resultado de cada comparación es un sí o un no, y aparece algo que en continuo no existe: *el primer paso en que la cadena se equivocó*. El error deja de ser una cantidad difusa y pasa a ser un *evento*, con fecha y lugar.

#fig("f19_localizar.svg")[(a) En una cadena discreta, cada paso se compara exactamente con el correcto: el primer error ocurre en el paso 5, y los siguientes lo heredan. (b) En una cadena continua, todos los pasos tienen algo de error; para hablar de "un error" hay que elegir una tolerancia arbitraria, y no hay un paso culpable.] <fig:localizar>

En una cadena continua (@fig:localizar, abajo) todos los pasos tienen *algo* de error, y este crece de a poco. Para decir "aquí hubo un error" hay que elegir un umbral, y la respuesta cambia con el umbral. No hay un paso culpable, sino una responsabilidad repartida entre todos.

Tener eventos en vez de cantidades difusas habilita cuatro cosas concretas:
- *Depurar.* Si una ejecución falla, se puede buscar el primer paso incorrecto y estudiar por qué. Es lo que hace un programador, y es lo que permite que DreamCoder #ct(<ellis2021>) verifique un programa contra los ejemplos de forma exacta: el programa es correcto o no lo es.
- *Asignar crédito.* En el entrenamiento, se puede concentrar la corrección en el paso que falló en vez de repartirla entre todos.
- *Contar y predecir.* Si cada paso falla con probabilidad $p_t$ de forma independiente, la probabilidad de que una cadena de $T$ pasos salga perfecta es
  $ P("cadena correcta") = product_(t=1)^T (1 - p_t) approx e^(- sum_t p_t). $
  Eso permite *predecir* cómo cae el rendimiento al alargar las cadenas, por ejemplo al pedirle a NLI programas más largos que los de entrenamiento.
- *Medir.* Meyer et al. pudieron comparar distribuciones de estados del modelo y del entorno porque los estados de un laberinto son contables. En un espacio continuo, la misma comparación exige discretizar *para medir*.

Hay una quinta capacidad, más especulativa. En un VQ-VAE, la distancia entre la salida del codificador y su código más cercano, $norm(z_e - e_k)$, es una *alarma gratuita*: si es grande, la entrada no se parece a nada de lo que el modelo conoce. En principio, eso sirve para detectar situaciones nuevas #conj.

== El precio y los límites

Seguir el error no es gratis, y es importante tener claros sus límites:
- *Los errores silenciosos son catastróficos.* Cuando un error supera el margen, el sistema salta a otro código *con total confianza*. En continuo, un error grande al menos se ve grande. En discreto, un error grande puede verse como un estado perfectamente normal.
- *El error de cuantización es invisible.* Si el estado verdadero está *entre* dos códigos, el sistema siempre se equivoca hasta en $d slash 2$ y nunca lo detecta, porque la alarma solo suena para desvíos respecto de los códigos, no respecto de la verdad. Es el costo de la pieza #pieza(1) que vimos en MAR y en Garrido et al.
- *Hace falta margen, y el margen cuesta capacidad.* Más separación entre códigos significa menos códigos en el mismo espacio.
- *Solo funciona si el ruido por paso es menor que el margen.* El cruce de la tabla ($sigma approx 0,29 d$) es un límite duro: con un modelo impreciso, redondear empeora las cosas.

== ¿Es exclusivo de lo discreto?

Volvamos a lo que realmente hizo falta en cada caso:
+ que los estados válidos ocupen *solo una parte* del espacio, con margen entre ellos (redundancia);
+ una forma de *volver* a esa parte cuando uno se sale (proyección).

Lo discreto es la forma más simple de tener las dos cosas, pero no la única. Hay sistemas continuos que también las tienen:
- *Restricciones conocidas.* Si el estado debe cumplir una ley (conservar la energía, que una rotación tenga norma uno), cada predicción se puede proyectar de vuelta a la superficie de estados que la cumplen. Los errores perpendiculares a esa superficie se borran.
- *Atractores continuos.* Las redes de Hopfield son dinámicas continuas con estados preferidos separados.
- *Filtros que estiman su propio error.* El filtro de Kalman #ct(<kalman1960>) no borra el error, pero *lleva la cuenta* de cuán incierto está su estado y combina predicción y observación en consecuencia. Es "seguir el error" en el sentido de medirlo, a cambio de necesitar un modelo del ruido.

Lo que sí es más propio de lo discreto es la identidad exacta (pieza #pieza(6)): poder decir "este paso es correcto" sin elegir una tolerancia. Esto anticipa la respuesta del capítulo VI a la pregunta A1. El principio no parece ser "discretizar", sino *tener estados preferidos con margen y una forma de volver a ellos*, y la discretización es su versión más barata y extrema #conj.

#rel("Cómo explicarlo en dos minutos")[
  En un espacio continuo, estar un poco equivocado se ve igual que estar en otro estado legítimo, así que el error es invisible y se acumula en silencio. Al discretizar, solo unos pocos estados separados son válidos. Esto tiene tres consecuencias:
  - caer entre ellos *delata* el error;
  - volver al más cercano lo *borra*, si era pequeño;
  - como dos estados son iguales o distintos, se puede *señalar el paso* en que la cadena se equivocó y *contar* los errores.

  El precio es que un error grande se convierte en un salto a otro estado, con total confianza. Por eso el redondeo solo conviene cuando el ruido por paso es claramente menor que la mitad de la separación entre estados.
]

#llevamos[
  - "Seguir el error" son cuatro capacidades: detectar, corregir, localizar y contar. Todas dependen de que los estados válidos sean pocos y estén separados.
  - En una cadena, el redondeo transforma una acumulación de ruido ($"Var" = T sigma^2$) en saltos raros (probabilidad $2 overline(Phi)(d slash (2 sigma))$ por paso). Con ruido pequeño frente al margen la mejora es enorme; desde $sigma approx 0,29 d$ el redondeo empeora las cosas #est (resultado matemático del modelo simple).
  - Con estados discretos el error se vuelve un evento con fecha: permite depurar, asignar crédito, predecir el rendimiento en cadenas más largas y medir.
  - Los costos son los errores silenciosos, el error de cuantización invisible y el compromiso entre margen y capacidad.
  - Lo esencial no parece ser lo discreto, sino tener estados preferidos con margen y una proyección hacia ellos #conj.
]
