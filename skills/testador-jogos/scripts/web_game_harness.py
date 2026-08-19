"""
Harness Playwright para testar jogos web (HTML5/canvas/DOM).

Uso típico:
    from web_game_harness import GameHarness

    with GameHarness("meujogo/index.html", shots_dir="shots") as h:   # ou URL http(s)
        h.shot("01-menu")
        h.press("Enter")                # começar
        h.hold(["ArrowRight"], 2.0)     # andar 2s
        h.spam("Space", 20)             # arsenal do destruidor
        h.monkey(seconds=15, seed=42)   # inputs caóticos reproduzíveis
        fps_ini = h.fps(3)
        ...  # sessão longa / restarts
        fps_fim = h.fps(3)
        h.shot("99-final")
        print(h.report())               # erros de console, pageerrors, requests falhas

Requisitos: pip install playwright --break-system-packages
(No sandbox Cowork o Chromium já está em PLAYWRIGHT_BROWSERS_PATH — não rode playwright install.)
"""

import json
import pathlib
import random
import time

from playwright.sync_api import sync_playwright

MOBILE = {"width": 390, "height": 844}
DESKTOP = {"width": 1280, "height": 720}

KEYS_COMUNS = ["ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight",
               "Space", "Enter", "Escape", "KeyW", "KeyA", "KeyS", "KeyD", "KeyP"]


class GameHarness:
    def __init__(self, alvo, viewport=None, mobile=False, shots_dir="shots"):
        self.alvo = alvo
        self.viewport = viewport or (MOBILE if mobile else DESKTOP)
        self.shots_dir = pathlib.Path(shots_dir)
        self.shots_dir.mkdir(parents=True, exist_ok=True)
        self.console = []        # [(tipo, texto)]
        self.pageerrors = []     # [texto]
        self.failed_requests = []

    # -- ciclo de vida -------------------------------------------------
    def __enter__(self):
        self._pw = sync_playwright().start()
        self.browser = self._pw.chromium.launch(headless=True)
        self.page = self.browser.new_page(viewport=self.viewport)
        self.page.on("console", lambda m: self.console.append((m.type, m.text)))
        self.page.on("pageerror", lambda e: self.pageerrors.append(str(e)))
        self.page.on("requestfailed",
                     lambda r: self.failed_requests.append(f"{r.method} {r.url} -> {r.failure}"))
        url = self.alvo
        if "://" not in url:  # caminho local -> file://
            url = pathlib.Path(url).resolve().as_uri()
        self.page.goto(url, wait_until="load")
        self.page.wait_for_timeout(500)
        return self

    def __exit__(self, *exc):
        try:
            self.browser.close()
        finally:
            self._pw.stop()

    # -- observação ----------------------------------------------------
    def shot(self, nome):
        caminho = self.shots_dir / f"{nome}.png"
        self.page.screenshot(path=str(caminho))
        return str(caminho)

    def texto_visivel(self):
        """Texto renderizado da página (para checar HUD, menus, typos)."""
        return self.page.evaluate("document.body.innerText")

    def fps(self, seconds=3):
        """FPS médio via requestAnimationFrame. Compare início vs fim da sessão
        (queda relativa indica vazamento); o valor absoluto do headless não é representativo."""
        frames = self.page.evaluate(
            """(secs) => new Promise(res => {
                   let n = 0; const t0 = performance.now();
                   function tick(t) { n++; (t - t0 < secs * 1000) ? requestAnimationFrame(tick) : res(n); }
                   requestAnimationFrame(tick);
               })""", seconds)
        return round(frames / seconds, 1)

    def canvas_mudou(self, ms=700):
        """True se algum pixel visível mudou no intervalo — 'o jogo reagiu?'"""
        a = self.page.screenshot()
        self.page.wait_for_timeout(ms)
        return a != self.page.screenshot()

    # -- entrada -------------------------------------------------------
    def press(self, key, vezes=1, intervalo_ms=60):
        for _ in range(vezes):
            self.page.keyboard.press(key)
            self.page.wait_for_timeout(intervalo_ms)

    def hold(self, keys, seconds):
        """Segura uma ou mais teclas ao mesmo tempo (ex.: ['ArrowLeft','ArrowRight'])."""
        for k in keys:
            self.page.keyboard.down(k)
        self.page.wait_for_timeout(int(seconds * 1000))
        for k in reversed(keys):
            self.page.keyboard.up(k)

    def spam(self, key, vezes=20):
        """Aperta o mais rápido possível — clássico do arsenal do destruidor."""
        for _ in range(vezes):
            self.page.keyboard.press(key, delay=0)

    def click(self, seletor=None, x=None, y=None, vezes=1):
        for _ in range(vezes):
            if seletor:
                self.page.click(seletor, timeout=3000)
            else:
                self.page.mouse.click(x, y)
            self.page.wait_for_timeout(50)

    def monkey(self, seconds=15, seed=42):
        """Inputs caóticos porém reproduzíveis (mesma seed = mesma sequência)."""
        rng = random.Random(seed)
        fim = time.time() + seconds
        w, h = self.viewport["width"], self.viewport["height"]
        while time.time() < fim:
            if rng.random() < 0.7:
                self.page.keyboard.press(rng.choice(KEYS_COMUNS), delay=0)
            else:
                self.page.mouse.click(rng.randrange(w), rng.randrange(h))
            self.page.wait_for_timeout(rng.randrange(20, 120))

    def resize(self, width, height):
        self.page.set_viewport_size({"width": width, "height": height})
        self.page.wait_for_timeout(300)

    def blur_focus(self, seconds=2):
        """Simula perder e recuperar o foco da aba (trocar de aba / minimizar)."""
        self.page.evaluate("window.dispatchEvent(new Event('blur'))")
        self.page.wait_for_timeout(int(seconds * 1000))
        self.page.evaluate("window.dispatchEvent(new Event('focus'))")

    def reload(self):
        self.page.reload(wait_until="load")
        self.page.wait_for_timeout(500)

    # -- balanço -------------------------------------------------------
    def erros_novos(self, desde=0):
        """Erros de console/página a partir do índice `desde` — útil para atribuir
        um erro à ação que acabou de ser executada."""
        return {"console": [c for c in self.console[desde:] if c[0] == "error"],
                "pageerrors": self.pageerrors[desde:]}

    def report(self):
        return json.dumps({
            "console_errors": [c[1] for c in self.console if c[0] == "error"],
            "console_warnings": [c[1] for c in self.console if c[0] == "warning"],
            "pageerrors": self.pageerrors,
            "failed_requests": self.failed_requests,
        }, ensure_ascii=False, indent=2)


if __name__ == "__main__":
    import sys
    alvo = sys.argv[1] if len(sys.argv) > 1 else "index.html"
    with GameHarness(alvo) as h:
        h.shot("smoke-01-inicial")
        h.press("Enter")
        h.shot("smoke-02-apos-enter")
        print("Canvas reagiu a input?", h.canvas_mudou())
        print("FPS:", h.fps(2))
        print(h.report())
