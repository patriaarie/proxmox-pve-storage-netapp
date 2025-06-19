#!/bin/bash

# Skrip pengecekan MTU (Jumbo Frame) antar node dan ke PBS & NetApp

MTU_SIZE=8972
IP_LIST=(
  "10.30.1.101 D1-SRV1-5"
  "10.30.1.102 D1-SRV2-8"
  "10.30.1.103 D1-SRV3-11"
  "10.30.1.104 D2-SRV4-12"
  "10.30.1.105 D2-SRV5-11"
  "10.30.1.106 D2-SRV6-8"
  "10.30.1.107 D2-SRV7-5 (Host PBS)"
  "10.30.1.133 PBS (VM)"
  "10.30.90.110 NetApp"
)

echo "=== Validasi MTU 9000 Byte ==="
echo "Testing dengan paket ICMP size $(($MTU_SIZE + 8)) bytes"
echo "--------------------------------------------------------"

for entry in "${IP_LIST[@]}"; do
  ip=$(echo "$entry" | awk '{print $1}')
  label=$(echo "$entry" | cut -d' ' -f2-)
  echo -n "→ $label ($ip): "

  ping -c 1 -s $MTU_SIZE -M do $ip > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo -e "\e[32mOK (MTU ≥ 9000)\e[0m"
  else
    echo -e "\e[31mFAILED (MTU < 9000)\e[0m"
  fi
done

echo "--------------------------------------------------------"
echo "Catatan: MTU yang tidak sama akan menyebabkan fragmentasi atau timeout saat backup"
