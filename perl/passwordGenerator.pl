#!/usr/bin/perl

# A simple scrypt to generate random passwords.
# The output of this script can be used to feed
# an automatic user generator.


# password length
$PASS_LENGTH=6;

# which symbols can be used in the password
@symbols = ('a'..'z','A'..'Z','0'..'9','+','-','=','$','!','(',')');

for($i=0;$i<=$PASS_LENGTH;$i++){
    $password .= join('',$symbols[rand($#symbols)]);
}

# print the encrypted password to stdout
print crypt($password,"01");
