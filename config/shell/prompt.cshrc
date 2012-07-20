# a fancy prompt for a C-Shell environment.
# It prints the username and hostname, the OS version and release, the working
# directory and a colored prompt sign.

set prompt="%{\033[0;1;33m%}%B[%{\033[0;1;37m%}%n%{\033[0;1;31m%}@%{\033[0;1;37m%}%M%{\033[0;1;33m%} %{\033[0;1;34m%}{%{\033[0;1;36m%}`uname -n -r`%{\033[0;1;34m%}}%{\033[0;1;33m%}] %{\033[0;1;32m%}%b%/%{\033[0;1;33m%} (%{\033[0;1;37m%}%h%{\033[0;1;33m%}) %{\033[0;1;36m%}%{\033[0;1;32m%}>%{\033[0;1;37m%} " 