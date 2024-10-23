import '../models/algebra_relacional.dart';
import '../models/select.dart';

typedef Tabela = String;
typedef Expressao = String;
typedef Atributo = String;
class ConvertorAlgebra{
  static List<Projecao> projecoesFrom({required Select select}){
    final List<Tabela> tabelasEmJoins = select.joins.map((join)=>join.tabela).toList();
    final List<Tabela> tabelas = [select.principal, ...tabelasEmJoins];

    final List<List<Atributo>> atributos = tabelas.map((tabela) => _obterAtributosDeTabela(select, tabela)).toList();

    final List<List<Expressao>> selecoes = tabelas.map((tabela) =>
      select.wheres.where((where) =>_verificarTabelaEmWhere(condicaoWhere: where, tabela: tabela)).toList()
    ).toList();

    final List<Projecao> projecoes = [];

    for(final (idx,_) in tabelas.indexed){
      final projecao = Projecao(tabela: tabelas[idx], tabelaAtributos: atributos[idx], selecoes: selecoes[idx]);
      projecoes.add(projecao);
    }

    return projecoes;
  }

  static bool _verificarTabelaEmWhere({required String condicaoWhere,required String tabela}) {
    RegExp tabelaRegex = RegExp(r'\b' + tabela + r'\.[a-zA-Z0-9_]+\b');
    final isMatch = tabelaRegex.hasMatch(condicaoWhere);
    print("Foi verificado o where ($condicaoWhere) usando a tabela ($tabela) e o resultado foi $isMatch");
    return isMatch;
  }

  static List<String> _obterAtributosDeTabela(Select select, String tabela) {
    List<String> atributos = [];

    for (var campo in select.campos) {
      if (campo.tabela == tabela) {
        atributos.add(campo.atributo);
      }
    }

    for (var join in select.joins) {
      RegExp regex = RegExp(r'([a-zA-Z0-9_]+)\.([a-zA-Z0-9_]+)');
      Iterable<RegExpMatch> matches = regex.allMatches(join.condicao);

      for (var match in matches) {
        if (match.group(1) == tabela) {
          atributos.add(match.group(2)!);
        }
      }
    }

    for (var where in select.wheres) {
      RegExp regex = RegExp(r'([a-zA-Z0-9_]+)\.([a-zA-Z0-9_]+)');
      Iterable<RegExpMatch> matches = regex.allMatches(where);

      for (var match in matches) {
        if (match.group(1) == tabela) {
          atributos.add(match.group(2)!);
        }
      }
    }

    return atributos;
  }
}