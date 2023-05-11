# Cloudflare Zero Trust Beacon Container

## What for?
Cloudflare, Cloudflare Tunnels (Previously Argo), and the Cloudflare ZeroTrust platform (WARP) provide some pretty awesome tools.

If you're using tunnels, you can create proxy and split tunnel policies for your devices or your users (or family) to be able to securely reach devices or services anywhere in the world.

Since you probably don't want to split tunnel your traffic and create a hairpin out of your home network, and back in to your home network.  You probably don't want to think about turning client settings on and off, or enabling and disabling a VPN profile.

Enter Zero Trust Managed Networks. You can deploy a TLS cert that acts as a Beacon to the WARP client.  The client will look for it on every network change, and if discovered, will verify the TLS SHA-256 fingerprint matches one of a known and configured network in the Cloudflare Zero Trust environments.  This allows you to then set policies and group assignment based on dynamic device location and network membership.  Why not use SSID name, subnet, etc?  SSIDs are easy to spoof, not reliable to the WARP client based on OS, and you may have the same SSID in multiple locations you want to segment.

SO: this container image is just a quick way to run a very light NGINX server to just serve a self-signed cert to the WARP client, so it can securely identify if its in a managed network or not.

To get started, clone this repo:

```git clone https://github.com/geekbleek/cloudflare-beacon```

Change into the new directory:

```cd cloudflare-beacon```

Generate self-signed certs:

```openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout network.local.key -out network.local.pem -subj "/CN=network.local" -addext "subjectAltName=DNS:network.local"```

Get SHA-256:

```openssl x509 -noout -fingerprint -sha256 -inform pem -in network.local.pem | tr -d :```

Run docker build:

```docker build . -t cloudflare-beacon```

By default this container is listening on port 80 & 443.  Port 80 isn't required to be open to the WARP client, and you can expose the container on any port (depends on how you're deploying this image) mapped to 443.

Run the container:

```docker run -d -p 8443:443 cloudflare-beacon```

Now you should be able to curl and validate the server is up.  Add the --insecure flag to ignore the self-signed (untrusted) cert:

```curl https://someLocalIP:8443 --insecure```

[Follow steps here](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/configure-warp/managed-networks) to configure a managed network with the SHA-256 we generated before, and the local LAN IP & port you deployed the container to: 

Make sure the IP isn't a host running other containers you want on your split tunnel.  Zero Trust will exclude the IP from split tunnel configs by default.

Also, make sure its not reachable from other networks, thru a cloudflare tunnel, or external to your network or it will be reached when you don't want it to be.
