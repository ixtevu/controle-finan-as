# Minhas Finanças (Flutter)

App de controle financeiro pessoal, offline, com SQLite.

## Como rodar

1. Crie o projeto base (gera as pastas android/ e ios/):
   flutter create controle_financas
2. Copie para dentro dele, substituindo os existentes:
   - pubspec.yaml
   - a pasta lib/ inteira
3. Instale as dependências e rode:
   flutter pub get
   flutter run

## Funcionalidades
- Receitas e despesas com valor, data, descrição e categoria
- Resumo mensal (saldo, receitas, despesas) e navegação entre meses
- Gráfico de despesas por categoria
- Editar (toque no item) e excluir (deslize para a esquerda, com "Desfazer")
- Dados salvos localmente no aparelho
