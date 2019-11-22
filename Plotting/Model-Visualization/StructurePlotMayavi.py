#########################################################################################
## This script plots the Nodes and Elements in order to render the OpenSees model.		 	
## Make sure you have installed Mayavi successfully.										
## As of now, this procedure does not work for 2D/3D shell and solid elements.				
##																							
## Created By - Anurag Upadhyay, Ph.D. Candidate, University of Utah																		
##																									
## You can download more examples from https://github.com/u-anurag										
#########################################################################################

import numpy as np
import mayavi.mlab as mlab

show_node_tags = 'no'		# Check if you want to display the node numbers     :: 'yes'  or   'no'
show_element_tags = 'no'	# Check if you want to display the element numbers  :: 'yes'  or   'no'
offset = 0.05 #offset for text

black = (0,0,0)
white = (1,1,1)
mlab.figure(bgcolor=white)

N,x,y,z = np.loadtxt('RecordNodes.out', dtype=float, delimiter=None, converters=None, unpack=True)

def nodecoords(nodetag):
	i, = np.where(N == float(nodetag))
	return [x[int(i)],  y[int(i)],  z[int(i)]]


with open ('RecordElements.out', 'r') as elements:
	for line in elements:
		
		iNode = nodecoords(line.split()[1])
		jNode = nodecoords(line.split()[2])
		
		mlab.plot3d((iNode[0], jNode[0]), (iNode[1], jNode[1]), (iNode[2], jNode[2]), color=black, tube_radius=0.35) ; #tube_radius=1.
		if show_node_tags == 'yes':
			mlab.text3d(iNode[0]+offset, iNode[1]+offset, iNode[2]+offset, str(line.split()[1]), color=(0.6,0,1), scale=(0.6,0.6,0.6))
			
		if show_element_tags == 'yes':
			mlab.text3d((iNode[0]+jNode[0])*0.5+offset, (iNode[1]+jNode[1])*0.5+offset, (iNode[2]+jNode[2])*0.5+offset, str(line.split()[0]), 
				color=(0.0,0.2,0.13), orient_to_camera = True, scale=(0.6,0.6,0.6))  

mlab.show()
