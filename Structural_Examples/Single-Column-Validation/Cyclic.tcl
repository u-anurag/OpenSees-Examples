
set dataDir Cyclic;

set LCol $Lcol
  #
file mkdir $dataDir;
  
# Define RECORDERS -------------------------------------------------------------
 recorder Node -file $dataDir/Reaction.out -node 1  -dof 1   reaction;
 recorder Node -file $dataDir/Disp_node2.out -node 2 -dof 1   disp;
 
 #############

set ControlNode 2;
set ControlDOF  1;
set Dmax  [expr 40*$in];	# This is needed to initiate the analysis. Not ACTUALLY used in cyclic analysis. 
set Nsteps 10;

 ####
 ## assign lateral loads and create load pattern:  use ASCE 7-10 distribution
	set Hload 1.0;	# force on each frame node 2
	
	pattern Plain 200 Linear {			
		load $ControlNode $Hload 0 0;
	}
#

	set Tol			1.0e-9;
	set maxNumIter		1000;
	set printFlag		0;
	set algorithmType KrylovNewton;  # KrylovNewton  -maxDim 3

	constraints		Transformation;					# how it handles boundary conditions
	numberer		RCM;						# renumber dof's to minimize band-width (optimization)
	system			UmfPack;					# how to store and solve the system of equations in the analysis (large model: try UmfPack)
	test			EnergyIncr  $Tol $maxNumIter;		# tolerance, max iterations  (Try  EnergyIncr)
	algorithm		$algorithmType ;
	analysis		Static;					# define type of analysis: static for pushover

			# this will return zero if no convergence problems were encountered
 
 #####         /-- Cycle 1 --\ /-- Cycle 2 --\ for first step of the loading. 
 ##### Cycle 1 = 0 in. -> +0.04 -> 2 in. -> -0.08 -> -2 in. -> +0.04 -> 0 in.
 ##### at node 33,  Peak displacement  
 ##### integrator DisplacementControl $nodeTag $ndf $Dincr
 
 	 set Dincr [expr 0.0005*$LCol]   ; # 0.00005*$LCol = 0.2311 mm
	 puts "Dincr = $Dincr"
	 
	 foreach driftPeak {1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0} { ; # 0.25 0.5 0.75  3.0  ;  1% = 46.22 mm
	 	foreach Dmax "$driftPeak -$driftPeak -$driftPeak $driftPeak" {
			integrator DisplacementControl $ControlNode   $ControlDOF [expr $Dincr*$Dmax/$driftPeak]
			set ok [analyze [expr round(0.01*$driftPeak*$LCol/$Dincr)]]
			source SolverAlgorithms.tcl;
      
      if {$ok != 0 } {
        puts " Could not converge at [expr [nodeDisp $ControlNode $ControlDOF]*100/$LCol] % drift ratio."
        }

      if {$ok == 0 } {
        puts " Analysis converged at [expr [nodeDisp $ControlNode $ControlDOF]*100/$LCol] % drift ratio"
        }

		  }
	  }
	
	puts "Cyclic load analysis done";