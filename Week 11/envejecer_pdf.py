#!/usr/bin/env python3
"""
envejecer_pdf.py: convierte un PDF en una versión que parece escaneada y desgastada.

El pipeline sigue el orden físico de lo que le pasa a una hoja real:

  1. RASTERIZAR   cada página del PDF se convierte en una imagen.
  2. LA HOJA      lo que le ocurre al papel antes de llegar al escáner:
                    tinta irregular -> tono del papel -> manchas -> doblez
  3. EL ESCÁNER   lo que introduce el proceso de escaneo:
                    rotación/desplazamiento -> desenfoque -> iluminación
                    desigual -> ruido del sensor -> compresión JPEG
  4. REENSAMBLAR  las imágenes se unen en un nuevo PDF.

Las manchas y el doblez van ANTES de la rotación porque son parte del papel:
giran con él. El ruido va al FINAL porque lo produce el sensor, que no gira.

Dependencias:
    pip install pymupdf pillow numpy

Uso:
    python envejecer_pdf.py entrada.pdf salida.pdf
    python envejecer_pdf.py entrada.pdf salida.pdf --dpi 200 --intensidad 1.5 --semilla 7 --gris
"""

import argparse
import io
import math

import numpy as np
import pymupdf
from PIL import Image, ImageFilter


# ---------------------------------------------------------------------------
# Utilidades
# ---------------------------------------------------------------------------

def ruido_suave(alto, ancho, escala, rng):
    """
    Ruido de baja frecuencia en [0, 1].

    Se genera una grilla pequeña de valores aleatorios y se amplía con
    interpolación bicúbica. Cuanto mayor es `escala` (en píxeles), más
    grandes y difusas son las variaciones.
    """
    h = max(2, int(alto / escala))
    w = max(2, int(ancho / escala))
    base = (rng.random((h, w)) * 255).astype(np.uint8)
    grande = Image.fromarray(base).resize((ancho, alto), Image.BICUBIC)
    return np.asarray(grande, dtype=np.float32) / 255.0


def a_pil(img):
    return Image.fromarray((np.clip(img, 0, 1) * 255).astype(np.uint8))


def a_array(pil):
    return np.asarray(pil, dtype=np.float32) / 255.0


# ---------------------------------------------------------------------------
# Etapa 1: rasterizar
# ---------------------------------------------------------------------------

def rasterizar(pagina, dpi):
    pix = pagina.get_pixmap(dpi=dpi, alpha=False)
    img = np.frombuffer(pix.samples, dtype=np.uint8).reshape(pix.height, pix.width, pix.n)
    return img[..., :3].astype(np.float32) / 255.0


# ---------------------------------------------------------------------------
# Etapa 2: lo que le pasa a la hoja
# ---------------------------------------------------------------------------

def tinta(img, intensidad, rng, s):
    """
    El tóner no es negro puro ni uniforme.

    Trabajamos con la "cantidad de tinta" t = 1 - I (0 = papel, 1 = negro).
    La reducimos un poco (levanta los negros) y la modulamos con ruido suave,
    para que haya zonas algo más desteñidas que otras.
    """
    alto, ancho, _ = img.shape
    t = 1.0 - img
    piso = min(0.25, 0.08 * intensidad)               # el negro más oscuro posible
    irregular = 1.0 - 0.25 * intensidad * ruido_suave(alto, ancho, 60 * s, rng)
    t = t * (1.0 - piso) * np.clip(irregular, 0.4, 1.0)[..., None]
    return 1.0 - t


def papel(img, intensidad, rng, s):
    """
    Tono amarillento del papel envejecido, con variaciones grandes (manchas de
    humedad) y finas (grano). Se aplica de forma multiplicativa: el papel
    tiñe todo lo que está sobre él, incluida la tinta.
    """
    alto, ancho, _ = img.shape
    tono = np.array([0.97, 0.94, 0.85], dtype=np.float32)
    mezcla = min(1.0, 0.6 * intensidad)
    color = 1.0 - (1.0 - tono) * mezcla

    textura = (0.6 * ruido_suave(alto, ancho, 120 * s, rng)
               + 0.4 * ruido_suave(alto, ancho, 6 * s, rng))
    variacion = 1.0 - 0.07 * intensidad * textura
    return img * color * variacion[..., None]


def manchas(img, intensidad, rng, s):
    """
    Manchas de café (anillos) y gotas, generadas proceduralmente.

    Cada mancha es una máscara `m` en [0, 1] calculada en un recuadro local.
    El borde es irregular porque el radio varía con el ángulo:
        R(θ) = R · (1 + Σ a_k sin(kθ + φ_k))
    Se combina por multiplicación: I' = I · (1 - m·(1 - color)).
    """
    alto, ancho, _ = img.shape
    n = rng.poisson(1.2 * intensidad)
    color = np.array([0.78, 0.62, 0.42], dtype=np.float32)
    lado = min(alto, ancho)

    for _ in range(n):
        R = rng.uniform(0.04, 0.13) * lado
        cx, cy = rng.uniform(0, ancho), rng.uniform(0, alto)

        # recuadro local para no calcular sobre la imagen completa
        m_ext = int(R * 1.5)
        x0, x1 = max(0, int(cx - m_ext)), min(ancho, int(cx + m_ext))
        y0, y1 = max(0, int(cy - m_ext)), min(alto, int(cy + m_ext))
        if x1 <= x0 or y1 <= y0:
            continue
        yy, xx = np.mgrid[y0:y1, x0:x1].astype(np.float32)
        dx, dy = xx - cx, yy - cy
        r = np.hypot(dx, dy)
        theta = np.arctan2(dy, dx)

        deformacion = sum(rng.uniform(-0.06, 0.06) * np.sin(k * theta + rng.uniform(0, 2 * math.pi))
                          for k in range(2, 7))
        Rv = R * (1.0 + deformacion)

        if rng.random() < 0.55:
            # anillo de taza: borde marcado y un velo tenue en el interior
            grosor = R * rng.uniform(0.025, 0.06)
            m = (np.exp(-((r - Rv) / grosor) ** 2) * rng.uniform(0.35, 0.65)
                 + (r < Rv) * rng.uniform(0.03, 0.08))
        else:
            # gota: más intensa al centro, se desvanece hacia el borde
            m = np.clip(1.0 - r / Rv, 0, 1) ** 0.6 * rng.uniform(0.12, 0.28)

        # irregularidad interna
        m = m * (0.6 + 0.4 * ruido_suave(y1 - y0, x1 - x0, 15 * s, rng))
        m = np.clip(m * min(1.5, intensidad), 0, 1)

        img[y0:y1, x0:x1] *= 1.0 - m[..., None] * (1.0 - color)
    return img


def doblez(img, intensidad, rng, s):
    """
    Un pliegue del papel: una línea casi recta con relieve.

    Si d es la distancia (con signo) a la línea, el perfil
        p(d) = a · (d/w) · exp(-(d/w)²) - b · exp(-(d/w)²)
    aclara un lado, oscurece el otro (luz rasante sobre el relieve) y deja
    un núcleo levemente más oscuro.
    """
    if rng.random() > min(1.0, 0.45 * intensidad):
        return img
    alto, ancho, _ = img.shape

    if rng.random() < 0.5:   # pliegue horizontal cerca del centro
        x0, y0 = ancho / 2, alto * rng.uniform(0.4, 0.6)
        angulo = rng.uniform(-0.02, 0.02)
    else:                     # pliegue vertical
        x0, y0 = ancho * rng.uniform(0.4, 0.6), alto / 2
        angulo = math.pi / 2 + rng.uniform(-0.02, 0.02)

    yy, xx = np.mgrid[0:alto, 0:ancho].astype(np.float32)
    d = -(xx - x0) * math.sin(angulo) + (yy - y0) * math.cos(angulo)
    w = 6.0 * s
    u = d / w
    g = np.exp(-u ** 2)
    perfil = 0.10 * u * g - 0.06 * g
    perfil *= min(1.5, intensidad)
    return img * (1.0 + perfil)[..., None]


# ---------------------------------------------------------------------------
# Etapa 3: lo que introduce el escáner
# ---------------------------------------------------------------------------

def colocar_en_escaner(img, intensidad, rng, s):
    """La hoja nunca entra recta: rotación pequeña y un leve desplazamiento."""
    angulo = rng.normal(0, 0.35) * min(2.0, intensidad)          # grados
    desplazamiento = (int(rng.normal(0, 4 * s)), int(rng.normal(0, 4 * s)))
    pil = a_pil(img).rotate(angulo, resample=Image.BICUBIC,
                            translate=desplazamiento, fillcolor=(232, 232, 230))
    return a_array(pil)


def desenfocar(img, intensidad, s):
    """La óptica no es perfecta y el papel no está pegado al vidrio."""
    radio = 0.55 * s * min(2.0, intensidad)
    return a_array(a_pil(img).filter(ImageFilter.GaussianBlur(radio)))


def iluminacion(img, intensidad, rng):
    """
    La lámpara no ilumina parejo: bordes más oscuros (viñeta radial) y un
    gradiente lineal suave en una dirección aleatoria.
    """
    alto, ancho, _ = img.shape
    yy, xx = np.mgrid[0:alto, 0:ancho].astype(np.float32)
    nx, ny = (xx / ancho - 0.5) * 2, (yy / alto - 0.5) * 2      # coordenadas en [-1, 1]
    vineta = 1.0 - 0.06 * intensidad * (nx ** 2 + ny ** 2) / 2
    ang = rng.uniform(0, 2 * math.pi)
    gradiente = 1.0 - 0.04 * intensidad * (nx * math.cos(ang) + ny * math.sin(ang) + 1) / 2
    return img * (vineta * gradiente)[..., None]


def ruido_sensor(img, intensidad, rng):
    """
    Ruido del sensor: I' = I + η,  η ~ N(0, σ²).
    Además, cada fila recibe un pequeño desplazamiento propio (bandas típicas
    de los escáneres que leen línea por línea).
    """
    alto, ancho, c = img.shape
    sigma = 0.018 * intensidad
    eta = rng.normal(0, sigma, (alto, ancho, 1)).astype(np.float32)   # mismo ruido en los 3 canales
    eta = eta + rng.normal(0, sigma * 0.3, (alto, ancho, c)).astype(np.float32)  # algo de ruido de color
    bandas = rng.normal(0, sigma * 0.4, (alto, 1, 1)).astype(np.float32)
    return img + eta + bandas


# ---------------------------------------------------------------------------
# Pipeline completo
# ---------------------------------------------------------------------------

def envejecer_pagina(img, dpi, intensidad, rng):
    s = dpi / 200.0   # los tamaños están pensados para 200 DPI y se escalan

    # La hoja
    img = tinta(img, intensidad, rng, s)
    img = papel(img, intensidad, rng, s)
    img = manchas(img, intensidad, rng, s)
    img = doblez(img, intensidad, rng, s)

    # El escáner
    img = colocar_en_escaner(img, intensidad, rng, s)
    img = desenfocar(img, intensidad, s)
    img = iluminacion(img, intensidad, rng)
    img = ruido_sensor(img, intensidad, rng)
    return np.clip(img, 0, 1)


def main():
    p = argparse.ArgumentParser(description="Convierte un PDF en una versión escaneada y desgastada.")
    p.add_argument("entrada", help="PDF de entrada")
    p.add_argument("salida", help="PDF de salida")
    p.add_argument("--dpi", type=int, default=200, help="resolución del 'escaneo' (por defecto 200)")
    p.add_argument("--intensidad", type=float, default=1.0,
                   help="cuánto desgaste aplicar: 0.5 sutil, 1 normal, 2 muy maltratado")
    p.add_argument("--calidad", type=int, default=70, help="calidad JPEG 1-95 (más bajo = más artefactos)")
    p.add_argument("--semilla", type=int, default=None, help="semilla aleatoria, para resultados reproducibles")
    p.add_argument("--gris", action="store_true", help="escanear en escala de grises")
    args = p.parse_args()

    rng = np.random.default_rng(args.semilla)
    origen = pymupdf.open(args.entrada)
    destino = pymupdf.open()

    for i, pagina in enumerate(origen, start=1):
        print(f"Página {i}/{len(origen)}...", flush=True)
        img = rasterizar(pagina, args.dpi)
        img = envejecer_pagina(img, args.dpi, args.intensidad, rng)

        pil = a_pil(img)
        if args.gris:
            pil = pil.convert("L")

        # La compresión JPEG es la última "degradación": añade sus propios artefactos.
        buffer = io.BytesIO()
        pil.save(buffer, format="JPEG", quality=args.calidad, dpi=(args.dpi, args.dpi))

        # Etapa 4: reensamblar, manteniendo el tamaño físico de la página original
        nueva = destino.new_page(width=pagina.rect.width, height=pagina.rect.height)
        nueva.insert_image(nueva.rect, stream=buffer.getvalue())

    destino.save(args.salida, garbage=4, deflate=True)
    print(f"Listo: {args.salida}")


if __name__ == "__main__":
    main()
