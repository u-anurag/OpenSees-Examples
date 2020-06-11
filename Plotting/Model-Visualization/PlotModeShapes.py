######################################################################################
## This script plots the modeshapes recorded using Get_Rendering.tcl in OpenSees model.	
## Make sure you have installed the latest version of Matplotlib successfully.		
## As of now, this procedure does not work for 2D/3D shell and solid elements.		
##																					
## Created By - Anurag Upadhyay, Ph.D. Candidate, University of Utah															
##																					
## You can download more examples from https://github.com/u-anurag					
######################################################################################

## Set some parameters here

show_nodes = "no"								# "no" or "yes"
show_arrows = "yes"								# "no" or "yes"  Shows arrow in the direction of node movement
scaleFactor = 50								# deformation scale factor
modeShapeFile = 'ModeShapes\ModeShape1.out'		# Folder\FileName


## start of plotting

from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import numpy as np

fig = plt.figure()
ax = fig.add_subplot(1,1,1, projection='3d')

N,x,y,z = np.loadtxt('RecordNodes.out', dtype=float, delimiter=None, converters=None, unpack=True)
ModeData = np.loadtxt(modeShapeFile, dtype=float, delimiter=None, converters=None, unpack=False)

M = ModeData[0]

ele_style = {'color':'black', 'linewidth':1, 'linestyle':'-'} # elements
ele_styleO = {'color':'magenta', 'linewidth':0.4, 'linestyle':'--'} # elements

def nodecoordsOriginal(nodetag):
    i, = np.where(N == float(nodetag))
    return [x[int(i)],  y[int(i)],  z[int(i)]]

def nodecoords(nodetag):
	i, = np.where(N == float(nodetag))
	return [x[int(i)]+scaleFactor*M[int(3*i)],  y[int(i)]+scaleFactor*M[int(3*i+1)],  z[int(i)]+scaleFactor*M[int(3*i+2)]]

with open ('RecordElements.out', 'r') as elements:
	for line in elements:
		
		iNodeO = nodecoordsOriginal(line.split()[1])
		jNodeO = nodecoordsOriginal(line.split()[2])
		
		iNode = nodecoords(line.split()[1])
		jNode = nodecoords(line.split()[2])
				
		ax.plot((iNode[0], jNode[0]), (iNode[1], jNode[1]), (iNode[2], jNode[2]), marker='', **ele_style)
		ax.plot((iNodeO[0], jNodeO[0]), (iNodeO[1], jNodeO[1]), (iNodeO[2], jNodeO[2]), marker='', **ele_styleO)
		
		if show_nodes == "yes":
			ax.scatter(iNode[0], iNode[1], iNode[2], marker='o', facecolor = 'black')
		
		if show_arrows == "yes":
			ax.quiver(iNodeO[0], iNodeO[1], iNodeO[2], (iNode[0]-iNodeO[0]), (iNode[1]-iNodeO[1]), (iNode[2]-iNodeO[2]), length=30, normalize=True, color='red', arrow_length_ratio=0.5)

nodeMins = np.array([min(x),min(y),min(z)])
nodeMaxs = np.array([max(x),max(y),max(z)])

xViewCenter = (nodeMins[0]+nodeMaxs[0])/2
yViewCenter = (nodeMins[1]+nodeMaxs[1])/2
zViewCenter = (nodeMins[2]+nodeMaxs[2])/2
view_range = max(max(x)-min(x), max(y)-min(y), max(z)-min(z))

ax.set_xlim(xViewCenter-(view_range/3), xViewCenter+(view_range/3))
ax.set_ylim(yViewCenter-(view_range/3), yViewCenter+(view_range/3))
ax.set_zlim(zViewCenter-(view_range/3), zViewCenter+(view_range/3))

plt.axis('off')
plt.show()
