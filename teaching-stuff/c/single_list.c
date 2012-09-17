/* single_list.c
   I)mplementation of the single list routings
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "single_list.h"




/**
 * Creates a new node and places it as the new head of the list, containing the
 * specified data.
 *
 * If the current head is null a new head will be placed in the list.
 *
 * \param payload the data the user wants to put into the new node
 * \param head the current head (or NULL to initialize a new list)
 * \returns the new current head of the list
 */ 
single_list_entry* 
s_add( void * payload, single_list_entry *head ){

  single_list_entry* new_node = NULL;

  /* check arguments */
  if( payload == NULL ){
    return;
  }

  /* create a new node to place in front of the head and to contain
     all the data of the user
  */
  new_node = ( single_list_entry* ) malloc( sizeof( single_list_entry ) );
  new_node->next = NULL;
  new_node->data = NULL;

  if( head == NULL ){
    /* the head is null, and therefore there is no current list at this time.
       Therefore the new node is also the head of the list.
    */
    head = new_node;
  }
  else
    /* if here the head is valid, therefore the new node will point to the
       current head
    */
    new_node->next = head;

  /* place the data into the current new node */
  new_node->data = payload;

  /* return the new head */
  return new_node;

}


/**
 * Removes a specified node from a list with the specified head.
 *
 * \param node the node to remove
 * \param head the head of the list to remove
 * \returns the new head
 */ 
single_list_entry*
s_remove( single_list_entry *node, single_list_entry *head ){

  single_list_entry *current  = NULL;
  single_list_entry *previous = NULL;

  /* check arguments */
  if( node == NULL
      || head == NULL
      || head == node )
    /* impossible to remove the node, do not do nothing at all! */
    return head;

  /* 
   * We must iterate over the whole list and search for the node to remove;
   * when found adjust pointers of previous and next elements.
   */
  for( current = head; current != NULL; current = current->next ){
    if( current == node ){
      /* found the node to remove */

      /* if the current node is the current head the head has to be relocated! */
      if( current == head )
	head = current->next;
      else
	previous->next = current->next; /* so that the current
					   node disappears from the list */

      free( current->data );
      free( current );
    }
    else
      previous = current;
  }

  /* all done */
  return head;
}


/**
 * Inserts a specified node into the specified head, that is the node
 * is inserted after the current specified head.
 *
 * \param node the node to insert after the head
 * \param head the head on which the node will be inserted
 * \returns the modified head
 */ 
single_list_entry* 
s_insert( single_list_entry *node, single_list_entry *head ){

  /* check arguments */
  if( node == NULL
      || head == NULL
      || head == node )
    /* cannot insert on a null list or on the same head */
    return head;

  node->next = head->next;
  head->next = node;
  return head;
}


/**
 * Searches for the specified data into each node of the specified list.
 *
 * \param head the head of the list to search for
 * \param data the data to search for into the nodes
 * \returns the pointer to the first node that contains the data or NULL if the data
 * is not found
 */ 
single_list_entry* 
s_find( void *data, single_list_entry* head ){

  

  /* check arguments */
  if( data == NULL
      || head == NULL )
    return NULL;


  /* iterate on all the nodes */
  for( ; head != NULL; head = head->next ){
    if( head->data == data )
      /* found the first node that contains the data! */
      return head;
  }

  /* if here the node has not been found */
  return NULL;
}


/**
 * Provides the last element in the current list.
 *
 * \param head the current head
 * \returns the last node in the list
 */
single_list_entry* 
s_tail( single_list_entry *head ){
  for( ; head->next != NULL; head = head->next )
    ;

  return head;
}
