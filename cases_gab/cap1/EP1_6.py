# sua solução
# Lê o valor total
valor_total = float(input())

# Aplica os descontos sucessivos (10% e depois mais 10%)
# Matematicamente equivalente a multiplicar por 0.81
valor_final = valor_total * 0.90 * 0.90

# Imprime formatado com 2 casas decimais
print(f"{valor_final:.2f}")
