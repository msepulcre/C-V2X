function [ PL , std_dev ] = get_PL_SH ( distance );

% get_PL_SH calculates the pathloss and shadowing for a given set of Tx-Rx
% distances following the Winner+ B1 propagation model. 
%
% This is an auxiliary script used by functions CV2XMode4, CV2XMode4_common,
% CV2XMode4_Step2 and CV2XMode4_Step3 to model the communication performance 
% of C-V2X or LTE-V Mode 4 using the analytical models described in:
% 
%    Manuel Gonzalez-Martín, Miguel Sepulcre, Rafael Molina-Masegosa, Javier Gozalvez, 
%    "Analytical Models of the Performance of C-V2X Mode 4 Vehicular Communications", 
%    arXiv:1807.06508 [cs.NI], Submitted on 17 July 2018, https://arxiv.org/abs/1807.06508
%
% The equations that are identified with a number between brackets in this script are the ones
% that also appear in the paper so that they can be easily identified. 

    % Parameters of the radio propagation model:
    fc = 5.91e9;                % Carrier frequency (Hz)
    hBS = 1.5;                  % Transmitter antenna height (m)
    hMS = 1.5;                  % Receiver antenna height (m)
    environmentHeight = 0;      % Average environmental height (m)
    distance = abs(distance);

    c = 3e8;
    dBP = 4 * (hBS-environmentHeight) * (hMS-environmentHeight) * fc / c; % breakpoint distance

    % Avoid errors for very small distances:
    i = find(distance < 3);
    distance(i) = 3;

    % Calculate pathloss for distances lower than the breakpoint distance:
    i = find(distance < dBP);
    PL(i) = 22.7*log10(distance(i)) + 27 + 20*log10(fc/1e9);
    std_dev(i) = 3;    % Standard deviation

    % Calculate pathloss for distances higher than the breakpoint distance:
    i = find(distance >= dBP);
    PL(i) = 40*log10(distance(i)) + 7.56 - 17.3*log10(hBS-environmentHeight) - 17.3*log10(hMS-environmentHeight) + 2.7*log10(fc/1e9);
    std_dev(i) = 3;    % Standard deviation

    % Compares obtained pathloss with free-space pathloss:
    PLfree = 20*log10(distance) + 46.4 + 20*log10(fc*1e-9 / 5);
    i = find(PLfree > PL);
    PL(i) = PLfree(i);


end