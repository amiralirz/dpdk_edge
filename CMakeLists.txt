cmake_minimum_required(VERSION 3.20)

project(PCP LANGUAGES CUDA CXX)

set(CMAKE_CUDA_ARCHITECTURES 89)
# set(CMAKE_VERBOSE_MAKEFILE ON)

find_package(PkgConfig REQUIRED)
pkg_check_modules(DPDK REQUIRED libdpdk)
pkg_check_modules(Pcap REQUIRED libpcap)

# message(STATUS "DPDK_LIBRARIES: ${DPDK_LIBRARIES}")
# message(STATUS "DPDK_LIBRARY_DIRS: ${DPDK_LIBRARY_DIRS}")

add_library(loader SHARED src/PCAPLoader.cu)
target_include_directories(loader PUBLIC include ${DPDK_INCLUDE_DIRS} ${Pcap_INCLUDE_DIRS})
target_link_directories(loader PRIVATE ${DPDK_LIBRARY_DIRS} ${Pcap_LIBRARY_DIRS})
target_link_libraries(loader ${DPDK_LIBRARIES} ${Pcap_LIBRARIES})
target_compile_options(loader PRIVATE -lpcap -Xcompiler -mssse3)

add_executable(PCP src/main.cu)
target_include_directories(PCP PUBLIC include ${DPDK_INCLUDE_DIRS} ${Pcap_INCLUDE_DIRS})
target_link_directories(PCP PRIVATE ${DPDK_LIBRARY_DIRS} ${Pcap_LIBRARY_DIRS})   
target_link_libraries(PCP loader ${DPDK_LIBRARIES} ${Pcap_LIBRARIES})
target_compile_options(PCP PRIVATE -lpcap -Xcompiler -mssse3)