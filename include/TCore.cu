#include "TCore.cuh"

void sendPackets(const std::vector<Packet>& packets, uint16_t port_id, rte_mempool* mbuf_pool, PortStatistics* stats, rte_eth_dev_tx_buffer *tx_buffer) {
    constexpr uint16_t mtu = 1500;
    uint16_t ret;

    int packet_index = 0;
    struct rte_mbuf* mbuf[MAX_PKT_BURST];
    rte_pktmbuf_alloc_bulk(mbuf_pool, mbuf, MAX_PKT_BURST);

    for (const auto& packet : packets) {
        // struct rte_mbuf* mbuf_chain = createPacketFragmentChain(packet.data, packet.header.caplen, mtu, mbuf_pool);
        uint8_t* pkt_data = (uint8_t*)rte_pktmbuf_append(mbuf[packet_index], packet.header.caplen);
        rte_memcpy(pkt_data, packet.data, packet.header.caplen);
        rte_eth_tx_buffer(port_id, 0, tx_buffer, mbuf[packet_index]);
        packet_index++;

        if(packet_index == MAX_PKT_BURST){
            rte_eth_tx_buffer_flush(port_id, 0, tx_buffer);
            packet_index = 0;
            rte_pktmbuf_alloc_bulk(mbuf_pool, mbuf, MAX_PKT_BURST);
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
    static struct rte_eth_dev_tx_buffer tx_buffer;
    rte_eth_tx_buffer_init(&tx_buffer, 32);

    printf("Starting TX core on port %u\n", port_id);
    int count = 0;
    uint16_t ret;
    int packet_index = 0;
    struct rte_mbuf* mbuf[MAX_PKT_BURST];
    rte_pktmbuf_alloc_bulk(mbuf_pool, mbuf, MAX_PKT_BURST);

    while (!(*force_quit)) {
        // sendPackets(packets, port_id, mbuf_pool, stats, &tx_buffer);
        for (const auto& packet : packets) {
            // struct rte_mbuf* mbuf_chain = createPacketFragmentChain(packet.data, packet.header.caplen, mtu, mbuf_pool);
            uint8_t* pkt_data = (uint8_t*)rte_pktmbuf_append(mbuf[packet_index], packet.header.caplen);
            rte_memcpy(pkt_data, packet.data, packet.header.caplen);
            rte_eth_tx_buffer(port_id, 0, &tx_buffer, mbuf[packet_index]);
            packet_index++;

            if(packet_index == MAX_PKT_BURST){
                rte_eth_tx_buffer_flush(port_id, 0, &tx_buffer);
                packet_index = 0;
                rte_pktmbuf_alloc_bulk(mbuf_pool, mbuf, MAX_PKT_BURST);
            }
        }
    }   

    return 0;
}