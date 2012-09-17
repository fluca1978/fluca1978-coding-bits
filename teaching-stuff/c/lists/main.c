/* main.c */

/* 
 * This main files demonstrates the usage of the single and double linked lists.


 To compile this program do as folllows:

 gcc -g -o list.exe main.c double_lists.h double_lists.c single_list.c single_list.h


 and run it as

 ./list.exe


 The following is an example of output:

 
Welcome to the list example

-------- LIST DUMP -----------
	.data = Hello World .next=(nil)d

-----------------------------

-------- LIST DUMP -----------
	.data = Fifth element .next=0xdaf140d
		.data = This will be removed from the list! .next=0xdaf120d
			.data = Third element .next=0xdaf100d
				.data = Second element .next=0xdaf0e0d
					.data = Hello World .next=(nil)d

-----------------------------

Remove an element
-------- LIST DUMP -----------
	.data = Fifth element .next=0xdaf120d
		.data = Third element .next=0xdaf100d
			.data = Second element .next=0xdaf0e0d
				.data = Hello World .next=(nil)d

-----------------------------

The tail of the list is as follows

-------- LIST DUMP -----------
	.data = Hello World .next=(nil)d

-----------------------------

-------- LIST DUMP -----------
	.data = Hello double linked list world!	.next=(nil)	.prev=(nil)

-----------------------------

-------- LIST DUMP -----------
	.data = Sixth element	.next=0xdaf1e0	.prev=(nil)
		.data = This will be removed from the list!	.next=0xdaf1c0	.prev=0xdaf200
			.data = Fourth element	.next=0xdaf1a0	.prev=0xdaf1e0
				.data = Third element	.next=0xdaf180	.prev=0xdaf1c0
					.data = Second element	.next=0xdaf140	.prev=0xdaf1a0
						.data = Hello double linked list world!	.next=(nil)	.prev=0xdaf180

-----------------------------

Removing an element from the list

-------- LIST DUMP -----------
	.data = Sixth element	.next=0xdaf1c0	.prev=(nil)
		.data = Fourth element	.next=0xdaf1a0	.prev=0xdaf200
			.data = Third element	.next=0xdaf180	.prev=0xdaf1c0
				.data = Second element	.next=0xdaf140	.prev=0xdaf1a0
					.data = Hello double linked list world!	.next=(nil)	.prev=0xdaf180

-----------------------------

The tail is as follows

-------- LIST DUMP -----------
	.data = Hello double linked list world!	.next=(nil)	.prev=0xdaf180

-----------------------------
 */


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "single_list.h"
#include "double_list.h"


void
dump_single_list( single_list_entry* head );

void
dump_double_list( double_list_entry* head );

int
main( int argc, char** argv ){
  single_list_entry *single_head  = NULL;
  single_list_entry *single_entry = NULL;
  double_list_entry *double_head  = NULL;
  double_list_entry *double_entry = NULL;


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



  /* double list management */
  payload = malloc( sizeof( char ) * 200 );
  sprintf( payload, "This will be removed from the list!" );

  double_head = d_add( "Hello double linked list world!", NULL );
  dump_double_list( double_head );
  double_head = d_add( "Second element", double_head );
  double_head = d_add( "Third element", double_head );
  double_head = d_add( "Fourth element", double_head );
  double_head = d_add( payload, double_head );
  double_head = d_add( "Sixth element", double_head );
  dump_double_list( double_head );
  printf( "\nRemoving an element from the list\n" );
  double_head = d_remove( d_find( payload, double_head ),
			  double_head );
  dump_double_list( double_head );
  printf( "\nThe tail is as follows\n" );
  dump_double_list( d_tail( double_head )  );

}


void
dump_single_list( single_list_entry* head ){
  int tabify = 1;
  int j;

  printf( "\n-------- LIST DUMP -----------\n" );

  do{

    for( j = 0; j < tabify; j++ )
      printf( "\t" );

    printf( ".data = %s .next=%pd\n",
	    (char*) head->data,
	    head->next );
    tabify++;
    

    /* move to the next entry in the list */
    head = head->next;
  }while( head != NULL );

  printf( "\n-----------------------------\n" );
}



void
dump_double_list( double_list_entry* head ){
  int tabify = 1;
  int j;

  printf( "\n-------- LIST DUMP -----------\n" );

  do{

    for( j = 0; j < tabify; j++ )
      printf( "\t" );

    printf( ".data = %s\t.next=%p\t.prev=%p\n",
	    (char*) head->data,
	    head->next,
	    head->prev );

    tabify++;
    

    /* move to the next entry in the list */
    head = head->next;
  }while( head != NULL );

  printf( "\n-----------------------------\n" );
}
