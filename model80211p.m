function [PDR,deltaSEN,deltaRXB,deltaPRO,deltaCOL,CBR] = model80211p(beta,lambda,Pt,B,Rd);

% model80211p is the main script of the implementation of the analytical 
% models of the communication performance of IEEE 802.11p described in the following paper:
% 
%    Miguel Sepulcre, Manuel Gonzalez-Martín, Javier Gozalvez, Rafael Molina-Masegosa, Baldomero Coll-Perales, 
%    "Analytical Models of the Performance of IEEE 802.11p Vehicle to Vehicle Communications", 
%    IEEE Transactions on Vehicular Technology, November 2021. DOI: 10.1109/TVT.2021.3124708
%    Final version available at: https://ieeexplore.ieee.org/document/9599363
%    Post-print version available at: https://arxiv.org/abs/2104.07923
%
% This paper addresses presents the first analytical models capable to accurately 
% model the performance of vehicle-to-vehicle communications based on the IEEE 802.11p standard. 
% The model quantifies the PDR (Packet Delivery Ratio) as a function of the distance between 
% transmitter and receiver. The paper also presents new analytical models to quantify the 
% probability of the four different types of packet errors in IEEE 802.11p. In addition, the 
% paper presents the first analytical model capable to accurately estimate the Channel Busy Ratio 
% (CBR) metric even under high channel load levels. All the analytical models are validated by 
% means of simulation for a wide range of parameters, including traffic densities, packet 
% transmission frequencies, transmission power levels, data rates and packet sizes. 
%
% In order to comply with our sponsor guidelines, we would appreciate if any publication using 
% this code references the above-mentioned publication.
%
% model80211p.m is the main script you have to run to get the PDR curve as a function of the 
% distance for a given set of parameters, the probability of each of the four 
% transmission errors and the CBR.
%
% The resulting figures are compared with simulations when the same configuration 
% is available in the ./simulations folder.
%
% Input parameters:
%    beta: traffic density in veh/m. Values tested: 0.06 and 0.12 veh/m.
%    lambda: packet transmission frequency in Hz. Values tested: 10 and 25 Hz.
%    Pt: transmission power in dBm. Values tested: 15, 23 and 30 dBm.
%    B: packet size in bytes. Values tested: 190 and 500 Bytes.
%    Rd: data rate in bits/s. Values tested: 6, 18 and 27 Mbps.
%
% Output metrics:
%    PDR: Packet Delivery Ratio for different Tx-Rx distances 
%    deltaSEN: probability of packet loss due to a received signal power below the sensing power threshold for different Tx-Rx distances
%    deltaRXB: probability of packet loss because the radio interface is busy receiving another packet
%    deltaPRO: probability of packet loss due to propagation effects for different Tx-Rx distances
%    deltaCOL: probability of packet loss due to packet collisions for different Tx-Rx distances
%    CBR: Channel Busy Ratio between 0 and 1
%
% The equations that are identified with a number between brackets in this script are the ones
% that also appear in the paper so that they can be easily identified. 

   
    disp('=========================================================')
    disp('Input parameters:')
    fprintf('  beta   = %f veh/m \n', beta)
    fprintf('  lambda = %d Hz \n', lambda)
    fprintf('  Pt     = %d dBm \n', Pt)    
    fprintf('  B      = %d bytes \n', B)
    fprintf('  Rd     = %d Mbps \n', Rd/1e6)

    % Configuration parameters and settings:
    distance_tx_to_rx = [0:25:500]; % Tx-Rx distances to evaluate (m)
    step_dB = 0.1;                  % Discrete steps to compute the PDF of the SNR and SINR (dB) 
    BW = 10e6;                      % Channel bandwidth (Hz)    
    Psen = -85;                     % Sensing threshold (dBm)    
    noise = -95;                    % Background noise in 10 MHz assuming a noise figure of 9dB (dBm)   
    sigma = 13e-6;                  % aSlotTime in 802.11-2012 (seconds)
    H = 30;                         % length of headers in Omnet++ approx (Bytes)    
    Ttr = 40e-6 + (B+H)*8/Rd;       % Packet transmission time (duration) in 802.11-2012 (page 1588,1591) =  T_preamble + T_signal + T_data ; t_preamble = 32 us , t_signal = 8 us , t_data = nºbits/data_rate
    
    % Compute the PSR (Packet Sensing Ratio):
    d_aux=-1500:1500;
    [ PL std_dev ] = get_PL_SH(d_aux);    % Pathloss and shadowing standard deviation for the propagation model considered
    PSR = 0.5 * ( 1 + erf( ( Pt - PL - Psen)./( std_dev*sqrt(2) ) ) );   % Equation (13)    
    
    % Compute the CBR (Channel Busy Ratio):   
    CBR_u = beta * lambda * Ttr * sum(PSR);           % Equation (34)
    CBR = - 0.2481*CBR_u^2 + 0.913*CBR_u + 0.003844;  % Equation (35)

    % Compute SEN and PRO errors due to propagation effects for all
    % distances between tx and rx:
    
    deltaSEN_pre = zeros(1,length(distance_tx_to_rx));  % Initialization
    deltaPRO_pre = zeros(1,length(distance_tx_to_rx));  % Initialization
    
    for i=1:length(distance_tx_to_rx)
        
        % Compute the probability of error due to a received signal power
        % below the sensing power threshold for a distance
        % distance_tx_to_rx(i) between tx and rx:
        
        [PL_Tx_Rx(i) std_dev_Tx_Rx(i)] = get_PL_SH( distance_tx_to_rx(i) );                           % Pathloss and shadowing standard deviation for the propagation model considered
        deltaSEN_pre(i) = 0.5 * (1 - erf( ( Pt - PL_Tx_Rx(i) - Psen )/(std_dev_Tx_Rx(i)*sqrt(2)) ) ); % Equation (12)
            
        % Compute the probability of error due to a insufficient SNR for a distance
        % distance_tx_to_rx(i) between tx and rx:

        [SNR PDF_SNR] = get_SINRdistribution( Pt-PL_Tx_Rx(i) , -inf , std_dev_Tx_Rx(i) , std_dev_Tx_Rx(i) , noise , Psen , step_dB);   % Distribution of the SNR of the received packet (without interference, i.e. -inf dB) 
        Eb_No = SNR + 10*log10(BW/Rd);   % Linear transformation
        PDF_Eb_No = PDF_SNR;             % SNR and Eb/No have the same probability distribution
        deltaPRO_pre(i) = get_FER( Eb_No , PDF_Eb_No , step_dB );    % Equation (24)
                    
    end

    % Compute the probability of error because the receiver is busy and the 
    % probability of error due to collision for all distances between tx and rx:
    
    Lint_max = round(1000*beta)/beta;         % Distance to the farthest interfering vehicle. Up to 1000m distances considered to speed up the calculations.
    distance_int_to_rx = [-Lint_max : 1/beta : Lint_max];           % Distances from all the interfering vehicles to the receiving vehicle.
    distance_int_to_rx ( (length(distance_int_to_rx)+1)/2) = [];    % Remove from the list the position of the receiving vehicle. 
    
    R_PSR = xcorr(PSR);  % Autocorrelation of the PSR function. Equation (20)
    R_PSR = R_PSR(2*max(d_aux)+1:end) / max(R_PSR);  % Remove left part of the function and normalize
    
    for d=1:length(distance_tx_to_rx)

        distance_int_to_tx = distance_int_to_rx + distance_tx_to_rx(d);   % Distances from all the interfering vehicles to the transmitting vehicle.
        
        for i = 1:length(distance_int_to_rx)  % Compute the probability for every interfering vehicle

            [PL_i_Rx std_dev_i_Rx] = get_PL_SH( abs(distance_int_to_rx(i)));  % Pathloss and shadowing for interf and rx
            [PL_i_Tx std_dev_i_Tx] = get_PL_SH( abs(distance_int_to_tx(i)));  % Pathloss and shadowing for interf and tx

            if deltaPRO_pre(d) == 1                
                p_int(i) = 0;     % If the probability of propagation error is one, we don't need to calculate the collision error because it is zero.               
            else                
                [SINR PDF_SINR] = get_SINRdistribution( Pt-PL_Tx_Rx(d) , Pt-PL_i_Rx , std_dev_Tx_Rx(d) , std_dev_i_Rx , noise , Psen , step_dB);   % % Distribution of the SINR of the received packet considering vehicle vi as interferer
                Eb_No = SINR + 10*log10(BW/Rd);  % Convert SINR to Eb/No
                PDF_Eb_No = PDF_SINR;            % Convert SINR to Eb/No
                pSINR(i) = get_FER( Eb_No , PDF_Eb_No , step_dB );              % Equation (30)
                p_int(i) = (pSINR(i)-deltaPRO_pre(d)) / (1 - deltaPRO_pre(d));  % Equation (31)
            end
            
            p_DET_i_Rx(i) = 0.5 * (1 + erf(( Pt - PL_i_Rx - Psen )/(sqrt(2)*std_dev_i_Rx)));  % Probability that the receiving vehicle (vr) senses the interfering one (vi) 
            p_DET_i_Tx(i) = 0.5 * (1 + erf(( Pt - PL_i_Tx - Psen )/(sqrt(2)*std_dev_i_Tx)));  % Probability that the interfering vehicle (vi) senses the transmitting one (vt) or viceversa
            
            p_sim_CT(i) = sigma  * lambda *  p_DET_i_Tx(i)   / (1-CBR*R_PSR( round( abs(distance_int_to_tx(i)) ) + 1 )) ; % Equation (22)
            
            % Differentiate when the interfering is closer than the transmitter: Equation (21)
            if abs(distance_int_to_rx(i)) < abs(distance_tx_to_rx(d))                 
                p_RXB_CT(i) = p_sim_CT(i) * p_DET_i_Rx(i) ;  
            else                
                p_RXB_CT(i) =  0 ;                
            end
            
            p_RXB_HT(i) = Ttr * lambda * p_DET_i_Rx(i) *(1-p_DET_i_Tx(i)) / (1-CBR*R_PSR( round( abs(distance_int_to_tx(i)) ) + 1 ));  % Equation (16)
            
            % Differentiate when the interfering is closer than the transmitter: Equation (32)
            if abs(distance_int_to_rx(i)) >= abs(distance_tx_to_rx(d)) 
                p_COL_CT(i) = p_int(i) * p_sim_CT(i); 
            else
                p_COL_CT(i) = 0; 
            end
            
            p_sim_HT(i) = Ttr * lambda * (1-p_DET_i_Tx(i)) / (1-CBR*R_PSR( round( abs(distance_int_to_tx(i)) ) + 1 )) ; % Equation (18)
            
            p_COL_HT(i) = p_int(i) * p_sim_HT(i) + p_int(i) * p_sim_HT(i) * ( 1-p_DET_i_Rx(i) ) ;  % Equation (28)
             
        end

        % Combine the probability for all potential interfering vehicles to compute the overall probabilities:
        deltaRXB_pre(d) = 1 - prod( 1 - ( p_RXB_CT + p_RXB_HT ) );   % Equation (14) 
        deltaCOL_pre(d) = 1 - prod( 1 - ( p_COL_CT + p_COL_HT ) ) ;  % Equation (26)

        % Calculate final probabilities for each type of error:
        deltaSEN(d) = deltaSEN_pre(d);                                                          % Equation (3)
        deltaRXB(d) = deltaRXB_pre(d) * ( 1 - deltaSEN_pre(d) );                                % Equation (4)
        deltaPRO(d) = deltaPRO_pre(d) * ( 1 - deltaSEN_pre(d) ) * ( 1 - deltaRXB_pre(d) );      % Equation (5)
        deltaCOL(d) = deltaCOL_pre(d) * ( 1 - deltaSEN_pre(d) ) * ( 1 - deltaRXB_pre(d) ) * ( 1 - deltaPRO_pre(d) );    % Equation (6)

    end

    % Compute the Packet Delivery Ratio:    
    PDR = 1 - deltaSEN - deltaRXB - deltaPRO - deltaCOL; % Equation (1)
    
    % Figures with simulation results for validation:    
    file1 = ['simulations\ERRORS_' num2str(beta) 'vehm_' num2str(Rd/1e6) 'Mbps_' num2str(lambda) 'Hz_Pt' num2str(Pt) '_' num2str(B) 'Bytes.fig'];
    file2 = ['simulations\PDR_' num2str(beta) 'vehm_' num2str(Rd/1e6) 'Mbps_' num2str(lambda) 'Hz_Pt' num2str(Pt) '_' num2str(B) 'Bytes.fig'];
    file3 = ['simulations\CBR_' num2str(beta) 'vehm_' num2str(Rd/1e6) 'Mbps_' num2str(lambda) 'Hz_Pt' num2str(Pt) '_' num2str(B) 'Bytes.fig'];
    
    disp('Output: ')
    file_out = [num2str(beta) 'vehm_' num2str(Rd/1e6) 'Mbps_' num2str(lambda) 'Hz_Pt' num2str(Pt) '_' num2str(B) 'Bytes.fig'];
    
    CBR_sim = 0;
    
    % Load simulation results if they exist: 
    if exist(file1,'file')
        fig_ERR = openfig(file1);
        lh = findall(fig_ERR, 'type', 'line');
        X = get(lh,'xdata'); 
        Y = get(lh,'ydata'); 
        delta_PRO_sim = Y{4};
        delta_COL_sim = Y{3};
        delta_RXB_sim = Y{2};
        delta_SEN_sim = Y{1};
        
        fig_PDR = open(file2);
        lh = findall(fig_PDR, 'type', 'line');
        distance_sim = get(lh,'xdata'); 
        PDR_sim = get(lh,'ydata'); 
        clear lh                      
        
        if exist(file3,'file')
            fig_CBR = open(file3);
            hold on
            lh = findall(fig_CBR, 'type', 'bar');
            x_cbr_sim = get(lh,'xdata'); 
            pdf_cbr_sim = get(lh,'ydata'); 
            CBR_sim = sum(x_cbr_sim.*pdf_cbr_sim);
            clear lh             
            disp(['  CBR simulation: ' num2str(CBR_sim)]) 
            stem(CBR,1,'b')
            legend('Simulation','Analytical')
            disp(['  CBR analytical: ' num2str(CBR) ' (' num2str(100*abs(CBR_sim-CBR)/CBR_sim) '% error)'])                        
        else
            disp(['  CBR analytical: ' num2str(CBR) ])
        end
        
    else
        disp('  Equivalent simulation not available.')
        fig_ERR = figure;
        fig_PDR = figure;
        disp(['  CBR analytical: ' num2str(CBR) ])
    end
    
    

    % Plot analytical curves obtained for the different types of errors:
    figure(fig_ERR)
    hold on
    plot(distance_tx_to_rx , deltaPRO, 'r--','LineWidth',2);
    plot(distance_tx_to_rx , deltaCOL, 'k--','LineWidth',2);
    plot(distance_tx_to_rx , deltaRXB, 'g--','LineWidth',2);
    plot(distance_tx_to_rx , deltaSEN, 'm--','LineWidth',2);
    titulo = [num2str(beta*1000) ' veh/km, ' num2str(lambda) ' pkt/s, ' num2str(Rd/1e6) ' Mbps, ' num2str(Pt) ' dBm, ' num2str(B) ' Bytes'];
    title(titulo)
    ylim([0 1])
    ylabel('Probability')
    xlabel('Distance Tx-Rx (m)')
    if exist(file1,'file')
        legend('PRO sim' , 'COL sim' , 'RXB sim', 'SEN sim','PRO analit' , 'COL analit' , 'RXB analit', 'SEN analit','location','northwest')    
    else
        legend('PRO analit' , 'COL analit' , 'RXB analit', 'SEN analit','location','northwest')            
    end    

    % Plot analytical PDR curve obtained:
    figure(fig_PDR)
    hold on
    plot(distance_tx_to_rx , PDR , 'b--','LineWidth',2);
    ylim([0 1])
    title(titulo)
    ylabel('PDR')
    xlabel('Distance Tx-Rx (m)')
    if exist(file1,'file')
        legend('Simulation','Analytical')
    else
        legend('Analytical')
    end

    if exist(file1,'file')        

        % Mean Absolute Deviation (MAD) between the simulation and the analytical model 
        % of the PDR and the different error types using equation (36):
        
        MAD_PDR = mean( abs(PDR - PDR_sim) )*100;
        MAD_SEN = mean( abs(deltaSEN - delta_SEN_sim) )*100;
        MAD_PRO = mean( abs(deltaPRO - delta_PRO_sim) )*100;
        MAD_RXB = mean( abs(deltaRXB - delta_RXB_sim) )*100;
        MAD_COL = mean( abs(deltaCOL - delta_COL_sim) )*100;
        
        disp('  Mean Absolute Deviation results: ')
        fprintf('  PDR \tSEN \tRXB \tPRO \tCOL \n')
        fprintf('  %.2f\t%.2f\t%.2f\t%.2f\t%.2f \n', MAD_PDR, MAD_SEN, MAD_RXB, MAD_PRO, MAD_COL)            
        
    end

    disp('=========================================================')

return
