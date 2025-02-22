import Microsoft.Quantum.Diagnostics.*;
open Microsoft.Quantum.Intrinsic;
open Microsoft.Quantum.Canon;
open Microsoft.Quantum.Math;
open Microsoft.Quantum.Convert;
open Microsoft.Quantum.Measurement;
open Microsoft.Quantum.Random;

// Função para calcular o MDC (Máximo Divisor Comum)
function GCD(a: Int, b: Int) : Int {
    mutable x = a;
    mutable y = b;
    while (y != 0) {
        let temp = y;
        set y = x % y;
        set x = temp;
    }
    return x;
}

// Função para verificar se um número é primo
function IsPrime(n: Int) : Bool {
    if (n <= 1) {
        return false;
    }
    for i in 2..Floor(Sqrt(IntAsDouble(n))) {
        if (n % i == 0) {
            return false;
        }
    }
    return true;
}

// Mede um array de qubits e converte em um número inteiro
operation MeasureInteger(qubits: Qubit[]) : Int {
    mutable result = 0;
    for i in 0..Length(qubits) - 1 {
        let outcome = M(qubits[i]);
        if (outcome == One) {
            set result = result + (1 <<< i); // Equivalente a 2^i
        }
    }
    return result;
}

// Gera um número pseudoaleatório entre min e max usando medições quânticas
operation CustomRandomInt(min: Int, max: Int) : Int {
    let range = max - min + 1;
    let nQubits = BitSizeI(range); // Define o número de qubits necessário para cobrir o intervalo
    use qubits = Qubit[nQubits];

    ApplyToEach(H, qubits); // Coloca os qubits em superposição
    let measuredValue = MeasureInteger(qubits);
    ResetAll(qubits);

    return min + (measuredValue % range); // Garante que o número gerado está dentro do intervalo
}

// Inversa da Transformada de Fourier Quântica (QFT^-1)
operation InverseQFT(qubits: Qubit[]) : Unit is Adj + Ctl {
    let n = Length(qubits);
    for i in 0..n - 1 {
        H(qubits[i]);
        for j in 0..i - 1 {
            let angle = -PI() / IntAsDouble(1 <<< (i - j)); // 1 <<< (i - j) é 2^(i-j)
            Controlled R1([qubits[j]], (angle, qubits[i]));
        }
    }
}

// Exponenciação modular eficiente: (a^power) % N
function PowMod(a: Int, power: Int, N: Int) : Int {
    mutable result = 1;
    mutable base = a % N;
    mutable exp = power;

    while (exp > 0) {
        if (exp % 2 == 1) {
            set result = (result * base) % N;
        }
        set base = (base * base) % N;
        set exp = exp / 2;
    }
    return result;
}

// Aplica um valor inteiro a um registro de qubits usando X
operation ApplyXorInPlace(value: Int, qubits: Qubit[]) : Unit is Adj + Ctl {
    for i in 0..Length(qubits) - 1 {
        if ((value / (1 <<< i))) % 2 == 1 { // 1 <<< i é 2^i
            X(qubits[i]);
        }
    }
}

// Exponenciação modular controlada usada no QPE
operation ModularExponentiation(a: Int, power: Int, N: Int, qubits: Qubit[]) : Unit is Adj + Ctl {
    let result = PowMod(a, power, N);
    ApplyXorInPlace(result, qubits);
}

// Estima a fase quântica para encontrar o período r
operation QuantumPhaseEstimation(a: Int, N: Int) : Int {
    let nQubits = BitSizeI(N);
    use qubits = Qubit[nQubits];
    
    ApplyToEach(H, qubits);
    ModularExponentiation(a, 1, N, qubits);
    InverseQFT(qubits);

    let phase = MeasureInteger(qubits);
    ResetAll(qubits);

    return phase;
}

// Algoritmo de Shor para fatoração de N
operation ShorAlgorithm(N: Int) : Int[] {
    mutable factors = [];
    if (IsPrime(N)) {
        set factors += [N];
        return factors;
    }

    mutable a = 0;
    repeat {
        set a = CustomRandomInt(1, N - 1); // Usando CustomRandomInt
    } until (GCD(a, N) == 1);

    let r = QuantumPhaseEstimation(a, N);

    if (r % 2 == 0 and PowMod(a, r / 2, N) != N - 1) {
        let factor1 = GCD(PowMod(a, r / 2, N) - 1, N);
        let factor2 = GCD(PowMod(a, r / 2, N) + 1, N);

        // Adiciona os fatores encontrados à lista
        set factors += ShorAlgorithm(factor1); // Recursão para fator1
        set factors += ShorAlgorithm(factor2); // Recursão para fator2
    } else {
        // Se não encontrar fatores válidos, tenta novamente
        set factors += ShorAlgorithm(N);
    }

    return factors;
}

// Executa o algoritmo de Shor e imprime os fatores
@EntryPoint()
operation RunShorAlgorithm() : Int[] {
    let N = 10;
    Message($"Fatorando {N}...");
    let factors = ShorAlgorithm(N);
    Message($"Fatores encontrados: {factors}");
    return factors;
}
