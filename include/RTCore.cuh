#pragma once

#include <iostream>
#include <vector>

#include "TCore.cuh"
#include "PCAPLoader.cuh"
#include "PortStatistics.cuh"
#include "rte_eal.h"
#include "rte_ethdev.h"

#define BUSRT_SIZE 128

/*
* The arguments for the real-time core.
*/
struct RTCoreArgs {
    uint16_t tx_port_id;
    uint16_t rx_port_id;
    int* force_quit;
    // uint16_t mtu;
    PortStatistics* stats;
    const std::vector<Packet>& packets;
    rte_mempool* mbuf_pool_tx;
};

/*
* The real-time core that sends packets from the tx_port_id and receives packets on the rx_port_id.
*/
int RTCore(void* args);
