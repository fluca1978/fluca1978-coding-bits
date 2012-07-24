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








#endif
