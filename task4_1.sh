#!/bin/bash

script_path=$(dirname "${BASH_SOURCE[0]}")

get_report() {
echo "--- Hardware ---"


echo "CPU: $(sed -n 's/^model name[[:space:]]\+: \(.*\)/\1/p' /proc/cpuinfo | head -n 1)"

ram=$(sed -n 's/^MemTotal:[[:space:]]*\(.*\)/\1/p' /proc/meminfo)
ram=${ram^^}

echo "RAM: $ram"

motherboard_manufacturer=$(dmidecode --string baseboard-manufacturer)
motherboard_product_name=$(dmidecode --string baseboard-product-name)
motherboard=$motherboard_manufacturer
if [[ $motherboard_product_name ]]; then
  if [[ $motherboard ]]; then
    motherboard=$motherboard" "
  fi
  motherboard=$motherboard$motherboard_product_name
fi
echo "Motherboard: ${motherboard:-Unknown}"

system_serial_number=$(dmidecode --string system-serial-number)
echo "System Serial Number: ${system_serial_number:-Unknown}"


echo "--- System ---"


echo "OS Distribution: $(lsb_release --short --description)"
echo "Kernel version: $(uname --release)"

installation_date=$(date --reference=/var/log/installer/media-info)
echo "Installation date: ${installation_date:-Unknown}"

echo "Hostname: $(hostname --fqdn)"

uptime=$(uptime --pretty)
uptime=$(echo "$uptime" | sed -n 's/up \(.*\)/\1/p')
echo "Uptime: $uptime"

echo "Processes running: $(ps -e | wc -l)"
echo "Users logged in: $(users | wc -w)"


echo "--- Network ---"


shopt -s nullglob
for file in /sys/class/net/*; do
  ifname="${file##*/}"
  ip_str="$(ip address show dev "$ifname" | sed -n 's/[[:space:]]*inet \([0-9./]\+\).*/\1/p')"
  ips=""
  for ip in $ip_str; do
    if [[ $ips ]]; then
      ips=$ips", "
    fi
    ips=$ips$ip
  done
  echo "$ifname: ${ips:--}"
done
}

get_report > "$script_path/task4_1.out"
