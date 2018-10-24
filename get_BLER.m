function [ avg_BLER ] = get_BLER ( SINR , PDF , coding , step_dB)

% get_BLER calculates the average BLER experienced given the PDF of the 
% SINR at the receiver and a given coding scheme.
%
% This is an auxiliary script used by functions CV2XMode4, CV2XMode4_common,
% CV2XMode4_Step2 and CV2XMode4_Step3 to model the communication performance 
% of C-V2X or LTE-V Mode 4 using the analytical models described in:
% 
%    Manuel Gonzalez-Martín, Miguel Sepulcre, Rafael Molina-Masegosa, Javier Gozalvez, 
%    "Analytical Models of the Performance of C-V2X Mode 4 Vehicular Communications", 
%    arXiv:1807.06508 [cs.NI], Submitted on 17 July 2018, https://arxiv.org/abs/1807.06508
%
% Input parameters:
%    SINR: Signal-to-Interference and Noise Ratio levels for different distances. It is a matrix where each row represent the SINR levels for a given Tx-Rx distance
%    PDF: Probability Density Function of the SINR levels for different distances. It is a matrix where each row represent the PDF for a given Tx-Rx distance
%    coding: coding rate considered (only 1 is implemented but could easily be extended)
%    step_dB: discrete steps to compute the PDF of the SNR and SINR (dB)
%
% Output metric:
%    avg_BLER: average probability of error for the different distances considered in the input parameters.
%
% The equations that are identified with a number between brackets in this script are the ones
% that also appear in the paper so that they can be easily identified. 

    a = min(-3 , SINR(1));      % Select the extreme values so that the interpolation does not cause an error
    b = max(21 , SINR(end));

    switch coding
        case 1      % 190 Bytes, QPSK r=0.7, Vr = 280 km/h - From R1-160284, DMRS enhancement of V2V in 3GPP
            vector_SNR_paper  = [a      0   2   4   6    8    10    12    14   16   18   20 20+1e-6    b];
            vector_BLER_paper = [1      1 0.9 0.7 0.4 0.13 0.045 0.017 0.007 1e-3 1e-3 1e-3    1e-4 1e-4];           
        case 2      % 190 Bytes, QPSK r=0.5, Vr = 280 km/h - From R1-160284, DMRS enhancement of V2V in 3GPP
            vector_SNR_paper  = [a -2   0   2   4    6    8    10   12    14   16   18   20 20+1e-6    b];
            vector_BLER_paper = [1  1 0.9 0.7 0.3 0.09 0.02 0.002 1e-3  1e-3 1e-3 1e-3 1e-3    1e-4 1e-4];       
    end

    for i=1:size(SINR,1)
        BLER_interp = interp1(vector_SNR_paper , vector_BLER_paper , SINR(i,:) , 'linear');   % BLER vector for a given SINR vector for a given Tx-Rx distance
        avg_BLER(i) =  PDF(i,:) * BLER_interp' * step_dB;   % Equation (13) or Equation (17) depending on whether the input is the PDF(SINR) or PDF(SNR)
    end


end