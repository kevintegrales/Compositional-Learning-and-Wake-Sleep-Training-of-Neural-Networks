"""Herramientas para preparar anotaciones al margen con motor.typ.

Requiere PyMuPDF (import fitz). Ejecutar con:  python -I herramientas.py <comando> ...

Comandos
--------
  info      <pdf>                         Tamaño de páginas, capa de texto, xr/xl sugeridos.
  lineas    <pdf> [paginas]               Líneas de texto con coordenadas (y0-y1, x0-x1).
                                          paginas: "3" | "1,4,7" | "2-5" | "1,3-6" (por defecto todas).
  cuadricula <pdf> <pagina> <salida.png>  Página con reglas horizontales cada 25 pt (para PDFs sin texto
                                          o ecuaciones que el OCR destroza).
  recorte   <pdf> <pagina> <x0> <y0> <x1> <y1> <salida.png> [dpi]
                                          Recorte de una zona (ver una ecuación con calma).
  revisar   <pdf_anotado> <carpeta> [dpi] Renderiza el PDF anotado en pares de páginas y avisa de
                                          las páginas con DESBORDE (notas que no caben).

Todas las coordenadas están en pt, con origen arriba-izquierda: son las mismas que usa motor.typ.
"""
import os
import sys

import fitz  # PyMuPDF

sys.stdout.reconfigure(encoding="utf-8")


def rango_paginas(txt, n):
    if not txt:
        return list(range(1, n + 1))
    out = []
    for parte in txt.split(","):
        if "-" in parte:
            a, b = parte.split("-")
            out += list(range(int(a), int(b) + 1))
        else:
            out.append(int(parte))
    return [p for p in out if 1 <= p <= n]


def lineas_de(pagina):
    filas = []
    for b in pagina.get_text("dict")["blocks"]:
        for l in b.get("lines", []):
            t = "".join(s["text"] for s in l["spans"]).strip()
            if t:
                filas.append((l["bbox"], t))
    filas.sort(key=lambda r: (round(r[0][1]), r[0][0]))
    return filas


def percentil(vals, q):
    if not vals:
        return None
    vals = sorted(vals)
    k = min(len(vals) - 1, max(0, int(round(q * (len(vals) - 1)))))
    return vals[k]


def sugerir_bordes(pagina):
    """Borde derecho/izquierdo típico del texto, usando solo líneas largas."""
    W = pagina.rect.width
    filas = lineas_de(pagina)
    largas = [bb for bb, t in filas if (bb[2] - bb[0]) > 0.4 * W]
    if len(largas) < 3:  # probablemente dos columnas
        largas = [bb for bb, t in filas if (bb[2] - bb[0]) > 0.25 * W]
    if not largas:
        return None, None
    der = percentil([bb[2] for bb in largas], 0.9)
    izq = percentil([bb[0] for bb in largas], 0.1)
    return round(der + 4), round(izq)


def cmd_info(pdf):
    d = fitz.open(pdf)
    print(f"{pdf}: {d.page_count} páginas")
    tamanos = {}
    for i, p in enumerate(d):
        clave = (round(p.rect.width, 2), round(p.rect.height, 2))
        tamanos.setdefault(clave, []).append(i + 1)
    for (w, h), pags in tamanos.items():
        print(f"  W = {w}, H = {h}  -> páginas {pags[0]}..{pags[-1]} ({len(pags)})")
    p0 = d[0]
    if p0.cropbox != p0.mediabox:
        print(f"  ojo: cropbox {p0.cropbox} != mediabox {p0.mediabox} (verifica la alineación con una prueba)")
    print("  página | palabras | xr sugerido | xl sugerido")
    for i, p in enumerate(d):
        nw = len(p.get_text("words"))
        xr, xl = sugerir_bordes(p)
        aviso = "  <- sin capa de texto: usa 'cuadricula' u OCR" if nw == 0 else ""
        print(f"  {i + 1:6d} | {nw:8d} | {str(xr):>11} | {str(xl):>11}{aviso}")


def cmd_lineas(pdf, paginas=None):
    d = fitz.open(pdf)
    for pn in rango_paginas(paginas, d.page_count):
        p = d[pn - 1]
        xr, xl = sugerir_bordes(p)
        print(f"===== PÁGINA {pn}  (W={p.rect.width:.2f}, H={p.rect.height:.2f}, xr≈{xr}, xl≈{xl})")
        for bb, t in lineas_de(p):
            print(f"{bb[1]:5.0f}-{bb[3]:4.0f}  x{bb[0]:4.0f}-{bb[2]:4.0f} | {t[:80]}")


def cmd_cuadricula(pdf, pagina, salida, dpi=110):
    d = fitz.open(pdf)
    p = d[int(pagina) - 1]
    W, H = p.rect.width, p.rect.height
    out = fitz.open()
    q = out.new_page(width=W + 30, height=H)
    q.show_pdf_page(fitz.Rect(30, 0, W + 30, H), d, int(pagina) - 1)
    y = 0
    while y <= H:
        grueso = y % 100 == 0
        q.draw_line((30, y), (W + 30, y), color=(1, 0, 0) if grueso else (1, 0.6, 0.6), width=0.5 if grueso else 0.25)
        q.insert_text((2, y + 3), str(int(y)), fontsize=6, color=(0.8, 0, 0))
        y += 25
    q.get_pixmap(dpi=dpi).save(salida)
    print(f"guardado {salida} (las x del original están corridas 30 pt a la derecha en la imagen)")


def cmd_recorte(pdf, pagina, x0, y0, x1, y1, salida, dpi=150):
    d = fitz.open(pdf)
    r = fitz.Rect(float(x0), float(y0), float(x1), float(y1))
    d[int(pagina) - 1].get_pixmap(dpi=int(dpi), clip=r).save(salida)
    print(f"guardado {salida}")


def cmd_revisar(pdf, carpeta, dpi=60):
    os.makedirs(carpeta, exist_ok=True)
    src = fitz.open(pdf)
    n = src.page_count
    malas = [i + 1 for i, p in enumerate(src) if "DESBORDE" in p.get_text()]
    for k in range(0, n, 2):
        w, h = src[k].rect.width, src[k].rect.height
        out = fitz.open()
        q = out.new_page(width=2 * w, height=h)
        q.show_pdf_page(fitz.Rect(0, 0, w, h), src, k)
        if k + 1 < n:
            q.show_pdf_page(fitz.Rect(w, 0, 2 * w, h), src, k + 1)
        q.get_pixmap(dpi=int(dpi)).save(os.path.join(carpeta, f"par_{k + 1:03d}.png"))
    print(f"{n} páginas renderizadas en {carpeta}")
    print("DESBORDE en páginas:", malas if malas else "ninguna")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    cmd, args = sys.argv[1], sys.argv[2:]
    {
        "info": cmd_info,
        "lineas": cmd_lineas,
        "cuadricula": cmd_cuadricula,
        "recorte": cmd_recorte,
        "revisar": cmd_revisar,
    }[cmd](*args)
