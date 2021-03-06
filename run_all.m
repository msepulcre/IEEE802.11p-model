function run_all

% This script runs all the configurations included in the following paper:  
%
%    Miguel Sepulcre, Manuel Gonzalez-Martín, Javier Gozalvez, Rafael Molina-Masegosa, 
%    "Analytical Models of the Performance of IEEE 802.11p Vehicle to Vehicle Communications", 
%    arXiv:2104.07923 [cs.NI], April 2021.
%    Available at: https://arxiv.org/abs/2104.07923
    
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
