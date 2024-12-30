#pragma once

#include <iostream>
#include <vector>

#include "TCore.cuh"
#include "PCAPLoader.cuh"
#include "PortStatistics.cuh"
#include "rte_eal.h"
#include "rte_ethdev.h"

void sendPackets(const std::vector<Packet>& packets, uint16_t port_id, uint16_t mtu);

struct TxCoreArgs {
    uint16_t port_id;
    int* force_quit;
    uint16_t mtu;
    PortStatistics* stats;
};

int TxCore(void* args);
