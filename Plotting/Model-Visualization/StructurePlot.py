######################################################################################
## This script plots the Nodes and Elements in order to render the OpenSees model.	
## Make sure you have installed the latest version of Matplotlib successfully.		
## As of now, this procedure does not work for 2D/3D shell and solid elements.		
##																					
## Created By - Anurag Upadhyay, Ph.D. Candidate, University of Utah													
##																					
## You can download more examples from https://github.com/u-anurag					
######################################################################################

from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import numpy as np

fig = plt.figure()
ax = fig.add_subplot(1,1,1, projection='3d')

N,x,y,z = np.loadtxt('RecordNodes.out', dtype=float, delimiter=None, converters=None, unpack=True)

def nodecoords(nodetag):
	i, = np.where(N == float(nodetag))
	return [x[int(i)],  y[int(i)],  z[int(i)]]

with open ('RecordElements.out', 'r') as elements:
	for line in elements:
		iNode = nodecoords(line.split()[1])
		jNode = nodecoords(line.split()[2])
		ele_style = {'color':'black', 'linewidth':1, 'linestyle':'-'} # elements
					
		ax.plot((iNode[0], jNode[0]), (iNode[1], jNode[1]), (iNode[2], jNode[2]), marker='', **ele_style)
		#ax.scatter(iNode[0], iNode[1], iNode[2], marker='o', facecolor = 'black')

#ax.scatter(x, y, z)

# Scale axes to preserve aspect ratio of 1
nodeMins = np.array([min(x),min(y),min(z)])
nodeMaxs = np.array([max(x),max(y),max(z)])

print(nodeMins)
print(nodeMaxs)

xViewCenter = (nodeMins[0]+nodeMaxs[0])/2
yViewCenter = (nodeMins[1]+nodeMaxs[1])/2
zViewCenter = (nodeMins[2]+nodeMaxs[2])/2
view_range = max(max(x)-min(x), max(y)-min(y), max(z)-min(z))

print(xViewCenter , yViewCenter , zViewCenter)
print(view_range)

ax.set_xlim(xViewCenter-(view_range/4), xViewCenter+(view_range/4))
ax.set_ylim(yViewCenter-(view_range/4), yViewCenter+(view_range/4))
ax.set_zlim(zViewCenter-(view_range/4), zViewCenter+(view_range/4))

plt.axis('off')

plt.show()
