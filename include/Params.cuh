#pragma once

#include <rte_ethdev.h>
#include <rte_mbuf.h>

#define RX_DESC_DEFAULT 1024
#define TX_DESC_DEFAULT 1024

static uint16_t nb_rxd = 1024;
static uint16_t nb_txd = 1024;