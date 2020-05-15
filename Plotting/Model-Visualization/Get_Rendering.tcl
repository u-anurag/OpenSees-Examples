##########################################################################################
## This script records the Nodes and Elements in order to render the OpenSees model.	##
## As of now, this procedure does not work for 2D/3D shell and solid elements.		##
##											##
## Created By - Anurag Upadhyay								##
##											##
## You can download more examples from https://github.com/u-anurag			##
##########################################################################################

## Set number of modeshapes to record

set numModes 6


# There is no need to change anything beyond this line #

set NodeFile "RecordNodes.out"
set fieldNodes [open $NodeFile w+]

set EleFile "RecordElements.out"
set fieldElements [open $EleFile w+]

set listNodes		[getNodeTags] ; # Get all the node tags in the current domain
set listElements	[getEleTags]  ; # get all the element tags in the current domain

foreach nodeTag $listNodes {
	set tempNode [nodeCoord $nodeTag]
	puts $fieldNodes	"$nodeTag $tempNode"
	unset tempNode
	}
	
foreach eleTag $listElements {
	set tempEle [eleNodes $eleTag]
	puts $fieldElements "$eleTag $tempEle"
	unset tempEle
	}
	
close $fieldNodes
close $fieldElements


proc RecordModeShapes {numModes listNodes} {

	set ModeShapeDir ModeShapes
	file mkdir $ModeShapeDir
	set N [llength $listNodes]
	
	for { set k 1 } { $k <= $numModes } { incr k } {
		recorder Node -file [format "$ModeShapeDir/ModeShape%i.out" $k] -nodeRange [lindex $listNodes 0] [lindex $listNodes [expr $N-1]] -dof 1 2 3  "eigen $k"
	} 
}

RecordModeShapes $numModes $listNodes ;

record
