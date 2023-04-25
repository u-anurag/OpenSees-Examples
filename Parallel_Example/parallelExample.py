###########################################################
#### OpenSees Parallel Parametric Analysis ################
#### Anurag Upadhyay, Ph.D., 04-25-2023    ################
#### www.anuragupadhyay.weebly.com         ################
###########################################################

import os
import math
import numpy as np
import vfo.vfo as vfo
import openseespy.opensees as ops

import matplotlib.pyplot as plt 

from concurrent.futures import ProcessPoolExecutor


def myParallelModel(parameter):

	ops.wipe()

	# set modelbuilder
	ops.model('basic', '-ndm', 2, '-ndf', 3)

	### Units and Constants  ###################

	inch = 1;
	kip = 1;
	sec = 1;

	# Dependent units
	sq_in = inch*inch;
	ksi = kip/sq_in;
	ft = 12*inch;

	# Constants
	g = 386.2*inch/(sec*sec);
	pi = math.acos(-1);

	##### Dimensions 

	H_story=parameter;  # Change frame height using parameter
	
	W_bayX=16.0*ft;

	###### Nodes

	ops.node(1, 0.0, 0.0)
	ops.node(2, W_bayX, 0.0)

	ops.node(11, 0.0, H_story)
	ops.node(12, W_bayX, H_story)

	#  Constraints

	ops.fix(1, 1, 1, 1)
	ops.fix(2, 1, 1, 1)

	# ### Elements 

	ColTransfTag=1
	BeamTranfTag=2

	ops.geomTransf('Linear', ColTransfTag)
	ops.geomTransf('Linear', BeamTranfTag)

	# Assign Elements  ##############
	ops.element('elasticBeamColumn', 1, 1, 11, 20., 1000., 1000., ColTransfTag, '-mass', 0.1)
	ops.element('elasticBeamColumn', 2, 2, 12, 20., 1000., 1000., ColTransfTag, '-mass', 0.1)

	ops.element('elasticBeamColumn', 101, 11, 12, 20., 1000., 1000., BeamTranfTag, '-mass', 0.1)

	# Visualize the model
	# return  vfo.plot_model()

	## Gravity Load 

	NstepsGrav = 5

	ops.system("BandGEN")
	ops.numberer("Plain")
	ops.constraints("Transformation")
	ops.integrator("LoadControl", 1.0/NstepsGrav)
	ops.algorithm("Newton")
	ops.test('EnergyIncr', 1e-8, 10)
	ops.analysis("Static")

	# Define Static Analysis
	ops.timeSeries('Linear', 1)
	ops.pattern('Plain', 1, 1)

	ops.load(11, 0.0, -1.0, 0.0)
	ops.load(12, 0.0, -1.0, 0.0)

	ops.analysis('Static')

	Nsteps = NstepsGrav

	# perform the analysis
	data = np.zeros((Nsteps+1,2))
	for j in range(Nsteps):
		ops.analyze(1)
		data[j+1,0] = ops.nodeDisp(1,1)
		data[j+1,1] = ops.getLoadFactor(1)

	plt.plot(data[:,0], data[:,1])
	plt.xlabel('Horizontal Displacement')
	plt.ylabel('Horizontal Load')
	plt.title("parameter = "+str(parameter))	
	plt.show()

	ops.loadConst('-time', 0.0)
		 
	print("Gravity analysis with parameter = "+str(parameter) +" complete")



###############################
## Now Parametric Analysis  ###
###############################


parameter_list = [10,15,20,25]  # list of frame height parameters

def Parallel_Analysis():
	with ProcessPoolExecutor() as executor:
		### submit all tasks
		for parameter in parameter_list:
			p = executor.submit(myParallelModel,parameter)
            
			
if __name__ == '__main__':
    Parallel_Analysis()
