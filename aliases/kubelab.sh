alias pulumi-export-kubeconfig='x=$(mktemp);(z pulumi; PULUMI_CONFIG_PASSPHRASE=password pulumi stack output kubeconfig --show-secrets) > $x; export KUBECONFIG=$x'
