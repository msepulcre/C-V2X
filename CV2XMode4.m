function [PDR, deltaHD, deltaSEN, deltaPRO, deltaCOL, CBR] = CV2XMode4(beta,lambda,Pt,S,B);

% CV2XMode4 is the main script of the implementation of the analytical 
% models of the communication performance of C-V2X or LTE-V Mode 4 
% described in the following paper:
% 
%    Manuel Gonzalez-Martín, Miguel Sepulcre, Rafael Molina-Masegosa, Javier Gozalvez, 
%    "Analytical Models of the Performance of C-V2X Mode 4 Vehicular Communications", 
%    IEEE Transactions on Vehicular Technology, Vol. 68, Issue 2, Feb. 2019. DOI: 10.1109/TVT.2018.2888704
%    Final version available at: https://ieeexplore.ieee.org/document/8581518
%    Post-print version available at: https://arxiv.org/abs/1807.06508
%
% The paper presents analytical models for the average PDR (Packet Delivery Ratio) as a 
% function of the distance between transmitter and receiver, and for the four different 
% types of transmission errors that can be encountered in C-V2X or LTE-V Mode 4. The models 
% have been validated for a wide range of transmission parameters and traffic densities by 
% comparing the results obtained with the analytical models to those obtained with a C-V2X 
% or LTE-V Mode 4 simulator implemented by the authors over the Veins simulation platform.
%
% CV2XMode4.m is the main script you have to run to get the PDR curve as a function of the 
% distance for a given set of parameters, and the probability of each of the four 
% transmission errors. 
%
% The resulting figures are compared with simulations when the same configuration 
% is available in the ./simulations folder.
%
% The resulting figures are stored in the ./fig folder.
%
% Input parameters:
%    beta: traffic density in veh/m. Values tested: 0.1, 0.2 and 0.3.
%    lambda: packet transmission frequency in Hz. Values tested: 10 and 20.
%    Pt: transmission power in dBm. Values tested: 20 and 23.
%    S: number of sub-channels. Values tested: 2 and 4.
%    B: packet size in bytes. Values tested: 190.
%
% Output metrics:
%    PDR: Packet Delivery Ratio for different Tx-Rx distances 
%    deltaHD: probability of packet loss due to half-duplex transmissions for different Tx-Rx distances
%    deltaSEN: probability of packet loss due to a received signal power below the sensing power threshold for different Tx-Rx distances
%    deltaPRO: probability of packet loss due to propagation effects for different Tx-Rx distances
%    deltaCOL: probability of packet loss due to packet collisions for different Tx-Rx distances
%    CBR: Channel Busy Ratio between 0 and 1
%
% Overall code structure:
%     CV2XMode4.m
%         |---->   CV2XMode4_common.m   ----> get_PL_SH.m, get_SINRdistribution.m, get_BLER.m
%         |---->   CV2XMode4_Step2.m    ----> get_PL_SH.m, get_SINRdistribution.m, get_BLER.m
%         |---->   CV2XMode4_Step3.m    ----> get_PL_SH.m, get_SINRdistribution.m, get_BLER.m
%
% The equations that are identified with a number between brackets in this script are the ones
% that also appear in the paper so that they can be easily identified. 
    
    disp('=========================================================')
    disp('Input parameters:')
    fprintf('  beta   = %f veh/m \n', beta)
    fprintf('  lambda = %d Hz \n', lambda)
    fprintf('  Pt     = %d dBm \n', Pt)
    fprintf('  S      = %d subchannels \n', S)
    fprintf('  B      = %d bytes \n', B)
    
    distance = [0:25:500];  % Tx-Rx distances to evaluate (m)

    Psen = -90.5;               % Sensing threshold (dBm)

    step_dB = 0.1;              % Discrete steps to compute the PDF of the SNR and SINR (dB)

    % Calculate the number of RBs that are needed to transmit each message
    % and the coding used based on the number of sub-channels and packet size:
    switch B
        case 190
            switch S
                case 4
                    coding = 1;   % Used to identify the BLER vs SINR curve to be used (190 Bytes, QPSK r=0.7, Vr = 280 km/h)
                    RBs = 10;     % Number of RBs needed to transmit the DATA field of each message 
                case 2
                    coding = 2;   % Used to identify the BLER vs SINR curve to be used (190 Bytes, QPSK r=0.5, Vr = 280 km/h)
                    RBs = 12;     % Number of RBs needed to transmit the DATA field of each message
            end
    end

    noise = -95 - 10*log10(50/RBs);     % Noise corresponding to the DATA field of each message. Assumes a noise figure of 9dB and 10MHz channel (background noise of -95dBm). The total number of RBs in 10MHz is 50.

    % Calculate errors associated to HD, SEN and PRO:
    [ deltaHD_pre , deltaSEN_pre , deltaPRO_pre ] = CV2XMode4_common( lambda , Pt , distance, Psen , step_dB , noise , coding ); 
            
    % Calculate probability of collision considering only Step 2 and CBR:
    [ deltaCOL2_pre , CBR ] = CV2XMode4_Step2( beta , lambda , Pt , S , distance , Psen , step_dB , noise , coding , deltaPRO_pre );    

    % Calculate weighting factor alpha using equation (22):
    if CBR < 0.2
        alpha = 0;
    elseif CBR <= 0.7
        alpha = 2*CBR - 0.4;
    else
        alpha = 1;
    end
    
    % Calculate probability of collision considering only Step 3:
    if alpha < 1             
         [ deltaCOL3_pre ] = CV2XMode4_Step3( beta , lambda , Pt , S , distance , Psen , step_dB , noise , coding , deltaPRO_pre );        
    else
        deltaCOL3_pre = 0;
    end
      
    % Calculate final probabilities for each type of error: 
    deltaHD   = deltaHD_pre;                               % Equation (6.1)
    deltaSEN  = deltaSEN_pre .* (1 - deltaHD);             % Equation (6.2)
    deltaPRO  = deltaPRO_pre .* (1 - deltaHD_pre) .* (1 - deltaSEN_pre);  % Equation (6.3)
    deltaCOL2 = deltaCOL2_pre .* (1 - deltaHD_pre) .* (1 - deltaSEN_pre) .* (1 - deltaPRO_pre); % Equation (6.4)
    deltaCOL3 = deltaCOL3_pre .* (1 - deltaHD_pre) .* (1 - deltaSEN_pre) .* (1 - deltaPRO_pre); % Equation (6.5)
    deltaCOL = alpha*deltaCOL2 + (1-alpha)*deltaCOL3; % Equation (21)
    
    % Calculate PDR:
    PDR = 1 - deltaHD - deltaSEN - deltaPRO - deltaCOL; % Equation (6)      
    
    % Presentation of the obtained results:    

    % Load simulation results (if available):
    simulation_path = [pwd '\simulations\' num2str(S) 'subchannels\'  num2str(Pt) 'dBm'];    
    sim_file = [ simulation_path '\FALLOS_LOS_D2D_' num2str(beta*1000) 'vehpkm_16Alg_' num2str(1/lambda) 's_' num2str(8*B) 'bit.fig' ];
    fig_name = ['CV2XMode4_beta' num2str(beta) '-lambda' num2str(lambda) '-Pt' num2str(Pt) '-S' num2str(S) '-B' num2str(B)];

    if exist(sim_file,'file')==2        
        open(sim_file)
        lh = findall(gca, 'type', 'line');
        X = get(lh,'xdata'); 
        Y = get(lh,'ydata'); 
        deltaHD_sim = Y{5};
        deltaSEN_sim = Y{1};
        deltaPRO_sim = Y{4};
        deltaCOL_sim = Y{3};
        close
        
        figure; hold on; grid on; box on
        plot(distance , deltaHD_sim/100,'b-','LineWidth',2)
        plot(distance , deltaSEN_sim/100,'m-','LineWidth',2)
        plot(distance , deltaPRO_sim/100,'r-','LineWidth',2)
        plot(distance , deltaCOL_sim/100,'k-','LineWidth',2)        
        
    else        
        figure; hold on; grid on; box on        
    end

    % Plot errors:
    ylabel('Error probability')
    xlabel('Distance [m]')
    plot(distance , deltaHD,'b--','LineWidth',2)
    plot(distance , deltaSEN,'m--','LineWidth',2)
    plot(distance , deltaPRO,'r--','LineWidth',2)
    plot(distance , deltaCOL,'k--','LineWidth',2)
    ylim([0 1])
    
    if exist(sim_file,'file')==2
        legend('\delta_{HD} Simulation','\delta_{SEN} Simulation','\delta_{PRO} Simulation','\delta_{COL} Simulation','\delta_{HD} Analytical','\delta_{SEN} Analytical','\delta_{PRO} Analytical','\delta_{COL} Analytical','Location','northwest')
    else
        legend('\delta_{HD} Analytical','\delta_{SEN} Analytical','\delta_{PRO} Analytical','\delta_{COL} Analytical','Location','northwest')
    end    
    hgsave(['fig/' fig_name '_errors.fig'])    


    % Plot PDR:
    figure; hold on; grid on; box on
    if exist(sim_file,'file')==2
        PDR_sim = (100 - deltaHD_sim - deltaSEN_sim - deltaPRO_sim - deltaCOL_sim)/100;           
        plot(distance,PDR_sim,'b-','LineWidth',2)        
        plot(distance,PDR,'b--','LineWidth',2)        
        legend('PDR Simulation','PDR Analytical')
    else
        plot(distance,PDR,'--')
        legend('PDR Analytical')
    end       
    ylim([0 1])    
    ylabel('PDR')
    xlabel('Distance [m]')
    hgsave(['fig/' fig_name '_PDR.fig'])    

    fprintf('Channel load: CBR = %.2f, alpha = %f \n',CBR, alpha)
    
    if exist(sim_file,'file')==2        
        MAD_HD  = mean( abs(deltaHD*100 - deltaHD_sim) );    % Equation (35)
        MAD_SEN = mean( abs(deltaSEN*100 - deltaSEN_sim) );  % Equation (35)
        MAD_PRO = mean( abs(deltaPRO*100 - deltaPRO_sim) );  % Equation (35)
        MAD_COL = mean( abs(deltaCOL*100 - deltaCOL_sim) );  % Equation (35)
        MAD     = mean( abs(PDR - PDR_sim) * 100 );          % Equation (35)
        
        disp('Mean Absolute Deviation results : ')
        fprintf('PDR \tHD  \tSEN \tPRO \tCOL \n')
        fprintf('%.2f\t%.2f\t%.2f\t%.2f\t%.2f \n', MAD, MAD_HD, MAD_SEN, MAD_PRO, MAD_COL)
    end
    
    disp('=========================================================')

    

 return
    
