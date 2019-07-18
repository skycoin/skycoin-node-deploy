# Skycoin One-Click Application

Scripts to build skycoin Once-Click DigitalOcean image that obey the rules for Marketplace.

## Install tools

[Fabric](https://www.fabfile.org/installing.html) and [Packer](https://www.packer.io/intro/getting-started/install.html) are required to run the commands below.

## Build image

To create a image, you'll need to [create a DigitalOcean personal access token](https://www.digitalocean.com/docs/api/create-personal-access-token/) and set it to env variable `DIGITALOCEAN_TOKEN`.

Run the following command to build a image, clean template files, create snapshot, and verify if it match the rules of Marketplace.

```sh
make do-build-image-snapshot
```

Once the image is created, you can test it by creating a droplet from the new created snapshot.

The new droplet will take a few minutes to be ready. After the server is up, the `skycoin` service will start automatically, you can test it by running:

```sh
curl http://$server_ip:6420/api/v1/health
```

## Debug and Test

...
