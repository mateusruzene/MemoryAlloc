 > Mateus Ruzene e Ramon Pelle
#### Seção `.data`

- **topoInicialHeap**: Armazena o endereço inicial da heap.
- **topoAtualHeap**: Armazena o endereço atual do topo da heap.
- **ultimoBloco**: Armazena o endereço do último bloco alocado.
- **strCabecalho**: String usada para imprimir o cabeçalho dos blocos.
- **strOcupado**: String usada para imprimir blocos ocupados.
- **strDesocupado**: String usada para imprimir blocos desocupados.
- **strFim**: String usada para imprimir uma quebra de linha no final do mapa da heap.

#### Seção `.text`

- **topoInicialHeap, topoAtualHeap, ultimoBloco**: Variáveis globais que representam os endereços da heap.
- **iniciaAlocador, finalizaAlocador, alocaMem, liberaMem, imprimeMapa, aumentaHeap**: Funções globais que gerenciam a heap.

### Funções

#### `iniciaAlocador`

- **Funcionalidade**: Inicializa o alocador de memória, configurando os endereços iniciais da heap.
- **Registradores Utilizados**:
    - `%rdi`: Parâmetro da função, recebe `topoInicialHeap`.
    - `%rax`: Usado para armazenar o número do syscall `brk`.
    - `%rax`: Recebe o valor atual de `brk` após o syscall.

#### `finalizaAlocador`

- **Funcionalidade**: Finaliza o alocador de memória, restaurando o estado inicial da heap.
- **Registradores Utilizados**:
    - `%rdi`: Parâmetro da função, recebe `topoInicialHeap`.
    - `%rax`: Usado para armazenar o número do syscall `brk`.

#### `alocaMem`

- **Funcionalidade**: Aloca um bloco de memória na heap.
- **Registradores Utilizados**:
    - `%rdi`: Tamanho de alocação solicitado.
    - `%r8`: Armazena `topoInicialHeap`.
    - `%r9`: Armazena `topoAtualHeap`.
    - `%r10`: Salva o argumento `%rdi`.
    - `%r11`: Usado para armazenar o topo inicial da heap.
    - `%r14`: Guarda o endereço onde o bloco será alocado.
    - `%r15`: Guarda o tamanho do bloco que será alocado.

#### Labels e Blocos de Código

##### `.finding`

- **Funcionalidade**: Percorre a heap para encontrar um bloco desocupado que possa acomodar o tamanho solicitado. Método aplicado: best fit - encontra o menor bloco maior ou igual ao tamanho solicitado.
- **Registradores Utilizados**:
    - `%r11`: Endereço do bloco atual.
    - `%rdi`: Tamanho solicitado.
    - `%r15`: Tamanho do menor bloco encontrado até agora.

##### `.aposEncontrar`

- **Funcionalidade**: Atualiza `%r15` com o tamanho do bloco atual e `%r14` com o endereço do bloco atual.
- **Registradores Utilizados**:
    - `%r11`: Endereço do bloco atual.
    - `%r14`: Endereço do bloco a ser alocado.
    - `%r15`: Tamanho do bloco a ser alocado.

##### `.realocaBloco`

- **Funcionalidade**: Marca o bloco como ocupado e verifica se há espaço para separação.
- **Registradores Utilizados**:
    - `%r14`: Endereço do bloco a ser alocado.
    - `%r15`: Tamanho do bloco a ser alocado.
    - `%r12`: Tamanho do bloco atual menos o tamanho solicitado.
    - `%r10`: Tamanho solicitado.

##### `.separacao`

- **Funcionalidade**: Realiza a separação do bloco se houver espaço suficiente.
- **Registradores Utilizados**:
    - `%r14`: Endereço do bloco a ser alocado.
    - `%r10`: Tamanho solicitado.
    - `%r12`: Tamanho do bloco restante após a separação.
    - `%r13`: Endereço do primeiro bloco após a separação.

##### `.aumentaHeap`

- **Funcionalidade**: Aumenta o tamanho da heap em múltiplos de 4096 bytes.
- **Registradores Utilizados**:
    - `%r15`: Espaço livre na heap.
    - `%r13`: Espaço livre na heap incrementado em 4096 bytes.
    - `%rdi`: Valor a ser adicionado no `brk`.
    - `%rax`: Usado para armazenar o número do syscall `brk`.

##### `.continuaAlocacao`

- **Funcionalidade**: Continua a alocação do bloco após aumentar (ou não) a heap.
- **Registradores Utilizados**:
    - `%r9`: Endereço do novo bloco.
    - `%r12`: Endereço do novo bloco.
    - `%r10`: Tamanho solicitado.
    - `%r8`: Endereço do novo bloco.
    - `%rax`: Endereço do novo bloco a ser retornado.

##### `.proxBloco`

- **Funcionalidade**: Avança para o próximo bloco na heap.
- **Registradores Utilizados**:
    - `%r11`: Endereço do bloco atual.
    - `%r14`: Endereço do bloco a ser alocado.

#### `liberaMem`

- **Funcionalidade**: Libera um bloco de memória na heap.
- **Registradores Utilizados**:
    - `%rdi`: Endereço do bloco a ser liberado.
    - `%r8`: Armazena `topoInicialHeap`.
    - `%r9`: Armazena `ultimoBloco`.

##### `.alloc_fail`

- **Funcionalidade**: Retorna 0 em caso de falha na liberação de memória.
- **Registradores Utilizados**:
    - `%rax`: Retorna 0.

#### `imprimeMapa`

- **Funcionalidade**: Imprime um mapa da memória da região da heap.
- **Registradores Utilizados**:
    - `%r8`: Armazena `topoInicialHeap`.
    - `%r9`: Armazena `topoAtualHeap`.
    - `%r14`: Contador para impressão.
    - `%r15`: Tamanho do bloco atual.
    - `%rdi`: Parâmetro para `printf`.
    - `%rbp`: Usado para manipulação da pilha.
    - `%rsp`: Usado para manipulação da pilha.

##### `.inicioDoBloco`

- **Funcionalidade**: Imprime o cabeçalho do início do bloco.
- **Registradores Utilizados**:
    - `%rdi`: Parâmetro para `printf`.

##### `.continuaImprimir`

- **Funcionalidade**: Continua a imprimir o resto do bloco.
- **Registradores Utilizados**:
    - `%r15`: Tamanho do bloco atual.
    - `%r14`: Contador para impressão.
    - `%r8`: Endereço do bloco atual.

##### `.contunuaProxBloco`

- **Funcionalidade**: Avança para o próximo bloco na heap.
- **Registradores Utilizados**:
    - `%r8`: Endereço do bloco atual.

##### `.imprimeOcupado`

- **Funcionalidade**: Imprime o caractere de bloco ocupado.
- **Registradores Utilizados**:
    - `%rdi`: Parâmetro para `printf`.
    - `%r14`: Contador para impressão.
    - `%r15`: Tamanho do bloco atual.

##### `.imprimeDesocupado`

- **Funcionalidade**: Imprime o caractere de bloco desocupado.
- **Registradores Utilizados**:
    - `%rdi`: Parâmetro para `printf`.
    - `%r14`: Contador para impressão.
    - `%r15`: Tamanho do bloco atual.

##### `.fimMapa`

- **Funcionalidade**: Imprime uma quebra de linha no final da heap.
- **Registradores Utilizados**:
    - `%rdi`: Parâmetro para `printf`.

##### `.fim`

- **Funcionalidade**: Finaliza a função `imprimeMapa`.
- **Registradores Utilizados**:
    - `%rsp`: Usado para manipulação da pilha.
    - `%rbp`: Usado para manipulação da pilha.
