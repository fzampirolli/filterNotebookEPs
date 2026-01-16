# sua solução
# incluir no VPL APENA a função;
def calcular_distancia(x1, y1, x2, y2):
    # Distância Manhattan: |x1 - x2| + |y1 - y2|
    return abs(x1 - x2) + abs(y1 - y2)

# não incluir o que segue:
x1, y1, x2, y2 = int(input()), int(input()), int(input()), int(input())
r = calcular_distancia(x1, y1, x2, y2)
print(r)
# max(0, r - 10)
# distância extra além dos 10 primeiros metros