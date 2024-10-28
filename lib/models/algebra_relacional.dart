typedef Tabela = String;
typedef Expressao = String;
typedef AtributoTabela = String;

sealed class AlgebraComponente{}


class ProdutoCartesiano implements{

}

class Projecao implements AlgebraComponente{//π
   final Tabela tabela;
   final List<AtributoTabela> tabelaAtributos;
   final List<Expressao> selecoes; //σ
   Projecao({required this.tabela, required this.tabelaAtributos, required this.selecoes});
}


