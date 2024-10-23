typedef Tabela = String;
typedef Expressao = String;

class Campo {
  final Tabela tabela;
  final String atributo;
  Campo(this.tabela, this.atributo);
}

class Join {
  final Tabela tabela;
  final Expressao condicao;
  Join(this.tabela, this.condicao);
}

class Select {
  final Tabela principal;
  final List<Campo> campos;
  final List<Join> joins;
  final List<Expressao> wheres;
  Select(this.principal, this.campos, this.joins, this.wheres);
}

