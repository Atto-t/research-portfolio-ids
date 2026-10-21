#!/bin/bash
# cronにて5分間隔で実行 (*/5 * * * *)
# SNAT環境のため、自サーバーのIPを取得せずHTTPヘッダーの送信元をDuckDNSに読ませる軽量設計
echo url="https://www.duckdns.org/update?domains=<YOUR_DUCKDNS_DOMAIN>&token=<YOUR_DUCKDNS_TOKEN>&ip=" | curl -k -o /mnt/data/duckdns/duck.log -K -