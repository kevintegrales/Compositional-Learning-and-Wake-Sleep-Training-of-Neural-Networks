#import "/math_functions.typ": *
#import "/bloques.typ": *

#frase[Discretizar no es un solo cambio, sino varios a la vez; para entender por qué ayuda (o perjudica) hay que separar esos cambios y preguntarse cuál de ellos necesita cada problema.]

== La pregunta, y por qué está mal planteada

En el curso vimos un caso que parecía resolver la cuestión. LPN #ct(<macfarlane2025>) representa un programa como un punto en un espacio continuo y lo busca por gradiente. NLI #ct(<macfarlane2026>), de casi los mismos autores, aprende un vocabulario discreto de operaciones, las encadena en secuencias y generaliza mucho mejor a combinaciones nuevas. La conclusión tentadora es "lo discreto generaliza mejor".

Pero NLI no cambia una sola cosa respecto de LPN. Sus símbolos son discretos, *y además* sus programas tienen largo variable, *y además* el decodificador es un intérprete que lee símbolo por símbolo. Cualquiera de esos cambios podría explicar la mejora. Por eso, en el reporte de la semana 9 quedó anotada una duda: ¿es necesariamente el discretizar lo que mejora los algoritmos, o es algún principio subyacente que la discretización pone en práctica?

Este capítulo toma esa duda en serio. La tesis es que la pregunta "¿discreto o continuo?" está mal planteada, porque "discretizar" no nombra una intervención, sino un paquete de intervenciones que casi siempre viajan juntas.

== El paquete

Pensemos en lo más simple: un codificador produce un vector continuo $z in RR^d$, y un cuantizador $q$ lo reemplaza por uno de $K$ códigos posibles (@fig:paquete). ¿Qué cambió? Al menos seis cosas:

#fig("f01_paquete.svg")[Las seis piezas que cambian a la vez al discretizar. A lo largo del capítulo, cada resultado de la literatura se atribuye a una (o a varias) de estas piezas.] <fig:paquete>

+ #pieza(1) *Capacidad.* Un código de $K$ entradas lleva como máximo $log_2 K$ bits. Un vector continuo, en principio, puede llevar muchos más. Discretizar impone un cuello de botella de información.
+ #pieza(2) *Geometría.* El código se puede entregar a la red siguiente como un vector _one-hot_ (todos los códigos a la misma distancia) o como el vector del diccionario que le corresponde (códigos cercanos y lejanos). No es un detalle: veremos que cambia los resultados.
+ #pieza(3) *Pérdida.* Si lo que se predice es un código, la pérdida natural es la entropía cruzada (clasificar) y no el error cuadrático (regresionar). Son problemas de optimización distintos.
+ #pieza(4) *Elegir entre modos.* Un predictor que entrega una distribución sobre códigos puede repartir probabilidad entre futuros distintos. Uno que entrega un vector tiende a entregar su promedio.
+ #pieza(5) *Redondeo.* Al proyectar al código más cercano, un error pequeño desaparece. Esto es lo que permite _seguir_ el error, la idea a la que dedicamos el capítulo V.
+ #pieza(6) *Identidad exacta.* Dos estados son el mismo código o no lo son. Eso permite enumerar, reutilizar, comparar y componer, cosas que en un espacio continuo requieren elegir una tolerancia arbitraria.

Cuando un paper reporta que "discretizar mejoró el resultado", casi nunca dice cuál de las seis piezas fue la responsable, porque cambió las seis a la vez. Separarlas es justamente lo que pide la pregunta P3, y es la condición para responder la pregunta A1: si cada beneficio se puede atribuir a una pieza, y cada pieza se puede conseguir por otra vía, entonces el principio no es "discretizar", sino lo que la pieza hace.

#pensar[Antes de seguir, ¿cuál de las seis piezas crees que explica mejor la diferencia entre LPN y NLI? Vale la pena anotar la respuesta y revisarla al final del capítulo VI.]

== Cómo usamos la evidencia

El profesor compartió un documento generado con IA que reúne pros y contras de las representaciones discretas en modelos del mundo #ct(<petrache2026>). Es útil como catálogo, pero no tiene hilo: enumera resultados de papers distintos sin decir qué mecanismo explica cada uno. Aquí lo usamos como materia prima. Cada pro y cada contra se lee como evidencia sobre una pieza del paquete, y cada paper como un experimento que aísla, o no, esa pieza.

Además, revisamos los números del documento contra los papers originales. Casi todos son correctos, con una excepción que señalamos en su lugar: el _rotation trick_ mejora el FID de reconstrucción de VQGAN de 5,0 a 1,1, y no a 1,6 como dice el documento.

La @fig:mapa muestra el recorrido. Los capítulos II y III dan las herramientas. El IV reúne la evidencia empírica. El V desarrolla en detalle una de las piezas, el redondeo, y la idea de "seguir el error". El VI intenta atribuir los efectos a las piezas. El VII trata los costos (los distintos tipos de colapso) y su relación con el error acumulado. El VIII revisa la familia JEPA, y el IX condensa todo en criterios para decidir cuándo discretizar.

#fig("f02_mapa.svg")[Mapa del capítulo. Debajo de cada capítulo aparecen las preguntas que responde (ver la tabla de la guía de lectura).] <fig:mapa>

#llevamos[
  - "Discretizar" cambia al menos seis cosas a la vez: capacidad, geometría, pérdida, elección entre modos, redondeo e identidad exacta.
  - La pregunta útil no es "¿discreto o continuo?", sino "¿qué pieza necesita este problema, y se puede obtener sin las demás?".
  - El documento del profesor se lee como un catálogo de evidencia; nuestro trabajo es darle un hilo, atribuyendo cada resultado a una pieza.
]
