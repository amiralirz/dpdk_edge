#include "PortConfig.cuh"

void ConfigPort(PortType port_type, uint16_t port_id, rte_mempool** mbuf_pool, const char* pool_name){
    int ret;
    *mbuf_pool = rte_pktmbuf_pool_create(pool_name, 8192, 256, 0, RTE_MBUF_DEFAULT_BUF_SIZE, rte_socket_id());
    if (*mbuf_pool == nullptr) {
        rte_exit(EXIT_FAILURE, "Cannot create mbuf pool\n");
    } 

    uint16_t nb_rxd = RX_DESC_DEFAULT;
    uint16_t nb_txd = TX_DESC_DEFAULT;

    rte_eth_dev_info dev_info;
    ret = rte_eth_dev_info_get(port_id, &dev_info);
    if (ret < 0) {
        rte_exit(EXIT_FAILURE, "Cannot get device info: err=%d, port=%u\n", ret, port_id);
    }

    ret = rte_eth_dev_adjust_nb_rx_tx_desc(port_id, &nb_rxd, &nb_txd);
    if (ret < 0) {
        rte_exit(EXIT_FAILURE, "rte_eth_dev_adjust_nb_rx_tx_desc:err=%d, port=%u\n", ret, port_id);
    }

    rte_eth_conf port_conf = {0};

    if (port_type == PortType::RX_PORT){
        ret = rte_eth_dev_configure(port_id, 1, 0, &port_conf);
        if (ret < 0) {
            rte_exit(EXIT_FAILURE, "Cannot configure device: err=%d, port=%u\n", ret, port_id);
        }
        rte_eth_rxconf rxq_conf = dev_info.default_rxconf;

        ret = rte_eth_rx_queue_setup(port_id, 0, nb_rxd, 
                        rte_eth_dev_socket_id(port_id), 
                        &rxq_conf, *mbuf_pool);
        if (ret < 0) {
            rte_exit(EXIT_FAILURE, "rte_eth_rx_queue_setup:err=%d, port=%u\n", ret, port_id);
        }
    }
    else if(port_type == PortType::TX_PORT){
        ret = rte_eth_dev_configure(port_id, 0, 1, &port_conf);
        if (ret < 0) {
            rte_exit(EXIT_FAILURE, "Cannot configure device: err=%d, port=%u\n", ret, port_id);
        }
        rte_eth_txconf txq_conf = dev_info.default_txconf;
        
        ret = rte_eth_tx_queue_setup(port_id, 0, nb_txd, 
                        rte_eth_dev_socket_id(port_id), 
                        &txq_conf);
        if (ret < 0) {
            rte_exit(EXIT_FAILURE, "rte_eth_tx_queue_setup:err=%d, port=%u\n", ret, port_id);
        }
    }

    ret = rte_eth_dev_set_ptypes(port_id, RTE_PTYPE_UNKNOWN, NULL, 0);
    if (ret < 0) {
        rte_exit(EXIT_FAILURE, "rte_eth_dev_set_ptypes:err=%d, port=%u\n", ret, port_id);
    }

    ret = rte_eth_dev_start(port_id);
    if (ret < 0) {
        rte_exit(EXIT_FAILURE, "rte_eth_dev_start:err=%d, port=%u\n", ret, port_id);
    }

    ret = rte_eth_promiscuous_enable(port_id);
    if (ret != 0) {
        rte_exit(EXIT_FAILURE, "rte_eth_promiscuous_enable:err=%s, port=%u\n", rte_strerror(-ret), port_id);
    }
}
