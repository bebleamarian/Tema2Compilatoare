%{
	#include<stdio.h>
	#include<string.h>
	int yylex();
	int yyerror(const char* message);
	extern char *message;
	extern int lineNumber;
	extern int columnNumber;
	int d=0;

	class TVAR
	{
	     char* nume;
	     int valoare;
	     TVAR* next;
	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1);
	     TVAR();
	     int exists(char* n);
         void add(char* n, int v = -1);
         int getValue(char* n);
	     void setValue(char* n, int v);
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n, int v)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->valoare = v;
	 this->next = NULL;
	}

	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	}

	int TVAR::exists(char* n)
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	      return 0;
            tmp = tmp->next;
	  }
	  return 1;
	 }

         void TVAR::add(char* n, int v)
	 {
	   TVAR* elem = new TVAR(n, v);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	 }

         int TVAR::getValue(char* n)
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      return tmp->valoare;
	     tmp = tmp->next;
	   }
	   return -1;
	  }

	  void TVAR::setValue(char* n, int v)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		tmp->valoare = v;
	      }
	      tmp = tmp->next;
	    }
	  }

	TVAR* ts = NULL;
	

%}

%union { char* nume; int valoare; }

%locations

%token TOK_PLUS TOK_MINUS TOK_MULTIPLY TOK_DIVIDE TOK_LEFT TOK_RIGHT TOK_PROGRAM TOK_VAR TOK_BEGIN TOK_END TOK_DOT TOK_ASSIGN TOK_TYPE TOK_READ TOK_WRITE TOK_FOR TOK_DO TOK_TO
%token  TOK_NUMBER
%token <nume> TOK_VARIABLE


%start program

%%
program : TOK_PROGRAM name 
	      TOK_VAR 
		  mainbody
		  |
		  error mainbody  
 ;
name : TOK_VARIABLE
	 ;
mainbody : declaration_list  	  { d=1;}
		  begin
		  instruction_list		  
		  TOK_END TOK_DOT
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
variable_list : TOK_VARIABLE 				{
												if(d==0)
			  										if(ts==NULL)
			  										{	ts=new TVAR();
			  											ts->add($1,0);
			  										}
			  										else
			  										{
			  											if(ts->exists($1)==1)
			  											{
			  												ts->add($1,0);
			  											}
			  											else
			  												{
			  													yyerror("semantic error Multiple declarations");
			  												}
			  										}
			  									if(d!=0)
			  									 	if(ts==NULL)
			  									 		yyerror("semantic error Undeclared identifier");
			  									 	else
			  									 		{
			  									 			if(ts->exists($1)==1)
			  									 				yyerror("semantic error Variable being used without being initialized");

			  											}
			  									
			  								}
			  | 
			  variable_list ',' TOK_VARIABLE 	{
												if(d==0)
			  										if(ts==NULL)
			  										{	ts=new TVAR();
			  											ts->add($3,0);
			  										}
			  										else
			  										{
			  											if(ts->exists($3)==1)
			  											{
			  												ts->add($3,0);
			  											}
			  											else
			  												{
			  													yyerror("Error : semantic error Multiple declarations");
			  												}
			  										}
			  									if(d!=0)
			  									 	if(ts==NULL)
			  									 		yyerror("semantic error Undeclared identifier");
			  									 	else
			  									 		{
			  									 			if(ts->exists($3)==1)
			  									 				yyerror("semantic error Variable being used without being initialized");

			  									 		}
			  									 	
			  									}
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
assign : TOK_VARIABLE TOK_ASSIGN expression  		{
														if(ts==NULL)
			  									 			yyerror("semantic error Undeclared identifier");

			  									 		else
			  									 		{
			  									 			if(ts->exists($1)==1)
			  									 					yyerror("semantic error Undeclared identifier");
			  									 			else
			  									 				ts->setValue($1,1);
			  									 				
														}
													}
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
factor : TOK_VARIABLE							{
														if(ts==NULL)
			  									 			yyerror("semantic error Undeclared identifier");

			  									 		else
			  									 		{
			  									 			if(ts->exists($1)==1)
			  									 				yyerror("semantic error Undeclared identifier");
			  									 			else
			  									 				if(ts->exists($1)==0 && ts->getValue($1)==0)
			  									 					yyerror("semantic error Variable being used without being initialized");

														}
												}
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
	printf("Error:%s %d:%d\n",message,lineNumber,columnNumber);
	return 1;	
}

