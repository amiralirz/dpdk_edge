#pragma once
#include <cstdint>
#include "rte_ethdev.h"
#include "Macros.cuh"
#include "Params.cuh"

enum PortType {
    RX_PORT,
    TX_PORT,
    RT_PORT
};

/*
* Configures the port with the given port_id.
* 
* @param port_type: The type of the port (RX_PORT or TX_PORT).
* @param port_id: The port id.
* @param mbuf_pool: The pointer to the mbuf pool.
* @param pool_name: The name of the mbuf pool.
*/
void ConfigPort(PortType port_type, uint16_t port_id, rte_mempool** mbuf_pool, const char* pool_name);