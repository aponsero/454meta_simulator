# 454meta_simulator

This pipeline is a basic 454 metagenome simulator. This is intended to be run on an HPC with a PBS scheduler.

## Calculator
takes the given profile and calculates how many reads are needed for each genome
the calculator give a report.log as output with the following informations :
- name
- real number of reads needed
- rounded number of reads needed

In the general output file (scripts/out/01-Profile_calculator), is printed the real number of reads that will be produced (because of the rounding system, the actual number of read can be different from the input number of reads).

The Calculator step also defines the size of reads that the artificial datasets need in order to obtain a gaussian distribution of read size. The parameter of the gaussian distribution can be modified by editing the gaussian.py file. 
gaussian.py will create a log containing the read sizes for the artificial dataset (gaussian.log)

## Simulator
After splitting workload on the nodes using array jobs, each independant workflows compute the random selection of reads from the genomes using the gaussian size distribution. Theses artificial reads are available in the artificial_${GENOME_NAME}.fna file. 
Errors are added to the artificial reads. Three different models are availables (model 1 to 3). The model choice is can be modify by the user in the config.sh file. 
The artificial reads with error added are available in the err_artificial_${GENOME_NAME}.fna files.

## Quick start

### Edit scripts/config.sh file

please modify the

  - OUT_DIR = indicate here the output directory path
  - NB_READ = indicate here the total number of simulated read to produce
  - PROFILE= indicate here the text file containing the community profile. The profile should be under this format :
      name_genome \t percentage_of_the_population
  - DB_DIR = indicate here the folder containing the genomes to use for the simulated metagenome. The files names of the genomes should be under the format "name_genome.fna"
  - MODEL_CHOICE = error model. Choose error model 1, 2 or 3
  - MAIL_USER = indicate here your arizona.edu email
  - GROUP = indicate here your group affiliation

You can also modify

  - MAIL_TYPE = change the mail type option. By default set to "bea".
  - QUEUE = change the submission queue. By default set to "standard".
  
  ### Run the calculator
  
  Run ./1_submit.sh
  
  This command will submit 1 job. Once the job is run, the second command can be submitted.
  
  ### Run simulator
  
  Run ./2_submit.sh
  
  Will place in queue 2 successive jobs in queue.
