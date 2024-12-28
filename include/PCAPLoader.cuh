#pragma once

#include <pcap.h>
#include <vector>
#include <iostream>

#include <rte_mbuf.h>

struct Packet {
    const u_char* data;
    struct pcap_pkthdr header;
};

std::vector<Packet> loadPcapIntoMemory(const std::string& filePath);

struct rte_mbuf* createPacketFragmentChain(const u_char* data, uint32_t length, uint16_t fragment_size, struct rte_mempool* mbuf_pool);




