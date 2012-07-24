#ifndef  _PANIC_MODULE_H_
#define  _PANIC_MODULE_H_ 


/**
 * A struct that represents module arguments.
 * This module accepts only one argument, that includes
 * a list of names that will generate the panic when the user
 * tries to write them on the filesystem.
 * The argument therefore is defined as a list (array) of strings
 * and a counter that expresses how many of them must be used.
 */
typedef struct panic_module_arguments{
  int count;      /* how many names are there */
  char* names[];  /* list of names */
} panic_module_argv_t;


#endif
