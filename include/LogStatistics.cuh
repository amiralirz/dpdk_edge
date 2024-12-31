#pragma once

#include <iostream>
#include "PortStatistics.cuh"

void print_stats(PortStatistics* stats,const int num_ports) {
    PortStatistics *stats_copy = (PortStatistics*) malloc(num_ports * sizeof(PortStatistics));
    memcpy(stats_copy, stats, num_ports * sizeof(PortStatistics));
    std::cout << "Port statistics:" << std::endl;
    for(int i = 0; i < num_ports; i++){
        std::cout << "Port " << i << ": " << std::endl;
        std::cout << "    TX count: " << stats_copy[i].tx_count << std::endl;
        std::cout << "    TX bytes: " << stats_copy[i].tx_bytes << std::endl;
        std::cout << "    RX count: " << stats_copy[i].rx_count << std::endl;
        std::cout << "    RX bytes: " << stats_copy[i].rx_bytes << std::endl;
    }
    free(stats_copy);   
}

void measure_throughput(uint16_t port_id){
    const int delay_ms = 1;
    struct rte_eth_stats stats, next_stats;
    rte_eth_stats_get(port_id, &stats);
    rte_delay_ms(delay_ms);
    rte_eth_stats_get(port_id, &next_stats);

    double rx_Mbps = (next_stats.ibytes - stats.ibytes) * 8 / (delay_ms * 1000);
    double tx_Mbps = (next_stats.obytes - stats.obytes) * 8 / (delay_ms * 1000);

    std::cout << "Port " << port_id << " statistics:" << std::endl;
    std::cout << "    RX packets: " << stats.ipackets << std::endl;
    std::cout << "    RX bytes: " << stats.ibytes << std::endl;
    printf("    RX Mbps: %.2f\n", rx_Mbps );
    std::cout << "    TX packets: " << stats.opackets << std::endl;
    std::cout << "    TX bytes: " << stats.obytes << std::endl;
    printf("    TX Mbps: %.2f\n", tx_Mbps );
}