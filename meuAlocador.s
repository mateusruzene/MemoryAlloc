.section .data
topoInicialHeap: .quad 0
topoAtualHeap: .quad 0
ultimoBloco: .quad 0

.section .text

.global topoInicialHeap
.global topoAtualHeap
.global ultimoBloco

.global iniciaAlocador
.global finalizaAlocador
.global alocaMem
.global liberaMem
.global imprimeMapa
.global aumentaHeap

iniciaAlocador:
    movq $0, topoInicialHeap # Atribui 0 ao brk original
    movq topoInicialHeap, %rdi # Atribui brk original (0) ao rdi
    movq $12, %rax # syscall de brk
    syscall
    movq %rax, topoAtualHeap  # Atribui o endereço de brk consultado em brk current
    movq %rax, topoInicialHeap # Atribui o endereço de brk consultado em brk original 
    movq %rax, ultimoBloco # Atribui o endereço de brk cao ultimoBloco para saber que a heap está vazia
    ret

finalizaAlocador:
    movq topoInicialHeap, %rdi # Atribui o brk original a rdi
    movq $12, %rax # syscall de brk
    syscall
    movq %rdi, topoAtualHeap # Atribui rdi ao brk original
    ret

alocaMem:
    # Tamanho de alocacao solicitado esta em rdi
    movq topoInicialHeap, %r8 # Armazena o valor original de brk em r8
    movq topoAtualHeap, %r9 # Armazena o valor atual de brk em r9
    movq %rdi, %r10 # Salva o rdi(argumento)
    cmpq %r8, %r9 # Se current == brk ja estamos em um bloco vazio
    je alocaBloco 

    movq %r8, %r11 # Armazena o valor original de brk em r11
    movq $0, %r14 # r14 sera responsavel por guardar o endereco onde o bloco sera alocado
    movq $0, %r15 # r15 sera responsavel por guardar o tamanho

.finding:
    cmpq $0, (%r11) # Verifica se o bloco e desocupado
    jne .proxBloco

    cmpq 8(%r11), %rdi # Verifica se o bloco atual é maior ou igual o tamanho solicitado
    jg .proxBloco

    cmpq $0, %r15 # Verifica se o bloco atual é o primeiro
    je .aposEncontrar

    cmpq 8(%r11), %r15 # Verifica se o bloco atual é menor do que o maior bloco encontrado
    jl .proxBloco

.aposEncontrar:
    movq 8(%r11), %r15 # Salva o tamanho do bloco em r15
    movq %r11, %r14 # Salva o endereco do bloco em r14 
    jmp .proxBloco

.realocaBloco:
    movq $1, (%r14) # Indica que o bloco agora esta ocupado
    
    movq %r15, %r12 # r12 recebe o tamanho do bloco atual
    subq %r10, %r12 # diminui o rdi do tamanho
    cmpq $17, %r12 # Vericia se existe espaco para realizar separacao
    jge .separacao

    addq $16, %r14 # Avanca o tamanho do cabecalho
    movq %r14, %rax # Retorna o endereco atual
    ret

alocaBloco:
    movq ultimoBloco, %r9 # Armazena o valor atual de brk em r9
    addq $16, %r9 # Endereco a ser retornado
    movq %r9, %r12 # salva o endereco
    addq %rdi, %r9 # Adiciona o tamanho do bloco solicitado na posicao pos tags

    # Verifica espaço na heap
    movq topoAtualHeap, %r15 # Carrega o topo atual da heap
    subq ultimoBloco, %r15 # Calcula o espaço livre após o último bloco
    cmpq %r9, %r15 # Verifica se cabe no espaço livre
    jl aumentaHeap # Se não couber, pula para aumentar a heap

.continuaAlocacao:
    movq ultimoBloco, %r8 # Endereco do novo bloco
    movq $1, (%r8) # current brk recebe 1
    movq %r10, 8(%r8) # currentbrk + 8 recebe o tamanho solicitado
    movq %r9, ultimoBloco # novo current brk apos o novo bloco

    movq %r12, %rax # retornar endereco do novo bloco
    ret

.proxBloco:
    addq 8(%r11), %r11 # Adiciona qual for o tamanho do bloco ocupado no endereco que estamos (vai ate o fim do bloco - 16)
    addq $16, %r11  # Pula os 16 bits restantes

    cmpq ultimoBloco, %r11 # Verifica se passamos o último bloco
    jle .finding           # Se ainda não passamos, continua procurando

    cmpq $0, %r14 # se r14 == 0, ou seja, não encontrou nenhum bloco, podemos alocar um bloco
    je alocaBloco

    jmp .realocaBloco

.separacao:
    movq %r10, 8(%r14) # Demarca o espaco do primeiro bloco
    addq $16, %r14 # Espaco das tags
    movq %r14, %r13 # Salva o endereco do primeiro bloco

    addq %r10, %r14 # r14 = r14 + o tamanho requerido
    movq $0, (%r14) # demarca o bit para 0

    subq $16, %r12 # Corrige a posicao de r12
    movq %r12, 8(%r14) # Insere r12 em r14+8

    movq %r13, %rax
    ret

aumentaHeap:
    # %r9 <= %r15 + i * 4096
    movq $1, %r14 # i do loop
    movq %r15, %r13 # soma dos valores
.loop:
    addq $4096, %r13 
    cmpq %r13, %r9 # Compara se o valor pedido é maior que o multiplo de 4096 para aumentar a heap
    jg .loop

    subq %r15, %r13 # remove a diferença do espaço vazio
    movq %r13, %rdi # passa o valor que vai ser adicionado no brk
    movq $12, %rax # Novo valor de brk
    syscall

    jmp .continuaAlocacao 

liberaMem:
    movq topoInicialHeap, %r8 # Armazena o valor original de brk em rbx
    movq topoAtualHeap, %r9 # Armazena o valor atual de brk em rcx
    cmpq %rdi, %r8 
    jg .alloc_fail
    cmpq %rdi, %r9
    jl .alloc_fail
    movq $0, -16(%rdi) # Define o bit de marcacao como livre
    ret

.alloc_fail:
    movq $0, %rax
    ret

imprimeMapa:
    push %rbp                # Salva o ponteiro base
    movq %rsp, %rbp          # Configura o ponteiro base
    
    movq topoInicialHeap, %r8   # Carrega o início da heap em r8
    movq topoAtualHeap, %r9     # Carrega o topo atual da heap em r9

.imprimeBloco:
    cmpq %r8, %r9            # Verifica se atingimos o topo da heap
    jge .fimImpressao        # Se sim, termina

    # Imprime cabeçalho gerencial ("#")
    movq $16, %rcx           # Cabeçalho tem 16 bytes
    movb $'#', %al           # Prepara caractere "#"
.gerencialLoop:
    call imprimeChar         # Chama procedimento para imprimir caractere
    addq $1, %r8             # Avança para o próximo byte
    loop .gerencialLoop      # Continua até imprimir todos os 16 bytes

    # Verifica se o bloco está livre ou ocupado
    movq (%r8), %rax         # Lê o status do bloco
    cmpq $0, %rax            # Verifica se o bloco está livre (0)
    je .imprimeLivre         # Se livre, imprime "-"
    jmp .imprimeOcupado      # Se ocupado, imprime "+"

.imprimeLivre:
    movb $'-', %al           # Prepara caractere "-"
    jmp .imprimeConteudo

.imprimeOcupado:
    movb $'+', %al           # Prepara caractere "+"

.imprimeConteudo:
    movq 8(%r8), %rcx        # Lê o tamanho do bloco (em bytes)
    addq $16, %r8            # Pula o cabeçalho
.conteudoLoop:
    call imprimeChar         # Imprime o caractere correspondente
    addq $1, %r8             # Avança para o próximo byte
    loop .conteudoLoop       # Continua até o final do bloco

    jmp .imprimeBloco        # Vai para o próximo bloco

.fimImpressao:
    call imprimeNovaLinha    # Imprime uma nova linha para organização
    pop %rbp                 # Restaura o ponteiro base
    ret                      # Retorna

imprimeChar:
    # rdi deve conter o caractere a ser impresso
    movq $1, %rdi            # File descriptor (stdout)
    movq %rsp, %rsi          # Endereço do buffer
    movb %al, (%rsi)         # Armazena o caractere em %al no buffer
    movq $1, %rdx            # Tamanho do caractere (1 byte)
    movq $1, %rax            # syscall write
    syscall
    ret

imprimeNovaLinha:
    movb $'\n', %al          # Prepara caractere de nova linha (usando movb para 8 bits)
    call imprimeChar         # Chama procedimento para imprimir
    ret
