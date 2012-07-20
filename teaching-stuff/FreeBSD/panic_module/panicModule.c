
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

#include <panicModule.h>            /* module initialization type  */
#include <panicModuleSyscalls.h>    /* system call implementations for this module */

/*---------------------------------------------------------------------------------*/
/*-------------- MODULE INTERNAL VARIABLES ----------------------------------------*/
/*---------------------------------------------------------------------------------*/




/**
 * Define a fixed name for this module, that is the unique
 * name this module will be registered in the system.
 */
static char my_name[] = "FreeBSDPanicModule";





/**
 * Here goes an initialization structure that will be passed
 * to the module, so that it gets the data to check against
 * file system names for generating a panic.
 * This struct will be used below in the module definition
 * and will get extracted from the module initialization.
 */
static panic_module_argv_t _argv = {
  3,
  { "panic", "crash", "bsdmag" }
};



/**
 * Arguments that initialized the module.
 * By default the module has no arguments.
 * This variable will be used to handle the initialization
 * of the module so that it can be passed around from the 
 * module to another function.
 */
panic_module_argv_t* moduleInitializationData = NULL;


/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/






/*---------------------------------------------------------------------------------*/
/*-------------------- MODULE EVENT HANDLER ---------------------------------------*/
/*---------------------------------------------------------------------------------*/



/**
 * A method that will be called each time a module related event
 * happens (e.g., when the module is loaded, unloaded, and so on).
 * The method is defined as static, that means it cannot be used
 * outside this module definition.
 *
 * \param st_module a pointer to a module structure
 * \param event the event that has to be processed
 * \param argv  custom module arguments
 * \returns zero on success, an error if something goes wrong
 */
static int 
panicEventHandler(  
		  struct module *st_module, 	/* pointer to the module struct */
		  int event,			/* the event to process for this module */
		  void* argv			/* custom arguments for the module */
    )
{

  /* Define a variable to handle the exit status (0 on success) */
  int error = 0;  

  /* which kind of event is happening for this module? */
  switch( event ){	

    /* the module is being loaded */
  case MOD_LOAD:	
    /* print a message in the logs */
    uprintf( "\nLoading (%d) the module %s ...\n", event, my_name );

    /* get the arguments for the module */
    if( argv != NULL ){
      moduleInitializationData = (panic_module_argv_t*) argv;

      for( int i = 0; i < moduleInitializationData->count; i++ ){
	uprintf( "\nWill generate a panic on filesystem name containing [%s]", 
		 moduleInitializationData->names[i] );
      }
      
    } /* end of argument for the module */
    else{
      /* set the module arguments to null */
      moduleInitializationData = NULL;
    }

    /* insert the panicable system calls in the system table */
    uprintf( "\nInstalling a panicable mkdir system call...\n" );
    clean_mkdir_sysent_definition = sysent[ SYS_mkdir ];
    sysent[ SYS_mkdir ]           = panicable_mkdir_sysent_definition;
    uprintf( "\nInstalling a panicable open system call...\n" );
    clean_open_sysent_definition  = sysent[ SYS_open ];
    sysent[ SYS_open ]            = panicable_open_sysent_definition;


    break;

    /* the module is being unloaded */    
  case MOD_UNLOAD:  

    /* print a message in the logs */
    uprintf( "\nUnloading (%d) the module %s ...\n", event, my_name );
    
    /* restore the original system call */
    uprintf( "\nRestoring the original system calls...\n" );
    sysent[ SYS_mkdir ] = clean_mkdir_sysent_definition;
    sysent[ SYS_open ]  = clean_open_sysent_definition;

    break;
    
  default:
    /* if here the event is not supported by this module */
    uprintf( "\nEvent/Command %d not supported by module %s\n", event, my_name );
    error = EOPNOTSUPP;	
    break;
  }
  
  
  /* all done */
  return error;
  
}



/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/





/*---------------------------------------------------------------------------------*/
/*----------------- MODULE DEFINITION ---------------------------------------------*/
/*---------------------------------------------------------------------------------*/





/**
 * Define structure that represents this module.
 * The structure defines the name of the module (that must be unique),
 * the event handler (function pointer) that will be called each time
 * an event related to the module happens, and a set of custom
 * initialization data.
 */
static moduledata_t panic_module_definition = {
  my_name,		  /* module unique name */
  panicEventHandler,      /* event handler */
  &_argv		  /* module arguments */
};


/**
 * Use the DECLARE_MODULE macro to insert the module binary in the running
 * system.
 * The macro requires the name of the binary file for the module,
 * the name of module struct that handles all the data about the module,
 * the subsystem the module belongs to and an initialization order.
 * The module can be loaded using the name specified as first argument
 * (e.g., panicModuleBin), therefore:
 \code
    kldload ./panicModuleBin.ko
 \endcode

 * and can be unloaded using the same (simple) name:

 \code
    kldunload panicModuleBin
 \endcode
 *
 */
DECLARE_MODULE( panicModuleBin,		                /* binary file name */
                panic_module_definition,	        /* module structure name */
		SI_SUB_DRIVERS,                         /* subsystem */
		SI_ORDER_MIDDLE                         /* initialization order */
);


/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------*/
