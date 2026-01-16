# sua solução
# Leitura dos valores na ordem: VP, FN, FP, VN
vp = int(input())
fn = int(input())
fp = int(input())
vn = int(input())

# Cálculos das métricas
acuracia = (vp + vn) / (vp + vn + fp + fn)
precisao = vp / (vp + fp)
sensibilidade = vp / (vp + fn)

# Impressão formatada
print(f"{acuracia:.2f}")
print(f"{precisao:.2f}")
print(f"{sensibilidade:.2f}")
