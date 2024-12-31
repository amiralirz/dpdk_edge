#pragma once

#include <iostream>
#include <vector>

#include "TCore.cuh"
#include "PCAPLoader.cuh"
#include "PortStatistics.cuh"
#include "rte_eal.h"
#include "rte_ethdev.h"

#define MAX_PKT_BURST 32

void sendPackets(const std::vector<Packet>& packets, uint16_t port_id, rte_mempool* mbuf_pool, PortStatistics* stats, rte_eth_dev_tx_buffer *tx_buffer);

/*
* The arguments for the TX core.
*/
struct TxCoreArgs {
    uint16_t port_id;
    int* force_quit;
    // uint16_t mtu;
    PortStatistics* stats;
    const std::vector<Packet>& packets;
    rte_mempool* mbuf_pool;
};

/*
* The TX core that sends packets on the given port.
*/
int TxCore(void* args);
