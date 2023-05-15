# CELESTIA NODE MONITORING TOOL

The rapid growth of decentralized networks has highlighted the importance of monitoring and ensuring the performance of network nodes. Celestia, being a prominent network built on Cosmos SDK, is no exception. In this essay, we will explore the necessity of developing a performance monitoring tool for Celestia network nodes. By analyzing the challenges and potential benefits, we will demonstrate how such a tool can enhance the overall efficiency, reliability, and scalability of the network.

 * Ensuring Network Stability and Uptime:
One fundamental aspect of any blockchain network is the stability and uptime of its nodes. A performance monitoring tool will allow continuous monitoring of key metrics, such as node uptime, response time, and error rates. By proactively identifying and addressing issues, network administrators can ensure a stable and reliable Celestia network for users.

 * Optimizing Resource Allocation:
Efficient resource allocation is crucial for maintaining optimal performance. A performance monitoring tool can provide insights into resource utilization, such as CPU usage, memory consumption, and network bandwidth. By analyzing these metrics, node operators can identify resource bottlenecks, optimize configurations, and allocate resources effectively, leading to improved performance and cost-efficiency.

 * Detecting and Resolving Performance Bottlenecks:
In a complex network like Celestia, performance bottlenecks can occur due to various factors, including network congestion, software bugs, or hardware limitations. A monitoring tool equipped with real-time performance data and analytics can help identify these bottlenecks promptly. By pinpointing the root causes of performance degradation, node operators can take proactive measures to resolve issues and optimize network performance.

 * Enhancing Security and Fault Tolerance:
Performance monitoring goes hand in hand with ensuring network security and fault tolerance. By monitoring key security indicators, such as node synchronization, block validation, and consensus participation, the monitoring tool can detect and raise alarms in case of abnormal behavior or potential security threats. Additionally, by monitoring fault tolerance metrics, such as node failure rates and network partitioning, administrators can implement robust fault recovery mechanisms, ensuring uninterrupted network operation.

* Facilitating Network Scaling and Upgrades:
As Celestia expands and evolves, the need for seamless network scaling and upgrades becomes vital. A performance monitoring tool can provide valuable insights into network performance during scaling events or software updates. It enables administrators to evaluate the impact of changes on performance metrics, identify potential bottlenecks, and ensure a smooth transition without compromising the network's stability or user experience.

The development of a performance monitoring tool for Celestia network nodes is of utmost importance to ensure a robust, scalable, and efficient network infrastructure. By continuously monitoring and optimizing performance, network administrators can proactively address issues, enhance security, optimize resource allocation, and facilitate network growth. The implementation of such a tool will undoubtedly contribute to the overall success and widespread adoption of Celestia, benefiting both network operators and end-users alike.

So, how do we proceed?

That's always a challenging question. We are already familiar with popular monitoring tools like Prometheus and Grafana. Visualizing the metrics as graphs would be suitable for operators to monitor and supervise. However, these tools monitor systems based on system metrics. Where can we obtain the metrics for Celestia?

We can categorize the metrics into two types:

Type 1: Celestia network-specific metrics:

 * celestia_node_das_network_head
 * celestia_node_das_sampled_chain_head
 * celestia_node_last_restart_time
 * celestia_node_head
 * ...
Type 2: Host performance metrics:
 * CPU Load
 * RAM Usage
 * Network Traffic
 * Disk Usage
 * ...
For Type 1, we need to understand how to extract the metrics from the Celestia network nodes to the external monitoring system. Type 2 is more common and easier. After some research, we can use Prometheus' node-exporter to monitor these metrics.

Returning to Type 1, if we examine the code running a service for Celestia, we will notice that the default node metrics are pushed to an endpoint at otel.celestia.tools:4318.

We have the solution now. If we change our endpoint to replace this default endpoint, we can retrieve the necessary metrics.

Note: Changing the endpoint to collect metrics will cause your node not to display information on Tiascan because the default endpoint is the one Tiascan uses to gather node information and process it.

I have made some modifications to the code running the node, and we will have the following service: `celestia light start --core.ip https://rpc-blockspacerace.pops.one/ --keyring.accname my_celes_key --gateway --gateway.addr localhost --gateway.port 26659 --p2p.network blockspacerace --metrics.tls=false --metrics --metrics.endpoint localhost:4318`
Yes, so what if we use OpenTelemetry - a tool to collect metrics from various sources? We can retrieve and display Celestia's metrics on Grafana! Yahoo!!!
In the next step, I will use a solution to set up node-exporter, Prometheus, otel-collector, and Grafana using Docker Compose to enable a quick deployment of the monitoring system with just a single command!
(You can learn how to build a docker-compose.yml file at this link: https://docs.docker.com/compose/)
Here is the complete docker-compose file:

version: "3"
services:

  node-exporter:
    image: prom/node-exporter
    container_name: "node-exporter"
    ports:
      - "9100:9100"    
    networks: 
      - monitoring
    restart: unless-stopped 
  
  celestia-exporter:
    image: thinhpn/celes-exporter-light-node
    platform: linux/arm64
    container_name: "celestia-exporter"
    ports:      
      - "3456:3456"
    depends_on:
    - "node-exporter"    
    networks: 
      - monitoring    
    restart: unless-stopped 

  prometheus:
    image: prom/prometheus
    container_name: "prometheus"
    ports:
      - "6060:9090"
    depends_on:
      - "node-exporter"
      - "celestia-exporter"
    networks: 
      - monitoring
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    command: '--config.file=/etc/prometheus/prometheus.yml'
    restart: unless-stopped 

  otel-collector-default-metric:
    image: otel/opentelemetry-collector
    container_name: "otel-collector-default-metric"
    ports:      
      - "4318:4318"      
    depends_on:
    - "node-exporter"
    - "celestia-exporter"
    - "prometheus"
    networks: 
      - monitoring
    volumes:
      - ./otel_celestia_default_metric/config.yaml:/etc/otel/config.yaml
    command: ["--config=/etc/otel/config.yaml"]
    restart: unless-stopped 

  grafana:
    image: grafana/grafana
    container_name: "grafana"
    user: ":"
    depends_on:
      - "node-exporter"
      - "celestia-exporter"
      - "prometheus"     
      - "otel-collector-default-metric"      
    ports:
      - "3000:3000"      
    networks: 
      - monitoring
    volumes:
      - ./grafana/datasource.yml:/etc/grafana/provisioning/datasources/datasource.yml
      - ./grafana/dashboards.yml:/etc/grafana/provisioning/dashboards/datasource.yml
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./grafana/grafana.ini:/etc/grafana/grafana.ini:ro
    restart: unless-stopped

networks:
  monitoring:
    driver: bridge

This is a video of the process of deploying the Celestia light-node using a single script:

This is the deployment process of the Celestia network node performance monitoring tool using docker-compose in just 30 seconds.

You can refer to my node monitoring link at this address: `https://monitor.thinhpn.com/d/J_fOYgs4k/celestia-node-stats?orgId=1&refresh=10s`