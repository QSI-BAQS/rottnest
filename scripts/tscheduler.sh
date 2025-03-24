
#!/bin/env
#
# Used to setup rottnest py once it has been downloaded


BUILDDIR=$1
cd $BUILDDIR/tscheduler
RESRET=$(pip install -e .)

if test $RESRET -ne 0; then
  echo 'Building tscheduler failed'
  exit 1
else
  exit 0
fi

