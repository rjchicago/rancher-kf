# Rancher KF

Download kubeconfig files from Rancher.

Under the hood, this image uses the `rancher/cli2` image to call `rancher clusters kf`.

For each cluster a user has access to via Rancher, `rancher-kf` will write out a separate kubeconfig file to the volume mounted folder.

## .env

See the `example.env` and create a local `.env` file.

``` sh
URL="https://rancher.example.com/"
TOKEN="token-*****:***********************************************"
CONTEXT="c-m-(...):p-(...)"
```

Note: do not include quotes in the .env file.

### Env Vars

The follow environment variables are supported:

* `URL` is the url to the Rancher UI.
* `TOKEN` is API Token created via Rancher UI.
* `CONTEXT` is optional and must be provided in a Rancher format - example:
  * `local:p-xxxxx, c-xxxxx:p-xxxxx, c-xxxxx:project-xxxxx, c-m-xxxxxxxx:p-xxxxx or c-m-xxxxxxxx:project-xxxxx`

### Rancher API Token

Create token in Rancher UI following steps in the documentation:
> <https://ranchermanager.docs.rancher.com/reference-guides/user-settings/api-keys>

Note: select "no scope"

### Cluster

If cluster is not provided, you will prompted to select a default cluster. Any cluster should suffice.

## Docker Compose

Build and Run via Docker Compose...

``` sh
# build
docker compose build

# run
docker compose run --rm -it rancher-kf
```

## Docker Run

``` sh
# local .kube folder
docker run --rm -v $(pwd)/.kube:/.kube --env-file .env rjchicago/rancher-kf

# user profile .kube folder
docker run --rm -v ~/.kube:/.kube --env-file .env rjchicago/rancher-kf
```