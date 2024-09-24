#!/bin/bash
#File name
capture_file="capture.pcap"
#Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
#Error Handle
error_exit() {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}
#install & check tshark
if ! command -v tshark &> /dev/null; then
    echo "Installing tshark..."
    if ! sudo apt-get install -y tshark &> /dev/null; then
        error_exit "Failed to install tshark."
    fi
fi

clear

read -p "Enter the network interface (e.g., eth0, wlan0): " iface

if ! ip link show "$iface" &> /dev/null; then
    error_exit "Network interface '$iface' does not exist."
fi
#inputs
read -p "Enter capture duration (seconds): " duration
read -p "Enter max packets to capture: " max_packets
#Del
rm -f "$capture_file"
#Start
echo -e "${YELLOW}Starting to capture packets on interface '$iface' for $duration seconds...${NC}"
if ! sudo tshark -i "$iface" -a duration:"$duration" -c "$max_packets" -w "$capture_file" &> /dev/null; then
    error_exit "Failed to capture packets."
fi

echo -e "\n${YELLOW}Analyzing captured packets...${NC}\n"

# TCP Error Analysis
echo -e "${CYAN}TCP Error Analysis:${NC}"

tcp_errors=(
    "tcp.analysis.retransmission:Retransmission"
    "tcp.analysis.fast_retransmission:Fast Retransmission"
    "tcp.analysis.out_of_order:Out-of-Order"
    "tcp.analysis.spurious_retransmission:Spurious Retransmission"
    "tcp.analysis.duplicate_ack:Duplicate ACK"
    "tcp.analysis.zero_window_probe:Zero Window Probe"
    "tcp.analysis.zero_window:Zero Window"
    "tcp.analysis.keep_alive:Keep-Alive"
)

total_errors=0
total_packets=$(tshark -r "$capture_file" 2>/dev/null | wc -l)

for error in "${tcp_errors[@]}"; do
    IFS=":" read -r filter name <<< "$error"
    count=$(tshark -r "$capture_file" -Y "$filter" 2>/dev/null | wc -l)
    total_errors=$((total_errors + count))
    percentage=$(awk "BEGIN {printf \"%.2f\", ($count / $total_packets) * 100}")
    
    if (( $(echo "$percentage < 0.1" | bc -l) )); then
        status="${GREEN}[✓]${NC}"
    elif (( $(echo "$percentage < 1.0" | bc -l) )); then
        status="${YELLOW}[ ! ]${NC}"
    else
        status="${RED}[ X ]${NC}"
    fi
    
    printf "${status} %-25s: %d (%.2f%%)\n" "$name" "$count" "$percentage"
    sleep 0.5
done

# Health Checker
echo -e "\n${CYAN}Network Health Assessment:${NC}"
error_percentage=$(awk "BEGIN {printf \"%.2f\", ($total_errors / $total_packets) * 100}")
if (( $(echo "$error_percentage < 1.0" | bc -l) )); then
    echo -e "${GREEN}[✓] The network appears to be relatively healthy.${NC}"
elif (( $(echo "$error_percentage < 5.0" | bc -l) )); then
    echo -e "${YELLOW}[ ! ] The network has some issues that may need attention.${NC}"
else
    echo -e "${RED}[ X ] The network has significant problems and requires immediate attention.${NC}"
fi

sleep 1

#Tcp Quality 
echo -e "\n${CYAN}TCP Connection Quality:${NC}"
syn_count=$(tshark -r "$capture_file" -Y "tcp.flags.syn==1 and tcp.flags.ack==0" 2>/dev/null | wc -l)
synack_count=$(tshark -r "$capture_file" -Y "tcp.flags.syn==1 and tcp.flags.ack==1" 2>/dev/null | wc -l)
rst_count=$(tshark -r "$capture_file" -Y "tcp.flags.reset==1" 2>/dev/null | wc -l)
total_tcp=$(tshark -r "$capture_file" -Y "tcp" 2>/dev/null | wc -l)

print_tcp_metric() {
    local name=$1
    local count=$2
    local percentage=$(awk "BEGIN {printf \"%.2f\", ($count / $total_tcp) * 100}")
    if (( $(echo "$percentage < 1" | bc -l) )); then
        status="${GREEN}[✓]${NC}"
    elif (( $(echo "$percentage < 5" | bc -l) )); then
        status="${YELLOW}[ ! ]${NC}"
    else
        status="${RED}[ X ]${NC}"
    fi
    printf "${status} %-15s: %d (%.2f%%)\n" "$name" "$count" "$percentage"
}

print_tcp_metric "SYN packets" $syn_count
print_tcp_metric "SYN-ACK packets" $synack_count
print_tcp_metric "RST packets" $rst_count

sleep 1

#Top ip
echo -e "\n${CYAN}Top 5 Talkers:${NC}"
tshark -r "$capture_file" -T fields -e ip.src -e ip.dst 2>/dev/null | 
    sed 's/\t/\n/' | sort | uniq -c | sort -nr | head -n 5 |
    awk '{ printf "%-15s %s packets\n", $2, $1 }'

sleep 1

#Top Protocols 
echo -e "\n${CYAN}Protocol Distribution:${NC}"
protocol_data=$(tshark -r "$capture_file" -T fields -e frame.protocols 2>/dev/null | 
    sed 's/:/\n/g' | sort | uniq -c | sort -nr | head -n 5)

total_packets=$(echo "$protocol_data" | awk '{sum += $1} END {print sum}')

echo "$protocol_data" | while read count protocol; do
    percentage=$(awk "BEGIN {printf \"%.2f\", ($count / $total_packets) * 100}")
    if (( $(echo "$percentage > 50" | bc -l) )); then
        status="${RED}[ ! ]${NC}"
    elif (( $(echo "$percentage > 20" | bc -l) )); then
        status="${YELLOW}[ - ]${NC}"
    else
        status="${GREEN}[✓]${NC}"
    fi
    printf "${status} %-15s %s packets (%.2f%%)\n" "$protocol" "$count" "$percentage"
done

echo -e "\n${GREEN} @FreakXray Analysis complete.${NC}"
