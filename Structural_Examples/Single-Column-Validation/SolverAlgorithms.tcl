# Procedure to try additional algorithms


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
			puts "Trying KrylovNewton .."
			algorithm KrylovNewton 
			set ok [analyze 1];
			algorithm $algorithmType
			}
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
	};	# end while loop
};      # end if ok !0

 
 if {$ok != 0 } {
  puts " Could not converge at [nodeDisp $ControlNode $ControlDOF] mm"
  }
  
  if {$ok == 0 } {
    puts " Analysis converged at node $ControlNode displacement [nodeDisp $ControlNode $ControlDOF] mm"
  }
