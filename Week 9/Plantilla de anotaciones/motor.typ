// =====================================================================
//  MOTOR DE ANOTACIONES AL MARGEN  (plantilla reutilizable)
//  Requiere Typst >= 0.14 (incrusta páginas PDF con image(..., page: k)).
//
//  Idea: cada página del PDF original se incrusta intacta (vectorial) y se
//  le agrega un margen (derecho y/o izquierdo) con notas. Cada nota se ancla
//  a un rango vertical [y0, y1] del original (en pt, origen arriba-izquierda,
//  las mismas coordenadas que entrega PyMuPDF) y opcionalmente a un
//  rectángulo r = (x0, y0, x1, y1) que se enmarca.
//  Ver GUIA.pdf para el flujo completo.
// =====================================================================

#let fuente-notas-base = ("Segoe UI", "Arial", "New Computer Modern")

// ---------- Tipos de nota (color + rótulo + descripción para la leyenda) ----------
// Para crear tipos nuevos, NO edites esto: en tu archivo haz
//   #let mis-tipos = tipos-base + (nombre: (color: rgb("#0f766e"), rotulo: "DEF", desc: [...]))
// y pásalo como `tipos: mis-tipos`.
#let tipos-base = (
  apunte: (color: rgb("#1f4e79"), rotulo: "APUNTE", desc: [Dónde está explicado en el material de apoyo (sección o etiqueta).]),
  ejercicio: (color: rgb("#2e6b30"), rotulo: "EJERCICIO", desc: [Algo que el lector ya demostró o debe demostrar.]),
  cuidado: (color: rgb("#b5530f"), rotulo: "CUIDADO", desc: [Trampas de notación, errores del texto o diferencias de convención.]),
  idea: (color: rgb("#5b2a86"), rotulo: "IDEA", desc: [Interpretación, intuición o conexión entre partes.]),
  extra: (color: rgb("#5a5a5a"), rotulo: "EXTRA", desc: [Profundización o algo que se puede saltar.]),
)

// ---------- Una nota ----------
// y0, y1 : rango vertical del pasaje en el original (pt).
// tipo   : clave de `tipos` (string).
// cuerpo : contenido Typst (admite $matemática$, *negrita*, etc.).
// r      : rectángulo (x0, y0, x1, y1) a enmarcar, o none.
// lado   : "der" (margen derecho, por defecto) o "izq" (requiere ML > 0 y xl).
#let n(y0, y1, tipo, cuerpo, r: none, lado: "der") = (
  y0: y0, y1: y1, tipo: tipo, cuerpo: cuerpo, r: r, lado: lado,
)

#let ficha(num, col, fuente) = box(
  width: 8.6pt, height: 8.6pt, radius: 4.3pt, fill: col, baseline: 1.6pt,
  align(center + horizon, text(font: fuente, size: 5.6pt, fill: white, weight: "bold", str(num))),
)

// Posiciona cajas de alto conocido: primero hacia abajo sin superponer,
// luego hacia arriba si la última se pasa del borde inferior.
#let _colocar(cajas, H, gap) = {
  let tops = ()
  let prev = 6pt - gap
  for c in cajas {
    let t = calc.max(c.x.y0 * 1pt - 3pt, prev + gap)
    tops.push(t)
    prev = t + c.h
  }
  let lim = H * 1pt - 6pt
  for i in range(cajas.len() - 1, -1, step: -1) {
    let t = calc.min(tops.at(i), lim - cajas.at(i).h)
    tops.at(i) = t
    lim = t - gap
  }
  tops
}

// Carriles: barras de anclas que se superponen se corren lateralmente.
#let _carriles(cajas) = {
  let carriles = ()
  for (i, c) in cajas.enumerate() {
    let k = 0
    for j in range(i) {
      if cajas.at(j).x.y1 > c.x.y0 and carriles.at(j) == k { k += 1 }
    }
    carriles.push(k)
  }
  carriles
}

// ---------- Una página anotada ----------
// src  : ruta al PDF original (absoluta desde --root, p. ej. "/papers/x.pdf").
// num  : número de página (1 = primera).
// notas: arreglo de n(...).
// W, H : tamaño de la página original en pt (lo entrega herramientas.py).
// xr   : x (pt) donde van las barras del margen derecho: borde derecho del texto + 4.
// M    : ancho del margen derecho agregado (pt). ML: margen izquierdo (0 = sin él).
// xl   : x (pt) del borde izquierdo del texto, para notas con lado: "izq".
#let hoja(
  src, num, notas,
  W: none, H: none, xr: none, M: 230, ML: 0, xl: none,
  tipos: tipos-base, fuente: fuente-notas-base, tam: 7.3pt,
  fondo: luma(97%), gap: 4pt,
) = {
  assert(W != none and H != none and xr != none, message: "hoja(): faltan W, H o xr")
  page(width: (ML + W + M) * 1pt, height: H * 1pt, margin: 0pt, header: none, footer: none)[
    #place(dx: ML * 1pt, image(src, page: num, width: W * 1pt, height: H * 1pt))
    #if M > 0 {
      place(dx: (ML + W) * 1pt, rect(width: M * 1pt, height: H * 1pt, fill: fondo, stroke: none))
      place(line(start: ((ML + W) * 1pt, 0pt), end: ((ML + W) * 1pt, H * 1pt), stroke: 0.5pt + luma(78%)))
    }
    #if ML > 0 {
      place(rect(width: ML * 1pt, height: H * 1pt, fill: fondo, stroke: none))
      place(line(start: (ML * 1pt, 0pt), end: (ML * 1pt, H * 1pt), stroke: 0.5pt + luma(78%)))
    }
    #context {
      let ns = notas.sorted(key: x => x.y0)
      let todas = ns.enumerate().map(((i, x)) => {
        if x.tipo not in tipos {
          panic("Tipo de nota desconocido: '" + x.tipo + "'. Disponibles: " + tipos.keys().join(", "))
        }
        if x.lado == "izq" and (ML <= 0 or xl == none) {
          panic("Nota con lado: \"izq\" en la página " + str(num) + ", pero falta ML > 0 o xl")
        }
        let t = tipos.at(x.tipo)
        let ancho = if x.lado == "izq" { (ML - 15) * 1pt } else { (M - 15) * 1pt }
        let b = block(
          width: ancho, inset: (left: 5pt, right: 4pt, y: 3.6pt),
          fill: t.color.lighten(91%), stroke: (left: 1.8pt + t.color), radius: (right: 1.5pt),
        )[
          #set text(font: fuente, size: tam)
          #set par(justify: false, leading: 0.42em, spacing: 0.55em)
          #ficha(i + 1, t.color, fuente) #text(fill: t.color, weight: "bold", size: tam - 1.1pt)[#t.rotulo] #h(1pt)
          #x.cuerpo
        ]
        (b: b, h: measure(b).height, col: t.color, x: x, num: i + 1)
      })
      for lado in ("der", "izq") {
        let cajas = todas.filter(c => c.x.lado == lado)
        if cajas.len() == 0 { continue }
        let tops = _colocar(cajas, H, gap)
        if tops.at(0) < 2pt {
          let xd = if lado == "der" { (ML + W + 8) * 1pt } else { 8pt }
          place(dx: xd, dy: 0pt, text(fill: red, size: 6pt)[DESBORDE])
        }
        let carriles = _carriles(cajas)
        for (i, c) in cajas.enumerate() {
          let x = c.x
          let y0 = x.y0 * 1pt
          let alto = calc.max(x.y1 - x.y0, 5) * 1pt
          let ym = y0 + alto / 2
          if x.r != none {
            let (a, b, cc, d) = x.r
            place(dx: (ML + a) * 1pt - 2pt, dy: b * 1pt - 2pt, rect(
              width: (cc - a) * 1pt + 4pt, height: (d - b) * 1pt + 4pt,
              stroke: 0.7pt + c.col, fill: c.col.transparentize(92%), radius: 2pt,
            ))
          }
          if lado == "der" {
            let xb = (ML + xr) * 1pt + carriles.at(i) * 4.5pt
            let xn = (ML + W + 8) * 1pt
            place(dx: xb, dy: y0, rect(width: 2.2pt, height: alto, fill: c.col, stroke: none))
            place(dx: xb + 3.2pt, dy: y0 - 1pt, ficha(c.num, c.col, fuente))
            place(line(start: (xb + 2.2pt, ym), end: (xn, tops.at(i) + 5pt), stroke: 0.45pt + c.col))
            place(dx: xn, dy: tops.at(i), c.b)
          } else {
            let xb = (ML + xl) * 1pt - 4.2pt - carriles.at(i) * 4.5pt
            let xn = 8pt
            place(dx: xb, dy: y0, rect(width: 2.2pt, height: alto, fill: c.col, stroke: none))
            place(dx: xb - 11.8pt, dy: y0 - 1pt, ficha(c.num, c.col, fuente))
            place(line(start: (xb, ym), end: (xn + (ML - 15) * 1pt, tops.at(i) + 5pt), stroke: 0.45pt + c.col))
            place(dx: xn, dy: tops.at(i), c.b)
          }
        }
      }
    }
  ]
}

// ---------- Atajo: fija los parámetros de un documento una sola vez ----------
// #let pag = anotador("/x.pdf", W: 504, H: 705.28, xr: 433)
// #pag(3, (n(...), ...))            // usa los valores fijados
// #pag(5, (...), xr: 380)           // y se pueden cambiar por página
#let anotador(src, ..fijos) = (num, notas, ..cambios) => hoja(
  src, num, notas, ..(fijos.named() + cambios.named()),
)

// ---------- Leyenda y portada ----------
#let leyenda(tipos: tipos-base, fuente: fuente-notas-base) = {
  set text(font: fuente, size: 8pt)
  grid(
    columns: (auto, 1fr), row-gutter: 5pt, column-gutter: 6pt,
    ..tipos.pairs().map(((k, t)) => (
      box[#box(width: 7pt, height: 7pt, fill: t.color, radius: 1pt) #h(3pt) *#t.rotulo*],
      t.desc,
    )).flatten(),
  )
}

// Portada del mismo tamaño que las páginas anotadas.
// `cuerpo`: texto libre de introducción; `derecha`: contenido para la columna
// derecha (p. ej. una tabla de etiquetas del material de apoyo) o none.
#let portada(
  titulo, subtitulo, cuerpo,
  W: none, H: none, M: 230, ML: 0,
  tipos: tipos-base, fuente: fuente-notas-base,
  encabezado: [Anotaciones al margen], derecha: none, color: rgb("#1f4e79"),
) = page(
  width: (ML + W + M) * 1pt, height: H * 1pt, margin: (x: 42pt, y: 40pt), header: none, footer: none,
)[
  #set text(font: fuente, size: 9pt)
  #set par(justify: false, leading: 0.55em)
  #text(size: 8.5pt, fill: color, weight: "bold")[#encabezado]
  #v(4pt)
  #text(size: 20pt, weight: "bold")[#titulo]
  #v(2pt)
  #text(size: 11pt)[#subtitulo]
  #v(6pt)
  #line(length: 100%, stroke: 0.7pt + color)
  #v(4pt)
  #let izquierda = [
    #cuerpo
    #v(6pt)
    *Colores de las notas*
    #v(3pt)
    #leyenda(tipos: tipos, fuente: fuente)
    #v(8pt)
    *Cómo leer.* Cada nota tiene un número. El mismo número aparece junto a una *barra de color* al lado del pasaje del original, y una línea fina las une. Si la nota se refiere a una ecuación o figura precisa, esta aparece *enmarcada* con el mismo color.
  ]
  #if derecha == none { izquierda } else {
    grid(columns: (1fr, 1fr), column-gutter: 22pt, izquierda, derecha)
  }
]
