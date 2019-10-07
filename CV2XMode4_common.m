function [ deltaHD , deltaSEN , deltaPRO ] = CV2XMode4_common( lambda , Pt , distance, Psen , step_dB , noise , coding);

% CV2XMode4_common is a script that calculates the probability of packet 
% loss due to half-duplex transmissions, the probability of packet loss 
% due to a received signal power below the sensing power threshold and the
% probability of packet loss due to propagation effects for different 
% Tx-Rx distances based on the models described in the following paper:
% 
%    Manuel Gonzalez-Martín, Miguel Sepulcre, Rafael Molina-Masegosa, Javier Gozalvez, 
%    "Analytical Models of the Performance of C-V2X Mode 4 Vehicular Communications", 
%    IEEE Transactions on Vehicular Technology, Vol. 68, Issue 2, Feb. 2019. DOI: 10.1109/TVT.2018.2888704
%    Final version available at: https://ieeexplore.ieee.org/document/8581518
%    Post-print version available at: https://arxiv.org/abs/1807.06508
%
% CV2XMode4_common is called from the main script, CV2XMode4.
%
% Input parameters:
%   lambda: packet transmission frequency in Hz. .
%   Pt: transmission power in dBm. 
%   distance: distance between tramsmitter and receiver in meters. It can be a vector with multiple distances.
%   Psen: sensing threshold in dBm.
%   step_dB: discrete steps to compute the PDF of the SNR and SINR in dB.
%   noise: noise corresponding to the DATA field of each message. Assumes a noise figure of 9dB and 10MHz channel (background noise of -95dBm). The total number of RBs in 10MHz is 50.
%   coding: ID of the coding used to identify the BLER curve 
% 
% Output metrics:
%    deltaHD: probability of packet loss due to half-duplex transmissions for different Tx-Rx distances
%    deltaSEN: probability of packet loss due to a received signal power below the sensing power threshold for different Tx-Rx distances
%    deltaPRO: probability of packet loss due to propagation effects for different Tx-Rx distances
%
% The equations that are identified with a number between brackets in this script are the ones
% that also appear in the paper so that they can be easily identified. 

  
    D = length(distance);

    deltaHD(1:D) = lambda/1000;  % Equation (7)

    [PL_E_R, std_dev_E_R] = get_PL_SH(distance);   % Obtains pathloss and shadowing for different Tx-Rx distances.
    deltaSEN = 0.5 * ( 1 - erf( (Pt - PL_E_R - Psen)./(std_dev_E_R*sqrt(2)) ) );         % Equation (10)

    [SNR, PDF_SNR] = get_SINRdistribution( Pt - PL_E_R , -180 , std_dev_E_R , 3 , noise , Psen , step_dB); % Obtains the PDF of the SNR experienced by Rx (without interference).
    deltaPRO = get_BLER( SNR , PDF_SNR , coding , step_dB);   % Equation (13)

end



