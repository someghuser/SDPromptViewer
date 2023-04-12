#!/bin/bash
#
# make.sh - Compiles, installs, and uninstalls the SD Prompt Viewer plugin
#
# Author : Martin Rizzo | <martinrizzo@gmail.com>
# Date   : Mar 25, 2023
# License: http://www.opensource.org/licenses/mit-license.html [MIT License]
#-----------------------------------------------------------------------------
#                      Stable Diffusion Prompt Viewer
#       A plugin for "Eye of GNOME" that shows the embedded prompts.
#   
#     Copyright (c) 2023 Martin Rizzo
#     
#     Permission is hereby granted, free of charge, to any person obtaining
#     a copy of this software and associated documentation files (the
#     "Software"), to deal in the Software without restriction, including
#     without limitation the rights to use, copy, modify, merge, publish,
#     distribute, sublicense, and/or sell copies of the Software, and to
#     permit persons to whom the Software is furnished to do so, subject to
#     the following conditions:
#     
#     The above copyright notice and this permission notice shall be
#     included in all copies or substantial portions of the Software.
#     
#     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#     EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#     TORT OR OTHERWISE, ARISING FROM,OUT OF OR IN CONNECTION WITH THE
#     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#
#  plugin will be installed in:
#    ~/.local/share/eog/plugins/libsdprompt-viewer.so
#    ~/.local/share/eog/plugins/sdprompt-viewer.plugin
#    ~/.local/share/glib-2.0/schemas/org.gnome.eog.plugins.sdprompt-viewer.gschema.xml
#
SCRIPT_NAME=${BASH_SOURCE[0]##*/}
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCRIPT_HELP="
Usage: ./$SCRIPT_NAME [TARGET]

This script compiles, executes, installs, and uninstalls
the Stable Diffusion Prompt Viewer plugin for Eye of GNOME.

Available targets:
     build       Compiles the plugin.
     run         Runs Eye of GNOME with the plugin installed.
     clean       Removes files generated by compilation.
     install     Installs the plugin into Eye of GNOME.
     remove      Uninstalls the plugin from Eye of GNOME.

Example:
  ./$SCRIPT_NAME install   # Installs the plugin.
"


# IMPORTANT:
#   Directory where test images are located. These images are used
#   when running './make.sh run' to test the plugin functionality.
TEST_IMAGES_DIR="$HOME/Extra/Test"

# Directory where the GSettings schemas are stored
GIO_SCHEMAS_DIR="$HOME/.local/share/glib-2.0/schemas"

# Initialize script status to 0 (success)
SCRIPT_STATUS=0


#--------------------------------- TARGETS ---------------------------------#

build() {
  echo "Executing build command..."
  meson build && ninja -C build
  SCRIPT_STATUS=$?
}

run() {
  echo "Executing run command..."
  install
  if [ $SCRIPT_STATUS -eq 0 ]; then
    if [ -e "$TEST_IMAGES_DIR" ]; then
      EOG_DEBUG_PLUGINS='true'  eog "$TEST_IMAGES_DIR" & disown
    else
      EOG_DEBUG_PLUGINS='true'  eog &disown
    fi
  fi
}

clean() {
  echo "Executing clean command..."
  # check if the current directory is the source code directory
  if [[ -f "$SCRIPT_NAME" ]]; then
    rm -Rf 'build'
    SCRIPT_STATUS=0
  else 
    echo "ERROR: can´t remote the build directory"
    SCRIPT_STATUS=1
  fi
}

install() {
  echo "Executing install command..."
  meson build && ninja -C build install
  SCRIPT_STATUS=$?
}

remove() {
  echo "Executing remove command..."
  rm "$HOME/.local/share/eog/plugins/libsdprompt-viewer.so"
  rm "$HOME/.local/share/eog/plugins/sdprompt-viewer.plugin"
  rm "$GIO_SCHEMAS_DIR/org.gnome.eog.plugins.sdprompt-viewer.gschema.xml"
  glib-compile-schemas "$GIO_SCHEMAS_DIR"
}

#================================== START ==================================#

# if no arguments are provided, show the help message
if [ $# -eq 0 ]; then
  echo "$SCRIPT_HELP"
  exit 0
fi

# change to the script directory
cd "$SCRIPT_DIR"

# execute the appropriate function based on the first argument
case "$1" in
  build)
    build
    ;;
  run)
    run
    ;;
  clean)
    clean
    ;;
  install)
    install
    ;;
  remove)
    remove
    ;;
  *)
    echo "Invalid command: $1"
    echo "$SCRIPT_HELP"
    exit 1
    ;;
esac

echo "Exiting..."
exit $SCRIPT_STATUS
