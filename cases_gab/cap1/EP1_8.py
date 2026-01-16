# sua solução
# Leitura da capacidade total
capacidade = int(input())

# 500kg
print(capacidade // 500)
capacidade %= 500

# 100kg
print(capacidade // 100)
capacidade %= 100

# 25kg
print(capacidade // 25)
capacidade %= 25

# 1kg (o que sobrou)
print(capacidade)
