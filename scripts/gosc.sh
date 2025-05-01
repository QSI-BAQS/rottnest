


BUILDDIR=$1
source $BUILDDIR/venv/bin/activate
eval "$(pyenv init -)"
pyenv global 3.11
cd $BUILDDIR/gosc-graph-state-generation
pip install -e .

RESRET=$?
if test $RESRET -ne 0; then
  echo 'Building gosc-graph-state-generation failed'
  exit 1
else
  exit 0
fi

