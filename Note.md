### Check status các target datasource: http://ip-server:9090/targets?search=
### Các công thức tính biểu đồ từ Metrics của node-exporter:
 - CPU Load (%):
    + 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle", job="node-exporter"}[5m])) * 100)
 - RAM Usage (%):
    + 100 - ((node_memory_MemAvailable_bytes{job="node-exporter"} / node_memory_MemTotal_bytes{job="node-exporter"}) * 100)
 - Network Traffic (Mbps):
    + Download: irate(node_network_receive_bytes_total{device="eth0"}[1m]) / 1024 / 1024
    + Upload: irate(node_network_transmit_bytes_total{device="eth0"}[1m])/1024/1024
 - Free Disk (%):
    + 100*node_filesystem_free_bytes{mountpoint="/etc/hostname"} / node_filesystem_size_bytes{mountpoint="/etc/hostname"}

### Test nhanh script với docker desktop:
 docker run -it -v C:\Users\User\OneDrive\Coding\CELESTIA\celestia-dockers:/home/ --name "TEST_SCRIPT" -h TEST_SCRIPT_SERVER ubuntu:latest
 Lưu ý cần set quyền cho script trước khi chạy: sudo chmod +x celestia_one_script.sh