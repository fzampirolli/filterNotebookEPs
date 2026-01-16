# sua solução
import math

# Leitura das 4 coordenadas (valores reais)
ax = float(input())
ay = float(input())
bx = float(input())
by = float(input())

# Cálculo da distância Euclidiana
# Fórmula: raiz((xb - xa)² + (yb - ya)²)
distancia = math.sqrt((bx - ax)**2 + (by - ay)**2)

# Impressão formatada com duas casas decimais
print(f"{distancia:.2f}")
