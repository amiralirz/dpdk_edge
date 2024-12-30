#pragma once

#include <iostream>
#include <vector>

#include "TCore.cuh"
#include "PCAPLoader.cuh"
#include "PortStatistics.cuh"
#include "rte_eal.h"
#include "rte_ethdev.h"

#define BUSRT_SIZE 128

struct RxCoreArgs {
    uint16_t port_id;
    int* force_quit;
    // uint16_t mtu;
    PortStatistics* stats;
};

int RxCore(void* args);
