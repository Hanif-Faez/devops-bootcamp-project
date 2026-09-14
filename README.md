# DevOps Bootcamp Project

A small 3-node AWS setup where a private controller node does all the configuration with Ansible.

```
web-server        10.0.0.5    public + EIP   Immich (Docker + Nginx)
controller-node   10.0.0.135  private        Ansible (runs everything)
monitoring-node   10.0.0.136  private        Prometheus + Grafana + cloudflared
```

The private nodes have no public IP — access is via SSM only.

## Infrastructure provisioning

`terraform/` builds the VPC (public/private /25 + IGW + NAT), the three instances (t3.medium for web, t3.small for the rest), the security groups, and the IAM policies on the existing `AWS-SSM` instance profile. Terraform state stored inside S3 bucket.

Security groups: 80 public, 22 only from the controller, 9100 only from the monitoring node. No SSH from the internet.

The controller bootstraps itself from `controller.sh.tftpl` — waits for outbound internet since NAT initialization takes time then verify if it able have access to the internet before installing Ansible and AWS CLI v2, pulls the SSH key from SSM, clones the repo, installs the Galaxy requirements.

Requirement: `FedoraLab` key pair, S3 state bucket, and SSM params `/devops-project/ssh-PK`, `/devops-project/CF-tunnel`, `/devops-project/grafana-cred`.

```bash
cd terraform && terraform init && terraform apply
```

## Configuration management

Playbooks run on the controller. Terraform renders the inventory, so IPs aren't hardcoded. Order:

1. `playbook-dockApp.yaml` — Docker on web
2. `playbook-immich.yaml` — Immich + Postgres + Redis + Nginx on web
3. `playbook-exporter.yaml` — node_exporter on web
4. `playbook-monitor-stack.yaml` — Prometheus + Grafana + cloudflared on monitoring

The Immich image is built from `app/Dockerfile` and pushed once with `scripts/build-push-immich.sh`. Secrets are read from SSM and written to `.env` files (0600) — nothing sensitive being kept.

## Monitoring and observability

Prometheus scrapes itself and the web node's node_exporter (9100 is allowed only from the monitoring node). Grafana's Prometheus datasource is provisioned automatically.
## Domain and secure access

- **Grafana** — `https://monitoring.hanif-faez.com` through a Cloudflare tunnel. cloudflared runs as a container and dials out; the hostname maps to `http://grafana:3000`. No inbound ports.
- **Immich** — `https://immichapp.hanif-faez.com` run Nginx on web node via port 80.
- **Admin access** — SSM sessions only (run as `ubuntu`), no public SSH. The controller SSH to other nodes via private IPs.

## Documentation

```
terraform/   infra: VPC, EC2, SGs, IAM, inventory
ansible/     playbooks + configs/templates
app/         Immich Dockerfile
scripts/     build-push-immich.sh
setup-ssm-preferences.sh <- Before deploying, run this to change ssm_user to ubuntu and vice versa
```

```bash
cd terraform && terraform init && terraform apply
bash scripts/build-push-immich.sh

# controller via SSM as ubuntu
cd /opt/devops-bootcamp/ansible
ansible-playbook playbook-dockApp.yaml
ansible-playbook playbook-immich.yaml
ansible-playbook playbook-exporter.yaml
ansible-playbook playbook-monitor-stack.yaml
```

```bash
# Grafana credential still using default username but password is stored inside Parameter Store
aws ssm get-parameter --name /devops-project/grafana-cred \
  --with-decryption --region ap-southeast-1 --query Parameter.Value --output text
```
