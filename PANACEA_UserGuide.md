# PANACEA USER GUIDE

## Running PANACEA
1. Unzip this package into a folder
2. Launch the PANACEA executable
3. Click on "Start Simulation"
4. Use the dialog to select the folder created when unzipping, and then select the desired configuration filed (base_config.json is initially provided)

## Modifying PANACEA simulation
The configuration file controls the conditons of the PANACEA simulation.  These can be modified to reflect different behaviors of the agent within the bounds of the hard-coded assumptions of the simulation engine.

#### Input files:
* Configuration file: A JSON formatted file of parameter keys and their values.
* Person file: defines the individuals and allows for scenaros where specific individuals are initially dosed with poison
* Schedule file:  defines where and when individuals go to different objects in the simulation.  The objects are defined within the "map" layer of the Godot project and thus requires manual effort to expand, however, within the framework of rooms and locations that exist, one could alter these schedules by maniputing this file.

#### Configuration Parameters
	"output_file": Simulation results, a time stamped collection of poison exchanges and absorption for people and objects are recorded in this JSON-formated file.

    ## Physics Values - Modify with care,these effect how the simulation runs, some values may result in unstable conditions for the simulator 
	"sim_speed_scale": 1.0,
	"save_every_s": 5,

    ## Main parameters
	"prob_poison_xfer": Probability of there being a transfer
	"person_to_obj_coeff": Proportion on person that transfers to the object
	"obj_to_person_coeff": Proportion on the Object that transfers to the person
	"max_person_gain": Maximum amount that can be transferred to a person
	"initial_poison":  Initial amount of poison at the entrance door
	"abs_tick_duration_m": Update timing for absorption in minutes, every X minutes the poison dosage and poison absorbed is updated based on the rates below
	"abs_fast_poison_threshold": Threshold dividing the linear (fast) and fractional (slow)absorption rates
	"abs_fast_rate_per_h": Units of poison absorbed by a person per hour when total dosage exceeds the threshold
	"abs_slow_frac_rate_per_h": Fraction of poison absorbed per hour when poison dosage is below the threshold
	"abs_obj_absorption_frac": Fraction of poison conveyed to an object that is absorbed by the object and thus not available for future transfers

## Batch processing
Batch processing can be acheived by running this in a headless mode from a terminal or power shell using the command:
``` panacea_v1-3.exe --headless -- --config <configuration_file> ```
We have successfully generate thousands of configurations each with different output names and then analyzed the resulting output files.  When running on a large scientific computing platform each run does not need much memory and thus many can processed in parallel.  