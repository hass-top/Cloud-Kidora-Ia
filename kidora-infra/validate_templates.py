"""
Render every Jinja2 template in the staging 3-server stack against a mock
context, then re-parse the result.

Catches the two bug classes that only surface at deploy time:
  - Jinja2 syntax errors in the template itself
  - undefined variables, which under Ansible's default settings render as an
    empty string and quietly produce an nginx directive or a Compose key that
    has lost its value

StrictUndefined is used precisely because that silent-empty behaviour is what
we are trying to detect. Ansible is NOT used here: it is not installed on this
machine, and a mock context is enough to catch both classes.

Run:  python validate_templates.py
"""
import os
import sys
import glob
import yaml
import jinja2

HERE = os.path.dirname(os.path.abspath(__file__))
ROLES = os.path.join(HERE, "ansible", "roles")

# Mirrors inventories/staging/group_vars/{all,monitoring,app,edge}.yml.
CTX = {
    "ansible_managed": "Ansible managed",
    "ansible_distribution": "Ubuntu",
    "ansible_distribution_release": "noble",
    "ansible_architecture": "x86_64",
    "ansible_os_family": "Debian",

    "environment": "staging",
    "domain_name": "kidora.freeddns.org",
    "deploy_user": "kidora",
    "deploy_group": "kidora",
    "deploy_root": "/opt/kidora",
    "kidora_role": "edge",

    "kidora_monitoring_ip": "203.0.113.11",
    "kidora_app_ip": "203.0.113.12",
    "kidora_edge_ip": "203.0.113.13",

    "app_images": {
        "backend": "ghcr.io/hass-top/kidora-backend:latest",
        "frontend": "ghcr.io/hass-top/kidora-frontend:latest",
        "ai_backend": "ghcr.io/hass-top/kidora-ia-center:latest",
        "backoffice": "ghcr.io/hass-top/kidora-backoffice:latest",
    },
    "monitoring_images": {
        "prometheus": "prom/prometheus:v2.54.1",
        "grafana": "grafana/grafana:11.2.0",
        "alertmanager": "prom/alertmanager:v0.27.0",
        "node_exporter": "prom/node-exporter:v1.8.2",
        "cadvisor": "gcr.io/cadvisor/cadvisor:v0.50.1",
        "mongo_exporter": "percona/mongodb_exporter:0.40.0",
    },

    "mongodb_database": "kidora",
    "mongodb_username": "kidora_app",
    "mongodb_root_username": "admin",
    "mongodb_port": 27017,
    "minio_root_user": "kidora_admin",
    "minio_bucket": "kidora",
    "minio_port": 9000,
    "minio_console_port": 9001,

    "backend_port": 8086,
    "frontend_port": 80,
    "backoffice_port": 8080,
    "ai_port": 8000,
    "ai_memory_limit": "512m",
    "backend_memory_limit": "768m",

    "node_exporter_port": 9100,
    "cadvisor_port": 9101,
    "mongo_exporter_port": 9216,
    "prometheus_port": 9090,
    "alertmanager_port": 9093,
    "grafana_port": 3000,
    "prometheus_bind_address": "0.0.0.0",
    "grafana_bind_address": "0.0.0.0",

    "app_server_url": "https://kidora.freeddns.org",
    "allowed_origins": "https://kidora.freeddns.org",
    "groq_model_name": "llama-3.3-70b-versatile",
    "groq_vision_model": "llama-3.2-90b-vision-preview",
    "llm_temperature": "0.7",
    "llm_max_tokens": "2048",
    "llm_memory_window": "10",
    "log_level": "INFO",
    "image_provider": "gemini",
    "ai_app_name": "Generateur de Rapports Educatifs IA",
    "app_jwt_expiration_time": "86400000",

    "prometheus_retention": "30d",
    "prometheus_retention_size": "20GB",
    "prometheus_scrape_interval": "30s",
    "prometheus_scrape_timeout": "15s",
    "alertmanager_retention": "120h",
    "alertmanager_webhook_url": "",
    "grafana_root_url": "https://kidora.freeddns.org/grafana/",
    "grafana_datasource_name": "Prometheus",
    "grafana_admin_user": "admin",

    "certbot_email": "admin@kidora.freeddns.org",
    "certbot_domains": ["kidora.freeddns.org", "www.kidora.freeddns.org"],
    "certbot_webroot_path": "/var/www/certbot",
    "certbot_use_staging": True,
    "ssl_certificate_path": "/etc/letsencrypt/live/kidora.freeddns.org/fullchain.pem",
    "ssl_certificate_key_path": "/etc/letsencrypt/live/kidora.freeddns.org/privkey.pem",

    "grafana_vhost": {"enabled": True, "location": "/grafana"},
    "prometheus_vhost": {"enabled": True},
    "backoffice_vhost": {
        "enabled": True,
        "server_name": "backoffice.kidora.freeddns.org",
        "allow_cidr": "100.64.0.0/10",
    },

    "nginx_worker_connections": 2048,
    "nginx_client_max_body_size": "64m",
    "nginx_proxy_read_timeout": "900s",
    "nginx_proxy_send_timeout": "900s",
    "nginx_proxy_connect_timeout": "30s",
    "nginx_real_ip_header": "X-Forwarded-For",

    "tailscale_enabled": True,
    "tailscale_cidr": "100.64.0.0/10",

    "fail2ban_sshd_maxretry": 5,
    "fail2ban_sshd_bantime": "1h",
    "fail2ban_sshd_findtime": "10m",
    "fail2ban_nginx_enabled": True,
    "fail2ban_nginx_bantime": "1h",
    "fail2ban_nginx_maxretry": 10,
    "fail2ban_ignore_ips": ["127.0.0.1/8", "10.0.0.0/8"],
    "fail2ban_docker_enabled": False,

    "swap_file": "/swapfile",
    "swap_size": "2G",

    # Vault-backed. Deliberately full of characters that are significant in a
    # URI and in YAML, so the urlencode/to_json filters are exercised.
    "vault_github_pat": "ghp_test",
    "vault_mongodb_root_password": "p@ss w#rd",
    "vault_mongodb_app_password": "app/p@ss",
    "vault_minio_root_password": "minio-pass",
    "vault_app_secret_key": "secret-key",
    "vault_grafana_admin_password": "grafana-pass",
    "vault_tailscale_auth_key": "tskey-auth-test",
    "vault_groq_api_key": "",
    "vault_bfl_api_key": "",
    "vault_pollinations_api_key": "",
}

# Templates whose rendered output must be valid YAML.
# NB: app.env.j2 is a dotenv file, not YAML — it is checked separately below.
YAML_TEMPLATES = {
    "app_stack/templates/compose.yml.j2",
    "prometheus_stack/templates/compose.yml.j2",
    "prometheus_stack/templates/prometheus.yml.j2",
    "prometheus_stack/templates/alertmanager.yml.j2",
    "prometheus_stack/templates/rules.yml.j2",
    "prometheus_stack/templates/grafana-datasource.yml.j2",
    "docker_engine/templates/docker-config.json.j2",
}
DOTENV_TEMPLATES = {"app_stack/templates/app.env.j2"}

# Variables that are allowed to be blank. See the note in the loop below.
ALLOWED_EMPTY_DOTENV = {
    "GROQ_API_KEY",
    "BFL_API_KEY",
    "POLLINATIONS_API_KEY",
}

# Only the roles introduced by this 3-server stack. The older k3s/Helm roles
# (k3s_master, helm, nginx, ssh_hardening, certbot, zot, users) are a separate
# deployment path with their own variables and are out of scope here.
NEW_ROLES = [
    "app_stack",
    "base_server",
    "certbot_webroot",
    "docker_engine",
    "edge_nginx",
    "fail2ban_hardening",
    "network_firewall",
    "prometheus_stack",
]

# Ansible-only filters are not present in plain Jinja2. Register the ones the
# templates use, so a genuinely missing filter is still an error here rather
# than a surprise inside an Ansible run.
#
#   urlencode  - vault_mongodb_app_password is embedded in a MongoDB URI, so an
#                unencoded '@' or '/' would change how the driver parses the
#                whole connection string.
#   to_json    - the MongoDB init script is JavaScript, so credentials must be
#                emitted as quoted JSON string literals.
#   bool       - Ansible's truthiness coercion (| bool), used on the
#                `*.enabled` feature flags.
env = jinja2.Environment(
    undefined=jinja2.StrictUndefined,
    keep_trailing_newline=True,
)


def _urlencode(value):
    from urllib.parse import quote
    return quote(str(value), safe="")


def _to_json(value):
    import json
    return json.dumps(value)


def _bool(value):
    if isinstance(value, bool):
        return value
    if value is None:
        return False
    if isinstance(value, str):
        return value.strip().lower() in ("true", "yes", "on", "1")
    return bool(value)


env.filters["urlencode"] = _urlencode
env.filters["to_json"] = _to_json
env.filters["bool"] = _bool

failures = []
checked = 0

for role in NEW_ROLES:
    for path in sorted(glob.glob(os.path.join(ROLES, role, "templates", "*.j2"))):
        rel = os.path.relpath(path, ROLES).replace(os.sep, "/")
        with open(path, encoding="utf-8") as fh:
            source = fh.read()
        try:
            rendered = env.from_string(source).render(**CTX)
        except Exception as exc:  # noqa: BLE001
            failures.append(("RENDER", rel, str(exc)))
            print("FAIL render  %s" % rel)
            print("      %s" % exc)
            continue
        checked += 1
        print("OK   render  %s" % rel)

        if rel in YAML_TEMPLATES:
            try:
                yaml.safe_load(rendered)
                print("OK   yaml    %s" % rel)
            except Exception as exc:  # noqa: BLE001
                failures.append(("YAML", rel, str(exc)))
                print("FAIL yaml    %s" % rel)
                print("      %s" % str(exc)[:400])

        if rel in DOTENV_TEMPLATES:
            # Every non-comment line must be KEY=VALUE with a non-empty value.
            # Compose silently substitutes an empty string for a missing var,
            # so an empty one here is a real defect.
            for lineno, line in enumerate(rendered.splitlines(), 1):
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                if "=" not in line:
                    failures.append(("DOTENV", rel, "line %d has no '='" % lineno))
                    print("FAIL dotenv  %s line %d: %s" % (rel, lineno, line))
                    break
                key, _, value = line.partition("=")
                # The AI provider keys are genuinely optional: the service
                # starts without them and only the features that call them
                # fail. Requiring a value would push people to invent a
                # placeholder, which is worse than an honest blank.
                if not value and key not in ALLOWED_EMPTY_DOTENV:
                    failures.append(("DOTENV", rel, "line %d: %s is empty" % (lineno, key)))
                    print("FAIL dotenv  %s line %d: %s is empty" % (rel, lineno, key))
                    break
            else:
                print("OK   dotenv  %s" % rel)

print()
print("templates rendered: %d   failures: %d" % (checked, len(failures)))
if failures:
    for kind, rel, msg in failures:
        print("  [%s] %s: %s" % (kind, rel, msg[:300]))
    sys.exit(1)
print("All templates render cleanly with no undefined variables.")

