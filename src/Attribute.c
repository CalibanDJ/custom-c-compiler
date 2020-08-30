#include "Attribute.h"
#include "Table_des_symboles.h"
#include <stdlib.h>
#include <stdio.h>

/* allocate new attribute */
attribute new_attribute () {
  attribute r;
  r  = malloc (sizeof (struct ATTRIBUTE));
  r->nb_ref = 0;
  return r;
};

/* retrieve good type of attribute with operation + (and cast + retrieve operands if needed) */
attribute plus_attribute(attribute x, attribute y, FILE * header, FILE * prog) {
  attribute r = new_attribute();
  if (x->type_val == INT && y->type_val == INT)
    {
      /* retrieve registers of differents operands */
      r-> reg_left_operand = x->reg_number;
      r-> reg_right_operand = y->reg_number;
      r->type_val = INT;
      r->int_val = x->int_val + y->int_val;
    }
  else if (x->type_val == INT && y->type_val == FLOAT)
    {
      r->type_val = FLOAT;

      /* cast register in float in another register */
      int reg_cast = new_number_reg();
      fprintf(header, "float r%d;\n", reg_cast);
      fprintf(prog, "r%d = (float) r%d;\n", reg_cast, x->reg_number);

      r-> reg_left_operand = reg_cast;
      r-> reg_right_operand = y->reg_number;
      r->float_val = x->int_val + y->float_val;
    }
  else if (y->type_val == INT && x->type_val == FLOAT)
    {
      r->type_val = FLOAT;

      /* cast register in float in another register */
      int reg_cast = new_number_reg();
      fprintf(header, "float r%d;\n", reg_cast);
      fprintf(prog, "r%d = (float) r%d;\n", reg_cast, y->reg_number);

      r-> reg_left_operand = x->reg_number;
      r-> reg_right_operand = reg_cast;

      r->float_val = y->int_val + x->float_val;
    }
  else if (x->type_val == FLOAT && y->type_val == FLOAT)
    {
      r-> reg_left_operand = x->reg_number;
      r-> reg_right_operand = y->reg_number;
      r->type_val = FLOAT;
      r->float_val = x->float_val + y->float_val;
    }
  else
    perror("Wrong type for operand +");
  return r;
};

attribute mult_attribute(attribute x, attribute y, FILE * header, FILE * prog){
  attribute r = new_attribute();
  if (x->type_val == INT && y->type_val == INT)
    {
      r-> reg_left_operand = x->reg_number;
      r-> reg_right_operand = y->reg_number;
      r->type_val = INT;
      r->int_val = x->int_val * y->int_val;
    }
  else if (x->type_val == INT && y->type_val == FLOAT)
    {
      r->type_val = FLOAT;

      /* cast register in float in another register */
      int reg_cast = new_number_reg();
      fprintf(header, "float r%d;\n", reg_cast);
      fprintf(prog, "r%d = (float) r%d;\n", reg_cast, x->reg_number);
      r-> reg_left_operand = reg_cast;
      r-> reg_right_operand = y->reg_number;
      r->float_val = x->int_val * y->float_val;
    }
  else if (y->type_val == INT && x->type_val == FLOAT)
    {
      r->type_val = FLOAT;

      /* cast register in float in another register */
      int reg_cast = new_number_reg();
      fprintf(header, "float r%d;\n", reg_cast);
      fprintf(prog, "r%d = (float) r%d;\n", reg_cast, y->reg_number);
      r-> reg_left_operand = x->reg_number;
      r-> reg_right_operand = reg_cast;
      r->float_val = y->int_val * x->float_val;
    }
  else if (x->type_val == FLOAT && y->type_val == FLOAT)
    {
      r-> reg_left_operand = x->reg_number;
      r-> reg_right_operand = y->reg_number;
      r->type_val = FLOAT;
      r->float_val = x->float_val * y->float_val;
    }
  else
    perror("Wrong type for operand *");
  return r;
};

attribute minus_attribute(attribute x, attribute y, FILE * header, FILE * prog){
  attribute r = new_attribute();
  if (x->type_val == INT && y->type_val == INT)
    {
      r-> reg_left_operand = x->reg_number;
      r-> reg_right_operand = y->reg_number;
      r->type_val = INT;
      r->int_val = x->int_val - y->int_val;
    }
  else if (x->type_val == INT && y->type_val == FLOAT)
    {
      r->type_val = FLOAT;

      /* cast register in float in another register */
      int reg_cast = new_number_reg();
      fprintf(header, "float r%d;\n", reg_cast);
      fprintf(prog, "r%d = (float) r%d;\n", reg_cast, x->reg_number);

      r-> reg_left_operand = reg_cast;
      r-> reg_right_operand = y->reg_number;
      r->float_val = x->int_val - y->float_val;
    }
  else if (y->type_val == INT && x->type_val == FLOAT)
    {
      r->type_val = FLOAT;

      /* cast register in float in another register */
      int reg_cast = new_number_reg();
      fprintf(header, "float r%d;\n", reg_cast);
      fprintf(prog, "r%d = (float) r%d;\n", reg_cast, y->reg_number);
      r-> reg_left_operand = x->reg_number;
      r-> reg_right_operand = reg_cast;
      r->float_val = x->float_val - y->int_val;
    }
  else if (x->type_val == FLOAT && y->type_val == FLOAT)
    {
      r-> reg_left_operand = x->reg_number;
      r-> reg_right_operand = y->reg_number;
      r->type_val = FLOAT;
      r->float_val = x->float_val - y->float_val;
    }
  else
    perror("Wrong type for operand -");


  return r;
};

attribute div_attribute(attribute x, attribute y, FILE * header, FILE * prog){
  attribute r = new_attribute();

  if (y == 0)
    {
      perror("Division by 0 is forbidden");
      exit(EXIT_FAILURE);
    }
  else if (x->type_val == INT && y->type_val == INT)
    {
      r->type_val = INT;

      r->reg_left_operand = x->reg_number;
      r->reg_right_operand = y->reg_number;
      r->int_val = x->int_val / y->int_val;
    }
  else if (x->type_val == INT && y->type_val == FLOAT)
    {
      r->type_val = FLOAT;

      /* cast register in float in another register */
      int reg_cast = new_number_reg();
      fprintf(header, "float r%d;\n", reg_cast);
      fprintf(prog, "r%d = (float) r%d;\n", reg_cast, x->reg_number);
      r-> reg_left_operand = reg_cast;
      r-> reg_right_operand = y->reg_number;
      r->float_val = x->int_val / y->float_val;
    }
  else if (y->type_val == INT && x->type_val == FLOAT)
    {
      r->type_val = FLOAT;

      /* cast register in float in another register */
      int reg_cast = new_number_reg();
      fprintf(header, "float r%d;\n", reg_cast);
      fprintf(prog, "r%d = (float) r%d;\n", reg_cast, y->reg_number);
      r-> reg_left_operand = x->reg_number;
      r-> reg_right_operand = reg_cast;
      r->float_val = x->float_val / y->int_val;
    }
  else if (x->type_val == FLOAT && y->type_val == FLOAT)
    {
      r-> reg_left_operand = x->reg_number;
      r-> reg_right_operand = y->reg_number;
      r->type_val = FLOAT;
      r->float_val = x->float_val / y->float_val;
    }
  else
    perror("Wrong type for operand /");
  return r;
};

attribute neg_attribute(attribute x){
  attribute r = new_attribute();

  if (x->type_val == INT)
    {
      r->type_val = INT;
      r->int_val = - (x->int_val);
    }
  else if (x->type_val == FLOAT)
    {
      r->type_val = FLOAT;
      r->float_val = - (x->float_val);
    }
  else
    perror("Wrong type for operand neg");
  return r;
};

/* affection with user variable as : int a = b; */
attribute affect_attribute(attribute x, attribute y, FILE * header, FILE * prog) {
  /* if both variables dont have the same number of references */
  if (x->nb_ref != y->nb_ref)
    perror("Can't affect an expression with different ref number");

  if (x->type_val == INT && y->type_val == INT)
    {
      x->int_val = y->int_val;
      fprintf(prog, "%s = r%d;\n", x->name, y->reg_number);
    }
  /* if both variables are not the same type and if the vasted variable is not a pointer */
  else if (x->type_val == INT && y->type_val == FLOAT && x->nb_ref == 0)
    {
      int reg_cast = new_number_reg();
      fprintf(header, "int r%d;\n", reg_cast);
      fprintf(prog, "r%d = (int) r%d;\n", reg_cast, y->reg_number);
      fprintf(prog, "%s = r%d;\n", x->name, reg_cast);
      x->int_val = y->float_val;
    }
  else if (x->type_val == INT && y->type_val == FLOAT && x->nb_ref != 0)
    perror("Can't cast pointer");
  else if (x->type_val == FLOAT && y->type_val == INT && x->nb_ref == 0)
    {
      int reg_cast = new_number_reg();
      fprintf(header, "float r%d;\n", reg_cast);
      fprintf(prog, "r%d = (float) r%d;\n", reg_cast, y->reg_number);
      fprintf(prog, "%s = r%d;\n", x->name, reg_cast);
      x->float_val = y->int_val;
    }
  else if (x->type_val == FLOAT && y->type_val == INT && x->nb_ref != 0)
    perror("Can't cast pointer");
  else if (x->type_val == FLOAT && y->type_val == FLOAT)
     {
      x->float_val = y->float_val;
      fprintf(prog, "%s = r%d;\n", x->name, y->reg_number);
    }
  else
    perror("Unhandled affectation types");

  return x;
}

/* unreference of a pointer */
attribute unref_attribute(attribute x) {

  if (x->nb_ref == 0)
    perror("Cant unref non-pointer symbol");

  attribute r = new_attribute();

  r->type_val = x->type_val;
  r->nb_ref = x->nb_ref - 1;

  return r;
}

/* get string type of a given type */
char * get_type_string(type t)
{
  switch (t) {

  case INT:
    return "int";
    break;

  case FLOAT:
    return "float";
    break;

  case VIDE:
    return "void";
    break;

  default:
    fprintf(stderr, "Unknown type\n");}
}

void debug_print(attribute x, FILE * f) {
  if (x->type_val == INT)
    fprintf(f, "printf(\"r%d = %s\", r%d);\n", x->reg_number, "%d\\n", x->reg_number);
  else
    fprintf(f, "printf(\"r%d = %s\", r%d);\n", x->reg_number, "%f\\n", x->reg_number);
}

/* debug function that allows us to get infos on an attribute */
void to_string(attribute x) {
  printf("Name : %s\n",x->name);
  printf("Type value : %s\n",get_type_string(x->type_val));
  switch(x->type_val) {
  case 0:
    printf("int value : %d\n",x->int_val);
    break;
  case 1:
    printf("float value : %f\n",x->float_val);
    break;
  default:
    break;
  }
  printf("reg number : %d\n",x->reg_number);
  printf("reg left operand : %d\n",x->reg_left_operand);
  printf("reg right operand : %d\n",x->reg_right_operand);
  printf("nb ref : %d\n",x->nb_ref);

  return;
}

/* prints the number of ref as stars * */
void fprintf_ref(attribute x, FILE* file) {
  int i;

  if (x->nb_ref == 0) {
    fprintf(file, " ");
    return;
  }

  fprintf(file, " ");
  for(i = 0; i < x->nb_ref; i++)
    fprintf(file,"*");
  fprintf(file, " ");
  return;
}

int new_labelt_number() {
  static int t = 1;
  return t++;
}

int new_labelf_number() {
  static int f = 1;
  return f++;
}

int new_labele_number() {
  static int e = 1;
  return e++;
}

int new_labelif_number() {
  static int i = 1;
  return i++;
}
