#!/bin/sh

commands=$(echo cmd_*.py | wc -w)
commands_loc=$(cat cmd_*.py | wc -l)
commands_defs=$(cat cmd_*.py | grep 'def ' | grep -v 'fatal\|usage\|error' | wc -l)
commands_classes=$(cat cmd_*.py | grep 'class ' | grep -v Error | wc -l)

modules=$(($(echo *.py | wc -w) - $commands ))
modules_loc=$(($(cat *.py | wc -l)-$commands_loc))
modules_defs=$(($(cat *.py | grep 'def ' | grep -v 'fatal\|usage\|error' | wc -l)-$commands_defs))
modules_classes=$(($(cat *.py | grep 'class ' | grep -v Error | wc -l)-$commands_classes))

echo "loc $(($commands_loc+$modules_loc))"
echo

# print stats for cli code
echo "commands $commands"
echo "commands_loc $commands_loc"
echo "commands_defs $commands_defs"
echo "commands_classes $commands_classes"

# print frequences for cli code
echo
echo "commands_loc/commands $(($commands_loc/$commands))"
echo "commands_loc/commands_defs $(($commands_loc/$commands_defs))"

echo

# print states for module code
echo "modules $modules"
echo "modules_loc $modules_loc"
echo "modules_defs $modules_defs"
echo "modules_classes $modules_classes"

echo

# print frequences for module code
echo "modules_loc/modules = $(($modules_loc/$modules))"
echo "modules_loc/modules_defs = $(($modules_loc/$modules_defs))"
[ $modules_classes != "0" ] && \
    echo "modules_loc/modules_classes = $(($modules_loc/$modules_classes))"
