# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.bin" ] ; then
    PATH="$HOME/.bin:$PATH"
fi

# add MKL to load path
if [ -d "$HOME/.sdk/mkl/lib" ] ; then
    LD_LIBRARY_PATH="$HOME/.sdk/mkl/lib:$LD_LIBRARY_PATH"
fi

# if present
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
