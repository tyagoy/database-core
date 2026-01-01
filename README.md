# database-core

Biblioteca Ruby para centralizar o acesso a banco de dados e regras comuns de persistência, para ser reutilizada entre diferentes serviços e aplicações da organização.

Ela não é uma aplicação standalone, mas sim um "core" que expõe classes, módulos e configurações para ser usada como dependência em outros projetos Ruby/Rails.

## Instalação

### Via Git (recomendado durante o desenvolvimento)

No `Gemfile` da sua aplicação, adicione:

```ruby
gem 'database-core', git: 'https://github.com/[USERNAME]/database-core.git'
```

Depois rode:

```bash
bundle install
```

### Via gem (quando publicada no RubyGems)

Quando a gem estiver publicada, você poderá instalá-la com:

```bash
gem install database-core
```

Ou adicionar ao `Gemfile`:

```ruby
gem 'database-core'
```

## Uso

1. Adicione a gem ao seu projeto (ver seção de Instalação).
2. Requeira a biblioteca principal no ponto de entrada da sua aplicação, caso necessário:

```ruby
require 'database/core'
```

3. Utilize os módulos e classes expostos pela gem, por exemplo:

```ruby
# Exemplo ilustrativo, ajuste para refletir suas APIs reais
DatabaseCore::Core.configure do |config|
  config.logger = Rails.logger
  config.default_connection_url = ENV['DATABASE_URL']
end

connection = DatabaseCore::Core.connection
result = connection.execute('SELECT 1')
```

Consulte a pasta `lib/` para ver os componentes disponíveis (conexões, repositórios, adapters, etc.) e adapte o exemplo acima à API real do projeto.

## Desenvolvimento

Após clonar o repositório, instale as dependências:

```bash
bin/setup
```

Para abrir um console interativo com o ambiente da gem carregado:

```bash
bin/console
```

Para rodar a suíte de testes (ajuste o comando conforme o test runner configurado, por exemplo RSpec ou Minitest):

```bash
bundle exec rake test
# ou
bundle exec rspec
```

Para instalar a gem localmente (para usar em outro projeto do mesmo ambiente):

```bash
bundle exec rake install
```

Para criar uma nova versão:

1. Atualize o número da versão em `lib/database/core/version.rb`.
2. Rode:

```bash
bundle exec rake release
```

Isso criará uma tag git, fará o push dos commits e publicará a gem (se configurado).

## Contribuindo

Relatos de bugs e pull requests são bem-vindos no GitHub em:

https://github.com/[USERNAME]/database-core

Ao contribuir, siga as boas práticas de código Ruby, adicione testes cobrindo as mudanças e atualize a documentação quando necessário.

## Licença

Este projeto está disponível como código aberto sob os termos da [Licença MIT](https://opensource.org/licenses/MIT).

## Código de Conduta

Todos que interagem com o repositório `database-core`, issue trackers, salas de bate-papo e listas de e-mail devem seguir o código de conduta definido em:

https://github.com/[USERNAME]/database-core/blob/master/CODE_OF_CONDUCT.md
