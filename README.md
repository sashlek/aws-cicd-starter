![AWS-CICD-Starter Dashboard](./assets/screenshot.png)

🚀 AWS-CICD-Starter: Hybrid Homelab to Cloud Pipeline


A production-grade, fully automated CI/CD pipeline and Infrastructure as Code (IaC) solution. This project demonstrates how to orchestrate a hybrid on-premise homelab (Proxmox + Hyper-V) to seamlessly provision, configure, and deploy immutable infrastructure directly to AWS Cloud.


🏗️ Architecture & Infrastructure Topology



Jenkins Master Node: Hosted inside a dedicated Docker container running on a Windows 10 IoT Hyper-V Virtual Machine (192.168.1.32).

Jenkins Inbound (JNLP) Agent: Isolated inside a dedicated Proxmox LXC Container (192.168.1.201) communicating securely via WebSockets.

Trigger Mechanism: Instant GitHub Webhooks tunneled securely via Cloudflare Tunnels, bypassing local CGNAT/firewalls for real-time build execution on every git push.

Provisioning Layer: Terraform v1.16 dynamically provisions AWS EC2 instances (t3.micro), security groups, subnets, and dynamic SSH key pairs.

Configuration Management: Ansible Playbooks automatically harden the remote Linux kernel (fixing MTU/MSS clamping for robust browser delivery), install Docker, and deploy a custom portfolio web container.



🛠️ Tech Stack & Tooling



Orchestration: Jenkins (Master-Agent architecture with WebSocket JNLP)

Provisioning (IaC): Terraform, AWS Provider

Configuration Management: Ansible, Jinja2 dynamic inventory generation

Containerization: Docker, Nginx Alpine

Networking & Security: Cloudflare Tunnels (Secure Webhook ingress), OpenSSH key-based authentication, Linux sysctl kernel tuning

Homelab Infrastructure: Proxmox VE, Hyper-V, LXC, Docker



⚙️ Pipeline Lifecycle (Jenkinsfile)



The pipeline is fully declarative and parameterized, allowing engineers to choose the infrastructure state directly from the Jenkins UI:


Checkout SCM: Clones the repository dynamically based on the latest commit.

Terraform Action (apply or destroy):  Initializes the backend and safely injects ephemeral agent public SSH keys.  Dynamically evaluates AWS VPC subnets and spins up the EC2 instance.

Dynamic Inventory Generation: Extracts the newly created EC2 public IP via Terraform outputs and injects it on-the-fly into an Ansible temporary inventory file.

Ansible Provisioning:  Applies kernel-level network fixes (tcp_mtu_probing and tcp_base_mss) to eliminate packet drop anomalies.  Installs and configures Docker engine. * Deploys the custom portfolio application inside an Nginx Alpine container mapped to port 80.



🎯 Key Engineering Challenges Solved



Hybrid Homelab Networking: Solved local-to-cloud webhook delivery without opening vulnerable home router ports by implementing secure Cloudflare quick tunnels.

Agent-Master Resilience: Migrated legacy fragile SSH-based Jenkins slave launching to robust, container-friendly Inbound WebSocket JNLP backed by a persistent systemd service daemon.

AWS MTU Black Hole Mitigation: Resolved silent browser HTTP hanging issues by embedding automatic TCP MSS clamping (net.ipv4.tcp_base_mss = 1024) directly into the automated Ansible configuration phase.