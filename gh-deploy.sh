if [ -z "${PYTHONPATH-}" ]
then export PYTHONPATH=./python
else PYTHONPATH=./python\;$PYTHONPATH
fi
mkdocs gh-deploy --remote-branch docs