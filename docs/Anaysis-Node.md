# How I used monitoring system to analyze the performance of a data-availability node?
In this article`https://medium.com/@qlclnoc/how-i-made-celestia-node-monitoring-tool-by-docker-compose-f80f4730903`, I have explained how I created toolings for the Celestia Network. Now, I will explain how I leveraged the monitoring system to monitor the performance of my network node.

After running docker-compose, I obtained metrics for monitoring performance. I divided them into two groups: group 1 includes metrics related to Celestia nodes, and group 2 includes metrics related to the host.

1. Group 1: DAS Params
For group 1, Celestia nodes provide us with various metrics, but we focus on the following important ones:

 * DAS: Network Height, Total Sampling, Last Sampled Time, Das Worker...
 * Play For Blob: PFB Count, Last Time PFB...
 * Bad Encoding...
 * Uptime...

The detailed list of metrics can be viewed in the Metrics Browser of Grafana. Based on the classification and comparison with the collected metrics, along with the data type and nature of each metric, I have synthesized the following charts and formulas:

Gauge Charts:
 * DAS Network Height: das_network_head
 * DAS Total Sampled: das_total_sampled_headers
 * Last Sampled Time: time() - das_latest_sampled_ts
 * PFB Count: pfb_count
 * Last PFB (minutes ago): `(time()*1000 - last_pfb_timestamp)/(1000*60)`
 * Uptime Score (%): 100 * das_total_sampled_headers / das_network_head

Stats Charts:
 * DAS Worker: das_busy_workers_amount
Time Series Charts:
 * Bad Encoding Count: badencoding

Additionally, I built a system to collect metrics from https://leaderboard.celestia.tools/api/v1/ to gather aggregated metrics network-wide, such as Uptime Rankings and PFB Count Rankings. This enriches my monitoring dashboard and provides insights into the position of my node compared to other nodes on the network.

My system is built as a Docker image and deployed on any system. I also attempted to retrieve other parameters from Celestia's Node API, but encountered some execution environment issues, preventing me from deploying all metrics via docker-compose. I will continue working to address this problem. If you're interested, you can refer to the code at the following public link: https://github.com/thinhpn/celestia-exporter.

I have also built two additional leaderboards for tracking Uptime Score and PFB Count:
Bar gauge:
 * PFB Count Leaderboard: sort_desc(topk(10, celestia_node_pfb_count))
 * Uptime Score Leaderboard (%): topk(10, sort_desc(celestia_node_uptime))

With these additions, our monitoring dashboard is now comprehensive and rich in information.

2. Group 2: Host Params

In this second group, which is relatively straightforward for me, we need to monitor the following metrics for a server system: CPU, RAM, Disk Usage, Network Traffic In/Out (kb/s), and Server Uptime.

Fortunately, there are many sources available to reference and these metrics are quite common. After some research, I have constructed a monitoring dashboard and formulas for each metric using node-exporter metrics specifically, as follows:

 * CPU Load (%): 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle", job="node-exporter"}[5m])) * 100)
 * RAM Usage (%): 100 - ((node_memory_MemAvailable_bytes{job="node-exporter"} / node_memory_MemTotal_bytes{job="node-exporter"}) * 100)
 * Disk Usage (%): 100 * node_filesystem_free_bytes{mountpoint="/etc/hostname"} / node_filesystem_size_bytes{mountpoint="/etc/hostname"}
 * Server Uptime: time() - node_boot_time_seconds
 * Network Traffic Download (kb/s): avg(irate(node_network_receive_bytes_total{device="eth0"}[5m])) / 1024
 * Network Traffic Upload (kb/s): avg(irate(node_network_transmit_bytes_total{device="eth0"}[5m])) / 1024

 So, I have completed building the monitoring dashboard for both DAS nodes and hosts.
Now, let's take a look at the metrics of my DAS nodes and hosts!

3. Analyzing Node Performance

