***Settings***
Documentation       Receber Pedidos
...                 Sendo um cozinheiro que possui produtos no dashboard
...                 Quero receber solicitação de preparo dos pratos
...                 Para que eu possa enviá-los aos clientes

Resource    ../resources/base.robot

Library               RequestsLibrary
Library               OperatingSystem

Test Setup      Open Session
Test Teardown   Close Session

***Test Cases***
Receber Novo Pedido
    Dado que "cozinheiro@gmail.com" é a minha conta de cozinheiro
    E "cliente@gmail.com" é o email do cliente 
    E que "Hamburguer Vegano" está cadastrado no meu dashboard
    Quando o cliente solicita o preparo dos meus pratos
    Então devo receber uma notificação de pedido
    E posso aceitar ou rejeitar o pedido

***Keywords***
Dado que "${email_cozinheiro}" é a minha conta de cozinheiro
    Set Test Variable       ${email_cozinheiro}

    &{headers}=       Create Dictionary        Content-Type=application/json
    &{payload}=       Create Dictionary        email=${email_cozinheiro}

    Create Session         api                http://ninjachef-api-qaninja-io.umbler.net
    ${resp}=               Post Request       api            /sessions             data=${payload}          headers=${headers}
    Status Should Be       200                ${resp}

    ${token_cozinheiro}     Convert to String         ${resp.json()['_id']}
    Set Test Variable       ${token_cozinheiro}

E "${email_cliente}" é o email do cliente
    Set Test Variable       ${email_cliente}

    &{headers}=       Create Dictionary        Content-Type=application/json
    &{payload}=       Create Dictionary        email=${email_cliente}

    Create Session         api                http://ninjachef-api-qaninja-io.umbler.net
    ${resp}=               Post Request       api            /sessions             data=${payload}          headers=${headers}
    Status Should Be       200                ${resp}

    ${token_cliente}     Convert to String         ${resp.json()['_id']}
    Set Test Variable       ${token_cliente}


E que "${produto}" está cadastrado no meu dashboard
    Set Test Variable       ${produto}

    &{payload}=         Create Dictionary       name=${produto}     plate=Kind      price=23.00

    ###buscando a imagem no formato binário
    ${image_file}=      Get Binary File        ${EXECDIR}/resources/images/hamburguerVeggie.jpg
    &{files}=           Create Dictionary       thumbnail=${image_file}
    
    ###obtendo o token na API
    &{headers}=         Create Dictionary       user_id=${token_cozinheiro}

    ###cria a sessão na API e manda um POST na rota /products enviando a foto e o payload como nome, preço e tipo
    Create Session         api                http://ninjachef-api-qaninja-io.umbler.net
    ${resp}=               Post Request       api            /products           files=${files}       data=${payload}          headers=${headers}
    Status Should Be       200                ${resp}

    ${produto_id}          Convert to String         ${resp.json()['_id']}
    Set Test Variable      ${produto_id}

    Go To           ${base_url}
    Input Text      ${CAMPO_EMAIL}    ${email_cozinheiro}
    Click Element   ${BOTAO_ENTRAR}
    Wait Until Page Contains Element    ${DIV_DASH}



Quando o cliente solicita o preparo dos meus pratos
    
    &{headers}=       Create Dictionary        Content-Type=application/json        user_id=${token_cliente}
    &{payload}=       Create Dictionary        payment=Dinheiro

    Create Session         api                http://ninjachef-api-qaninja-io.umbler.net
    ${resp}=               Post Request       api            /products/${produto_id}/orders             data=${payload}          headers=${headers}
    Status Should Be       200                ${resp}


Então devo receber uma notificação de pedido

    ${mensagem_esperada}          Convert To String       ${email_cliente} está solicitando o preparo do seguinte prato: ${produto}
    Wait Until Page Contains      ${mensagem_esperada}    10


E posso aceitar ou rejeitar o pedido
    Wait Until Page Contains        ACEITAR         5
    Wait Until Page Contains        REJEITAR        5