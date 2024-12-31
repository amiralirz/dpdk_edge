#include "PCAPLoader.cuh"
#include "TCore.cuh"
#include "RCore.cuh"
#include "Macros.cuh"
#include "PortStatistics.cuh"
#include "LogStatistics.cuh"
#include "Params.cuh"
#include "PortConfig.cuh"
#include "RTCore.cuh"

int main(int argc, char* argv[]) {
    if (rte_eal_init(argc, argv) < 0) {
        rte_exit(EXIT_FAILURE, "Error with EAL initialization\n");
    }

    // printf("Total ports ddavailable: %d\n", rte_eth_dev_count_avail());
    RTE_LOG(INFO, USER1, "Total ports available: %d\n", rte_eth_dev_count_avail());

    std::string filePath = "/home/amirali/sample.pcap";
    std::vector<Packet> packets = loadPcapIntoMemory(filePath);    

    uint16_t rx_port_id = 1;  
    uint16_t tx_port_id = 0;  

    rte_mempool* rx_mbuf_pool;
    rte_mempool* tx_mbuf_pool;

    ConfigPort(PortType::RX_PORT, rx_port_id, &rx_mbuf_pool, "RX_MBUF_POOL");
    ConfigPort(PortType::TX_PORT, tx_port_id, &tx_mbuf_pool, "TX_MBUF_POOL");

    PortStatistics statistics[2]; // 0 for rx, 1 for tx
    PortStatistics prev_statistics[2];
    int force_quit = 0;
    RxCoreArgs rx_args = {rx_port_id, &force_quit, &statistics[0]};
    TxCoreArgs tx_args = {tx_port_id, &force_quit, &statistics[1], packets, tx_mbuf_pool};

    rte_eal_remote_launch(RxCore, &rx_args, 1);
    rte_eal_remote_launch(TxCore, &tx_args, 2);

    // RTCoreArgs rt_args = {tx_port_id, rx_port_id, &force_quit, &statistics[0], packets, tx_mbuf_pool};

    // printf("Starting RTCore\n");
    // rte_eal_remote_launch(RTCore, &rt_args, 1);

    while(!force_quit){
        measure_throughput(0);
        measure_throughput(1);
        rte_delay_ms(1000);
    }

    return 0;
}
