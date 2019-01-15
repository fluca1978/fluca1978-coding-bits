#include <stdio.h>
#include <stdlib.h>


typedef struct entry {
  char name[64];
  struct entry* next;
} entry;

void
main() {

  /* define an entry pointer */
  entry* root = malloc( sizeof( entry ) );
  sprintf( root->name,  "ROOT" );

  /* loop and create 10 other structures */
  entry* current = root;
  for ( int i = 0; i < 10; i++ ){
    printf( "Creating next structure %d\n", i );
    entry* next = malloc( sizeof( entry ) );
    sprintf( next->name, "Entry %d", i);
    next->next = NULL;

    printf( "Attaching structures [%s] -> [%s]\n",
            current->name, next->name );
    current->next = next;
    current = next;
  }

  /* print out */
  for ( current = root; current; current = current->next ){
    printf( "Entry [%s] -> [%s]\n", current->name, current->next->name );
  }

}
