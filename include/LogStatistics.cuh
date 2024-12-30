#pragma once

#include <iostream>
#include "PortStatistics.cuh"

void print_stats(PortStatistics* stats, int num_ports) {
    for (int i = 0; i < num_ports; i++) {
        std::cout << "Port " << i << " TX: " << stats[i].tx_count << " RX: " << stats[i].rx_count << std::endl;
    }
}