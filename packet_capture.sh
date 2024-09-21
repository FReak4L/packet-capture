#!/bin/bash

# Name of file for captured packets
capture_file="capture.pcap"


error_exit() {
    echo -e "\033[31mError: $1\033[0m"  # Print in red
    exit 1
}

# Check tshark
if ! command -v tshark &> /dev/null; then
    echo "Installing tshark..."
    if ! sudo apt-get install -y tshark; then
        error_exit "Failed to install tshark."
    fi
else
    echo "tshark is already installed."
fi


clear

# Prompt 
read -p "Enter the network interface (e.g., eth0, wlan0): " iface

# Validate the network interface
if ! ip link show "$iface" &> /dev/null; then
    error_exit "Network interface '$iface' does not exist."
fi

# Get capture duration and max packets
read -p "Enter capture duration (seconds): " duration
read -p "Enter max packets to capture: " max_packets

# Remove capture file
rm -f "$capture_file"

# Start capturing packets
echo -e "\033[1;34mStarting to capture packets on interface '$iface' for $duration seconds...\033[0m"  
if ! sudo tshark -i "$iface" -a duration:"$duration" -c "$max_packets" -w "$capture_file"; then
    error_exit "Failed to capture packets."
fi

# Analyze captured packets
echo -e "\033[1;34mAnalyzing captured packets...\033[0m"  
tshark -r "$capture_file" -Y "tcp or icmp or ip" -T fields \
-e tcp.analysis.retransmission \
-e tcp.flags.reset | \
awk '
BEGIN {
    total_packets = 0; 
    retransmission_packets = 0; 
    reset_packets = 0;

    # Initialize counters
}
{
    total_packets++;
    if ($1 == "1") retransmission_packets++;
    if ($2 == "1") reset_packets++;
}
END {
    if (total_packets == 0) {
        print "\nNo packets found.";
        exit 1;
    }

    # Calculate values
    lost_packets = 0; # implement logic if needed
    out_of_order_packets = 0; # implement logic if needed

    # Print summary metrics
    printf "\n\033[1;32m@FreakXray Session Report\033[0m\n\n";
    printf "%-30s%-20s\n", "Analysis Metrics", "";
    printf "%-30s%-20s\n", "Total Packets", total_packets;
    printf "%-30s%-20s\n", "Lost Packets", lost_packets;
    printf "%-30s%-20s\n", "Reset Packets", reset_packets;
    printf "%-30s%-20s\n", "Retransmissions", retransmission_packets;
    printf "%-30s%-20s\n", "Out of Order", out_of_order_packets;

    if (total_packets > 0) {
        loss_rate = (lost_packets / total_packets) * 100;
    } else {
        loss_rate = 0;
    }

    printf "%-30s%-20.2f\n", "Loss Rate (%)", loss_rate;

    printf "\n%-30s%-20s\n", "Overall Risk Level", 
    (loss_rate > 10 ? "High" : (loss_rate > 5 ? "Medium" : "Low"));

    printf "\n\033[1;32m%-30s\033[0m\n", "@FreakXray";
}
'
