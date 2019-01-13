%{
	#include<stdio.h>
	#include<string.h>
	int yylex();
	int yyerror(const char* message);
	extern char *message;
	extern int lineNumber;
	extern int columnNumber;

	class Simbol
	{
		char *nume;
		int valoare;
		int stare;
		Simbol* urmator; 	
	public:
		static Simbol* cap;
		static Simbol* coada;
		
		Simbol();
		Simbol(char *_nume,int _valoare);
		int GetStare(char *_nume);	
		void Adaugare(char *_nume,int _stare);
		int GetValoare(char *_nume);
		void SetValoare(char* _nume,int _valoare);
	};

	Simbol* Simbol::cap;
	Simbol* Simbol::coada;
	
	Simbol::Simbol()
	{
		Simbol::cap=NULL;
		Simbol::coada=NULL;
	}	
	Simbol::Simbol(char *_nume,int _stare)
	{
		this->nume=new char[strlen(_nume)+1];
		strcpy(nume,_nume);

		this->stare=_stare;
		this->urmator=NULL;
	}
	
	void Simbol::Adaugare(char *_nume,int _stare)
	{
		
		Simbol* element_nou=new Simbol(_nume,_stare);

		if(cap==NULL)
		{
			Simbol::cap=element_nou;
			Simbol::coada=element_nou;
		}
		else
		{
			Simbol::coada->urmator=element_nou;
			Simbol::coada=element_nou;
		}

		return;
	}

	int Simbol::GetStare(char *_nume)
	{
		Simbol* aux=Simbol::cap;
		while(aux!=NULL)
		{
			if(strcmp(aux->nume,_nume)==0)
				switch(aux->stare)
				{
					case 0:	
						{
							return 0;
							break;
						}

					case 1:	
						{
							return 1;
							break;
						}

					default:
						break;
				}
			aux=aux->urmator;
		}
		return 2;
	}
	
	int Simbol::GetValoare(char *_nume)
	{
		Simbol* aux=Simbol::cap;
		while(aux!=NULL)
		{
			if(strcmp(aux->nume,_nume)==0)
				return aux->valoare;
		}
	}

	void Simbol::SetValoare(char* _nume,int _valoare)
	{
		Simbol* aux=Simbol::cap;
		while(aux!=NULL)
		{
			if(strcmp(aux->nume,_nume)==0)
				aux->valoare=_valoare;
		}
	}
		
	Simbol* simbol=NULL;

%}

%union { char* nume; int valoare; }

%locations

%token TOK_PLUS TOK_MINUS TOK_MULTIPLY TOK_DIVIDE TOK_LEFT TOK_RIGHT TOK_PROGRAM TOK_VAR TOK_BEGIN TOK_END TOK_DOT TOK_ASSIGN TOK_TYPE TOK_READ TOK_WRITE TOK_FOR TOK_DO TOK_TO
%token  TOK_NUMBER
%token  TOK_VARIABLE


%start program

%%
program : TOK_PROGRAM name 
	      TOK_VAR 
		  declaration_list 
		  begin
		  instruction_list
		  TOK_END TOK_DOT   
 ;
name : TOK_VARIABLE
	 ;
declaration_list : declaration
				 |
				 declaration_list ';' declaration	
				 |
				 error TOK_BEGIN 
				 |
				 error ';' declaration 
				 ;
declaration : variable_list ':' TOK_TYPE
			;
variable_list : TOK_VARIABLE 						
			  | 
			  variable_list ',' TOK_VARIABLE 		
			  ;	
begin : TOK_BEGIN
	  |
	  error instruction_list


instruction_list : instruction
		     |
	         instruction_list ';' instruction         
	         |
	         error ';' instruction {yyerrok; yyclearin;}
	         ;
instruction : assign
			|
			read
			|
			write
			|
			for		
			;
assign : TOK_VARIABLE TOK_ASSIGN expression 
	    |
	    error expression 
	    ;
expression : term					
		   |
		   expression TOK_PLUS term		
		   |
		   expression TOK_MINUS term	
		   ;
term : factor						
	 |
	 term TOK_MULTIPLY factor		
	 |
	 term TOK_DIVIDE factor			
		 ;
factor : TOK_VARIABLE				
	   |
	   TOK_NUMBER				
	   |
	   TOK_LEFT expression TOK_RIGHT 
	   ;
read : TOK_READ TOK_LEFT variable_list TOK_RIGHT
	 ;
write : TOK_WRITE TOK_LEFT variable_list TOK_RIGHT 
	  ;
for : TOK_FOR index_range TOK_DO body
	|
	error TOK_END 
	;
index_range : TOK_VARIABLE TOK_ASSIGN expression TOK_TO expression
			;
body : instruction
     |
     TOK_BEGIN instruction_list TOK_END 
     |
     error TOK_BEGIN instruction
     ;

%%
int main()
{
	yyparse();
	return 0;
}

int yyerror(const char* message)
{
	printf("Error:%s \n",message);
	return 1;	
}

