/// - [n] Número de Página
/// - [i] Instrução
/// - [d] Dado
/// - [r] Bit de Acesso
/// - [m] Bit de Modificação
/// - [t] Tempo de Envelhecimento
class PaginaDeMemoria {
  int n;
  int i;
  int d;
  int r;
  int m;
  int t;

  PaginaDeMemoria({
    required this.n,
    required this.i,
    required this.d,
    required this.r,
    required this.m,
    required this.t,
  });
}
