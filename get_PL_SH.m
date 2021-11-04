function [ PL , std_dev ] = get_PL_SH ( distance );

% get_PL_SH calculates the pathloss and shadowing for a given set of Tx-Rx
% distances following the Winner+ B1 propagation model. 
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
% The equations that are identified with a number between brackets in this script are the ones
% that also appear in the paper so that they can be easily identified. 

    % Parameters of the radio propagation model:
    fc = 5.89e9;                % Carrier frequency (Hz)
    hBS = 1.5;                  % Transmitter antenna height (m)
    hMS = 1.5;                  % Receiver antenna height (m)
    environmentHeight = 0.5;    % Average environmental height (m)
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
