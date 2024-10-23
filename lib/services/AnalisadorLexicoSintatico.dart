import '../models/select.dart';

class CampoRegex {
  String tabela;
  String nome;

  CampoRegex(this.tabela, this.nome);

  @override
  String toString() {
    return '$tabela.$nome';
  }
}

class JoinRegex {
  String tabela;
  String condicao;

  JoinRegex(this.tabela, this.condicao);
}

class AnalisadorLexicoSintatico{
  static Select generate({required String query}) {

    // Regex para capturar os campos, a tabela principal e os joins
    RegExp regex = RegExp(
        r'SELECT\s+((?:[a-zA-Z0-9_]+\.[a-zA-Z0-9_]+(?:,\s*)?)+)\s+FROM\s+([a-zA-Z0-9_]+)(.*)');

    // Aplicando a regex
    RegExpMatch? match = regex.firstMatch(query);

    if (match != null) {
      // Captura os campos e a tabela principal
      String campos = match.group(1)!;
      String tabelaPrincipal = match.group(2)!;
      String resto = match.group(3)!;

      // Convertendo os campos em uma lista de objetos Campo
      List<CampoRegex> listaCampos = campos.split(',').map((campo) {
        var partes = campo.trim().split('.');
        return CampoRegex(partes[0], partes[1]);
      }).toList();

      // Verificando se todos os campos possuem ponto
      bool validacaoCampos = listaCampos
          .every((campo) => campo.tabela.isNotEmpty && campo.nome.isNotEmpty);

      if (validacaoCampos) {
        // Processando os joins
        List<JoinRegex> joins = [];
        RegExp joinRegex = RegExp(
            r'JOIN\s+([a-zA-Z0-9_]+)\s+ON\s+([a-zA-Z0-9_]+\.[a-zA-Z0-9_]+)\s*=\s*([a-zA-Z0-9_]+\.[a-zA-Z0-9_]+)',
            dotAll: true);
        Iterable<RegExpMatch> joinMatches = joinRegex.allMatches(resto);

        for (var joinMatch in joinMatches) {
          String tabelaJoin = joinMatch.group(1)!;
          String condicao = '${joinMatch.group(2)} = ${joinMatch.group(3)}';

          joins.add(JoinRegex(tabelaJoin, condicao));
        }

        // Processando a cláusula WHERE
        RegExp whereRegex =
        RegExp(r'WHERE\s+(.*?)(?=\s+WHERE\s+|$)', dotAll: true);
        Iterable<RegExpMatch> whereMatches = whereRegex.allMatches(resto);

        List<String> listaWhere = [];
        for (var whereMatch in whereMatches) {
          String condicaoWhere = whereMatch.group(1)!.trim();
          // Dividindo a condição em partes por AND
          List<String> partesWhere = condicaoWhere.split(RegExp(r'\s+AND\s+'));

          // Verificando cada parte
          for (String parte in partesWhere) {
            if (AnalisadorLexicoSintatico._validarCondicao(parte.trim())) {
              listaWhere.add(parte.trim());
            } else {
              throw Exception(
                  'Erro: Condição inválida na cláusula WHERE: ${parte.trim()}.');
            }
          }
        }
        // Mostrando o resultado
        print('Campos: ${listaCampos}');
        print('Tabela Principal: $tabelaPrincipal');
        print('Joins:');
        for (var join in joins) {
          print('  Tabela: ${join.tabela}, Condição: ${join.condicao}');
        }
        // Mostrando as condições do WHERE
        print('Condições WHERE:');
        for (var where in listaWhere) {
          print('  $where');
        }

        final select = Select(
            tabelaPrincipal,
            listaCampos
                .map((campo) => Campo(campo.tabela, campo.nome))
                .toList(),
            joins.map((join) => Join(join.tabela, join.condicao)).toList(),
            listaWhere);
        return select;
      } else {
        throw Exception(
            'Erro: Todos os campos devem ter o formato "tabela.campo".');
      }
    } else {
      throw Exception('Consulta SQL inválida.');
    }
  }

  static bool _validarCondicao(String condicao) {
    // Regex para verificar se a condição é válida com base nos operadores permitidos
    RegExp condicaoRegex = RegExp(
        r"([a-zA-Z0-9_]+\.[a-zA-Z0-9_]+|\'[^\']*\'|\d+)\s*(=|>|<|>=|<=|<>|AND)\s*([a-zA-Z0-9_]+\.[a-zA-Z0-9_]+|\'[^\']*\'|\d+)");

    // Verifica se a condição contém o operador "OR", o qual não é permitido
    if (condicao.contains('OR')) {
      print('Erro: Operador "OR" não é permitido nas condições.');
      return false;
    }

    // Verifica se a condição segue o padrão correto
    if (!condicaoRegex.hasMatch(condicao.trim())) {
      return false;
    }

    return true;
  }
}

