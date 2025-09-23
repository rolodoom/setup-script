#!/bin/bash
# check_libfuse.sh - Checks if libfuse2t64 package is installed and optionally installs it
# Assumes notify function is already loaded

check_libfuse() {
  if ! dpkg -s libfuse2t64 >/dev/null 2>&1; then
    read -p "libfuse2t64 is not installed. Do you want to install it now? [y/N]: " answer
    if [ "$answer" = "y" ]; then
      sudo apt install libfuse2t64
      return $?
    else
      notify "libfuse2t64 not installed. Cannot proceed." "error"
      return 1
    fi
  fi
  return 0
}
