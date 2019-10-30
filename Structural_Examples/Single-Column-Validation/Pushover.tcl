 set dataDir Pushover;
 file mkdir $dataDir;

 recorder Node -file $dataDir/Reaction.out -node 1  -dof 1   reaction;
 recorder Node -file $dataDir/Disp_node2.out -node 2 -dof 1   disp;
 
set ControlNode 2;
set ControlDOF  1;
set Dmax  [expr 0.15*$Lcol];
set Dincr  [expr 0.0005*$Lcol];
set Nsteps [expr int($Dmax/$Dincr)];

 ## assign lateral loads and create load pattern:  use ASCE 7-10 distribution
	set Hload 1.0;	# force on each frame node 2
	
	pattern Plain 200 Linear {			
					load $ControlNode   $Hload 0 0 ;
	}
#


# integrator LoadControl 0.1;

	set Tol			1.0e-9;
	set maxNumIter		1000;
	set printFlag		0;
	set TestType		EnergyIncr;
	set algorithmType Newton;  # KrylovNewton  -maxDim 3

	constraints Transformation;					# how it handles boundary conditions
	numberer RCM;						# renumber dof's to minimize band-width (optimization)
	system UmfPack;					# how to store and solve the system of equations in the analysis (large model: try UmfPack)
	test EnergyIncr  $Tol $maxNumIter;		# tolerance, max iterations  (Try  EnergyIncr)
	algorithm   $algorithmType ;
	integrator DisplacementControl  $ControlNode   $ControlDOF $Dincr;
	analysis Static;					# define type of analysis: static for pushover

	set ok [analyze $Nsteps];			# this will return zero if no convergence problems were encountered
 
  
if {$ok != 0} {  
	# if analysis fails, we try some other stuff, performance is slower inside this loop
	set Dstep 0.0;
	set ok 0
	while {$Dstep <= 1.0 && $ok == 0} {	
		set controlDisp [nodeDisp $ControlNode $ControlDOF ];   # current displacement of the node
		set Dstep [expr $controlDisp/$Dincr]
		set ok [analyze 1 ]
		# if analysis fails, we try some other stuff
		# performance is slower inside this loop	global maxNumIterStatic;	    # max no. of iterations performed before "failure to converge" is ret'd
			
			if {$ok != 0} {
				puts "Trying Newton with Initial Tangent .."
				algorithm Newton -initial
				set ok [analyze 1]
				algorithm $algorithmType
			}
			if {$ok != 0} {
				puts "Trying Broyden .."
				algorithm Broyden 8
				set ok [analyze 1 ]
				algorithm $algorithmType
			}
			if {$ok != 0} {
				puts "Trying NewtonWithLineSearch .."
				algorithm NewtonLineSearch 0.8 
				set ok [analyze 1]
				algorithm $algorithmType
			}
			if {$ok != 0} {
				puts "Trying KrylovNewton .."
				algorithm KrylovNewton 
				set ok [analyze 1];
				algorithm $algorithmType
			}
			if {$ok != 0} {
				puts "Trying reduced increment step .."
				set DincrReduced  [expr 0.5*$Dincr];
				algorithm KrylovNewton 
				set ok [analyze 2]
				algorithm $algorithmType
			}
	};	# end while loop
};      # end if ok !0
#

set finalDisp [nodeDisp $ControlNode $ControlDOF] ;
puts "displacement $finalDisp"

 if {$ok != 0 } {
  puts " Could not converge for  [expr 100*$finalDisp/$Lcol]% drift ratio "
  }
  
  if {$ok == 0 } {
    puts " Analysis converged at [expr 100*$finalDisp/$Lcol]% drift ratio"
  }
