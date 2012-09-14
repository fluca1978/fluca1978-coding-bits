// sorting_main.c
/**
 * This is a simple program to show how the different main sorting
 * alghortims work.
 *
 * To compile the program use the following command:

 gcc -DSORT_VERBOSE -lm -g -o sort.exe sorting_main.c

 * where the SORT_VERBOSE flag indicates to produce output at each step of sorting.
 * It is also possible to use the SORT_SIMPLE flag to produce a very simple
 * initial array to ease the alghortim analysys.
 *
 *
 *
 * The following is an example of a program output:
 
 Welcome to the sorting sample!

The program is configured for sorting max 10000 random values

#######################################

		Bubble Sort O(n^2) = 100000000 


		Bubble Sort took 1.04 secs, complexity was 25224415

		Bubble Sort Aggressive took 0.65 secs, complexity was 25119051
#######################################

#######################################

		Selection Sort O(n^2) = 100000000 


		Selection Sort took 0.25 secs, complexity was 10000
#######################################

#######################################

		Quick Sort  O( n log n) = 92103.403720 up to O(n^2) = 100000000 


		Quick Sort took 0.00 secs, complexity was 33541
#######################################
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h> // for memset/bzero utilities
#include <time.h>   // for getting times
#include <math.h>   // for log functions


// number of items in the array 
// to sort
#define MAX_ITEMS 10000

#define MICROSECS_PER_SECOND 1000000

/*
 * Alghoritm selectors
 */
#define BUBBLE_SORT            1
#define BUBBLE_SORT_AGGRESSIVE 2
#define MERGE_SORT             3
#define QUICK_SORT             4
#define SELECTION_SORT         5



double
duration( struct timeval *startTime, struct timeval *endTime );

void 
init_array_with_random_values( int* arrayToFill, int count );

void
_dump( int * arrayToDump, int end );

long
do_bubble_sort( int* array, int start, int end );

long
do_bubble_sort_aggressive( int* array, int start, int end );

long
do_selection_sort( int* array, int start, int end );

long
do_quick_sort( int* array, int start, int end );

long
do_merge_sort( int* array, int start, int end );

void
do_merge( int* array, int start, int partitionIndex, int end );

void 
run_sort( int whichAlghoritm, int* array_to_sort, int start, int end );

////////////////////////////////////////////////////////////////////////////////

int
main( int argc, char** argv ){
  
  long number_of_elements = 0;


  printf( "\nWelcome to the sorting sample!\n" );
  printf( "\nThe program is configured for sorting max %ld random values\n", (long) MAX_ITEMS );

  // get the number of elements to sort from the command line
  if( argc == 2 )
     number_of_elements = atol( argv[1] );
  else
    number_of_elements  = MAX_ITEMS;



  // create an integer array
  // with the number of items
  int* array_to_sort = (int*) malloc( sizeof( int ) * number_of_elements );

  // zero fill the array
  memset( array_to_sort, 0, sizeof( int ) * number_of_elements );
  // or this is equivalent
  bzero( array_to_sort, sizeof( int ) * number_of_elements );


  // init the array
  init_array_with_random_values( array_to_sort, number_of_elements );



  run_sort( BUBBLE_SORT, array_to_sort, 0, number_of_elements );
  run_sort( BUBBLE_SORT_AGGRESSIVE, array_to_sort, 0, number_of_elements );
  run_sort( SELECTION_SORT, array_to_sort, 0, number_of_elements );
  run_sort( QUICK_SORT, array_to_sort, 0, number_of_elements );
  run_sort( MERGE_SORT, array_to_sort, 0, number_of_elements );

  free( array_to_sort );

}

/**
 * Main entry poinf for calling a specific sorting alghoritm.
 * The function does a copy of the initial data set, so that it is left unchanged,
 * and then calls the right alghoritm printing also a report about the execution
 * time and so on.
 *
 * \param whichAlghoritm an identifier for the alghoritm to iovoke
 * \param array_to_sort_src the source array to sort, it will be cloned and therefore
 * will be unchanged
 * \param start initial index in the array, usually 0
 * \param end the last entry in the array
 */
void 
run_sort( int whichAlghoritm, int* array_to_sort_src, int start, int end ){

  // pointer to the sorter engine
  long (*sorter)(int*, int, int);
  char *title  = NULL;
  int number_of_elements = end - start;
  long complexity         = 0;
  int  *array_to_sort = (int*) malloc( sizeof( int ) * number_of_elements );
  // clone the array to sort so that the initial array is untouched
  memcpy( array_to_sort, array_to_sort_src, sizeof( int ) * number_of_elements );

  // variables to handle timing of the sorting alghoritms
  struct timeval *startTime, *endTime;
  // allocate time structures
  startTime = (struct timeval *) malloc( sizeof( struct timeval ) );
  endTime   = (struct timeval *) malloc( sizeof( struct timeval ) );


  switch( whichAlghoritm ){
  case BUBBLE_SORT:
    sorter = do_bubble_sort;
    title  = "Bubble Sort O(n^2)";
    break;
  case BUBBLE_SORT_AGGRESSIVE:
    sorter = do_bubble_sort_aggressive;
    title  = "Bubble Sort Aggressive";
    break;
  case MERGE_SORT:
    sorter = do_merge_sort;
    title  = "Merge Sort O(n log n)";
    break;
  case QUICK_SORT:
    sorter = do_quick_sort;
    title  = "Quick Sort O(n log n)";
    break;
  case SELECTION_SORT:
    sorter = do_selection_sort;
    title  = "Selection Sort O(n^2)";
    break;
  default:
    sorter = NULL;
    printf( "\nNo sorter specified!\n" );
    return;
  }


  printf( "\n#######################################\n" );
  printf( "\n\t\t%s,\n", title );
	  
  
#ifdef SORT_VERBOSE
  printf( "\n Initial array is\n" );
  _dump( array_to_sort, number_of_elements );
#endif // SORT_VERBOSE 

  gettimeofday( startTime, NULL );
  complexity = sorter( array_to_sort, start, number_of_elements );
  gettimeofday( endTime, NULL );
  printf( "\n\n\t\t%s\n", title );
  printf( " %2.2f secs, complexity was %ld", 
	  duration( startTime, endTime ),
	  complexity );
#ifdef SORT_VERBOSE
  printf( "\nSorted array is\n" );
  _dump( array_to_sort, number_of_elements );
#endif //SORT_VERBOSE

  printf( "\n#######################################\n" );

  /*  
  free( startTime );
  free( endTime );
  */

  free( array_to_sort );
}


/**
 * A method to compute the elapsed seconds between a start and an and time.
 * Suppose none of the alghoritms is using more than one day!
 * \param startTime a pointer to the starting time struct
 * \param endTime a pointer to the end time struct
 * \returns the number of elapsed seconds
 */
double
duration( struct timeval *startTime, struct timeval *endTime ){
  double secs = ( endTime->tv_sec - startTime->tv_sec ) * MICROSECS_PER_SECOND;
  secs       += ( endTime->tv_usec - startTime->tv_usec );
  secs       /= MICROSECS_PER_SECOND;
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
#ifndef SORT_SIMPLE
    arrayToFill[ i ] = (int) random();
#else
    arrayToFill[ i ] = 10 - i;
#endif //SORT_SIMPLE
}




/**
 * A method to implement the classic bubble sort.
 * The complexity is O(n^2).
 * \param array the array to sort
 * \param count the number of items to sort
 * \returns the number of steps performed to sort the
 * array
 */
long
do_bubble_sort( int* array, int start, int end ){
  long complexity     = 0;
  int swap_counter   = 0;
  int swapping_value;
  int i;

  do{
    swap_counter = 0;

    for( i = start; i < end - 1; i++ )
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
long
do_bubble_sort_aggressive( int* array, int start, int end ){
  long complexity           = 0;
  int swap_counter          = 0;
  int biggest_swapped_index = 0;
  int stopAtItem            = end - 1;
  int swapping_value;
  int i;

  do{
    swap_counter = 0;

    biggest_swapped_index = 0;

    for( i = start; i < stopAtItem; i++ )
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




/**
 * Classical implementation of the selection sort.
 * The alghortim is as follows:
 * 1) select the minimum value in the list
 * 2) swap the min value with the first position of the list
 * 3) move to the first element of the list and search again the min value
 * 4) swap the value with the first element
 * 5) repeat for every value in the list
 */
long
do_selection_sort( int* array, int start, int end ){
  long complexity         = 0;
  int current_min_index  = 0;
  int swapping           = 0;
  int i;
  int start_index;
  start_index = 0 + start;

  do{
    current_min_index = start_index;

    for( i = start_index; i < end; i++ )
      if( array[ current_min_index ] > array[ i ] )
	// the i-th position is the new current min
	current_min_index = i;
    

#ifdef SORT_VERBOSE
    printf( "\n\t[doSelectionSort] min index is %d, swapping value with index %d",
	    current_min_index, start_index );
#endif // SORT_VERBOSE
    
    // now I've got the min value in the list, place it at the
    // last position
    swapping = array[ current_min_index ];               // current min value
    array[ current_min_index ] = array[ start_index ];   // move the current start value
    array[ start_index ] = swapping;                     // place the min at the begin
    start_index++;

    complexity++;
    
  }while( start_index < end );

  return complexity;
}



long
do_quick_sort( int* array, int start, int end ){
  long complexity   = 0;
  int pivot_value  = 0;
  int pivot_index  = 0;
  int i;
  int swapping;

  int partition_start = start;
  int partition_end   = end;

  // pick a pivot (get an index in the middle of the partition)
  pivot_index = ( partition_end - partition_start ) / 2 + partition_start;
  pivot_value = array[ pivot_index ];


#ifdef SORT_VERBOSE
  printf( "\n\t[do_quick_sort] pivot value is %d at index %d - current partition from %d to %d ",
	  pivot_value, pivot_index, start, end );
#endif // SORT_VERBOSE


  // do the partitioning
  while( partition_start <= partition_end ){

    while( array[ partition_start ] < pivot_value )
      partition_start++;

    while( array[ partition_end ] > pivot_value )
      partition_end--;

    if( partition_start <= partition_end ){
#ifdef SORT_VERBOSE
      printf( "\n\t[do_quick_sort] swapping values at indexes %d <-> %d",
	      partition_start, partition_end );
#endif // SORT_VERBOSE

      swapping                 = array[ partition_start ];
      array[ partition_start ] = array[ partition_end ];
      array[ partition_end ]   = swapping;
      partition_start++;
      partition_end--;

      complexity++;
    }
  }


  // recursion
  if( start < partition_end )
    complexity += do_quick_sort( array, start, partition_end );
  if( end > partition_start )
    complexity += do_quick_sort( array, partition_start, end );
    
  return complexity;
}






long
do_merge_sort( int* array, int start, int end ){

  int partitionIndex = ( end + start ) / 2;
  long complexity    = -1;
  
  if( start < end ){
#ifdef SORT_VERBOSE
    printf( "\nAnalyzing partition split at index %d\n", partitionIndex );
#endif // SORT_VERBOSE

    do_merge_sort( array, start, partitionIndex );
    do_merge_sort( array, partitionIndex + 1, end );

#ifdef SORT_VERBOSE
    printf( "\nDoing merge of %d <-> %d and %d <-> %d\n", 
	    start, partitionIndex, partitionIndex + 1, end );
#endif // SORT_VERBOSE

    // do the merge
    do_merge( array, start, partitionIndex, end );
  }

  return complexity;
}


void
do_merge( int* array, int start, int partitionIndex, int end ){
  int copyArray[ (end - start + 1 ) ];
  int leftIndex  = start, rightIndex = partitionIndex + 1;
  int copyIndex  = 0;
  int mergeIndex = 0;

  // sorting phase
  while( leftIndex <= partitionIndex && rightIndex <= end )
    if( array[ leftIndex ] < array[ rightIndex ] )
      copyArray[ copyIndex++ ] = array[ leftIndex++ ];

    else
      copyArray[ copyIndex++ ] = array[ rightIndex++ ];


  while( leftIndex <= partitionIndex )
    copyArray[ copyIndex++ ] = array[ leftIndex++ ];

  while( rightIndex <= end )
      copyArray[ copyIndex++ ] = array[ rightIndex++ ];

  // merge
  for( mergeIndex = 0; mergeIndex < copyIndex; mergeIndex++ )
    array[ start + mergeIndex ] = copyArray[ mergeIndex ];

}




////////////////////////////////////////////////////////////////////////////////

void _dump( int * array, int count ){
  int i = 0;

  printf( "\n" );


  for( i = 0; i < count; i++ ){

    printf( "array[ %d ] = %d\n", i, array[ i ] );
  }

  printf( "\n" );
}
