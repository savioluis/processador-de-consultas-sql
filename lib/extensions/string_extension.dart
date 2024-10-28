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