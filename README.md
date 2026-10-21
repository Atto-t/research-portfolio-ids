# Edge AI SOC & Honeypot Architecture (v6 Plus / MAP-E Environment)

## 1. Project Overview (概要)
本プロジェクトは、日本のコンシューマ向けISPに特有の「IPv4 over IPv6 (MAP-E) / CGNAT」という厳しいネットワーク制約下において、完全にオンプレミスなゼロトラスト・エッジサーバーを構築し、攻撃者のTTPs（戦術・技術・手順）を収集・AI分析する自己完結型のSOC（Security Operations Center）基盤です。

## 2. Architecture (システム構成)
![Architecture Diagram](./docs/architecture.png)
*(※ここに後でDraw.ioで作った図を貼ります)*

* **Hardware:** Ubuntu Server 26.04 LTS / Intel Core i7-7700HQ / 8GB RAM / GTX 1050 Ti (VRAM 4GB)
* **Storage:** 128GB SSD (OS) / 1TB HDD (Data /mnt/data - ext4)
* **Network:** NTT PR-500KI + Buffalo Router (Double DNAT) / WireGuard (Full Tunnel)
* **Data Pipeline:** Nginx(Read-Only Dummy) -> Suricata -> Promtail -> Loki -> Grafana
* **AI Analysis:** JupyterLab (NVIDIA Container Toolkit + GPU Passthrough)

## 3. Key Challenges & Technical Solutions (直面した課題と技術的解決策)
本環境の構築にあたり、以下の技術的制約を独自のアプローチで突破しました。

* **MAP-E (v6 Plus) 環境でのポート制約とDouble NAT貫通**
  NTTルーターの隠し管理画面から利用可能なIPv4ポートブロックを特定。バッファロールーターのDHCP自動取得とIPv6パススルーを固定設定し、Double DNAT構成でVPN(UDP)およびハニーポット(TCP 8080)の通信を確立。
* **WireGuardのMTUブラックホール回避**
  v6プラス環境特有のカプセル化オーバーヘッドによるパケットロスを特定し、MTUを `1360` にチューニングしてフルトンネルを安定化。
* **UEFI Secure Boot下でのGPUパススルー**
  `nvidia-driver-580-server` の実行権限を確保するため、MOK（Machine-Owner Key）を自作・登録。VRAM 4GBの制約に対してはTensorFlowの `set_memory_growth` を適用し枯渇を防止。
* **戦略的撤退によるSOCダッシュボードの最適化**
  SNAT環境下でのGeoIP（位置情報）維持はインフラ改修コストが大きいため、IoC（送信元IP）の追及を避け、攻撃者の意図（TTPs: 標的URLやシグネチャ）の可視化へリソースを集中。LokiのgRPC 4MB制限やGrafanaの描画バグも設定のオーバーライドにより解決。

## 4. How to Use (起動手順)
すべてのデータとコンテナボリュームは、OS領域を避けるため `/mnt/data` 配下に展開されます。
```bash
# 1. Start PLG Stack
cd docker/plg-stack
docker compose up -d

# 2. Start Honeypot & IDS
cd docker/honeypot
docker compose up -d