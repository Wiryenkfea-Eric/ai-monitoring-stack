# 🔒 AI-Augmented Cloud Monitoring Stack

<div align="center">

![Stack](https://img.shields.io/badge/AWS-EC2%20%7C%20VPC-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-Metrics-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-Dashboards-F46800?style=for-the-badge&logo=grafana&logoColor=white)
![Splunk](https://img.shields.io/badge/Splunk-SIEM%20%7C%20MLTK-000000?style=for-the-badge&logo=splunk&logoColor=white)
![Python](https://img.shields.io/badge/Python-Flask-3776AB?style=for-the-badge&logo=python&logoColor=white)

**Automated AI-powered monitoring infrastructure deployed entirely as code on AWS**

*Prometheus · Grafana · Splunk MLTK · Terraform · Slack Alerting*

</div>

---

## 📊 Key Results

| Metric | Before | After |
|--------|--------|-------|
| Mean Time to Detection (MTTD) | 25 minutes (manual log review) | **5 minutes (automated)** |
| CPU Spike Detection | Manual CloudWatch check | **Slack alert in real time** |
| Error Rate Monitoring | Manual log grep | **Grafana panel + auto-alert** |
| Anomaly Detection | None | **Splunk MLTK ML model** |
| Infrastructure Provisioning | Manual console clicks | **Terraform — 3 servers in 3 minutes** |
| Log Ingestion | None | **Splunk — flask + audit logs** |

---

## 🏗️ Architecture

![Architecture Diagram](docs/architecture.svg)

### Infrastructure Overview

| Server | Type | Role | Private IP |
|--------|------|------|------------|
| Monitoring Server | t3.small | Prometheus + Grafana + Node Exporter | 10.0.1.106 |
| Splunk Server | t3.medium | Splunk Enterprise + MLTK | 10.0.1.61 |
| App Server | t3.micro | Flask App + Node Exporter + Splunk Forwarder | 10.0.1.181 |

All servers deployed inside a custom VPC with:
- Public subnet in us-east-1a
- Internet Gateway for external access
- Least-privilege security groups per server role
- SSH restricted to engineer IP only (`/32`)

---

## 🛠️ Tech Stack

| Category | Tool | Purpose |
|----------|------|---------|
| Cloud | AWS EC2, VPC, Security Groups | Infrastructure hosting |
| IaC | Terraform | Provision all infrastructure as code |
| Metrics | Prometheus v2.48 | Scrape and store time-series metrics |
| OS Metrics | Node Exporter v1.7 | CPU, memory, disk, network per host |
| Visualisation | Grafana v12 | Dashboards, alerting rules |
| Alerting | Grafana → Slack Webhook | Real-time incident notifications |
| Log Analysis | Splunk Enterprise Free | Log ingestion, search, dashboards |
| AI/ML | Splunk MLTK | Anomaly detection on log patterns |
| Log Shipping | Splunk Universal Forwarder | Forward logs from app server to Splunk |
| Application | Python Flask | Sample app generating real metrics/logs |

---

## 📸 Screenshots

### Grafana Dashboard — Live Application Metrics
> CPU usage gauge, P95 latency, error rate, and request rate — all pulling from Prometheus in real time

![Grafana Dashboard](docs/screenshots/grafana-dashboard.png)

---

### Slack Alert — CPU Spike Detected and Auto-Resolved
> Grafana detected CPU spike to 50.3%, fired alert to Slack at 5:12 AM, auto-resolved at 5:17 AM

![Slack Alert](docs/screenshots/slack-alert.png)

---

### Prometheus Targets — All Scrapers UP
> Prometheus successfully scraping all 4 targets: itself, monitoring node, app node, Flask app

![Prometheus Targets](docs/screenshots/prometheus-targets.png)

---

### Splunk — Flask Application Logs Ingested
> Splunk receiving real-time logs from the Flask app via Universal Forwarder over private VPC IP

![Splunk Logs](docs/screenshots/splunk-logs.png)

---

## 🚀 Deploy It Yourself

### Prerequisites

- AWS account with CLI configured (`aws configure`)
- Terraform >= 1.0 installed
- SSH key pair created in AWS EC2
- Git installed

### Step 1 — Clone the Repo

```bash
git clone https://github.com/YOUR_USERNAME/ai-monitoring-stack
cd ai-monitoring-stack
```

### Step 2 — Configure Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
your_ip       = "YOUR_PUBLIC_IP/32"   # get with: curl ifconfig.me
key_pair_name = "your-key-pair-name"
```

### Step 3 — Deploy Infrastructure

```bash
terraform init
terraform plan    # review what will be created
terraform apply   # type 'yes' to confirm
```

Terraform creates:
- 1 VPC with public subnet and internet gateway
- 3 security groups (monitoring, splunk, app)
- 3 EC2 instances

### Step 4 — Note Your Output IPs

```
monitoring_public_ip = "x.x.x.x"
splunk_public_ip     = "x.x.x.x"
app_public_ip        = "x.x.x.x"
app_private_ip       = "10.0.1.x"
```

### Step 5 — Set Up App Server

```bash
ssh -i your-key.pem ec2-user@APP_PUBLIC_IP
sudo dnf install python3-pip nano wget -y
pip3 install flask prometheus_client
nano app.py   # paste app.py content
sudo systemctl start flask-app
sudo systemctl start node_exporter
```

### Step 6 — Set Up Monitoring Server

```bash
ssh -i your-key.pem ec2-user@MONITORING_PUBLIC_IP
# Install Prometheus, Node Exporter, Grafana
# Configure prometheus.yml with app private IP
# Connect Grafana to Prometheus data source
```

### Step 7 — Access Your Stack

| Service | URL |
|---------|-----|
| Prometheus | `http://MONITORING_IP:9090` |
| Grafana | `http://MONITORING_IP:3000` |
| Splunk | `http://SPLUNK_IP:8000` |
| Flask App | `http://APP_IP:5000` |

---

## 🔐 Security Design Decisions

### Network Security
- **SSH restricted to `/32`** — only the engineer's exact IP can SSH. No `0.0.0.0/0` SSH rules anywhere.
- **Least-privilege security groups** — each server has its own SG allowing only the ports it needs
- **Internal VPC traffic only** — Prometheus scrapes app server via private IP `10.0.1.x`, not public IP. Splunk forwarder sends logs via private IP. No unnecessary internet exposure.
- **Node Exporter port 9100** — only accessible from within the VPC CIDR `10.0.0.0/16`, not from the internet

### Credentials
- No hardcoded credentials anywhere in the codebase
- `terraform.tfvars` excluded from git via `.gitignore`
- `.pem` key files excluded from git
- AWS credentials managed via `aws configure`, not embedded in code

### Why This Matters
This demonstrates zero-trust thinking applied to monitoring infrastructure — the same principles I apply to production client environments.

---

## 🤖 AI/ML Anomaly Detection

The Splunk Machine Learning Toolkit (MLTK) adds genuine AI capability to this stack:

**How it works:**
1. Splunk Universal Forwarder ships Flask app logs to Splunk over port 9997 (private IP)
2. MLTK trains a `DensityFunction` model on request volume patterns
3. The model establishes a baseline of "normal" traffic
4. Any request pattern outside the 95th percentile is flagged as an anomaly
5. Anomaly alerts surface in the Splunk Security Dashboard

**What it catches:**
- Unusual spikes in error rates
- Traffic volume anomalies (potential DDoS or app failure)
- Off-hours activity patterns
- System audit events (BPF program loads/unloads)

This is the same approach used in production AIOps environments — applying ML to reduce alert fatigue and catch subtle signals that threshold-based alerting misses.

---

## 🔥 Incident Simulations

### CPU Stress Test
```bash
sudo dnf install stress -y
stress --cpu 2 --timeout 120
```
**Result:** Prometheus detected spike, Grafana fired Slack alert within 3 minutes

### High Error Rate
```bash
for i in {1..50}; do curl -s http://localhost:5000/api/data > /dev/null; done
```
**Result:** Flask app's 10% random error rate triggered Grafana Error Rate alert

### Instance Down
```bash
sudo systemctl stop flask-app
# Prometheus fires InstanceDown alert within 1 minute
sudo systemctl start flask-app
```
**Result:** Alert fired in Prometheus, auto-resolved on recovery

### Failed Auth Events
```bash
ssh wronguser@APP_PUBLIC_IP  # intentional failure
```
**Result:** Linux audit log captured event, Splunk ingested and displayed in security dashboard

---

## 💰 Cost Analysis

| Resource | Type | Running Cost | Stopped Cost |
|----------|------|-------------|--------------|
| Monitoring Server | t3.small | ~$15/month | ~$0 |
| Splunk Server | t3.medium | ~$30/month | ~$0 |
| App Server | t3.micro | ~$8/month | ~$0 |
| EBS Storage (90GB total) | gp3 | ~$7/month | ~$7/month |
| Data transfer | Minimal | ~$1/month | ~$0 |
| **Total running** | | **~$61/month** | |
| **Total stopped** | | | **~$7/month** |

**Cost optimisation strategy:** Stop instances when not actively using the stack. All data and configuration persists on EBS volumes. Restart takes under 2 minutes.

```bash
# Stop all instances via AWS CLI
aws ec2 stop-instances --instance-ids i-xxx i-yyy i-zzz

# Start them again
aws ec2 start-instances --instance-ids i-xxx i-yyy i-zzz
```

---

## 📁 Project Structure

```
ai-monitoring-stack/
├── terraform/
│   ├── main.tf                 # VPC, subnet, internet gateway, route table
│   ├── ec2.tf                  # 3 EC2 instances with AMI lookup
│   ├── security_groups.tf      # Least-privilege SGs per server role
│   ├── variables.tf            # Input variables with defaults
│   ├── outputs.tf              # Public/private IPs output
│   └── terraform.tfvars        # Your IP and key pair (gitignored)
├── app/
│   └── app.py                  # Flask app with Prometheus metrics
├── prometheus/
│   ├── prometheus.yml          # Scrape config for all targets
│   └── alert_rules.yml         # CPU, memory, down, latency, error alerts
├── grafana/
│   └── dashboards/             # Dashboard JSON exports
├── docs/
│   ├── architecture.svg        # Architecture diagram
│   └── screenshots/            # Project screenshots
└── README.md
```

---

## 🔮 Future Improvements

- [ ] **HashiCorp Vault** — centralized secrets management, dynamic credentials for PostgreSQL
- [ ] **EKS Cluster Monitoring** — kube-state-metrics, pod-level observability
- [ ] **PagerDuty Integration** — on-call alerting with escalation policies
- [ ] **Terraform Remote State** — S3 backend with DynamoDB locking
- [ ] **AWS GuardDuty** — threat detection integrated with Splunk SIEM
- [ ] **Multi-region DR** — Route 53 failover, RDS Multi-AZ, S3 cross-region replication
- [ ] **Ansible Playbooks** — automate all server configuration (replace manual setup)
- [ ] **GitHub Actions CI/CD** — auto-validate Terraform on PR, run `terraform plan`

---

## 👤 Author

**Eric Nyuydze Wiryenkfea**
Cloud & DevOps Engineer | AWS | Azure | DevSecOps | IaC

- 🌍 [LinkedIn](https://www.linkedin.com/in/eric-nyuydze-wiryenkfea-198862162)
- 💻 [GitHub](https://github.com/YOUR_USERNAME)
- 🎤 Speaker: HashiTalks Africa · ALX Africa · Bincom Dev Center

---

## 📄 License

MIT License — free to use, modify, and distribute with attribution.

---

<div align="center">

⭐ **Star this repo if it helped you** ⭐

*Built to demonstrate senior-level cloud security and monitoring skills*

</div>
