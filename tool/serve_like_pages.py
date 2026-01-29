#!/usr/bin/env python3
"""Local preview server that behaves like GitHub Pages for this site.

    flutter build web --release --base-href /portfolio/ --pwa-strategy=none
    python3 tool/generate_route_pages.py build/web http://localhost:8766/portfolio/
    python3 tool/serve_like_pages.py 8766

Then open http://localhost:8766/portfolio/. Like GitHub Pages it serves
`/portfolio/x` from `x.html` when it exists, falls back to `404.html` (with a
404 status) for anything else, and disables caching so every build is fresh.
"""
import http.server
import sys
from pathlib import Path

ROOT = Path('build/web').resolve()
PREFIX = '/portfolio'


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def end_headers(self):
        self.send_header('Cache-Control', 'no-store')
        super().end_headers()

    def do_GET(self):
        path = self.path.split('?', 1)[0].split('#', 1)[0]
        if not path.startswith(PREFIX):
            return self.send_error(404)
        rel = path[len(PREFIX):] or '/'
        target = ROOT / rel.lstrip('/')
        if target.is_dir():
            target = target / 'index.html'
        elif not target.exists() and target.with_suffix('.html').exists():
            target = target.with_suffix('.html')
        if target.exists():
            self.path = '/' + str(target.relative_to(ROOT))
            return super().do_GET()
        # GitHub Pages: unknown path -> 404.html with status 404.
        body = (ROOT / '404.html').read_bytes()
        self.send_response(404)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)


if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8766
    http.server.ThreadingHTTPServer(('', port), Handler).serve_forever()
