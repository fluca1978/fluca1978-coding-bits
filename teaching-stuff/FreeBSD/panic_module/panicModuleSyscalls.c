#include <panicModuleSyscalls.h>    /* syscall declaration and arguments */
#include <panicModule.h>            /* initialization module variable */


#ifdef _MALLOC_ARGS_
#include <sys/param.h>
#include <sys/malloc.h>
#include <sys/kernel.h>
#endif //_MALLOC_ARGS_

/**
 * The module will use a global variable to handle the initialization
 * of the module itself.
 */

extern panic_module_argv_t* moduleInitializationData;


/*---------------------------------------------------------------------------------*/
/*-------------------- SYSTEM CALLS TO USE IN THE MODULE --------------------------*/
/*---------------------------------------------------------------------------------*/



#ifdef _MALLOC_ARGS_

static MALLOC_DEFINE( M_PANIC_MEMORY, "mkdir-path", "Argument to the mkdir system call" );
#endif //_MALLOC_ARGS_





int panicable_mkdir( struct thread *thread,
		     struct mkdir_args *uap 
		     )
{
  /* a flag to indicate if should generate a panic or not */
  int shouldPanic = 0;

#ifdef _LOCAL_PATH_

  char localPath[ 255 ];
  char *localPathPointer;

  /* zero fill the memory */
  memset( localPath, 0, 255 );

  /* copy the mkdir path to a local variable, so it will be available
     when using the debugger */
  strcpy( localPath, uap->path );

  /* copy also the pointer, to see the difference in the debugger */
  localPathPointer = uap->path;

#endif /* _LOCAL_PATH */


#ifdef _MALLOC_ARGS_
  char *kPath = malloc( strlen( uap->path ) + 1 , M_PANIC_MEMORY, M_NOWAIT | M_ZERO );
  

  // copy the uap into the kernel version
  copyinstr( uap->path, kPath, strlen( uap->path ), NULL );
#endif //_MALLOC_ARGS_



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

#ifdef _MALLOC_ARGS_
    /* since the free does not zeroes the memory, do it manually
       to protect sensible data */
    memset( localPathPointer, 0, strlen( uap->path ) + 1 );
    free( localPathPointer, M_PANIC_MEMORY );
#endif //_MALLOC_ARGS_



  /* should we call the standard mkdir or panic? */
  if( ! shouldPanic ){
    /* ok, do a regular call */
    return sys_mkdir( thread, uap );
  }
  else{
    /*  be polite, and sync dirty buffers  */
    sys_sync( thread, NULL );
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

#ifdef _LOCAL_PATH_

  char localPath[ 255 ];

  /* zero fill the memory */
  memset( localPath, 0, 255 );

  /* copy the mkdir path to a local variable, so it will be available
     when using the debugger */
  strcpy( localPath, uap->path );
#endif /* _LOCAL_PATH */

  


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
    return sys_open( thread, uap );
  }
  else{
    /*  be polite, and sync dirty buffers  */
    sys_sync( thread, NULL );
    panic( "Generating a panic from open system call!" );
    return shouldPanic; /* should never get here, just to keep quite the compiler */
  }

  
}








/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/
