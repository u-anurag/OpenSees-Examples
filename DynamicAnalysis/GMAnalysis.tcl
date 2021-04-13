
# ##################################
# Prepared by - Anurag Upadhyay, PhD Student, Civil and Environmental Engineering
#               University of Utah, Salt Lake City, UT - 84112
# Date - 3/14/2016
# Prepared for - Analysis of a 3 column bridge bent for earthquake retrofit
# ##################################


#source $SourceDir/$GMDetails;
set GM_MAJ $SourceDir/$GMfileMAJ;
set GM_MIN $SourceDir/$GMfileMIN;
set ExtendedT [expr int($totalT + 5/$dT)];
	    
# DATA collection

set SF_MAJ [expr $Sa*$g/$Sa1MAJ];
set SF_MIN [expr $Sa*$g/$Sa1MIN];
file mkdir $dataDir;

set FinishTfile "$dataDir/FinishTime.txt"
  
# Define RECORDERS -------------------------------------------------------------
recorder Drift -file $dataDir/Drift_1.out -time -iNode 42 -jNode 43 -dof 1 -perpDirn 3;
recorder Node -file $dataDir/ReactionsBent.out  -node 4100011 6100011 -dof 1 2 3 reaction;		# support reaction at column 1
recorder Node -file $dataDir/ReactionsAbutmentA.out  -node 10010 10011 10012 -dof 1 2 3 reaction;		# support reaction at column 1
recorder Node -file $dataDir/ReactionsAbutmentB.out  -node 20010 20011 20012 -dof 1 2 3 reaction;		# support reaction at column 1
recorder Node -file $dataDir/Node40.out  -node 40 -dof 1 2 disp;  # 
recorder Node -file $dataDir/Node41.out  -node 41 -dof 1 2 disp;  # 
recorder Node -file $dataDir/Node42.out  -node 42 -dof 1 2 disp;  # 
recorder Node -file $dataDir/Node43.out  -node 43 -dof 1 2 disp;  # 
recorder Node -file $dataDir/Node44.out  -node 44 -dof 1 2 disp;  # 
recorder Node -file $dataDir/Node45.out  -node 45 -dof 1 2 disp;  # 

recorder Node -file $dataDir/Node55.out  -node 55 -dof 1 2 disp;  # 

recorder Node -file $dataDir/Node60.out  -node 60 -dof 1 2 disp;  # 
recorder Node -file $dataDir/Node61.out  -node 61 -dof 1 2 disp;  # 
recorder Node -file $dataDir/Node62.out  -node 62 -dof 1 2 disp;  # 
recorder Node -file $dataDir/Node63.out  -node 63 -dof 1 2 disp;  # 
recorder Node -file $dataDir/Node64.out  -node 64 -dof 1 2 disp;  # 
recorder Node -file $dataDir/Node65.out  -node 65 -dof 1 2 disp;  # 

recorder Node -file $dataDir/Node111.out  -node 111 -dof 1 2 disp;  # 
recorder Node -file $dataDir/Node116.out  -node 116 -dof 1 2 disp;  # 
recorder Node -file $dataDir/Node126.out  -node 126 -dof 1 2 disp;  # 

recorder Element -file $dataDir/Contact[expr (41*1000 + 42*100)+48+1].out		-ele [expr (41*1000 + 42*100)+48+1] deformationsANDforces;
recorder Element -file $dataDir/Contact[expr (43*1000 + 44*100)+48+1].out		-ele [expr (44*1000 + 44*100)+48+1] deformationsANDforces;
recorder Element -file $dataDir/Contact[expr (41*1000 + 42*100)+64].out		-ele [expr (41*1000 + 42*100)+64] deformationsANDforces;
recorder Element -file $dataDir/Contact[expr (43*1000 + 44*100)+48+1].out		-ele [expr (43*1000 + 44*100)+48+1] deformationsANDforces;
recorder Element -file $dataDir/Contact[expr (61*1000 + 62*100)+48+1].out		-ele [expr (61*1000 + 62*100)+48+1] deformationsANDforces;
#recorder Element -file $dataDir/Contact[expr ($Node1*1000 + $Node2*100)+$i+1].out -ele	[expr ($Node1*1000 + $Node2*100)+$i+1]	deformation  # deformationsANDforces

recorder Element -file $dataDir/ContactAll_Col4.out		-eleRange [expr (41*1000 + 42*100)+64+1] [expr (41*1000 + 42*100)+79+1] deformation;
recorder Element -file $dataDir/ContactAll_Col6.out		-eleRange [expr (61*1000 + 62*100)+64+1] [expr (61*1000 + 62*100)+79+1] deformation;
#recorder Element -file $dataDir/ContactAll_Col4.out		-ele [expr (41*1000 + 42*100)+79+1] deformation;

recorder Element -file $dataDir/ConcCol1y.out  -ele 42 section 1 fiber  [expr $RCol-$coverCol] 0		$CoreConcMat stressStrain; # y,z location of fiber
recorder Element -file $dataDir/ConcCol1.out  -ele 42 section 1 fiber	0 [expr $RCol-$coverCol] 		$CoreConcMat stressStrain; # y,z location of fiber
recorder Element -file $dataDir/ConcCol1Top.out  -ele 42 section $numIntgrPts fiber	0 [expr $RCol-$coverCol] 		$CoreConcMat stressStrain; # y,z location of fiber
recorder Element -file $dataDir/ConcCol2.out  -ele 62 section 1 fiber	0 [expr $RCol-$coverCol] 		$CoreConcMat stressStrain; # y,z location of fiber

recorder Element -file $dataDir/BearingBent.out       -ele 210  deformation;
recorder Element -file $dataDir/BearingAbutmentA.out  -ele 201  deformation;

recorder Element -file $dataDir/PTCol4Force.out -ele 4051 4251 4351  axialForce;
recorder Element -file $dataDir/PTCol4Def.out   -ele 4051 4251 4351  deformations;
recorder Element -file $dataDir/PTCol6Force.out -ele 6051 6251 6351  axialForce;
recorder Element -file $dataDir/PTCol6Def.out   -ele 6051 6251 6351  deformations;



timeSeries Path 1 -dt $dT -filePath $GM_MAJ -factor $SF_MAJ;
timeSeries Path 2 -dt $dT -filePath $GM_MIN -factor $SF_MIN;


# Definition of analysis
# ----------------------------------------
# Define earthquake ground motion acceleration to the all fixed points


pattern UniformExcitation  2   1  -accel   1 ;
pattern UniformExcitation  3   2  -accel   2 ;

set Tol				1.0e-5;
set maxNumIter		1000;
set printFlag		0;
set TestType		EnergyIncr;
set NewmarkGamma	0.50;
set NewmarkBeta		0.25;
set algorithmType	KrylovNewton;  # Newton;
#set algorithmType	Broyden;

	constraints		Transformation;					# how it handles boundary conditions
	numberer		RCM;						# renumber dof's to minimize band-width (optimization)
	system			SparseSYM;
	# system		SparseGeneral -piv;
	# system		ProfileSPD
	# system		UmfPack  ; #-lvalueFact 30;
	test EnergyIncr  $Tol $maxNumIter;		# tolerance, max iterations  (Try  EnergyIncr)
	# test NormDispIncr $Tol $maxNumIter ;
	algorithm   $algorithmType -maxDim 3;
integrator Newmark $NewmarkGamma $NewmarkBeta;
# integrator HHT 0.70
# integrator GeneralizedAlpha 1.0 0.7  ;   # 0.8 works for no SSI 
# integrator TRBDF2;
analysis Transient;

set ok [analyze $ExtendedT $dT];                # this will return zero if no convergence problems were encountered

if {$ok != 0} {  
	# if analysis fails, we try some other stuff, performance is slower inside this loop
	set ik 0.0;
	set ok 0;
	set TimeNow [getTime];
	
	while {$TimeNow <= [expr $dT*$ExtendedT] && $ok == 0} {	
		
		set ok [analyze 1 $dT];
		# if analysis fails, we try some other stuff
		# performance is slower inside this loop	global maxNumIterStatic;	    # max no. of iterations performed before "failure to converge" is ret'd
		
		if {$ok != 0} {
			puts "Trying Broyden .."
			algorithm Broyden 8 ;
			set ok [analyze 1 $dT];
			# algorithm $algorithmType ;
			algorithm KrylovNewton  -maxDim 3;
			# algorithm NewtonLineSearch 0.75;
		}
		if {$ok != 0} {
			puts "Trying Broyden with reduced time step.."
			algorithm Broyden
			set dT2  [expr 0.5*$dT];
			set ok [analyze 2  $dT2];
			algorithm KrylovNewton  -maxDim 3;
			# algorithm $algorithmType ;
		}
		# if {$ok != 0} {
			# puts "Trying Broyden with further reduced time step.."
			# algorithm Broyden 
			# set dT2  [expr 0.25*$dT];
			# set ok [analyze 4  $dT2];
			# algorithm KrylovNewton  -maxDim 3;
			# # algorithm $algorithmType ;
		# }
		# if {$ok != 0} {
			# puts "Trying Broyden with further reduced time step.."
			# algorithm Broyden 8
			# set dT2  [expr 0.125*$dT];
			# set ok [analyze 8  $dT2];
			# algorithm KrylovNewton  -maxDim 3;
			# # algorithm $algorithmType ;
		# }
		if {$ok != 0} {
			puts "Trying NewtonWithLineSearch .."
			algorithm NewtonLineSearch 0.8 ;
			set ok [analyze 1  $dT];
			# algorithm $algorithmType ;
			algorithm KrylovNewton  -maxDim 3;
			# algorithm NewtonLineSearch 0.75;
		}
		if {$ok != 0} {
			puts "Trying NewtonLineSearch with reduced time step.."
			algorithm NewtonLineSearch 0.8
			set dT2  [expr 0.5*$dT];
			set ok [analyze 2  $dT2];
			algorithm KrylovNewton  -maxDim 3;
			# algorithm $algorithmType ;
		}
		if {$ok != 0} {
			puts "Trying NewtonLineSearch with further reduced time step.."
			algorithm NewtonLineSearch 0.8
			set dT2  [expr 0.25*$dT];
			set ok [analyze 4  $dT2];
			algorithm KrylovNewton  -maxDim 3;
			# algorithm $algorithmType ;
		}
		if {$ok != 0} {
			puts "Trying NewtonLineSearch with even further reduced time step.."
			algorithm NewtonLineSearch 0.8
			set dT2  [expr 0.125*$dT];
			set ok [analyze 8  $dT2];
			algorithm KrylovNewton  -maxDim 3;
			# algorithm $algorithmType ;
		}
		if {$ok != 0} {
			puts "Trying KrylovNewton with reduced time step.."
			#algorithm KrylovNewton -maxDim 3 
			set dT2  [expr 0.5*$dT];
			set ok [analyze 2  $dT2];
			#algorithm KrylovNewton  -maxDim 3;
			# algorithm $algorithmType ;
		}
		if {$ok != 0} {
			puts "Trying KrylovNewton with further reduced time step.."
			#algorithm KrylovNewton -maxDim 3
			set dT2  [expr 0.25*$dT];
			set ok [analyze 4  $dT2];
			#algorithm KrylovNewton  -maxDim 3;
			# algorithm $algorithmType ;
		}
		if {$ok != 0} {
			puts "Trying KrylovNewton with further reduced time step.."
			#algorithm KrylovNewton -maxDim 3
			set dT2  [expr 0.125*$dT];
			set ok [analyze 8  $dT2];
			#algorithm KrylovNewton  -maxDim 3;
			# algorithm $algorithmType ;
		}
		if {$ok != 0} {
			puts "Trying BFGS .."
			algorithm BFGS ;
			set ok [analyze 1 $dT];
			# algorithm $algorithmType ;
			algorithm KrylovNewton  -maxDim 3;
			# algorithm NewtonLineSearch 0.75;
		}
		if {$ok != 0} {
			puts "Trying BFGS with reduced time step.."
			algorithm BFGS 
			set dT2  [expr 0.5*$dT];
			set ok [analyze 2  $dT2];
			algorithm KrylovNewton  -maxDim 3;
			# algorithm NewtonLineSearch 0.75;
			# algorithm $algorithmType ;
		}
		if {$ok != 0} {
			puts "Trying BFGS with further reduced time step.."
			algorithm BFGS 
			set dT2  [expr 0.25*$dT];
			set ok [analyze 4  $dT2];
			algorithm KrylovNewton  -maxDim 3;
			# algorithm NewtonLineSearch 0.75;
			# algorithm $algorithmType ;
		}
		if {$ok != 0} {
			puts "Trying BFGS & NormDisp Test.."
			test NormDispIncr   1e-3 100  2 ;
			algorithm BFGS ;
			set ok [analyze 1 $dT];
			# algorithm $algorithmType ;
			test EnergyIncr  $Tol $maxNumIter
			algorithm KrylovNewton  -maxDim 3;
			# algorithm NewtonLineSearch 0.75;
		}
		if {$ok != 0} {
			puts "Trying BFGS & NormDisp Test with reduced time step.."
			test NormDispIncr   1e-3 100  2 ;
			algorithm BFGS 
			set dT2  [expr 0.5*$dT];
			set ok [analyze 2  $dT2];
			test EnergyIncr  $Tol $maxNumIter
			algorithm KrylovNewton  -maxDim 3;
			# algorithm NewtonLineSearch 0.75;
			# algorithm $algorithmType ;
		}
		if {$ok != 0} {
			puts "Trying BFGS & NormDisp Test with further reduced time step.."
			test NormDispIncr   1e-3 100  2 ;
			algorithm BFGS 
			set dT2  [expr 0.25*$dT];
			set ok [analyze 4  $dT2];
			test EnergyIncr  $Tol $maxNumIter
			algorithm KrylovNewton  -maxDim 3;
			# algorithm NewtonLineSearch 0.75;
			# algorithm $algorithmType ;
		}
		if {$ok != 0} {
			puts "Trying NewtonLineSearch Bisection ...";
			algorithm NewtonLineSearch <-type Bisection> ;
			set ok [analyze 1 $dT]
			algorithm KrylovNewton  -maxDim 3;
			# algorithm NewtonLineSearch 0.75;
			};
		if {$ok != 0} {
			puts "Trying NewtonLineSearch Bisection with reduced time step...";
			algorithm NewtonLineSearch <-type Bisection> ;
			set dT2  [expr 0.5*$dT];
			set ok [analyze 2 $dT2]
			algorithm KrylovNewton  -maxDim 3;
			# algorithm NewtonLineSearch 0.75;
			};
		if {$ok != 0} {
			puts "Trying NewtonLineSearch Bisection with further reduced time step...";
			algorithm NewtonLineSearch <-type Bisection> ;
			set dT2  [expr 0.25*$dT];
			set ok [analyze 4 $dT2]
			algorithm KrylovNewton  -maxDim 3;
			# algorithm NewtonLineSearch 0.75;
			};
		if {$ok != 0} {
			puts "Trying NewtonLineSearch Secant ...";
			algorithm NewtonLineSearch <-type Secant>;
			set ok [analyze 1 $dT]
			algorithm KrylovNewton  -maxDim 3;
			# algorithm NewtonLineSearch 0.75;
			};
		if {$ok != 0} {
			puts "Trying NewtonLineSearch Secant with reduced time step ...";
			algorithm NewtonLineSearch <-type Secant>;
			set dT2  [expr 0.5*$dT];
			set ok [analyze 2 $dT2]
			algorithm KrylovNewton  -maxDim 3;
			# algorithm NewtonLineSearch 0.75;
			};
		if {$ok != 0} {
			puts "Trying NewtonLineSearch Secant with further reduced time step ...";
			algorithm NewtonLineSearch <-type Secant>;
			set dT2  [expr 0.25*$dT];
			set ok [analyze 4 $dT2]
			algorithm KrylovNewton  -maxDim 3;
			# algorithm NewtonLineSearch 0.75;
			};
		if {$ok != 0} {
			puts "Trying NewtonLineSearch RegulaFalsi ...";
			algorithm NewtonLineSearch <-type RegulaFalsi>;
			set ok [analyze 1 $dT]
			algorithm KrylovNewton  -maxDim 3;
			# algorithm NewtonLineSearch 0.75;
			};
		if {$ok != 0} {
			puts "Trying NewtonLineSearch RegulaFalsi with reduced time step ...";
			algorithm NewtonLineSearch <-type RegulaFalsi>;
			set dT2  [expr 0.5*$dT];
			set ok [analyze 2 $dT2]
			algorithm KrylovNewton  -maxDim 3;
			# algorithm NewtonLineSearch 0.75;
			};
		if {$ok != 0} {
			puts "Trying NewtonLineSearch RegulaFalsi with further reduced time step ...";
			algorithm NewtonLineSearch <-type RegulaFalsi>;
			set dT2  [expr 0.25*$dT];
			set ok [analyze 4 $dT2]
			algorithm KrylovNewton  -maxDim 3;
			# algorithm NewtonLineSearch 0.75;
			};
		if {$ok != 0} {
			puts "Trying Generalized alpha integrator ...";
			integrator GeneralizedAlpha 1.0 0.83  ;
			set ok [analyze 1 $dT]
			integrator Newmark $NewmarkGamma $NewmarkBeta;
			};
		if {$ok != 0} {
			puts "Trying Generalized alpha integrator with reduced time step...";
			integrator GeneralizedAlpha 1.0 0.83  ;
			set dT2  [expr 0.5*$dT];
			set ok [analyze 2 $dT2]
			integrator Newmark $NewmarkGamma $NewmarkBeta;
			};
		if {$ok != 0} {
			puts "Trying Generalized alpha integrator with further reduced time step...";
			integrator GeneralizedAlpha 1.0 0.83  ;
			set dT2  [expr 0.25*$dT];
			set ok [analyze 4 $dT2]
			integrator Newmark $NewmarkGamma $NewmarkBeta;
			};
		if {$ok != 0} {
			puts "Trying Generalized alpha integrator with further reduced time step...";
			integrator GeneralizedAlpha 1.0 0.83  ;
			set dT2  [expr 0.125*$dT];
			set ok [analyze 8 $dT2]
			integrator Newmark $NewmarkGamma $NewmarkBeta;
			};
		if {$ok != 0} {
			puts "Trying HHT integrator ...";
			integrator HHT 0.8 ;
			set ok [analyze 1 $dT]
			integrator Newmark $NewmarkGamma $NewmarkBeta;
			};
		if {$ok != 0} {
			puts "Trying HHT integrator with reduced time step...";
			integrator HHT 0.8 ;
			set dT2  [expr 0.5*$dT];
			set ok [analyze 2 $dT2]
			integrator Newmark $NewmarkGamma $NewmarkBeta;
			};
		if {$ok != 0} {
			puts "Trying HHT integrator with further reduced time step...";
			integrator HHT 0.8 ;
			set dT2  [expr 0.25*$dT];
			set ok [analyze 4 $dT2]
			integrator Newmark $NewmarkGamma $NewmarkBeta;
			};
		if {$ok != 0} {
			puts "Trying HHT integrator with further reduced time step...";
			integrator HHT 0.8 ;
			set dT2  [expr 0.125*$dT];
			set ok [analyze 8 $dT2]
			integrator Newmark $NewmarkGamma $NewmarkBeta;
			};
		# if {$ok != 0} {
			# puts "Trying TRBDF2 integrator ...";
			# integrator TRBDF2 ;
			# set ok [analyze 1 $dT]
			# integrator Newmark $NewmarkGamma $NewmarkBeta;
			# };
		# if {$ok != 0} {
			# puts "Trying TRBDF2 integrator with reduced time step...";
			# integrator TRBDF2 ;
			# set dT2  [expr 0.5*$dT];
			# set ok [analyze 2 $dT2]
			# integrator Newmark $NewmarkGamma $NewmarkBeta;
			# };
		# if {$ok != 0} {
			# puts "Trying TRBDF2 integrator with further reduced time step...";
			# integrator TRBDF2 ;
			# set dT2  [expr 0.25*$dT];
			# set ok [analyze 4 $dT2]
			# integrator Newmark $NewmarkGamma $NewmarkBeta;
			# };
		# if {$ok != 0} {
			# puts "Trying TRBDF2 integrator with further reduced time step...";
			# integrator TRBDF2 ;
			# set dT2  [expr 0.125*$dT];
			# set ok [analyze 8 $dT2]
			# integrator Newmark $NewmarkGamma $NewmarkBeta;
			# };
		# if {$ok != 0} {
			# puts "Trying UmfPack system ...";
			# #system	SparseGEN 
			# system UmfPack  -lvalueFact 30
			# #algorithm KrylovNewton  -maxDim 3;
			# set ok [analyze 1 $dT]
			# system	SparseSYM;
			# };
		# if {$ok != 0} {
			# puts "Trying UmfPack system with reduced time step ...";
			# #system	SparseGEN 
			# system UmfPack  -lvalueFact 30
			# set dT2  [expr 0.5*$dT];
			# #algorithm KrylovNewton  -maxDim 3;
			# set ok [analyze 2 $dT2]
			# system	SparseSYM;
			# };
		# if {$ok != 0} {
			# puts "Trying SparseGEN system with Krylovenewton & reduced time step...";
			# system	SparseGEN
			# #algorithm KrylovNewton  -maxDim 3;
			# set dT2  [expr 0.5*$dT];
			# set ok [analyze 2 $dT2]
			# system	SparseSYM;
			# };
		# if {$ok != 0} {
			# puts "Trying SparseGEN system with Krylovenewton & further reduced time step...";
			# system	SparseGEN
			# #algorithm KrylovNewton  -maxDim 3;
			# set dT2  [expr 0.25*$dT];
			# set ok [analyze 4 $dT2]
			# system	SparseSYM;
			# };
		# if {$ok != 0} {
			# puts "Trying SparseGEN system with Krylovenewton & further reduced time step...";
			# system	SparseGEN
			# #algorithm KrylovNewton  -maxDim 3;
			# set dT2  [expr 0.125*$dT];
			# set ok [analyze 8 $dT2]
			# system	SparseSYM;
			# };
			
		set TimeNow [getTime];
		puts $TimeNow
		
	};	# end while loop
};      # end if ok !0
#
# -----------------------------------------------------------------------------------------------------
if {$ok != 0 } {
	puts "Analysis Failed at time [getTime] sec."
	set field [open $FinishTfile "w"] ;
	puts $field  "1  [getTime]" ;
	
} else {
	puts "Analysis completed at time [getTime] sec." 
	set field [open $FinishTfile "w"]  ;
	puts $field  "0  [getTime]"  ;
}

 close $field

### Analysis is finished ###