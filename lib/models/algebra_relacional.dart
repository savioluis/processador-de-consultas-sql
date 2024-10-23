typedef Tabela = String;
typedef Expressao = String;
typedef AtributoTabela = String;
//π
class Projecao{
   final Tabela tabela;
   final List<AtributoTabela> tabelaAtributos;
   final List<Expressao> selecoes; //σ
   Projecao({required this.tabela, required this.tabelaAtributos, required this.selecoes});
}


