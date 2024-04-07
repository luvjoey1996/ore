#!/bin/bash

# 设置变量，表示最大重试次数
MAX_RETRIES=1000
# 设置变量，表示重试间隔（单位：秒）
RETRY_INTERVAL=5

# 设置 priority fee
PRIORITY_FEE=10000

# 设置线程数
THREADS=4
echo $PRIV > /root/.config/solana/id.json
# 钱包 keypair 文件
KEYPAIR_FILE=/root/.config/solana/id.json

# RPC 地址
RPC_URL=https://api.mainnet-beta.solana.com

# 使用 getopts 解析命令行参数
while getopts ":f:r:" opt; do
  case $opt in
    f) KEYPAIR_FILE="$OPTARG";;  # 钱包 keypair 文件
    r) RPC_URL="$OPTARG";;  # solana RPC 地址
    \?) echo "Invalid option: -$OPTARG" >&2;;
  esac
done
shift $((OPTIND -1))

# 设置变量，表示当前重试次数
retry_count=0

echo "keypair file: $KEYPAIR_FILE\nRPC URL: $RPC_URL"
sleep 2

# 无限循环，直到命令成功执行或者达到最大重试次数
while true; do
    # 执行命令
    ore --rpc $RPC_URL --keypair <(echo $PRIV) --priority-fee $PRIORITY_FEE mine --threads $THREADS

    # 检查命令的退出状态
    if [ $? -eq 0 ]; then
        # 如果命令成功执行，退出循环
        break
    else
        # 如果命令执行异常，增加重试次数
        ((retry_count++))

        # 检查是否达到最大重试次数
        if [ $retry_count -eq $MAX_RETRIES ]; then
            echo "Reached maximum retry attempts. Exiting."
            exit 1
        fi

        # 如果未达到最大重试次数，等待一段时间后再次执行命令
        echo "Command failed. Retrying in $RETRY_INTERVAL seconds..."
        sleep $RETRY_INTERVAL
    fi
done