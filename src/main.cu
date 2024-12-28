#include <iostream>
#include <vector>
#include <string>
#include <pcap.h>
#include <rte_eal.h>
#include <rte_ethdev.h>
#include <rte_mbuf.h>
#include <cstring>

#include "PCAPLoader.cuh"

void sendPackets(const std::vector<Packet>& packets, uint16_t port_id, uint16_t mtu) {
    constexpr uint16_t nb_rxd = 128;
    constexpr uint16_t nb_txd = 512;
    constexpr uint16_t burst_size = 32;

    struct rte_mempool* mbuf_pool = rte_pktmbuf_pool_create("MBUF_POOL", 8192, 256, 0,
                                                            RTE_MBUF_DEFAULT_BUF_SIZE, rte_socket_id());
    if (mbuf_pool == nullptr) {
        rte_exit(EXIT_FAILURE, "Cannot create mbuf pool\n");
    }

    struct rte_eth_conf port_conf = {0};
    if (rte_eth_dev_configure(port_id, 1, 1, &port_conf) < 0) {
        rte_exit(EXIT_FAILURE, "Cannot configure device\n");
    }

    if (rte_eth_rx_queue_setup(port_id, 0, nb_rxd, rte_eth_dev_socket_id(port_id), nullptr, mbuf_pool) < 0) {
        rte_exit(EXIT_FAILURE, "Cannot setup RX queue\n");
    }

    if (rte_eth_tx_queue_setup(port_id, 0, nb_txd, rte_eth_dev_socket_id(port_id), nullptr) < 0) {
        rte_exit(EXIT_FAILURE, "Cannot setup TX queue\n");
    }

    if (rte_eth_dev_start(port_id) < 0) {
        rte_exit(EXIT_FAILURE, "Cannot start device\n");
    }

    std::cout << "Sending packets through port " << port_id << "..." << std::endl;

    for (const auto& packet : packets) {
        struct rte_mbuf* mbuf_chain = createPacketFragmentChain(packet.data, packet.header.caplen, mtu, mbuf_pool);
        if (!mbuf_chain) {
            std::cerr << "Failed to create packet fragment chain." << std::endl;
            continue;
        }

        if (rte_eth_tx_burst(port_id, 0, &mbuf_chain, 1) < 1) {
            std::cerr << "Failed to send packet chain." << std::endl;
            // Free the entire mbuf chain
            struct rte_mbuf* temp;
            while (mbuf_chain) {
                temp = mbuf_chain->next;
                rte_pktmbuf_free(mbuf_chain);
                mbuf_chain = temp;
            }
        }
    }

    rte_eth_dev_stop(port_id);
    rte_eth_dev_close(port_id);

    std::cout << "All packets sent." << std::endl;
}

int main(int argc, char* argv[]) {
    if (rte_eal_init(argc, argv) < 0) {
        rte_exit(EXIT_FAILURE, "Error with EAL initialization\n");
    }

    std::string filePath = "/home/amirali/dpdk_assets/test/sample.pcap";

    // Load PCAP file into memory
    std::vector<Packet> packets = loadPcapIntoMemory(filePath);

    // Define MTU for fragmentation
    constexpr uint16_t mtu = 1500;

    // Send packets through port 0
    sendPackets(packets, 0, mtu);

    return 0;
}
