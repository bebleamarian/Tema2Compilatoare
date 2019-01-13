%{
	#include "e.tab.h"
	extern int yyerror(const char* message);
	int lineNumber=1;
	int columnNumber=1;
	char message[200];	
%}

%%
"+"						{ columnNumber++; return TOK_PLUS; }
"-"						{ columnNumber++; return TOK_MINUS; }
"*"						{ columnNumber++; return TOK_MULTIPLY; }
"DIV"		    		{ columnNumber+=strlen(yytext); return TOK_DIVIDE; }
"("						{ columnNumber++; return TOK_LEFT; }
")"						{ columnNumber++; return TOK_RIGHT; }
";"						{ columnNumber++; return ';'; }
":"						{ columnNumber++; return ':'; }
","						{ columnNumber++; return ','; }
":="		  		    { columnNumber+=strlen(yytext); return TOK_ASSIGN; }
"PROGRAM"				{ columnNumber+=strlen(yytext); return TOK_PROGRAM; }
"VAR"					{ columnNumber+=strlen(yytext); return TOK_VAR;}
"BEGIN"					{ columnNumber+=strlen(yytext); return TOK_BEGIN;}
"END"					{ columnNumber+=strlen(yytext); return TOK_END;}
"."						{ columnNumber+=strlen(yytext); return TOK_DOT;}	
"INTEGER"				{ columnNumber+=strlen(yytext); return TOK_TYPE;}			
"READ"					{ columnNumber+=strlen(yytext); return TOK_READ;}
"WRITE"					{ columnNumber+=strlen(yytext); return TOK_WRITE;}
"FOR"					{ columnNumber+=strlen(yytext); return TOK_FOR;}
"DO"					{ columnNumber+=strlen(yytext); return TOK_DO;}
"TO"					{ columnNumber+=strlen(yytext); return TOK_TO;}
[a-zA-Z][a-zA-Z0-9]*    { columnNumber+=strlen(yytext); yylval.nume=new char[strlen(yytext)+1]; memcpy(yylval.nume,yytext,strlen(yytext)+1); return TOK_VARIABLE;}
0|[1-9][0-9]*			{ columnNumber+=strlen(yytext); yylval.valoare=atoi(yytext); return TOK_NUMBER;}
[ ]              	    { columnNumber++; }
\r\n 					{ lineNumber++; columnNumber=1; }
\t						{ columnNumber++;}
\n 						{ lineNumber++; columnNumber=1; }
.						{ columnNumber++; sprintf(message," lexical error"); yyerror(message);}

%%
