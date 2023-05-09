
####################################################################
## Deep beam simple test in OpenSeesPy
## Anurag Upadhyay, Ph.D.
## 05-08-2023
####################################################################


import os
import sys
import math
import numpy as np
import vfo.vfo as vfo
import matplotlib.pyplot as plt
import openseespy.opensees as ops
 
#
def DeepBeam(beam_length, beam_depth, nEle_L, nEle_D):

    """
    beam_length :  Beam length
    beam_depth  :  Beam depth
    nEle_L      :  Number of elements along beam length
    nEle_D      :  Number of elements along beam depth
	
    """
	
    
    fc = 10.0               # ksi  Expected strength
    E = 1820*(fc**0.5)    # ksi
    v = 0.3
    beam_thick = 1

    ops.wipe()
    ops.model('basic','-ndm',2,'-ndf',2)
     
    ops.nDMaterial('ElasticIsotropic',1,E,v)
     
    eleArgs = [beam_thick,'PlaneStress',1]
    points = [1,0,0,
              2,beam_length,0,
              3,beam_length,beam_depth,
              4,0,beam_depth]
    ops.block2D(nEle_L,nEle_D,1,1,'quad',*eleArgs,*points)
    
	# fix nodes along X=0
    ops.fixX(0,1,1)
	
	# fix nodes along X=beam_length
    ops.fixX(beam_length,0,1)

    # create TimeSeries
    ops.timeSeries("Linear", 1)
    ops.pattern("Plain", 1, 1)

    loadNode = round((nEle_L+1)*(nEle_D+1) - 0.5*nEle_L)

    ops.load(loadNode, 0.0, -10.0)

    vfo.createODB(model="DeepBeam", loadcase="Gravity")
    
    # ------------------------------
    # Start of analysis generation
    # ------------------------------

    ops.system("BandSPD")
    ops.numberer("RCM")
    ops.constraints("Plain")
    ops.integrator("LoadControl", 1.0)
    ops.algorithm("Linear")
    ops.analysis("Static")
    ops.analyze(2)

    
    #### Record node reactions 
    all_nodes = ops.getNodeTags()

    fixed_nodes = []
    Y_coords = []
    X_reaction = []

    for node in all_nodes:
        if ops.nodeCoord(node, 1) == 0:
            fixed_nodes.append(node)
            Y_coords.append(ops.nodeCoord(node, 2))
            X_reaction.append(ops.nodeReaction(node, 1))
            
    
    reaction_limit = math.ceil(max(abs(min(X_reaction)), max(X_reaction)))
    
    plt.plot(X_reaction, Y_coords, 'r-')
    plt.xlabel('Reaction Force')
    plt.ylabel('Location from Bottom')
    plt.title('Beam L/D = '+str(round(beam_length/beam_depth, 2)))
    plt.axvline(x=0, color='k')
    plt.axis([-reaction_limit, reaction_limit, 0, beam_depth])
    plt.grid(True)
    plt.show()
    
    
	
beam_length=40 
beam_depth=20
DeepBeam(beam_length,beam_depth,beam_length,beam_depth)

# vfo.plot_model(show_nodetags="yes")

vfo.plot_deformedshape(model="DeepBeam", loadcase="Gravity", scale=10, contour='y')
