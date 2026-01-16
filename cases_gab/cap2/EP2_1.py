# sua solução
def delta(a, b, c):
    d = b * b - 4 * a * c
    return d

# Programa principal
valor = delta(5, -2, 4)
print("O delta de 5x^2 – 2x + 4 é %.1f" % valor)