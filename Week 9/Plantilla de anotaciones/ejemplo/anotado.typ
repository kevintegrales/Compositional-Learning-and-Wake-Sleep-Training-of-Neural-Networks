// Ejemplo completo de uso del motor. Compilar desde la carpeta de la plantilla:
//   tinymist compile --root . ejemplo/anotado.typ ejemplo/anotado.pdf
#import "../motor.typ": *

#set document(title: "Ejemplo anotado")

// 1) Tipos de nota: los cinco de base + uno nuevo + un color cambiado.
#let mis-tipos = tipos-base + (
  definicion: (color: rgb("#0f766e"), rotulo: "DEFINICIÓN", desc: [Definiciones que conviene memorizar.]),
)
#mis-tipos.at("cuidado").insert("color", rgb("#c2410c"))

// 2) Datos del PDF original (salen de `python -I herramientas.py info ejemplo/original.pdf`).
#let src = "/ejemplo/original.pdf"
#let W = 612
#let H = 792
#let pag = anotador(src, W: W, H: H, xr: 547, M: 230, tipos: mis-tipos)

// 3) Portada (opcional).
#portada(
  [Toy paper, anotado], [_A Short Note on Energy Decay for the Heat Equation_],
  [Ejemplo de la plantilla. La página 1 usa solo el margen derecho; la página 2 (a dos columnas) usa ambos márgenes.],
  W: W, H: H, M: 230, tipos: mis-tipos,
)

// 4) Página 1: una columna, notas a la derecha.
#pag(1, (
  n(133, 171, "idea")[El resumen ya contiene toda la estrategia: *identidad de energía* + *Poincaré* ⇒ decaimiento.],
  n(223, 240, "definicion", r: (190, 223, 420, 240))[Ecuación del calor con datos de Dirichlet homogéneos: $u = 0$ en ambos extremos.],
  n(266, 299, "definicion", r: (245, 266, 365, 299))[Energía: $E = 1/2 norm(u)_(L^2)^2$.],
  n(351, 385, "ejercicio", r: (205, 351, 405, 385))[Integra por partes tú mismo: $integral u u'' = [u u'] - integral (u')^2$.],
  n(391, 409, "cuidado")[El término de borde se anula *solo* por los datos de Dirichlet; con condiciones de Neumann también, pero con datos no nulos no.],
  n(430, 455, "apunte")[Poincaré óptima con constante $(pi slash L)^2$.],
  n(456, 471, "extra", r: (235, 456, 378, 471))[El factor 2 viene de que $E$ es *la mitad* de la norma al cuadrado.],
))

// 5) Página 2: dos columnas. Margen izquierdo para la columna izquierda.
#pag(2, (
  n(89, 130, "idea", lado: "izq")[Cota óptima: la alcanza el primer modo propio.],
  n(136, 175, "extra", lado: "izq")[En varias dimensiones se usa el teorema de la divergencia.],
  n(89, 115, "cuidado")[Aquí $w$ es *constante* ($partial_x w = 0$); en general basta $op("div") bold(w) = 0$.],
  n(123, 150, "ejercicio", r: (358, 123, 498, 150))[Comprueba la igualdad: $u u' = 1/2 (u^2)'$.],
  n(163, 188, "idea")[El transporte redistribuye energía pero no la crea.],
), xr: 550, ML: 150, xl: 72)
