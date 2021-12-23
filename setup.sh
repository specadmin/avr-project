#!/bin/bash

rm -rf ./.git
rm -f Readme.md
git init
echo -n "Set git remote: "
read GIT_REMOTE
if [[ -n "$GIT_REMOTE" ]]; then
    git remote add origin $GIT_REMOTE
fi

git submodule add https://github.com/specadmin/avr-misc lib/avr-misc

echo -n "Add debug library? (y/n): "
read LIB_DEBUG
case $LIB_DEBUG in
    y|Y)
        git submodule add https://github.com/specadmin/avr-debug lib/avr-debug
        ;;
esac

echo -n "Add UART library? (y/n): "
read LIB_UART
case $LIB_UART in
    y|Y)
        git submodule add https://github.com/specadmin/avr-uart lib/avr-uart
        ;;
esac

echo -n "Add TWI/I2C library? (y/n): "
read LIB_TWI
case $LIB_TWI in
    y|Y)
        git submodule add https://github.com/specadmin/avr-twi lib/avr-twi
        ;;
esac

git add .
git commit -m "Initial commit"
