/* double_list.h */

/* 
 * This file provides the interface the an easy and simple implementation of doubly
 * linked lists.
 * The idea is that the list node will contain
 * all the data and the pointers to other elements.
 * 
 */

#ifndef DOUBLE_LISTS
#define DOUBLE_LISTS 1

typedef struct DOUBLE_LIST_ENTRY{


  /* pointer to the next element in the list */
  struct DOUBLE_LIST_ENTRY *next;

  /* pointer to the previous element in the list */
  struct DOUBLE_LIST_ENTRY *prev;

  /* data */
  void *data;
} double_list_entry;


double_list_entry*
d_add( void* payload, double_list_entry *head );

double_list_entry*
d_remove( double_list_entry *entry, double_list_entry *head );

double_list_entry*
d_insert( double_list_entry *entry, double_list_entry *head );

double_list_entry*
d_find( void *payload, double_list_entry *head );

double_list_entry*
d_tail( double_list_entry* head );

#endif	/* DOUBLE_LISTS */
