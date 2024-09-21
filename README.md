<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Network Packet Capture & Analysis Script</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 20px;
            padding: 20px;
            background-color: #f4f4f4;
        }
        h1, h2, h3 {
            color: #333;
        }
        code {
            background-color: #eaeaea;
            padding: 2px 4px;
            border-radius: 4px;
        }
        pre {
            background-color: #eaeaea;
            padding: 10px;
            border-radius: 4px;
            overflow-x: auto;
        }
    </style>
</head>
<body>

<h1>Network Packet Capture & Analysis Script</h1>

<h2>Overview</h2>
<p>This Bash script leverages the power of <code>tshark</code> for real-time network packet capture and analysis. Designed for network engineers and security professionals, it streamlines monitoring network traffic, detecting anomalies, and troubleshooting issues.</p>

<h2>Key Features</h2>
<ul>
    <li><strong>Real-time Packet Capture</strong>: Capture packets on specified network interfaces for a user-defined duration.</li>
    <li><strong>Detailed Analysis</strong>: Evaluate captured packets for retransmissions, resets, and other critical metrics.</li>
    <li><strong>User-Friendly Interface</strong>: Interactive prompts make it easy to navigate, suitable for users of all skill levels.</li>
    <li><strong>Efficient Reporting</strong>: Generates a concise summary of the captured data, highlighting key performance indicators.</li>
</ul>

<h2>Execute the Script</h2>
<p>You can run the script directly from the command line using <code>wget</code> and <code>bash</code>, without saving it locally:</p>
<pre><code>wget -O - https://your-repo-link.com/path/to/script.sh | bash</code></pre>
<p><em>Replace <code>https://your-repo-link.com/path/to/script.sh</code> with the actual URL of your script.</em></p>

<h2>How It Works</h2>
<ol>
    <li><strong>Start the Script</strong>: The command fetches the script and pipes it directly into <code>bash</code> for execution.</li>
    <li><strong>User Inputs</strong>: You will be prompted to enter:
        <ul>
            <li>The network interface (e.g., <code>eth0</code>, <code>wlan0</code>).</li>
            <li>The capture duration in seconds.</li>
            <li>The maximum number of packets to capture.</li>
        </ul>
    </li>
</ol>

<h2>Logic & Calculations</h2>
<ul>
    <li><strong>Packet Capture</strong>: Uses <code>tshark</code> to capture packets from the specified network interface based on user-defined parameters.</li>
    <li><strong>Data Analysis</strong>: After capturing, the script processes the data:
        <ul>
            <li><strong>Total Packets</strong>: Counts all captured packets.</li>
            <li><strong>Retransmissions & Resets</strong>: Identifies and quantifies any retransmissions and TCP reset packets.</li>
            <li><strong>Loss Rate Calculation</strong>: Placeholder values are set for lost packets and out-of-order calculations, laying the groundwork for advanced reporting.</li>
        </ul>
    </li>
</ul>

<h2>Conclusion</h2>
<p>With its intuitive interface and robust functionality, this packet capture script is an essential tool for diving deeper into network diagnostics and performance tuning. Whether you're troubleshooting connectivity issues, analyzing traffic patterns, or enhancing network security, this script is your go-to solution.</p>
<p>Harness the power of <code>tshark</code> and elevate your network management strategy today!</p>

</body>
</html>
