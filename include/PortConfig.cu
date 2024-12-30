#include "PortConfig.cuh"

void ConfigPort(PortType port_type, uint16_t port_id, rte_mempool** mbuf_pool){
    int ret;
    *mbuf_pool = rte_pktmbuf_pool_create("MBUF_POOL", 8192, 256, 0, RTE_MBUF_DEFAULT_BUF_SIZE, rte_socket_id());
    if (mbuf_pool == nullptr) {
        rte_exit(EXIT_FAILURE, "Cannot create mbuf pool\n");
    } 

    rte_eth_conf port_conf;
    ret = rte_eth_dev_configure(port_id, 1, 1, &port_conf);
    if (ret < 0) {
        rte_exit(EXIT_FAILURE, "Cannot configure device: err=%d, port=%u\n", ret, port_id);
    }

    rte_eth_rxconf rxq_conf;
    rte_eth_dev_info dev_info;
    ret = rte_eth_dev_info_get(port_id, &dev_info);
    if (ret < 0) {
        rte_exit(EXIT_FAILURE, "Cannot get device info: err=%d, port=%u\n", ret, port_id);
    }

    rxq_conf = dev_info.default_rxconf;

    ret = rte_eth_rx_queue_setup(port_id, 0, nb_rxd, rte_eth_dev_socket_id(port_id), &rxq_conf, *mbuf_pool);
    if (ret < 0) {
        rte_exit(EXIT_FAILURE, "rte_eth_rx_queue_setup:err=%d, port=%u\n", ret, port_id);
    }

    // rte_eth_dev_adjust_nb_rx_tx_desc(rx_port_id, &nb_rxd, &nb_txd);
    ret = rte_eth_dev_start(port_id);
    if (ret < 0) {
        rte_exit(EXIT_FAILURE, "rte_eth_dev_start:err=%d, port=%u\n", ret, port_id);
    }
}
