/* double_lists.c */


#include <stdlib.h>
#include "double_list.h"


double_list_entry*
d_add( void* payload, double_list_entry *head ){
  double_list_entry *new_node;

  /* check arguments */
  if( payload == NULL )
    return head;

  /* allocate a new node */
  new_node = ( double_list_entry* ) malloc( sizeof( double_list_entry ) );
  new_node->next = NULL;
  new_node->prev = NULL;
  new_node->data = NULL;


  /* associate the data to the node */
  new_node->data = payload;

  /* if the head is not null, associate the head to the new_node and vice-versa */
  if( head != NULL ){
    new_node->next = head;
    head->prev     = new_node;
  }

  /* the new_node is the new head of the list */
  return new_node;

}

double_list_entry*
d_remove( double_list_entry *entry, double_list_entry *head ){
  
  double_list_entry *current  = NULL;

  /* check arguments */
  if( entry == NULL
      || head == NULL
      || entry == head ){
    /* cannot delete this element */
    return head;
  }

  /* iterate on all the nodes to find out the one to eras */
  for( current = head; current != NULL; current = current->next )
    if( current == entry ){

      /* this is the node to delete.
	 It is required to check if this is the last node in the list
	 or the head of the list	 
      */

      if( current == head ){
	/* we are deleting the list, so relocate it */
	head = current->next;
      }
      else if( current->next == NULL ){
	/* this is the last node of the list */
	current->prev->next = NULL;
      }
      else{
	/* intermediate node */
	current->prev->next = current->next;
	current->next->prev = current->prev;
      }

	
      free( current->data );
      free( current );
      break;
    }

  /* all done */
  return head;
}

double_list_entry*
d_insert( double_list_entry *entry, double_list_entry *head ){

  /* check arguments */
  if( entry == NULL
      || head == NULL
      || entry == head ){
    return head;
  }

  entry->prev = head;
  entry->next = head->next;
  head->next  = entry;

  return head;
}

double_list_entry*
d_find( void *payload, double_list_entry *head ){

  double_list_entry *current = NULL;

  /* check arguments */
  if( payload == NULL
      || head == NULL )
    return NULL;

  /* iterate on all the nodes */
  for( current = head; current != NULL; current = current->next ){
    if( current->data == payload ){
      /* found the node that contains the data */
      return current;
    }
  }

  /* if here nothing has been found */
  return NULL;
  
}

/**
 * Provides the last element in the list (going forward).
 * \param head the head of the list
 * \returns the last element of the list
 */
double_list_entry*
d_last( double_list_entry* head ){
  
  /* check arguments */
  if( head == NULL )
    return head;

  for( ; head->next != NULL; head = head->next )
    ;

  return head;
}


/**
 * Provides the tail of the list, that is the list without the current head.
 * \param head the head of the list
 * \returns the tail of the list or null
 */
double_list_entry*
d_tail( double_list_entry* head ){
  return ( head != NULL ? head->next : NULL );
}
