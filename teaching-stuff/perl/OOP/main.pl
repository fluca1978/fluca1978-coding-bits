#!/usr/bin/env perl

use strict;

# import the module we want to use
use Person;
use Student;



print "\nWelcome to a simple Perl example to demonstrate the usage of";
print "\nmodules as classes and objects\n";

# create a couple of person instance
my $person_1 = new Person 'Luca', 'Ferrari';
print "\nPerson is " . ref( $person_1 );
print "\nCreated a person\n\t" . $person_1->description() . "\n";
my $person_2 = Person::new( 'Person', 'Luca', 'Ferrari' );
print "\nCreated a person\n\t" . $person_2->description() . "\n";
my $person_3 = Person->new( 'Luca', 'Ferrari' );
print "\nCreated a person\n\t" . $person_3->description() . "\n";
print "\nThe static variable Person::instance_counter is " . $Person::instance_counter . "\n";

# if we try to call the new method on an instance, instead of a class
# our constructor will fail
my $person_4 = $person_1->new( 'Luca', 'Ferrari' );
print "\nCreating an object from another object has failed\n" unless( defined( $person_4 ) );

# enable the person constructor to allow for creation by copy and try it again
$Person::allows_copy_constructor = 1;
$person_4 = $person_1->new( 'Luca', 'Ferrari' );
print "\nCloned a person\n\t" . $person_4->description() . "\n";

# trying to place a value into a class (not a reference) should not work
print "\nCannot set a name on a class!\n" unless Person->set_name( 'Luca' );


# create a student
my $student_1 = new Student 'Alfred', 'Einstein';
# use an extended attribute
$student_1->set_university( "Nipissing University" );
# call the overridden method
print "\nCreated a student\n\t" . $student_1->description() . "\n";

# let's see what we have so far
# (the isa method is defined in the UNIVERSAL base object, so
# every object has it)
print "\nThe first person is a person\n" if( $person_1->isa( 'Person' ) );
print "\nThe first person is not a student\n" unless( $person_1->isa( 'Student' ) );



print "\nThe first student is a person\n"  if( $student_1->isa( 'Person' ) );
print "\nThe first student is a student\n" if( $student_1->isa( 'Student' ) );
