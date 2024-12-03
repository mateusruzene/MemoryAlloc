### 1) (.5 ponto) Se você pudesse voltar no tempo, o que você (de hoje) recomendaria ao você (do primeiro dia de aula de Software Básico) para minimizar o sofrimento do desenvolvimento deste trabalho?

Faria mais exercícios em assembly para desenvolver mais as práticas da linguagem

### 2 (.5 ponto) O que você recomendaria ao professor da disciplina quando ele se preparar para o próximo semestre remoto a fim de aumentar o grau de absorção do conteúdo da disciplina por parte dos alunos?

Continuar o mesmo método de aula, interação com os alunos ajuda muito na absorção do conteúdo e o material didático é muito bom para o aprendizado em casa após a aula.

### 3 (2 pontos) Explique quais os trechos de código e quais as principais alterações que você fez para que a segunda parte funcionasse, ou indique o motivo de você não ter conseguido terminar alteração. Indique, por exemplo, Quais as linhas de código que você mudou e com qual objetivo

Na aréa de .finding temos uma comparação (cmpq 8(%r11), %r15) com um jmp em seguida (jl .proxBloco) onde verificamos se o bloco atual é menor do que os bloco encontrado, logo para trocar essa condição para encontrar o maior bloco (Worstfit) devemos apenas trocar o jl para jg.
