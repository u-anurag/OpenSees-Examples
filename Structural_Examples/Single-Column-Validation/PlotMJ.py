
# to run the file in commandline, cd to directory containing this file
# for example, type in commandline interface " cd D:\Python\SingleColumn " 
# then run the file by typing " python PlotMJ.py "
# Alternate: Install and use Anaconda to run python files

#from IPython import get_ipython;   
#get_ipython().magic('reset -sf')

import matplotlib.pyplot as plt
import numpy as np
import os
#import xlsxwriter


# decide if you want to write output to a file or not: type 'yes' or 'no'
write_to_excel = 'no'    
filename = 'Pushover'

# Check if the folder to which you are saving output figures exists or not. If not, create a folder 'Figures'
Figures = r'Pushover\Figures'
if not os.path.exists(Figures):
    os.makedirs(Figures)
    
DataDir = 'Pushover'  # Location of OpenSees output 
#datafile = os.path.join(DIR ,name,'DFree161.out')

### Load column test data from MJ's test
x, y1 = np.loadtxt('CB-CIP-O(MJ).txt', delimiter='\t', unpack=True, skiprows=1)

### Load output data from OpenSees model
DispOS = np.loadtxt(os.path.join(DataDir,'Disp_node2.out'), delimiter=' ', unpack=False)
ReacOS = np.loadtxt(os.path.join(DataDir, 'Reaction.out'), delimiter=' ', unpack=False)

## Set parameters for the plot
plt.rcParams.update({'font.size': 7})
plt.figure(figsize=(4,3), dpi=100)
plt.rc('font', family='serif')

# Plot MJ's column test data
plt.plot(x,y1, color="blue", linewidth=0.8, linestyle="-", label='CB-CIP')

# Plot OpenSees output data
plt.plot(DispOS,-ReacOS, color='red', linewidth=0.8, linestyle="--", label='OpenSees')

plt.axhline(0, color='black', linewidth=0.4)
plt.axvline(0, color='black', linewidth=0.4)

plt.xlim(-12.5,12.5 )
plt.xticks(np.linspace(-12.5,12.5,11,endpoint=True)) 
plt.grid(linestyle='dotted') 
plt.xlabel('Displacement (in)')
plt.ylabel('BaseShear (kip)')
plt.title('MJ-CB-CIP')
plt.legend()
#plt.savefig("Pushover/Figures/Comparison-CB-CIP.png",dpi=1200)
plt.show()

if(write_to_excel == 'yes'):
    import xlsxwriter

    workbook = xlsxwriter.Workbook("Cyclic/Figures/OpenSeesData.xlsx")
    worksheet = workbook.add_worksheet('Cyclic')
    
    worksheet.write_column(0, 0, "Disp")
    worksheet.write_column(0, 1, "force")
    worksheet.write_column(1, 0, DispOS)
    worksheet.write_column(1, 1, -ReacOS)
    
    workbook.close()

