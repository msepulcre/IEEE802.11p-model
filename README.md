# Analytical Models of the Performance of IEEE 802.11p Vehicle to Vehicle Communications
This code implements in Matlab the analytical models of the communication performance of IEEE 802.11p described in the following paper:

    Miguel Sepulcre, Manuel Gonzalez-Martín, Javier Gozalvez, Rafael Molina-Masegosa, 
    "Analytical Models of the Performance of IEEE 802.11p Vehicle to Vehicle Communications", 
    Arxiv, 2021.

This paper addresses this gap, and presents the first analytical models capable to accurately model the performance of vehicle-to-vehicle communications based on the IEEE 802.11p standard. The model quantifies the PDR (Packet Delivery Ratio) as a function of the distance between transmitter and receiver. The paper also presents new analytical models to quantify the probability of the four different types of packet errors in IEEE 802.11p. In addition, the paper presents the first analytical model capable to accurately estimate the Channel Busy Ratio (CBR) metric even under high channel load levels. All the analytical models are validated by means of simulation for a wide range of parameters, including traffic densities, packet transmission frequencies, transmission power levels, data rates and packet sizes. 

In order to comply with our sponsor guidelines, we would appreciate if any publication using this code references the above-mentioned publication.

model80211p.m is the main script you have to run to get the PDR and the probability of each of the four transmission errors as a function of the distance between transmitter and receiver. 

If you want to run the same configurations than the ones in the paper, you could simply run the script run_all.m

The resulting figures are compared with simulations when the same configuration is available in the ./simulations folder.

The lines of code that contain equations that appear in the paper are shown with their number in brackets so that they can be easily identified in the paper. 

Feel free to contact Prof. Miguel Sepulcre (msepulcre@umh.es) if you are interested in collaborating on the evolution of these models. 
