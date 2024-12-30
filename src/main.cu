#include "PCAPLoader.cuh"
#include "TCore.cuh"
#include "RCore.cuh"
#include "Macros.cuh"
#include "PortStatistics.cuh"
#include "LogStatistics.cuh"
#include "Params.cuh"
#include "PortConfig.cuh"

int main(int argc, char* argv[]) {
    if (rte_eal_init(argc, argv) < 0) {
        rte_exit(EXIT_FAILURE, "Error with EAL initialization\n");
    }

    std::string filePath = "/home/amirali/dpdk_assets/test/sample.pcap";
    // std::vector<Packet> packets = loadPcapIntoMemory(filePath);    

    uint16_t rx_port_id = 0;  
    rte_mempool* mbuf_pool;
    ConfigPort(PortType::RX_PORT, rx_port_id, &mbuf_pool);

    PortStatistics statistics[2]; // 0 for rx, 1 for tx
    int force_quit = 0;
    RxCoreArgs rx_args = {rx_port_id, &force_quit, &statistics[0]};

    int lcore_id = 1;

    rte_eal_remote_launch(RxCore, &rx_args, lcore_id);

    while(!force_quit){
        print_stats(statistics, 1);
        rte_delay_ms(1000);
    }

    return 0;
}
