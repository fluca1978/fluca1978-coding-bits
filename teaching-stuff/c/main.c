/* main.c */

/* This main files demonstrates the usage of the single and double linked lists. */


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "single_list.h"


void
dump_single_list( single_list_entry* head );

int
main( int argc, char** argv ){
  single_list_entry *single_head  = NULL;
  single_list_entry *single_entry = NULL;
  char *payload = malloc( sizeof( char ) * 200 );
  sprintf( payload, "This will be removed from the list!" );

  printf( "\nWelcome to the list example\n" );

  /* initialize a single list with some stuff */
  single_head = s_add( "Hello World", NULL );
  dump_single_list( single_head );
  /* add a few elements to the list */
  single_head = s_add( "Second element", single_head );
  single_head = s_add( "Third element", single_head );
  single_head = s_add( payload, single_head );
  single_head = s_add( "Fifth element", single_head );
  dump_single_list( single_head );

  /* find an element that contains the payload and remove its node
     from the list
  */
  printf( "\nRemove an element" );
  single_head = s_remove( s_find( payload, single_head ),
			  single_head );
  dump_single_list( single_head );

  printf( "\nThe tail of the list is as follows\n" );
  dump_single_list( s_tail( single_head ) );

}


void
dump_single_list( single_list_entry* head ){
  int tabify = 1;
  int j;

  printf( "\n-------- LIST DUMP -----------\n" );

  do{

    for( j = 0; j < tabify; j++ )
      printf( "\t" );

    printf( ".data = %s\n", (char*) head->data );
    tabify++;
    

    /* move to the next entry in the list */
    head = head->next;
  }while( head != NULL );

  printf( "\n-----------------------------\n" );
}
