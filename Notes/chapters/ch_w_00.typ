// Funciones
#import "/math_functions.typ": *
#import "/notalmar.typ": *
#include "/notalmar.typ"

== Introducción y Definiciones Básicas

=== Lenguaje Formal
Un *lenguaje formal* es un conjunto de cadenas formadas a partir de un conjunto finito de símbolos, estructuradas de acuerdo a reglas específicas.

- *Notación:* Sea un alfabeto $Sigma$ (un conjunto finito de símbolos, por ejemplo, ${0, 1}$). El cierre de Kleene, $Sigma^*$, denota el conjunto de todas las cadenas finitas posibles formadas con símbolos de $Sigma$. Un lenguaje formal $L$ es cualquier subconjunto de $Sigma^*$, es decir, $L subset.eq Sigma^*$. Si $x$ es una cadena que pertenece al lenguaje, se escribe $x in L$.

Para investigar la complejidad de Kolmogorov con aplicaciones en el aprendizaje composicional y el algoritmo wake-sleep, los siguientes conceptos son fundamentales:

=== Máquina de Turing (y Computabilidad)
Define rigurosamente qué significa que una función sea computable. En complejidad de Kolmogorov, la descripción de un objeto se evalúa como la entrada a una máquina de Turing. El aprendizaje composicional se modela como la inferencia de subrutinas o primitivas computables.

- *Notación:* $U(p) = x$. Indica que la máquina de Turing universal $U$, al recibir el programa (o descripción) $p$, computa y produce la salida $x$. El tiempo de ejecución se acota mediante $U^t (p) = x$, donde $t$ es el número máximo de pasos.

=== Entropía de Shannon (Teoría de la Información)
Mide la incertidumbre o la cantidad de información esperada de una variable aleatoria que sigue una distribución de probabilidad. A diferencia de la complejidad de Kolmogorov, que mide la información contenida en un objeto algorítmico individual, la entropía de Shannon asume un modelo probabilístico subyacente. El aprendizaje wake-sleep busca codificar información acercándose a este límite.

- *Notación:* $H(X) = - sum_(x in cal(X)) P(x) log_2 P(x)$, donde $X$ es una variable aleatoria con un conjunto de posibles resultados $cal(X)$ y función de masa de probabilidad $P(x)$.

=== Principio de Longitud de Descripción Mínima (MDL)
Es un método de inferencia estadística que postula que la mejor hipótesis (o modelo) para un conjunto de datos es la que permite la compresión de esos datos. Constituye un puente práctico entre la complejidad de Kolmogorov (incomputable) y el aprendizaje automático, útil en el aprendizaje composicional para seleccionar representaciones compactas y modulares.

- *Notación:* El objetivo es encontrar una hipótesis $H$ dentro de un espacio de hipótesis $cal(H)$ que minimice $L(H) + L(D|H)$. Aquí, $L(H)$ es la longitud en bits para describir el modelo, y $L(D|H)$ es la longitud para describir los datos $D$ dado el modelo $H$.

=== Probabilidad Algorítmica (Distribución de Solomonoff)
Asigna una probabilidad a priori a una cadena basándose en la longitud del programa más corto que la genera. Conecta la teoría de la computación con la inferencia inductiva. En modelos generativos y de aprendizaje, relaciona por qué las representaciones más simples son estadísticamente probables.

- *Notación:* $M(x) = sum_(p: U(p)=x) 2^(-|p|)$. La probabilidad universal $M(x)$ de una cadena $x$ es la suma de las probabilidades de todos los programas $p$ (con la propiedad de ser libres de prefijo) cuya ejecución en $U$ produce $x$, siendo $|p|$ la longitud del programa.

=== Inferencia Bayesiana y Divergencia Kullback-Leibler (KL)
El paradigma wake-sleep involucra un modelo generativo (sleep) y un modelo de reconocimiento o inferencia (wake). Estos modelos se optimizan minimizando una medida de distancia entre la distribución de probabilidad generada y la distribución inferida a partir de los datos.

- *Notación Bayesiana:* $P(Z|X) = (P(X|Z)P(Z)) / P(X)$, donde $Z$ representa las variables latentes (las representaciones composicionales ocultas) y $X$ los datos observables.
- *Notación Divergencia KL:* $D_"KL"(Q || P) = sum_(z in cal(Z)) Q(z|x) log( (Q(z|x)) / (P(z|x)) )$. En el contexto de wake-sleep, se busca minimizar la divergencia entre la distribución aproximada de inferencia $Q(z|x)$ y la distribución posterior $P(z|x)$ del modelo generativo.

=== Encoders y Autoencoders

VAEs

== Reinforcement Learning

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

