# Analytical Models of the Performance of C-V2X Mode 4 Vehicular Communications
This code implements in Matlab the analytical models of the communication performance of C-V2X or LTE-V Mode 4 described in the following paper:

    Manuel Gonzalez-Martín, Miguel Sepulcre, Rafael Molina-Masegosa, Javier Gozalvez, 
    "Analytical Models of the Performance of C-V2X Mode 4 Vehicular Communications", 
    arXiv:1807.06508 [cs.NI], Submitted on 17 July 2018, https://arxiv.org/abs/1807.06508

CV2XMode4.m is the main script you have to run to get the PDR curve as a function of the distance for a given set of parameters. This script is related to the rest of scripts following the following diagram:

     CV2XMode4.m
         |---->   CV2XMode4_common.m   ----> get_PL_SH.m, get_SINRdistribution.m, get_BLER.m
         |---->   CV2XMode4_Step2.m    ----> get_PL_SH.m, get_SINRdistribution.m, get_BLER.m
         |---->   CV2XMode4_Step3.m    ----> get_PL_SH.m, get_SINRdistribution.m, get_BLER.m
         
If you want to run the same configurations than the ones in the paper, you could simply run the script run_all.m

The resulting figures are compared with simulations when the same configuration is available in the ./simulations folder.

The resulting figures are stored in the ./fig folder.

The equations in this code that appear in the paper are shown with their number in brackets so that they can be easily identified in the paper. 

