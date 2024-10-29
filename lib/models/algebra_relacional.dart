typedef Tabela = String;
typedef Expressao = String;
typedef AtributoTabela = String;

sealed class AlgebraArvore {}

final class AlgebraArvoreSemJoin implements AlgebraArvore {
  final Projecao projecao;
  AlgebraArvoreSemJoin({required this.projecao});
}

final class AlgebraArvoreComJoin implements AlgebraArvore {
  final String raiz;
  final List<ProdutoCartesiano> produtoCartesiano;
  AlgebraArvoreComJoin({required this.raiz, required this.produtoCartesiano});
}

sealed class AlgebraComponente {}

final class NoVazio implements AlgebraComponente {}

final class ProdutoCartesiano implements AlgebraComponente {
  AlgebraComponente noEsquerdo;
  AlgebraComponente noDireito;

  ProdutoCartesiano({
    required this.noEsquerdo,
    required this.noDireito,
  });

  ProdutoCartesiano.vazio()
      : noDireito = NoVazio(),
        noEsquerdo = NoVazio();

  void addNoDireito(AlgebraComponente no) => noDireito = no;
  void addNoEsquerdo(AlgebraComponente no) => noEsquerdo = no;
  bool temEspaco() => noEsquerdo is NoVazio || noDireito is NoVazio;
}

final class Projecao implements AlgebraComponente {
  //π
  final Tabela tabela;
  final List<AtributoTabela> tabelaAtributos;
  final List<Expressao> selecoes; //σ
  Projecao(
      {required this.tabela,
      required this.tabelaAtributos,
      required this.selecoes});
}