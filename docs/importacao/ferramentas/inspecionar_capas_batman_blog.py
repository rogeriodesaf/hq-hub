"""Lista imagens e seu contexto imediato para revisao humana."""
import re
import sys
from html import unescape
from robo_enriquecer_capas_multiplas_fontes import baixar

for url in sys.argv[1:]:
    html = baixar(url)
    print('FONTE', url)
    for img in re.finditer(r'<img\b[^>]*>', html):
        src = re.search(r'\bsrc="([^"]+)"', img[0])
        if src:
            contexto = unescape(re.sub(r'<[^>]+>', ' ', html[img.end():img.end()+2400]))
            print(unescape(src[1]), re.sub(r'\s+', ' ', contexto)[:260])
