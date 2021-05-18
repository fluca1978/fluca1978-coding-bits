#include <iostream>
#include <string>
#include <list>

#include <array>
#include <vector>
#include <algorithm>
#include <iterator>
using namespace std;


int main( int argc, char **argv ) {
  array<string, 2> people = { "Luca", "Emanuela" };

  for ( std::string current : people )
    std::cout << current << std::endl;
    

  // a vector does non include a size
  vector<string> vPeople = {  "Luca", "Ferrari" ,  "Emanuela Santunione" };
  for ( string current : vPeople )
    cout << current << endl;

  cout << "size of the vector is " << vPeople.size();

  cout << "\nBEGIN VECTOR " << vPeople.front();
  cout << "\nEND VECOTR " << vPeople.back() <<endl;


  // use an iterator
  vector<string>::iterator iter;
  for ( iter = vPeople.begin(); iter != vPeople.end(); iter++ ) {
    auto incrementing = *iter;
    auto& decrementing = *iter;  // using a reference any change done here is going to be reflect in the list

    incrementing += " plus ";
    decrementing += " minus ";
  }

  for ( iter = vPeople.begin(); iter != vPeople.end(); iter++ )
    cout << *iter;

  return 0;
}


