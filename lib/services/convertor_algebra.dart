import 'package:processador_consultas/extensions/string_extension.dart';

import '../models/algebra_relacional.dart';
import '../models/select.dart';

typedef Tabela = String;
typedef Expressao = String;
typedef Atributo = String;

class ConvertorAlgebra{

  static AlgebraArvore _arvoreAlgebra({required Select select}) {
    final projecoes = _projecoesFrom(select: select);

    final naoTemJoin = select.joins.isEmpty;
    if (naoTemJoin) return AlgebraArvoreSemJoin(projecao: projecoes[0]);

    final arvoreNome = select.campos.fold("", (acc, campo) {
      return "$acc${campo.tabela}.${campo.atributo},";
    });
    final expressoesJoin = select.joins.map((join) => join.condicao).toList();
    //////
    List<ProdutoCartesiano> produtosCartesianos = [];
    expressoesJoin.forEach((expressaoJoin){
      final ProdutoCartesiano produtoCartesiano = ProdutoCartesiano(
          noEsquerdo: NoVazio(),
          noDireito: NoVazio()
      );

      projecoes.forEach((projecao){
          final tabela = projecao.tabela;
          final (tb1,tb2) = expressaoJoin.obterTabelasEmJoin();

          if(tabela == tb1 && produtoCartesiano.temEspaco()){
            produtoCartesiano.addNoEsquerdo(projecao);
          }else if(tabela == tb2 && produtoCartesiano.temEspaco()){
            produtoCartesiano.addNoDireito(projecao);
          }
          if(produtoCartesiano.noEsquerdo is! NoVazio && produtoCartesiano.noDireito is! NoVazio){
            produtosCartesianos.add(produtoCartesiano);
          }
      });

    });

    return ArvoreAlgebraComJoin(
        nomeRaiz: arvoreNome,
        produtoCartesiano: produtoCartesianoRaiz
    );
  }


  static List<Projecao> _projecoesFrom({required Select select}) {
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