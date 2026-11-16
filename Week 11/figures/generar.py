"""Genera las figuras del capítulo sobre discretización.

Uso:  python generar.py [carpeta_previsualizaciones]

Escribe un SVG por figura en la carpeta de este script. Si se entrega una
carpeta extra, también guarda allí una versión PNG para revisar.

Convención de color en todo el capítulo: azul = continuo, naranja = discreto.
Las figuras marcadas como "esquema cualitativo" no reproducen datos de ningún
paper; las simulaciones usan la semilla fija indicada en cada función.
"""

import os
import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import Circle, FancyArrowPatch, FancyBboxPatch, Polygon, Rectangle
from scipy.special import erf

AQUI = os.path.dirname(os.path.abspath(__file__))
PREVIEW = sys.argv[1] if len(sys.argv) > 1 else None

# Paleta (dataviz: slots 1-3 validados para todos los pares) + colores del documento
AZUL = "#2a78d6"      # continuo
NARANJA = "#eb6834"   # discreto
AQUA = "#1baf7a"      # correcto / se corrige
ROJO = "#e34948"      # error
MORADO = "#1a1a1a"    # estructura de los diagramas (negro de la plantilla)
MAGENTA = "#b5467a"   # rosa oscuro de la plantilla (etiquetas de preguntas)
TINTA = "#1f1f1f"
GRIS = "#6b6b6b"
GRIS_CLARO = "#d9d9d9"

AZUL_F = "#dceaf9"
NARANJA_F = "#fbe1d6"
AQUA_F = "#d6f2e7"
ROJO_F = "#f9dada"
MORADO_F = "#fbe4ec"  # rosa pastel de la plantilla
GRIS_F = "#f2f2f2"

ANCHO = 5.2  # pulgadas: ancho del texto en la plantilla

plt.rcParams.update({
    "font.family": "DejaVu Sans",
    "font.size": 8,
    "axes.titlesize": 8.5,
    "axes.labelsize": 8,
    "xtick.labelsize": 7,
    "ytick.labelsize": 7,
    "legend.fontsize": 7,
    "axes.edgecolor": GRIS,
    "axes.labelcolor": TINTA,
    "xtick.color": GRIS,
    "ytick.color": GRIS,
    "text.color": TINTA,
    "axes.spines.top": False,
    "axes.spines.right": False,
    "svg.fonttype": "path",
    "mathtext.fontset": "dejavusans",
})


# ---------------------------------------------------------------------------
# Utilidades
# ---------------------------------------------------------------------------

def guardar(fig, nombre):
    fig.savefig(os.path.join(AQUI, nombre + ".svg"), bbox_inches="tight", pad_inches=0.03)
    # PNG para el EPUB: los lectores Kindle no muestran bien SVG
    os.makedirs(os.path.join(AQUI, "png"), exist_ok=True)
    fig.savefig(os.path.join(AQUI, "png", nombre + ".png"), dpi=220, bbox_inches="tight",
                pad_inches=0.05, facecolor="white")
    if PREVIEW:
        fig.savefig(os.path.join(PREVIEW, nombre + ".png"), dpi=150, bbox_inches="tight", pad_inches=0.03)
    plt.close(fig)


def lienzo(alto, xmax=10, ymax=None):
    """Ejes sin marco con coordenadas en 'unidades' (1 unidad = ANCHO/xmax pulgadas)."""
    ymax = ymax if ymax is not None else alto * xmax / ANCHO
    fig = plt.figure(figsize=(ANCHO, alto))
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, xmax)
    ax.set_ylim(0, ymax)
    ax.set_aspect("equal")
    ax.axis("off")
    return fig, ax


def caja(ax, x, y, w, h, texto="", fc=GRIS_F, ec=GRIS, lw=0.8, size=8, color=TINTA,
         weight="normal", radio=0.12, ha="center"):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle=f"round,pad=0,rounding_size={radio}",
                                fc=fc, ec=ec, lw=lw))
    if texto:
        tx = x + w / 2 if ha == "center" else x + 0.15
        ax.text(tx, y + h / 2, texto, ha=ha, va="center", fontsize=size, color=color,
                weight=weight, linespacing=1.25)
    return (x, y, w, h)


def flecha(ax, p, q, color=GRIS, lw=0.9, estilo="-|>", ls="-", curva=0.0, mut=8):
    ax.add_patch(FancyArrowPatch(p, q, arrowstyle=estilo, mutation_scale=mut, color=color,
                                 lw=lw, linestyle=ls, shrinkA=0, shrinkB=0,
                                 connectionstyle=f"arc3,rad={curva}"))


def marcador(ax, x, y, n, color=NARANJA, r=0.22, size=7.5):
    ax.add_patch(Circle((x, y), r, fc=color, ec="white", lw=0.8, zorder=5))
    ax.text(x, y, str(n), ha="center", va="center", color="white", fontsize=size,
            weight="bold", zorder=6)


def ejes_limpios(ax):
    ax.spines["left"].set_color(GRIS)
    ax.spines["bottom"].set_color(GRIS)
    ax.tick_params(length=2.5, width=0.6)


# ---------------------------------------------------------------------------
# Capítulo I: introducción
# ---------------------------------------------------------------------------

def f01_paquete():
    fig, ax = lienzo(3.15, ymax=6.3)
    caja(ax, 0.2, 4.75, 2.6, 1.15, "Vector continuo\n$z \\in \\mathbb{R}^d$", fc=AZUL_F, ec=AZUL)
    caja(ax, 3.9, 4.75, 2.2, 1.15, "Cuantizador\n$q(z)$", fc=MORADO_F, ec=MORADO, weight="bold",
         color=MORADO)
    caja(ax, 7.2, 4.75, 2.6, 1.15, "Código discreto\n$k \\in \\{1,\\dots,K\\}$", fc=NARANJA_F,
         ec=NARANJA)
    flecha(ax, (2.8, 5.33), (3.9, 5.33))
    flecha(ax, (6.1, 5.33), (7.2, 5.33))

    piezas = [
        ("1 · Capacidad", "caben a lo más\n$\\log_2 K$ bits"),
        ("2 · Geometría", "one-hot o vector\ndel diccionario"),
        ("3 · Pérdida", "clasificar (CE) en vez\nde regresionar (MSE)"),
        ("4 · Elegir entre modos", "un futuro posible,\nno su promedio"),
        ("5 · Redondeo", "los errores pequeños\nse borran"),
        ("6 · Identidad exacta", "enumerar, reutilizar,\ncomponer"),
    ]
    xs = [0.2, 3.5, 6.8]
    ys = [2.55, 0.25]
    for i, (titulo, cuerpo) in enumerate(piezas):
        x, y = xs[i % 3], ys[i // 3]
        caja(ax, x, y, 3.0, 1.85, "", fc="white", ec=MORADO, lw=0.7)
        ax.text(x + 1.5, y + 1.42, titulo, ha="center", va="center", fontsize=8, weight="bold",
                color=MORADO)
        ax.text(x + 1.5, y + 0.65, cuerpo, ha="center", va="center", fontsize=7.5,
                linespacing=1.3)
        ax.plot([5.0, x + 1.5], [4.75, y + 1.85], color=GRIS_CLARO, lw=0.7, zorder=0)
    guardar(fig, "f01_paquete")


def f02_mapa():
    fig, ax = lienzo(3.0, ymax=6.0)
    cols = [0.1, 2.1, 4.1, 6.1, 8.1]
    w = 1.8
    grupos = ["Herramientas", "Evidencia", "Mecanismos", "Costos y\naplicación", "Síntesis"]
    for x, g in zip(cols, grupos):
        ax.text(x + w / 2, 5.75, g, ha="center", va="center", fontsize=7.5, color=GRIS,
                style="italic", linespacing=1.1)
    cajas = {
        "II": (cols[0], 3.6, "II\nFundamentos", []),
        "III": (cols[0], 1.3, "III\nCómo se\ndiscretiza", []),
        "IV": (cols[1], 2.45, "IV\nEvidencia:\ndónde ayuda", ["P2"]),
        "V": (cols[2], 3.6, "V\nSeguir\nel error", []),
        "VI": (cols[2], 1.3, "VI\n¿Es la\ndiscretización?", ["P3", "A1"]),
        "VII": (cols[3], 3.6, "VII\nColapso y\nerror acumulado", ["P1", "P5", "N"]),
        "VIII": (cols[3], 1.3, "VIII\nJEPA", ["P4"]),
        "IX": (cols[4], 3.6, "IX\n¿Cuándo\ndiscretizar?", ["A2"]),
        "X": (cols[4], 1.3, "X\nConclusiones", ["todas"]),
    }
    h = 1.55
    for clave, (x, y, texto, tags) in cajas.items():
        caja(ax, x, y, w, h, texto, fc=MORADO_F, ec=MORADO, size=7.3)
        for j, t in enumerate(tags):
            tw = 0.42 if t != "todas" else 0.75
            total = sum((0.42 if s != "todas" else 0.75) + 0.08 for s in tags) - 0.08
            x0 = x + w / 2 - total / 2 + sum((0.42 if s != "todas" else 0.75) + 0.08
                                               for s in tags[:j])
            caja(ax, x0, y - 0.42, tw, 0.32, t, fc=MAGENTA, ec=MAGENTA, size=6.3, color="white",
                 weight="bold", radio=0.12)
    flujo = [("II", "IV"), ("III", "IV"), ("IV", "V"), ("IV", "VI"), ("V", "VII"),
             ("VI", "VII"), ("VI", "VIII"), ("VII", "IX"), ("VIII", "IX"), ("IX", "X"),
             ("V", "VI")]
    for a, b in flujo:
        xa, ya, _, _ = cajas[a]
        xb, yb, _, _ = cajas[b]
        if xa == xb:
            flecha(ax, (xa + w / 2, ya), (xb + w / 2, yb + h), color=GRIS, lw=0.7)
        else:
            flecha(ax, (xa + w, ya + h / 2), (xb, yb + h / 2), color=GRIS, lw=0.7)
    guardar(fig, "f02_mapa")


# ---------------------------------------------------------------------------
# Capítulo II: fundamentos
# ---------------------------------------------------------------------------

def f03_autoencoder():
    fig, ax = lienzo(1.45, ymax=2.8)
    caja(ax, 0.1, 0.9, 1.0, 1.0, "$x$", fc=GRIS_F, size=10)
    ax.add_patch(Polygon([[1.5, 0.3], [3.6, 0.95], [3.6, 1.85], [1.5, 2.5]], closed=True,
                         fc=AZUL_F, ec=AZUL, lw=0.8))
    ax.text(2.55, 1.4, "codificador\n$q_\\phi$", ha="center", va="center", fontsize=7.5)
    caja(ax, 4.2, 0.95, 1.6, 0.9, "latente $z$", fc=MORADO_F, ec=MORADO, weight="bold",
         color=MORADO)
    ax.text(5.0, 0.6, "cuello de botella", ha="center", va="center", fontsize=7, color=GRIS,
            style="italic")
    ax.add_patch(Polygon([[6.4, 0.95], [8.5, 0.3], [8.5, 2.5], [6.4, 1.85]], closed=True,
                         fc=AZUL_F, ec=AZUL, lw=0.8))
    ax.text(7.45, 1.4, "decodificador\n$p_\\theta$", ha="center", va="center", fontsize=7.5)
    caja(ax, 8.9, 0.9, 1.0, 1.0, "$\\hat{x}$", fc=GRIS_F, size=10)
    flecha(ax, (1.1, 1.4), (1.5, 1.4))
    flecha(ax, (3.6, 1.4), (4.2, 1.4))
    flecha(ax, (5.8, 1.4), (6.4, 1.4))
    flecha(ax, (8.5, 1.4), (8.9, 1.4))
    guardar(fig, "f03_autoencoder")


def f04_mse_vs_ce():
    fig, axs = plt.subplots(1, 2, figsize=(ANCHO, 1.9), sharey=True)
    for ax in axs:
        ejes_limpios(ax)
        ax.set_xlim(-2, 2)
        ax.set_ylim(0, 0.62)
        ax.set_xticks([-1, 0, 1], ["A", "0", "B"])
        ax.set_xlabel("estado siguiente")
    ax = axs[0]
    ax.set_title("Regresión (MSE)\npredice la media", color=AZUL)
    ax.vlines([-1, 1], 0, 0.5, color=GRIS, lw=3)
    ax.plot([0], [0.04], marker="X", color=AZUL, ms=9, mec="white", mew=0.8, clip_on=False)
    ax.annotate("predicción:\nel promedio,\nque no es un\nfuturo real", xy=(0, 0.07),
                xytext=(0, 0.25), ha="center", fontsize=6.8, color=AZUL, linespacing=1.15,
                arrowprops=dict(arrowstyle="-|>", color=AZUL, lw=0.8))
    ax.set_ylabel("probabilidad")
    ax.text(-1, 0.52, "50 %", ha="center", fontsize=7, color=GRIS)
    ax.text(1, 0.52, "50 %", ha="center", fontsize=7, color=GRIS)
    ax = axs[1]
    ax.set_title("Clasificación (CE)\npredice una distribución", color=NARANJA)
    alturas = np.array([0.01, 0.02, 0.45, 0.02, 0.02, 0.45, 0.02, 0.01])
    centros = np.array([-1.75, -1.25, -1.0, -0.5, 0.5, 1.0, 1.25, 1.75])
    ax.bar(centros, alturas, width=0.2, color=NARANJA, edgecolor="white", linewidth=0.8)
    ax.text(0, 0.25, "la masa\nqueda sobre\nA y sobre B", ha="center", fontsize=6.8,
            color=NARANJA, linespacing=1.15)
    guardar(fig, "f04_mse_vs_ce")


def f05_modelo_mundo():
    fig, ax = lienzo(2.5, ymax=4.8)
    caja(ax, 0.2, 3.5, 2.2, 1.0, "Agente", fc=MORADO_F, ec=MORADO, weight="bold", color=MORADO)
    caja(ax, 7.6, 3.5, 2.2, 1.0, "Entorno real", fc=GRIS_F, ec=GRIS, weight="bold")
    flecha(ax, (2.4, 4.2), (7.6, 4.2), color=GRIS)
    ax.text(5.0, 4.35, "acción $a_t$", ha="center", fontsize=7.5)
    flecha(ax, (7.6, 3.75), (2.4, 3.75), color=GRIS)
    ax.text(5.0, 3.42, "observación $x_{t+1}$, recompensa $r_{t+1}$", ha="center", fontsize=7.5,
            va="top")
    ax.text(0.2, 2.65, "Imaginación con el modelo del mundo:", fontsize=7.5, color=GRIS,
            style="italic")
    xs = np.linspace(0.9, 9.1, 6)
    y0 = 1.25
    # cono de error que crece
    sup = [y0 + 0.28 + 0.13 * i for i in range(6)]
    inf = [y0 - 0.28 - 0.13 * i for i in range(6)]
    ax.add_patch(Polygon(list(zip(xs, sup)) + list(zip(xs[::-1], inf[::-1])), closed=True,
                         fc=ROJO_F, ec="none", zorder=0))
    for i, x in enumerate(xs):
        ax.add_patch(Circle((x, y0), 0.33, fc="white", ec=AZUL, lw=0.9, zorder=3))
        ax.text(x, y0, f"$\\hat z_{i}$" if i else "$z_0$", ha="center", va="center", fontsize=8,
                zorder=4)
        if i < 5:
            flecha(ax, (x + 0.33, y0), (xs[i + 1] - 0.33, y0), color=AZUL, lw=0.8)
            ax.text((x + xs[i + 1]) / 2, y0 + 0.12, f"$a_{i}$", ha="center", va="bottom",
                    fontsize=7, color=GRIS)
        if i:
            ax.text(x, y0 - 0.5 - 0.13 * i, f"$\\hat r_{i}$", ha="center", va="top", fontsize=7,
                    color=GRIS)
    ax.text(9.6, y0 + 0.95, "el error\nse acumula", ha="right", va="bottom", fontsize=7,
            color=ROJO)
    guardar(fig, "f05_modelo_mundo")


# ---------------------------------------------------------------------------
# Capítulo III: cómo se discretiza
# ---------------------------------------------------------------------------

def _kmeans(x, k, semilla=0, iters=30):
    rng = np.random.default_rng(semilla)
    c = x[rng.choice(len(x), k, replace=False)]
    for _ in range(iters):
        a = np.argmin(((x[:, None] - c[None]) ** 2).sum(-1), 1)
        c = np.array([x[a == j].mean(0) if np.any(a == j) else c[j] for j in range(k)])
    return c


def f06_geometria():
    fig, axs = plt.subplots(1, 3, figsize=(ANCHO, 1.95))
    rng = np.random.default_rng(3)
    centros_v = np.array([[-0.9, -0.6], [-0.4, 0.8], [0.7, 0.6], [0.9, -0.7], [0.0, -0.1]])
    datos = np.concatenate([c + 0.22 * rng.standard_normal((70, 2)) for c in centros_v])

    ax = axs[0]
    cod = _kmeans(datos, 8, semilla=1)
    g = np.linspace(-1.6, 1.6, 400)
    gx, gy = np.meshgrid(g, g)
    asig = np.argmin(((np.stack([gx, gy], -1)[..., None, :] - cod) ** 2).sum(-1), -1)
    ax.contour(gx, gy, asig, levels=np.arange(9) - 0.5, colors=NARANJA, linewidths=0.6)
    ax.scatter(datos[:, 0], datos[:, 1], s=2, color=GRIS, alpha=0.5, lw=0)
    ax.scatter(cod[:, 0], cod[:, 1], s=22, color=NARANJA, edgecolor="white", lw=0.8, zorder=3)
    ax.set_title("VQ\ndiccionario aprendido")

    ax = axs[1]
    niveles = np.linspace(-1, 1, 5)
    for v in (niveles[:-1] + niveles[1:]) / 2:
        ax.axvline(v, color=NARANJA, lw=0.6)
        ax.axhline(v, color=NARANJA, lw=0.6)
    d2 = np.tanh(1.1 * datos)
    ax.scatter(d2[:, 0], d2[:, 1], s=2, color=GRIS, alpha=0.5, lw=0)
    px, py = np.meshgrid(niveles, niveles)
    ax.scatter(px, py, s=22, color=NARANJA, edgecolor="white", lw=0.8, zorder=3)
    ax.set_title("FSQ\ngrilla fija (5 × 5)")

    ax = axs[2]
    v = np.array([[0, 0], [1, 0], [0.5, np.sqrt(3) / 2]]) * 2.4 - [1.2, 0.85]
    ax.add_patch(Polygon(v, closed=True, fc=GRIS_F, ec=GRIS, lw=0.8))
    for i, p in enumerate(v):
        ax.scatter(*p, s=30, color=NARANJA, edgecolor="white", lw=0.8, zorder=3)
    ax.text(v[0][0] - 0.05, v[0][1] - 0.2, "$e_1$", ha="center", va="top", fontsize=8)
    ax.text(v[1][0] + 0.05, v[1][1] - 0.2, "$e_2$", ha="center", va="top", fontsize=8)
    ax.text(v[2][0], v[2][1] + 0.12, "$e_3$", ha="center", va="bottom", fontsize=8)
    p = 0.55 * v[1] + 0.25 * v[0] + 0.20 * v[2]
    ax.scatter(*p, s=26, color=AZUL, edgecolor="white", lw=0.8, zorder=4)
    ax.annotate("", xy=v[1] + [-0.1, 0.06], xytext=p,
                arrowprops=dict(arrowstyle="-|>", color=NARANJA, lw=0.9))
    ax.text(p[0] - 0.12, p[1] + 0.08, "softmax", ha="right", fontsize=6.8, color=AZUL)
    ax.text(0.62, -0.62, "argmax", ha="center", fontsize=6.8, color=NARANJA)
    ax.set_title("One-hot\nvértices del símplex")

    for ax in axs:
        ax.set_xlim(-1.6, 1.6)
        ax.set_ylim(-1.6, 1.6)
        ax.set_aspect("equal")
        ax.set_xticks([])
        ax.set_yticks([])
        for s in ax.spines.values():
            s.set_visible(True)
            s.set_color(GRIS_CLARO)
    fig.tight_layout(w_pad=0.6)
    guardar(fig, "f06_geometria")


def f07_donde():
    fig, ax = lienzo(3.15, ymax=6.0)
    y = 3.6
    h = 0.95
    caja(ax, 0.1, y, 0.9, h, "$x_t$")
    caja(ax, 1.4, y, 1.7, h, "Codificador", fc=AZUL_F, ec=AZUL)
    caja(ax, 3.5, y, 0.9, h, "$z_t$", fc=MORADO_F, ec=MORADO)
    caja(ax, 4.8, y, 1.7, h, "Predictor", fc=AZUL_F, ec=AZUL)
    caja(ax, 6.9, y, 1.0, h, "$\\hat z_{t+1}$", fc=MORADO_F, ec=MORADO)
    caja(ax, 8.3, y, 1.6, h, "Pérdida", fc=GRIS_F, ec=GRIS)
    caja(ax, 8.3, y + 1.25, 1.6, 0.6, "$z_{t+1}$ objetivo", size=7)
    caja(ax, 4.8, y + 1.25, 1.7, 0.6, "acción $a_t$", size=7)
    flecha(ax, (1.0, y + h / 2), (1.4, y + h / 2))
    flecha(ax, (3.1, y + h / 2), (3.5, y + h / 2))
    flecha(ax, (4.4, y + h / 2), (4.8, y + h / 2))
    flecha(ax, (6.5, y + h / 2), (6.9, y + h / 2))
    flecha(ax, (7.9, y + h / 2), (8.3, y + h / 2))
    flecha(ax, (9.1, y + 1.25), (9.1, y + h))
    flecha(ax, (5.65, y + 1.25), (5.65, y + h))
    marcador(ax, 3.95, y - 0.05, 1)
    marcador(ax, 2.25, y - 0.05, 2)
    marcador(ax, 5.65, y - 0.05, 3)
    marcador(ax, 9.1, y - 0.05, 4)
    marcador(ax, 4.5, y + 1.55, 5)
    filas = [
        (1, "Valores del latente", "VQ-VAE, DreamerV2/V3 (categóricas), FSQ, DCWM"),
        (2, "Estructura del latente", "factores de OPF (JEPA-Anything), slots de objetos"),
        (3, "Elección de predictor", "K cabezas de MoP-JEPA, código de azar de Stochastic MuZero"),
        (4, "Objetivo o pérdida", "two-hot de DreamerV3, HL-Gauss, entropía cruzada de DCWM"),
        (5, "Acciones", "acciones latentes VQ (Genie) frente a continuas (Garrido et al.)"),
    ]
    for i, (n, que, ej) in enumerate(filas):
        yy = 2.75 - i * 0.6
        marcador(ax, 0.35, yy, n, r=0.19, size=6.8)
        ax.text(0.7, yy, que, va="center", fontsize=7.5, weight="bold", color=TINTA)
        ax.text(3.55, yy, ej, va="center", fontsize=7.3, color=GRIS)
    guardar(fig, "f07_donde")


def f08_onehot_vs_vector():
    fig, axs = plt.subplots(1, 2, figsize=(ANCHO, 2.0))
    nombres = ["izq.", "centro", "der."]
    axs[0].set_title("One-hot\ntodos a la misma distancia", color=NARANJA)
    axs[1].set_title("Vectores del diccionario\nconservan el orden", color=NARANJA)
    ax = axs[0]
    v = np.array([[0, 0], [1, 0], [0.5, np.sqrt(3) / 2]])
    ax.add_patch(Polygon(v, closed=True, fc="none", ec=GRIS_CLARO, lw=0.8))
    for (a, b) in [(0, 1), (1, 2), (0, 2)]:
        m = (v[a] + v[b]) / 2
        ax.text(m[0] + (0.06 if a or b == 2 else 0), m[1] - (0.09 if (a, b) == (0, 1) else -0.02),
                "$\\sqrt{2}$", ha="center", va="center", fontsize=7.5, color=GRIS)
    codigos = ["(1,0,0)", "(0,1,0)", "(0,0,1)"]
    offs = [(-0.02, -0.17), (0.02, -0.17), (0, 0.1)]
    for p, n, c, o in zip(v, nombres, codigos, offs):
        ax.scatter(*p, s=40, color=NARANJA, edgecolor="white", lw=0.8, zorder=3)
        ax.text(p[0] + o[0], p[1] + o[1], f"{n}\n{c}", ha="center",
                va="top" if o[1] < 0 else "bottom", fontsize=6.8, linespacing=1.15)
    ax.set_xlim(-0.35, 1.35)
    ax.set_ylim(-0.45, 1.15)

    ax = axs[1]
    p = np.array([[0, 0.45], [0.5, 0.45], [1.0, 0.45]])
    ax.plot(p[:, 0], p[:, 1], color=GRIS_CLARO, lw=0.8, zorder=1)
    for q, n in zip(p, nombres):
        ax.scatter(*q, s=40, color=NARANJA, edgecolor="white", lw=0.8, zorder=3)
        ax.text(q[0], q[1] - 0.1, n, ha="center", va="top", fontsize=6.8)
    ax.annotate("", xy=(0.48, 0.58), xytext=(0.02, 0.58),
                arrowprops=dict(arrowstyle="<->", color=GRIS, lw=0.7))
    ax.text(0.25, 0.63, "cerca", ha="center", fontsize=7, color=GRIS)
    ax.annotate("", xy=(0.98, 0.18), xytext=(0.02, 0.18),
                arrowprops=dict(arrowstyle="<->", color=GRIS, lw=0.7))
    ax.text(0.5, 0.08, "lejos", ha="center", fontsize=7, color=GRIS, va="top")
    ax.set_xlim(-0.25, 1.25)
    ax.set_ylim(-0.1, 1.0)
    for ax in axs:
        ax.set_aspect("equal")
        ax.axis("off")
    fig.tight_layout(w_pad=1.0)
    guardar(fig, "f08_onehot_vs_vector")


def f09_ste():
    fig, axs = plt.subplots(1, 2, figsize=(ANCHO, 1.95))
    z = np.linspace(-2.4, 2.4, 2000)
    ax = axs[0]
    ejes_limpios(ax)
    ax.plot(z, z, ls="--", color=AZUL, lw=1.0, label="identidad (lo que el STE finge)")
    ax.plot(z, np.round(z), color=NARANJA, lw=1.6, label="redondeo $q(z)$")
    ax.set_xlabel("$z$ (salida del codificador)")
    ax.set_ylabel("valor que sigue")
    ax.set_title("Hacia adelante: se redondea")
    ax.legend(frameon=False, loc="lower right", fontsize=6.5, handlelength=1.6)
    ax = axs[1]
    ejes_limpios(ax)
    ax.plot(z, np.zeros_like(z), color=NARANJA, lw=1.6, label="derivada real de $q$: 0")
    ax.plot(z, np.ones_like(z), ls="--", color=AZUL, lw=1.0, label="derivada usada por el STE: 1")
    for s in np.arange(-1.5, 2.0, 1.0):
        ax.vlines(s, 0, 1.5, color=NARANJA, lw=0.6, linestyles=":")
    ax.set_ylim(-0.25, 1.6)
    ax.set_xlabel("$z$")
    ax.set_ylabel("pendiente")
    ax.set_title("Hacia atrás: se copia el gradiente")
    ax.legend(frameon=False, loc="upper left", fontsize=6.5, handlelength=1.6)
    fig.tight_layout(w_pad=1.2)
    guardar(fig, "f09_ste")


# ---------------------------------------------------------------------------
# Capítulo IV: evidencia
# ---------------------------------------------------------------------------

def f10_rssm():
    fig, ax = lienzo(3.2, ymax=6.15)
    xs = [1.5, 5.0, 8.5]
    etiquetas = ["t-1", "t", "t+1"]
    for x, e in zip(xs, etiquetas):
        caja(ax, x - 0.5, 4.5, 1.0, 0.8, f"$h_{{{e}}}$", fc=GRIS_F, ec=GRIS, size=8)
        ax.add_patch(Circle((x, 3.2), 0.45, fc=NARANJA_F, ec=NARANJA, lw=0.9))
        ax.text(x, 3.2, f"$z_{{{e}}}$", ha="center", va="center", fontsize=8)
        caja(ax, x - 0.4, 1.75, 0.8, 0.6, f"$x_{{{e}}}$", size=7.5)
        flecha(ax, (x, 4.5), (x, 3.65), color=GRIS)
        flecha(ax, (x, 2.35), (x, 2.75), color=GRIS)
    for i in range(2):
        flecha(ax, (xs[i] + 0.5, 4.9), (xs[i + 1] - 0.5, 4.9), color=GRIS)
        flecha(ax, (xs[i] + 0.4, 3.45), (xs[i + 1] - 0.55, 4.6), color=GRIS)
        ax.text((xs[i] + xs[i + 1]) / 2, 5.45, f"acción $a_{{{etiquetas[i]}}}$", ha="center",
                fontsize=7, color=GRIS)
        flecha(ax, ((xs[i] + xs[i + 1]) / 2, 5.35), ((xs[i] + xs[i + 1]) / 2, 4.95), color=GRIS,
               lw=0.6)
    ax.text(0.05, 4.9, "determinista", fontsize=6.8, color=GRIS, va="center", rotation=90)
    ax.text(0.05, 3.2, "estocástico", fontsize=6.8, color=NARANJA, va="center", rotation=90)
    ax.text(0.05, 2.05, "imagen", fontsize=6.8, color=GRIS, va="center", rotation=90)
    # recuadros comparativos
    ax.text(2.4, 1.25, "PlaNet / DreamerV1: $z$ gaussiana", ha="center", fontsize=7.5,
            color=AZUL, weight="bold")
    t = np.linspace(-3, 3, 100)
    for j, (mu, s) in enumerate([(0.0, 0.9), (0.6, 0.6), (-0.5, 1.2)]):
        x0 = 0.6 + j * 1.25
        ax.plot(x0 + 0.17 * (t + 3), 0.1 + 0.85 * np.exp(-((t - mu) ** 2) / (2 * s ** 2)),
                color=AZUL, lw=1.0)
    ax.text(7.4, 1.25, "DreamerV2: 32 categóricas × 32 clases", ha="center", fontsize=7.5,
            color=NARANJA, weight="bold")
    rng = np.random.default_rng(5)
    celda = 0.034
    x0, y0 = 5.75, 0.02
    ax.add_patch(Rectangle((x0, y0), 32 * celda, 32 * celda, fc="white", ec=GRIS, lw=0.5))
    for fila in range(32):
        col = rng.integers(32)
        ax.add_patch(Rectangle((x0 + col * celda, y0 + (31 - fila) * celda), celda, celda,
                               fc=NARANJA, ec="none"))
    ax.text(x0 + 32 * celda + 0.15, y0 + 16 * celda,
            "cada fila: una variable\ncon un solo 1 (one-hot)\n→ vector de 1024 bits\ncon 32 unos",
            fontsize=6.5, va="center", color=GRIS, linespacing=1.2)
    guardar(fig, "f10_rssm")


def f11_codificaciones():
    fig = plt.figure(figsize=(ANCHO, 2.35))
    axg = fig.add_axes([0.0, 0.18, 0.2, 0.64])
    n = 5
    for i in range(n + 1):
        axg.plot([0, n], [i, i], color=GRIS_CLARO, lw=0.6)
        axg.plot([i, i], [0, n], color=GRIS_CLARO, lw=0.6)
    axg.add_patch(Rectangle((4, 0), 1, 1, fc=AQUA_F, ec="none"))
    axg.add_patch(Rectangle((2, 1), 1, 3, fc=GRIS, ec="none"))
    axg.add_patch(Polygon([[0.25, 3.2], [0.25, 3.8], [0.8, 3.5]], closed=True, fc=ROJO, ec="none"))
    axg.set_xlim(-0.1, n + 0.1)
    axg.set_ylim(-0.1, n + 0.1)
    axg.set_aspect("equal")
    axg.axis("off")
    axg.set_title("el mismo estado", fontsize=7.5, color=GRIS)

    ax = fig.add_axes([0.26, 0.0, 0.74, 1.0])
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 4.6)
    ax.axis("off")
    rng = np.random.default_rng(11)
    filas = [
        ("Continua densa (AE)", AZUL, rng.uniform(0.15, 1.0, 16)),
        ("Continua esparsa (FTA)", AZUL, np.where(np.isin(np.arange(16), [2, 3, 9, 14]),
                                                  [0, 0, 0.6, 1.0, 0, 0, 0, 0, 0, 0.9, 0, 0, 0,
                                                   0, 0.35, 0], 0)),
        ("Multi-one-hot (VQ, índices)", NARANJA, np.array([0, 1, 0, 0, 0, 0, 0, 1,
                                                          1, 0, 0, 0, 0, 0, 1, 0], float)),
        ("Cuantizada (VQ, vectores)", NARANJA, rng.uniform(0.15, 1.0, 16)),
    ]
    w = 0.33
    for i, (nombre, color, vals) in enumerate(filas):
        y = 3.75 - i * 1.0
        ax.text(0.0, y + 0.17, nombre, fontsize=7.3, va="center", color=TINTA)
        for j, v in enumerate(vals):
            gap = 0.12 if (i >= 2 and j % 4 == 0 and j) else 0
            x = 4.0 + j * w + (j // 4) * 0.12 * (i >= 2)
            ax.add_patch(Rectangle((x, y), w * 0.92, 0.36, fc=color if v > 0 else "white",
                                   alpha=float(min(1.0, 0.15 + 0.85 * v)) if v > 0 else 1.0,
                                   ec=GRIS_CLARO, lw=0.4))
    ax.plot([9.75, 9.85, 9.85, 9.75], [1.93, 1.93, 0.6, 0.6], color=NARANJA, lw=0.8)
    ax.text(9.95, 1.27, "misma\ninformación,\ndistinta\nforma", fontsize=6.4, va="center",
            color=NARANJA, linespacing=1.15)
    guardar(fig, "f11_codificaciones")


def f12_capacidad():
    fig, ax = plt.subplots(figsize=(ANCHO, 2.0))
    ejes_limpios(ax)
    s = np.linspace(0, 1, 300)
    cont = 0.08 + 0.92 / (1 + np.exp(14 * (s - 0.62)))
    disc = 0.08 + 0.92 / (1 + np.exp(14 * (s - 0.35)))
    ax.fill_between(s, disc, cont, color=NARANJA_F, lw=0)
    ax.plot(s, cont, color=AZUL, lw=2)
    ax.plot(s, disc, color=NARANJA, lw=2)
    ax.text(0.62, 0.72, "continua", color=AZUL, fontsize=7.5)
    ax.text(0.10, 0.55, "discreta\n(multi-one-hot)", color=NARANJA, fontsize=7.5)
    ax.text(0.50, 0.42, "ventaja de\nlo discreto", ha="center", fontsize=7, color=GRIS)
    ax.text(0.97, 0.45, "con un modelo grande\nlas curvas se juntan", ha="right", fontsize=7,
            color=GRIS)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.set_xlabel("capacidad del modelo del mundo →")
    ax.set_ylabel("error del modelo →")
    ax.set_title("Esquema cualitativo (inspirado en Meyer et al., fig. 3)", color=GRIS,
                 style="italic")
    guardar(fig, "f12_capacidad")


def f13_promediar_elegir():
    fig, ax = plt.subplots(figsize=(ANCHO, 2.15))
    ax.set_aspect("equal")
    ax.axis("off")
    rng = np.random.default_rng(2)
    a = np.array([3.0, 1.1]) + 0.13 * rng.standard_normal((40, 2))
    b = np.array([3.0, -1.1]) + 0.13 * rng.standard_normal((40, 2))
    ax.scatter(*a.T, s=5, color=GRIS, alpha=0.7, lw=0)
    ax.scatter(*b.T, s=5, color=GRIS, alpha=0.7, lw=0)
    ax.text(3.35, 1.1, "futuro A", va="center", fontsize=7.5)
    ax.text(3.35, -1.1, "futuro B", va="center", fontsize=7.5)
    ax.scatter([0], [0], s=40, color=TINTA, zorder=3)
    ax.text(-0.15, 0, "contexto", ha="right", va="center", fontsize=7.5)
    ax.annotate("", xy=(2.9, 0.0), xytext=(0.1, 0),
                arrowprops=dict(arrowstyle="-|>", color=AZUL, lw=1.3))
    ax.plot([3.0], [0.0], marker="X", color=AZUL, ms=9, mec="white", mew=0.8)
    ax.text(3.2, 0.0, "predictor MSE: el promedio\n(un estado que no ocurre)", va="center",
            fontsize=7.3, color=AZUL)
    ax.annotate("", xy=(2.8, 1.05), xytext=(0.1, 0.08),
                arrowprops=dict(arrowstyle="-|>", color=NARANJA, lw=1.3,
                                connectionstyle="arc3,rad=-0.15"))
    ax.annotate("", xy=(2.8, -1.05), xytext=(0.1, -0.08),
                arrowprops=dict(arrowstyle="-|>", color=NARANJA, lw=1.3,
                                connectionstyle="arc3,rad=0.15"))
    ax.text(1.2, 1.0, "cabeza 1", fontsize=7.3, color=NARANJA, ha="center")
    ax.text(1.2, -1.07, "cabeza 2", fontsize=7.3, color=NARANJA, ha="center")
    ax.set_xlim(-1.4, 6.4)
    ax.set_ylim(-1.55, 1.55)
    guardar(fig, "f13_promediar_elegir")


def f14_mar():
    fig, ax = lienzo(1.95, ymax=3.75)
    ax.text(0.05, 3.45, "(a) Token discreto", fontsize=7.8, weight="bold", color=NARANJA)
    y = 2.3
    caja(ax, 0.05, y, 1.7, 0.85, "Transformer", fc=GRIS_F)
    caja(ax, 2.15, y, 1.9, 0.85, "logits sobre\nK códigos", fc=NARANJA_F, ec=NARANJA, size=7.3)
    caja(ax, 4.45, y, 1.6, 0.85, "pérdida:\nentropía cruzada", fc=NARANJA_F, ec=NARANJA, size=7)
    caja(ax, 6.45, y, 1.5, 0.85, "índice $k$", fc=NARANJA_F, ec=NARANJA, size=7.3)
    caja(ax, 8.35, y, 1.6, 0.85, "token $e_k$\n(del diccionario)", fc=NARANJA_F, ec=NARANJA,
         size=7)
    for x0, x1 in [(1.75, 2.15), (4.05, 4.45), (6.05, 6.45), (7.95, 8.35)]:
        flecha(ax, (x0, y + 0.42), (x1, y + 0.42))
    ax.text(0.05, 1.55, "(b) Token continuo (MAR)", fontsize=7.8, weight="bold", color=AZUL)
    y = 0.4
    caja(ax, 0.05, y, 1.7, 0.85, "Transformer", fc=GRIS_F)
    caja(ax, 2.15, y, 1.9, 0.85, "condición $c$", fc=AZUL_F, ec=AZUL, size=7.3)
    caja(ax, 4.45, y, 3.5, 0.85, "MLP pequeña que quita ruido\n(pérdida de difusión)", fc=AZUL_F,
         ec=AZUL, size=7)
    caja(ax, 8.35, y, 1.6, 0.85, "token $x \\in \\mathbb{R}^d$", fc=AZUL_F, ec=AZUL, size=7)
    for x0, x1 in [(1.75, 2.15), (4.05, 4.45), (7.95, 8.35)]:
        flecha(ax, (x0, y + 0.42), (x1, y + 0.42))
    guardar(fig, "f14_mar")


# ---------------------------------------------------------------------------
# Capítulo V: seguir el error
# ---------------------------------------------------------------------------

def f15_error_o_estado():
    fig, axs = plt.subplots(2, 1, figsize=(ANCHO, 2.2))
    for ax in axs:
        ax.set_xlim(-0.3, 4.3)
        ax.set_ylim(-0.6, 1.1)
        ax.axis("off")
        ax.plot([-0.2, 4.2], [0, 0], color=GRIS, lw=0.8)
        for k in range(5):
            ax.text(k, -0.32, str(k), ha="center", va="top", fontsize=7, color=GRIS)
    ax = axs[0]
    ax.fill_between([-0.2, 4.2], -0.06, 0.06, color=AZUL_F, lw=0)
    ax.text(-0.3, 0.95, "(a) Continuo: todo punto es un estado válido", fontsize=7.8,
            color=AZUL, weight="bold", va="top")
    ax.scatter([1.0], [0], s=26, color=GRIS, zorder=3)
    ax.scatter([1.27], [0], s=26, color=AZUL, zorder=3)
    ax.annotate("valor real 1,00", xy=(1.0, 0.05), xytext=(0.35, 0.3), fontsize=7, color=GRIS,
                ha="center", arrowprops=dict(arrowstyle="-", color=GRIS, lw=0.6))
    ax.annotate("valor con error 1,27: también es un estado\nposible, así que no hay ninguna alarma",
                xy=(1.27, 0.05), xytext=(2.85, 0.22), fontsize=7, color=AZUL, ha="center",
                arrowprops=dict(arrowstyle="-", color=AZUL, lw=0.6))
    ax = axs[1]
    ax.text(-0.3, 0.95, "(b) Discreto: solo los enteros son estados válidos", fontsize=7.8,
            color=NARANJA, weight="bold", va="top")
    ax.scatter(range(5), [0] * 5, s=30, color=NARANJA, zorder=3, edgecolor="white", lw=0.8)
    ax.scatter([1.27], [0], s=26, color=AZUL, zorder=4)
    ax.annotate("", xy=(1.05, 0.08), xytext=(1.25, 0.08),
                arrowprops=dict(arrowstyle="-|>", color=NARANJA, lw=0.9))
    ax.annotate("1,27 no es un estado: hay un error (se detecta)\ny se redondea a 1 (se corrige)",
                xy=(1.27, 0.05), xytext=(2.85, 0.22), fontsize=7, color=NARANJA, ha="center",
                arrowprops=dict(arrowstyle="-", color=NARANJA, lw=0.6))
    fig.tight_layout(h_pad=0.3)
    guardar(fig, "f15_error_o_estado")


def f16_zonas():
    fig, axs = plt.subplots(1, 2, figsize=(ANCHO, 2.3), gridspec_kw={"width_ratios": [1, 1.35]})
    ax = axs[0]
    d, r = 1.0, 0.3
    ax.add_patch(Rectangle((-0.55, -0.55), 3.1, 2.1, fc=GRIS_F, ec="none"))
    for i in range(3):
        for j in range(2):
            ax.add_patch(Circle((i * d, j * d), r, fc=AQUA_F, ec=AQUA, lw=0.6))
            ax.scatter([i * d], [j * d], s=14, color=NARANJA, zorder=3)
    ax.text(0, -0.08, "A", ha="center", va="top", fontsize=7.5, weight="bold")
    ax.text(1, -0.08, "B", ha="center", va="top", fontsize=7.5, weight="bold")
    recibidos = [((0.17, 0.12), AQUA, "✓"), ((0.5, 0.18), GRIS, "?"), ((0.86, 0.08), ROJO, "✗")]
    for (x, y), c, s in recibidos:
        ax.scatter([x], [y], s=16, color=c, marker="D", zorder=4, edgecolor="white", lw=0.5)
        ax.text(x, y + 0.13, s, ha="center", va="bottom", fontsize=8, color=c, weight="bold")
    ax.annotate("", xy=(1.0, 1.42), xytext=(0.0, 1.42),
                arrowprops=dict(arrowstyle="<->", color=GRIS, lw=0.7))
    ax.text(0.5, 1.47, "separación $d$", ha="center", va="bottom", fontsize=7, color=GRIS)
    ax.set_xlim(-0.6, 2.6)
    ax.set_ylim(-0.6, 1.75)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_title("Se envía A; se recibe un punto con ruido", fontsize=7.5)

    ax = axs[1]
    ejes_limpios(ax)
    x = np.linspace(-0.45, 1.45, 600)
    sigma = 0.22
    dens = np.exp(-x ** 2 / (2 * sigma ** 2)) / (sigma * np.sqrt(2 * np.pi))
    zonas = [(-0.45, r, AQUA_F, AQUA, "se\ncorrige"), (r, d - r, GRIS_F, GRIS, "se\ndetecta"),
             (d - r, 1.45, ROJO_F, ROJO, "error\nsilencioso")]
    for a, b, fc, c, t in zonas:
        ax.axvspan(a, b, color=fc, lw=0)
        ax.text((max(a, -0.2) + min(b, 1.3)) / 2, 2.55, t, ha="center", va="top", fontsize=6.8,
                color=c, weight="bold", linespacing=1.1)
    ax.plot(x, dens, color=TINTA, lw=1.0)
    ax.axvline(0, color=NARANJA, lw=0.8)
    ax.axvline(d, color=NARANJA, lw=0.8)
    ax.set_xticks([0, r, 0.5, d - r, d], ["A", "$r$", "$d/2$", "$d-r$", "B"])
    ax.set_yticks([])
    ax.set_ylim(0, 2.6)
    ax.set_xlabel("posición recibida, sobre el segmento de A a B")
    ax.set_title("Ruido centrado en A: dónde cae la masa", fontsize=7.5)
    fig.tight_layout(w_pad=1.0)
    guardar(fig, "f16_zonas")


def f17_trayectorias():
    rng = np.random.default_rng(7)
    T, n, sigma = 60, 30, 0.18
    ruido = sigma * rng.standard_normal((n, T))
    cont = np.cumsum(ruido, axis=1)
    disc = np.zeros((n, T))
    e = np.zeros(n)
    for t in range(T):
        e = np.round(e + ruido[:, t])
        disc[:, t] = e
    t = np.arange(1, T + 1)
    fig, axs = plt.subplots(1, 2, figsize=(ANCHO, 2.0), sharey=True)
    for ax, datos, c, tit in [(axs[0], cont, AZUL, "Continuo: el error se acumula"),
                              (axs[1], disc, NARANJA, "Discreto: el error es 0 o un salto")]:
        ejes_limpios(ax)
        ax.axhspan(-0.5, 0.5, color=GRIS_F, lw=0)
        for fila in datos:
            ax.plot(t, fila, color=c, lw=0.8, alpha=0.55, drawstyle="default" if c == AZUL
                    else "steps-post")
        ax.set_title(tit, color=c)
        ax.set_xlabel("paso del rollout $t$")
        ax.set_ylim(-3.2, 3.2)
    axs[0].set_ylabel("error (en unidades de $d$)")
    axs[1].text(2, -2.4, "banda gris: tolerancia $\\pm d/2$", fontsize=6.5, color=GRIS)
    exactas = int(np.sum(np.all(disc == 0, axis=1)))
    axs[1].text(59, 3.0, f"{exactas} de {n} trayectorias\nsin ningún error",
                ha="right", va="top", fontsize=6.8, color=NARANJA)
    fig.tight_layout(w_pad=0.8)
    guardar(fig, "f17_trayectorias")


def _prob_cero_discreto(s, T_max):
    """P(error = 0 en el paso T) cuando el error entero recibe en cada paso round(ruido).

    Como el error ya es entero, round(e + ruido) = e + round(ruido): el error es una
    caminata aleatoria sobre los enteros. Se calcula por convolución exacta.
    """
    k = np.arange(-6, 7)
    fi = lambda u: 0.5 * (1 + erf(u / np.sqrt(2)))
    paso = fi((k + 0.5) / s) - fi((k - 0.5) / s)
    rango = 6 * T_max if s > 0.3 else 200
    dist = np.zeros(2 * rango + 1)
    dist[rango] = 1.0
    out = []
    for _ in range(T_max):
        dist = np.convolve(dist, paso, mode="same")
        out.append(dist[rango])
    return np.array(out)


def f18_prob_exacta():
    T_max = 1000
    T = np.arange(1, T_max + 1)
    fig, ax = plt.subplots(figsize=(ANCHO, 2.15))
    ejes_limpios(ax)
    for s, alfa in [(0.15, 1.0), (0.25, 0.5)]:
        et = f"{s:.2f}".replace(".", ",")
        disc = _prob_cero_discreto(s, T_max)
        cont = erf(0.5 / (s * np.sqrt(2 * T)))
        ax.plot(T, disc, color=NARANJA, lw=1.8, alpha=alfa,
                label=f"discreto, σ = {et}·d: P(error = 0)")
        ax.plot(T, cont, color=AZUL, lw=1.8, ls="--", alpha=alfa,
                label=f"continuo, σ = {et}·d: P(|error| < d/2)")
    ax.set_xscale("log")
    ax.set_xlabel("largo del rollout $T$ (pasos)")
    ax.set_ylabel("probabilidad")
    ax.set_ylim(0, 1.05)
    ax.legend(frameon=False, loc="upper center", bbox_to_anchor=(0.5, -0.28), ncol=2,
              fontsize=6.5)
    guardar(fig, "f18_prob_exacta")


def f19_localizar():
    fig, ax = lienzo(1.95, ymax=3.75)
    ax.text(0.05, 3.5, "(a) Cadena discreta: cada paso se compara exactamente", fontsize=7.8,
            weight="bold", color=NARANJA)
    pred = ["A", "C", "F", "B", "E", "E", "D", "A"]
    real = ["A", "C", "F", "B", "D", "E", "D", "A"]
    xs = np.linspace(0.6, 9.4, 8)
    for i, (x, p, r) in enumerate(zip(xs, pred, real)):
        if i < 4:
            fc, ec, marca, c = AQUA_F, AQUA, "✓", AQUA
        elif i == 4:
            fc, ec, marca, c = ROJO_F, ROJO, "✗", ROJO
        else:
            fc, ec, marca, c = "#fdeeee", "#efb3b3", "?", "#d98c8c"
        caja(ax, x - 0.38, 2.45, 0.76, 0.7, p, fc=fc, ec=ec, size=8.5)
        ax.text(x, 2.2, f"real: {r}", ha="center", va="top", fontsize=6.3, color=GRIS)
        ax.text(x + 0.3, 3.1, marca, ha="center", va="center", fontsize=8, color=c,
                weight="bold")
        if i < 7:
            flecha(ax, (x + 0.38, 2.8), (xs[i + 1] - 0.38, 2.8), color=GRIS, lw=0.6, mut=6)
    ax.text(xs[6], 3.5, "primer error: paso 5", fontsize=7, color=ROJO, ha="center",
            va="center", weight="bold")
    ax.text(0.05, 1.45, "(b) Cadena continua: el error crece sin un culpable claro",
            fontsize=7.8, weight="bold", color=AZUL)
    errores = [0.02, 0.05, 0.07, 0.12, 0.16, 0.21, 0.29, 0.37]
    cmap = matplotlib.colormaps["Blues"]
    for x, e in zip(xs, errores):
        ax.add_patch(Circle((x, 0.65), 0.33, fc=cmap(0.15 + 1.8 * e), ec=AZUL, lw=0.6))
        ax.text(x, 0.65, f"{e:.2f}".replace(".", ","), ha="center", va="center", fontsize=6.5,
                color="white" if e > 0.25 else TINTA)
    for i in range(7):
        flecha(ax, (xs[i] + 0.33, 0.65), (xs[i + 1] - 0.33, 0.65), color=GRIS, lw=0.6, mut=6)
    ax.text(5.0, 0.12, "error acumulado en cada paso: ¿dónde empezó?", ha="center",
            fontsize=6.8, color=GRIS, style="italic")
    guardar(fig, "f19_localizar")


# ---------------------------------------------------------------------------
# Capítulo VI: ¿es la discretización?
# ---------------------------------------------------------------------------

def f20_matriz():
    filas = ["1 Capacidad", "2 Geometría", "3 Pérdida", "4 Elegir entre modos", "5 Redondeo",
             "6 Identidad exacta", "Estimador del gradiente"]
    cols = ["Meyer: one-hot o vector", "Meyer: tamaño del modelo", "DCWM: ablaciones",
            "St. MuZero: Go o 2048", "MoP-JEPA: K cabezas", "MAR: mismo tokenizador",
            "Garrido: VQ o ruido", "I-JEPA: ancho predictor", "Discrete-JEPA: horizonte",
            "Rotation trick"]
    # 2 = aísla la pieza; 1 = la toca sin aislarla
    m = np.zeros((len(filas), len(cols)), int)
    m[0, 1] = 1; m[0, 5] = 1; m[0, 6] = 2; m[0, 7] = 2
    m[1, 0] = 2; m[1, 2] = 2
    m[2, 0] = 1; m[2, 2] = 2; m[2, 5] = 2
    m[3, 2] = 2; m[3, 3] = 2; m[3, 4] = 2; m[3, 5] = 1
    m[4, 1] = 1; m[4, 8] = 1
    m[6, 9] = 2
    fig, ax = plt.subplots(figsize=(ANCHO, 3.0))
    ax.set_xlim(-0.5, len(cols) - 0.5)
    ax.set_ylim(len(filas) - 0.5, -0.5)
    for i in range(len(filas)):
        ax.axhline(i + 0.5, color=GRIS_CLARO, lw=0.5)
        for j in range(len(cols)):
            if m[i, j] == 2:
                ax.scatter(j, i, s=70, color=NARANJA, zorder=3)
            elif m[i, j] == 1:
                ax.scatter(j, i, s=70, facecolor="white", edgecolor=NARANJA, lw=1.3, zorder=3)
    ax.add_patch(Rectangle((-0.5, 4.5), len(cols), 1, fc=ROJO_F, ec="none", zorder=0))
    ax.text(len(cols) / 2 - 0.5, 5, "ningún experimento la aísla", ha="center", va="center",
            fontsize=7, color=ROJO, style="italic")
    ax.set_yticks(range(len(filas)), filas)
    ax.set_xticks(range(len(cols)), cols, fontsize=6.3, rotation=40, ha="left",
                  rotation_mode="anchor")
    ax.xaxis.tick_top()
    ax.tick_params(length=0)
    for s in ax.spines.values():
        s.set_visible(False)
    ax.scatter([], [], s=50, color=NARANJA, label="aísla la pieza")
    ax.scatter([], [], s=50, facecolor="white", edgecolor=NARANJA, lw=1.3,
               label="la toca, sin aislarla")
    ax.legend(frameon=False, loc="upper center", bbox_to_anchor=(0.4, -0.02), ncol=2,
              fontsize=7)
    guardar(fig, "f20_matriz")


def f21_cubo():
    fig, ax = lienzo(2.55, ymax=4.9)
    o = np.array([1.2, 0.6])
    ex, ey, ez = np.array([2.6, 0]), np.array([0, 2.1]), np.array([1.25, 0.95])
    P = lambda a, b, c: o + a * ex + b * ey + c * ez
    aristas = [((0, 0, 0), (1, 0, 0)), ((0, 0, 0), (0, 1, 0)), ((0, 0, 0), (0, 0, 1)),
               ((1, 0, 0), (1, 1, 0)), ((1, 0, 0), (1, 0, 1)), ((0, 1, 0), (1, 1, 0)),
               ((0, 1, 0), (0, 1, 1)), ((0, 0, 1), (1, 0, 1)), ((0, 0, 1), (0, 1, 1)),
               ((1, 1, 0), (1, 1, 1)), ((1, 0, 1), (1, 1, 1)), ((0, 1, 1), (1, 1, 1))]
    for a, b in aristas:
        pa, pb = P(*a), P(*b)
        oculta = (a == (0, 0, 1) and b == (0, 1, 1)) or (a == (0, 0, 1) and b == (1, 0, 1)) \
            or (a == (0, 0, 0) and b == (0, 0, 1))
        ax.plot([pa[0], pb[0]], [pa[1], pb[1]], color=GRIS, lw=0.8, ls=":" if oculta else "-")
    for a in (0, 1):
        for b in (0, 1):
            for c in (0, 1):
                p = P(a, b, c)
                ax.add_patch(Circle(p, 0.13, fc=NARANJA if a else AZUL, ec="white", lw=0.8,
                                    zorder=3))
    ax.text(*(P(0.5, 0, 0) + [0, -0.38]), "representación: continua → discreta", ha="center",
            fontsize=7.3)
    ax.text(*(P(0, 0.5, 0) + [-0.3, 0]), "capacidad:\nlibre → igualada", ha="right",
            va="center", fontsize=7.3)
    ax.text(*(P(1, 0, 0.5) + [0.25, -0.12]), "pérdida:\nMSE → CE", ha="left", va="center",
            fontsize=7.3)
    caja(ax, 6.6, 2.75, 3.25, 1.75,
         "× entorno\n(determinista / estocástico)\n× horizonte\n(1 paso / 30 pasos)",
         fc=MORADO_F, ec=MORADO, size=7.2)
    caja(ax, 6.6, 0.5, 3.25, 1.75, "dentro de lo discreto:\n× geometría\n(one-hot / vector)",
         fc=NARANJA_F, ec=NARANJA, size=7.2)
    guardar(fig, "f21_cubo")


def f22_principio():
    rng = np.random.default_rng(4)
    fig, axs = plt.subplots(1, 3, figsize=(ANCHO, 1.95))
    titulos = ["(a) Continuo sin margen", "(b) Continuo con margen\ne invarianza",
               "(c) Discreto"]
    for k, ax in enumerate(axs):
        if k == 0:
            a = np.array([-0.35, 0]) + rng.normal(0, [0.28, 0.5], (40, 2))
            b = np.array([0.35, 0]) + rng.normal(0, [0.28, 0.5], (40, 2))
        elif k == 1:
            a = np.array([-0.9, 0]) + rng.normal(0, [0.12, 0.12], (40, 2))
            b = np.array([0.9, 0]) + rng.normal(0, [0.12, 0.12], (40, 2))
        else:
            a = np.tile([-0.9, 0], (40, 1))
            b = np.tile([0.9, 0], (40, 1))
        c = AZUL if k < 2 else NARANJA
        ax.scatter(*a.T, s=9, color=c, marker="o", lw=0, alpha=0.8)
        ax.scatter(*b.T, s=11, color=c, marker="^", lw=0, alpha=0.8)
        ax.axvline(0, color=GRIS, lw=0.6, ls="--")
        x0 = a[np.argmax(a[:, 0])] if k == 0 else np.array([-0.9, 0.0]) + [0.12, 0.0]
        dx = 0.55
        ax.annotate("", xy=(x0[0] + dx, x0[1] + 0.05), xytext=(x0[0], x0[1]),
                    arrowprops=dict(arrowstyle="-|>", color=ROJO, lw=1.0))
        if k == 0:
            ax.text(0.05, -1.3, "el ruido cruza\nla frontera", fontsize=6.5, color=ROJO)
        elif k == 1:
            ax.text(-0.75, -0.85, "el ruido no\nalcanza a cruzar", fontsize=6.5, color=ROJO)
        else:
            ax.text(-0.75, -0.85, "y además se\nredondea de vuelta", fontsize=6.5, color=ROJO)
        ax.set_title(titulos[k], fontsize=7.6)
        ax.set_xlim(-1.6, 1.6)
        ax.set_ylim(-1.6, 1.6)
        ax.set_aspect("equal")
        ax.set_xticks([])
        ax.set_yticks([])
        for s in ax.spines.values():
            s.set_visible(True)
            s.set_color(GRIS_CLARO)
    fig.tight_layout(w_pad=0.6)
    guardar(fig, "f22_principio")


# ---------------------------------------------------------------------------
# Capítulo VII: colapso
# ---------------------------------------------------------------------------

def f23_colapsos():
    rng = np.random.default_rng(8)
    fig, axs = plt.subplots(2, 3, figsize=(ANCHO, 3.35))
    axs = axs.ravel()
    t = np.linspace(-3, 3, 200)
    # 0 sano
    ax = axs[0]
    p = rng.normal(0, 0.9, (120, 2))
    ax.scatter(*p.T, s=4, color=AZUL, lw=0, alpha=0.8)
    ax.set_title("Referencia: sano", color=AQUA)
    # 1 posterior
    ax = axs[1]
    for mu in (-1.4, 0.0, 1.4):
        ax.plot(t, 1.2 * np.exp(-(t - mu) ** 2 / 0.18) - 1.4, color=GRIS_CLARO, lw=0.8)
    ax.plot(t, 2.3 * np.exp(-t ** 2 / 2) - 1.4, color=AZUL, lw=1.6)
    ax.text(0, 1.15, "$q(z|x) = p(z)$\npara todo $x$", ha="center", fontsize=6.5, color=AZUL)
    ax.set_title("Colapso posterior")
    # 2 completo
    ax = axs[2]
    ax.scatter(rng.normal(0.3, 0.03, 120), rng.normal(0.2, 0.03, 120), s=4, color=AZUL, lw=0)
    ax.text(0.3, -0.6, "todo en un punto", ha="center", fontsize=6.5, color=AZUL)
    ax.set_title("Colapso completo")
    # 3 dimensional
    ax = axs[3]
    u = rng.normal(0, 1.0, 120)
    ax.scatter(u, 0.55 * u + rng.normal(0, 0.05, 120), s=4, color=AZUL, lw=0)
    ax.text(0.2, -1.6, "todo sobre una recta", ha="center", fontsize=6.5, color=AZUL)
    ax.set_title("Colapso dimensional")
    # 4 diccionario
    ax = axs[4]
    datos = np.concatenate([np.array([-0.8, 0.4]) + 0.3 * rng.standard_normal((60, 2)),
                            np.array([0.7, -0.3]) + 0.3 * rng.standard_normal((60, 2))])
    vivos = np.array([[-0.8, 0.4], [0.7, -0.3]])
    muertos = np.array([[-1.6, -1.5], [1.6, 1.5], [-1.7, 1.6], [1.7, -1.6], [0.0, 1.8],
                        [0.0, -1.85]])
    ax.scatter(*datos.T, s=4, color=GRIS, lw=0, alpha=0.6)
    ax.scatter(*vivos.T, s=30, color=NARANJA, edgecolor="white", lw=0.8, zorder=3)
    ax.scatter(*muertos.T, s=24, facecolor="white", edgecolor=GRIS, lw=0.9, zorder=3)
    ax.text(0, -1.4, "2 de 8 códigos en uso", ha="center", fontsize=6.5, color=NARANJA)
    ax.set_title("Colapso del diccionario")
    # 5 neural
    ax = axs[5]
    v = np.array([[0, 1.3], [-1.13, -0.65], [1.13, -0.65]])
    for c, mk in zip(v, ["o", "^", "s"]):
        q = c + rng.normal(0, 0.06, (40, 2))
        ax.scatter(*q.T, s=6, color=AZUL, marker=mk, lw=0)
    ax.add_patch(Polygon(v, closed=True, fc="none", ec=GRIS_CLARO, lw=0.7, ls="--"))
    ax.text(0, -1.35, "clases en vértices\nequidistantes", ha="center", fontsize=6.5,
            color=AQUA, va="top")
    ax.set_title("Colapso neuronal (útil)", color=AQUA)
    for ax in axs:
        ax.set_xlim(-2.1, 2.1)
        ax.set_ylim(-2.1, 2.1)
        ax.set_aspect("equal")
        ax.set_xticks([])
        ax.set_yticks([])
        for s in ax.spines.values():
            s.set_visible(True)
            s.set_color(GRIS_CLARO)
    fig.tight_layout(h_pad=0.8, w_pad=0.5)
    guardar(fig, "f23_colapsos")


def f24_identificabilidad():
    x = np.linspace(-4, 4, 400)
    g = lambda m, s: np.exp(-(x - m) ** 2 / (2 * s ** 2)) / (s * np.sqrt(2 * np.pi))
    fig, axs = plt.subplots(1, 2, figsize=(ANCHO, 1.85), sharey=True)
    for ax, (m, tit, nota, col) in zip(axs, [
            (1.8, "Códigos bien separados", "ver $x$ revela $z$:\n$z$ es identificable", AQUA),
            (0.2, "Códigos casi iguales", "ver $x$ no revela $z$:\nel decoder puede ignorarlo",
             ROJO)]):
        ejes_limpios(ax)
        ax.fill_between(x, g(-m, 0.6), color=NARANJA, alpha=0.25, lw=0)
        ax.fill_between(x, g(m, 0.6), color=AZUL, alpha=0.25, lw=0)
        ax.plot(x, g(-m, 0.6), color=NARANJA, lw=1.3)
        ax.plot(x, g(m, 0.6), color=AZUL, lw=1.3)
        ax.text(-m - (0.0 if m > 1 else 0.6), 0.72, "$p(x|z=1)$", ha="center", fontsize=6.8,
                color=NARANJA)
        ax.text(m + (0.0 if m > 1 else 0.6), 0.72, "$p(x|z=2)$", ha="center", fontsize=6.8,
                color=AZUL)
        ax.text(0, 0.95, nota, ha="center", fontsize=6.8, color=col)
        ax.set_title(tit)
        ax.set_yticks([])
        ax.set_ylim(0, 1.2)
        ax.set_xlabel("$x$")
    fig.tight_layout(w_pad=1.0)
    guardar(fig, "f24_identificabilidad")


def f25_diccionario():
    rng = np.random.default_rng(12)
    fig, axs = plt.subplots(1, 2, figsize=(ANCHO, 2.1), gridspec_kw={"width_ratios": [1, 1.3]})
    ax = axs[0]
    datos = rng.normal(0, 0.45, (150, 2))
    vivos = np.array([[-0.35, 0.25], [0.4, 0.1], [0.0, -0.45]])
    muertos = np.array([[-1.5, 1.3], [1.5, 1.4], [1.4, -1.4], [-1.5, -1.2]])
    ax.scatter(*datos.T, s=4, color=GRIS, lw=0, alpha=0.6)
    for p in vivos:
        ax.scatter(*p, s=36, color=NARANJA, edgecolor="white", lw=0.8, zorder=3)
    for p in muertos:
        ax.scatter(*p, s=30, facecolor="white", edgecolor=GRIS, lw=1.0, zorder=3)
    ax.text(0, -1.85, "los códigos lejanos nunca son\nlos más cercanos: no se mueven",
            ha="center", fontsize=6.4, color=GRIS)
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2.1, 2)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_title("Códigos vivos y muertos")
    ax = axs[1]
    ejes_limpios(ax)
    n = np.arange(8, 17)
    # Esquema que respeta lo que reporta el paper: VQ no usa más de ~2^10 códigos
    # (bajo 50 % desde 2^11); FSQ usa casi todos hasta 2^14 y más de la mitad en 2^16.
    vq = np.minimum(0.97, 2.0 ** 10 / 2.0 ** n)
    fsq = np.where(n <= 14, 0.99, 0.99 - 0.22 * (n - 14))
    ax.plot(n, vq, color=NARANJA, lw=1.8, ls="--", marker="o", ms=3.5, label="VQ (aprendido)")
    ax.plot(n, fsq, color=NARANJA, lw=1.8, marker="s", ms=3.5, label="FSQ (grilla fija)")
    ax.axhline(0.5, color=GRIS_CLARO, lw=0.7)
    ax.set_xticks(n, [f"$2^{{{k}}}$" for k in n])
    ax.set_yticks([0, 0.5, 1], ["0 %", "50 %", "100 %"])
    ax.set_xlabel("tamaño del diccionario")
    ax.set_ylabel("códigos en uso")
    ax.set_title("Esquema según Mentzer et al. (2024)", style="italic", color=GRIS)
    ax.legend(frameon=False, fontsize=6.6, loc="lower left")
    fig.tight_layout(w_pad=0.8)
    guardar(fig, "f25_diccionario")


def f26_mapa_iterado():
    rng = np.random.default_rng(3)
    T = 25
    t = np.arange(T + 1)
    fig, axs = plt.subplots(1, 3, figsize=(ANCHO, 1.95), sharey=True)
    inicios = [0.9, 1.1, 2.9, 3.1]
    colores = [AZUL, AZUL, MORADO, MORADO]
    # (a) contracción
    ax = axs[0]
    for x0, c in zip(inicios, colores):
        x = [x0]
        for _ in range(T):
            x.append(0.85 * x[-1])
        ax.plot(t, x, color=c, lw=1.1)
    ax.set_title("(a) Contrae", color=AZUL, fontsize=7.6)
    # (b) expansión
    ax = axs[1]
    for x0, c in zip(inicios, colores):
        x = [x0]
        for _ in range(T):
            x.append(2.0 + 1.12 * (x[-1] - 2.0))
        ax.plot(t, np.clip(x, -1, 5), color=c, lw=1.1)
    ax.set_title("(b) Expande", color=AZUL, fontsize=7.6)
    # (c) escalera: el estado ruidoso se redondea al entero más cercano en cada paso
    ax = axs[2]
    for x0, c in zip(inicios, colores):
        x = [x0]
        for _ in range(T):
            x.append(np.round(x[-1] + rng.normal(0, 0.15)))
        ax.plot(t, x, color=NARANJA if c == AZUL else "#b5451b", lw=1.1, marker="o", ms=1.8)
    for k in range(0, 5):
        ax.axhline(k, color=GRIS_CLARO, lw=0.5, zorder=0)
    ax.set_title("(c) Escalera (redondeo)", color=NARANJA, fontsize=7.6)
    for ax in axs:
        ejes_limpios(ax)
        ax.set_ylim(-0.5, 4.6)
        ax.set_xlabel("iteración")
    axs[0].set_ylabel("estado")
    fig.tight_layout(w_pad=0.6)
    guardar(fig, "f26_mapa_iterado")


# ---------------------------------------------------------------------------
# Capítulo VIII: JEPA
# ---------------------------------------------------------------------------

def f27_jepa():
    fig, ax = lienzo(2.75, ymax=5.3)
    ax.text(0.05, 5.05, "(a) I-JEPA: un predictor", fontsize=7.8, weight="bold", color=AZUL)
    y = 3.35
    caja(ax, 0.05, y + 0.6, 1.3, 0.75, "contexto $x$", size=7)
    caja(ax, 1.7, y + 0.6, 1.9, 0.75, "codificador", fc=AZUL_F, ec=AZUL, size=7)
    caja(ax, 4.0, y + 0.6, 1.9, 0.75, "predictor", fc=AZUL_F, ec=AZUL, size=7)
    caja(ax, 6.3, y + 0.6, 1.0, 0.75, "$\\hat s_y$", fc=MORADO_F, ec=MORADO, size=7.5)
    caja(ax, 0.05, y - 0.45, 1.3, 0.75, "objetivo $y$", size=7)
    caja(ax, 1.7, y - 0.45, 1.9, 0.75, "codificador\nEMA", fc=GRIS_F, ec=GRIS, size=6.8)
    caja(ax, 6.3, y - 0.45, 1.0, 0.75, "$s_y$", fc=MORADO_F, ec=MORADO, size=7.5)
    caja(ax, 7.8, y + 0.05, 2.1, 0.85, "$\\|\\hat s_y - s_y\\|^2$", fc=GRIS_F, size=7.2)
    for p, q in [((1.35, y + 0.97), (1.7, y + 0.97)), ((3.6, y + 0.97), (4.0, y + 0.97)),
                 ((5.9, y + 0.97), (6.3, y + 0.97)), ((1.35, y - 0.07), (1.7, y - 0.07)),
                 ((3.6, y - 0.07), (6.3, y - 0.07)), ((7.3, y + 0.97), (7.8, y + 0.6)),
                 ((7.3, y - 0.07), (7.8, y + 0.3))]:
        flecha(ax, p, q)
    ax.text(0.05, 2.25, "(b) MoP-JEPA: K cabezas, se entrena solo la mejor", fontsize=7.8,
            weight="bold", color=NARANJA)
    y = 0.3
    caja(ax, 0.05, y + 0.6, 1.3, 0.75, "contexto $x$", size=7)
    caja(ax, 1.7, y + 0.6, 1.9, 0.75, "codificador", fc=AZUL_F, ec=AZUL, size=7)
    for k in range(3):
        caja(ax, 4.0, y + 1.25 - k * 0.6, 1.9, 0.48, f"cabeza {k + 1}", fc=NARANJA_F, ec=NARANJA,
             size=6.6)
        flecha(ax, (3.6, y + 0.97), (4.0, y + 1.49 - k * 0.6), lw=0.6)
        flecha(ax, (5.9, y + 1.49 - k * 0.6), (6.3, y + 0.97), lw=0.6)
    caja(ax, 6.3, y + 0.6, 1.0, 0.75, "$\\hat s_y^{(k)}$", fc=MORADO_F, ec=MORADO, size=7.2)
    caja(ax, 7.8, y + 0.55, 2.1, 0.85, "$\\min_k \\|\\hat s_y^{(k)} - s_y\\|^2$", fc=NARANJA_F,
         ec=NARANJA, size=7.0)
    flecha(ax, (1.35, y + 0.97), (1.7, y + 0.97))
    flecha(ax, (7.3, y + 0.97), (7.8, y + 0.97))
    ax.text(4.95, y - 0.25, "un enrutador que mira solo el contexto elige la cabeza",
            ha="center", fontsize=6.5, color=GRIS, style="italic")
    guardar(fig, "f27_jepa")


# ---------------------------------------------------------------------------
# Capítulo IX: ¿cuándo discretizar?
# ---------------------------------------------------------------------------

def f28_arbol():
    fig, ax = lienzo(4.55, ymax=8.75)
    preguntas = [
        "¿Hay que buscar, enumerar,\nreutilizar o componer hipótesis?",
        "¿El futuro se ramifica\n(varios resultados posibles)?",
        "¿Se encadenan muchas predicciones\ncon ruido por paso ≪ margen?",
        "¿El mundo tiene huecos: estados\nagrupados, categorías, saltos?",
        "¿La variable es rica y continua,\ncon precisión fina?",
    ]
    respuestas = [
        "Símbolos discretos (pieza 6):\nprogramas, vocabularios (NLI, DreamCoder)",
        "Discretiza la elección, no el estado:\nK cabezas, código de azar (pieza 4)",
        "Estado discreto o proyección a estados\npreferidos (pieza 5)",
        "Latente discreto; one-hot si no hay orden,\nvectores si lo hay (piezas 2 y 1)",
        "Continuo; limita la capacidad con\nruido o esparsidad (Garrido, MAR)",
    ]
    y0, dy = 8.15, 1.55
    for i, (q, r) in enumerate(zip(preguntas, respuestas)):
        y = y0 - i * dy
        caja(ax, 0.1, y - 0.5, 4.3, 1.0, q, fc=MORADO_F, ec=MORADO, size=7.0)
        caja(ax, 5.4, y - 0.5, 4.5, 1.0, r, fc=AZUL_F if i == 4 else NARANJA_F,
             ec=AZUL if i == 4 else NARANJA, size=6.8)
        flecha(ax, (4.4, y), (5.4, y), color=AQUA)
        ax.text(4.9, y + 0.1, "sí", ha="center", va="bottom", fontsize=7, color=AQUA,
                weight="bold")
        if i < 4:
            flecha(ax, (2.25, y - 0.5), (2.25, y - dy + 0.5), color=GRIS)
            ax.text(2.4, y - dy / 2, "no", va="center", fontsize=7, color=GRIS, weight="bold")
    yf = y0 - 4 * dy
    flecha(ax, (2.25, yf - 0.5), (2.25, yf - 0.95), color=GRIS)
    ax.text(2.4, yf - 0.72, "no", va="center", fontsize=7, color=GRIS, weight="bold")
    caja(ax, 0.1, yf - 1.6, 9.8, 0.62,
         "Ninguna pieza es necesaria: probablemente da igual. Prueba ambas con capacidad igualada.",
         fc=GRIS_F, ec=GRIS, size=6.8)
    guardar(fig, "f28_arbol")


def f29_mapa_ejes():
    fig, ax = plt.subplots(figsize=(ANCHO, 2.75))
    ejes_limpios(ax)
    casos = [
        (0.92, 0.15, "Programas (NLI,\nDreamCoder)", NARANJA),
        (0.85, 0.30, "Laberintos\n(Meyer)", NARANJA),
        (0.75, 0.42, "2048, backgammon\n(St. MuZero)", NARANJA),
        (0.62, 0.50, "Atari\n(DreamerV2)", NARANJA),
        (0.34, 0.62, "Control continuo\n(DCWM, vectores)", NARANJA),
        (0.45, 0.30, "Robustez ImageNet\n(Mao, híbrido)", GRIS),
        (0.18, 0.80, "Generar imágenes\n(MAR)", AZUL),
        (0.08, 0.66, "Acciones en video\nreal (Garrido)", AZUL),
    ]
    ax.axvspan(0.5, 1.05, color=NARANJA_F, alpha=0.5, lw=0)
    for x, y, t, c in casos:
        ax.scatter(x, y, s=40, color=c, edgecolor="white", lw=0.8, zorder=3)
        ax.text(x + 0.02, y + 0.03, t, fontsize=6.4, va="bottom", color=TINTA,
                linespacing=1.1)
    ax.set_xlim(0, 1.12)
    ax.set_ylim(0, 1.0)
    ax.set_xticks([0.05, 1.0], ["suave, sin huecos", "agrupado, con saltos"])
    ax.set_yticks([0.05, 0.92], ["gruesa", "fina"])
    ax.set_xlabel("estructura del mundo →")
    ax.set_ylabel("precisión que exige la tarea →")
    ax.scatter([], [], s=30, color=NARANJA, label="gana lo discreto")
    ax.scatter([], [], s=30, color=AZUL, label="gana lo continuo")
    ax.scatter([], [], s=30, color=GRIS, label="híbrido")
    ax.legend(frameon=False, fontsize=6.6, loc="upper right")
    ax.set_title("Ubicación aproximada de los casos (juicio nuestro)", style="italic",
                 color=GRIS)
    guardar(fig, "f29_mapa_ejes")


if __name__ == "__main__":
    for nombre, f in list(globals().items()):
        if nombre.startswith("f") and nombre[1:3].isdigit() and callable(f):
            f()
            print("ok", nombre)
