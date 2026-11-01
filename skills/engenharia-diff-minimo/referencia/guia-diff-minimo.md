# Guia Prático de Engenharia de Diff Mínimo

Este guia estabelece os padrões e contrastes práticos para aplicação da disciplina do menor diff viável.

## 1. O Contraste Canônico: Correção Inchada vs. Cirúrgica

### Cenário: Erro de "off-by-one" em paginação

**Código original:**
```java
public List<Item> obterPagina(List<Item> itens, int pagina, int tamanho) {
    int inicio = pagina * tamanho;
    int fim = Math.min(inicio + tamanho, itens.size());
    return itens.subList(inicio, fim);
}
```

**❌ Correção Inchada (40 linhas alteradas — risco alto de regressão):**
- Renomeia parâmetros para seguir convenção nova.
- Adiciona validação de lista nula.
- Extrai métodos auxiliares privados.
- Altera imports e adiciona javadoc desnecessário.
```java
// O desenvolvedor reescreveu a classe inteira para parecer "mais limpa"
```

**✅ Correção Cirúrgica (1 linha alterada — risco zero):**
```diff
- int inicio = pagina * tamanho;
+ int inicio = (pagina - 1) * tamanho;
```

Apenas o bug foi corrigido. A revisão leva 5 segundos e o git blame permanece preservado.

---

## 2. Checklist do Autocrivo de Diff

Antes de submeter qualquer patch:
1. `git diff` inspecionado manualmente do começo ao fim.
2. Cada linha modificada responde à pergunta: "Se eu remover esta linha, o teste falha?". Se a resposta for não, ela deve ser revertida.
3. Zero arquivos tocados além do estritamente necessário.
4. Nenhuma reformatação de indentação ou ajuste de quebra de linha em código alheio.
