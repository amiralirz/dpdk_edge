#include "RCore.cuh"

int RxCore(void* args){
    RxCoreArgs* rx_args = (RxCoreArgs*) args;
    uint16_t port_id = rx_args->port_id;
    int* force_quit = rx_args->force_quit;
    // uint16_t mtu = rx_args->mtu;
    PortStatistics* stats = rx_args->stats;

    struct rte_mbuf* pkts_burst[BUSRT_SIZE];
    uint16_t nb_rx;

    while(!(*force_quit)){
        nb_rx = rte_eth_rx_burst(port_id, 0, pkts_burst, BUSRT_SIZE);
        rte_pktmbuf_free_bulk(pkts_burst, nb_rx);
    }

    return 0;
}