#!/bin/bash

# Daftar semua Proxmox Host Node dan NetApp
declare -A targets=(
  ["D1-SRV1-5 (10.30.1.101)"]="10.30.1.101"
  ["D1-SRV2-8 (10.30.1.102)"]="10.30.1.102"
  ["D1-SRV3-11 (10.30.1.103)"]="10.30.1.103"
  ["D2-SRV4-12 (10.30.1.104)"]="10.30.1.104"
  ["D2-SRV5-11 (10.30.1.105)"]="10.30.1.105"
  ["D2-SRV6-8 (10.30.1.106)"]="10.30.1.106"
  ["D2-SRV7-5 (Host PBS) (10.30.1.107)"]="10.30.1.107"
  ["PBS (VM) (10.30.1.133)"]="10.30.1.133"
  ["NetApp FAS2820 (10.30.90.110)"]="10.30.90.110"
)

payload_size=8972

echo "=== MTU Validation from PBS (VM: $(hostname)) ==="
echo "Testing ICMP Jumbo Frame (payload: ${payload_size} bytes)"
echo "-------------------------------------------------------------"

for name in "${!targets[@]}"; do
  ip=${targets[$name]}
  echo -n "→ $name: "

  # Jalankan 1 ping jumbo frame
  output=$(ping -c 1 -s $payload_size -M do $ip 2>&1)

  if echo "$output" | grep -q "bytes from"; then
    echo -e "✅ OK (MTU ≥ 9000)"
  elif echo "$output" | grep -q "message too long"; then
    echo -e "❌ FAILED (MTU < 9000)"
  else
    echo -e "⚠️ ERROR (Unknown issue)"
    echo "$output" | sed 's/^/   /'
  fi
done

echo "-------------------------------------------------------------"
