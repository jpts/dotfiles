#!/bin/bash

kitty-set-back-op() {
    pathmunge  /Applications/kitty.app/Contents/MacOS/

    kitty @ set-background-opacity "$1"
    kitty @ set-font-size "$2"
}

alias mode-demo='kitty-set-back-op 1.0 18 && clear'
alias mode-screenshare='kitty-set-back-op 1.0 16'
alias mode-screenshot='kitty-set-back-op 1.0 14'
alias mode-normal='kitty-set-back-op 0.85 14'
