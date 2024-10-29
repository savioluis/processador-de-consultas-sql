import 'package:processador_consultas/extensions/string_extension.dart';

import '../models/algebra_relacional.dart';
import '../models/select.dart';

typedef Tabela = String;
typedef Expressao = String;
typedef Atributo = String;

class ConvertorAlgebra{

  static AlgebraArvore _arvoreAlgebra({required Select select}) {
    //arvore sem join
    final projecoes = _projecoesFrom(select: select);

    final naoTemJoin = select.joins.isEmpty;
    if (naoTemJoin) return AlgebraArvoreSemJoin(projecao: projecoes[0]);

    final arvoreNome = select.campos.fold("", (acc, campo) {
      return "$acc${campo.tabela}.${campo.atributo},";
    });
    final expressoesJoin = select.joins.map((join) => join.condicao).toList();
    
    //arvore com join
    List<ProdutoCartesiano> produtosCartesianos = [];

    for (int i = 0; i < expressoesJoin.length; i++) {
      final expressaoJoinAtual = expressoesJoin[i];
      final produtoCartesiano = ProdutoCartesiano.vazio();

      for (int j = 0; j < projecoes.length; j++) {
        final projecaoAtual = projecoes[j];
        final tabela = projecaoAtual.tabela;
        final (tb1,tb2) = expressaoJoinAtual.obterTabelasEmJoin();

        if (tabela == tb1 && produtoCartesiano.temEspaco()) {
          produtoCartesiano.addNoEsquerdo(projecaoAtual);
        } else if (tabela == tb2 && produtoCartesiano.temEspaco()) {
          produtoCartesiano.addNoDireito(projecaoAtual);
        }

        if (!produtoCartesiano.temEspaco()) {
          produtosCartesianos.add(produtoCartesiano);
        }

      }
      //se o produto cartesiano nao foi adicionado na lista,
      // significa que ele possui algum nó como NoVazio
      // e será passado para esse NoVazio o produto cartesiano anterior
      if (!produtosCartesianos.contains(produtoCartesiano)) {
        if (produtoCartesiano.noEsquerdo is NoVazio) {
          produtoCartesiano.addNoEsquerdo(produtosCartesianos[i-1]);
        } else if (produtoCartesiano.noDireito is NoVazio) {
          produtoCartesiano.addNoDireito(produtosCartesianos[i-1]);
        }
      }
    }

    //dessa forma tenho os produtos cartesianos em ordem,
    //com suas projecoes e eu conheco quem é a raiz
    //assim consigo formar a arvore

    return AlgebraArvoreComJoin(
        raiz: arvoreNome,
        produtoCartesiano: produtosCartesianos,
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