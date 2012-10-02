# Student.pm

# A simple module that extends the Person one and that provides
# some additional info to a simple Person.

package Student;

# It is important to mark this package/class as being a subclass
# of a Person, so that Perl will know where to go to find methods
# and attributes defined in the base class.
@ISA = qw( Person );

sub new{
    # the current class type
    my ($class) = shift;
    # to allow this constructor to create a new instance
    # even when an object is passed use the following code that
    # always returns the class type and never the reference to an
    # object: get the name of the class in the case an object reference
    # has been passed or use the classname as it has been passed
    $class = ref( $class ) || $class;

    # create a base object
    $this = $class->SUPER::new( @_ );
    # do the usual blessing
    bless( $this, $class );
}

# Sets the university for this Person/Student. This requires
# to break the encapsulation of the parent class, since we know
# that the base class is using an hashmap to store its internal
# attributes and that we can append new attributes to it too.
sub set_university{
    my ($this, $university) = @_;

    if( ref( $this ) ){
	$this->{'university'} = $university;
    }
}

sub get_university{
    return $_[0]->{'university'} if( ref( $this ) );
}

# Override the superclass method. 
# It is possible to reference the superclass method using the special
# "SUPER" pseudo-class.
sub description{
    if( ! ref( $_[0] ) ){
	return undef();
    }

    return $_[0]->SUPER::description() . " UNIVERSITY = " . $_[0]->{'university'};
}
