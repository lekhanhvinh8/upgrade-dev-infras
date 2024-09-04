auto_auth {
  method "approle" {
    config = {
      role_id_file_path   = "/vault/creds/role_id"
      secret_id_file_path = "/vault/creds/secret_id"
    }
  }
}

template {
  source      = "/vault/config/secret-template.tpl"
  destination = "/vault/output/secret.json"
}

vault {
  address = "http://vault:8200"
}

template_config {
  static_secret_render_interval = "1s"
  exit_on_retry_failure         = true
  max_connections_per_host      = 10
}