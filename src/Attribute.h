/*
 *  Attribute.h
 *
 *  Created by Janin on 10/2019
 *  Copyright 2018 LaBRI. All rights reserved.
 *
 *  Module for a clean handling of attibutes values
 *
 */

#ifndef ATTRIBUTE_H
#define ATTRIBUTE_H

#include <stdio.h>

typedef enum {INT, FLOAT, VIDE} type;


struct ATTRIBUTE {
  char * name;
  int int_val;
  float float_val;
  type type_val;
  int reg_number;
  /* Used in case of cast for arithmetic expressions*/
  int reg_left_operand; 
  int reg_right_operand; 
  /* Count nb of referencing */
  int nb_ref;
  /* label numbers for goto */
  int label_number;
  int label_end;
  int label_if;

  
  /* other attribute's fields can goes here */ 

};

typedef struct ATTRIBUTE * attribute;

attribute new_attribute ();
/* returns the pointeur to a newly allocated (but uninitialized) attribute value structure */

/*attribute new_type_attribute(int t);*/

attribute plus_attribute(attribute x, attribute y, FILE * header, FILE * prog);
attribute mult_attribute(attribute x, attribute y, FILE * header, FILE * prog);
attribute minus_attribute(attribute x, attribute y, FILE * header, FILE * prog);
attribute div_attribute(attribute x, attribute y, FILE * header, FILE * prog);
attribute neg_attribute(attribute x);
attribute affect_attribute(attribute x, attribute y, FILE * header, FILE * prog);
attribute unref_attribute(attribute x);
char * get_type_string(type t);
/* true statement */
int new_labelt_number();
/* false statement */
int new_labelf_number();
/* end of cond */
int new_labele_number();
/* label to goto if */
int new_labelif_number();
void to_string(attribute x);
void fprintf_ref(attribute x, FILE* file);
void debug_print(attribute x, FILE * f);

#endif

