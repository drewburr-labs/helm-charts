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

Due to the limitations of Crafty Controller's file manager, an SFTP server is provided to help ease management. This container is configued to be fully compatible with Crafty Controller's permissions requirements, and will not break Crafty on its own.

> Note: The Crafty Controller maintainers will state that Crafty can not support FTP. This is not true, the maintainers are choosing not to support FTP. This chart fully supports FTP, and is compatible with Crafty Controller. If you believe Crafty Controller is unhappy due to files updated using the FTP server, please open an Issue and describe the problem experienced.

```yaml
sftp:
  enabled: true
  service:
    type: LoadBalancer
```
