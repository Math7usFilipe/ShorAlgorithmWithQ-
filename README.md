# Algoritmo de Shor em Q#

## Q#
É uma linguagem de programação desenvolvida pela Microsoft voltada ao desenvolvimento quântico.
## Algoritmo de Shor
É um algoritmo de fatoração, nele é possível fatorar números inteiros em tempo polinomial, sendo exponencialmente melhor que algoritmos não quânticos.
O algoritmo de Shor possui uma parte quântica e outra que chamamos de clássica. Essa parte quântica é responsável o périodo de uma função modular, que será usada para fatorar um número.

## Estrutura do Código
No arquivo `Program.qs` temos um programa chamado `Quantum.Shor`. Esse programa contém as operações e funções que implementam o Algoritmo de Shor utilizando bibliotecas padrões do Q#.

```
    Microsoft.Quantum.Intrinsic;
    Microsoft.Quantum.Canon;
    Microsoft.Quantum.Math;
    Microsoft.Quantum.Convert;
    Microsoft.Quantum.Measurement;
    Microsoft.Quantum.Random;
```

### Configurando o ambiente de execução do programa
Você deve seguir os passos que foram passados no site da Microsoft. Quando tudo estiver configurado o seu ambiente estará pronto para executar o programa por linha de comando.

**Documentação oficial:**
[Configure seu ambiente](https://learn.microsoft.com/en-us/azure/quantum/install-overview-qdk)
<br>

## **Funções e Operações**
### GCD
``` 
    function GCD(a: Int, b: Int) : Int
```
**Descrição:** Implementando o algoritmo de Euclides iterativo para calcular o máximo divisor comum (MDC) entre dois números inteiros `a` e `b`.
<br>
**Parâmetros:**
- `a`: Primeiro número inteiro;
- `b`: Segundo número inteiro.
<br>

**Retorno:** O MDC de `a` e `b`.
<br>

### MeasureInteger (Medição de Qubits)
```
    operation MeasureInteger(qubits: Qubit[]) : Int
```
**Descrição:** Mede um array de qubits e converte o resultado em um número inteiro.
<br>
**Parâmetros:**
- `qubits`: Arrays de qubits a serem medidos.
<br>

**Retorno:** O valor inteiro correspondente ao estado medido dos qubits.

### CustomRandomInt (Geração de Números Aleatórios)
**Descrição:** Gera um número pseudoaleatório entre `min` e `max` usando medição quânticas.
<br>

**Parâmetros:**
- `min`: Valor mínimo do intervalo;
- `max`: Valor máximo do intervalo.
<br>

**Retorno:** Um número aletório dentro do intervalo especificado.

### InverseQFT (Transformada de Fourier Quântica Inversa)
```
operation InverseQFT (qubits: Qubit[]) : Unit is Adj + Ctl
```
**Descrição:** Aplica a Tranformada de Fourier Quântica Inversa (QFT^-1) em um array de qubits.
<br>

**Parâmetros:** 
- `qubits`: Array de qubits no qual a QFT^-1 será aplicada.
<br>

**Obersavação:** A QFT^-1 é usada para estimar a fase quântica no algoritmo de Shor.

### PowMod (Exponenciação Modular)
```
function PowMod(a: Int, power: Int, N: Int) : Int
```
**Descrição:** Calcula `(a^power) % N` de forma eficiente usando exponenciação modular.
<br>

**Parâmetros:**
- `a`: Base da exponenciação;
- `power`: Expoente;
- `N`: Módulo.
<br>

**Retorno:** O resultado da exponenciação modular.

### ApplyXorInPlace (Aplicação de XOR)
```
operation ApplyXorInPlace(value: Int, qubits: Qubit[]) : Unit is Adj + Ctl
```
**Descrição:** Aplica um valor inteiro a um registro de qubits usando a operação `X`(NOT quântico).
<br>

**Parâmetros:**
- `value`: Valor inteiro a ser aplicado;
- `qubits`: Array de qubits no qual o valor será aplicado.
<br>

### ModularExponentiation (Exponenciação Modular Controlada)
```
operation ModularExponentiation(a: Int, power: Int, N: Int, qubits: Qubit[]) : Unit is Adj + Ctl
```
**Descrição:** Realiza a exponenciação modular controlada, usada na estimativa de fase quântica (QPE).
<br>

**Parâmetros:**
- `a`: Base exponenciação;
- `power`: Expoente;
- `N`: Módulo;
- `qubits`: Array de qubits no qual a operação será aplicada.
<br>

### QuantumPhaseEstimation (Estimativa de Fase Quântica)
```
operation QuantumPhaseEstimation(a: Int, N: Int) : Int
```
**Descrição:** Estima a fase quântica para encontrar o período `r` da função modular.
<br>

**Parâmetros:**
- `a`: Número aleatório coprimo com `N`;
- `N`: Número a ser fatorado.
<br>

**Retorno:** A fase estimada, que é usada para determinar o período `r`.

### ShorAlgorithm (Algoritmo de Shor)
```
operation ShorAlgorithm(N: Int) : (Int, Int)
```
**Descrição:** Implementa o Algoritmo de Shor para fatorar o número `N`.
<br>

**Parâmetro:**
- `N`: Número inteiro a ser fatorado;
<br>

**Retorno:** Um par de fatores de `N`.

### RunShorAlgorithm (Ponto de Entrada)
```
@EntryPoint()
operation RunShorAlgorithm() : (Int, Int)
```
**Descrição:** Ponto de entrada do programa. Executa o Algoritmo de Shor para fatorar um número específico(`N = 9999`) e imprime os fatores encontrados.
<br>

**Retorno:** Um par de fatores de `N`.

### Fluxo do Algoritmo de Shor

- **Escolha de `a`**: Um número aleatório `a` é escolhido entre 1 e `N - 1` usando `CustomRandomInt`;
- **Verificação de Coprimalidade:** O MDC entre `a` e `N` é calculado usando `GCD`. Se `a` e `N` não forem coprimos, um novo `a` é escolhido;
- **Estimativa de Fase:** A fase quântica é estimada usando `QuantumPhaseEstimation`, que envolve a aplicação QFT^-1;
- **Cálculo do Período:** O período `r` é derivado da fase estimada;
- **Fatoração:** Se `r` for par e `a^(r/2) % N != N-1`, os fatores de `N` são calculados usando `GCD`;
- **Repetição:** Se as condições não forem satisfeitas, o algoritmo é repetido.

### Exemplo de Uso
O ponto de entrada `RunShorAlgorithm` executa o algoritmo para fatorar o número `99999`. O resultado é impresso na saída.

### Considerações
O código é uma implementação didática do Algoritmo de Shor.
<br>
A parte quântica (QPE e QFT^-1) é cruncial para a efiencência do algoritmo.
<br>
O algoritmo pode ser adaptado para fatorar outros números inteiros, alterando o valor de `N` no ponto de entrada;
<br>

### OBS:
O seundo arquivo no diretório `recursiveSolution` é uma abordagem recursiva do primeiro código. Nele podemos receber todos fatores de um números, mas por limitações tanto minhas quanto da VM não consegui obter os fatores de qualquer número maior que 5. Caso você encontre um solução para o que está acarretando isso você está apto a fazer qualquer modificação e publicação relacionada a esse repositório.

