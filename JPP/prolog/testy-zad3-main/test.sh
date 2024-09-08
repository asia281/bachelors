#!/bin/bash

set -e # exit on failures

function _run_test() {
    echo "Command: ./solution $2 < $1.in > user.out"
    ./solution $2 < $1.in > user.out
    set +e # still continue when output differs
    diff --color=always $1.out user.out
    if [ $? == 0 ]; then
        echo "OK"
        passed=1
    else
        echo "Error: output differs from $1.out"
        passed=0
    fi
    echo ""
    set -e
}

function run_test() {
    echo "Running test $1.."
    _run_test $1 $2
}

function run_test_with_readme() {
    echo "Running test $1 (read $1.md for explanation).."
    _run_test $1 $2
}

make
echo ""

run_test warmup tatry.txt
if [ $passed == 0 ]; then
    echo "Warmup didn't pass, skipping other tests."
    # that's because test_correctness.py requires warmup to pass
    exit 1
fi

echo "Command: python test_correctness.py"
python3 test_correctness.py
echo ""
run_test multiple_same_types tatry.txt
run_test invalid_conditions tatry.txt
run_test_with_readme invalid_names tatry.txt
run_test_with_readme weird_names weird_names.txt
run_test_with_readme loops loops.txt
run_test_with_readme invalid_argument invalid_file.txt
run_test_with_readme multiple_invalid_conditions tatry.txt
echo "Testing finished."
