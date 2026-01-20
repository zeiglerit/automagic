resource "google_service_account" "vault_sa" {
  account_id   = "vault-server"
  display_name = "Vault Server Service Account"
}

resource "google_compute_instance" "vault" {
  name         = "vault-server"
  machine_type = "e2-standard-2"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }

  network_interface {
    network = "default"

    access_config {} # enables external IP
  }

  service_account {
    email  = google_service_account.vault_sa.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y unzip curl jq

    curl -fsSL https://releases.hashicorp.com/vault/1.15.0/vault_1.15.0_linux_amd64.zip -o vault.zip
    unzip vault.zip
    mv vault /usr/local/bin/
    setcap cap_ipc_lock=+ep /usr/local/bin/vault

    mkdir -p /etc/vault
    cat <<CONFIG >/etc/vault/config.hcl
    storage "file" {
      path = "/opt/vault/data"
    }

    listener "tcp" {
      address     = "0.0.0.0:8200"
      tls_disable = 1
    }

    ui = true
    CONFIG

    mkdir -p /opt/vault/data
    vault server -config=/etc/vault/config.hcl > /var/log/vault.log 2>&1 &
  EOF
}

resource "google_compute_firewall" "vault_fw" {
  name    = "vault-allow-8200"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8200"]
  }

  source_ranges = ["YOUR_IP/32"] # replace with your IP
}
