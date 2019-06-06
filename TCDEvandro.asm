; EVANDRO FERNANDES BARRETO
; 04/06/2019 - UNESP BAURU
; TRABALHO FINAL PARA DISCIPLINA DE MICROCONTROLADORES

;PROPOSTA: UMA ESTUFA PARA APARTAMENTOS
;METODO:   CONTROLAR DE FORMA AUTONOMA A IRRICA��O E ILUMINA��O DO AMBIENTE
;NECESSIDADE: A IDEIA SURGE DA NECESSIDADE DO AUTOR DE PLANTAR EM SUA CASA
;COM POUCOS RECURSO DE ILUMINA��O E TEMPO PARA MOLHAR AS PLANTAS

;MATERIAIS: SER� USADA UM SENSOR DE UMIDADE E UMA LAMPADA 


#include "p16f873a.inc"


CBLOCK  0x20

	TIQUE          ; variavel para incrementa quantas vezes acontece int pelo timer
	SEC			   ; incrementar os segundos
	MIN			   ; incrementar os minutos
	HORA		   ; incrementar as horas
	
	SETTAR_HORARIO ; VARIAVEL USADA PARA SABER SE O USUARIO QUER SETAR HORARIO DE LIGAMENTO DA ILUMINA��O OU NAO

	; VARIAVEIS LIGADAS AO DESLIGAMENTOS DA ILUMINA��O
	DESLIGA_HORA
	DESLIGA_MIN
	DESLIGA_SEC
	
	; VARIAVEIS LIGADAS AO LIGAMENTO DA ILUMINA��O
	LIGA_HORA
	LIGA_MIN
	LIGA_SEC 
   
ENDC ; FIM DO BLOCO DE VARIAVEIS

;===================================================================================;
;============================= INICIO DO PIC  ======================================;
;===================================================================================;
	ORG 0x0
		GOTO INICIO


 ; COSTANTES PARA ACIONAMENTO DE PORTAS

		LED_ILUMINACAO      EQU RB5   ; ACIONAMENTO DA ILUMINA��O NA PORTA RB5  
		LED_IRRIGACAO		EQU RA0	  ; ACIONAMENTO DA IRRIGA��O NA PORTA  RA0
		LED_SINALIZADORA    EQU RA1   ; ACIONAMENTO DA PORTA RA1 QUE INDICA FUNCIONAMENTO DO SISTEMA
		SENSOR_UMIDADE      EQU RB1   ; RB1 = PORTA DO SENSOR DE UMIDADE 
		
;====================================================================;

;===================================================================================;
;================================ AREA DE INTERUP�OES ==============================;
;===================================================================================;
	ORG 0x04    
;TMR0IF = 1 , SIGNIFICA QUE OUVE INTERRUP��O DO FRAG DO TIMER
      BANKSEL   INTCON
      BTFSS     INTCON, TMR0IF         ; TESTA SE A INT FOI DO TIMER
      GOTO   	FIM				       ; SIM: SAI SE N�O FOR
      GOTO      INCREMENTA_TIQUES	   ; N�O: INCREMENTA O TIQUE

;RESETANDO OS FRAGS DO TIMER	
RESETA_FRAGS
       BANKSEL  TMR0
       MOVLW    D'131'				   ; TMR0 = 131 CALCULADO PARA 125 TIQUES 
       MOVWF    TMR0
       BANKSEL  INTCON
       BCF      INTCON,TMR0IF		   ; TMROIF = 0 , ZERA O FRAG DE INTERRUPCAO   
     
FIM	RETFIE   ; DAS INTERRUPCOES 
;=========================================================================================;
;=========================================================================================;
;=========================================================================================;




;=========================================================================================;
;============================== INICIALIZA��O DE VARIAVEIS ===============================;
;=========================================================================================;

INICIO
; ZERANDO AS VARIAVEIS LIGADAS A CONTAGEM DE HORAS,MINUTOS,SEGUNDOS E NUMERO DE INTERRUP�OES
      MOVLW D'0'
      MOVWF MIN      ; MIN  = 0
      
      MOVLW D'0'
      MOVWF SEC      ; SEC  = 0
      
      MOVLW D'0' 
      MOVWF HORA     ; HORA = 0
      
      MOVLW D'0'
      MOVWF TIQUE    ; TIQUE = 0;
      
;=========================================================================================;
;=========================================================================================;
;=========================================================================================;      
      
      
;=========================================================================================;
;============== CONFIGURANDO HORARIO PARA  LIGAR/DESLIGAR A ILUMINA��O ===================;
;=========================================================================================;     
      
;=============================    HORARIO PARA LIGAR   ===================================;

;=======================    SETTAR HORARIO PARA DESLIGA/LIGA =============================;      
; VOC� DESEJA SETTAR O HORARIO DE LIGAMENTO E DESLIGAMENTO DA ILUMINA��O?
	  ; SETTA_HORARIO = 0 , N�O DESEJA SETTAR O HORAIO
	  ; SETTA_HORARIO = 1 , DESEJA SETTAR

	  MOVLW D'1'			; MUDE ESSE VALOR 
      MOVWF SETTAR_HORARIO;
;=========================================================================================;
; AQUI PRECISA SER SETTADO QUE HORAS/MINUTOS/SEGUNDOS O USUARIO QUER QUE A ILUMINA��O
; SEJA ACIONADA

      ; SETANDO A HORA
	  MOVLW D'0'			; AQUI DEVE SER SETTADO PARA O VALOR DESEJADO 
      MOVWF LIGA_HORA       ; LIGA_HORA = "VALOR SETTADO"
	
      ; SETANDO OS MINUTOS
      MOVLW D'0'			; AQUI DEVE SER SETTADO PARA O VALOR DESEJAD
      MOVWF LIGA_MIN	    ; LIGA_MIN = "VALOR SETTADO"
      ; SETANDO OS SEGUNDOS
      MOVLW D'10'			; AQUI DEVE SER SETTADO PARA O VALOR DESEJAD
      MOVWF LIGA_SEC		; LIGA_SEC = "VALOR SETTADO"

;===========================      HORARIO PARA DESLIGAR   ================================;
; AQUI PRECISA SER SETTADO A HORA/MINUTO/SEGUNDOS PARA DESLIGAR A ILUMINA�AO
      MOVLW D'0'			; AQUI DEVE SER SETTADO PARA O VALOR DESEJADO 
      MOVWF DESLIGA_HORA    ; LIGA_HORA = "VALOR SETTADO" 
      
	  MOVLW D'0'			; AQUI DEVE SER SETTADO PARA O VALOR DESEJADO 
      MOVWF DESLIGA_MIN		; LIGA_HORA = "VALOR SETTADO"

      MOVLW D'27'           ; AQUI DEVE SER SETTADO PARA O VALOR DESEJADO 
      MOVWF DESLIGA_SEC		; LIGA_HORA = "VALOR SETTADO"
      
;=========================================================================================;
;=========================================================================================;
;=========================================================================================;



;=========================================================================================;     
;============================== CONFIGURANDO TIMER  ======================================;  
;=========================================================================================;
; BANK 1     
	 BANKSEL OPTION_REG
     MOVLW  b'00000101' 	; CONFIGURANDO BITS  PARA O OPTION_REG                                    
     MOVWF  OPTION_REG		; OPTION_REG = "VALOR EM BIS"
     
     BANKSEL INTCON 
     MOVLW B'10100000' 		; CONFIGURANDO OS BITS PARA INTCON
     MOVWF  INTCON       	; SALVANDO OS VALORES NO REG
; BANK 0
	 BANKSEL TMR0 
     MOVLW D'131'           ; VALOR NECESSARIO PARA DAR 1 SEG               ; 
     MOVWF TMR0           	; SALVANDO O VALOR TMR0
     
  
;=========================================================================================;
;=========================================================================================;
;=========================================================================================;   

;=========================================================================================;
;==================== CONFIGURANDOS AS PORTAS OUTPUT/INPUT ===============================;
;=========================================================================================;


; BANK 1
	BANKSEL TRISA	   			; Setando o Banco do TRISA
	MOVLW 	b'00000000' 		; definindo a PORTA  COMO OUTPUT
	MOVWF 	TRISA	 			; enviando o valor para a  TRISA

;=================== = CONFIGURANDO AS PORTAS B  ========================================;
; NOTA DE CONFIGURA��O, PORTAS EM:
; < PORTA > = 0 , SIGNIFICA OUTPUT
; < PORTA > = 1 , SIGNIFICA INPUT 
	MOVLW 	b'00000111' 		; setando os bits para TRISB
	MOVWF 	TRISB	  			; TRISB = "BITS SETTADOS"
;NESSA CONFIGURA��O:
    ;RB0 = INPUT  ;RB1 = INPUT  ; RB2 = INPUT 
	 
  	
;=========================================================================================;
;=========================================================================================;
;=========================================================================================; 

;=========================================================================================;
;========================= CONFIGURANDO PORTAS SERIAIS ===================================;
;=========================================================================================; 
; BANK 1
	BANKSEL TXSTA  			   ; setando o banco do TXSTA
	MOVLW   B'00100110'		   ; SETTANDO VALORS  < 8 BITS DE TRANSMISSAO,TRANSMISS�O ASSINCRONA  E ALTA VELOCIDADE >
	MOVWF   TXSTA    		   ; JOGA O VALOR PARA TXSTA 
	MOVLW   D'25'   		   ; VALOR PARA CONFIGURAR EM 9600 BPS
	MOVWF   SPBRG    		   ; SPBRG = 25 
; BANK 0
    BANKSEL RCSTA  			   ; SETANDO O BANCO DO TMR0
	MOVLW   B'10010000'        ; SETANDO OS BITS PARA RCSTA < SERIAL HABILITADA , 8 BITS DE TRANSMISS�O , ASSIMCRONO >
	MOVWF   RCSTA              ; CONFIGURANDO A PORTA SERIAL DE RECEP��O  

; TESTAR O ENVIO DE VALOR             

	MOVLW d'66'                ; W = 66 DECIMAL           
	MOVWF TXREG    		       ; ENVIA O VALOR DE W (66)
  ;  CALL  DELAY				   ; ROTINA PARA DELAY
;=========================================================================================;
;=========================================================================================;
;=========================================================================================; 

;=========================================================================================;
;==============================    LIMPA BITS   ==========================================;
;=========================================================================================;
    ;CLRF STATUS           ;LIMPA A MEMORIA DO STATUS
    BCF    PORTB,LED_ILUMINACAO
    BCF    PORTA,LED_IRRIGACAO
    BCF    PORTB,SENSOR_UMIDADE


;=========================================================================================;
;=========================================================================================;
;=========================================================================================;


;=========================================================================================;
;============================= ANALIZA SENSORES E TEMPO ==================================;
;=========================================================================================; 

; ESSA ROTINA ANALIZA O SENSOR DA BOMBA E A HORA PARA LIGAR/DESLIGAR ILUMINA��O 
; UMA VEZ LIGADA UMA FUN��O A OUTRA NAO PODER� SER LIGADA
; NOTA:
; SENSOR_UMIDADE = 1 , TERRA SECA 
; SENSOR_UMIDADE = 0 , TERRA MOLHADA
; BANK 0

ANALIZA
BANKSEL PORTA
	BSF	   PORTA,LED_SINALIZADORA               
	BTFSS  PORTB,SENSOR_UMIDADE    ; RB1 = 1 ? VERIFICA SE O SENSOR DE UMIDADE ESTA ALTO OU BAIXO
	GOTO   DESLIGA_BOMBA	       ; N�O : continua analisar RB1
	GOTO   LIGA_BOMBA              ; SIM : liga bomba de agua





;========================  ROTINA PARA LIGAR A BOMBA DE AGUA =============================;
; ESSA ROTINA SER� ACIONADA QUANDO A TERRA ESTIVER SECA 
LIGA_BOMBA	
; BANK 0
	BANKSEL PORTA	
	BSF     PORTA,LED_IRRIGACAO; RA0 = 1  ACIONANDO A BOMBA DE AGUA
;	CALL    DELAY
	GOTO ANALIZA               ; VOLTA A ANALIZAR O SENSOR E TEMPO
;=========================================================================================;

;======================  ROTINA PARA DESLIGAR A BOMBA DE AGUA ============================;
;; A bomba de agua ser� desligada quando o sensor apontar que a terra est� molhada
DESLIGA_BOMBA
	BANKSEL PORTA	
	BCF     PORTA,LED_IRRIGACAO  ; RA =1  desliga a bomba de agua
;	CALL    DELAY
	GOTO    ANALIZA_TEMPO		 ; ANALIZA O TEMPO
; UMA VEZ GARANTIDO QUE A BOMBA DE AGUA EST� DESLIGADA, O TEMPO � VERIFICADO
;=========================================================================================;
;=========================================================================================;
;=========================================================================================; 



;=========================================================================================;
;=========================== ROTINA DE ANALIZADORA DE TEMPO ==============================;
;=========================================================================================; 

; ESSA ROTINA VERIFICA A HORA ATUAL E COMPARA COM A HORA PARA LIGAR A ILUMINA��O
; SE HORA,MINUTOS E SEGUNDOS  ATUAIS FOREM IGUAIS AO HORARIO SETTADO PARA LIGAR A ILUMINA��O
; UMA VEZ A LUZ LIGADA, O PROGRAMA ENTRA NO BLOCO DE CODIGO QUE ANALIZA O TEMPO PARA DESLIGAR
   
ANALIZA_TEMPO
  MOVF    SETTAR_HORARIO,W        ; W = SETTA_HORARIO
  SUBLW   D'1'                   ; W - 1 , VERIFICA SE O USUARIO DESEJA LIGAR ILUMINA��O OU NAO
  BTFSS   STATUS,Z	             ; Z = 1 ? QUER ACENDER AS LUZES?
  	   GOTO    ANALIZA           ; N�O: VOLTA ANALIZAR OS SENSORES
;SIM: VERIFICA OS HORARIO
; BANK 0	
;BANKSEL   PORTB
;   BCF    PORTB,LED_ILUMINACAO   ; RB5 = 0 , DESLIGA A ILUMINA��O   
   ;CALL DELAY

;=========================  VERIFICA O TEMPO PARA LIGAR  ================================;   
; VERIFICA MINUTOS
VERIFICA_LIGAR_MIN	
   MOVF   MIN,W                  ; W = MIN , JOGA PARA O REG O VALOR ATUAL DOS MINUTOS
   SUBWF  LIGA_MIN,W			 ; LIGA_MIN - W , SUBTRAI DO MINUTO ATUAL O MINUTO PARA LIGAR 
   BTFSS  STATUS,Z               ; SE Z = 1 , SE O VALOR FOR ALTO  LIGA_MIN = MIN OU SEJA MINUTO PARA LIGAR 
        GOTO   ANALIZA	         ; N�O : VOLTA PARA ROTINA ANALIZA

; VERIFICA SEGUNDOS 
VERIFICA_LIGAR_SEC	             ; SIM : VERIFICA A VALIDADE DOS SEGUNDOS AGORA	
   MOVF   SEC,W					 ; W = SEC 
   SUBWF  LIGA_SEC,W			 ; LIGA_SEC - W   
   BTFSS  STATUS,Z   		     ; SE Z = 1 ?
        GOTO ANALIZA			 ; N�O: VOLTA PARA ANALIZAR
	
		

LIGA_LUZ                         
;BANK 0   
   BANKSEL PORTB
   BSF PORTB,LED_ILUMINACAO      ; RB5 = 1 , LIGA A ILUMINA��O
  
;=========================================================================================; 
; UMA VEZ LIGADA A LUZ ENTRA PRA ROTINA QUE FICA VERIFICANDO SE DEU O TMEPO PRA LUZ SER DESLIGADA
; ENQUANTO N�O DER ESSE TEMPO O PROGRAMA FICA NUM LOOP DESSA ROTINA ATE ELA SER DESLIGADA
; RAZ�O:
      ; UMA VEZ LIGADA A LUZ, N�O � INTERESSANTE FAZER LIGAR A BOMBA D'AGUA POIS PODE COZINHAR A PLANTA


;========================== VERIFICA O TEMPO DE DESLIGAMENTO =============================;  
; VERIFICA SE A HORA DE DESLIGAR A ILUMINA��O � IGUAL AO HORARIO ATUAL
; A VERIFICA��O � FEITA EM BLOCOS E ENQUANTO ELA N FOR VALIDA, N�O SAI DOS BLOCOS

VERIFICA_DESLIGAR_HORA
   ; VERIFICA AS HORAS
	MOVF  HORA,W                    ; W = HORA  , VALOR DO REG ASSUME O VALOR DA HORA ATUAL
    SUBWF DESLIGA_HORA,W            ; DESLIGA_HORA  - W 
    BTFSS STATUS,Z                  ; Z=1?  SE OS VALOR FOR BAIXO SIGNIFICA QUE S�O IGUAIS
         GOTO  VERIFICA_DESLIGAR_HORA; N�O: VOLTA A ANALIZAR AS HORAS
 
 VERIFICA_DESLIGAR_MIN
  ; VERIFICA OS MINUTOS
	MOVF  MIN,W                     ; W = MIN , VALOR ASSUME O MINUTO ATUAL
    SUBWF DESLIGA_MIN,W             ; DESLIGA_MIN - W 
    BTFSS STATUS,Z                  ; Z=1?
         GOTO  VERIFICA_DESLIGAR_MIN; N�O: VOLTA A ANALIZAR OS MINUTOS

VERIFICA_DESLIGAR_SEC 
  ; VERIFICA OS SEGUNDOS 	
   MOVF  SEC,W                      ; SEC = W
   SUBWF DESLIGA_SEC,W				; DESLIGA_SECC - W
   BTFSS STATUS,Z					; Z = 1 ?
        GOTO  VERIFICA_DESLIGAR_SEC ; N�O, VOLTA PRO LOOP AT� DAR O SEGUNDOS
BANKSEL  PORTB
   BCF   PORTB,LED_ILUMINACAO       ; SIM: DESLIGA A LUZ
 ; CALL  DELAY                      
   GOTO  ANALIZA                    ; VOLTA PARA ROTINA DE ANALIZA	

 
;=========================================================================================;
;=========================================================================================;
;=========================================================================================; 
 

;=========================================================================================;
;====================== ROTINAS AUXILIARES PARA CONTAGEM DE TEMPO ========================;
;=========================================================================================; 

;ROTINA DE DELAY SIMPLES
DELAY 
     NOP
	 NOP
	 NOP
 	 NOP
	 NOP
	 NOP
RETURN



;==================== INCREMENTA A CONTAGEM DE INTERRUPCOES DO TIMER =====================; 
 INCREMENTA_TIQUES
 	INCF   TIQUE,F                 ; TIQUE = TIQUE +1
	MOVF   TIQUE,W                 ; W = TIQUE
    SUBLW  d'125'                  ; W - 125 , 125 � O VALOR SETTADO PARA 1 SEGUNDO
    BTFSS  STATUS,Z                ; Z = 1: SIGNIFICA QUE OS VALORES S�O IGUAIS E DEU 1 SEGUNDO
	    GOTO   RESETA_FRAGS        ; NAO: RESETA OS FRAGS DO TIMER
	    GOTO   INCREMENTA_SEGUNDOS ; SIM: FORAM 125 TIQUES E SOMA UM SEGUNDO
	 	
INCREMENTA_SEGUNDOS
BANKSEL PORTA
    MOVLW  D'0'                    ; W = 0
    MOVWF  TIQUE                   ; TIQUE = 0 , ZERA O CONTATOR PARA INICAR UMA PROX CONTAGEM
    INCF   SEC,F				   ; SEC   = SEC + 1 , INCREMENTA 1 A VARIAVEL DE SEGUNDO
    MOVF   SEC,W			       ; W     = SEC  
    SUBLW  D'60'                   ; W - 60
    BTFSS  STATUS,Z                ; Z = 1 , SE FOR 1 SIGNIFICA QUE TEMOS 60 SEGUNDOS LOGO INCREMENTAR� OS MINUTOS 
    	 GOTO   RESETA_FRAGS       ; N�O: ZERA O FRAG DO TIMER
   		 GOTO   INCREMENTA_MINUTOS ; SIM: INCREMENTA OS MINUTOS

INCREMENTA_MINUTOS   
   MOVLW   D'0'                    ; w = 0
   MOVWF   SEC					   ; SEC = W ; ZERA OS SEGUNDOS
   INCF    MIN,F				   ; MIN = MIN + 1;
   MOVF    MIN,W                   ; W = MIN 
   SUBLW   D'60'				   ;  W - 60 		
   BTFSS   STATUS,Z                ; Z = 1? SE  MIN =  60 ?
       GOTO  RESETA_FRAGS          ; NAO: ZERA OS FRAGS DO TIMER
	   GOTO  INCREMENTA_HORA       ; SIM: INCREMENTA AS HORAS
 
INCREMENTA_HORA
   INCF    HORA,F                  ; HORA = HORA + 1
   MOVLW   D'0'					   
   MOVWF   MIN                     ; RESETA OS MINUTOS
   MOVF    HORA,W                  ; W = HORA
   SUBLW   D'23'                   ; HORA - 23 
   BTFSS   STATUS,Z  			   ; HORA = 23?
       GOTO  RESETA_FRAGS          ; N�O: RESETA OS FRAGS
ZERA_HORA						   ; SIM: MEIA NOITE						
   MOVLW D'0'
   MOVWF HORA					   ; HORA = 0
   		GOTO    RESETA_FRAGS			
;=========================================================================================;
;=========================================================================================;
;=========================================================================================;    




;=========================================================================================;
;============================ ROTINA PARA RECEP��O SERIAL ================================;
;=========================================================================================;
; ESSAS ROTINAS SERIAM USADAS PARA DESLIGAR E LIGAR A ILUMINA��O VIA SERIAL
; POR�M NO TRABALHO N�O SER� MAIS USADA ESSE METODO
ANALIZA_RECEBIMENTO
	BANKSEL PORTA
   	BCF PORTA, RA1          ;RA1 = 0, INDICA QUE PAROU DE ANALIZAR
	BANKSEL PORTB
	BSF PORTB, RB4 		    ;RA4 = 1, INDICA QUE COME�OU A RECEBER
	BANKSEL PIR1
	BTFSS PIR1,RCIF   		; RECEBEU ALGUM BIT DA SERIAL?
	    GOTO  ANALIZA   		; N�O : VOLTA ANALIZAR OS SENSORES
	    GOTO  LIGA_LUZ		; SIM :	LIGA A LUZ	  
	    
;;======================   ROTINA PARA LIGAR A LUZ SERIAL   ================ =============;

LIGA_LUZ_SERIAL
	 BANKSEL PORTB
	 BCF     PORTB,RB4			; SIM :	SETA O BANCO PARA PORTA	
	       ; LED INDICA LUZ LIGADA 
	 BANKSEL RCREG           ; SETA O BANCO DE PIR1
	 MOVF RCREG,W           ; ZERA O BUFF
;========================================================================================;
; aqui ele ficara ligado at� receber uma nova mensagem para desligar
LOOP
     BANKSEL PIR1           ; SETA O BANCO DE PIR1
	 BTFSS	 PIR1,RCIF
	      GOTO    LOOP   ; RECEBEU ALGUMA COISA? SIM: DESLIGA A LUZ
     ;GOTO    DESLIGA_LUZ_SERIAL          ; N�O : CONTINUA COM A LUZ LIGADA
;=========================================================================================;
;=========================================================================================;
;=========================================================================================;



 END
