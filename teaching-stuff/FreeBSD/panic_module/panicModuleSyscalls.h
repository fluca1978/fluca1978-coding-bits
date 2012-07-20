#ifndef _PANIC_MODULE_SYSCALLS_H_
#define _PANIC_MODULE_SYSCALLS_H_

#include <sys/param.h>
#include <sys/module.h>
#include <sys/kernel.h>
#include <sys/types.h>
#include <sys/systm.h>
#include <sys/proc.h>
#include <sys/syscall.h>
#include <sys/sysproto.h>
#include <sys/sysent.h>
#include <sys/fcntl.h>



/**
 * A system call that wraps the mkdir one and that is able to generate
 * a system panic if the arguments to mkdir (in particular the path)
 * match a panic condition (i.e., contain a word that is listed as
 * panic one - see the module initialization).
 *
 * \param thead a pointer to the current thread executing the system call
 * \param uap a pointer to the mkdir arguments
 * \returns the exit code of the original mkdir system call or nothing if
 * the system gets paniced (the method does not return).
 */
int panicable_mkdir( struct thread *thread,
		     struct mkdir_args *uap 
		     );




/**
 * Define the panicable mkdir system call.
 * The struct contains the number of arguments used for the system call
 * (i.e., size of arguments over the size of the registers = number
 * of the registers) as well as the method to call to execute the 
 * system call. The structure contains also some other initialization stuff
 * that is copied by sys/init_sysent.c
 */
struct sysent panicable_mkdir_sysent_definition = {
  (sizeof(struct mkdir_args) / sizeof(register_t)), /* same AS(name) from init_sysent.c */
  (sy_call_t *) panicable_mkdir,
  AUE_MKDIR, 
  NULL, 
  0, 
  0, 
  0
};

/**
 * A struct used to keep the data of the original mkdir system call,
 * so that is is possible to switch back to the original system call
 * once the module is unloaded.
 */
struct sysent clean_mkdir_sysent_definition = {
  (sizeof(struct mkdir_args) / sizeof(register_t)), /* same AS(name) from init_sysent.c */
  NULL,
  AUE_MKDIR, 
  NULL, 
  0, 
  0, 
  0
};





/**
 * A system call that wraps the open one and that is able to generate
 * a system panic if the arguments to open (i.e., the path and the
 * opening mode) match a condition:
 * - the path is contained in the names of the module initialization
 * panic list names;
 * - the file is opened in write mode
 *
 *
 * \param thead a pointer to the current thread executing the system call
 * \param uap a pointer to the open arguments
 * \returns the exit code of the original open system call or nothing if
 * the system gets paniced (the method does not return).
 */
int panicable_open(  struct thread    *thread,
		     struct open_args *uap 
		     );



/**
 * Define the panicable open system call.
 * The struct contains the number of arguments used for the system call
 * (i.e., size of arguments over the size of the registers = number
 * of the registers) as well as the method to call to execute the 
 * system call. The structure contains also some other initialization stuff
 * that is copied by sys/init_sysent.c
 */
struct sysent panicable_open_sysent_definition = {
  (sizeof(struct open_args) / sizeof(register_t)), /* same AS(name) from init_sysent.c */
  (sy_call_t *) panicable_open,
  AUE_OPEN_RWTC, 
  NULL, 
  0, 
  0, 
  0
};

/**
 * A struct used to keep the data of the original open system call,
 * so that is is possible to switch back to the original system call
 * once the module is unloaded.
 */
struct sysent clean_open_sysent_definition = {
  (sizeof(struct open_args) / sizeof(register_t)), /* same AS(name) from init_sysent.c */
  NULL,
  AUE_OPEN_RWTC, 
  NULL, 
  0, 
  0, 
  0
};





#endif
