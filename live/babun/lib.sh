#!/usr/bin/env  zsh
# Loaded after everything else.



#debug=true


{  #  PATH
  PATH="$zshdir/../babun/scripts":"$PATH"

  # Babun cannot deal with relative paths.  Iterate through and correct them:
  # FIXME - An unavoidable slowdown in startup.  Maybe these results could be cached in a file..
  \unset  __
  oldIFS="$IFS"
  IFS=':'
  for i in $PATH
  do
    if [ $debug ]; then
      \echo  "Processing PATH: $i"
    fi
    __="$__":$( \realpath "$i" 2> /dev/null )
  done 
  IFS="$oldIFS"
  PATH="$__"
  \unset  __
}



{  #  Variables
  # Note that I use --mixed to use forward-slashes (/) and not backslashes (\) because backslashes are an impossible problem to overcome.
  # Windows can work with forward slashes just fine, so don't worry.

  # CSIDL_PROGRAM_FILES 0x0026  --  This still reports (x86)
  PF="$( \cygpath  --folder 0x0026 )"
  # FIXME - Semi-manually doing it:
  PF="$( \dirname  "$PF" )/Program Files"
  # CSIDL_PROGRAM_FILESX86 0x002a
  PFx="$( \cygpath  --folder 0x002a )"
  # The Windows-style versions:
  wPF="$(  \cygpath  --mixed  "$PF"  )"
  wPFx="$( \cygpath  --mixed  "$PFx" )"
  # CSIDL_PROFILE 0x0028
  windows_home_as_linux="$( \cygpath  --folder 0x0028 )"
  windows_home_as_windows="$( \cygpath  --mixed  "$windows_home_as_linux" )"

  if [ $debug ]; then
    \echo  "PF   = $PF"
    \echo  "PFx  = $PFx"
    \echo  "wPF  = $wPF"
    \echo  "wPFx = $wPFx"
    \echo  "windows_home_as_linux   = $windows_home_as_linux"
    \echo  "windows_home_as_windows = $windows_home_as_windows"
  fi
}



geany() {  #  The GUI editor
  # The basic solution won't work with symbolic links:
  #\cygstart  '/c/Program Files (x86)/Geany/bin/geany.exe'  $*  &
  for file in $*; do
    if  [ -L "$file" ]; then
      string=${string}' '\"$( \cygpath  --dos  "$file" )\"
    else
      string=${string}' '\"$file\"
    fi
  done
  \cygstart  "$PFx/Geany/bin/geany.exe"  "$string" &
  \unset  string
}



\unset  debug










:<<'NOTES'
# It's probably just a lock on this file preventing ~/.zshrc source-ing it.
problem(){  # Fix startup freezing

# Problem:
# Windows file locking will hit $HISTFILE, causing a new shell to freeze on startup.

# Reproduction:
# Start one instance of Babun
# nano (this file), make no changes
# Start another instance of Babun
# Instance 2 freezes and never gets to the prompt.
# Exit nano from instance 1
# type rm (with nothing else)
# The prompt on instance 2 un-freezes

unsetopt inc_append_history
unsetopt share_history
# This frees up locks on $HISTFILE
\rm >> /dev/null &

# No luck with this
\flock  --unlock  "$0"
}
NOTES
