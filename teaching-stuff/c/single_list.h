/*
 * single_list.h
 *
 * This file defines the structures for a simple single list
 * way of handling custom data.
 * It does not uses the offset_of macro so the idea is that the
 * list header and structure to be at the beginning of the custom data
 * structure.
 */


#ifndef LISTS_SINGLE_LIST
#define LISTS_SINGLE_LIST

typedef struct SINGLE_LIST_ENTRY{
  struct SINGLE_LIST_ENTRY *next; /* a pointer to the next element in the list */
  void * data;			  /* a custom pointer to any kind of data element */
  
} single_list_entry;


single_list_entry* s_add( void * payload, single_list_entry *head );
single_list_entry* s_remove( single_list_entry *node, single_list_entry *head );
single_list_entry* s_insert( single_list_entry *node, single_list_entry *head );
single_list_entry* s_find( void *data, single_list_entry* head );
single_list_entry* s_tail( single_list_entry *head );

#endif	/* LISTS_SINGLE_LIST */
