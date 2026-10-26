#import "/math_functions.typ": *
#import "/bloques.typ": *

#heading(numbering: none)[Glosario]

#set par(spacing: 0.8em)

/ Ablación: experimento que quita o cambia una sola pieza de un método para medir su aporte.
/ Atractor: estado estable de una dinámica, al que convergen los estados cercanos (redes de Hopfield).
/ Bootstrapping: usar las salidas del propio modelo como objetivo de entrenamiento (BYOL, JEPA).
/ Celda de Voronoi: región de puntos más cercanos a un código que a cualquier otro.
/ Código muerto: código de un diccionario que nunca es elegido y, por lo tanto, nunca se actualiza.
/ Colapso (del diccionario, posterior, completo, dimensional, neuronal): ver el capítulo VII.
/ Confusor: variable que cambia junto con la que se estudia y podría explicar el efecto por sí sola.
/ EMA: promedio móvil exponencial; en JEPA, forma de actualizar lentamente el codificador objetivo.
/ Entropía cruzada (CE): pérdida de clasificación; su óptimo es la distribución completa de resultados.
/ Error compuesto: error que crece al usar cada predicción como entrada de la siguiente.
/ Error silencioso: error tan grande que el redondeo lleva el estado a otro código válido sin detectarlo.
/ FSQ: cuantización que redondea cada coordenada a una grilla fija de niveles.
/ Identificabilidad: propiedad de un modelo en que valores distintos del latente producen datos distinguibles.
/ Margen: distancia entre representaciones que deben distinguirse, comparada con el ruido.
/ MSE: error cuadrático medio; su óptimo es el promedio de los resultados posibles.
/ One-hot: vector con un 1 en la posición de la categoría y 0 en el resto.
/ Perplejidad: $2^H$; número efectivo de códigos usados.
/ Pieza: cada uno de los seis cambios que trae la discretización (capítulo I).
/ Rollout: secuencia de estados imaginados por un modelo del mundo.
/ STE (_straight-through estimator_): redondear hacia adelante y copiar el gradiente hacia atrás.
/ Two-hot: representación de un número real como peso repartido entre dos intervalos vecinos.
/ VQ: cuantización vectorial; reemplazar un vector por el más cercano de un diccionario aprendido.
