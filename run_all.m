function run_all

% This script runs all the configurations included in the following paper:  
%
%  Miguel Sepulcre, Manuel Gonzalez-Martín, Javier Gozalvez, Rafael Molina-Masegosa, Baldomero Coll-Perales, 
%  "Analytical Models of the Performance of IEEE 802.11p Vehicle to Vehicle Communications", 
%  IEEE Transactions on Vehicular Technology, November 2021. DOI: 10.1109/TVT.2021.3124708
%  Final version available at: https://ieeexplore.ieee.org/document/9599363
%  Post-print version available at: https://arxiv.org/abs/2104.07923
    
%   model80211p(beta,lambda,Pt,B,Rd);

    model80211p(0.06,10,23,190,6e6); 
    model80211p(0.06,10,23,190,18e6); 
    model80211p(0.06,10,23,190,27e6); 
    
    model80211p(0.12,25,23,190,6e6); 
    model80211p(0.12,25,23,190,18e6); 
    model80211p(0.12,25,23,190,27e6); 
    
    model80211p(0.06,10,15,190,6e6); 
    model80211p(0.06,10,23,190,6e6); 
    model80211p(0.06,10,30,190,6e6); 
    
    model80211p(0.12,25,15,190,6e6); 
    model80211p(0.12,25,23,190,6e6); 
    model80211p(0.12,25,30,190,6e6); 
       
    model80211p(0.06,10,23,190,6e6); 
    model80211p(0.06,10,23,500,6e6);         

return
