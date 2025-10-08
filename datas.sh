#!/bin/bash
#####################################################################################################
#.SYNOPSIS
#  Gera sequências de datas em múltiplos formatos, variando-as com sufixos de 00 a 99, desde um ano 
#	inicial fornecido até o ano corrente.
#
#.DESCRIPTION
#  Este script percorre todas as datas de 01/01/<Ano_Inicial> até 31/12/<Ano_Corrente>.
#  Para cada data, gera 4 formatos diferentes: ddMMyyyy, ddMMyy, MMddyy, e MMddyyyy.
#  Cada formato de data é salvo uma vez sem sufixo e mais 100 vezes com um sufixo sequencial de '00' 
#	a '99'.
#  
#  Os resultados brutos são salvos em 'data_gerada.txt' e, em seguida, processados para gerar um 
#	arquivo final ('datasunicas.txt') contendo apenas sequências únicas e um resumo estatístico.
#
#.PARAMETER ano_inicial
#  O ano de início (com 4 dígitos) para a geração das datas.
#
#.INPUTS
#  Nenhum. O script requer apenas um parâmetro de linha de comando.
#
#.OUTPUTS
#  data_gerada.txt: Arquivo com todas as sequências geradas (incluindo duplicatas).
#  datasunicas.txt: Arquivo com sequências únicas e um cabeçalho de resumo (contagem de gerados, 
#	únicos e duplicados).
#
#.EXAMPLE
#  ./seu_script.sh 1990
#  
#  Descrição: Inicia a geração das datas de 01/01/1990 até 31/12/ do ano atual.
#
#.NOTES
#  Autor: [Seu Nome/Alias, Opcional]
#  Data: [Data da Criação/Revisão]
#####################################################################################################

# --- Configuração de Cores para Melhor Visualização (Opcional) ---
VD='\033[0;32m'
VM='\033[0;31m'
NC='\033[0m' # No Color

# --- Variáveis de Arquivo ---
OUTPUT_FILE="data_gerada.txt"
UNIQUE_FILE="datasunicas.txt"

# --- Validação do Parâmetro ---
if [ "$#" -ne 1 ]; then
    echo -e "${VM}Erro:${NC} Você deve fornecer o ano inicial (4 dígitos) como parâmetro."
    echo "Uso: $0 <ano_inicial>"
    exit 1
fi

ANO_INICIAL=$1

# Verifica se o ano inicial é um número de 4 dígitos
if ! [[ "$ANO_INICIAL" =~ ^[0-9]{4}$ ]]; then
    echo -e "${VM}Erro:${NC} O ano inicial '$ANO_INICIAL' não é um ano válido de 4 dígitos."
    exit 1
fi

# Pega o ano atual do sistema
ANOCORRENTE=$(date +%Y)

echo -e "${VD}--- Iniciando Geração de Datas ---${NC}"
echo "Ano Inicial: $ANO_INICIAL"
echo "Ano Corrente: $ANOCORRENTE"
echo "Arquivos de Saída:"
echo "  - Dados Brutos: $OUTPUT_FILE"
echo "  - Dados Únicos e Resumo: $UNIQUE_FILE"
echo "-----------------------------------"

# Remove arquivos anteriores, se existirem
rm -f "$OUTPUT_FILE" "$UNIQUE_FILE"

# Inicializa o contador total de sequências geradas
TOTALGERADO=0

# Loop principal para iterar sobre cada ano, do inicial ao atual
for ((ANOVARIACAO = ANO_INICIAL; ANOVARIACAO <= ANOCORRENTE; ANOVARIACAO++)); do
    echo "Processando ano $ANOVARIACAO..."

    # Define o primeiro e o último dia do ano
    DATA_INICIO="$ANOVARIACAO-01-01"
    DATA_ULTIMA="$ANOVARIACAO-12-31"

    # Converte a data de início para segundos Unix
    TSTMPINICIO=$(date -d "$DATA_INICIO" +%s)
    # Converte a data de fim para segundos Unix
    TSTMP_FINAL=$(date -d "$DATA_FIM" +%s)

    # Loop para iterar sobre cada dia do ano
    for ((T_STAMPCALC = TSTMPINICIO; T_STAMPCALC <= TSTMP_FINAL; T_STAMPCALC += 86400)); do
        
        # Obtém a data no formato YYYY-MM-DD
        DATA__ATUAL=$(date -d "@$T_STAMPCALC" +%Y-%m-%d)

        # Extrai os componentes para formatação
        DIA_CALCULO=$(date -d "$DATA__ATUAL" +%d)
        MES_CALCULO=$(date -d "$DATA__ATUAL" +%m)
        ANO_COMPLET=$(date -d "$DATA__ATUAL" +%Y)
        ANO_EMCURTA=$(date -d "$DATA__ATUAL" +%y)

        # 1. ddMMyyyy
        FORMATO1="${DIA_CALCULO}${MES_CALCULO}${ANO_COMPLET}"
        # 2. ddMMyy
        FORMATO2="${DIA_CALCULO}${MES_CALCULO}${ANO_EMCURTA}"
        # 3. MMddyy
        FORMATO3="${MES_CALCULO}${DIA_CALCULO}${ANO_EMCURTA}"
        # 4. MMddyyyy
        FORMATO4="${MES_CALCULO}${DIA_CALCULO}${ANO_COMPLET}"

        # Array com todos os formatos de data base
        DATACALCULO=("$FORMATO1" "$FORMATO2" "$FORMATO3" "$FORMATO4")

        # --- NOVA LÓGICA: Salvar a data base (sem o sequencial 00-99) ---
        for DATACALCULO in "${DATACALCULO[@]}"; do
            # Salva a data base
            echo "$DATA_BASE" >> "$OUTPUT_FILE"
            TOTALGERADO=$((TOTALGERADO + 1))
            
            # Salva a data com a variação 00 a 99
            for i in {0..99}; do
                # Formata o número da variação para ter sempre 2 dígitos (ex: 00, 01, ..., 99)
                VALVARIACAO=$(printf "%02d" $i)
                SEQUENFINAL="${DATACALCULO}${VALVARIACAO}"

                # Escreve a sequência final no arquivo de saída
                echo "$SEQUENFINAL" >> "$OUTPUT_FILE"
                TOTALGERADO=$((TOTALGERADO + 1))
            done
        done
    done
done

echo "-----------------------------------"
echo -e "${VD}Geração de dados brutos concluída.${NC}"
echo "Total de sequências geradas (incluindo duplicatas): $TOTALGERADO"
echo "--- Processando Unicidade e Resumo ---"

# 1. Cria um arquivo temporário com as linhas únicas (ordenadas)
# O comando `sort | uniq` garante a unicidade.
sort "$OUTPUT_FILE" | uniq > tempunifile

# 2. Conta o número de sequências únicas
TOTAL_UNICO=$(wc -l < tempunifile)

# 3. Calcula o número de duplicatas removidas
DUPLICATASR=$((TOTALGERADO - TOTAL_UNICO))

# 4. Adiciona o resumo ao topo do arquivo de sequências únicas
{
    echo "--- RESUMO DA GERAÇÃO DE DATAS ---"
    echo "Ano Inicial: $ANO_INICIAL"
    echo "Ano Corrente: $ANOCORRENTE"
    echo "Total de Sequências Geradas (Brutas): $TOTALGERADO"
    echo "Total de Sequências Únicas (Neste Arquivo): $TOTAL_UNICO"
    echo "Total de Duplicatas Removidas: $DUPLICATASR"
    echo "-----------------------------------"
    cat tempunifile
} > "$UNIQUE_FILE"

# Remove o arquivo temporário
rm tempunifile

echo -e "${VD}Processamento de unicidade concluído.${NC}"
echo "Total de Sequências Únicas (Gravadas em '$UNIQUE_FILE'): $TOTAL_UNICO"
echo "Duplicatas Removidas: $DUPLICATASR"
echo -e "${VD}O script foi finalizado com sucesso!${NC}"