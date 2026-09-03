# Arquétipos de Navegação e Rodapés (Component Cookbook)

Proveniência: `nutlope/hallmark` (Together AI, MIT) — laudo em `garimpo-lote-5repos-2026-08-26.md` (G6).

## Navegação (Headers & Navs)

Evite o padrão previsível de IA (Logo à esquerda + 4 links centralizados + Botão à direita com linha cinza embaixo). Varie conforme a macroestrutura:

- **N1b · SaaS Três Seções:** Logo + links utilitários à esquerda, busca/status ao centro, ações de conta e CTA à direita.
- **N2 · Floating Chip:** Barra de navegação flutuante compacta em formato de pílula com fundo translúcido (`backdrop-filter`) e sombra suave.
- **N3 · Side Rail:** Trilho vertical lateral fixo (ideal para apps densos, documentação e workbenches).
- **N4 · Minimal Wordmark + 2 Links:** Ultra minimalista: apenas o nome do produto e dois destinos essenciais ("Docs" e "Entrar").
- **N5 · Terminal Command Bar:** Barra em estilo CLI com atalho rápido de busca (`Cmd + K`) integrado.
- **N6 · Newspaper Masthead:** Cabeçalho editorial clássico com data, edição, divisores em linha fina e tipografia serifada.
- **N7 · Brutal Slab:** Barra de navegação com bordas sólidas pretas de 2px, cantos retos (zero border-radius) e contraste acentuado.
- **N8 · Floating On-Scroll Morph:** Nav que inicia integrada ao Hero e se transforma em pílula flutuante compacta ao rolar a página.

---

## Rodapés (Footers)

Evite o rodapé genérico de 4 colunas em cinza claro com copyright minúsculo. Varie a arquitetura de fechamento:

- **Ft1 · Masthead / Statement:** Fechamento com uma declaração tipográfica marcante em tamanho grande + links essenciais em linha única.
- **Ft2 · Single-Line Rule:** Linha única e limpa separada por borda sutil: Copyright à esquerda, links legais ao centro, status à direita.
- **Ft3 · Index-Style Category List:** Lista organizada como sumário de diretório técnico por ordem alfabética ou hierárquica.
- **Ft4 · Dense Typographic:** Rodapé rico em micro-tipografia, metadados de versão, commit hash e status de uptime.
- **Ft5 · Letter Close:** Assinatura pessoal com foto/avatar do criador e link para feedback direto.
- **Ft6 · Action-First / Newsletter:** Focado em captura de interesse ou call-to-action final com campo de e-mail integrado.
- **Ft7 · Marquee Scroll:** Faixa animada contínua com slogans, depoimentos ou parcerias antes das informações de copyright.
