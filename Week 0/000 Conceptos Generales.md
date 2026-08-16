# El concepto de One-Hot
## One-hot

Es un formato de representación de datos matemáticos mediante vectores binarios donde un único elemento tiene el valor 1 (activo o "hot") y todos los demás elementos tienen el valor 0 (inactivos o "cold").

## One-hot encoding

Es el proceso algorítmico de convertir datos categóricos en vectores **one-hot** para que puedan ser procesados por modelos de Machine Learning.

Para aplicarlo, se define un vector con una longitud igual al número total de categorías posibles. A cada categoría se le asigna un índice fijo.

**Ejemplo:**

Dado un conjunto de tres categorías: `[Rojo, Verde, Azul]`

- Rojo: `[1, 0, 0]`
- Verde: `[0, 1, 0]`
- Azul: `[0, 0, 1]`

## Multi-hot (o Multi-one-hot)

Es una variación del formato one-hot en la que múltiples elementos del vector binario pueden tener el valor 1 al mismo tiempo. Se utiliza para codificar datos que pertenecen a varias categorías simultáneamente (clasificación multietiqueta).

**Ejemplo:**

Dado un conjunto de géneros de cine: `[Acción, Terror, Comedia, Ciencia Ficción]`

- Una película que es exclusivamente de Terror: `[0, 1, 0, 0]` (Comportamiento one-hot
- Una película que es de Acción y Ciencia Ficción: `[1, 0, 0, 1]` (Comportamiento multi-hot)

# Síntesis de programas

Es la generación automática de un programa informático a partir de una especificación de alto nivel (como ejemplos de entrada/salida, lenguaje natural o reglas matemáticas), en lugar de requerir que un programador humano escriba el código paso a paso. El sistema deduce y construye la lógica necesaria para satisfacer las condiciones dadas.

## Refactorización vs. Síntesis
- **Síntesis de programas:** Genera código nuevo a partir de una necesidad o restricción. El flujo es de _especificación_ a _código_.
- **Refactorización:** Modifica la estructura interna de un código ya existente sin alterar su comportamiento externo. El flujo es de _código funcional_ a _código optimizado_.

# Sueño-Vigilia


