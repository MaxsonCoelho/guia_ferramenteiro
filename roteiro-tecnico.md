ROTEIRO TÉCNICO – PAQUÍMETRO DIGITAL DIDÁTICO (MM / POLEGADA)
1. OBJETIVO DO PROJETO
Desenvolver um paquímetro digital interativo, com funcionamento realista, para uso didático, permitindo:
	•	Interação do professor e alunos
	•	Simulação de medições reais
	•	Treinamento de leitura metrológica
	•	Alternância entre mm e polegadas
	•	Controle de aproximação, erro e resolução

2. ESPECIFICAÇÕES METROLÓGICAS BÁSICAS
2.1 Sistema Métrico (Milímetro)
	•	Unidade: mm
	•	Resolução (aproximação): 0,02 mm
	•	Escala principal: 1 mm por divisão
	•	Nônio: 50 divisões = 49 mm 
                       Cada divisão = 0,02 mm
2.2 Sistema Imperial (Polegada)
	•	Unidade: polegada (″)
	•	Resolução: 0,001"
	•	Escala principal:  0,025" (1/40")
	•	Nônio: 25 divisões = 0,024"
                       Cada divisão = 0,001"

3. COMPONENTES DO PAQUÍMETRO (MODELO LÓGICO)
3.1 Componentes Físicos Simulados
O sistema deve conter, visualmente e logicamente:
	•	Bico externo (medição externa)
	•	Bico interno (medição interna)
	•	Haste de profundidade
	•	Escala fixa (corpo)
	•	Escala móvel (cursor)
	•	Display digital
	•	Botões virtuais

4. BOTÕES E FUNÇÕES DIGITAIS
4.1 Botões Obrigatórios
Botão
Função
ON / OFF
Liga e desliga o instrumento
mm / inch
Alterna unidade
ZERO
Zera em qualquer posição
HOLD
Congela leitura
RESET (opcional didático)
Retorna ao zero mecânico

5. LÓGICA DE FUNCIONAMENTO DO PAQUÍMETRO
5.1 Variáveis Principais
posição_cursor (float)
unidade_atual (mm / inch)
resolução (0,02 mm ou 0,001")
leitura_real
leitura_display
modo_hold (boolean)
zero_offset

5.2 Movimento do Cursor
	•	O cursor deve se mover de forma contínua
	•	O deslocamento é feito por:
	•	Mouse
	•	Touch
	•	Teclas (±)
	•	Cada incremento mínimo deve respeitar:
	•	0,02 mm
	•	0,001"

6. CÁLCULO DA LEITURA – SISTEMA MÉTRICO
6.1 Fórmula Geral
Leitura (mm)=Escala principal+(Divisão do nônio×0,02) 
6.2 Lógica de Cálculo
	•	Identificar o último mm inteiro antes do zero do nônio
	•	Identificar qual traço do nônio coincide
	•	Multiplicar pelo valor do nônio (0,02 mm)
	•	Somar

6.3 Exemplo
	•	Escala principal: 24 mm
	•	Nônio coincidindo na divisão 17
           24+(17×0,02)=24,34 mm 

7. CÁLCULO DA LEITURA – POLEGADA
7.1 Fórmula Geral
Leitura (inch)=Escala principal+(Divisão do nônio×0,001) 

7.2 Exemplo
	•	Escala principal: 1.250"
	•	Nônio: divisão 7
          1.250+(7×0,001)=1.257"    

8. COMPORTAMENTO DO ZERO (FUNÇÃO ZERO)
8.1 Zero Mecânico
	•	Cursor totalmente fechado
	•	Leitura = 0,00 mm / 0.000"

8.2 Zero Relativo
	•	Usuário pressiona ZERO em qualquer posição
	•	Sistema cria um offset
leitura_corrigida = leitura_real - zero_offset

9. MODO HOLD
	•	Congela a leitura
	•	Cursor pode se mover visualmente
	•	Display não altera até HOLD ser desativado

10. ERROS DIDÁTICOS (OPCIONAL, RECOMENDADO)
10.1 Tipos de Erro Simuláveis
	•	Erro de paralaxe (modo leitura manual)
	•	Erro de pressão excessiva
	•	Erro de sujeira entre bicos
	•	Erro de zeragem

10.2 Ativação
	•	Ativado pelo professor
	•	Percentual ou valor fixo (ex: +0,04 mm)

11. MODOS DE MEDIÇÃO
11.1 Medição Externa
	•	Usa bicos externos
	•	Curso limitado

11.2 Medição Interna
	•	Usa bicos superiores
	•	Correção automática de offset interno

11.3 Profundidade
	•	Usa haste
	•	Leitura direta

12. INTERAÇÃO DIDÁTICA
12.1 Para Alunos
	•	Ler valor manualmente
	•	Conferir no display
	•	Exercícios com resposta certa/errada
	•	Feedback imediato

12.2 Para Professor
	•	Criar exercícios
	•	Bloquear display
	•	Avaliar leitura manual
	•	Registrar tentativas

13. REQUISITOS VISUAIS
	•	Escalas idênticas às reais
	•	Nônio com alinhamento preciso
	•	Zoom da escala
	•	Destaque da linha coincidente
	•	Animação suave

14. PRECISÃO E ARREDONDAMENTO
14.1 Regras
	•	Nunca exibir valores fora da resolução
	•	Sempre múltiplos de:
	•	0,02 mm
	•	0,001"

14.2 Exemplo
❌ 12,341 mm✅ 12,34 mm

15. VALIDAÇÃO FINAL
Checklist:
	•	Alternância mm / inch correta
	•	ZERO funcional
	•	HOLD funcional
	•	Resolução respeitada
	•	Cursor limitado mecanicamente
	•	Leitura consistente manual x digital

16. TECNOLOGIAS SUGERIDAS (OPCIONAL)
	•	Front-end: HTML5 / Canvas / SVG
	•	Lógica: JavaScript / Python
	•	Integração: PowerPoint, Web ou App