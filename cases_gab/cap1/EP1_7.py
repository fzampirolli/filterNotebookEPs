# sua solução
# Lê o número como inteiro
n = int(input())

# Extrai cada dígito, soma 1 e aplica o módulo 10
# Milhar
d1 = (n // 1000 + 1) % 10
# Centena
d2 = ((n // 100) % 10 + 1) % 10
# Dezena
d3 = ((n // 10) % 10 + 1) % 10
# Unidade
d4 = (n % 10 + 1) % 10

# Imprime tudo junto para formar o "novo número"
# O sep='' garante que não haja espaços entre os dígitos
print(f"{d1}{d2}{d3}{d4}")
