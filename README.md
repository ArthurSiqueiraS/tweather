# Tweather API

Uma API para enviar tweets com informações do clima de qualquer cidade, através do twitter https://twitter.com/tweatherapi.

O projeto utiliza a API [OpenWeatherMap](https://github.com/ArthurSiqueiraS/open-weather) para buscar os dados de clima e a API para desenvolvedores do [Twitter](https://github.com/sferik/twitter) para publicar os tweets.

## Versões

- Ruby 2.5.1
- Rails 6.0.3.4
- Bundler 2.0.2

## Instalação

```bash
bundle install
```

## Inicialização

```ruby
rails s -p [PORT]
```

A aplicação deverá ficar disponível em http://localhost:[PORT]

## Enviar uma requisição de tweet

É necessário passar como parâmetro o ID da cidade que se deseja informar o clima. [Lista de IDs de cidades](http://bulk.openweathermap.org/sample/).

### Requisição

`POST /post`

    curl -H 'Accept: application/json' -d 'cityId=3454244' http://localhost:3000/post

### Resposta

    HTTP/1.1 201 Created
    X-Frame-Options: SAMEORIGIN
    X-XSS-Protection: 1; mode=block
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Permitted-Cross-Domain-Policies: none
    Referrer-Policy: strict-origin-when-cross-origin
    Content-Type: application/json; charset=utf-8
    ETag: W/"e0391b92a629e172ad3e38df14a57da1"
    Cache-Control: max-age=0, private, must-revalidate
    X-Request-Id: 38f5a3c2-bd27-46a8-a7ed-22513b4e8114
    X-Runtime: 3.565954
    Transfer-Encoding: chunked

    {
      "tweet_url": "https://twitter.com/tweatherapi/status/1333138369027694597",
      "tweet_text": "30°C e nuvens dispersas em Pelotas em 29/11.. Média para os próximos dias: 21°C em 30/11, 19°C em 01/12, 21°C em 02/12, 22°C em 03/12 e 21°C em 04/12."
    }

## Tweets duplicados

Devido a restrições da API do Twitter, tweets com textos idênticos a outros tweets recentes da mesma conta não podem ser publicados. Caso isto aconteça, a resposta retornará o tweet original e uma mensagem indicando que não foi publicado um novo tweet.

    {
      "tweet_url": "https://twitter.com/tweatherapi/status/1333138369027694597",
      "tweet_text": "30°C e nuvens dispersas em Pelotas em 29/11.. Média para os próximos dias: 21°C em 30/11, 19°C em 01/12, 21°C em 02/12, 22°C em 03/12 e 21°C em 04/12.",
      "message": "O texto gerado era uma duplicata de um tweet recente e não foi publicado."
    }
