// Software de Controle - Projeto Sensores de Presença Microcontrolado - STM8S003F3P6
// MarGirius Continental Industria de Controles Elétricos
// Principais caracteristicas dos produtos:
//  1- Seleção de tempo: 5 seg, 1 min, 4 min.
//  2- Seleção de sensibilidade: máxima e mínima.
//  3- Ajuste da fotocélula: ligada e desligada.
// Desenvolvedores: Luis Felipe, Izau, Menarin, Elinton.

/***********************************************************************************************************************************
 Inclusão dos arquivos externos para chamada do compilador
***********************************************************************************************************************************/
#include "stm8s.h"
#include "typedef_gpio_sensor_e27.h"
#include "stm8s_flash.h"

extern volatile unsigned int cnt; // Variável está no stm8s_it.c
#define CCR3_Val  ((uint16_t)12)  
#define CCR1_Val  ((uint16_t)16)  


/***********************************************************************************************************************************
 Declaração e Inicialização das Variaveis Globais
***********************************************************************************************************************************/
unsigned int  Ajuste_Fot = 0;     // Utilizada na função VerificaAjusteFotocelula (1- Fotocelula = ON , 2- Fotocelula = OFF
unsigned int tp = 0;              // Utilizada na função VerificaAjusteTempo para contar o tempo selecionado
unsigned int g = 0;               // Utilizada na função Disparo para contagem de looping
unsigned int lumi = 0;            // Utilizada na função VerificaLuminosidade para ver se est? de dia ou de noite (lumi = 0 dia, lumi = 1 noite
unsigned int Escuridade = 0;      // Utilizada na função LerLDR para armazenar a leitura A/D do LDR
unsigned int Lux = 410;           // Ponto de atuação da Fotocélula.
int Piro = 0;                     // Utilizada na função VerificaPiroSensor para armazenar a leitura A/D do pirosensor
int Psup = 0;                     // Pontos de atuação da janela do pirosensor, nivel superior - Variavel de apoio
int Pinf = 0;                     // Pontos de atuação da janela do pirosensor, nivel inferior - Variavel de apoio
unsigned short temp = 0;
unsigned short Sl = 0;
unsigned short AD_Foto = 0;





/******************************************************************************************************************************
	Protótipos das Funções
*****************************************************************************************************************************/
void VerificaPiroSensor(void);					// Função que faz a leitura do A/D ligado a malha do pirosensor
void VerificaAjusteSensibilidade(void);	// Função que faz a leitura da memória e atribui os valores da janela de atuação do pirosensor
void VerificaAjusteTempo(void);					// Função que faz a leitura do potenciometro de Tempo e determina os valores a serem contados
void VerificaAjusteFotocelula(void);		// Função que faz a leitura do A/D ligado ao potenciometro Foto e determina qual a opção escolhida
void VerificaLuminosidade(void);        // Função que determina se está de dia ou de noite
void Disparo(void);								      // Função que analisa o o valor recebido do pirosensor e dispara a carga
void LerLDR(void);
void Delay_500us(int x);
void Inicializa(void);
void Desliga(void);
void Liga(void);

/***************************************************************************************************************************
	Inicialização e configuração da CPU dos Pinos e do Delay
***************************************************************************************************************************/
main(){
		//CPU inicia em 2MHz 
		//CPU foi alterada para trabalhar de 16 MHZ para 2MHz para diminuir o consumo do micro
		//Configuração de sugestão ST
		CLK_HSIPrescalerConfig (CLK_PRESCALER_HSIDIV8);	// Primeiro determina-se o clock como "High Speedy (HS)" o que dá 16MHz e divide-se por 8 (16/8 = 2MHz)

		// Inicialização GPIOs 
		// Parte está definida no typedef
    GPIO_Init(Pino_Rele_conf); 	  					// Inicialização do pino correspondente ao Triac (sáida)
		GPIO_Init(Pino_Zero_conf); 			    			// Inicialização do pino correspondente ao ZeroCrossing (entrada)
		GPIO_Init(Pino_Led_conf); 								// Inicialização do pino correspondente ao Led (saída)
		GPIO_Init(Pino_Teste_conf); 							// Inicialização do pino correspondente ao Teste Rápido (entrada)

		// Inicialização Timer4 - 8 bits
		TIM4_TimeBaseInit(TIM4_PRESCALER_8,124);	// Configuração do Time base, ver no excel
	  TIM4_ClearFlag(TIM4_FLAG_UPDATE); 				// Clear TIM4 update flag 
		TIM4_ITConfig(TIM4_IT_UPDATE, ENABLE);		// Enable update interrupt
		TIM4_Cmd(ENABLE);   											// Habilita TIM4 
		enableInterrupts();                       // Habilita Interrupções
		
		
/******************************************************************************************************************************
 Rotina de configuração da gravação em memória
******************************************************************************************************************************/
		FLASH_SetProgrammingTime(FLASH_PROGRAMTIME_STANDARD); //Espera até que a área de programação da Flash desbloqueada seja setada
		FLASH_Unlock(FLASH_MEMTYPE_PROG);
		/* Wait until Flash Program area unlocked flag is set*/
		while(FLASH_GetFlagStatus(FLASH_FLAG_PUL) == RESET){;} // Flag de segurança para gravação da memória Flash
		/*Unlock flash data eeprom memory */
		FLASH_Unlock(FLASH_MEMTYPE_DATA);
		/* Wait until Data EEPROM area unlocked flag is set*/
		while(FLASH_GetFlagStatus(FLASH_FLAG_DUL) == RESET){;}/**/ //Flag de segurança para gravação na memória EEPROM
  
	
/******************************************************************************************************************************
 Rotina de Estabilização do Produto
******************************************************************************************************************************/

		
		
/******************************************************************************************************************************
 Rotina Principal
******************************************************************************************************************************/
	Rele = 0;
	Inicializa();
	
  while(1){   
		VerificaAjusteTempo();             // Verifica o tempo selecionado e carrega na variavel tp
		VerificaAjusteFotocelula();    		 // Verifica a posição do ajuste da fotocelula e carrega na variável Ajuste_Fot
		VerificaLuminosidade();            // Verifica o nivel da luminosidade e carrega na variável Lumi
		VerificaPiroSensor();
		VerificaAjusteSensibilidade();     // Verifica a posição do ajuste da sensibilidade e carrega na variável Sensibilidade
		
	 if (Ajuste_Fot==2)              { Disparo();} // Fotocélula desligada, dispara a carga independente da luz externa
   if((Ajuste_Fot==1) && (lumi==1)){Disparo();}  // Fotocélula ligada e ambiente escuro, dispara a carga.
		
  }
}

/*********************************************************************************************************************************
	Função VerificaPiroSensor
	Essa função configura o AD do pino3 AIN6 e faz a leitura do pirosensor. 
*********************************************************************************************************************************/
void VerificaPiroSensor(void){// Definição da Função de leitura do Pirosensor
	
	ADC1_ConversionConfig(ADC1_CONVERSIONMODE_CONTINUOUS,ADC1_CHANNEL_6,ADC1_ALIGN_RIGHT);
	ADC1_Cmd(ENABLE);
	ADC1_StartConversion(); // Leitura AD do pirosensor
	
	//for(h=0; h<100; h++){
	  if(ADC1_GetFlagStatus(ADC1_FLAG_EOC)){ Piro = ADC1_GetConversionValue();} // Proteção BUG de conversão AD da ST
	  //while(ADC1_GetFlagStatus(ADC1_FLAG_EOC) == 0){;} // Flag de segurança que aguarda o fim da conversão analógica
		//cnt=1;while(cnt); // Aguarda um tempo de 500us
  //}
	
	return;
}


/*********************************************************************************************************************************
	Função VerificaAjusteSensibilidade
	Essa função configura o AD do pino AIN6 e faz a leitura do potenciometro de ajuste de sensibilidade. 
**********************************************************************************************************************************/
void VerificaAjusteSensibilidade(void){ // Definição da Função de Seleção Sensibilidade em +/- 50us
  ADC1_ConversionConfig(ADC1_CONVERSIONMODE_CONTINUOUS,ADC1_CHANNEL_4,ADC1_ALIGN_RIGHT) ; // Modo de conversão analógico
  ADC1_Cmd(ENABLE); // Habilita o ADC1
  ADC1_StartConversion(); // Inicia a conversão
  // Leitura AD
	
	if(ADC1_GetFlagStatus(ADC1_FLAG_EOC)){ Sl = ADC1_GetConversionValue(); } // Proteção BUG de conversão AD da ST
	//cnt=1;while(cnt); // Aguarda um tempo de 500us
		
	if(Sl<650)               { Pinf = Piro - 50;    Psup = Piro + 50;}  // Sens Máx Atribuição de valores inf e sup da janela do Pirosensor
	if(Sl>=650)              { Pinf = Piro - 250;   Psup = Piro + 250;} // Sens Mín Atribuição de valores inf e sup da janela do Pirosensor 
		
	//cnt = 18; while(cnt);
	return;
}


/*********************************************************************************************************************************
 Função VerificaAjusteTempo
 Essa função configura o AD do pino 2 AIN5 e faz a leitura do potenciometro de ajuste de tempo. 
*********************************************************************************************************************************/
 void VerificaAjusteTempo(void){ // Definição da Função  Leitura de Tempo
  ADC1_ConversionConfig(ADC1_CONVERSIONMODE_CONTINUOUS,ADC1_CHANNEL_3,ADC1_ALIGN_RIGHT);
  ADC1_Cmd(ENABLE);
	nop();
  ADC1_StartConversion(); // Inicia a conversão A/D
	
	if(ADC1_GetFlagStatus(ADC1_FLAG_EOC)){ temp = ADC1_GetConversionValue(); } // Proteção BUG de conversão AD da ST
	//cnt=1; while(cnt);
   

	                                      	
	if (temp<450)                 { tp = 760; } //Posição 3 - 4 minutos
	if ((temp>=450)&&(temp<=750)) { tp = 190; } //Posição 2 - 1 minuto
	if (temp>750)                 { tp = 15; }  //Posição 1 - 5 segundos
	return;
}


/*********************************************************************************************************************************
  Função VerificaAjusteFotocelula
	Essa função configura o AD do pino 19 AIN3 e faz a leitura do potenciometro de ajuste da fotocelula. 
*********************************************************************************************************************************/
void VerificaAjusteFotocelula(void){ // Definição da Função de Seleção Fotocelula em +/- 50us
  ADC1_ConversionConfig(ADC1_CONVERSIONMODE_CONTINUOUS,ADC1_CHANNEL_5,ADC1_ALIGN_RIGHT); // Modo de conversão analógico
  ADC1_Cmd(ENABLE);
  ADC1_StartConversion(); // Inicia a conversão
  // Leitura AD
	if(ADC1_GetFlagStatus(ADC1_FLAG_EOC)){ AD_Foto = ADC1_GetConversionValue(); } // Proteção BUG de conversão AD da ST
	//cnt=1;while(cnt); //Delay de 500us
		
   if (AD_Foto<=650)                    {Ajuste_Fot = 1;} // Posição 3 - Noite, luminosidade minima (-)
	 if (AD_Foto>650)                     {Ajuste_Fot = 2;} // Posição 1 - Fotocélula OFF (DESL)
	
	return;
}	
	
	
/*********************************************************************************************************************************
  Função VerificaLuminosidade
	Essa função faz leitura do LDR e carrega a Variável lumi para valor 1 ou 0
*********************************************************************************************************************************/
void VerificaLuminosidade(void){      // Definição da função luminosidade
  unsigned short a, b, c;             // Atribui zero  para as variaveis a, b, c, Lux


  LerLDR();
    if(Escuridade>=Lux){              // Escuridade é uma variavel que representa a quantidade de lux
    for(a=0; a<50; a++){              // Incremento para verificação da luminosidade durante 50ms
       b++;                           // Incrementa a variavel b
       LerLDR();                      // Leitura do A/D  LDR e carrega na variavel LDR
           if(Escuridade<Lux){break;} // Se a variavel LDR for menor que Lux sai da instrução for e atribui para variavel lumi=0
           Delay_500us(2);            // Tempo de 1ms
    }
    if(b>=49){ lumi = 1;}             // Noite; Se a variavel b atingir valor igual a 50, lumi recebe 1 indicando que esta noite
  }
  if(Escuridade<(Lux-50)){            // Escuridade é uma variavel que representa a quantidade de lux
    for(a=0; a<50; a++){              // Incremento para verificação da luminosidade durante 50ms
       c++;                           // Incrementa a variavel c
           LerLDR();                  // Leitura do A/D  LDR e carrega na variavel LDR
       if(Escuridade>Lux){break;}     // Se a variavel LDR for maior que Lux, sai da instrução for e atribui para variavel lumi=0
       Delay_500us(2);                // Tempo de 1ms
    }
    if(c>=49){ lumi = 0; }            // De dia...
   }
   return;
 }


/*********************************************************************************************************************************
 Função Disparo
 Essa função verifica o tempo selecionado e dispara a carga através do PWM(1) e 
 desligando a carga através do PWM(0), se não houver mais movimento.
*********************************************************************************************************************************/
void Disparo(void){	 //0,2s
	short PiroInicial=0;
	short PiroFinal=0;
	char estado_rele = 0;

	g = 0;

	while(g<tp){
		VerificaPiroSensor();					               // Verifica o valor do AD referente ao Pirosensor e salva na variavel Piro;
		VerificaAjusteTempo();                       // Verifica o tempo selecionado e carrega na variavel tp
		VerificaAjusteSensibilidade();               // Verifica as janelas de atuação do pirosensor
		Delay_500us(1);

		VerificaPiroSensor(); PiroInicial = Piro;    // Desvia para a função para verificar o pirosensor
		Delay_500us(600);                            // Tempo 100ms (Antes Tempo de 150ms)	(antes 200ms)
		VerificaPiroSensor(); PiroFinal = Piro;

		if((PiroInicial<PiroFinal) && (Piro>=Psup)){
			 Liga();							                      // Dispara a carga no "zero" da senoide
   		 estado_rele = 1;
		   g = 0;
		}

		if((PiroInicial>PiroFinal) && (Piro<=Pinf)){
			 Liga();							                      // Dispara a carga no "zero" da senoide
			 estado_rele = 1;
			 g = 0;
		}

		g++;
    }

	if((g>=tp)&&(estado_rele == 1)){
		 g=0;
		 Desliga();                                   // Desliga a carga no "zero" da senoide
		 Delay_500us(2000);                          // Delay de 1 segundo inserido devido ao ruido de disparo do Rele
	}
	return;
}

/*********************************************************************************************************************************
 Função LerLDR 
 
*********************************************************************************************************************************/
void LerLDR(void){           // Definição da função "EsperaZero"
  ADC1_ConversionConfig(ADC1_CONVERSIONMODE_CONTINUOUS,ADC1_CHANNEL_2,ADC1_ALIGN_RIGHT); // Inicialização ADC1 - 8 bits
	ADC1_Cmd(ENABLE);       // Habilita o ADC1
	ADC1_StartConversion(); // Inicia a coversão
	
	if(ADC1_GetFlagStatus(ADC1_FLAG_EOC)){ Escuridade = ADC1_GetConversionValue(); } // Proteção BUG de conversão AD da ST
	//cnt=1; while(cnt); // Delay de 500us 
	return;
}

void Liga(void){                  // Definição da função "EsperaZero"
 int e=0,f=0;
 if(Zero==1){                     // Se a senoide estiver em 1, aguarda ela passar por 0
		  do { Delay_500us(1); }      // Delay de 500us verificando o sinal da senoide
		  while(Zero!= 0);            // Quando for 0, retorna para o disparo da carga
      for(e=0; e<20; e++){        // Conta um tempo de 20ms
	      Delay_500us(2);           // Delay de 1ms.
        if (Zero==1){f++;};       // Durante o periodo de 20ms analisa-se o tempo que a senoide fica em nivel alto(1) e incrementa a variavel f
      }
      if(f<=9){Delay_500us(16);}   // Se o tempo que a senoide ficou em nivel alto for menor que 9ms a rede é 60Hz ent?o aguardo 8ms para ligar a carga,
      else{Delay_500us(9);}       // Se for maior que 9ms a rede é 50Hz entao aguardo 4,5ms para acionar a carga
 }
 else{ 						                // Senão, se a senoide ja estiver em 0, espera ela ir para 1
		  do {Delay_500us(1);}        // Delay de 500us verificando o sinal da senoide
			while(Zero!= 1);            // Quando for 1, espera passar por 0 novamente
			if(Zero==1){                // Se Zero igual a 1 segue a instrução
				do {Delay_500us(1);}      // Delay de 500us verificando o sinal da senoide
		    while(Zero!= 0);          // Quando for 0, retorna para o disparo da carga
				for(e=0; e<20; e++){      // Conta um tempo de 20ms
           Delay_500us(2);        // Delay de 1ms.
           if (Zero==1){f++;};    // Durante o periodo de 20ms analisa-se o tempo que a senoide fica em nivel alto(1) e incrementa a variavel f
        }
        if(f<=9){Delay_500us(16);} // Se o tempo que a senoide ficou em nivel alto for menor que 9ms a rede é 60Hz ent?o aguardo 8ms para ligar a carga,
        else{Delay_500us(9);}     // Se for maior que 9ms a rede é 50Hz ent?o aguardo 4,5ms para acionar a carga
			}
	}
 Rele=1;
 return;
}


void Desliga(void){               // Definição da função "EsperaZero"
 int e=0,f=0;
 if(Zero==1){                     // Se a senoide estiver em 1, aguarda ela passar por 0
      do { Delay_500us(1); }      // Delay de 500us verificando o sinal da sen?ide
      while(Zero!= 0);            // Quando for 0, retorna para o disparo da carga
      for(e=0; e<20; e++){        // Conta um tempo de 20ms
        Delay_500us(2);           // Delay de 1ms.
        if (Zero==1){f++;};       // Durante o periodo de 20ms analisa-se o tempo que a senoide fica em nivel alto(1) e incrementa a variavel f
      }
      if(f<=9){Delay_500us(16);}   // Se o tempo que a senoide ficou em nivel alto for menor que 9ms a rede é 60Hz ent?o aguardo 8ms para ligar a carga,
      else{Delay_500us(9);}       // Se for maior que 9ms a rede é 50Hz ent?o aguardo 4,5ms para acionar a carga
 }
  else{                           // Senão, se a senoide ja estiver em 0, espera ela ir para 1
      do {Delay_500us(1);}        // Delay de 500us verificando o sinal da sen?ide
      while(Zero!= 1);            // Quando for 1, espera passar por 0 novamente
      if(Zero==1){                // Se Zero igual a 1 segue a instrução
        do {Delay_500us(1);}      // Delay de 500us verificando o sinal da senoide
        while(Zero!= 0);          // Quando for 0, retorna para o disparo da carga
        for(e=0; e<20; e++){      // Conta um tempo de 20ms
           Delay_500us(2);        // Delay de 1ms.
           if (Zero==1){f++;};    // Durante o periodo de 20ms analisa-se o tempo que a senoide fica em nivel alto(1) e incrementa a variavel f
        }
        if(f<=9){Delay_500us(16);} // Se o tempo que a senoide ficou em nivel alto for menor que 9ms a rede é 60Hz ent?o aguardo 8ms para ligar a carga,
        else{Delay_500us(9);}     // Se for maior que 9ms a rede é 50Hz então aguardo 4,5ms para acionar a carga
      }
  }
 Rele=0;
 return;
}

void Inicializa(void){
	  Delay_500us(2000);      // Tempo de inicialização para estabilizar o sinal do Pirosensor
		Liga();
		Delay_500us(16000);
		Desliga();
		Delay_500us(10000);
    return;
}

void Delay_500us(int x){
	int y=0,z=0,l=0;

	if(x<256){cnt=x; while(cnt);}
	else{ do{x=x-255;
	         z++;
	        }while(x>=255);
	      for(l=z; l>0; l--){
	    	 cnt=255;while(cnt);
	      }
	      cnt=x; while(cnt);
	}
 return;
}
