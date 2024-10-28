import 'package:processador_consultas/extensions/string_extension.dart';

import '../models/algebra_relacional.dart';
import '../models/select.dart';

typedef Tabela = String;
typedef Expressao = String;
typedef Atributo = String;

class ConvertorAlgebra{
  static List<Projecao> projecoesFrom({required Select select}) {
    final List<Tabela> tabelasEmJoins = select.joins.map((join) => join.tabela)
        .toList();
    final List<Tabela> tabelas = [select.principal, ...tabelasEmJoins];

    final List<List<Atributo>> atributos = tabelas.map((tabela) =>
        tabela.obterAtributosEmTabela(select)).toList();

    final List<List<Expressao>> selecoes = tabelas.map((tabela) =>
        select.wheres.where((where) =>
            tabela.verificarWhereEmTabela(condicaoWhere: where)).toList()
    ).toList();

    final List<Projecao> projecoes = [];

    for (final (idx, _) in tabelas.indexed) {
      final projecao = Projecao(tabela: tabelas[idx],
          tabelaAtributos: atributos[idx],
          selecoes: selecoes[idx]);
      projecoes.add(projecao);
    }

    return projecoes;
  }
}