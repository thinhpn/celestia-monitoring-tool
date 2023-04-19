- Check status các target datasource: http://ip-server:9090/targets?search=
- Một số các metric để giám sát server:
   + CPU Usage: node_cpu_seconds_total
   + CPU Load: node_load1, node_load5, node_load15
   + Memory Usage: node_memory_MemTotal_bytes, node_memory_MemFree_bytes, node_memory_Cached_bytes, node_memory_Buffers_bytes, node_memory_Active_bytes, + node_memory_Inactive_bytes, node_memory_SwapTotal_bytes, node_memory_SwapFree_bytes
   + Disk Usage: node_filesystem_avail_bytes, node_filesystem_size_bytes
   + Network Traffic: node_network_receive_bytes_total, node_network_transmit_bytes_total
   + Disk IO: node_disk_io_time_seconds_total
   + Uptime: node_time_seconds

 docker run -it -v C:\Users\User\OneDrive\Coding\CELESTIA\celestia-dockers:/home/ --name "TEST_SCRIPT" -h TEST_SCRIPT_SERVER ubuntu:latest