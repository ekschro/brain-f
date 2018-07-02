// interpreter.asm
// Name: Ericsson Schroeter
// Date: Novemeber 23, 2016
// CSE 2421 5:20 PM
// oxo5194c41

#include <stdio.h>

#define ARRAY_SIZE 30000        //generic array size

//global variables
char BY[ARRAY_SIZE] = {0};      //Array for program to generate
int l = 0;                      //nest array index
int loop = 0;                   //unique loop id
int nest[ARRAY_SIZE] = {0};     //nested loop array

//prototypes
void readIn();
void evalInstr(char c);

int main(void) {
                                //Read in BY prgram into array
    readIn();
                                //Print out proper Assembly heading
    printf("USE32\n\n");
    printf("section .data\n\n");
    printf("stack   : times 1000 dd 0\n\n");
    printf("ma	: times 30000 db 0\n");
    printf("pa	: times 30000 db 0\n");
    printf("dp	: times 30000 dd 0\n");
    printf("ip	: times 30000 dd 0\n\n");
    printf("section .text\n\nglobal _start\n\n_start:\n\n");
    
    int i = 0;                  //varible i for array index
    
    while (BY[i] != 0) {        //while element of array isn't NUL
        evalInstr(BY[i]);       //Evaluate BY instruction
        i++;                    //increment i
    }
    
    printf("xor ebx, ebx\n");   //print proper assembly footer
    printf("mov eax, 1\n");
    printf("int 80h\n\n");
    
}

void readIn() {
    int i = 0;
    
    scanf("%c", (BY+i));        //input initial BY instruction
    
    while (BY[i] != '#') {      //while element is not '#'
        i++;                    //increment i
        scanf("%c", (BY+i));    //input BY instruction
    }

}


void evalInstr(char c) {
    
    switch (c) {                //switch prints out appropriate assembly for
        case '>':               //current instructon
            printf("inc dword [dp]\n\n");
            break;
            
        case '<':
            printf("dec dword [dp]\n\n");
            break;
            
        case '+':
            printf("mov ebx, [dp]\n");
            printf("inc byte [ma+ebx]\n\n");
            break;
            
        case '-':
            printf("mov ebx, [dp]\n");
            printf("dec byte [ma+ebx]\n\n");
            break;
            
        case '.':
            printf("mov ebx, dword [dp]\n");
            printf("mov ecx, dword [ma+ebx]\n");
            printf("push ecx\n");
            printf("mov eax, 4\n");
            printf("mov ebx, 1\n");
            printf("mov ecx, esp\n");
            printf("mov edx, 1\n");
            printf("int 80h\n");
            printf("add esp, 4\n\n");
            break;
            
        case ',':
            printf("mov eax, 3\n");
            printf("mov ebx, 0\n");
            printf("sub esp, 1\n");
            printf("mov ecx, esp\n");
            printf("mov edx, 1\n");
            printf("int 80h\n");
            printf("xor eax, eax\n");
            printf("mov al, byte [esp]\n");
            printf("add esp, 1\n\n");
            break;
            
        case '[':
            printf("loop%d:\n", loop);
            printf("mov ebx, [dp]\n");
            printf("mov cl, [ma+ebx]\n");
            printf("cmp cl, byte 0\n");
            printf("je false%d\n\n", loop);
            nest[l] = loop;
            loop++;
            l++;
            
            break;
            
        case ']':

                printf("jmp loop%d\n", nest[l-1]);
                printf("false%d:\n\n", nest[l-1]);
                l--;
            
            break;
        default:
            
            break;
    }
}
