function run_all

% run_all is an auxiliary script that evaluates all the configurations of
% the analytical models of the communication performance of C-V2X or LTE-V 
% Mode 4 that are presented in the following paper:
%
%    Manuel Gonzalez-Martín, Miguel Sepulcre, Rafael Molina-Masegosa, Javier Gozalvez, 
%    "Analytical Models of the Performance of C-V2X Mode 4 Vehicular Communications", 
%    arXiv:1807.06508 [cs.NI], Submitted on 17 July 2018, https://arxiv.org/abs/1807.06508
%
% CV2XMode4 is the main script to evaluate the models and the input parameters are:
%    beta: traffic density in veh/m, e.g. 0.1.
%    lambda: packet transmission frequency in Hz, e.g. 10.
%    Pt: transmission power in dBm, e.g. 20.
%    S: number of sub-channels, e.g. 2.
%    B: packet size in bytes, e.g. 190.
   
%    CV2XMode4(beta,lambda,Pt,S,B);

    CV2XMode4(0.1,10,20,4,190);
    CV2XMode4(0.2,10,20,4,190);
    CV2XMode4(0.3,10,20,4,190);
    
    CV2XMode4(0.1,10,23,4,190);
    CV2XMode4(0.2,10,23,4,190);
    CV2XMode4(0.3,10,23,4,190);
    
    CV2XMode4(0.1,20,20,4,190);
    CV2XMode4(0.2,20,20,4,190);
    CV2XMode4(0.3,20,20,4,190);
    
    CV2XMode4(0.1,10,20,2,190);
    CV2XMode4(0.2,10,20,2,190);
    CV2XMode4(0.3,10,20,2,190);


return