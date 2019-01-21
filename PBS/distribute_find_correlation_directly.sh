#!/bin/bash
# -------------------------------Get Inputs--------------------------------
# Give the etarange
Etarange=($(seq 0.005 0.005 1))

# Give the control parameter range
CPRange=($(seq -1 0.01 0))

# Give the correlation type
CorrelationType="Pearson"

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

    sed "s/xxNamexx/$Name/g" PBS_run_find_correlation_directly.sh > "$Name.sh"
    sed -i "s/xxSubEtarangexx/[${SubEtarange[*]}]/g" "$Name.sh"
    sed -i "s/xxDirectionsxx/$Directions/g" "$Name.sh"
    sed -i "s/xxCPRangexx/$CPRange/g" "$Name.sh"
    sed -i "s/xxCorrelationTypexx/$CorrelationType/g" "$Name.sh"

    qsub "$Name.sh"

    rm "$Name.sh"

fi
done
