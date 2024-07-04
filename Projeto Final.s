# IAC 2023/2024 k-means
# 
# Grupo: 26
# Campus: Alameda
#
# Autores:
# n_aluno 111407, nome Eric Arnou
# n_aluno 109555, nome Miguel Costa
# n_aluno 110386, nome Rodrigo Vintem
#
# Tecnico/ULisboa


# ALGUMA INFORMACAO ADICIONAL PARA CADA GRUPO:
# - A "LED matrix" deve ter um tamanho de 32 x 32
# - O input e' definido na seccao .data. 
# - Abaixo propomos alguns inputs possiveis. Para usar um dos inputs propostos, basta descomentar 
#   esse e comentar os restantes.
# - Encorajamos cada grupo a inventar e experimentar outros inputs.
# - Os vetores points e centroids estao na forma x0, y0, x1, y1, ...

# Variaveis em memoria
.data

comentario:  .string "Clusters inicializados \n"
comentario1: .string "Centroids inicializados aleatoriamente\n"
comentario2: .string "Executado cleanScreen\n"
comentario3: .string "Executado printClusters\n"
comentario4: .string "Executado calculateCentroids\n"
comentario5: .string "Executado printCentroids\n"
comentario6: .string "Coordenada centroid: ("
comentariovirgula: .string ","
comentario7: .string ")\n"
comentario8: .string "Fim de iteração\n\n"

#Input A - linha inclinada
#n_points:    .word 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8

#Input B - Cruz
#n_points:    .word 5
#points:     .word 4,2, 5,1, 5,2, 5,3 6,2

#Input C
#n_points:    .word 23
#points: .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
n_points:    .word 30
points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10

# Valores de centroids e k a usar na 1a parte do projeto:
#centroids:   .word 0,0
#k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
centroids:   .word 0,0,0,0,0,0,0,0,0,0
k:           .word 3
L:           .word 5

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
clusters: .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff,0xff69b4,0xffa500  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff


# Codigo
 
.text
    jal mainKMeans
    
    # Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall


### printPoint
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja' e' fornecida pelos docentes
# E' uma funcao auxiliar que deve ser chamada pelas funcoes seguintes que pintam a LED matrix.
# Argumentos:
# a0: x
# a1: y
# a2: cor

printPoint:
    li a3, LED_MATRIX_0_HEIGHT
    sub a1, a3, a1
    addi a1, a1, -1
    li a3, LED_MATRIX_0_WIDTH
    mul a3, a3, a1
    add a3, a3, a0
    slli a3, a3, 2
    li a0, LED_MATRIX_0_BASE
    add a3, a3, a0 
    sw a2, 0(a3)
    jr ra
    
### cleanScreen
# Limpa todos os pontos do ecrã
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    li t2, LED_MATRIX_0_WIDTH     # t2 = nº colunas
    li t3, LED_MATRIX_0_HEIGHT    # t3 = nº linhas
    li a2, white                  # a2 = cor branca
    li t0, 0                      # Inicializa o x em t0
    mv t1, t3                     # Inicializa o y em t1
    
    # Adiciona um frame no stack para armazenar o ra de cleanScreen
    addi sp, sp, -4 
    sw ra, 0(sp)
        
loop_linha:
    addi t1, t1, -1               # Decrementa y
    addi t0, x0, 0                # Redefine x para 0
    bge t1, x0, loop_coluna       # Se o y >= 0, vai percorrer essa linha
    j retorno                     # Se o y < 0, termina a função
    
loop_coluna:
    mv a0,t0                      # a0 = t0 = x
    mv a1,t1                      # a1 = t1 = y
    jal ra, printPoint            # Chama printPoint para pintar o ponto atual a branco
    addi t0, t0, 1                # Incrementa x
    blt t0, t2, loop_coluna       # Se x < nºcolunas, continua a percorrer a linha
    j loop_linha                  # Se não for, volta ao loop_linha para passar a outra coluna

retorno:
    # Recupera o ra da primeira chamada e retorna
    lw ra, 0(sp)
    addi sp,sp,4
    jr ra

### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    # Adiciona um frame no stack para armazenar o ra de printClusters
    addi sp, sp, -4 
    sw ra, 0(sp)
    
    la t0, points         # t0 = endereço para o conjunto de pontos
    la t1, clusters       # t1 = endereço para o vetor clusters
    lw t2, n_points       # t2 = nº total de pontos
    li t3, 0              # t3 = contador
    
loop_printClusters:
    lw a0, 0(t0)          # a0 = x
    lw a1, 4(t0)          # a1 = y
    
    lw t4, 0(t1)          # t4 = índice do ponto atual
    la t5, colors         # t5 = array das cores
    slli t4, t4, 2        # t4 *= 4 (calcular o deslocamento para a cor)
    add t5, t5, t4        # t5 = endereço da cor apropriada
    lw a2, 0(t5)          # a2 = carregar a cor do ponto
    jal printPoint        # Chama printPoint para pintar o ponto atual
    
    addi t0, t0, 8        # Passa para o próximo ponto
    addi t1, t1, 4        # Passa para o próximo índice
    addi t3, t3, 1        # contador++
    
    blt t3, t2, loop_printClusters # Se contador < n_points, continua
        
    # Se contador >= n_points, recupera o endereço de retorno e retorna
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    # Adiciona um frame no stack para armazenar o ra de printClusters
    addi sp, sp, -4 
    sw ra, 0(sp)
    
    la t2, centroids             # t2 = endereco para o conjunto de centroids
    lw t3, k                     # t3 = número de centroids
    li t4, 0                     # Inicializa o contador
    li a2, black                 # a2 = cor preta
    
loop_printCentroids:
    lw t0, 0(t2)                 # t0 = x do centroide
    lw t1, 4(t2)                 # t1 = y do centroide
    
    # Print das coordenadas do centroide na forma (x,y)
    la a0, comentario6           
    addi a7, zero, 4    
    ecall
    addi a7,zero,1
    add a0,x0,t0
    ecall
    la a0, comentariovirgula
    addi a7,zero,4
    ecall
    addi a7,zero,1
    add a0,x0,t1    
    ecall
    la a0, comentario7
    addi a7,zero,4
    ecall
    
    add a0, x0, t0                    # a0 = t0 = x
    add a1, x0, t1                    # a1 = t1 = y    
    jal printPoint                    # Chama printPoint para pintar o ponto atual
    
    addi t4, t4, 1                    # Incrementa o contador
    addi t2, t2, 8                    # Passa para o próximo centroid
    blt t4, t3, loop_printCentroids   # contador < k, continua
    
    # Se contador >= n_points, recupera o endereço de retorno e retorna
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
    # Adiciona um frame no stack para armazenar o t0 e t1
    addi sp,sp,-8
    sw t0,0(sp)
    sw t1,4(sp)
    
    sub t0, a0, a2         # t0 = x0 - x1
    sub t1, a1, a3         # t1 = y0 - y1

    # Calcular o valor absoluto de t0
    bgez t0, posX          # se t0 >= 0, vai para posX
    sub t0,zero,t0         # t0 = -t0 (se t0 for negativo)
posX:
    # Calcular valor absoluto de t1
    bgez t1, posY          # se t1 >= 0, vai para posY
    sub t1,zero,t1         # t1 = -t1 (se t1 for negativo)
posY:
    add a0, t0, t1         # a0 = abs(x0 - x1) + abs(y0 - y1)
    
    # Recupera os valores de t0 e t1 e retorna
    lw t0,0(sp)
    lw t1,4(sp)
    addi sp,sp,8
    jr ra

### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    # Guarda os registos anteriores (ra,t0,t1,t2,t3)
    addi sp, sp, -20 
    sw ra, 16(sp)               
    sw t0, 12(sp)            
    sw t1, 8(sp)             
    sw t2, 4(sp)             
    sw t3, 0(sp)             
    
    la t0, centroids             # t0 = endereço para o vetor dos centroids
    lw t1, k                     # t1 = k
    li t2, 0                     # t2 = contador
    li t3, -1                    # t3 = variável para o índice do centróide mais próximo
    li t4, 0x7FFFFFFF            # t4 = variável para a distância mais curta (inicializada muito grande)
    mv t5,a0                     # t5 = x do ponto
    mv t6,a1                     # t6 = y do ponto

nearestLoop:
    bge t2,t1,endNearestLoop     # Se contador >= k, termina
    lw a2,0(t0)                  # a2 = x do centróide atual
    lw a3,4(t0)                  # a3 = y do centróide atual
 
    jal manhattanDistance        # Calcula a distância do ponto ao centróide atual
    
    blt a0,t4,updateNear         # Se distância atual < t4, t4 vai passar a distância atual
    mv a0,t5                     # a0 = x do ponto 
    mv a1,t6                     # a1 = y do ponto
    addi t2,t2,1                 # contador++
    addi t0,t0,8                 # Passa ao próximo centróide
    j nearestLoop
    
updateNear:
    mv t4,a0                     # Atualiza a distância mais curta
    mv t3,t2                     # Atualiza o índice do centróide mais próximo
    mv a0,t5                     # a0 = x do ponto 
    mv a1,t6                     # a1 = y do ponto
    addi t2,t2,1                 # contador++
    addi t0,t0,8                 # Passa ao próximo centróide
    j nearestLoop

endNearestLoop:
    mv a0,t3                     # Coloca o índice do centróide mais próximo em a0 

    # Restaura os registos guardados e retorna
    lw ra, 16(sp)         
    lw t0, 12(sp)             
    lw t1, 8(sp)            
    lw t2, 4(sp)             
    lw t3, 0(sp)             
    addi sp, sp, 20 

    jr ra

### random_point
# Cria 1 ponto aleatório
# Usa a supported system call: Time_msec, para obeter o tempo do relogio
# Realiza o MOD entre o valor obtido no relógio e o número de pontos do input. (n_points)
# Multiplica o valor do MOD por 8 para obter as coordenadas de um ponto pertencente ao vetor points   
# Argumentos: nenhum
# Retorno:
# a0,a1 = x,y

random_point:
    # Guarda os registos anteriores (ra,t0,t1)
    addi sp, sp, -12 
    sw ra, 8(sp)             
    sw t0, 4(sp)            
    sw t1, 0(sp) 

    # Obtém o tempo em milissegundos
    li a7, 30                    # Carrega o número da função Time_msec (30) no registro a7
    ecall                        # Chama a função Time_msec
    mv t0, a0                    # Move o valor retornado (tempo em milissegundos) para t0

    # Calcula t0 % n_points
    lw t1,n_points               # t1 = n_points
    rem t0, t0, t1               # t0 = t0 % t1

    # Calcula o valor absoluto e coloca em a0
    bltz t0, tornaPositivo1
    mv a0, t0                    # Move o valor de t0 para a0
    j continua1

tornaPositivo1:
    neg t0, t0                   # t0 = -t0 , se t0 < 0
    mv a0, t0                    # Move o valor de t0 para a0

continua1:
    slli a0,a0,3                 # Calcula o desvio em bytes (a0 * 8)
    la t2,points                 # t2 = endereço do conjunto de pontos
    add t2,t2,a0                 # Ajusta o endereço com o desvio de a0
    lw a0,0(t2)                  # Carrega o x do ponto que está nesse desvio
    lw a1,4(t2)                  # Carrega o y do ponto que está nesse desvio
    
continua2:
    # Restaura registos guardados e retorna
    lw ra, 8(sp) 
    lw t0, 4(sp)      
    lw t1, 0(sp)         
    addi sp, sp, 12
    
    jr ra 
 
### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Para calcular, calcula o centroid de cada cluster individual (ponto médio)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    # Adiciona um frame no stack para armazenar o ra de calculateCentroids
    addi sp, sp, -4 
    sw ra, 0(sp)
    
    la t0, points              # t0 = Endereço para o conjunto dos pontos
    lw t1, n_points            # t1 = nº total de pontos
    la t2, centroids           # t2 = endereco para o conjunto de centroids
    la t3, clusters            # t3 = endereço para o array dos clusters
    lw t4, k                   # t4 = nº total de centroides
    li t5, 0                   # inicializa o contador para comparar com k
    li t6, 0                   # inicializa contador para comparar com nº total de pontos
    li s3,0                    # acumulador de x
    li s4,0                    # acumulador de y
    li s5,0                    # contador de pontos cluster
    
loopcalculateCentroids:
    bge t5,t4,fim              # se t5 >= t4, todos os centroides já foram vistos, acaba
    bge t6,t1,reseta           # se t6 >= t1, todos os pontos já foram vistos, passa ao próximo centroide
    
    lw s0, 0(t3)               # s0 = indice do ponto atual
    beq s0,t5,acumula          # se o indice do ponto atual for igual ao k atual, acumula o x e o y
 
    # Caso o indice não seja igual, passa ao proximo ponto
    addi t0,t0,8               # Passa ao próximo ponto
    addi t3,t3,4               # Passa ao próximo índice do cluster
    addi t6,t6,1               # Contador de pontos ++
    j loopcalculateCentroids

acumula:
    lw s1,0(t0)                # s1 = x
    lw s2,4(t0)                # s2 = y
    add s3,s3,s1               # s3 += s1 (acumula x)
    add s4,s4,s2               # s4 += s2 (acumula y)
    addi s5,s5,1               # Contador de pontos acumulados ++
    
    # Passa ao próximo ponto
    addi t0,t0,8               # Passa ao próximo ponto no vetor points
    addi t3,t3,4               # Passa ao próximo ponto no vetor clusters
    addi t6,t6,1               # Contador de pontos ++
    j loopcalculateCentroids
    
reseta:
    beqz s5,vazio              # Se esse centroide não tiver pontos mantém-o no mesmo local
    div s3,s3,s5               # s3 = acumulador x / contador de pontos acumulados
    div s4,s4,s5               # s4 = acumulador y / contador de pontos acumulados
    sw s3, 0(t2)               # X do centroide = s3
    sw s4, 4(t2)               # Y do centroide = s4
    
    li s3,0                    # Reseta o acumulador de x
    li s4,0                    # Reseta o acumulador de y
    li s5,0                    # Reseta o contador de pontos acumulados
    li t6,0                    # Reseta o contador de pontos vistos
 
    addi t2,t2,8               # Passa ao próximo centróide
    addi t5,t5,1               # Passa ao próximo k
    
    # Volta ao inicio dos vetores pontos e clusters
    la t0,points
    la t3,clusters
    
    j loopcalculateCentroids
    
vazio:
    li t6,0                    # Reseta o contador de pontos vistos
    addi t2,t2,8               # Passa ao próximo centróide
    addi t5,t5,1               # Passa ao próximo k
    
    # Volta ao inicio dos vetores pontos e clusters
    la t0,points
    la t3,clusters
    
    j loopcalculateCentroids
    
fim: 
    # Recupera o ra da primeira chamada e retorna
    lw ra,0(sp)
    addi sp,sp,4
    jr ra

### initializeCentroids
# Cria pseudo-aleatoriamente k centroids mediante os segundos atuais.
# Argumentos: nenhum
# Retorno: nenhum

initializeCentroids:
    # Guarda os registos t0,t1,ra no stack para os preservar
    addi sp, sp, -12
    sw t1,8(sp)
    sw t0,4(sp)
    sw ra, 0(sp)

    la t0, centroids           # t0 = endereço do vetor dos centróides
    lw t1, k                   # t1 = k
    li t3, 0                   # t3 = contador

init_loop:
    bge t3, t1, exit           # Se contador >= k, sair do loop

    # Chama a função random_point para gerar um ponto aleatório
    jal random_point

    # Armazena as coordenadas no vetor centróides
    sw a0, 0(t0)               # Armazena o x
    sw a1, 4(t0)               # Armazena o y

    addi t3, t3, 1             # contador ++
    addi t0,t0,8               # Passa ao próximo centróide

    j init_loop

exit:
    # Recupera os registos preservados e retorna
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    addi sp, sp, 12
    jr ra

### initializeClusters
# Associa a cada ponto o cluster respetivo. 
# No final, cada ponto pertencerá ao cluster cujo centróide está mais próximo desse ponto.
# Argumentos: nenhum
# Retorno: nenhum

initializeClusters:
    # Adiciona um frame no stack para armazenar o ra de initializeClusters
    addi sp,sp,-4
    sw ra,0(sp)
    
    lw t0, n_points              # t0 = n_points
    la t1, points                # t1 = endereço do vetor points
    la t2, clusters              # t2 = endereço do vetor clusters
    li t3, 0                     # t3 = contador

point_loop:
    bge t3, t0, endIniClust      # Se contador >= n_points, acaba o loop

    # Carrega o ponto atual
    lw a0, 0(t1)                 # Carrega o x do ponto em a0
    lw a1, 4(t1)                 # Carrega o y do ponto em a1

    # Chama nearestCluster para encontrar o centróide mais próximo
    jal ra, nearestCluster
    # Guarda o índice do centróide mais próximo no vetor clusters
    sw a0,0(t2)

    addi t3,t3,1               # contador++
    addi t1,t1,8               # Passa ao próximo ponto no vetor points
    addi t2,t2,4               # Passa ao próximo ponto no vetor clusters

    j point_loop
    
endIniClust:
    # Recupera o endereço de retorno e retorna 
    lw ra,0(sp)
    addi sp,sp,4
    jr ra

### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:
    # Adiciona um frame no stack para armazenar o ra de mainkMeans
    addi sp,sp,-4
    sw ra, 0(sp)
    
    lw s11,L                   # s11 = L = nº de iterações
    
    # Limpa a matriz
    jal cleanScreen
    # Print: "Executado cleanScreen"
    la a0,comentario2
    addi a7,zero,4
    ecall
    
    # Inicializa os centroides pseudo-aleatoriamente
    jal initializeCentroids
    # Print: "Centroids inicializados aleatoriamente"
    la a0,comentario1
    addi a7,zero,4
    ecall
    
    # Associa um cluster a cada ponto
    jal initializeClusters
    # Print: "Clusters inicializados"
    la a0,comentario
    addi a7,zero,4
    ecall
    
    # Pinta todos os pontos na matriz nas cores respetivas
    jal printClusters
    # Print: "Executado printClusters"
    la a0,comentario3
    addi a7,zero,4
    ecall
    
    # Pinta todos os centroides na matriz a preto
    jal printCentroids
    # Print: "Executado printCentroids"
    la a0,comentario5
    addi a7,zero,4
    ecall
    
    li s10, 1                  # contador = 1 (iteração inicial)
    
loopKMeans:
    bge s10,s11,endKMeans
    
    # Limpa a matriz
    jal cleanScreen
    # Print: "Executado cleanScreen"
    la a0,comentario2
    addi a7,zero,4
    ecall
    
    # Muda os centroids para o ponto médio de cada cluster
    jal calculateCentroids
    # Print: "Executado calculateCentroids"
    la a0,comentario4
    addi a7,zero,4
    ecall
    
    # Associa um cluster a cada ponto
    jal initializeClusters
    # Print: "Clusters inicializados"
    la a0,comentario
    addi a7,zero,4
    ecall
    
    # Pinta todos os pontos na matriz nas cores respetivas
    jal printClusters
    # Print: "Executado printClusters"
    la a0,comentario3
    addi a7,zero,4
    ecall
    
    # Pinta todos os centroides na matriz a preto
    jal printCentroids
    # Print: "Executado printCentroids"
    la a0,comentario5
    addi a7,zero,4
    ecall
 
    addi s10,s10,1             # contador++
    
    # Print: "Fim de iteração"
    la a0,comentario8
    addi a7,zero,4
    ecall
    
    j loopKMeans
    
endKMeans:
    # Recupera o endereço de retorno e retorna
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra