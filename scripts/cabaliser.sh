BUILDDIR=$1
cd $BUILDDIR/cabaliser
cd c_lib
RESRET=$(make all)

if test $RESRET -ne 0; then
  echo 'Building cabaliser-lib failed'
  exit 1
else
  exit 0
fi

cd ..
RESRET=$(pip install -e .)

if test $RESRET -ne 0; then
  echo 'Building cabaliser-python api failed'
  exit 1
else
  exit 0
fi


