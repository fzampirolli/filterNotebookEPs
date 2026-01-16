#!/bin/bash

# ==============================================================================
# 📘 INSTRUÇÕES DE CONFIGURAÇÃO PARA O ALUNO
# ==============================================================================
# 1. Crie uma pasta 'cases_gab' com subpastas cap1, cap2...
# 2. Salve suas soluções dentro delas (Ex: cases_gab/cap1/EP1_1.py)
# 3. Execute: bash ./cases/run_all.sh cases cases_gab
#
# 🚀 Comandos Úteis:
#    bash ./cases/run_all.sh cases cases_gab --file EP2_3.py  (Testa um arquivo)
#    bash ./cases/run_all.sh cases cases_gab --force          (Testa tudo)
#    bash ./cases/run_all.sh cases cases_gab --modified       (Testa só modificados)
# ==============================================================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuração
CACHE_FILE="test_cache.json"
FORCE_ALL=false
ONLY_MODIFIED=false
SPECIFIC_FILE=""
PASTA_CASOS=""
PASTA_GABARITOS=""

# --- PROCESSAMENTO DE ARGUMENTOS ---
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --force) FORCE_ALL=true; shift ;;
        --modified) ONLY_MODIFIED=true; shift ;;
        --file) SPECIFIC_FILE="$2"; shift 2 ;;
        *) POSITIONAL_ARGS+=("$1"); shift ;;
    esac
done

if [ ${#POSITIONAL_ARGS[@]} -ge 2 ]; then
    PASTA_CASOS="${POSITIONAL_ARGS[0]}"
    PASTA_GABARITOS="${POSITIONAL_ARGS[1]}"
fi

# Validações
if [ -z "$PASTA_CASOS" ] || [ -z "$PASTA_GABARITOS" ]; then
    echo -e "${RED}Uso: $0 <pasta_casos> <pasta_gabaritos> [--file Nome] [--modified]${NC}"
    rm "./testsuite.py"
    exit 1
fi
if [ ! -d "$PASTA_CASOS" ] || [ ! -d "$PASTA_GABARITOS" ]; then
    echo -e "${RED}❌ Pastas não encontradas.${NC}"
    rm "./testsuite.py"
    exit 1
fi

# ==============================================================================
# 🕵️ BUSCA DE ARQUIVO (VIA PYTHON)
# ==============================================================================
if [ -n "$SPECIFIC_FILE" ]; then
    BUSCA_NOME=$(basename "$SPECIFIC_FILE")
    echo -e "${CYAN}🔍 Procurando arquivo: $BUSCA_NOME${NC}"
    RESULTADO_PYTHON=$(python3 -c "
import os, sys
root_dir = '$PASTA_GABARITOS'
target = '$BUSCA_NOME'.lower()
for root, dirs, files in os.walk(root_dir):
    for file in files:
        if file.lower() == target:
            print(os.path.join(root, file))
            sys.exit(0)
sys.exit(1)
")
    if [ $? -eq 0 ]; then
        SPECIFIC_FILE_PATH="$RESULTADO_PYTHON"
        SPECIFIC_FILE=$(basename "$SPECIFIC_FILE_PATH") # Atualiza nome exato
        echo -e "${GREEN}✓ Arquivo encontrado: $SPECIFIC_FILE_PATH${NC}"
    else
        echo -e "${RED}❌ Arquivo não encontrado: $BUSCA_NOME${NC}"
        echo -e "${YELLOW}Verifique se o arquivo está salvo dentro de: $PASTA_GABARITOS/capX/${NC}"
        rm "./testsuite.py"
        exit 1
    fi
fi

# ==============================================================================
# FUNÇÕES DE CACHE OTIMIZADAS (JSON SIMPLIFICADO)
# ==============================================================================

# Retorna 0 (true) se foi modificado ou é novo. Retorna 1 (false) se não mudou.
check_status_and_modification() {
    local ep_name="$1"
    local file_path="$2"
    
    if [ ! -f "$CACHE_FILE" ] || [ "$FORCE_ALL" == "true" ]; then
        echo "TEST" # Deve testar
        return
    fi
    
    # Obtém timestamp atual do arquivo (Linux/Mac)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        current_mtime=$(stat -f %m "$file_path" 2>/dev/null || echo "0")
    else
        current_mtime=$(stat -c %Y "$file_path" 2>/dev/null || echo "0")
    fi
    
    # Verifica JSON via Python e retorna status: APPROVED, FAILED, MODIFIED, ou NEW
    python3 -c "
import json, sys, os
try:
    with open('$CACHE_FILE', 'r') as f: data = json.load(f)
except: data = {'approved': {}, 'failed': {}}

name = '$ep_name'
curr_time = int($current_mtime)

# Busca timestamp salvo (se existir)
saved_time = 0
status = 'NEW'

if name in data.get('approved', {}):
    saved_time = int(data['approved'][name])
    status = 'APPROVED'
elif name in data.get('failed', {}):
    saved_time = int(data['failed'][name])
    status = 'FAILED'

# Compara timestamps (se arquivo no disco for mais novo > MODIFIED)
if curr_time > saved_time:
    print('MODIFIED')
else:
    print(status)
"
}

update_cache() {
    local action="$1" # 'approved' ou 'failed'
    local ep_name="$2"
    local file_path="$3"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        mtime=$(stat -f %m "$file_path" 2>/dev/null || echo "0")
    else
        mtime=$(stat -c %Y "$file_path" 2>/dev/null || echo "0")
    fi
    
    python3 -c "
import json, os
cache = '$CACHE_FILE'
try:
    with open(cache, 'r') as f: data = json.load(f)
except: data = {'approved': {}, 'failed': {}}

# Garante estrutura
if not isinstance(data.get('approved'), dict): data['approved'] = {}
if not isinstance(data.get('failed'), dict): data['failed'] = {}

name = '$ep_name'
time = int($mtime)

if '$action' == 'approved':
    data['approved'][name] = time
    data['failed'].pop(name, None) # Remove de failed se existir
else:
    data['failed'][name] = time
    data['approved'].pop(name, None) # Remove de approved se existir

with open(cache, 'w') as f: json.dump(data, f, indent=2)
"
}

# ==============================================================================
# EXECUÇÃO PRINCIPAL
# ==============================================================================

TOTAL_TESTADOS=0; TOTAL_SUCESSO=0; TOTAL_FALHA=0; TOTAL_PULADOS=0
declare -a EPS_PASSARAM; declare -a EPS_FALHARAM; declare -a EPS_PULADOS

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}🚀 Iniciando Testes${NC}"
echo -e "${BLUE}================================================${NC}"

if [ -n "$SPECIFIC_FILE" ]; then
    echo -e "${MAGENTA}🎯 Modo FILE: Testando apenas $SPECIFIC_FILE${NC}"
elif [ "$FORCE_ALL" == "true" ]; then
    echo -e "${MAGENTA}🔄 Modo FORCE: Ignorando cache e re-testando tudo${NC}"
elif [ "$ONLY_MODIFIED" == "true" ]; then
    echo -e "${MAGENTA}✏️  Modo MODIFIED: Testando apenas arquivos alterados${NC}"
else
    echo -e "${CYAN}💾 Modo INTELIGENTE: Novos, Modificados ou Falhas${NC}"
fi

# Copiar testsuite
if [ ! -f "testsuite.py" ] && [ -f "$PASTA_CASOS/testsuite.py" ]; then
    cp "$PASTA_CASOS/testsuite.py" .
fi

# Links simbólicos
for cap_dir in "$PASTA_CASOS"/cap*; do
    [ -d "$cap_dir" ] && ln -sfn "$cap_dir" "$(basename "$cap_dir")"
done

EXTENSOES=("py" "cpp" "java" "js" "r" "c")

# Loop pelos capítulos
for cap_dir in "$PASTA_GABARITOS"/cap*; do
    [ ! -d "$cap_dir" ] && continue
    cap_name=$(basename "$cap_dir")
    cap_numero="${cap_name#cap}"
    
    # Otimização: Se busca arquivo específico e não está aqui, pula cap
    if [ -n "$SPECIFIC_FILE" ]; then
        if [ ! -f "$cap_dir/$SPECIFIC_FILE" ]; then continue; fi
    fi

    echo -e "${BLUE}━━━━━━━━━━━━━━━━ $cap_name ━━━━━━━━━━━━━━━━${NC}"
    
    # Coleta EPs
    declare -A eps_neste_cap
    for ext in "${EXTENSOES[@]}"; do
        for f in "$cap_dir"/EP${cap_numero}_*.${ext}; do
            [ -f "$f" ] && eps_neste_cap[$(basename "$f" | cut -d. -f1)]=1
        done
    done
    
    IFS=$'\n' sorted_keys=($(printf "%s\n" "${!eps_neste_cap[@]}" | sort))
    unset IFS

    for ep_base in "${sorted_keys[@]}"; do
        for ext in "${EXTENSOES[@]}"; do
            ep_arquivo="$cap_dir/${ep_base}.${ext}"
            [ ! -f "$ep_arquivo" ] && continue
            
            ep_nome=$(basename "$ep_arquivo")
            
            # Filtro de arquivo específico
            if [ -n "$SPECIFIC_FILE" ] && [ "$ep_nome" != "$SPECIFIC_FILE" ]; then continue; fi
            
            # === LÓGICA DE DECISÃO ===
            STATUS=$(check_status_and_modification "$ep_nome" "$ep_arquivo")
            SHOULD_RUN=false
            REASON=""

            if [ -n "$SPECIFIC_FILE" ] || [ "$FORCE_ALL" == "true" ]; then
                SHOULD_RUN=true
            elif [ "$ONLY_MODIFIED" == "true" ]; then
                # Se flag --modified usada, SÓ roda se for MODIFIED ou NEW
                if [ "$STATUS" == "MODIFIED" ] || [ "$STATUS" == "NEW" ]; then
                    SHOULD_RUN=true
                    REASON="Modificado/Novo"
                else
                    SHOULD_RUN=false
                    REASON="Não modificado (Ignorado pelo modo --modified)"
                fi
            else
                # Modo Padrão (Inteligente)
                if [ "$STATUS" == "APPROVED" ]; then
                    SHOULD_RUN=false
                    REASON="Já aprovado"
                elif [ "$STATUS" == "MODIFIED" ]; then
                    SHOULD_RUN=true
                    REASON="Arquivo alterado"
                elif [ "$STATUS" == "NEW" ]; then
                    SHOULD_RUN=true
                    REASON="Arquivo novo"
                elif [ "$STATUS" == "FAILED" ]; then
                    SHOULD_RUN=true
                    REASON="Falhou anteriormente"
                fi
            fi

            if [ "$SHOULD_RUN" == "false" ]; then
                # Só mostra mensagem de pulo se não estiver no modo --modified (pra não poluir)
                if [ "$ONLY_MODIFIED" == "false" ]; then
                    echo -e "${CYAN}⏭️  $ep_nome: PULADO ($REASON)${NC}"
                fi
                EPS_PULADOS+=("$ep_nome")
                TOTAL_PULADOS=$((TOTAL_PULADOS + 1))
                continue
            fi

            # === EXECUÇÃO ===
            if [ "$STATUS" == "MODIFIED" ]; then
                echo -e "${YELLOW}✏️  $ep_nome: DETECTADA ALTERAÇÃO - Retestando...${NC}"
            else
                echo -e "${YELLOW}📝 Testando: $ep_nome${NC}"
            fi
            
            TOTAL_TESTADOS=$((TOTAL_TESTADOS + 1))
            cp "$ep_arquivo" .
            
            if output=$(python3 testsuite.py "$ep_nome" 2>&1); then
                if echo "$output" | grep -q "100.0%\|Parabéns"; then
                    echo -e "${GREEN}✅ $ep_nome: PASSOU${NC}"
                    EPS_PASSARAM+=("$ep_nome")
                    TOTAL_SUCESSO=$((TOTAL_SUCESSO + 1))
                    update_cache "approved" "$ep_nome" "$ep_arquivo"
                else
                    echo -e "${RED}❌ $ep_nome: FALHOU${NC}"
                    echo -e "${YELLOW}--- DETALHES ---${NC}"
                    echo "$output"
                    echo -e "${YELLOW}----------------${NC}"
                    EPS_FALHARAM+=("$ep_nome")
                    TOTAL_FALHA=$((TOTAL_FALHA + 1))
                    update_cache "failed" "$ep_nome" "$ep_arquivo"
                fi
            else
                echo -e "${RED}❌ $ep_nome: ERRO EXECUÇÃO${NC}"
                echo "$output"
                EPS_FALHARAM+=("$ep_nome")
                TOTAL_FALHA=$((TOTAL_FALHA + 1))
            fi
            echo ""
            
            rm -f "$ep_nome" "${ep_base}.class" "${ep_base}" 2>/dev/null || true
        done
    done
done

# Limpeza Final
find . -maxdepth 1 -type l -name "cap*" -delete

# Resumo
echo -e "${BLUE}================================================${NC}"
echo -e "Total Testados: ${YELLOW}$TOTAL_TESTADOS${NC}"
echo -e "Sucessos:       ${GREEN}$TOTAL_SUCESSO${NC}"
echo -e "Falhas:         ${RED}$TOTAL_FALHA${NC}"
[ "$ONLY_MODIFIED" == "false" ] && echo -e "Pulados:        ${CYAN}$TOTAL_PULADOS${NC}"
echo ""

if [ $TOTAL_FALHA -gt 0 ]; then
    echo -e "${RED}⚠️  FALHAS:${NC}"
    for ep in "${EPS_FALHARAM[@]}"; do echo -e "   🚫 $ep"; done
    rm "./testsuite.py"
    exit 1
elif [ $TOTAL_TESTADOS -eq 0 ] && [ $TOTAL_PULADOS -eq 0 ]; then
    echo -e "${YELLOW}Nenhum arquivo encontrado.${NC}"
    rm "./testsuite.py"
    exit 0
fi
echo -e "${GREEN}🎉 Sucesso!${NC}"
exit 0

