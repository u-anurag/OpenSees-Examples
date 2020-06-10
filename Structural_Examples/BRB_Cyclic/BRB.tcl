#######################################################################################################
# BRB Component testing based on test 7 done by Xu (2016); 
# Download link - https://cdmbuntu.lib.utah.edu/utils/getfile/collection/etd3/id/4291/filename/4314.pdf
#
# By - Anurag Upadhyay
#      PhD Candidate
#      Civil and Environmental Engineering
#      University of Utah
# Learn More OpenSees Examples: https://anuragupadhyay.weebly.com/opensees.html
#######################################################################################################
#/
#    ^Y
#    |
#    |     2  __ 
#    |          | 
#    |          |
#    |          |
#  (1)       L_BRB
#    |          |
#    |          |
#    |          |
#          =1= _|_  -------->X
#

# SET UP ----------------------------------------------------------------------------
# units: kip, inch, sec
wipe;					# clear memory of all past model definitions

model BasicBuilder -ndm 2 -ndf 3;		# Define the model builder, ndm=#dimension, ndf=#dofs

set AnalysisType cyclic;    # axial, pushover, cyclic

#######################
## Units & Constants
#######################.

set in	1 ;
set kip 1 ;
set sec	1 ;

set ksi     [expr $kip/pow($in,2)]; 
set g		[expr 386.2*$in/pow($sec,2)];
set pi      [expr acos(-1.0)];

# define GEOMETRY -------------------------------------------------------------
set Lwp   [expr 219.0*$in]; 				# WorkPoint length  219. inch (Distance between the points where 
											#	center lines of the beam and the column meet at the connection.)
set Lcore [expr 157.0*$in]; 				# Length of the BRB core
set LR_BRB [expr $Lcore/$Lwp];				# Length ratio of the BRB
set Acore [expr 7.75*$in*$in];				# BRB Core area
set Aend  [expr 100.0*$in*$in];				# BRB End section area

# nodal coordinates:
node 1 0 0;			# node#, X, Y
node 2 0 $Lwp;	

# Single point constraints -- Boundary Conditions
fix 1 1 1 1; 			# node DX DY RZ
fix 2 0 0 1;


################################################################
### Define BRB Material 
################################################################

# BRB material here is defined as a combination of Steel02, Pinching and Fatigue material
# Mat1: Steel02 material has a symmetric hysteresis with isotropic and kinematic hardening properties, with no failure point.
# Mat2: Pinching material is used to add additional strength to the BRB material in compression due to friction. 
# Mat3: A new material is created by combining Steel02 and Pinching materials in parallel combination. 
# Mat4: Fatigue material is then used to wrap "Mat3" to simulate failure due to cyclic fatigue and/or ultimate tensile/compression strain.

set BRBMaterial_1 101;		# For Steel02
set BRBMaterial_2 102;		# For Pinching
set BRBMaterial_3 103;		# For parallel combination of Steel02 and Pinching
set BRBMaterial_4 104;		# For final BRB material with combination of Material3 and Fatigue 

########################
## Steel02 
########################

set R0   26;         
set cR1  0.910;      
set cR2  0.10;       

set a1    0.045;   	# Compression Part
set a2    1.02;    	

set a3    0.055;   	# Tension Part
set a4    1.0;   	

set si    0.1;

uniaxialMaterial Steel02  $BRBMaterial_1   [expr 40.2*$ksi]  [expr 29000.0*$ksi/$LR_BRB]   0.005  $R0 $cR1 $cR2  $a1 $a2 $a3 $a4 $si; 

###################
## Pinching 
###################
set pEnvelopeStress [list [expr 0.0001] [expr 0.0001] [expr 0.0001] [expr  0.0001]];
set nEnvelopeStress [list [expr -0.645] [expr -1.29] [expr -8.38] [expr -8.67]];
set pEnvelopeStrain [list [expr 0.0042] [expr 0.00636] [expr 0.023] [expr 0.042]];
set nEnvelopeStrain [list [expr -0.0001] [expr -0.0082] [expr -0.023] [expr -0.318]];
		

set rDisp  [list 1.0 0.5];
set rForce [list 0.4  0.4]; #0.0001 0.0001
set uForce [list 0.0  0.0];

set gammaK [list 0.5 0.1 0.15 0.1 0.45]; #
set gammaD [list 0.0 0.0 0.0 0.0 0.0];
set gammaF [list 0.0 0.0 0.0 0.0 0.0];
set gammaE 10.;

set dam "cycle";

uniaxialMaterial Pinching4 	$BRBMaterial_2 [lindex $pEnvelopeStress 0] [lindex $pEnvelopeStrain 0] [lindex $pEnvelopeStress 1] [lindex $pEnvelopeStrain 1] \
								[lindex $pEnvelopeStress 2] [lindex $pEnvelopeStrain 2] [lindex $pEnvelopeStress 3] [lindex $pEnvelopeStrain 3] \
								[lindex $nEnvelopeStress 0] [lindex $nEnvelopeStrain 0] [lindex $nEnvelopeStress 1] [lindex $nEnvelopeStrain 1] \
											[lindex $nEnvelopeStress 2] [lindex $nEnvelopeStrain 2] [lindex $nEnvelopeStress 3] [lindex $nEnvelopeStrain 3] \
											[lindex $rDisp 0] [lindex $rForce 0] [lindex $uForce 0] [lindex $rDisp 1] [lindex $rForce 1] [lindex $uForce 1] \
											[lindex $gammaK 0] [lindex $gammaK 1] [lindex $gammaK 2] [lindex $gammaK 3] [lindex $gammaK 4] \
											[lindex $gammaD 0] [lindex $gammaD 1] [lindex $gammaD 2] [lindex $gammaD 3] [lindex $gammaD 4] \
											[lindex $gammaF 0] [lindex $gammaF 1] [lindex $gammaF 2] [lindex $gammaF 3] [lindex $gammaF 4] $gammaE $dam


uniaxialMaterial Parallel 	$BRBMaterial_3 $BRBMaterial_1 $BRBMaterial_2 ;
uniaxialMaterial Fatigue	$BRBMaterial_4 $BRBMaterial_3 -E0  [expr 0.191*$LR_BRB]  -m  -0.671  -min  -0.035 -max  0.035;  # 0.458

#################
## BRB Element 
#################
element corotTruss   	1  1  2   $Acore	$BRBMaterial_4; 

puts "Model Built"


# DATA collection  
  set dataDir BRB_Output_Cyclic;		# Name of the output folder
  file mkdir $dataDir;					# Create the output folder
  
# Define RECORDERS -------------------------------------------------------------
recorder Element -file $dataDir/BRBforce.out		-ele 1 axialForce;			# Recorde axial force in BRB element
recorder Element -file $dataDir/BRBdeformation.out	-ele 1 deformations;		# Records axial deformation in BRB element
recorder Element -file $dataDir/Damage1Truss.out	-ele 1 material damage ;	# Records cyclic fatigue damage in BRB element 

 #############

set ControlNode 2;
set ControlDOF  2;

 ####
 ## assign lateral loads and create load pattern
	set Hload 1.0;	# force on each frame node 2
	
	pattern Plain 200 Linear {			
		load $ControlNode 0 -$Hload 0;
	}
#

	set Tol			1.0e-9;
	set maxNumIter		1000;
	set printFlag		0;
	set TestType		EnergyIncr;
	set algorithmType KrylovNewton;  # KrylovNewton  -maxDim 3

	constraints Transformation;					# how it handles boundary conditions
	numberer RCM;						# renumber dof's to minimize band-width (optimization)
	system UmfPack;					# how to store and solve the system of equations in the analysis (large model: try UmfPack)
	test EnergyIncr  $Tol $maxNumIter;		# tolerance, max iterations  (Try  EnergyIncr)
	algorithm   $algorithmType ;
	analysis Static;					# define type of analysis: static for pushover


 #####         /-- Cycle 1 --\ /-- Cycle 2 --\ for first step of the loading. 
 ##### Cycle 1 = 0 in. -> +0.04 -> 2 in. -> -0.08 -> -2 in. -> +0.04 -> 0 in.
 ##### at node 2,  Peak displacement  
 ##### integrator DisplacementControl $nodeTag $ndf $Dincr
 
 #### test starts in compression and hence Dincr is -ve to start from 0.
 
foreach Dincr {0.033 -0.066 0.033 0.033 -0.066 0.033 } {
  integrator DisplacementControl $ControlNode   $ControlDOF  [expr 0.25*$Dincr]
  set ok [analyze 40]
  source SolverAlgorithms.tcl;
}
  
foreach Dincr {0.085 -0.17 0.085 0.085 -0.17 0.085 } {
  integrator DisplacementControl $ControlNode   $ControlDOF  [expr 0.25*$Dincr]
  set ok [analyze 40]
  source SolverAlgorithms.tcl;
}

foreach Dincr {0.17 -0.34 0.17 0.17 -0.34 0.17 } {
  integrator DisplacementControl $ControlNode   $ControlDOF  [expr 0.25*$Dincr]
  set ok [analyze 40]
  source SolverAlgorithms.tcl;
}

foreach Dincr {0.258 -0.516 0.258 0.258 -0.516 0.258} {
  integrator DisplacementControl $ControlNode   $ControlDOF  [expr 0.25*$Dincr]
  set ok [analyze 40]
  source SolverAlgorithms.tcl;
}

foreach Dincr {0.34 -0.68 0.34 0.34 -0.68 0.34} {
  integrator DisplacementControl $ControlNode   $ControlDOF   [expr 0.25*$Dincr]
  set ok [analyze 40]
  source SolverAlgorithms.tcl;
}

foreach Dincr {0.452 -0.904 0.452  0.452 -0.904 0.452} {
  integrator DisplacementControl $ControlNode   $ControlDOF   [expr 0.25*$Dincr]
  set ok [analyze 40]
  source SolverAlgorithms.tcl;
}

#### Additional cycles for fatigue 

foreach Dincr {0.452 -0.904 0.452  0.452 -0.904 0.452} {
  integrator DisplacementControl $ControlNode   $ControlDOF   [expr 0.25*$Dincr]
  set ok [analyze 40]
  source SolverAlgorithms.tcl;
}
foreach Dincr {0.452 -0.904 0.452  0.452 -0.904 0.452} {
  integrator DisplacementControl $ControlNode   $ControlDOF   [expr 0.25*$Dincr]
  set ok [analyze 40]
  source SolverAlgorithms.tcl;
}
foreach Dincr {0.452 -0.904 0.452  0.452 -0.904 0.452} {
  integrator DisplacementControl $ControlNode   $ControlDOF   [expr 0.25*$Dincr]
  set ok [analyze 40]
  source SolverAlgorithms.tcl;
}


puts "Cyclic load analysis done";

  wipe;
