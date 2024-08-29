org 256
.data 
    dieci db 10
    var db 2
    
    errore db "Errore nel calcolo, riavviare programma" , "$" 
    
    inserisciX db "X: ", "$"
    X dw ?
    Y dw ?
    XS dw ?
    YS dw ?
    inserisciY db "Y: ", "$"
    negativo db "Pos-> 1 / Neg -> 0 :", "$"  
    
    nord db "Nord" , "$"
    est db "Est" , "$"
    sud db "Sud" , "$"
    ovest db "Ovest" , "$"
    
.code
    MOV CX, 0002h
    JMP switchs

error:
    MOV AX,0003h
    INT 10h
    LEA DX, errore
    MOV AX, 00h
    MOV AH, 09h
    INT 21h
exit:  
    MOV AX, 4C00h
    INT 21h
       
sommacoordinata:
    INC BL
    CMP var, 01
    JE Xsomma
    JMP Ysomma

coordinata:
    MOV CL, BH  
    CMP CL, BL
    JE switch
    POP AX
    MOV CH, 00h

ciclo:
    CMP CH, BL
    JE sommacoordinata
    JMP X10
    
X10:
    MUL dieci
    INC CH
    JMP ciclo 
    
     
Xsomma:
    ADD X, AX
    JMP coordinata

Ysomma:
    ADD Y, AX
    JMP coordinata        
           
           
switch:
    MOV CX, 0000h
    MOV BX, 0000h
    CMP var, 02
    JE Xoutput
    CMP var, 01
    JE Youtput
    CMP var, 00
    JE max
    
input:
    MOV AX, 0000h
    INT 16h 
    CMP AL, 0Dh
    JE coordinata
    CMP AL, 08h
    JE backspace
    MOV AH, 0Eh
    INT 10h      
    SUB AL, 30h
    MOV AH, 00h
    PUSH AX
    INC BH
    JMP input

backspace:
    POP AX
    DEC BH
    PUSH BX
    MOV BX, 0000h
    MOV AX, 0300h
    INT 10h
    DEC DL
    MOV AX, 0200h
    INT 10h
    MOV AX, 0E00h
    INT 10h
    MOV AX, 0300h
    INT 10h
    DEC DL
    MOV AX, 0200h
    INT 10h
    POP BX
    JMP input 
    
Xoutput:
    MOV AX,0003h
    INT 10h
    LEA DX, inserisciX
    MOV AX, 00h
    MOV AH, 09h
    INT 21h
    DEC var    
    JMP input

Youtput:
    MOV AX,0003h
    INT 10h
    LEA DX, inserisciY
    MOV AX, 00h
    MOV AH, 09h
    INT 21h
    DEC var         
    JMP input
    
max:
    CALL reset
    MOV AX, X 
    MOV BX, Y
    CMP AX, BX
    JBE setupX
    CMP BX, AX
    JB setupY
    JMP error

setupX:
    MOV AX, X
    MOV CX, Y
    JMP X2
 
setupY:
    MOV AX, Y
    MOV CX, X
    JMP X2
    
X2: 
    MOV BX, 0002h
    MUL BX
    
max2:
    CMP AX, CX
    JC monocoordinata
    JNC bicoordinata
    JMP error

monocoordinata:
    MOV AX, CX
    MOV DX, X
    CMP AX, DX
    JNE puntodiverso
    JE puntouguale 
                          
bicoordinata:
    CALL reset
    MOV CX, 0002h
    MOV AX, XS
    MOV BX, YS
    JMP stampaY
   
puntouguale:
    CALL reset
    CALL cancella
    MOV CX, 0001h
    JMP stampaX
            
puntodiverso:
    CALL reset
    CALL cancella
    MOV CX, 0001h
    JMP stampaY      

stampaX:
    MOV AX, XS
    CMP AX, 0001h
    JE Xest
    JNE Xovest
         
stampaY:
    MOV BX, YS
    CMP BX, 0001h
    JE Ysud
    JNE Ynord

Xest:
    LEA DX, est
    MOV AX, 00h
    MOV AH, 09h
    INT 21h
    JMP exit

Xovest:
    LEA DX, ovest
    MOV AX, 00h
    MOV AH, 09h
    INT 21h
    JMP exit

Ysud:
    CALL cancella
    LEA DX, sud
    MOV AX, 00h
    MOV AH, 09h
    INT 21h
    CMP CX, 0001h
    JE exit
    MOV AX, 0E2Dh
    INT 10h
    JNE stampaX

Ynord:
    CALL cancella
    LEA DX, nord
    MOV AX, 00h
    MOV AH, 09h
    INT 21h
    CMP CX, 0001h
    JE exit
    MOV AX, 0E2Dh
    INT 10h
    JNE stampaX

switchs:
    MOV BX, 0000h
    CMP CX, 02
    JE Xsegno
    CMP CX, 01
    JE Ysegno
    CMP CX, 00
    JE switch

segno:
    MOV AX, 0000h
    INT 16h
    MOV AH, 0Eh
    INT 10h      
    SUB AL, 30h
    CMP CX, 01h
    JE segnoX
    CMP CX, 00h
    JE segnoY

segnoX:
    MOV AH, 00h
    MOV XS, AX
    JMP switchs 
    
segnoY:
    MOV AH, 00h
    MOV YS, AX
    JMP switchs    

Ysegno:
    MOV AX,0003h
    INT 10h
    LEA DX, inserisciY
    MOV AX, 00h
    MOV AH, 09h
    INT 21h
    LEA DX, negativo
    MOV AX, 00h
    MOV AH, 09h
    INT 21h
    DEC CX
    JMP segno
    
Xsegno:
    MOV AX,0003h
    INT 10h
    LEA DX, inserisciX
    MOV AX, 00h
    MOV AH, 09h
    INT 21h
    LEA DX, negativo
    MOV AX, 00h
    MOV AH, 09h
    INT 21h
    DEC CX
    JMP segno

cancella PROC
    MOV AX,0003h
    INT 10h
    RET
cancella ENDP
    
reset PROC
    MOV AX, 0000h
    MOV BX, 0000h
    MOV CX, 0000h
    MOV DX, 0000h
    RET
reset ENDP