# ------------------------------------------------------------------------------------------------------------------------
# Anurag Upadhyay. February 25, 2015.
# PhD Candidate, University of Utah
# ------------------------------------------------------------------------------------------------------------------------
#
# Units: kip and in
#
# X	Longitudinal direction
# Y	Height direction

# ANALYSIS CONFIGURATIONS 
set AnalysisType  gravity   ;      # gravity, Pushover, dynamic, IDA, Cyclic, MomentCurvature

model BasicBuilder -ndm 2 -ndf 3;	# Two dimensions & three degrees of freedom

####################
########### US UNITS
####################
set kip  1.0;				# Kips
set in    1.0;				# inch
set sec   1.0;				# second

###########################
########### DEPENDENT UNITS
###########################

set ft      [expr $in*12];
set lb      [expr $kip/1000];
set ksi     [expr $kip/pow($in,2)];  
set psi     [expr $lb/pow($in,2)];
set ksi_psi [expr $ksi/$psi];
set sq_in	[expr $in*$in];

####################
########## CONSTANTS
####################

set g		[expr 386.2*$in/pow($sec,2)];
set pi      [expr acos(-1.0)];

###################
## Dimensions
###################

set Lcol  [expr 8.00*$ft]; #  Length of the column
set Dcol  [expr 21.56*$in];	# Column Diameter	
set Dbar  [expr 1.00*$in];	# Diameter of each longitudinal rebar
set Abar  [expr 0.79*$in*$in];	# Area of each longitudinal rebar
set s_bar [expr 2.50*$in];	# spacing between horizontal reinforcement / Spiral reinforcement
set cover [expr 2.00*$in];	# Concrete clear cover

 ########## CROSS-SECTION PROPERTIES
set Acol  [expr (($pi*$Dcol**2)/4)];		# Area of column
set Jcol  [expr ($pi*($Dcol/2)**4)/2];		
set I3col [expr ($pi*($Dcol/2)**4)/4];
set I2col [expr ($pi*($Dcol/2)**4)/4];

 ##############################
 ########## MATERIAL PROPERTIES
 ##############################

set ConcreteType Concrete02;                                 # (Concrete01, Concrete02, Hysteretic02)                                 
set SteelType    Steel02;                                    # (Steel02, ReinforcingSteel, Hysteretic)

set IDconcCore 		1; 			# material ID tag -- core concrete
set IDconcCover 	2;         
set IDreinf 		  3; 				# material ID tag -- reinforcement

set fc            [expr 6.7*$ksi];							# Test Day Concrete Strength OR 28 days Compressive Strength
set Ec            [expr 1820*pow($fc,0.5)*$ksi];			# should be in 'ksi' units
set Uc            0.2;										# Poisson's ratio
set Gc            [expr $Ec/(2*(1+$Uc))];					# Shear Modulus of Elasticity
set wconc	      [expr 143.96*$lb/pow($ft,3)];				# Normal Concrete Weight per Volume                                    
set mconc	      [expr 143.96*$lb/pow($ft,3)/$g];			# Normal Mass Weight per Volume

# ######## Confined Concrete ###########
set fc1 			[expr -1.3*$fc];			# CONFINED concrete strength (Use mender's equation to calculate), peak stress
set eps1			-0.0075;					# strain corresponding to maximum strength of confined concrete
set fc2 			[expr -5.0*$ksi];			# ultimate stress  
set eps2	 		-0.02;						# strain at ultimate stress  (or Crushing strain of confined concrete)
set lambda 			0.1;						# ratio between unloading slope at $eps2 and initial slope $Ec (See http://opensees.berkeley.edu/wiki/index.php/Concrete02_Material_--_Linear_Tension_Softening)
set Ets				$Ec;
set ft 				[expr 0.0*$fc];

uniaxialMaterial Concrete02 $IDconcCore $fc1 $eps1 $fc2 $eps2 $lambda $ft $Ets
uniaxialMaterial Concrete04 $IDconcCover -$fc -0.0030 -0.009 $Ec; # $ft $et $beta;


 ##### Steel Parameters

set Es           [expr 29000.*$ksi];	# modulus of steel
set Us           0.2;					# Poisson's ratio
set Gs           [expr $Es/(2*(1+$Us))];	# Shear Modulus of Elasticity
set fy           [expr 76*$ksi];		# Actual Yield Strength
#
set Fy		$fy;				# Yield strength, 
set Fu		[expr 1.35*$fy];	# Ultimate strength,  
set Esh		[expr 0.15*$Es];	# Tangent at initial strain hardening 
set esh           0.004;		# Strain corresponding to initial strain hardening
set esu           0.060;		# Strain at peak stress

# Additional parameters for reinforcing steel material (see: http://opensees.berkeley.edu/wiki/index.php/Reinforcing_Steel_Material)
set lsr      	[expr $s_bar/$Dbar];
set betaR     	1;
set rR       	0.4;
set gammaR    	0.5;

set Cf  	0.26;
set alpha 	0.506;
set Cd  	0.389;


set Bs 		0.005;								# strain-hardening ratio 
set R0 		18;						  			# control the transition from elastic to plastic branches
set cR1 	0.925;								# control the transition from elastic to plastic branches
set cR2 	0.15;							  	# control the transition from elastic to plastic branches
set a1    	0.03;   #default=0
set a2    	1.0;   	#default=1.0
set a3    	0.03;   #default=0
set a4    	1.0;   	#default=1.0
set si    	0.0;


uniaxialMaterial ReinforcingSteel $IDreinf $Fy $Fu $Es $Esh $esh $esu  -GABuck $lsr $betaR $rR $gammaR ; #  -CMFatigue $Cf $alpha $Cd; 
#uniaxialMaterial Steel02 $IDreinf $Fy $Es $Bs $R0 $cR1 $cR2;	

 ##########################
 ########## NODE ASSIGNMENT
 ##########################

node 1 0 0;
node 2 0 $Lcol;

 ########################
 ############ CONSTRAINTS            ### can be added to the nodes file
 ########################

fix	1		1	1	1;

 #########################################
 ############## COLUMN FIBER CROSS-SECTION
 #########################################

set ColSecTag			1;			# Column's cross-section tag

set yCenter		      	[expr 0.00*$in];		# y coordinate of the center of the circle
set zCenter		      	[expr 0.00*$in];		# z coordinate of the center of the circle

set numBarCol 6;                               # Number of rebar per column

set numSubdivCircCore	$numBarCol;			# Number of subdivisions (fibers) in the circumferential direction for core concrete
set numSubdivRadCore	11;			# Number of subdivisions (fibers) in the radial direction for the core concrete
set intRadCore			[expr 0.00*$in];		# Internal radius of core concrete
set extRadCore			[expr $Dcol/2 -$cover];  # External radius of core concrete

set numSubdivCircCover	$numBarCol;	            # Number of subdivisions (fibers) in the circumferential direction for cover concrete
set numSubdivRadCover	[expr 2];			# Number of subdivisions (fibers) in the radial direction for cover concrete
set intRadCover			[expr $Dcol/2-$cover];	# Internal radius of the cover concrete
set extRadCover			[expr $Dcol/2];		# External radius of the cover concrete

set numBar				$numBarCol;			      # Number of reinforcing bars along layer
set areaBar				$Abar;	      # Area of individual reinforcing bar
set radius				[expr ($Dcol/2)-$cover-($Dbar/2)];# Radius of reinforcing layer
set theta				[expr 360.0/$numBarCol];	# Angle increment between bars
# 
section Fiber $ColSecTag {
		patch circ $IDconcCore  $numSubdivCircCore  $numSubdivRadCore  $yCenter $zCenter $intRadCore  $extRadCore 0.0 360.0;  #Core
		patch circ $IDconcCover $numSubdivCircCover $numSubdivRadCover $yCenter $zCenter $intRadCover $extRadCover 0.0 360.0;  #Cover
		layer circ $IDreinf     $numBar $areaBar $yCenter $zCenter $radius $theta 360.0;
	}

 #############################################
 ############### ELEMENTS ####################
 #############################################

set TransfType PDelta;
geomTransf $TransfType 1 ;

# Define Beam-Column Elements
set np 3;					   # number of Gauss integration points for nonlinear curvature distribution-- np=2 for linear distribution ok
#
element nonlinearBeamColumn	1	1   2		$np	 $ColSecTag		1;	# Column			

 ################################
 ################ GRAVITY LOADING
 ################################
set Weight [expr abs(0.10*$fc1*$Acol)];

mass 2 [expr $Weight/$g] [expr $Weight/$g] 0.; 

pattern Plain 3 Linear {
#	Joint		X		Y				xx												
  load	2		0.000		-$Weight		0.000		;	#Column
};

 ###################################
 ################## STATIC  ANALYSIS
 ###################################
 file mkdir Gravity
 
  recorder Node -file Gravity/Reaction.out -node 1 -dof 2 reaction;		# support reaction
  recorder Element -file Gravity/Concrete.out -ele 1 section 1 fiber 0 0 $IDconcCore stressStrain; # y,z location of fiber

set Tol 1.0e-8;			      # convergence tolerance for test
constraints Plain;     		# how it handles boundary conditions
numberer Plain;			      # renumber dof's to minimize band-width (optimization), if you want to
system BandGeneral;	    	# how to store and solve the system of equations in the analysis
test NormDispIncr $Tol 6 ; 		# determine if convergence has been achieved at the end of an iteration step
algorithm Newton;			        # use Newton's solution algorithm: updates tangent stiffness at every iteration
set NstepGravity 10;  		    # apply gravity in 10 steps
set DGravity [expr 1./$NstepGravity]; 	# first load increment;
integrator LoadControl $DGravity;	      # determine the next time step for an analysis
analysis Static;			                  # define type of analysis static or transient
analyze $NstepGravity;		              # apply gravity

loadConst -time 0.0;

# MODAL ANALYSIS 
  set wa			[eigen -fullGenLapack  2];
  set wwa1		      [lindex $wa 0];
  set wwa2		      [lindex $wa 1];

  set Ta1			[expr 2*$pi/sqrt($wwa1)];
  set Ta2			[expr 2*$pi/sqrt($wwa2)];

  puts "Fundamental-Period after Gravity Analysis:"
  puts "Period1= $Ta1"
  # puts "Period2= $Ta2" 

# ####################################################################################
# #### Analysis Options ##############################################################
# ####################################################################################

puts "Model Built"

if {$AnalysisType == "gravity"} {
  puts "Gravity analysis done"
}
#
if {$AnalysisType == "Pushover"} {
  source Pushover.tcl
 }

if {$AnalysisType == "Cyclic"} {
  source Cyclic.tcl
}
#
if {$AnalysisType == "MomentCurvature"} {
  source MCanalysis.tcl
}
 wipe ;
