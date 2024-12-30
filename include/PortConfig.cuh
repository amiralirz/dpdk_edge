#pragma once
#include <cstdint>
#include "rte_ethdev.h"
#include "Macros.cuh"
#include "Params.cuh"

enum PortType {
    RX_PORT,
    TX_PORT
};

void ConfigPort(PortType port_type, uint16_t port_id, rte_mempool** mbuf_pool);