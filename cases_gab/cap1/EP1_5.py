# sua solução
# EP1_5 ➕ Soma da PA — Matemática sem Loops

# Leitura dos 3 valores inteiros
a1 = int(input())  # Primeiro termo
r = int(input())   # Razão
n = int(input())   # Número de termos

# 1. Encontrar o último termo (an)
# Fórmula: an = a1 + (n - 1) * r
an = a1 + (n - 1) * r

# 2. Calcular a soma (Sn)
# Fórmula: Sn = (n * (a1 + an)) / 2
# Importante: Usamos // para divisão inteira em Python
sn = (n * (a1 + an)) // 2

# Impressão do resultado
print(sn)
