# 454meta_simulator

edit script/config.log, user config section
run ./submit

1-Calculator
takes the given profile and calculates how many reads are needed for each genome
the calculator give a report.log as output with the following informations :
name    real number of reads needed     rounded number of reads needed

In the general output file (scripts/out/01-Profile_calculator), is printed the real number of reads that will be produced (because of the rounding system, the actual number of read can be different from the input number of reads).

The Calculator step also defines the size of reads that the artificial datasets need in order to obtain a gaussian distribution of read size. The parameter of the gaussian distribution can be modified by editing the gaussian.py file. 
gaussian.py will create a log containing the read sizes for the artificial dataset (gaussian.log)

2-Simulator
After splitting workload on the nodes using array jobs, each independant workflows compute the random selection of reads from the genomes using the gaussian size distribution. Theses artificial reads are available in the artificial_${GENOME_NAME}.fna file. 
Errors are added to the artificial reads. Two different models are availables (model 1 and 2). The model choice is can be modify by the user in the config.sh file. 
The artificial reads with error added are available in the err_artificial_${GENOME_NAME}.fna files.

