
#!/bin/env
#
# Used to setup rottnest py once it has been downloaded


BUILDDIR=$1
source $BUILDDIR/venv/bin/activate
eval "$(pyenv init -)"
pyenv global 3.11
cd $BUILDDIR/tscheduler
pip install -e .

RESRET=$?
if test $RESRET -ne 0; then
  echo 'Building tscheduler failed'
  exit 1
else
  exit 0
fi

