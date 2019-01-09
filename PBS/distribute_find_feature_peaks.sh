#!/bin/bash
# -------------------------------Get Inputs--------------------------------
# Give the etarange
Etarange=($(seq 0 0.1 1))

# Give the desired number of jobs (+- 1)
NumJobs=5

# Give the direction of each operation (will be filled automatically if completely empty)
Directions="[]"


---------------------------------------------------------------------------

# Calculate the step needed
let Step=(${#Etarange[@]}+$NumJobs-1)/$NumJobs



for i in $(seq 1 $NumJobs); do
SubEtarange=(${Etarange[@]:($i-1)*Step:$Step})
if [ ! -z $SubEtarange ]
then
    Name=$"res$i"

    sed "s/xxNamexx/$Name/g" PBS_run_find_feature_peaks.sh > "$Name.sh"
    sed -i "s/xxSubEtarangexx/[${SubEtarange[*]}]/g" "$Name.sh"
    sed -i "s/xxDirectionsxx/$Directions/g" "$Name.sh"

    qsub "$Name.sh"

    rm "$Name.sh"

fi
done
