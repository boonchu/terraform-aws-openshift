# https://github.com/openshift/oauth-proxy/issues/66

$ oc rsh -c grafana-proxy grafana-6b9f85786f-jlkgx

$ curl -k https://172.30.0.1/.well-known/oauth-authorization-server
{
  "issuer": "https://18.136.160.211.xip.io:8443",
  "authorization_endpoint": "https://18.136.160.211.xip.io:8443/oauth/authorize",
  "token_endpoint": "https://18.136.160.211.xip.io:8443/oauth/token",
  "scopes_supported": [
    "user:check-access",
    "user:full",
    "user:info",
    "user:list-projects",
    "user:list-scoped-projects"
  ],
  "response_types_supported": [
    "code",
    "token"
  ],
  "grant_types_supported": [
    "authorization_code",
    "implicit"
  ],
  "code_challenge_methods_supported": [
    "plain",
    "S256"
  ]
}

$ curl -fk https://18.136.160.211.xip.io:8443/oauth/authorize

#### Solved: need firewall access.
resource "aws_security_group" "openshift-public-egress" {
     cidr_blocks = ["0.0.0.0/0"]
   }

+  //  API AUTH HTTPS
+  egress {
+    from_port   = 8443
+    to_port     = 8443
+    protocol    = "tcp"
+    cidr_blocks = ["0.0.0.0/0"]
+  }
+
+  //  DNS
+  egress {
+    from_port   = 53
+    to_port     = 53
+    protocol    = "tcp"
+    cidr_blocks = ["0.0.0.0/0"]
+  }
+
