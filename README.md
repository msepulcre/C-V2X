# Analytical Models of the Performance of C-V2X Mode 4 Vehicular Communications
This code implements in Matlab the analytical models of the communication performance of C-V2X or LTE-V Mode 4 described in the following paper:

    Manuel Gonzalez-Martín, Miguel Sepulcre, Rafael Molina-Masegosa, Javier Gozalvez, 
    "Analytical Models of the Performance of C-V2X Mode 4 Vehicular Communications", 
    IEEE Transactions on Vehicular Technology, Vol. 68, Issue 2, Feb. 2019. DOI: 10.1109/TVT.2018.2888704
    Final version available at: https://ieeexplore.ieee.org/document/8581518
    Post-print version available at: https://arxiv.org/abs/1807.06508

In order to comply with our sponsor guidelines, we would appreciate if any publication using this code references the above-mentioned publication.

The paper presents analytical models for the average PDR (Packet Delivery Ratio) as a function of the distance between transmitter and receiver, and for the four different types of transmission errors that can be encountered in C-V2X Mode 4. The models are validated for a wide range of transmission parameters and traffic densities. To this aim, this study compares the results obtained with the analytical models to those obtained with a C-V2X Mode 4 simulator implemented over Veins. 

CV2XMode4.m is the main script you have to run to get the PDR and the probability of each of the four transmission errorscurve as a function of the distance between transmitter and receiver. This script is related to the rest of scripts as described in the following diagram:

     CV2XMode4.m
         |---->   CV2XMode4_common.m   ----> get_PL_SH.m, get_SINRdistribution.m, get_BLER.m
         |---->   CV2XMode4_Step2.m    ----> get_PL_SH.m, get_SINRdistribution.m, get_BLER.m
         |---->   CV2XMode4_Step3.m    ----> get_PL_SH.m, get_SINRdistribution.m, get_BLER.m
         
If you want to run the same configurations than the ones in the paper, you could simply run the script run_all.m

The resulting figures are compared with simulations when the same configuration is available in the ./simulations folder.

The resulting figures are stored in the ./fig folder.

The equations in this code that appear in the paper are shown with their number in brackets so that they can be easily identified in the paper. 

Feel free to contact Prof. Miguel Sepulcre (msepulcre@umh.es) if you are interested in collaborating on the evolution of these models. 
