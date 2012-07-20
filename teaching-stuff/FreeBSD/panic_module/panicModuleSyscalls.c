#include <panicModuleSyscalls.h>    /* syscall declaration and arguments */
#include <panicModule.h>            /* initialization module variable */


/**
 * The module will use a global variable to handle the initialization
 * of the module itself.
 */

extern panic_module_argv_t* moduleInitializationData;


/*---------------------------------------------------------------------------------*/
/*-------------------- SYSTEM CALLS TO USE IN THE MODULE --------------------------*/
/*---------------------------------------------------------------------------------*/


int panicable_mkdir( struct thread *thread,
		     struct mkdir_args *uap 
		     )
{
  /* a flag to indicate if should generate a panic or not */
  int shouldPanic = 0;

  /* check if the path for the mkdir call
     is contained into one of the panic paths defined
     at the time of module load */
  for( int i = 0; 
       moduleInitializationData != NULL && i < moduleInitializationData->count;
       i++ ){
    if( strstr( uap->path, moduleInitializationData->names[ i ] ) != NULL ){
      /* the path contains a panicying word! */
      shouldPanic = 1;
      uprintf( "\nThe path [%s] will generate a panic, it contains panic word {%s (index %d)}\n", 
	       uap->path, 
	       moduleInitializationData->names[ i ],
	       i );
      break;
    }
  }

  /* should we call the standard mkdir or panic? */
  if( ! shouldPanic ){
    /* ok, do a regular call */
    return mkdir( thread, uap );
  }
  else{
    panic( "Generating a panic from mkdir system call!" );
    return shouldPanic; /* should never get here, just to keep quite the compiler */
  }

  
}






/*----------------------------------------------------------------------------------*/

int panicable_open(  struct thread    *thread,
		     struct open_args *uap 
		     )
{
  /* a flag to indicate if should generate a panic or not */
  int shouldPanic = 0;

  


  /* check if the path for the open system call
     is contained into one of the panic paths defined
     at the time of module load, and if so check also the
     opening flags to see if the file is going to be opened
     for write
  */
  for( int i = 0; 
       moduleInitializationData != NULL && i < moduleInitializationData->count;
       i++ ){
    if( strstr( uap->path, moduleInitializationData->names[ i ] ) != NULL 
	&& (  (uap->flags & O_WRONLY) == O_WRONLY 
	      || (uap->flags & O_RDWR) == O_RDWR )
	){
      /* the path contains a panicying word, and the file is being opened for writing! */
      shouldPanic = 1;
      uprintf( "\nThe path [%s] will generate a panic, it contains panic word {%s (index %d)} and flags %d\n", 
	       uap->path, 
	       moduleInitializationData->names[ i ],
	       i,
	       uap->flags);
      break;
    }
  }

  /* should we call the standard open or panic? */
  if( ! shouldPanic ){
    /* ok, do a regular call */
    return open( thread, uap );
  }
  else{
    panic( "Generating a panic from open system call!" );
    return shouldPanic; /* should never get here, just to keep quite the compiler */
  }

  
}








/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/
