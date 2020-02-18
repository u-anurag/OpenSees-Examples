
# ##################################
# Prepared by - Anurag Upadhyay, PhD Student, Civil and Environmental Engineering
#               University of Utah, Salt Lake City, UT - 84112
# Date - 1/30/2017
# Prepared for - Analysis of a 3 column bridge bent for earthquake retrofit
# ##################################

# ####  set analysis option  

set pid [getPID]
set numP  [getNP]
set count 0;


set AnalysisLevel  MCE;  #DBE, MCE
set GMType FarField;   #  FarField, NearField, PulseType
#set BridgeType A ; # A - Riverdale    B - Alternative
set killTime [expr 10.*60*1000] ; # min

set LColBase  		[expr 182.0];  	# Base case Column clear height in basic units
set AspRBase		[expr $LColBase/44] ; # Base case aspect ratio
set PTAreaBase     	[expr 1.58];  	# Base case PT bar area

set CollapseLimit 0.025; # Collapse drift limit (If not non-convergence)


# Set CPU Time calculation for analysis
set startTime [clock clicks -milliseconds];	# Record Elapsed-Time (Debugging)

set DynamicCheckFile "DynamicAnalysis_Summary.out"
set field_Dynamic [open $DynamicCheckFile w+]

if {$GMType == "FarField"} {
	# set SourceDir FarFieldFiles;
	set SourceDir  "Riverdale_NGAW2"

	}
if {$GMType == "NearField"} {
	set SourceDir NearFieldFDFiles;
	}
if {$GMType == "PulseType"} {
	set SourceDir PulseLikeFiles;
	}

if {$AnalysisLevel == "DBE"} {
	set Sa 0.887;
	}
if {$AnalysisLevel == "MCE"} {
    set Sa [expr 1.5*0.887];
	}


set nGMs 40
source ReadRecord.tcl
source $SourceDir/GMlist_90.tcl
source $SourceDir/GMlist_00.tcl

set AnalysisTfile "AnalysisTime.txt"

#Loop for EQ analyses
foreach Bridge {"B"} {  ; # "B" 
	foreach AspectRatio {4.13 5 5.5 6 6.5 7 7.5 8} {
		foreach PTratio {0.1027 0.11 0.12 0.1295} {
			for {set skew 0} {$skew <= 0} {incr skew} {
				for {set l 1} {$l <= 40} {incr l} {
				
				set BridgeType $Bridge 
				set LCol [expr $LColBase*$AspectRatio/$AspRBase];
				set PTArea [expr $PTAreaBase*$PTratio/0.1027]
				set skewAngle	[expr $skew*15] ;	# degrees

				set gMotionName00 [string range [lindex $GMlist_00 [expr $l-1]] 0 end-4 ]
				set gMotionName90 [string range [lindex $GMlist_90 [expr $l-1]] 0 end-4 ]
				puts "$gMotionName00   $gMotionName90 "
				ReadRecord $SourceDir/$gMotionName00.AT2 $SourceDir/$gMotionName00.dat dT nPts
				ReadRecord $SourceDir/$gMotionName90.AT2 $SourceDir/$gMotionName90.dat dT nPts

				#set logFile	  
				set GM_MAJ $SourceDir/$gMotionName00.dat;
				set GM_MIN $SourceDir/$gMotionName90.dat;
						
				set dataDir Dynamic_Bridge_$BridgeType/$AspectRatio/$PTratio/$skewAngle/$l;
			
				# DATA collection
				file mkdir $dataDir;
				
				if {[expr $count % $numP] == $pid}  {

					puts "$pid $count GM $l"
					
					source TwoSpan_Model_Cloud.tcl;
					
					puts "totalT $totalT Sa1MAJ $Sa1MAJ Sa1MIN $Sa1MIN TargetSa $Sa"

					puts "Running dynamic analysis for Bridge $BridgeType AspRatio $AspectRatio PTratio $PTratio skewAngle $skewAngle GM $l"
					source GMAnalysis_Cloud2.tcl;
					
					puts "Running dynamic analysis for Bridge $BridgeType AspRatio $AspectRatio PTratio $PTratio skewAngle $skewAngle GM $l"

					set nPts [expr int($nPts + 5/$dT)];
					puts "nPts $nPts"
					set SF_MAJ $g;
					set SF_MIN $g;
					
					timeSeries Path 1 -dt $dT -filePath $GM_MAJ -factor $SF_MAJ;
					timeSeries Path 2 -dt $dT -filePath $GM_MIN -factor $SF_MIN;

					pattern UniformExcitation  2   1  -accel   1 ;
					pattern UniformExcitation  3   2  -accel   2 ;
					
					source Recorders_Cloud.tcl
					puts "Running dynamic analysis for Bridge $BridgeType skewAngle $skewAngle GM $l"
	  
					set okDyn [doDynamic $dT [expr int(1*$nPts)] $dataDir $killTime]
					
					if {$okDyn == 0} {
						puts $field_Dynamic	"Bridge $BridgeType AspRatio $AspectRatio PTratio $PTratio skewAngle $skewAngle GM $l : \t Dyn PASS \t at time: [getTime]"
					} else {
						puts $field_Dynamic	"Bridge $BridgeType AspRatio $AspectRatio PTratio $PTratio skewAngle $skewAngle GM $l : \t Dyn FAILED \t at time: [getTime]"
					}

					wipe;
					}
				incr count 1;
				}
			}
		}
	}
}

###############################################################
###															###
###			Displays Elapsed-Time for Debugging				###
###															###
###############################################################

	set finishTime	[clock clicks -milliseconds];
	set tSecs 		[expr ($finishTime - $startTime)/1000];
	set tMins		[expr ($tSecs / 60)];
	set tHrs		[expr ($tSecs / 3600)];
	set tMins		[expr ($tMins - $tHrs * 60)];
	set tSecs		[expr ($tSecs - $tMins * 60 - $tHrs * 3600)];
	
	puts "Total Elapsed Time $tHrs Hours $tMins Minutes $tSecs Secs"
	
	set field [open $AnalysisTfile "w"] ;
	puts $field  "Total Elapsed Time $tHrs Hours $tMins Minutes $tSecs Secs" ;
