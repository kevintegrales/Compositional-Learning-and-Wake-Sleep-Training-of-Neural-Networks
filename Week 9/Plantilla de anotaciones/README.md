# Plantilla de anotaciones al margen

Motor en Typst para anotar cualquier PDF (papers, capítulos) agregando un margen con notas de colores ancladas al texto original. **Lee `GUIA.pdf`**: tiene el flujo completo, la referencia de la API y cómo crear tipos de notas nuevos.

Inicio rápido:

1. `python -I herramientas.py info paper.pdf` → W, H, xr sugerido.
2. `python -I herramientas.py lineas paper.pdf 1-3` → coordenadas de cada línea.
3. Copia `ejemplo/anotado.typ`, cambia `src`, `W`, `H`, `xr` y escribe las notas `n(y0, y1, "tipo")[texto]`.
4. `tinymist compile --root <raíz> <archivo>.typ salida.pdf` (Typst ≥ 0.14; `--root` debe contener el PDF original).
5. `python -I herramientas.py revisar salida.pdf revision/` → mira las imágenes y corrige.
