// sorting_main.c
/**
 * This is a simple program to show how the different main sorting
 * alghortims work.
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h> // for memset/bzero utilities
#include <time.h>   // for getting times


// number of items in the array 
// to sort
#define MAX_ITEMS 10



long
duration( struct timeval *startTime, struct timeval *endTime );

void 
init_array_with_random_values( int* arrayToFill, int count );

void
_dump( int * arrayToDump );

int
do_bubble_sort( int* array, int count );

int
do_bubble_sort_aggressive( int* array, int count );



////////////////////////////////////////////////////////////////////////////////

int
main( int argc, char** argv ){
  
  printf( "\nWelcome to the sorting sample!\n" );
  printf( "\nThe program is configured for sorting %ld random values\n", (long) MAX_ITEMS );

  int complexity = 0;
  // variables to handle timing of the sorting alghoritms
  struct timeval *startTime, *endTime;
  startTime = (struct timeval *) malloc( sizeof( struct timeval ) );
  endTime   = (struct timeval *) malloc( sizeof( struct timeval ) );


  // create an integer array
  // with the number of items
  int* array_to_sort = (int*) malloc( sizeof( int ) * MAX_ITEMS );

  // zero fill the array
  memset( array_to_sort, 0, sizeof( int ) * MAX_ITEMS );
  // or this is equivalent
  bzero( array_to_sort, sizeof( int ) * MAX_ITEMS );


  init_array_with_random_values( array_to_sort, MAX_ITEMS );
  printf( "\n#######################################\n" );
  printf( "\n\t\tBubble Sort O(n^2) = %ld \n", ( (long) MAX_ITEMS ) * MAX_ITEMS  );
  gettimeofday( startTime, NULL );
  complexity = do_bubble_sort( array_to_sort, MAX_ITEMS );
  gettimeofday( endTime, NULL );
  printf( "\nBubble Sort took %ld secs, complexity was %d", 
	  duration( startTime, endTime ),
	  complexity );
  init_array_with_random_values( array_to_sort, MAX_ITEMS );
  gettimeofday( startTime, NULL );
  complexity = do_bubble_sort_aggressive( array_to_sort, MAX_ITEMS );
  gettimeofday( endTime, NULL );
  printf( "\nBubble Sort Aggressive took %ld secs, complexity was %d", 
	  duration( startTime, endTime ),
	  complexity );
  
  printf( "\n#######################################\n" );
  //  _dump( array_to_sort );

}


/**
 * A method to compute the elapsed seconds between a start and an and time.
 * Suppose none of the alghoritms is using more than one day!
 * \param startTime a pointer to the starting time struct
 * \param endTime a pointer to the end time struct
 * \returns the number of elapsed seconds
 */
long
duration( struct timeval *startTime, struct timeval *endTime ){
  long secs = endTime->tv_sec - startTime->tv_sec;
  secs     += ( endTime->tv_usec - startTime->tv_usec ) / 1000;
  return secs;
}


/**
 * A function to init an integer array with random values.
 * \param arrayToFill the array to fill
 * \param count how many entries of the array to fill
 */
void init_array_with_random_values( int* arrayToFill, int count ){
  int i = 0;

  for( i = 0; i < count; i++ )
    arrayToFill[ i ] = (int) random();
}




/**
 * A method to implement the classic bubble sort.
 * The complexity is O(n^2).
 * \param array the array to sort
 * \param count the number of items to sort
 * \returns the number of steps performed to sort the
 * array
 */
int
do_bubble_sort( int* array, int count ){
  int complexity     = 0;
  int swap_counter   = 0;
  int swapping_value;
  int i;

  do{
    swap_counter = 0;

    for( i = 0; i < count - 1; i++ )
      if( array[ i ] > array[ i + 1 ] ){
	// need a swap here
	swapping_value = array[ i ];
	array[ i ]     = array[ i + 1 ];
	array[ i + 1 ] = swapping_value;
	swap_counter++;
      }

    complexity += swap_counter;
    
  }while( swap_counter != 0 );
  

  return complexity;
}


/**
 * A method to implement an aggressive version of the bubble sort.
 * The idea is that at each step the end of the array contains its
 * biggest value, so at the first step the biggest element is placed
 * and never moved, and therefore the set of entries to inspect can be
 * reduced by one each complete loop. Moreover, it is possible to state
 * that it is possible to not see all the last i-th items being i
 * the greater index at which a sort happened in the current loop.
 *
 * \param array the array to sort
 * \param count the number of items to sort
 * \returns the number of steps performed to sort the
 * array
 */
int
do_bubble_sort_aggressive( int* array, int count ){
  int complexity            = 0;
  int swap_counter          = 0;
  int biggest_swapped_index = 0;
  int stopAtItem            = count - 1;
  int swapping_value;
  int i;

  do{
    swap_counter = 0;

    biggest_swapped_index = 0;

    for( i = 0; i < stopAtItem; i++ )
      if( array[ i ] > array[ i + 1 ] ){
	// need a swap here
	swapping_value = array[ i ];
	array[ i ]     = array[ i + 1 ];
	array[ i + 1 ] = swapping_value;
	swap_counter++;
	biggest_swapped_index = i;
      }

    stopAtItem = biggest_swapped_index;
    complexity += swap_counter;
    
  }while( swap_counter != 0 );
  

  return complexity;
}






void _dump( int * array){
  int i = 0;
  for( i = 0; i < MAX_ITEMS; i++ )
    printf( "\narray[ %d ] = %d", i, array[ i ] );
}
