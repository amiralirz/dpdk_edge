#include "RTCore.cuh"

int RTCore(void* args){
    RTCoreArgs* rt_args = (RTCoreArgs*) args;
    uint16_t tx_port_id = rt_args->tx_port_id;
    uint16_t rx_port_id = rt_args->rx_port_id;
    int* force_quit = rt_args->force_quit;
    PortStatistics* stats = rt_args->stats;
    const std::vector<Packet>& packets = rt_args->packets;
    rte_mempool* mbuf_pool_tx = rt_args->mbuf_pool_tx;
    int nb_rx;

    struct rte_mbuf* pkts_burst[BUSRT_SIZE];

    while(!(*force_quit)){
        sendPackets(packets, tx_port_id, mbuf_pool_tx, stats);
        stats->tx_count += packets.size();

        nb_rx = rte_eth_rx_burst(rx_port_id, 0, pkts_burst, BUSRT_SIZE);
        for(uint16_t i = 0; i < nb_rx; i++){
            rte_pktmbuf_free(pkts_burst[i]);
        }
        stats->rx_count += nb_rx;
    }

    return 0;
}