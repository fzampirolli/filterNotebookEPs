# 🚀 Sistema de Testes e Exercícios de PI (UFABC)

Este repositório contém o ambiente de testes automatizados dos Exercícios de Programação (EPs) para a disciplina de **Processamento da Informação (PI)**.

## 📂 Organização do Material

* **`./all` (CORE)**: Contém os arquivos Google Colab originais dos EPs presentes na disciplina compartilhada de PI no Moodle. **Esta é a pasta principal; qualquer alteração deve ser feita aqui**.
* **`./gen`**: Contém o conteúdo gerado automaticamente (scripts `.py`, `.c`, etc.) a partir dos notebooks da pasta `all`.
* **`./cases`**: Pasta com o script de teste (`testsuite.py`), o executor (`run_all.sh`) e os casos de teste extraídos do Moodle.
* **`./cases_gab`**: Alguns gabaritos de referência para os exercícios. As suas soluções devem ficar nesta pasta e depois copiadas nas respectivas atividades VPL do Moodle.
* **`install_deps.sh`**: Script para instalação das dependências.

## 🛡️ Filtro de Restrições Pedagógicas

O sistema inclui um validador automático de código Python para garantir que o aluno implemente a lógica algorítmica sem o uso de funções prontas da linguagem.

* **Créditos**: Este filtro foi desenvolvido pelo **Prof. Paulo Henrique Pisani (UFABC)**.
* **Objetivo**: Impedir o uso de funções como `sum()`, `max()`, `min()`, `sort()`, entre outras, incentivando a implementação lógica manual.
* **Como funciona**: O `testsuite.py` baixa e executa automaticamente o script `verificar_arquivo.py` antes de rodar os casos de teste em Python. Se uma função proibida for detectada, o teste é interrompido imediatamente.
* **Configuração**: Você pode ativar ou desativar este filtro alterando a variável `USE_PEDAGOGIC_FILTER` no topo do arquivo `testsuite.py`.

## ⚠️ Alerta de Fluxo de Trabalho e Revisão

> **IMPORTANTE:**
> **Tudo na pasta `./all` é considerado o "core" do projeto.**
> Se você precisar alterar um exercício, faça a modificação no notebook dentro de `./all`.
> Para atualizar os arquivos na pasta `./gen`, utilize o script de filtragem:
> `python3 filterNotebook.py all py` (ou a extensão desejada).

* **Geração Automática**: Os Colabs iniciais foram gerados utilizando o **Gemini Pro** a partir dos EPs do Moodle.
* **Revisão Obrigatória**: **Todo o material deve ser revisado!** É necessário validar a correção dos códigos e substituir EPs conforme o critério pedagógico de cada professor.

## 📖 Material de Referência

Este material é complementar ao livro texto de PI, disponível no link da Editora UFABC:
🔗 [Processando a Informação - Material Complementar](https://editora.ufabc.edu.br/matematica-e-ciencias-da-computacao/58-processando-a-informacao).

---

## 🛠️ Configuração e Instalação

Prepare o ambiente executando:

```bash
chmod +x install_deps.sh
./install_deps.sh

```

---

## 🚀 Como Executar os Testes

Os testes validam suas soluções em `cases_gab/` contra os casos oficiais em `cases/`.

### 1. Modo Inteligente

Testa apenas arquivos novos ou alterados:

```bash
bash cases/run_all.sh cases cases_gab

```

### 2. Forçar reteste total

```bash
bash cases/run_all.sh cases cases_gab --force

```

### 3. Testar um EP específico

```bash
bash cases/run_all.sh cases cases_gab --file EP1_1.py

```

### 4. Testar um EP modificado

```bash
bash cases/run_all.sh cases cases_gab --modified

```

---

> **ATENÇÃO:**
> **A lista de EPs que passaram nos casos de teste e os que não passaram estão no arquivo `test_cache.py`, criado após a primeira execução de `run_all.sh`. Esse recurso é fundamental para testar todos os EPs do Moodle de uma única vez utilizando as soluções implementadas e disponibilizadas na pasta `cases_gab`.**
