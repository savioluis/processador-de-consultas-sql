import '../models/select.dart';

extension Tabela on String{
  bool verificarWhereEmTabela({required String condicaoWhere}) {
    final tabela = this;
    RegExp tabelaRegex = RegExp(r'\b' + tabela + r'\.[a-zA-Z0-9_]+\b');
    final isMatch = tabelaRegex.hasMatch(condicaoWhere);
    print("Foi verificado o where ($condicaoWhere) usando a tabela ($tabela) e o resultado foi $isMatch");
    return isMatch;
  }

  List<String> obterAtributosEmTabela(Select select) {
    final tabela = this;
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

extension JoinExpressao  on String{
  (String tb1, String tb2) obterTabelasEmJoin() {
    RegExp regex = RegExp(r'([a-zA-Z0-9_]+)\.[a-zA-Z0-9_]+');
    var matches = regex.allMatches(this).map((match) => match.group(1)!).toSet();

    if (matches.length != 2) {
      throw Exception('Erro: A expressão JOIN deve conter exatamente duas tabelas.');
    }
    final matchesToList = matches.toList();
    return (matchesToList[0],matchesToList[1]);
  }
}