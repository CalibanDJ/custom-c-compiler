%code requires{
#include "src/Table_des_symboles.h"
#include "src/Attribute.h"
}

%{

#include <stdio.h>

extern int yylex();
extern int yyparse();

void yyerror (char* s) {
  printf ("%s\n",s);

}

int nb = 1;
FILE * file_h;
FILE * file_c;
%}

%union {
	attribute val;
}
%token <val> NUMI NUMF
%token TINT TFLOAT VOID STRUCT
%token <val> ID
%token AO AF PO PF PV VIR
%token RETURN EQ
%token IF ELSE WHILE
%type <val> type typename vlist vir exp aff pointer did bool_cond else if stat

%token <val> AND OR NOT DIFF EQUAL SUP INF
%token PLUS MOINS STAR DIV
%token DOT ARR

%left DIFF EQUAL SUP INF       // low priority on comparison
%left PLUS MOINS               // higher priority on + -
%left STAR DIV                 // higher priority on * /
%left OR                       // higher priority on ||
%left AND                      // higher priority on &&
%left DOT ARR                  // higher priority on . and ->
%nonassoc UNA                  // highest priority on unary operator

%start prog



%%
//!\\ Grammaire //!\\

prog: block                   {/*printf("yacc %d : Prog -> Block\n", nb++);*/} // Prgm = block de code
;

block: decl_list inst_list     {/*printf("yacc %d : Block -> Decl_list Inst_list\n", nb++);*/} // Block = list de declarations et d'instructions
;

// I. Declarations

decl_list : decl decl_list     {/*printf("yacc %d : Decl_list -> decl decl_list\n", nb++);*/} // Liste de declaration = decl + list decl
|                              {/*printf("yacc %d : Decl_list -> ()\n", nb++);*/} // ou ien (liste vide)
;

decl: var_decl PV              {/*printf("yacc %d : Decl -> var_decl PV\n", nb++);*/} // Declaration = declaration de var + ;
| struct_decl PV               {} // ou declaration de struct + ;
| fun_decl                     {} // ou declaration de function
;

// I.1. Variables
var_decl : type vlist          {/*printf("yacc %d : Var_decl -> type vlist\n", nb++);*/} // Declaration de var = un type + liste de var
;

// I.2. Structures
struct_decl : STRUCT ID struct {} // Declaration struct = struct + identifiant + structure
;

struct : AO attr AF            {} // Structure = { + attribut + }
;

attr : type ID                 {} // Attribut = un type + un identifiant
| type ID PV attr              {} // ou un type + un identifiant + ; + un autre attribut

// I.3. Functions

fun_decl : type fun            {} // Declaration de fonction = un type + function
;

fun : fun_head fun_body        {} // Fonction = en-tete + corps
;

fun_head : ID PO PF            {} // En-tete = Identifiant + ( + )
| ID PO params PF              {} // ou identifiant + ( + parmetres + )
;

params: type ID vir params     {} // Parametre = un type + identifiant + , + parametres
| type ID                      {} // ou un type + identifiant

vlist: did vir vlist            {/*printf("yacc %d : vlist -> did VIR vlist\n", nb++);*/}   // Liste de var = identifiant + , + liste de var
| did                           {/*printf("yacc %d : vlist -> did\n", nb++);*/}                // ou identifiant
;

did: ID                        {$$=$1;/*printf("yacc %d : did -> ID\n", nb++);*/
                                $$->type_val = $<val>0->type_val;
				$$->nb_ref = $<val>0->nb_ref;
                                set_symbol_value($$->name,$$);
				//$1->reg_number = new_number_reg();
				fprintf(file_h, "%s", get_type_string($$->type_val));
				fprintf_ref($$, file_h);
				fprintf(file_h, "%s;\n", $$->name);}

vir : VIR                      {$$=$<val>-1;/*printf("yacc %d : vir -> VIR\n", nb++);*/} // virgule = , ??
;

fun_body : AO block AF         {} // Corps de fct = { block de code }
;

// I.4. Types
type: typename pointer         {$$=$1;
                                $$->nb_ref = $2->nb_ref;
                                /*printf("yacc %d : type -> typename pointer\n", nb++);*/} // type = nom du type + pointeur
| typename                     {$$=$1;
                                /* printf("yacc %d : type -> typename\n", nb++);*/} // ou nom du type
;

typename: TINT                  {$$ = new_attribute(); $$->type_val = INT; /*printf("yacc %d : typename -> TINT\n", nb++);*/} // Nom de type = int
| TFLOAT                        {$$ = new_attribute(); $$->type_val = FLOAT; /*printf("yacc %d : typename -> TFLOAT\n", nb++);*/} // ou float
| VOID                          {$$ = new_attribute(); $$->type_val = VIDE; /*printf("yacc %d : typename -> VOID\n", nb++);*/} // ou void
| STRUCT ID                     {/*printf("yacc %d : typename -> STRUCT ID\n", nb++);*/} // ou struct + identifiant
;

pointer: pointer STAR          {/*printf("yacc %d : pointer -> pointer STAR\n", nb++);*/
                                $$ = $1;
                                $$->nb_ref += 1;} // pointeur = pointeur + *
| STAR                         {/*printf("yacc %d : pointer -> STAR\n", nb++);*/
                                $$ = new_attribute(); $$->nb_ref += 1;} // ou *
;


// II. Intructions
inst_list: inst PV inst_list   {} // Liste d'instructions = instruction + ; + liste d'instructions
| inst
|                              {} // ou instruction
;

inst: exp                     {} // Instruction = expression arithmétique
| AO block AF                 {} // ou { bloc de code }
| aff                         {} // affectation
| ret                         {} // ou return
| cond                        {} // ou condition
| loop                        {} // ou boucle
| PV                          {} // ou ;
;


// II.1 Affectations

aff : ID EQ exp               {$$ = get_symbol_value($1->name);
                               $$ = affect_attribute($$, $3, file_h, file_c);} // affectation = identifiant + = + expression
| exp STAR EQ exp             {} // ou expression + * + = + expression ?????????????
;


// II.2 Return
ret : RETURN exp              {} // Return = return expression
| RETURN PO PF                {} // ou return + ( + )
;

// II.3. Conditionelles
cond : if bool_cond stat else stat     {fprintf(file_c, "lif%d:\n", $2->label_if);
                                        fprintf(file_c, "if (r%d) goto lt%d;\n", $2->reg_number, $2->label_number);
                                        fprintf(file_c, "if (!r%d) goto lf%d;\n", $2->reg_number, $4->label_number);
					fprintf(file_c, "le%d:;\n", $3->label_end);
					/*printf("yacc %d : cond -> if else\n", nb++);*/} // condition = if + expression booleene + instruction
| if bool_cond stat                    {fprintf(file_c, "lif%d:\n", $2->label_if);
                                        fprintf(file_c, "if (r%d) goto lt%d;\n", $2->reg_number, $2->label_number);
                                        fprintf(file_c, "le%d:;\n", $3->label_end);
                                        /*printf("yacc %d : cond -> if\n", nb++);*/} // ou else + instruction
;

stat: AO block AF             {$$ = $<val>0;
                               fprintf(file_c, "goto le%d;\n", $$->label_end);
                               /*printf("yacc %d : stat -> {block}\n", nb++);*/}
;

bool_cond : PO exp PF         {$$ = $2;
                               $$->label_number = new_labelt_number();
			       $$->label_end = new_labele_number();
			       $$->label_if = new_labelif_number();
			       fprintf(file_c, "goto lif%d;\n", $$->label_if);
                               fprintf(file_c, "lt%d:\n", $$->label_number);
			       /*printf("yacc %d : bool_cond -> (exp)\n", nb++);*/} // Expression bool = ( + expression + )
;

if : IF                       {/*printf("yacc %d : if -> IF\n", nb++);*/} // if = mot clé if
;

else : ELSE                   {/*printf("yacc %d : else -> ELSE\n", nb++);*/
                               $$ = new_attribute();
			       $$->label_end = $<val>0->label_end;
                               $$->label_number = new_labelf_number();
                               fprintf(file_c, "lf%d:\n", $$->label_number);} // else pareil que if
;

// II.4. Iterations

loop : while while_cond inst  {} // Boucle = while + epression booleene + instruction
;

while_cond : PO exp PF        {} // pareil que bool_cond ?

while : WHILE                 {} // while = mot clé while
;


// II.3 Expressions
exp
// II.3.0 Exp. arithmetiques
: MOINS exp %prec UNA         {$$ = neg_attribute($2); /*%prec UNA = MOINS exp a la meme prio que UNA cad la plus élevée*/
                               $$->reg_number = new_number_reg();
			       fprintf(file_h, "%s r%d;\n", get_type_string($$->type_val), $$->reg_number);
			       fprintf(file_c, "r%d = - r%d;\n", $$->reg_number, $2->reg_number);
			       debug_print($$, file_c);}
| exp PLUS exp                {$$ = plus_attribute($1, $3, file_h, file_c);
                               $$->reg_number = new_number_reg();
                               fprintf(file_h, "%s r%d;\n", get_type_string($$->type_val), $$->reg_number);
                               fprintf(file_c, "r%d = r%d + r%d;\n", $$->reg_number, $$->reg_left_operand, $$->reg_right_operand);
			       debug_print($$, file_c);}
| exp MOINS exp               {$$ = minus_attribute($1, $3, file_h, file_c);
                               $$->reg_number = new_number_reg();
                               fprintf(file_h, "%s r%d;\n", get_type_string($$->type_val), $$->reg_number);
                               fprintf(file_c, "r%d = r%d - r%d;\n", $$->reg_number, $$->reg_left_operand, $$->reg_right_operand);
			       debug_print($$, file_c);}
| exp STAR exp                {$$ = mult_attribute($1, $3, file_h, file_c);
                               $$->reg_number = new_number_reg();
                               fprintf(file_h, "%s r%d;\n", get_type_string($$->type_val), $$->reg_number);
                               fprintf(file_c, "r%d = r%d * r%d;\n", $$->reg_number, $$->reg_left_operand, $$->reg_right_operand);
			       debug_print($$, file_c);}
| exp DIV exp                 {$$ = div_attribute($1, $3, file_h, file_c);
                               $$->reg_number = new_number_reg();
                               fprintf(file_h, "%s r%d;\n", get_type_string($$->type_val), $$->reg_number);
                               fprintf(file_c, "r%d = r%d / r%d;\n", $$->reg_number, $$->reg_left_operand, $$->reg_right_operand);
			       debug_print($$, file_c);}
| PO exp PF                   {$$ = $2;}
| ID                          {$$ = get_symbol_value($1->name);
                               $$->reg_number = new_number_reg();
                               fprintf(file_h, "%s", get_type_string($$->type_val));
			       fprintf_ref($$, file_h);
			       fprintf(file_h, "r%d;\n", $$->reg_number);
                               fprintf(file_c, "r%d = %s;\n", $$->reg_number, $$->name);}
| NUMI                        {$$ = $1;
                               $$->reg_number = new_number_reg();
                               fprintf(file_h, "int r%d;\n", $$->reg_number);
                               fprintf(file_c, "r%d = %d;\n", $$->reg_number, $$->int_val);}
| NUMF                        {$$ = $1;
                               $$->reg_number = new_number_reg();
                               fprintf(file_h, "float r%d;\n", $$->reg_number);
                               fprintf(file_c, "r%d = %f;\n", $$->reg_number, $$->float_val);} //Precision de la valeur ???

// II.3.1 Déréférencement

| STAR exp %prec UNA          {$$ = unref_attribute($2);
                               $$->reg_number = new_number_reg();
			       	fprintf(file_h, "%s", get_type_string($$->type_val));
				fprintf_ref($$, file_h);
				fprintf(file_h, "r%d;\n", $$->reg_number);
				fprintf(file_c, "r%d = *r%d;\n", $$->reg_number, $2->reg_number);

}
// II.3.2. Booléens

| NOT exp %prec UNA           {$$ = new_attribute();
                               $$->reg_number = new_number_reg();
			       fprintf(file_h, "int r%d;\n", $$->reg_number);
			       fprintf(file_c, "r%d = !r%d;\n", $$->reg_number, $2->reg_number);}
| exp INF exp                 {$$ = new_attribute();
                               $$->reg_number = new_number_reg();
			       fprintf(file_h, "int r%d;\n", $$->reg_number);
			       fprintf(file_c, "r%d = r%d < r%d;\n", $$->reg_number, $1->reg_number, $3->reg_number);}
| exp SUP exp                 {$$ = new_attribute();
                               $$->reg_number = new_number_reg();
			       fprintf(file_h, "int r%d;\n", $$->reg_number);
			       fprintf(file_c, "r%d = r%d > r%d;\n", $$->reg_number, $1->reg_number, $3->reg_number);}
| exp EQUAL exp               {$$ = new_attribute();
                               $$->reg_number = new_number_reg();
			       fprintf(file_h, "int r%d;\n", $$->reg_number);
			       fprintf(file_c, "r%d = r%d == r%d;\n", $$->reg_number, $1->reg_number, $3->reg_number);}
| exp DIFF exp                {$$ = new_attribute();
                               $$->reg_number = new_number_reg();
			       fprintf(file_h, "int r%d;\n", $$->reg_number);
			       fprintf(file_c, "r%d = r%d != r%d;\n", $$->reg_number, $1->reg_number, $3->reg_number);}
| exp AND exp                 {$$ = new_attribute();
                               $$->reg_number = new_number_reg();
			       fprintf(file_h, "int r%d;\n", $$->reg_number);
			       fprintf(file_c, "r%d = r%d && r%d;\n", $$->reg_number, $1->reg_number, $3->reg_number);}
| exp OR exp                  {$$ = new_attribute();
                               $$->reg_number = new_number_reg();
			       fprintf(file_h, "int r%d;\n", $$->reg_number);
			       fprintf(file_c, "r%d = r%d || r%d;\n", $$->reg_number, $1->reg_number, $3->reg_number);}

// II.3.3. Structures

| exp ARR ID                  {}
| exp DOT ID                  {}

| app                         {}
;

// II.4 Applications de fonctions

app : ID PO args PF;

args :  arglist               {}
|                             {}
;

arglist : exp VIR arglist     {}
| exp                         {}
;



%%
int main () {

  file_h = fopen("./test/test.h", "w");
  file_c = fopen("./test/test.c", "w");

  fprintf(file_h, "#ifndef TEST_H\n#define TEST_H\n\n");
  fprintf(file_c, "#include <stdio.h>\n#include \"test.h\"\n\nint main() {\n\n");

  if (file_h == NULL) fprintf(stderr, "Error: Couldnt open test.h file\n");
  if (file_c == NULL) fprintf(stderr, "Error: Couldnt open test.c file\n");

  yyparse ();

  fprintf(file_h, "\n#endif\n");
  fprintf(file_c, "\n}\n");

  fclose(file_h);
  fclose(file_c);

  //show_symbol_table();
}
