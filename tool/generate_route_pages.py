#!/usr/bin/env python3
"""Post-build step for GitHub Pages (a static host) with clean URLs.

Run after `flutter build web`:

    python3 tool/generate_route_pages.py [build/web] [https://site.url/base/]

For every project in assets/data/projects.json it writes
`projects/<id>.html` — a copy of index.html whose title and link-preview tags
describe that project. GitHub Pages serves it at `/projects/<id>` with a 200
status, so shared project links load directly and get their own preview card.
Any other path falls back to `404.html` (another copy of index.html), where
the app redirects unknown URLs home.
"""
import html
import json
import re
import sys
from pathlib import Path

build = Path(sys.argv[1] if len(sys.argv) > 1 else 'build/web')
site = (sys.argv[2] if len(sys.argv) > 2
        else 'https://sifou20ws.github.io/portfolio/').rstrip('/') + '/'
owner = 'Seifeddine Rezrazi'

index = (build / 'index.html').read_text(encoding='utf-8')
projects = json.loads(
    Path('assets/data/projects.json').read_text(encoding='utf-8'))['projects']


def text(value):
    """LocalizedText in JSON: plain string or {"en": …, "fr": …, "ar": …}."""
    if isinstance(value, dict):
        return value.get('en') or next(iter(value.values()), '')
    return value or ''


def set_meta(page, attr, key, value):
    pattern = rf'(<meta {attr}="{re.escape(key)}" content=")[^"]*(")'
    page, count = re.subn(pattern, lambda m: m.group(1) + value + m.group(2), page)
    assert count == 1, f'{attr}={key} not found exactly once in index.html'
    return page


def page_for(project):
    title = html.escape(f"{text(project['title'])} · {owner}", quote=True)
    desc = html.escape(text(project.get('summary')), quote=True)
    url = f"{site}projects/{project['id']}"
    page = index
    page, n = re.subn(r'<title>[^<]*</title>', f'<title>{title}</title>', page)
    assert n == 1
    page = set_meta(page, 'name', 'description', desc)
    for key, value in [('og:title', title), ('og:description', desc), ('og:url', url)]:
        page = set_meta(page, 'property', key, value)
    for key, value in [('twitter:title', title), ('twitter:description', desc)]:
        page = set_meta(page, 'name', key, value)
    page, n = re.subn(r'(<link rel="canonical" href=")[^"]*(")',
                      lambda m: m.group(1) + url + m.group(2), page)
    assert n == 1
    return page


out_dir = build / 'projects'
out_dir.mkdir(exist_ok=True)
for project in projects:
    (out_dir / f"{project['id']}.html").write_text(page_for(project), encoding='utf-8')
    print(f"wrote projects/{project['id']}.html")

(build / '404.html').write_text(index, encoding='utf-8')
print('wrote 404.html')
