# Person.pm
# A simple module that creates a "Person" base class.

# Each class must belong to one package with the name of the class
# itself.
package Person;



# This variable is a static variable, that is it is accessible
# using the package name qualifier as "Person::instance_counter"
$instance_counter = 0;

# This static variable defines if the constructor acts as plain constructor
# or copy constructor.
$allows_copy_constructor = 0;


# It is good practice to define a "new" method to create a
# new instance of the class (that is an object). The method
# will accept as first argument the class name (that should be
# the package name if not using inheritance) and other
# initialization parameters.
#
# The following method calls are all equivalents:
#
# my $person_1 = new Person 'Luca', 'Ferrari';
# my $person_2 = Person::new( 'Person', 'Luca', 'Ferrari' );
# my $person_3 = Person->new( 'Luca', 'Ferrari' );
#
# The first two method calls are called "indirect object method call"
# and are used to define an object in a way similar to Java/C++. The second
# way in particular is how the first way is expanded.
# The third way is called "direct object call" and Perl automagically
# invokes the "new" method into the Person package passing the Person
# name as first argument.
#
# \param $name the name of the person
# \param $surname the surname of the person
# \param $age the age of the person
# \param $gender the gender of the person
sub new{
    # the first argument is the class name
    my $class = shift;

    # copying the array of arguments into another array named "params" is
    # required to allows a "smart" copy constructor: the @_ array is read only
    # and to allow for a quick copy-constructor I will rewrite the array of
    # args to deal with copies
    my (@params)  = @_;

    # if the class is not a name but a reference, that is
    # it is not a scalar, the "new" method has been invoked on
    # an object instance and this is wrong!
    if( ref( $class ) ){
	if( ! $allows_copy_constructor ){
	    return undef();
	}
	else{
	    # it could be possible to use this branch as a copy constructor
	    # as follows (I will fakely populate the args array @_ so that
	    # it seems that the clone values has been passing as arguments)
	    $other = $class; 	        # rename it to readability
	    $class = ref( $other );     # gets the real class name of this object
	    $params[0]  = $other->get_name();
	    $params[1]  = $other->get_surname();
	    $params[2]  = $other->get_age();
	    $params[3]  = $other->get_gender();
	}
    }

    # create a new anonymous hash reference
    my $this = {};

    # increment the person instance counter
    $instance_counter++;


    # place each initialization data
    $this->{ 'name'    } = shift @params;
    $this->{ 'surname' } = shift @params;
    $this->{ 'age'     } = shift @params;
    $this->{ 'gender'  } = shift @params;
    # place the instance counter value into the current person
    # instance so that this person knows "when" it has been created
    $this->{ 'id'      } = $instance_counter;




    # bless the reference, so that it belongs (i.e., it is tagged)
    # to the specified class. Please note that "bless" returns the
    # blessed reference, so that it is safe to place the bless call
    # as the last instruction of the new method.
    bless( $this, $class );
}



# Define each getter and setter.
# It is interesting to note that each method will accept
# as first argument the reference to the blessed instance
# and therefore will act directly on such instance.

sub set_name{
    my ($this, $name ) = @_;
    
    # avoid to work on a class, work only on references to objects!
    if( ref( $this ) ){
	$this->{ 'name' }  = $name;
    }

}

sub set_surname{
    my ($this, $surname ) = @_;

    if( ref( $this ) ){
	$this->{ 'surname' }  = $surname;
    }
}

sub set_age{
    my ($this, $age ) = @_;

    if( ref( $this ) ){
	$this->{ 'age' }  = $age;
    }
}

sub set_gender{
    my ($this, $gender ) = @_;

    if( ref( $this ) ){
	$this->{ 'gender' }  = $gender;
    }
}

sub get_name{
    if( ref( $_[0] ) ){
	return $_[0]->{'name'};
    }
}

sub get_surname{
    if( ref( $_[0] ) ){
	return $_[0]->{'surname'};
    }
}

sub get_age{
    if( ref( $_[0] ) ){
	return $_[0]->{'age'};
    }
}

sub get_gender{
    if( ref( $_[0] ) ){
	return $_[0]->{'gender'};
    }
}

sub get_id{
    if( ref( $_[0] ) ){
	return $_[0]->{'id'};
    }
}



sub description(){
    my ($this) = @_;

    if( ! ref( $this ) ){
	return undef();
    }

    my $string = "";
    $string .= "{" . ref( $this ) ." with ID = " . $this->{'id'} . "} ";
    $string .= "Name = " . $this->{'name'} . " ";
    $string .= "Surname = " . $this->{'surname'} . " ";
    return $string;
}




#
#
# It is good practice (and required when using strict) to
# make the module to return a true value as the very last
# instruction, so that the compilation and import is marked
# as true
#
#
1;


