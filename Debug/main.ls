   1                     ; C Compiler for STM8 (COSMIC Software)
   2                     ; Parser V4.11.13 - 05 Feb 2019
   3                     ; Generator (Limited) V4.4.9 - 06 Feb 2019
2991                     	bsct
2992  0000               _Ajuste_Fot:
2993  0000 0000          	dc.w	0
2994  0002               _tp:
2995  0002 0000          	dc.w	0
2996  0004               _g:
2997  0004 0000          	dc.w	0
2998  0006               _lumi:
2999  0006 0000          	dc.w	0
3000  0008               _Escuridade:
3001  0008 0000          	dc.w	0
3002  000a               _Lux:
3003  000a 019a          	dc.w	410
3004  000c               _Piro:
3005  000c 0000          	dc.w	0
3006  000e               _Psup:
3007  000e 0000          	dc.w	0
3008  0010               _Pinf:
3009  0010 0000          	dc.w	0
3010  0012               _temp:
3011  0012 0000          	dc.w	0
3012  0014               _Sl:
3013  0014 0000          	dc.w	0
3014  0016               _AD_Foto:
3015  0016 0000          	dc.w	0
3064                     ; 59 main(){
3066                     	switch	.text
3067  0000               _main:
3071                     ; 63 		CLK_HSIPrescalerConfig (CLK_PRESCALER_HSIDIV8);	// Primeiro determina-se o clock como "High Speedy (HS)" o que dá 16MHz e divide-se por 8 (16/8 = 2MHz)
3073  0000 a618          	ld	a,#24
3074  0002 cd0000        	call	_CLK_HSIPrescalerConfig
3076                     ; 67     GPIO_Init(Pino_Rele_conf); 	  					// Inicialização do pino correspondente ao Triac (sáida)
3078  0005 4bd0          	push	#208
3079  0007 4b08          	push	#8
3080  0009 ae500a        	ldw	x,#20490
3081  000c cd0000        	call	_GPIO_Init
3083  000f 85            	popw	x
3084                     ; 68 		GPIO_Init(Pino_Zero_conf); 			    			// Inicialização do pino correspondente ao ZeroCrossing (entrada)
3086  0010 4b00          	push	#0
3087  0012 4b80          	push	#128
3088  0014 ae500a        	ldw	x,#20490
3089  0017 cd0000        	call	_GPIO_Init
3091  001a 85            	popw	x
3092                     ; 69 		GPIO_Init(Pino_Led_conf); 								// Inicialização do pino correspondente ao Led (saída)
3094  001b 4bd0          	push	#208
3095  001d 4b40          	push	#64
3096  001f ae500a        	ldw	x,#20490
3097  0022 cd0000        	call	_GPIO_Init
3099  0025 85            	popw	x
3100                     ; 70 		GPIO_Init(Pino_Teste_conf); 							// Inicialização do pino correspondente ao Teste Rápido (entrada)
3102  0026 4b00          	push	#0
3103  0028 4b20          	push	#32
3104  002a ae5005        	ldw	x,#20485
3105  002d cd0000        	call	_GPIO_Init
3107  0030 85            	popw	x
3108                     ; 73 		TIM4_TimeBaseInit(TIM4_PRESCALER_8,124);	// Configuração do Time base, ver no excel
3110  0031 ae037c        	ldw	x,#892
3111  0034 cd0000        	call	_TIM4_TimeBaseInit
3113                     ; 74 	  TIM4_ClearFlag(TIM4_FLAG_UPDATE); 				// Clear TIM4 update flag 
3115  0037 a601          	ld	a,#1
3116  0039 cd0000        	call	_TIM4_ClearFlag
3118                     ; 75 		TIM4_ITConfig(TIM4_IT_UPDATE, ENABLE);		// Enable update interrupt
3120  003c ae0101        	ldw	x,#257
3121  003f cd0000        	call	_TIM4_ITConfig
3123                     ; 76 		TIM4_Cmd(ENABLE);   											// Habilita TIM4 
3125  0042 a601          	ld	a,#1
3126  0044 cd0000        	call	_TIM4_Cmd
3128                     ; 77 		enableInterrupts();                       // Habilita Interrupções
3131  0047 9a            rim
3133                     ; 83 		FLASH_SetProgrammingTime(FLASH_PROGRAMTIME_STANDARD); //Espera até que a área de programação da Flash desbloqueada seja setada
3136  0048 4f            	clr	a
3137  0049 cd0000        	call	_FLASH_SetProgrammingTime
3139                     ; 84 		FLASH_Unlock(FLASH_MEMTYPE_PROG);
3141  004c a6fd          	ld	a,#253
3142  004e cd0000        	call	_FLASH_Unlock
3145  0051               L1212:
3146                     ; 86 		while(FLASH_GetFlagStatus(FLASH_FLAG_PUL) == RESET){;} // Flag de segurança para gravação da memória Flash
3148  0051 a602          	ld	a,#2
3149  0053 cd0000        	call	_FLASH_GetFlagStatus
3151  0056 4d            	tnz	a
3152  0057 27f8          	jreq	L1212
3153                     ; 88 		FLASH_Unlock(FLASH_MEMTYPE_DATA);
3155  0059 a6f7          	ld	a,#247
3156  005b cd0000        	call	_FLASH_Unlock
3159  005e               L7212:
3160                     ; 90 		while(FLASH_GetFlagStatus(FLASH_FLAG_DUL) == RESET){;}/**/ //Flag de segurança para gravação na memória EEPROM
3162  005e a608          	ld	a,#8
3163  0060 cd0000        	call	_FLASH_GetFlagStatus
3165  0063 4d            	tnz	a
3166  0064 27f8          	jreq	L7212
3167                     ; 102 	Rele = 0;
3169  0066 7217500a      	bres	_PCODR,#3
3170                     ; 103 	Inicializa();
3172  006a cd040c        	call	_Inicializa
3174  006d               L3312:
3175                     ; 106 		VerificaAjusteTempo();             // Verifica o tempo selecionado e carrega na variavel tp
3177  006d cd00ff        	call	_VerificaAjusteTempo
3179                     ; 107 		VerificaAjusteFotocelula();    		 // Verifica a posição do ajuste da fotocelula e carrega na variável Ajuste_Fot
3181  0070 cd014a        	call	_VerificaAjusteFotocelula
3183                     ; 108 		VerificaLuminosidade();            // Verifica o nivel da luminosidade e carrega na variável Lumi
3185  0073 cd0181        	call	_VerificaLuminosidade
3187                     ; 109 		VerificaPiroSensor();
3189  0076 ad1f          	call	_VerificaPiroSensor
3191                     ; 110 		VerificaAjusteSensibilidade();     // Verifica a posição do ajuste da sensibilidade e carrega na variável Sensibilidade
3193  0078 ad3c          	call	_VerificaAjusteSensibilidade
3195                     ; 112 	 if (Ajuste_Fot==2)              { Disparo();} // Fotocélula desligada, dispara a carga independente da luz externa
3197  007a be00          	ldw	x,_Ajuste_Fot
3198  007c a30002        	cpw	x,#2
3199  007f 2603          	jrne	L7312
3202  0081 cd01fc        	call	_Disparo
3204  0084               L7312:
3205                     ; 113    if((Ajuste_Fot==1) && (lumi==1)){Disparo();}  // Fotocélula ligada e ambiente escuro, dispara a carga.
3207  0084 be00          	ldw	x,_Ajuste_Fot
3208  0086 a30001        	cpw	x,#1
3209  0089 26e2          	jrne	L3312
3211  008b be06          	ldw	x,_lumi
3212  008d a30001        	cpw	x,#1
3213  0090 26db          	jrne	L3312
3216  0092 cd01fc        	call	_Disparo
3218  0095 20d6          	jra	L3312
3247                     ; 122 void VerificaPiroSensor(void){// Definição da Função de leitura do Pirosensor
3248                     	switch	.text
3249  0097               _VerificaPiroSensor:
3253                     ; 124 	ADC1_ConversionConfig(ADC1_CONVERSIONMODE_CONTINUOUS,ADC1_CHANNEL_6,ADC1_ALIGN_RIGHT);
3255  0097 4b08          	push	#8
3256  0099 ae0106        	ldw	x,#262
3257  009c cd0000        	call	_ADC1_ConversionConfig
3259  009f 84            	pop	a
3260                     ; 125 	ADC1_Cmd(ENABLE);
3262  00a0 a601          	ld	a,#1
3263  00a2 cd0000        	call	_ADC1_Cmd
3265                     ; 126 	ADC1_StartConversion(); // Leitura AD do pirosensor
3267  00a5 cd0000        	call	_ADC1_StartConversion
3269                     ; 129 	  if(ADC1_GetFlagStatus(ADC1_FLAG_EOC)){ Piro = ADC1_GetConversionValue();} // Proteção BUG de conversão AD da ST
3271  00a8 a680          	ld	a,#128
3272  00aa cd0000        	call	_ADC1_GetFlagStatus
3274  00ad 4d            	tnz	a
3275  00ae 2705          	jreq	L3512
3278  00b0 cd0000        	call	_ADC1_GetConversionValue
3280  00b3 bf0c          	ldw	_Piro,x
3281  00b5               L3512:
3282                     ; 134 	return;
3285  00b5 81            	ret
3318                     ; 142 void VerificaAjusteSensibilidade(void){ // Definição da Função de Seleção Sensibilidade em +/- 50us
3319                     	switch	.text
3320  00b6               _VerificaAjusteSensibilidade:
3324                     ; 143   ADC1_ConversionConfig(ADC1_CONVERSIONMODE_CONTINUOUS,ADC1_CHANNEL_4,ADC1_ALIGN_RIGHT) ; // Modo de conversão analógico
3326  00b6 4b08          	push	#8
3327  00b8 ae0104        	ldw	x,#260
3328  00bb cd0000        	call	_ADC1_ConversionConfig
3330  00be 84            	pop	a
3331                     ; 144   ADC1_Cmd(ENABLE); // Habilita o ADC1
3333  00bf a601          	ld	a,#1
3334  00c1 cd0000        	call	_ADC1_Cmd
3336                     ; 145   ADC1_StartConversion(); // Inicia a conversão
3338  00c4 cd0000        	call	_ADC1_StartConversion
3340                     ; 148 	if(ADC1_GetFlagStatus(ADC1_FLAG_EOC)){ Sl = ADC1_GetConversionValue(); } // Proteção BUG de conversão AD da ST
3342  00c7 a680          	ld	a,#128
3343  00c9 cd0000        	call	_ADC1_GetFlagStatus
3345  00cc 4d            	tnz	a
3346  00cd 2705          	jreq	L5612
3349  00cf cd0000        	call	_ADC1_GetConversionValue
3351  00d2 bf14          	ldw	_Sl,x
3352  00d4               L5612:
3353                     ; 151 	if(Sl<650)               { Pinf = Piro - 50;    Psup = Piro + 50;}  // Sens Máx Atribuição de valores inf e sup da janela do Pirosensor
3355  00d4 be14          	ldw	x,_Sl
3356  00d6 a3028a        	cpw	x,#650
3357  00d9 240e          	jruge	L7612
3360  00db be0c          	ldw	x,_Piro
3361  00dd 1d0032        	subw	x,#50
3362  00e0 bf10          	ldw	_Pinf,x
3365  00e2 be0c          	ldw	x,_Piro
3366  00e4 1c0032        	addw	x,#50
3367  00e7 bf0e          	ldw	_Psup,x
3368  00e9               L7612:
3369                     ; 152 	if(Sl>=650)              { Pinf = Piro - 250;   Psup = Piro + 250;} // Sens Mín Atribuição de valores inf e sup da janela do Pirosensor 
3371  00e9 be14          	ldw	x,_Sl
3372  00eb a3028a        	cpw	x,#650
3373  00ee 250e          	jrult	L1712
3376  00f0 be0c          	ldw	x,_Piro
3377  00f2 1d00fa        	subw	x,#250
3378  00f5 bf10          	ldw	_Pinf,x
3381  00f7 be0c          	ldw	x,_Piro
3382  00f9 1c00fa        	addw	x,#250
3383  00fc bf0e          	ldw	_Psup,x
3384  00fe               L1712:
3385                     ; 155 	return;
3388  00fe 81            	ret
3420                     ; 163  void VerificaAjusteTempo(void){ // Definição da Função  Leitura de Tempo
3421                     	switch	.text
3422  00ff               _VerificaAjusteTempo:
3426                     ; 164   ADC1_ConversionConfig(ADC1_CONVERSIONMODE_CONTINUOUS,ADC1_CHANNEL_3,ADC1_ALIGN_RIGHT);
3428  00ff 4b08          	push	#8
3429  0101 ae0103        	ldw	x,#259
3430  0104 cd0000        	call	_ADC1_ConversionConfig
3432  0107 84            	pop	a
3433                     ; 165   ADC1_Cmd(ENABLE);
3435  0108 a601          	ld	a,#1
3436  010a cd0000        	call	_ADC1_Cmd
3438                     ; 166 	nop();
3441  010d 9d            nop
3443                     ; 167   ADC1_StartConversion(); // Inicia a conversão A/D
3446  010e cd0000        	call	_ADC1_StartConversion
3448                     ; 169 	if(ADC1_GetFlagStatus(ADC1_FLAG_EOC)){ temp = ADC1_GetConversionValue(); } // Proteção BUG de conversão AD da ST
3450  0111 a680          	ld	a,#128
3451  0113 cd0000        	call	_ADC1_GetFlagStatus
3453  0116 4d            	tnz	a
3454  0117 2705          	jreq	L3022
3457  0119 cd0000        	call	_ADC1_GetConversionValue
3459  011c bf12          	ldw	_temp,x
3460  011e               L3022:
3461                     ; 174 	if (temp<450)                 { tp = 760; } //Posição 3 - 4 minutos
3463  011e be12          	ldw	x,_temp
3464  0120 a301c2        	cpw	x,#450
3465  0123 2405          	jruge	L5022
3468  0125 ae02f8        	ldw	x,#760
3469  0128 bf02          	ldw	_tp,x
3470  012a               L5022:
3471                     ; 175 	if ((temp>=450)&&(temp<=750)) { tp = 190; } //Posição 2 - 1 minuto
3473  012a be12          	ldw	x,_temp
3474  012c a301c2        	cpw	x,#450
3475  012f 250c          	jrult	L7022
3477  0131 be12          	ldw	x,_temp
3478  0133 a302ef        	cpw	x,#751
3479  0136 2405          	jruge	L7022
3482  0138 ae00be        	ldw	x,#190
3483  013b bf02          	ldw	_tp,x
3484  013d               L7022:
3485                     ; 176 	if (temp>750)                 { tp = 15; }  //Posição 1 - 5 segundos
3487  013d be12          	ldw	x,_temp
3488  013f a302ef        	cpw	x,#751
3489  0142 2505          	jrult	L1122
3492  0144 ae000f        	ldw	x,#15
3493  0147 bf02          	ldw	_tp,x
3494  0149               L1122:
3495                     ; 177 	return;
3498  0149 81            	ret
3529                     ; 185 void VerificaAjusteFotocelula(void){ // Definição da Função de Seleção Fotocelula em +/- 50us
3530                     	switch	.text
3531  014a               _VerificaAjusteFotocelula:
3535                     ; 186   ADC1_ConversionConfig(ADC1_CONVERSIONMODE_CONTINUOUS,ADC1_CHANNEL_5,ADC1_ALIGN_RIGHT); // Modo de conversão analógico
3537  014a 4b08          	push	#8
3538  014c ae0105        	ldw	x,#261
3539  014f cd0000        	call	_ADC1_ConversionConfig
3541  0152 84            	pop	a
3542                     ; 187   ADC1_Cmd(ENABLE);
3544  0153 a601          	ld	a,#1
3545  0155 cd0000        	call	_ADC1_Cmd
3547                     ; 188   ADC1_StartConversion(); // Inicia a conversão
3549  0158 cd0000        	call	_ADC1_StartConversion
3551                     ; 190 	if(ADC1_GetFlagStatus(ADC1_FLAG_EOC)){ AD_Foto = ADC1_GetConversionValue(); } // Proteção BUG de conversão AD da ST
3553  015b a680          	ld	a,#128
3554  015d cd0000        	call	_ADC1_GetFlagStatus
3556  0160 4d            	tnz	a
3557  0161 2705          	jreq	L3222
3560  0163 cd0000        	call	_ADC1_GetConversionValue
3562  0166 bf16          	ldw	_AD_Foto,x
3563  0168               L3222:
3564                     ; 193    if (AD_Foto<=650)                    {Ajuste_Fot = 1;} // Posição 3 - Noite, luminosidade minima (-)
3566  0168 be16          	ldw	x,_AD_Foto
3567  016a a3028b        	cpw	x,#651
3568  016d 2405          	jruge	L5222
3571  016f ae0001        	ldw	x,#1
3572  0172 bf00          	ldw	_Ajuste_Fot,x
3573  0174               L5222:
3574                     ; 194 	 if (AD_Foto>650)                     {Ajuste_Fot = 2;} // Posição 1 - Fotocélula OFF (DESL)
3576  0174 be16          	ldw	x,_AD_Foto
3577  0176 a3028b        	cpw	x,#651
3578  0179 2505          	jrult	L7222
3581  017b ae0002        	ldw	x,#2
3582  017e bf00          	ldw	_Ajuste_Fot,x
3583  0180               L7222:
3584                     ; 196 	return;
3587  0180 81            	ret
3645                     ; 204 void VerificaLuminosidade(void){      // Definição da função luminosidade
3646                     	switch	.text
3647  0181               _VerificaLuminosidade:
3649  0181 5206          	subw	sp,#6
3650       00000006      OFST:	set	6
3653                     ; 208   LerLDR();
3655  0183 cd027e        	call	_LerLDR
3657                     ; 209     if(Escuridade>=Lux){              // Escuridade é uma variavel que representa a quantidade de lux
3659  0186 be08          	ldw	x,_Escuridade
3660  0188 b30a          	cpw	x,_Lux
3661  018a 2533          	jrult	L7522
3662                     ; 210     for(a=0; a<50; a++){              // Incremento para verificação da luminosidade durante 50ms
3664  018c 5f            	clrw	x
3665  018d 1f05          	ldw	(OFST-1,sp),x
3667  018f               L1622:
3668                     ; 211        b++;                           // Incrementa a variavel b
3670  018f 1e01          	ldw	x,(OFST-5,sp)
3671  0191 1c0001        	addw	x,#1
3672  0194 1f01          	ldw	(OFST-5,sp),x
3674                     ; 212        LerLDR();                      // Leitura do A/D  LDR e carrega na variavel LDR
3676  0196 cd027e        	call	_LerLDR
3678                     ; 213            if(Escuridade<Lux){break;} // Se a variavel LDR for menor que Lux sai da instrução for e atribui para variavel lumi=0
3680  0199 be08          	ldw	x,_Escuridade
3681  019b b30a          	cpw	x,_Lux
3682  019d 2514          	jrult	L5622
3685                     ; 214            Delay_500us(2);            // Tempo de 1ms
3687  019f ae0002        	ldw	x,#2
3688  01a2 cd0422        	call	_Delay_500us
3690                     ; 210     for(a=0; a<50; a++){              // Incremento para verificação da luminosidade durante 50ms
3692  01a5 1e05          	ldw	x,(OFST-1,sp)
3693  01a7 1c0001        	addw	x,#1
3694  01aa 1f05          	ldw	(OFST-1,sp),x
3698  01ac 1e05          	ldw	x,(OFST-1,sp)
3699  01ae a30032        	cpw	x,#50
3700  01b1 25dc          	jrult	L1622
3701  01b3               L5622:
3702                     ; 216     if(b>=49){ lumi = 1;}             // Noite; Se a variavel b atingir valor igual a 50, lumi recebe 1 indicando que esta noite
3704  01b3 1e01          	ldw	x,(OFST-5,sp)
3705  01b5 a30031        	cpw	x,#49
3706  01b8 2505          	jrult	L7522
3709  01ba ae0001        	ldw	x,#1
3710  01bd bf06          	ldw	_lumi,x
3711  01bf               L7522:
3712                     ; 218   if(Escuridade<(Lux-50)){            // Escuridade é uma variavel que representa a quantidade de lux
3714  01bf be0a          	ldw	x,_Lux
3715  01c1 1d0032        	subw	x,#50
3716  01c4 b308          	cpw	x,_Escuridade
3717  01c6 2331          	jrule	L3722
3718                     ; 219     for(a=0; a<50; a++){              // Incremento para verificação da luminosidade durante 50ms
3720  01c8 5f            	clrw	x
3721  01c9 1f05          	ldw	(OFST-1,sp),x
3723  01cb               L5722:
3724                     ; 220        c++;                           // Incrementa a variavel c
3726  01cb 1e03          	ldw	x,(OFST-3,sp)
3727  01cd 1c0001        	addw	x,#1
3728  01d0 1f03          	ldw	(OFST-3,sp),x
3730                     ; 221            LerLDR();                  // Leitura do A/D  LDR e carrega na variavel LDR
3732  01d2 cd027e        	call	_LerLDR
3734                     ; 222        if(Escuridade>Lux){break;}     // Se a variavel LDR for maior que Lux, sai da instrução for e atribui para variavel lumi=0
3736  01d5 be08          	ldw	x,_Escuridade
3737  01d7 b30a          	cpw	x,_Lux
3738  01d9 2214          	jrugt	L1032
3741                     ; 223        Delay_500us(2);                // Tempo de 1ms
3743  01db ae0002        	ldw	x,#2
3744  01de cd0422        	call	_Delay_500us
3746                     ; 219     for(a=0; a<50; a++){              // Incremento para verificação da luminosidade durante 50ms
3748  01e1 1e05          	ldw	x,(OFST-1,sp)
3749  01e3 1c0001        	addw	x,#1
3750  01e6 1f05          	ldw	(OFST-1,sp),x
3754  01e8 1e05          	ldw	x,(OFST-1,sp)
3755  01ea a30032        	cpw	x,#50
3756  01ed 25dc          	jrult	L5722
3757  01ef               L1032:
3758                     ; 225     if(c>=49){ lumi = 0; }            // De dia...
3760  01ef 1e03          	ldw	x,(OFST-3,sp)
3761  01f1 a30031        	cpw	x,#49
3762  01f4 2503          	jrult	L3722
3765  01f6 5f            	clrw	x
3766  01f7 bf06          	ldw	_lumi,x
3767  01f9               L3722:
3768                     ; 227    return;
3771  01f9 5b06          	addw	sp,#6
3772  01fb 81            	ret
3835                     ; 236 void Disparo(void){	 //0,2s
3836                     	switch	.text
3837  01fc               _Disparo:
3839  01fc 5205          	subw	sp,#5
3840       00000005      OFST:	set	5
3843                     ; 237 	short PiroInicial=0;
3845                     ; 238 	short PiroFinal=0;
3847                     ; 239 	char estado_rele = 0;
3849  01fe 0f01          	clr	(OFST-4,sp)
3851                     ; 241 	g = 0;
3853  0200 5f            	clrw	x
3854  0201 bf04          	ldw	_g,x
3856  0203 2058          	jra	L1432
3857  0205               L5332:
3858                     ; 244 		VerificaPiroSensor();					               // Verifica o valor do AD referente ao Pirosensor e salva na variavel Piro;
3860  0205 cd0097        	call	_VerificaPiroSensor
3862                     ; 245 		VerificaAjusteTempo();                       // Verifica o tempo selecionado e carrega na variavel tp
3864  0208 cd00ff        	call	_VerificaAjusteTempo
3866                     ; 246 		VerificaAjusteSensibilidade();               // Verifica as janelas de atuação do pirosensor
3868  020b cd00b6        	call	_VerificaAjusteSensibilidade
3870                     ; 247 		Delay_500us(1);
3872  020e ae0001        	ldw	x,#1
3873  0211 cd0422        	call	_Delay_500us
3875                     ; 249 		VerificaPiroSensor(); PiroInicial = Piro;    // Desvia para a função para verificar o pirosensor
3877  0214 cd0097        	call	_VerificaPiroSensor
3881  0217 be0c          	ldw	x,_Piro
3882  0219 1f02          	ldw	(OFST-3,sp),x
3884                     ; 250 		Delay_500us(600);                            // Tempo 100ms (Antes Tempo de 150ms)	(antes 200ms)
3886  021b ae0258        	ldw	x,#600
3887  021e cd0422        	call	_Delay_500us
3889                     ; 251 		VerificaPiroSensor(); PiroFinal = Piro;
3891  0221 cd0097        	call	_VerificaPiroSensor
3895  0224 be0c          	ldw	x,_Piro
3896  0226 1f04          	ldw	(OFST-1,sp),x
3898                     ; 253 		if((PiroInicial<PiroFinal) && (Piro>=Psup)){
3900  0228 9c            	rvf
3901  0229 1e02          	ldw	x,(OFST-3,sp)
3902  022b 1304          	cpw	x,(OFST-1,sp)
3903  022d 2e10          	jrsge	L5432
3905  022f 9c            	rvf
3906  0230 be0c          	ldw	x,_Piro
3907  0232 b30e          	cpw	x,_Psup
3908  0234 2f09          	jrslt	L5432
3909                     ; 254 			 Liga();							                      // Dispara a carga no "zero" da senoide
3911  0236 ad65          	call	_Liga
3913                     ; 255    		 estado_rele = 1;
3915  0238 a601          	ld	a,#1
3916  023a 6b01          	ld	(OFST-4,sp),a
3918                     ; 256 		   g = 0;
3920  023c 5f            	clrw	x
3921  023d bf04          	ldw	_g,x
3922  023f               L5432:
3923                     ; 259 		if((PiroInicial>PiroFinal) && (Piro<=Pinf)){
3925  023f 9c            	rvf
3926  0240 1e02          	ldw	x,(OFST-3,sp)
3927  0242 1304          	cpw	x,(OFST-1,sp)
3928  0244 2d10          	jrsle	L7432
3930  0246 9c            	rvf
3931  0247 be0c          	ldw	x,_Piro
3932  0249 b310          	cpw	x,_Pinf
3933  024b 2c09          	jrsgt	L7432
3934                     ; 260 			 Liga();							                      // Dispara a carga no "zero" da senoide
3936  024d ad4e          	call	_Liga
3938                     ; 261 			 estado_rele = 1;
3940  024f a601          	ld	a,#1
3941  0251 6b01          	ld	(OFST-4,sp),a
3943                     ; 262 			 g = 0;
3945  0253 5f            	clrw	x
3946  0254 bf04          	ldw	_g,x
3947  0256               L7432:
3948                     ; 265 		g++;
3950  0256 be04          	ldw	x,_g
3951  0258 1c0001        	addw	x,#1
3952  025b bf04          	ldw	_g,x
3953  025d               L1432:
3954                     ; 243 	while(g<tp){
3954                     ; 244 		VerificaPiroSensor();					               // Verifica o valor do AD referente ao Pirosensor e salva na variavel Piro;
3954                     ; 245 		VerificaAjusteTempo();                       // Verifica o tempo selecionado e carrega na variavel tp
3954                     ; 246 		VerificaAjusteSensibilidade();               // Verifica as janelas de atuação do pirosensor
3954                     ; 247 		Delay_500us(1);
3954                     ; 248 
3954                     ; 249 		VerificaPiroSensor(); PiroInicial = Piro;    // Desvia para a função para verificar o pirosensor
3954                     ; 250 		Delay_500us(600);                            // Tempo 100ms (Antes Tempo de 150ms)	(antes 200ms)
3954                     ; 251 		VerificaPiroSensor(); PiroFinal = Piro;
3954                     ; 252 
3954                     ; 253 		if((PiroInicial<PiroFinal) && (Piro>=Psup)){
3954                     ; 254 			 Liga();							                      // Dispara a carga no "zero" da senoide
3954                     ; 255    		 estado_rele = 1;
3954                     ; 256 		   g = 0;
3954                     ; 257 		}
3954                     ; 258 
3954                     ; 259 		if((PiroInicial>PiroFinal) && (Piro<=Pinf)){
3954                     ; 260 			 Liga();							                      // Dispara a carga no "zero" da senoide
3954                     ; 261 			 estado_rele = 1;
3954                     ; 262 			 g = 0;
3954                     ; 263 		}
3954                     ; 264 
3954                     ; 265 		g++;
3956  025d be04          	ldw	x,_g
3957  025f b302          	cpw	x,_tp
3958  0261 25a2          	jrult	L5332
3959                     ; 268 	if((g>=tp)&&(estado_rele == 1)){
3961  0263 be04          	ldw	x,_g
3962  0265 b302          	cpw	x,_tp
3963  0267 2512          	jrult	L1532
3965  0269 7b01          	ld	a,(OFST-4,sp)
3966  026b a101          	cp	a,#1
3967  026d 260c          	jrne	L1532
3968                     ; 269 		 g=0;
3970  026f 5f            	clrw	x
3971  0270 bf04          	ldw	_g,x
3972                     ; 270 		 Desliga();                                   // Desliga a carga no "zero" da senoide
3974  0272 cd0358        	call	_Desliga
3976                     ; 271 		 Delay_500us(2000);                          // Delay de 1 segundo inserido devido ao ruido de disparo do Rele
3978  0275 ae07d0        	ldw	x,#2000
3979  0278 cd0422        	call	_Delay_500us
3981  027b               L1532:
3982                     ; 273 	return;
3985  027b 5b05          	addw	sp,#5
3986  027d 81            	ret
4015                     ; 280 void LerLDR(void){           // Definição da função "EsperaZero"
4016                     	switch	.text
4017  027e               _LerLDR:
4021                     ; 281   ADC1_ConversionConfig(ADC1_CONVERSIONMODE_CONTINUOUS,ADC1_CHANNEL_2,ADC1_ALIGN_RIGHT); // Inicialização ADC1 - 8 bits
4023  027e 4b08          	push	#8
4024  0280 ae0102        	ldw	x,#258
4025  0283 cd0000        	call	_ADC1_ConversionConfig
4027  0286 84            	pop	a
4028                     ; 282 	ADC1_Cmd(ENABLE);       // Habilita o ADC1
4030  0287 a601          	ld	a,#1
4031  0289 cd0000        	call	_ADC1_Cmd
4033                     ; 283 	ADC1_StartConversion(); // Inicia a coversão
4035  028c cd0000        	call	_ADC1_StartConversion
4037                     ; 285 	if(ADC1_GetFlagStatus(ADC1_FLAG_EOC)){ Escuridade = ADC1_GetConversionValue(); } // Proteção BUG de conversão AD da ST
4039  028f a680          	ld	a,#128
4040  0291 cd0000        	call	_ADC1_GetFlagStatus
4042  0294 4d            	tnz	a
4043  0295 2705          	jreq	L3632
4046  0297 cd0000        	call	_ADC1_GetConversionValue
4048  029a bf08          	ldw	_Escuridade,x
4049  029c               L3632:
4050                     ; 287 	return;
4053  029c 81            	ret
4099                     ; 290 void Liga(void){                  // Definição da função "EsperaZero"
4100                     	switch	.text
4101  029d               _Liga:
4103  029d 5204          	subw	sp,#4
4104       00000004      OFST:	set	4
4107                     ; 291  int e=0,f=0;
4111  029f 5f            	clrw	x
4112  02a0 1f01          	ldw	(OFST-3,sp),x
4114                     ; 292  if(Zero==1){                     // Se a senoide estiver em 1, aguarda ela passar por 0
4116  02a2 c6500b        	ld	a,_PCIDR
4117  02a5 a580          	bcp	a,#128
4118  02a7 274b          	jreq	L5342
4119  02a9               L1142:
4120                     ; 293 		  do { Delay_500us(1); }      // Delay de 500us verificando o sinal da senoide
4122  02a9 ae0001        	ldw	x,#1
4123  02ac cd0422        	call	_Delay_500us
4125                     ; 294 		  while(Zero!= 0);            // Quando for 0, retorna para o disparo da carga
4127  02af c6500b        	ld	a,_PCIDR
4128  02b2 a580          	bcp	a,#128
4129  02b4 26f3          	jrne	L1142
4130                     ; 295       for(e=0; e<20; e++){        // Conta um tempo de 20ms
4132  02b6 5f            	clrw	x
4133  02b7 1f03          	ldw	(OFST-1,sp),x
4135  02b9               L7142:
4136                     ; 296 	      Delay_500us(2);           // Delay de 1ms.
4138  02b9 ae0002        	ldw	x,#2
4139  02bc cd0422        	call	_Delay_500us
4141                     ; 297         if (Zero==1){f++;};       // Durante o periodo de 20ms analisa-se o tempo que a senoide fica em nivel alto(1) e incrementa a variavel f
4143  02bf c6500b        	ld	a,_PCIDR
4144  02c2 a580          	bcp	a,#128
4145  02c4 2707          	jreq	L5242
4148  02c6 1e01          	ldw	x,(OFST-3,sp)
4149  02c8 1c0001        	addw	x,#1
4150  02cb 1f01          	ldw	(OFST-3,sp),x
4152  02cd               L5242:
4153                     ; 295       for(e=0; e<20; e++){        // Conta um tempo de 20ms
4156  02cd 1e03          	ldw	x,(OFST-1,sp)
4157  02cf 1c0001        	addw	x,#1
4158  02d2 1f03          	ldw	(OFST-1,sp),x
4162  02d4 9c            	rvf
4163  02d5 1e03          	ldw	x,(OFST-1,sp)
4164  02d7 a30014        	cpw	x,#20
4165  02da 2fdd          	jrslt	L7142
4166                     ; 299       if(f<=9){Delay_500us(16);}   // Se o tempo que a senoide ficou em nivel alto for menor que 9ms a rede é 60Hz ent?o aguardo 8ms para ligar a carga,
4168  02dc 9c            	rvf
4169  02dd 1e01          	ldw	x,(OFST-3,sp)
4170  02df a3000a        	cpw	x,#10
4171  02e2 2e08          	jrsge	L7242
4174  02e4 ae0010        	ldw	x,#16
4175  02e7 cd0422        	call	_Delay_500us
4178  02ea 2065          	jra	L3342
4179  02ec               L7242:
4180                     ; 300       else{Delay_500us(9);}       // Se for maior que 9ms a rede é 50Hz entao aguardo 4,5ms para acionar a carga
4182  02ec ae0009        	ldw	x,#9
4183  02ef cd0422        	call	_Delay_500us
4185  02f2 205d          	jra	L3342
4186  02f4               L5342:
4187                     ; 303 		  do {Delay_500us(1);}        // Delay de 500us verificando o sinal da senoide
4189  02f4 ae0001        	ldw	x,#1
4190  02f7 cd0422        	call	_Delay_500us
4192                     ; 304 			while(Zero!= 1);            // Quando for 1, espera passar por 0 novamente
4194  02fa c6500b        	ld	a,_PCIDR
4195  02fd a580          	bcp	a,#128
4196  02ff 27f3          	jreq	L5342
4197                     ; 305 			if(Zero==1){                // Se Zero igual a 1 segue a instrução
4199  0301 c6500b        	ld	a,_PCIDR
4200  0304 a580          	bcp	a,#128
4201  0306 2749          	jreq	L3342
4202  0308               L5442:
4203                     ; 306 				do {Delay_500us(1);}      // Delay de 500us verificando o sinal da senoide
4205  0308 ae0001        	ldw	x,#1
4206  030b cd0422        	call	_Delay_500us
4208                     ; 307 		    while(Zero!= 0);          // Quando for 0, retorna para o disparo da carga
4210  030e c6500b        	ld	a,_PCIDR
4211  0311 a580          	bcp	a,#128
4212  0313 26f3          	jrne	L5442
4213                     ; 308 				for(e=0; e<20; e++){      // Conta um tempo de 20ms
4215  0315 5f            	clrw	x
4216  0316 1f03          	ldw	(OFST-1,sp),x
4218  0318               L3542:
4219                     ; 309            Delay_500us(2);        // Delay de 1ms.
4221  0318 ae0002        	ldw	x,#2
4222  031b cd0422        	call	_Delay_500us
4224                     ; 310            if (Zero==1){f++;};    // Durante o periodo de 20ms analisa-se o tempo que a senoide fica em nivel alto(1) e incrementa a variavel f
4226  031e c6500b        	ld	a,_PCIDR
4227  0321 a580          	bcp	a,#128
4228  0323 2707          	jreq	L1642
4231  0325 1e01          	ldw	x,(OFST-3,sp)
4232  0327 1c0001        	addw	x,#1
4233  032a 1f01          	ldw	(OFST-3,sp),x
4235  032c               L1642:
4236                     ; 308 				for(e=0; e<20; e++){      // Conta um tempo de 20ms
4239  032c 1e03          	ldw	x,(OFST-1,sp)
4240  032e 1c0001        	addw	x,#1
4241  0331 1f03          	ldw	(OFST-1,sp),x
4245  0333 9c            	rvf
4246  0334 1e03          	ldw	x,(OFST-1,sp)
4247  0336 a30014        	cpw	x,#20
4248  0339 2fdd          	jrslt	L3542
4249                     ; 312         if(f<=9){Delay_500us(16);} // Se o tempo que a senoide ficou em nivel alto for menor que 9ms a rede é 60Hz ent?o aguardo 8ms para ligar a carga,
4251  033b 9c            	rvf
4252  033c 1e01          	ldw	x,(OFST-3,sp)
4253  033e a3000a        	cpw	x,#10
4254  0341 2e08          	jrsge	L3642
4257  0343 ae0010        	ldw	x,#16
4258  0346 cd0422        	call	_Delay_500us
4261  0349 2006          	jra	L3342
4262  034b               L3642:
4263                     ; 313         else{Delay_500us(9);}     // Se for maior que 9ms a rede é 50Hz ent?o aguardo 4,5ms para acionar a carga
4265  034b ae0009        	ldw	x,#9
4266  034e cd0422        	call	_Delay_500us
4268  0351               L3342:
4269                     ; 316  Rele=1;
4271  0351 7216500a      	bset	_PCODR,#3
4272                     ; 317  return;
4275  0355 5b04          	addw	sp,#4
4276  0357 81            	ret
4322                     ; 321 void Desliga(void){               // Definição da função "EsperaZero"
4323                     	switch	.text
4324  0358               _Desliga:
4326  0358 5204          	subw	sp,#4
4327       00000004      OFST:	set	4
4330                     ; 322  int e=0,f=0;
4334  035a 5f            	clrw	x
4335  035b 1f01          	ldw	(OFST-3,sp),x
4337                     ; 323  if(Zero==1){                     // Se a senoide estiver em 1, aguarda ela passar por 0
4339  035d c6500b        	ld	a,_PCIDR
4340  0360 a580          	bcp	a,#128
4341  0362 2749          	jreq	L7352
4342  0364               L3152:
4343                     ; 324       do { Delay_500us(1); }      // Delay de 500us verificando o sinal da sen?ide
4345  0364 ae0001        	ldw	x,#1
4346  0367 cd0422        	call	_Delay_500us
4348                     ; 325       while(Zero!= 0);            // Quando for 0, retorna para o disparo da carga
4350  036a c6500b        	ld	a,_PCIDR
4351  036d a580          	bcp	a,#128
4352  036f 26f3          	jrne	L3152
4353                     ; 326       for(e=0; e<20; e++){        // Conta um tempo de 20ms
4355  0371 5f            	clrw	x
4356  0372 1f03          	ldw	(OFST-1,sp),x
4358  0374               L1252:
4359                     ; 327         Delay_500us(2);           // Delay de 1ms.
4361  0374 ae0002        	ldw	x,#2
4362  0377 cd0422        	call	_Delay_500us
4364                     ; 328         if (Zero==1){f++;};       // Durante o periodo de 20ms analisa-se o tempo que a senoide fica em nivel alto(1) e incrementa a variavel f
4366  037a c6500b        	ld	a,_PCIDR
4367  037d a580          	bcp	a,#128
4368  037f 2707          	jreq	L7252
4371  0381 1e01          	ldw	x,(OFST-3,sp)
4372  0383 1c0001        	addw	x,#1
4373  0386 1f01          	ldw	(OFST-3,sp),x
4375  0388               L7252:
4376                     ; 326       for(e=0; e<20; e++){        // Conta um tempo de 20ms
4379  0388 1e03          	ldw	x,(OFST-1,sp)
4380  038a 1c0001        	addw	x,#1
4381  038d 1f03          	ldw	(OFST-1,sp),x
4385  038f 9c            	rvf
4386  0390 1e03          	ldw	x,(OFST-1,sp)
4387  0392 a30014        	cpw	x,#20
4388  0395 2fdd          	jrslt	L1252
4389                     ; 330       if(f<=9){Delay_500us(16);}   // Se o tempo que a senoide ficou em nivel alto for menor que 9ms a rede é 60Hz ent?o aguardo 8ms para ligar a carga,
4391  0397 9c            	rvf
4392  0398 1e01          	ldw	x,(OFST-3,sp)
4393  039a a3000a        	cpw	x,#10
4394  039d 2e07          	jrsge	L1352
4397  039f ae0010        	ldw	x,#16
4398  03a2 ad7e          	call	_Delay_500us
4401  03a4 205f          	jra	L5352
4402  03a6               L1352:
4403                     ; 331       else{Delay_500us(9);}       // Se for maior que 9ms a rede é 50Hz ent?o aguardo 4,5ms para acionar a carga
4405  03a6 ae0009        	ldw	x,#9
4406  03a9 ad77          	call	_Delay_500us
4408  03ab 2058          	jra	L5352
4409  03ad               L7352:
4410                     ; 334       do {Delay_500us(1);}        // Delay de 500us verificando o sinal da sen?ide
4412  03ad ae0001        	ldw	x,#1
4413  03b0 ad70          	call	_Delay_500us
4415                     ; 335       while(Zero!= 1);            // Quando for 1, espera passar por 0 novamente
4417  03b2 c6500b        	ld	a,_PCIDR
4418  03b5 a580          	bcp	a,#128
4419  03b7 27f4          	jreq	L7352
4420                     ; 336       if(Zero==1){                // Se Zero igual a 1 segue a instrução
4422  03b9 c6500b        	ld	a,_PCIDR
4423  03bc a580          	bcp	a,#128
4424  03be 2745          	jreq	L5352
4425  03c0               L7452:
4426                     ; 337         do {Delay_500us(1);}      // Delay de 500us verificando o sinal da senoide
4428  03c0 ae0001        	ldw	x,#1
4429  03c3 ad5d          	call	_Delay_500us
4431                     ; 338         while(Zero!= 0);          // Quando for 0, retorna para o disparo da carga
4433  03c5 c6500b        	ld	a,_PCIDR
4434  03c8 a580          	bcp	a,#128
4435  03ca 26f4          	jrne	L7452
4436                     ; 339         for(e=0; e<20; e++){      // Conta um tempo de 20ms
4438  03cc 5f            	clrw	x
4439  03cd 1f03          	ldw	(OFST-1,sp),x
4441  03cf               L5552:
4442                     ; 340            Delay_500us(2);        // Delay de 1ms.
4444  03cf ae0002        	ldw	x,#2
4445  03d2 ad4e          	call	_Delay_500us
4447                     ; 341            if (Zero==1){f++;};    // Durante o periodo de 20ms analisa-se o tempo que a senoide fica em nivel alto(1) e incrementa a variavel f
4449  03d4 c6500b        	ld	a,_PCIDR
4450  03d7 a580          	bcp	a,#128
4451  03d9 2707          	jreq	L3652
4454  03db 1e01          	ldw	x,(OFST-3,sp)
4455  03dd 1c0001        	addw	x,#1
4456  03e0 1f01          	ldw	(OFST-3,sp),x
4458  03e2               L3652:
4459                     ; 339         for(e=0; e<20; e++){      // Conta um tempo de 20ms
4462  03e2 1e03          	ldw	x,(OFST-1,sp)
4463  03e4 1c0001        	addw	x,#1
4464  03e7 1f03          	ldw	(OFST-1,sp),x
4468  03e9 9c            	rvf
4469  03ea 1e03          	ldw	x,(OFST-1,sp)
4470  03ec a30014        	cpw	x,#20
4471  03ef 2fde          	jrslt	L5552
4472                     ; 343         if(f<=9){Delay_500us(16);} // Se o tempo que a senoide ficou em nivel alto for menor que 9ms a rede é 60Hz ent?o aguardo 8ms para ligar a carga,
4474  03f1 9c            	rvf
4475  03f2 1e01          	ldw	x,(OFST-3,sp)
4476  03f4 a3000a        	cpw	x,#10
4477  03f7 2e07          	jrsge	L5652
4480  03f9 ae0010        	ldw	x,#16
4481  03fc ad24          	call	_Delay_500us
4484  03fe 2005          	jra	L5352
4485  0400               L5652:
4486                     ; 344         else{Delay_500us(9);}     // Se for maior que 9ms a rede é 50Hz então aguardo 4,5ms para acionar a carga
4488  0400 ae0009        	ldw	x,#9
4489  0403 ad1d          	call	_Delay_500us
4491  0405               L5352:
4492                     ; 347  Rele=0;
4494  0405 7217500a      	bres	_PCODR,#3
4495                     ; 348  return;
4498  0409 5b04          	addw	sp,#4
4499  040b 81            	ret
4525                     ; 351 void Inicializa(void){
4526                     	switch	.text
4527  040c               _Inicializa:
4531                     ; 352 	  Delay_500us(2000);      // Tempo de inicialização para estabilizar o sinal do Pirosensor
4533  040c ae07d0        	ldw	x,#2000
4534  040f ad11          	call	_Delay_500us
4536                     ; 353 		Liga();
4538  0411 cd029d        	call	_Liga
4540                     ; 354 		Delay_500us(16000);
4542  0414 ae3e80        	ldw	x,#16000
4543  0417 ad09          	call	_Delay_500us
4545                     ; 355 		Desliga();
4547  0419 cd0358        	call	_Desliga
4549                     ; 356 		Delay_500us(10000);
4551  041c ae2710        	ldw	x,#10000
4552  041f ad01          	call	_Delay_500us
4554                     ; 357     return;
4557  0421 81            	ret
4619                     ; 360 void Delay_500us(int x){
4620                     	switch	.text
4621  0422               _Delay_500us:
4623  0422 89            	pushw	x
4624  0423 5204          	subw	sp,#4
4625       00000004      OFST:	set	4
4628                     ; 361 	int y=0,z=0,l=0;
4632  0425 5f            	clrw	x
4633  0426 1f03          	ldw	(OFST-1,sp),x
4637                     ; 363 	if(x<256){cnt=x; while(cnt);}
4639  0428 9c            	rvf
4640  0429 1e05          	ldw	x,(OFST+1,sp)
4641  042b a30100        	cpw	x,#256
4642  042e 2e0b          	jrsge	L7462
4645  0430 1e05          	ldw	x,(OFST+1,sp)
4646  0432 bf00          	ldw	_cnt,x
4648  0434               L1462:
4651  0434 be00          	ldw	x,_cnt
4652  0436 26fc          	jrne	L1462
4654  0438               L5462:
4655                     ; 372  return;
4658  0438 5b06          	addw	sp,#6
4659  043a 81            	ret
4660  043b               L7462:
4661                     ; 364 	else{ do{x=x-255;
4663  043b 1e05          	ldw	x,(OFST+1,sp)
4664  043d 1d00ff        	subw	x,#255
4665  0440 1f05          	ldw	(OFST+1,sp),x
4666                     ; 365 	         z++;
4668  0442 1e03          	ldw	x,(OFST-1,sp)
4669  0444 1c0001        	addw	x,#1
4670  0447 1f03          	ldw	(OFST-1,sp),x
4672                     ; 366 	        }while(x>=255);
4674  0449 9c            	rvf
4675  044a 1e05          	ldw	x,(OFST+1,sp)
4676  044c a300ff        	cpw	x,#255
4677  044f 2eea          	jrsge	L7462
4678                     ; 367 	      for(l=z; l>0; l--){
4682  0451 2010          	jra	L1662
4683  0453               L5562:
4684                     ; 368 	    	 cnt=255;while(cnt);
4686  0453 ae00ff        	ldw	x,#255
4687  0456 bf00          	ldw	_cnt,x
4689  0458               L1762:
4692  0458 be00          	ldw	x,_cnt
4693  045a 26fc          	jrne	L1762
4694                     ; 367 	      for(l=z; l>0; l--){
4696  045c 1e03          	ldw	x,(OFST-1,sp)
4697  045e 1d0001        	subw	x,#1
4698  0461 1f03          	ldw	(OFST-1,sp),x
4700  0463               L1662:
4703  0463 9c            	rvf
4704  0464 1e03          	ldw	x,(OFST-1,sp)
4705  0466 2ceb          	jrsgt	L5562
4706                     ; 370 	      cnt=x; while(cnt);
4708  0468 1e05          	ldw	x,(OFST+1,sp)
4709  046a bf00          	ldw	_cnt,x
4711  046c               L1072:
4714  046c be00          	ldw	x,_cnt
4715  046e 26fc          	jrne	L1072
4716  0470 20c6          	jra	L5462
4839                     	xdef	_main
4840                     	xdef	_Liga
4841                     	xdef	_Desliga
4842                     	xdef	_Inicializa
4843                     	xdef	_Delay_500us
4844                     	xdef	_LerLDR
4845                     	xdef	_Disparo
4846                     	xdef	_VerificaLuminosidade
4847                     	xdef	_VerificaAjusteFotocelula
4848                     	xdef	_VerificaAjusteTempo
4849                     	xdef	_VerificaAjusteSensibilidade
4850                     	xdef	_VerificaPiroSensor
4851                     	xdef	_AD_Foto
4852                     	xdef	_Sl
4853                     	xdef	_temp
4854                     	xdef	_Pinf
4855                     	xdef	_Psup
4856                     	xdef	_Piro
4857                     	xdef	_Lux
4858                     	xdef	_Escuridade
4859                     	xdef	_lumi
4860                     	xdef	_g
4861                     	xdef	_tp
4862                     	xdef	_Ajuste_Fot
4863                     	xref.b	_cnt
4864                     	xref	_TIM4_ClearFlag
4865                     	xref	_TIM4_ITConfig
4866                     	xref	_TIM4_Cmd
4867                     	xref	_TIM4_TimeBaseInit
4868                     	xref	_GPIO_Init
4869                     	xref	_FLASH_GetFlagStatus
4870                     	xref	_FLASH_SetProgrammingTime
4871                     	xref	_FLASH_Unlock
4872                     	xref	_CLK_HSIPrescalerConfig
4873                     	xref	_ADC1_GetFlagStatus
4874                     	xref	_ADC1_GetConversionValue
4875                     	xref	_ADC1_StartConversion
4876                     	xref	_ADC1_ConversionConfig
4877                     	xref	_ADC1_Cmd
4896                     	end
