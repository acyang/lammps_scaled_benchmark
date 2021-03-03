#!/bin/bash

NODE_GRID=(8 5 1)
CORE_GRID=(1 2 28)

for sf in intel opt
do
    if [ -d ${sf} ]; then
        echo "Foler ${sf} already exist. Skip!"
    else
        mkdir ${sf}
        echo "Foler ${sf} doesn't exist. Create it!"
    fi
    cd ${sf}
    for problem in lj eam sw tersoff
    do
        if [ -d ${problem} ]; then
            echo "Foler ${problem} already exist. Skip!"
        else
            mkdir ${problem}
            echo "Foler ${problem} doesn't exist. Create it!"
        fi
        cd ${problem}
        for size in 32000 64000 128000 256000 512000
        do
            if [ -d ${size} ]; then
                echo "Foler ${size} already exist. Skip!"
            else
                mkdir ${size}
                echo "Foler ${size} doesn't exist. Create it!"
            fi
            cd ${size}
            case "${size}" in
                "32000")
                    LATTICE_GRID=(20 20 10)
                ;;
                "64000")
                    LATTICE_GRID=(20 20 20)
                ;;
                "128000")
                    LATTICE_GRID=(40 20 20)
                ;;
                "256000")
                    LATTICE_GRID=(40 40 20)
                ;;
                "512000")
                    LATTICE_GRID=(40 40 40)
                ;;
                *)
                    echo "No match case"
                ;;
            esac
            for scale in 40 80 160 320 640 800
            do
                if [ -d ${scale} ]; then
                    echo "Foler ${scale} already exist. Skip!"
                else
                    mkdir ${scale}
                    echo "Foler ${scale} doesn't exist. Create it!"
                fi
                cd ${scale}
                cp -f ../../../../templates/in.${problem}.tmp in.${problem}
                cp -f ../../../../templates/job.sh.tmp job.sh
                case "${scale}" in
                    "40")
                        SCALE_GRID=(1 1 1)
                    ;;
                    "80")
                        SCALE_GRID=(2 1 1)
                    ;;
                    "160")
                        SCALE_GRID=(2 2 1)
                    ;;
                    "320")
                        SCALE_GRID=(2 2 2)
                    ;;
                    "640")
                        SCALE_GRID=(4 2 2)
                    ;;
                    "800")
                        SCALE_GRID=(4 5 1)
                    ;;
                    *)
                        echo "No match case"
                    ;;
                esac
                PROC_GRID[0]=$(( ${NODE_GRID[0]}*${CORE_GRID[0]}*${SCALE_GRID[0]} ))
                PROC_GRID[1]=$(( ${NODE_GRID[1]}*${CORE_GRID[1]}*${SCALE_GRID[1]} ))
                PROC_GRID[2]=$(( ${NODE_GRID[2]}*${CORE_GRID[2]}*${SCALE_GRID[2]} ))
                echo "Repeat system in three dimension: ${PROC_GRID[@]}"
                sed -i "s/@NODES/${scale}/g" job.sh
                sed -i "s/@NAME/${sf}-${scale}/g" job.sh
                sed -i "s/@SF/${sf}/g" job.sh
                sed -i "s/@INPUT/in.${problem}/g" job.sh
                sed -i "s/@NX/${PROC_GRID[0]}/g" job.sh
                sed -i "s/@NY/${PROC_GRID[1]}/g" job.sh
                sed -i "s/@NZ/${PROC_GRID[2]}/g" job.sh

                sed -i "s/@LX/${LATTICE_GRID[0]}/g" in.${problem}
                sed -i "s/@LY/${LATTICE_GRID[1]}/g" in.${problem}
                sed -i "s/@LZ/${LATTICE_GRID[2]}/g" in.${problem}
                cd ..
            done
            cd ..
        done
        cd ..
    done
    cd ..
done