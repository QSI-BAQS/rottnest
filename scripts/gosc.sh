BUILDDIR=$1
cd $BUILDDIR/gosc-graph-state-generation
RESRET=$(pip install -e .)

if test $RESRET -ne 0; then
  echo 'Building gosc-graph-state-generation failed'
  exit 1
else
  exit 0
fi

