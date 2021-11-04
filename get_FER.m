function [ FER_avg ] = get_FER ( Eb_No , PDF_Eb_No , step_dB)
     
    % get_FER calculates the average FER experienced given the PDF of the 
    % SINR at the receiver and a given coding scheme.
    %
    % This is an auxiliary script used by function model80211p to model the 
    % communication performance of IEEE 802.11p using the analytical models described in:
    % 
    %    Miguel Sepulcre, Manuel Gonzalez-Martín, Javier Gozalvez, Rafael Molina-Masegosa, Baldomero Coll-Perales, 
    %    "Analytical Models of the Performance of IEEE 802.11p Vehicle to Vehicle Communications", 
    %    IEEE Transactions on Vehicular Technology, November 2021. DOI: 10.1109/TVT.2021.3124708
    %    Final version available at: https://ieeexplore.ieee.org/document/9599363
    %    Post-print version available at: https://arxiv.org/abs/2104.07923
    %
    % Input parameters:
    %    Eb_No: Energy per bit over noise. 
    %    PDF: Probability Density Function of the Eb_No levels.
    %    step_dB: discrete steps to compute the PDF of the Eb_No (dB)
    %
    % Output metric:
    %    avg_FER: average probability of error for the different distances considered in the input parameters.
    %
    % The equations that are identified with a number between brackets in this script are the ones
    % that also appear in the paper so that they can be easily identified.

    a = min(-1 , Eb_No(1)); % Select the extreme values so that the interpolation does not cause an error
    b = max(36 , Eb_No(end));

    % Values of the LUTs obtained from Fig.14 with L=1 from paper O. Goubet et al., 
    % "Low-Complexity Scalable Iterative Algorithms for IEEE 802.11p Receivers," 
    % IEEE Transactions on Vehicular Technology, vol. 64, no. 9, pp. 3944-3956, Sept. 2015
    vector_Eb_No_paper = [a 0 5  10     15   20   25   30   35    b];
    vector_FER_paper =   [1 1 1 0.4 1.5e-2 4e-3 3e-3 2e-3 1e-3 1e-3];           

    FER_interp = interp1(vector_Eb_No_paper , vector_FER_paper , Eb_No , 'linear');    % Interpolated values from FER vs Eb/No curve

    FER_avg =  PDF_Eb_No * FER_interp' * step_dB;   % Provides the average FER. 

end
