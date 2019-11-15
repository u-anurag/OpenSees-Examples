##########################################################################################
## This script records the Nodes and Elements in order to render the OpenSees model.	##
## As of now, this procedure does not work for 2D/3D shell and solid elements.		##
##											##
## Created By - Anurag Upadhyay								##
##											##
## You can download more examples from https://github.com/u-anurag			##
##########################################################################################

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


proc RecordModeShapes {listNodes} {

	set ModeShapeDir ModeShapes
	file mkdir $ModeShapeDir
	set N [llength $listNodes]

	recorder Node -file $ModeShapeDir/ModeShape1.out  -nodeRange [lindex $listNodes 0] [lindex $listNodes [expr $N-1]]  -dof 1 2 3 "eigen 1";
	recorder Node -file $ModeShapeDir/ModeShape2.out  -nodeRange [lindex $listNodes 0] [lindex $listNodes [expr $N-1]]  -dof 1 2 3 "eigen 2";
	recorder Node -file $ModeShapeDir/ModeShape3.out  -nodeRange [lindex $listNodes 0] [lindex $listNodes [expr $N-1]]  -dof 1 2 3 "eigen 3";
	recorder Node -file $ModeShapeDir/ModeShape4.out  -nodeRange [lindex $listNodes 0] [lindex $listNodes [expr $N-1]]  -dof 1 2 3 "eigen 4";
	recorder Node -file $ModeShapeDir/ModeShape5.out  -nodeRange [lindex $listNodes 0] [lindex $listNodes [expr $N-1]]  -dof 1 2 3 "eigen 5";
	recorder Node -file $ModeShapeDir/ModeShape6.out  -nodeRange [lindex $listNodes 0] [lindex $listNodes [expr $N-1]]  -dof 1 2 3 "eigen 6";
	recorder Node -file $ModeShapeDir/ModeShape7.out  -nodeRange [lindex $listNodes 0] [lindex $listNodes [expr $N-1]]  -dof 1 2 3 "eigen 7";
	recorder Node -file $ModeShapeDir/ModeShape8.out  -nodeRange [lindex $listNodes 0] [lindex $listNodes [expr $N-1]]  -dof 1 2 3 "eigen 8";
	recorder Node -file $ModeShapeDir/ModeShape9.out  -nodeRange [lindex $listNodes 0] [lindex $listNodes [expr $N-1]]  -dof 1 2 3 "eigen 9";
	recorder Node -file $ModeShapeDir/ModeShape10.out  -nodeRange [lindex $listNodes 0] [lindex $listNodes [expr $N-1]]  -dof 1 2 3 "eigen 10";
	recorder Node -file $ModeShapeDir/ModeShape11.out  -nodeRange [lindex $listNodes 0] [lindex $listNodes [expr $N-1]]  -dof 1 2 3 "eigen 11";
	recorder Node -file $ModeShapeDir/ModeShape12.out  -nodeRange [lindex $listNodes 0] [lindex $listNodes [expr $N-1]]  -dof 1 2 3 "eigen 12";
	recorder Node -file $ModeShapeDir/ModeShape13.out  -nodeRange [lindex $listNodes 0] [lindex $listNodes [expr $N-1]]  -dof 1 2 3 "eigen 13";
	recorder Node -file $ModeShapeDir/ModeShape14.out  -nodeRange [lindex $listNodes 0] [lindex $listNodes [expr $N-1]]  -dof 1 2 3 "eigen 14";
	recorder Node -file $ModeShapeDir/ModeShape15.out  -nodeRange [lindex $listNodes 0] [lindex $listNodes [expr $N-1]]  -dof 1 2 3 "eigen 15";
}

# This will record mode shaps only if Eigen analysis is performed
if {[catch {RecordModeShapes $listNodes} issue]} {
    puts "Could not record modeshapes due to error : $issue ; this step is ignored"
}
