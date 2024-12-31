#include "TCore.cuh"

void sendPackets(const std::vector<Packet>& packets, uint16_t port_id, rte_mempool* mbuf_pool, PortStatistics* stats) {
    constexpr uint16_t mtu = 1500;
    uint16_t ret;

    for (const auto& packet : packets) {
        // struct rte_mbuf* mbuf_chain = createPacketFragmentChain(packet.data, packet.header.caplen, mtu, mbuf_pool);
        struct rte_mbuf* mbuf = rte_pktmbuf_alloc(mbuf_pool);
        uint8_t* pkt_data = (uint8_t*)rte_pktmbuf_append(mbuf, packet.header.caplen);
        memcpy(pkt_data, packet.data, packet.header.caplen);

        // if (!mbuf_chain) {
        //     std::cerr << "Failed to create packet fragment chain." << std::endl;
        //     continue;
        // }

        ret = rte_eth_tx_burst(port_id, 0, &mbuf, 1);
        if (ret < 1) {
            rte_pktmbuf_free(mbuf);
            // Free the entire mbuf chain
            // struct rte_mbuf* temp = nullptr;
            // while (mbuf_chain) {
            //     temp = mbuf_chain->next;
            //     rte_pktmbuf_free(mbuf_chain);
            //     mbuf_chain = temp;
            // }
        }
    }
}

int TxCore(void* args){
    TxCoreArgs* tx_args = (TxCoreArgs*) args;
    uint16_t port_id = tx_args->port_id;
    int* force_quit = tx_args->force_quit;
    PortStatistics* stats = tx_args->stats;
    const std::vector<Packet>& packets = tx_args->packets;
    rte_mempool* mbuf_pool = tx_args->mbuf_pool;

    // printf("mbuf_pool = %p\n", mbuf_pool);

    printf("Starting TX core on port %u\n", port_id);
    int count = 0;

    while (!(*force_quit)) {
        // if(count == 200){
        //     break;
        // }
        sendPackets(packets, port_id, mbuf_pool, stats);
        count++;
    }   

    return 0;
}