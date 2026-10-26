"""Arma el EPUB del capítulo a partir de la exportación HTML de Typst.

Pasos previos (desde la carpeta Week 10):
    tinymist compile --root . --input formato=html epub.typ epub/libro.html
    tinymist compile --root . main.typ main.pdf        (la portada sale de aquí)
Uso:
    python epub/construir_epub.py

Qué hace:
- Rasteriza cada ecuación (SVG de `html.frame`) a PNG, porque los Kindle no
  muestran MathML ni SVG en línea de forma confiable.
- Usa las figuras en PNG de `figures/png`.
- Divide el libro en un archivo por capítulo y genera la navegación.
"""

import hashlib
import os
import re
import shutil
import uuid
import zipfile
from datetime import datetime, timezone

import fitz  # PyMuPDF
from bs4 import BeautifulSoup

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.dirname(AQUI)
HTML = os.path.join(AQUI, "libro.html")
PDF = os.path.join(RAIZ, "main.pdf")
FIGURAS = os.path.join(RAIZ, "figures", "png")
SALIDA = os.path.join(RAIZ, "discretizacion.epub")

TITULO = "¿Qué gana y qué pierde un modelo al discretizar?"
AUTOR = "Kevin Cardemil Ulloa"
TAM_TEXTO_PT = 11.0   # tamaño de letra con que Typst compuso las ecuaciones
DPI_ECUACION = 300

CSS = """
@charset "utf-8";
body { font-family: serif; line-height: 1.45; margin: 0 0.4em; color: #1a1a1a; }
h1 { font-size: 1.6em; font-weight: normal; margin: 1.6em 0 0.2em; line-height: 1.2; }
h1 .num { display: block; font-size: 0.55em; letter-spacing: 0.15em; color: #b5467a;
          font-variant: small-caps; margin-bottom: 0.3em; }
h1 + hr { border: 0; border-top: 2px solid #f4c2d4; width: 30%; margin: 0 0 1.4em 0; }
h2 { font-size: 1.2em; margin: 1.5em 0 0.5em; }
h2 .num { color: #b5467a; margin-right: 0.4em; }
h3 { font-size: 1.05em; font-style: italic; font-weight: normal; margin: 1.2em 0 0.4em; }
p { margin: 0 0 0.7em; text-align: justify; }
a { color: #b5467a; text-decoration: none; }
img.eq { vertical-align: middle; margin: 0; padding: 0; }
div.eq-bloque { text-align: center; margin: 0.8em 0; }
div.eq-bloque img { max-width: 100%; }
figure { margin: 1.2em 0; text-align: center; }
img.figura { max-width: 100%; }
figcaption { font-size: 0.85em; text-align: left; margin-top: 0.4em; }
figcaption .rot { color: #b5467a; font-weight: bold; }
table { border-collapse: collapse; margin: 1em 0; font-size: 0.85em; width: 100%; }
th { border-bottom: 1px solid #1a1a1a; text-align: left; padding: 0.2em 0.4em; }
td { border-bottom: 1px solid #eeeeee; padding: 0.2em 0.4em; vertical-align: top; }
p.titulo-caja { font-variant: small-caps; font-weight: bold; margin: 0 0 0.3em; text-align: left; }
div.idea { background: #f6f6f6; border-left: 3px solid #1a1a1a; padding: 0.6em 0.8em; margin: 1em 0; }
div.llevamos { background: #fdf1f5; border: 1px solid #f4c2d4; padding: 0.6em 0.8em; margin: 1.2em 0; }
div.llevamos p.titulo-caja, div.frase p.titulo-caja, div.pensar p.titulo-caja { color: #b5467a; }
div.frase { border-top: 1px solid #f4c2d4; border-bottom: 1px solid #f4c2d4; padding: 0.5em 0.2em; margin: 0.5em 0 1.3em; }
div.pensar { border-left: 3px solid #f4c2d4; padding: 0.3em 0.8em; margin: 1em 0; }
div.destacado { border: 1px solid #1a1a1a; margin: 1.2em 0; }
div.destacado p.titulo-caja { background: #f4c2d4; padding: 0.3em 0.7em; margin: 0; font-variant: normal; }
div.destacado > *:not(.titulo-caja) { margin-left: 0.7em; margin-right: 0.7em; }
div.respuesta { border-left: 3px solid #f4c2d4; padding: 0.3em 0.8em; margin: 1em 0; }
div.respuesta p.titulo-caja { font-variant: normal; }
div.fuente { font-size: 0.85em; color: #5c5c5c; border-left: 1px solid #d9d9d9; padding-left: 0.6em; margin: 0.4em 0 1em; }
div.ficha { border-top: 1px solid #1a1a1a; border-bottom: 1px solid #1a1a1a; margin: 1em 0; }
div.ficha table { margin: 0.3em 0; }
div.ficha td { border: 0; }
/* Sin texto blanco sobre fondo oscuro: si un lector ignora el fondo, el texto sigue visible */
span.pieza { font-size: 0.8em; font-weight: bold; border: 1px solid #1a1a1a; padding: 0 0.3em;
             border-radius: 0.7em; }
span.etiqueta { font-variant: small-caps; font-size: 0.85em; padding: 0 0.3em; border-radius: 0.6em; }
span.establecido { border: 1px solid #1a1a1a; font-weight: bold; }
span.sugerido { background: #f4c2d4; border: 1px solid #f4c2d4; }
span.conjetura { border: 1px solid #b5467a; color: #b5467a; }
dl dt { font-weight: bold; margin-top: 0.4em; }
dl dd { margin-left: 1em; }
"""


def rasterizar_ecuaciones(html, carpeta):
    """Reemplaza cada <svg> por un marcador y guarda el PNG correspondiente."""
    os.makedirs(carpeta, exist_ok=True)
    cache, info = {}, []

    def reemplazar(m):
        svg = m.group(0)
        clave = hashlib.sha1(svg.encode("utf-8")).hexdigest()[:12]
        if clave not in cache:
            alto_pt = float(re.search(r'height="([\d.]+)pt"', svg).group(1))
            ancho_pt = float(re.search(r'width="([\d.]+)pt"', svg).group(1))
            doc = fitz.open(stream=svg.encode("utf-8"), filetype="svg")
            pix = doc[0].get_pixmap(dpi=DPI_ECUACION, alpha=True)
            nombre = f"e_{clave}.png"
            pix.save(os.path.join(carpeta, nombre))
            cache[clave] = (nombre, alto_pt, ancho_pt)
        nombre, alto_pt, ancho_pt = cache[clave]
        info.append(nombre)
        return (f'<img data-eq="{nombre}" data-alto="{alto_pt / TAM_TEXTO_PT:.3f}" '
                f'data-ancho="{ancho_pt / TAM_TEXTO_PT:.3f}"/>')

    html = re.sub(r"<svg\b.*?</svg>", reemplazar, html, flags=re.S)
    return html, sorted(set(info))


def main():
    trabajo = os.path.join(AQUI, "_construccion")
    shutil.rmtree(trabajo, ignore_errors=True)
    oebps = os.path.join(trabajo, "OEBPS")
    for sub in ("ecuaciones", "figuras"):
        os.makedirs(os.path.join(oebps, sub), exist_ok=True)

    html = open(HTML, encoding="utf-8").read()
    html, ecuaciones = rasterizar_ecuaciones(html, os.path.join(oebps, "ecuaciones"))
    sopa = BeautifulSoup(html, "html.parser")

    # Ecuaciones: marcador -> <img> con tamaño en em
    for img in sopa.find_all("img", attrs={"data-eq": True}):
        alto, ancho = float(img["data-alto"]), float(img["data-ancho"])
        nuevo = sopa.new_tag("img", src="ecuaciones/" + img["data-eq"], alt="ecuación")
        if img.find_parent("div", class_="eq-bloque"):
            nuevo["style"] = f"height:{alto:.3f}em;"
        else:
            nuevo["class"] = "eq"
            nuevo["style"] = f"height:{alto:.3f}em;width:{ancho:.3f}em;vertical-align:middle;"
        img.replace_with(nuevo)

    # Rótulo de las figuras en color
    for cap in sopa.find_all("figcaption"):
        m = re.match(r"^(Figura|Tabla)\s*(\d+):\s*", cap.get_text())
        primero = cap.contents[0] if cap.contents else None
        if m and isinstance(primero, str) and primero.startswith(m.group(0)):
            rot = sopa.new_tag("span", attrs={"class": "rot"})
            rot.string = f"{m.group(1)} {m.group(2)}. "
            primero.replace_with(primero[len(m.group(0)):])
            cap.insert(0, rot)

    # Dividir en capítulos (cada <h2> de Typst es un capítulo) y subir un nivel los títulos
    cuerpo = sopa.body
    capitulos, actual = [], None
    for nodo in list(cuerpo.children):
        if getattr(nodo, "name", None) == "h2":
            actual = []
            capitulos.append(actual)
        if actual is not None:
            actual.append(nodo)

    nav, ids = [], {}
    archivos = []
    for i, nodos in enumerate(capitulos, start=1):
        archivo = f"cap{i:02d}.xhtml"
        archivos.append(archivo)
        contenedor = BeautifulSoup("<div></div>", "html.parser").div
        for n in nodos:
            contenedor.append(n.extract() if hasattr(n, "extract") else n)
        secciones = []
        for j, h in enumerate(contenedor.find_all(["h2", "h3", "h4"])):
            nivel = {"h2": "h1", "h3": "h2", "h4": "h3"}[h.name]
            h.name = nivel
            h["id"] = h.get("id") or f"s{i}-{j}"
            texto = h.get_text()
            m = re.match(r"^([IVX]+(?:\.\d+)?)\s+(.*)$", texto)
            if m and nivel in ("h1", "h2"):
                h.clear()
                num = sopa.new_tag("span", attrs={"class": "num"})
                num.string = (f"Capítulo {m.group(1)}" if nivel == "h1" else m.group(1))
                h.append(num)
                h.append(("" if nivel == "h1" else " ") + m.group(2))
            if nivel == "h1":
                h.insert_after(sopa.new_tag("hr"))
                nav.append((archivo, h["id"], h.get_text(" ", strip=True), []))
            elif nivel == "h2" and nav:
                nav[-1][3].append((archivo, h["id"], h.get_text(" ", strip=True)))
            secciones.append(h)
        for el in contenedor.find_all(id=True):
            ids[el["id"]] = archivo
        capitulos[i - 1] = contenedor

    # Enlaces internos entre archivos
    for cont in capitulos:
        for a in cont.find_all("a", href=True):
            if a["href"].startswith("#") and a["href"][1:] in ids:
                a["href"] = ids[a["href"][1:]] + a["href"]

    def xhtml(titulo, cuerpo_html):
        return ("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<!DOCTYPE html>\n"
                "<html xmlns=\"http://www.w3.org/1999/xhtml\" "
                "xmlns:epub=\"http://www.idpf.org/2007/ops\" lang=\"es\" xml:lang=\"es\">\n"
                f"<head><meta charset=\"utf-8\"/><title>{titulo}</title>"
                "<link rel=\"stylesheet\" type=\"text/css\" href=\"estilo.css\"/></head>\n"
                f"<body>\n{cuerpo_html}\n</body></html>\n")

    for archivo, cont in zip(archivos, capitulos):
        contenido = "".join(str(n) for n in cont.contents)
        titulo = cont.find("h1").get_text(" ", strip=True)
        open(os.path.join(oebps, archivo), "w", encoding="utf-8").write(xhtml(titulo, contenido))

    # Portada: primera página del PDF
    portada = fitz.open(PDF)[0].get_pixmap(dpi=160)
    portada.save(os.path.join(oebps, "portada.png"))
    open(os.path.join(oebps, "portada.xhtml"), "w", encoding="utf-8").write(xhtml(
        "Portada", "<div style=\"text-align:center\"><img src=\"portada.png\" alt=\"Portada\" "
        "style=\"max-width:100%;max-height:100%\"/></div>"))

    # Figuras
    figuras = sorted(f for f in os.listdir(FIGURAS) if f.endswith(".png"))
    for f in figuras:
        with open(os.path.join(FIGURAS, f), "rb") as src:
            open(os.path.join(oebps, "figuras", f), "wb").write(src.read())

    open(os.path.join(oebps, "estilo.css"), "w", encoding="utf-8").write(CSS)

    # Navegación (EPUB 3) y toc.ncx (compatibilidad)
    items = []
    for archivo, hid, texto, subs in nav:
        sub = "".join(f"<li><a href=\"{a}#{s}\">{t}</a></li>" for a, s, t in subs)
        items.append(f"<li><a href=\"{archivo}#{hid}\">{texto}</a>"
                     + (f"<ol>{sub}</ol>" if sub else "") + "</li>")
    open(os.path.join(oebps, "nav.xhtml"), "w", encoding="utf-8").write(xhtml(
        "Contenidos", "<nav epub:type=\"toc\" id=\"toc\"><h1>Contenidos</h1><ol>"
        + "".join(items) + "</ol></nav>"))

    identificador = "urn:uuid:" + str(uuid.uuid5(uuid.NAMESPACE_URL, "discretizacion-ipre-2026"))
    puntos, orden = [], 1
    for archivo, hid, texto, subs in nav:
        hijos = ""
        for a, s, t in subs:
            orden += 1
            hijos += (f"<navPoint id=\"np{orden}\" playOrder=\"{orden}\"><navLabel><text>{t}</text>"
                      f"</navLabel><content src=\"{a}#{s}\"/></navPoint>")
        puntos.append(f"<navPoint id=\"np{orden}x\" playOrder=\"{orden}\"><navLabel><text>{texto}"
                      f"</text></navLabel><content src=\"{archivo}#{hid}\"/>{hijos}</navPoint>")
        orden += 1
    open(os.path.join(oebps, "toc.ncx"), "w", encoding="utf-8").write(
        "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<ncx xmlns=\"http://www.daisy.org/z3986/2005/ncx/\" "
        f"version=\"2005-1\"><head><meta name=\"dtb:uid\" content=\"{identificador}\"/></head>"
        f"<docTitle><text>{TITULO}</text></docTitle><navMap>{''.join(puntos)}</navMap></ncx>")

    manifiesto = [
        '<item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>',
        '<item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>',
        '<item id="css" href="estilo.css" media-type="text/css"/>',
        '<item id="portada-img" href="portada.png" media-type="image/png" properties="cover-image"/>',
        '<item id="portada" href="portada.xhtml" media-type="application/xhtml+xml"/>',
    ]
    for k, a in enumerate(archivos):
        manifiesto.append(f'<item id="c{k}" href="{a}" media-type="application/xhtml+xml"/>')
    for k, f in enumerate(figuras):
        manifiesto.append(f'<item id="f{k}" href="figuras/{f}" media-type="image/png"/>')
    for k, f in enumerate(ecuaciones):
        manifiesto.append(f'<item id="e{k}" href="ecuaciones/{f}" media-type="image/png"/>')
    espina = ['<itemref idref="portada"/>', '<itemref idref="nav"/>'] + \
        [f'<itemref idref="c{k}"/>' for k in range(len(archivos))]
    fecha = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    opf = f"""<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="uid" xml:lang="es">
<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
<dc:identifier id="uid">{identificador}</dc:identifier>
<dc:title>{TITULO}</dc:title>
<dc:creator>{AUTOR}</dc:creator>
<dc:language>es</dc:language>
<meta property="dcterms:modified">{fecha}</meta>
<meta name="cover" content="portada-img"/>
</metadata>
<manifest>
{chr(10).join(manifiesto)}
</manifest>
<spine toc="ncx">
{chr(10).join(espina)}
</spine>
</package>
"""
    open(os.path.join(oebps, "content.opf"), "w", encoding="utf-8").write(opf)

    with zipfile.ZipFile(SALIDA, "w") as z:
        z.writestr(zipfile.ZipInfo("mimetype"), "application/epub+zip",
                   compress_type=zipfile.ZIP_STORED)
        z.writestr("META-INF/container.xml",
                   "<?xml version=\"1.0\"?><container version=\"1.0\" "
                   "xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\"><rootfiles>"
                   "<rootfile full-path=\"OEBPS/content.opf\" "
                   "media-type=\"application/oebps-package+xml\"/></rootfiles></container>",
                   compress_type=zipfile.ZIP_DEFLATED)
        for carpeta, _, nombres in os.walk(oebps):
            for n in nombres:
                ruta = os.path.join(carpeta, n)
                z.write(ruta, os.path.relpath(ruta, trabajo).replace(os.sep, "/"),
                        compress_type=zipfile.ZIP_DEFLATED)
    print(f"{SALIDA}: {len(archivos)} capítulos, {len(ecuaciones)} ecuaciones, "
          f"{len(figuras)} figuras")


if __name__ == "__main__":
    main()
