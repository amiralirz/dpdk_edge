#include "PCAPLoader.cuh"

// Load the pcap file into memory
std::vector<Packet> loadPcapIntoMemory(const std::string& filePath) {
    std::vector<Packet> packets;
    char errbuf[PCAP_ERRBUF_SIZE];

    // Open the pcap file
    pcap_t* handle = pcap_open_offline(filePath.c_str(), errbuf);
    if (handle == nullptr) {
        std::cerr << "Error opening file: " << errbuf << std::endl;
        exit(EXIT_FAILURE);
    }

    struct pcap_pkthdr* header;
    const u_char* data;
    int res, packetCount = 0;

    // Read packets from the file
    while ((res = pcap_next_ex(handle, &header, &data)) >= 0) {
        if (res == 0) {
            // Timeout, continue to next packet
            continue;
        }
        Packet packet;
        packet.data = data;
        packet.header = *header;
        packets.push_back(packet);
        packetCount++;
        if(packetCount == 100000) {
            break;
        }   
    }

    if (res == -1) {
        std::cerr << "Error reading packets: " << pcap_geterr(handle) << std::endl;
        pcap_close(handle);
        exit(EXIT_FAILURE);
    }

    std::cout << "Successfully loaded " << packets.size() << " packets into memory." << std::endl;

    // Close the pcap handle
    pcap_close(handle);
    return packets;
}

//Fragment the packet into multiple mbufs
struct rte_mbuf* createPacketFragmentChain(const u_char* data, uint32_t length, uint16_t fragment_size, struct rte_mempool* mbuf_pool) {
    struct rte_mbuf* head = nullptr;
    struct rte_mbuf* current = nullptr;
    uint16_t fragments = 0;

    while (length > 0) {
        uint16_t size = std::min(length, static_cast<uint32_t>(fragment_size));

        struct rte_mbuf* mbuf = rte_pktmbuf_alloc(mbuf_pool);
        if (!mbuf) {
            std::cerr << "Failed to allocate mbuf for packet fragment." << std::endl;
            // Free any previously allocated fragments
            while (head) {
                struct rte_mbuf* temp = head->next;
                rte_pktmbuf_free(head);
                head = temp;
            }
            return nullptr;
        }

        uint8_t* pkt_data = (uint8_t*)rte_pktmbuf_append(mbuf, size);
        if (!pkt_data) {
            std::cout << "Failed to append data to mbuf." << std::endl;
            rte_pktmbuf_free(mbuf);
            while (head) {
                struct rte_mbuf* temp = head->next;
                rte_pktmbuf_free(head);
                head = temp;
            }
            return nullptr;
        }

        memcpy(pkt_data, data, size);
        data += size;
        length -= size;

        if (!head) {
            head = mbuf; // First fragment
        } else {
            current->next = mbuf; // Link previous fragment
        }
        current = mbuf;
        fragments++;
    }
    
    return head;
}