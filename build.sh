if [ -z "${PYTHONPATH-}" ]
then export PYTHONPATH=./python
else PYTHONPATH=./python\;$PYTHONPATH
fi
mkdocs build