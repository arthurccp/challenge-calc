# Challenge Calc

Aplicativo de calculadora para iPhone e iPad, desenvolvido em Swift, com interface em SwiftUI integrada ao ciclo de vida UIKit. Permite realizar operações básicas e consultar um histórico salvo localmente no dispositivo.

## Funcionalidades

- Adição, subtração, multiplicação e divisão.
- Entrada de números decimais com separador conforme a configuração regional do dispositivo.
- Exibição da operação e do resultado.
- Operações encadeadas, calculadas na ordem em que são selecionadas.
- Botão **AC** para limpar o cálculo atual.
- Histórico com expressão, resultado, data e horário, exibindo os registros mais recentes primeiro.
- Reutilização de um resultado ao tocar em um item do histórico.
- Exclusão individual de registros ao deslizar o item e limpeza completa com confirmação.
- Persistência do histórico entre aberturas do aplicativo.
- Alertas para divisão por zero, valores fora do limite e falhas ao carregar ou salvar o histórico.
- Rótulos de acessibilidade para os controles da calculadora.

## Tecnologias e organização

O projeto utiliza SwiftUI para as telas, Combine para atualização do estado e Foundation para cálculos e armazenamento. A organização segue o padrão MVVM, com a lógica de apresentação separada das views e da persistência.

```text
challenge-calc/
├── Models/
│   └── Calculation.swift              # Registro, operações e erros de cálculo
├── ViewModels/
│   └── CalculatorViewModel.swift      # Estado e ações da calculadora
├── Views/
│   ├── CalculatorView.swift           # Tela principal e teclado
│   └── HistoryView.swift              # Consulta e gerenciamento do histórico
├── Persistence/
│   └── CalculationHistoryStore.swift  # Leitura e gravação em JSON
├── ViewController.swift              # Integração entre UIKit e SwiftUI
├── AppDelegate.swift
└── SceneDelegate.swift
```

Os cálculos utilizam `Decimal`. O histórico é codificado com `Codable` e gravado de forma atômica no arquivo `Calculator/history.json`, dentro do diretório Application Support do aplicativo. O funcionamento é local e não exige conexão com a internet ou dependências externas.

## Como executar

1. Em um Mac, instale uma versão do Xcode com suporte ao SDK do iOS 18.4 ou superior.
2. Abra o arquivo `challenge-calc.xcodeproj` no Xcode.
3. Selecione o esquema `challenge-calc` e um simulador de iPhone ou iPad com iOS 18.4 ou superior.
4. Execute com **⌘R**.

Para executar em um dispositivo físico, configure a equipe de desenvolvimento em **Signing & Capabilities** e selecione o dispositivo como destino.

## Como usar

Digite um número, selecione uma operação, informe o segundo número e toque em **=**. O cálculo concluído será salvo no histórico, acessível pelo botão no canto superior da tela.

Ao tocar em um registro do histórico, seu resultado é carregado na calculadora para iniciar outra operação.

## Comportamentos e limites

- A entrada permite até 16 dígitos por número.
- As operações encadeadas são resolvidas sequencialmente, sem precedência matemática. Por exemplo, `2 + 3 × 4 =` resulta em `20`.
- O histórico registra a operação finalizada ao tocar em **=**; etapas intermediárias de uma sequência não geram registros separados.
- Se o histórico não puder ser carregado, o aplicativo preserva o arquivo existente e bloqueia alterações no histórico até uma nova tentativa ao reabrir o app.

## Validação manual

O projeto não possui uma suíte de testes automatizados. Alguns cenários para conferir no simulador:

- Realizar as quatro operações, incluindo números decimais e resultados negativos.
- Tentar dividir por zero e verificar o alerta.
- Encadear operações e conferir a execução sequencial.
- Concluir um cálculo, fechar e reabrir o aplicativo e conferir o histórico.
- Reutilizar um resultado, excluir um registro e limpar todo o histórico.
