#!/bin/bash
set -e

MODE="$1"

# fallback default
if [ -z "$MODE" ]; then
  MODE="lab"
fi

JUPYTER_ARGS="--ip=0.0.0.0 --no-browser --ServerApp.token='' --notebook-dir=/home/$NB_USER"

if [ -n "$JUPYTER_PASSWORD" ]; then
  JUPYTER_ARGS="$JUPYTER_ARGS --ServerApp.password=$JUPYTER_PASSWORD"
fi

echo "Starting Jupyter in mode: $MODE as user $NB_USER"
echo "Jupyter config generated at $JUPYTER_CONFIG_DIR"

if [ "$MODE" == "lab" ]; then
  exec start-notebook.sh --LabApp.default_url=/lab $JUPYTER_ARGS
elif [ "$MODE" == "notebook" ]; then
  exec start-notebook.sh $JUPYTER_ARGS
else
  echo "Unknown mode: $MODE"
  exit 1
fi


