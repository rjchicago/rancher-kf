# Quickstart

Under the hood, `rancher-kf` uses the `rancher/cli2` image to call `rancher clusters kf`.

## Rancher API Token

Create an API token in the Rancher UI following steps in the documentation:
> <https://ranchermanager.docs.rancher.com/reference-guides/user-settings/api-keys>

Note: select "no scope", optionally set expiration or select `custom: 0` for no expiration.

## rancher-kf.env

Create a `rancher-kf.env` file in your local `.kube` directory..

``` sh
URL=https://rancher.example.com/
TOKEN=token-*****:***********************************************

echo "
URL=$URL
TOKEN=$TOKEN
" > ~/.kube/rancher-kf.env
```

## Aliases

Configure aliases in your bash profile..

``` sh
# refresh kubeconfig files from rancher
alias rancher-kf="docker run --rm -it -v ~/.kube:/.kube --env-file ~/.kube/rancher-kf.env rjchicago/rancher-kf"

# include all kubeconfig files in KUBECONFIG
export KUBECONFIG=~/.kube/config$(for YAML in $(find ${HOME}/.kube -name '*.y*ml') ; do echo -n ":${YAML}"; done)
```

## Run rancher-kf

``` sh
# via alias..
rancher-kf

# you will be prompted to "Select a Project" - enter any id and hit enter.
# ..
```
