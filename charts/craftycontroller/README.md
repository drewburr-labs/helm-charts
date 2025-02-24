# craftycontroller

A Helm chart for [Crafty Controller](https://craftycontrol.com/), a web-based GUI for Minecraft Server administration.

Source code can be found here:

- [https://gitlab.com/crafty-controller/crafty-4](https://gitlab.com/crafty-controller/crafty-4)

This is a 3rd party maintained chart, and supports several features not supported by the Crafty Controller team.

The default installation is intended to be similar to the official [Docker Installation Guide](https://docs.craftycontrol.com/pages/getting-started/installation/docker/)

## Limitations

This chart is designed to make it simple to run many instances of Crafty.Doing so permits resource isolation and allows simple service and port customizations for mods and plugins that require it. Therefore, it is encouraged to deploy an instance of Crafty for each Minecraft server being run.

As this is a 3rd party chart, the default image tag is set `latest`. This is intended to simplify maintainence, but may not be desired for your use-case.

Minecraft servers managed by Crafty must also have their ports defined in this chart. This is also true for mods and plugins that require exposed ports, such as those that provide proximity chat and web-based mapping.

## Basic usage

### Expose Crafty and Minecraft server on default ports

By default, no services are exposed outside the cluster. An Ingress or LoadBalancer service may be required to access Minecraft and/or the Crafty GUI.

```yaml
services:
  https:
    ingress:
      hosts:
        - crafty.example.com
      tls:
        - secretName: crafty-tls
          hosts:
            - crafty.example.com

  minecraft:
    type: LoadBalancer
```

### Setup persistence

By default, only required PVC are created (app config and servers). Here are all the volume mounts Crafty supports.

```yaml
persistence:
  crafty-app-config: # Defaults shown
    enabled: true
    requests: 1Gi
  crafty-servers: # Defaults shown
    enabled: true
    requests: 10Gi
  crafty-backups:
    enabled: true
    requests: 20Gi
  crafty-logs:
    enabled: true
    requests: 1Gi
  crafty-import:
    enabled: true
    requests: 5Gi
```

### Enabling the SFTP server

The SFTP server is provided by [atmoz/sftp](https://github.com/atmoz/sftp)

Due to the limitations of Crafty Controller's file manager, an SFTP server is provided to help ease management. This container is configued to be fully compatible with Crafty Controller's permissions requirements, and will not break Crafty on its own.

> Note: The Crafty Controller maintainers will state that Crafty can not support FTP. This is not true, the maintainers are choosing not to support FTP. This chart fully supports FTP, and is compatible with Crafty Controller. If you believe Crafty Controller is unhappy due to files updated using the FTP server, please open an Issue and describe the problem experienced.

```yaml
sftp:
  enabled: true
  service:
    type: LoadBalancer
```

By default, two secrets are required by the FTP server to provide user credentials and SSH keys.

The `sftp-users` secret's `users` key is used to define accounts for the FTP server. This value *must* be in the following format. It is critical that the UID and GID do not change:

```text
username:password:1000:0:
```

```sh
kubectl create secret generic sftp-users --from-literal=users='username:password:1000:0:'
```

In addition, the `sftp-host-keys` secret stores the server SSH keys. The following cammands can be used to generate these keys and create the secret.

```sh
ssh-keygen -t ed25519 -f ssh_host_ed25519_key < /dev/null
ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key < /dev/null
kubectl create secret generic sftp-host-keys --from-file=ssh_host_ed25519_key,ssh_host_ed25519_key.pub,ssh_host_rsa_key,ssh_host_rsa_key.pub
```
