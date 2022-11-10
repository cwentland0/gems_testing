#!/bin/bash

# Cleans ALL files

inp=""
echo "WARNING: CLEANING ALL RUN DIRECTORIES"
read -p "To proceed, enter \"yes\": " inp
if [ ${inp} != "yes" ]; then
    echo "Exiting..."
    exit
fi

declare -a case_list=('1d_flame')
#declare -a case_list=('1d_flame' '2d_injector' '3d_duct')
declare -a type_list=('fom' 'static' 'adaptive')

declare -a del_dirs=('AveFieldResults' 'FaceIntegralResults' 'PointResults' 'RestartFiles' 'UnsteadyFieldResults' 'VolIntegralResults' 'Warnings')
declare -a del_files=('output*.txt' 'gemsma.res.*dat' 'wall_time.dat')

declare -a spec_files
for case_dir in "${case_list[@]}"; do
    
    if [ ${case_dir} == '1d_flame' ]; then
        spec_files=('global1.chem' 'thermo.chem' 'trans.chem')
    elif [ ${case_dir} == "2d_injector" ]; then
        spec_files=()
    elif [ ${case_dir} == "3d_duct" ]; then
        spec_files=()
    else
        echo "Something went wrong setting spec_files, exiting..."
        exit
    fi

    for type_dir in "${type_list[@]}"; do

        exec_dir=${case_dir}/${type_dir}
        for del_dir in "${del_dirs[@]}"; do
            rm -rf ${exec_dir}/${del_dir}
        done
        for del_file in "${del_files[@]}"; do
            rm -f ${exec_dir}/${del_file}
        done
        for spec_file in "${spec_files[@]}"; do
            rm -f ${exec_dir}/${spec_file}
        done
    done
done

echo "Finished"
