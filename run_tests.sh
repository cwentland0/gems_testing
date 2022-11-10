#!/bin/bash

# Execute tests

# ----- START USER INPUTS ------

gems_code_dir="/home/chris/Research/Code/gems_adaptive/code"

# which optimization levels to test
# test_x: execute gems.x
# test_ON: test optimization level -ON
#   NOTE: execute must be in form "gems_ON.x", e.g. "gems_O3.x" for -O3
test_x=1
test_O0=0
test_O1=0
test_O2=0
test_O3=0

# what type of tests to execute
test_fom=1
test_static=0
test_adaptive=0

# what cases to test
test_flame=1
test_injector=0
test_duct=0

# ----- END USER INPUTS ------

# executable specification
declare -a exec_list=()
if [ ${test_x} -eq 1 ]; then
    exec_list+=("gems.x")
fi
if [ ${test_O0} -eq 1 ]; then
    exec_list+=("gems_O0.x")
fi
if [ ${test_O1} -eq 1 ]; then
    exec_list+=("gems_O1.x")
fi
if [ ${test_O2} -eq 1 ]; then
    exec_list+=("gems_O2.x")
fi
if [ ${test_O3} -eq 1 ]; then
    exec_list+=("gems_O3.x")
fi
if [ ${#exec_list[@]} -eq 0 ]; then
    echo "No executables specified, exiting..."
    exit
fi
# check that executables exist
for exec_file in "${exec_list[@]}"; do
    gems_exec=${gems_code_dir}/${exec_file}
    if [ ! -f ${gems_exec} ]; then
        echo "GEMS executable does not exist at ${gems_exec}"
    fi
done

# test type specification
declare -a type_list=()
if [ ${test_fom} -eq 1 ]; then
    type_list+=("fom")
fi
if [ ${test_static} -eq 1 ]; then
    type_list+=("static")
fi
if [ ${test_adaptive} -eq 1 ]; then
    type_list+=("adaptive")
fi
if [ ${#type_list[@]} -eq 0 ]; then
    echo "No test types specified, exiting..."
    exit
fi

# case specification
declare -a case_list=()
if [ ${test_flame} -eq 1 ]; then
    case_list+=("1d_flame")
fi
if [ ${test_injector} -eq 1 ]; then
    case_list+=("2d_injector")
fi
if [ ${test_duct} -eq 1 ]; then
    case_list+=("3d_duct")
fi
if [ ${#case_list[@]} -eq 0 ]; then
    echo "No test cases specified, exiting..."
    exit
fi

basedir=${PWD}
for case_dir in "${case_list[@]}"; do

    # set number of processes for case
    if [ ${case_dir} == "1d_flame" ]; then
        np=2
    elif [ ${case_dir} == "2d_injector" ]; then
        np=2
    elif [ ${case_dir} == "3d_duct" ]; then
        np=10
    else
        echo "Something went wrong setting np, exiting..."
        exit
    fi

    for type_dir in "${type_list[@]}"; do

        # enter working directory and copy inputs
        cd ${basedir}/${case_dir}/${type_dir}
        cp ../inputs/* .

        # set executable and run
        for exec_file in "${exec_list[@]}"; do
            gems_exec=${gems_code_dir}/${exec_file}
            mpiexec -n ${np} ${gems_exec} 2>&1 | tee output.txt
        done
    done
done

echo "Finished!"
