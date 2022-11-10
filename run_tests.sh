#!/bin/bash

# Execute tests

# ----- START USER INPUTS ------

gems_code_dir="/home/chris/Research/Code/gems_adaptive/code"

# which optimization levels to test
# test_x: execute gems.x
# test_ON: test optimization level -ON
#   NOTE: execute must be in form "gems_ON.x", e.g. "gems_O3.x" for -O3
test_x=0
test_O0=0
test_O1=0
test_O2=0
test_O3=1

# what type of tests to execute
test_fom=1
test_static=1
test_adaptive=1

# what cases to test
test_flame=1
test_injector=0
test_duct=0

# ----- END USER INPUTS ------

# executable specification
declare -a exec_list=()
if [ ${test_x} -gt 0 ]; then
    exec_list+=("")
fi
if [ ${test_O0} -gt 0 ]; then
    exec_list+=("_O0")
fi
if [ ${test_O1} -gt 0 ]; then
    exec_list+=("_O1")
fi
if [ ${test_O2} -gt 0 ]; then
    exec_list+=("_O2")
fi
if [ ${test_O3} -gt 0 ]; then
    exec_list+=("_O3")
fi
if [ ${#exec_list[@]} -eq 0 ]; then
    echo "No executables specified, exiting..."
    exit
fi
# check that executables exist
for exec_file in "${exec_list[@]}"; do
    gems_exec=${gems_code_dir}/gems${exec_file}.x
    if [ ! -f ${gems_exec} ]; then
        echo "GEMS executable does not exist at ${gems_exec}"
    fi
done

# test type specification
declare -a type_list=()
if [ ${test_fom} -gt 0 ]; then
    type_list+=("fom")
fi
if [ ${test_static} -gt 0 ]; then
    type_list+=("static")
fi
if [ ${test_adaptive} -gt 0 ]; then
    type_list+=("adaptive")
fi
if [ ${#type_list[@]} -eq 0 ]; then
    echo "No test types specified, exiting..."
    exit
fi

# case specification
declare -a case_list=()
if [ ${test_flame} -gt 0 ]; then
    case_list+=("1d_flame")
fi
if [ ${test_injector} -gt 0 ]; then
    case_list+=("2d_injector")
fi
if [ ${test_duct} -gt 0 ]; then
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
        cp ../inputs/* . 2>/dev/null

        # set executable and run
        for exec_file in "${exec_list[@]}"; do
            gems_exec=${gems_code_dir}/gems${exec_file}.x
            echo "Executing ${gems_exec} for ${case_dir}/${type_dir}"
            sleep 2
            mpiexec -n ${np} ${gems_exec} 2>&1 | tee output${exec_file}.txt
            mv gemsma.res.dat gemsma.res.${exec_file}.dat
        done
    done
done

echo "Finished!"
