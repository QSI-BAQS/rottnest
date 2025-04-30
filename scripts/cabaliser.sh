

BUILDDIR=$1
source $BUILDDIR/venv/bin/activate
eval "$(pyenv init -)"
pyenv global 3.11
cd $BUILDDIR/cabaliser
cd c_lib

make all
RESRET=$?

if test $RESRET -ne 0; then
  echo 'Building cabaliser-lib failed'
  exit 1
fi

cd ..
pip install -e .
RESRET=$?

if test $RESRET -ne 0; then
  echo 'Building cabaliser-python api failed'
  exit 1
fi


