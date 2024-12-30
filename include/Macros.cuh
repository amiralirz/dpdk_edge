#pragma once

#include <cuda_runtime.h>
#include <iostream>

#define CHECK_RTE_ERROR(call)                                                    \
    do {                                                                         \
        int ret = call;                                                          \
        if (ret < 0) {                                                           \
            std::cerr << "RTE error in file " << __FILE__ << " at line "         \
                      << __LINE__ << ":(" << ret << ") " << rte_strerror(rte_errno) << std::endl; \
            return ret;                                                          \
        }                                                                        \
    } while (0)