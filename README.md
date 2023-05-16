# k Github Action

Installs and configures [k](https://github.com/reclaim-the-stack/k) inside GitHub actions.

# Configuration

## Required

`gitops-repository-url` - The URL for your GitOps repository. Include a [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) in the userinfo part of the URL if it's a private repository. Eg. `https://<personal-access-token>@github.com/<organization>/<repository>`.

`kube-config` - A Base64 encoded string containing a full `kubectl` configuration YAML payload with access to the Kubernetes repository you want `k` to interact with. Eg. `cat ~/.kube/config | base64 `.

## Optional

`kube-config` - The name of the `kubectl` context to use. Defaults to the current context as set in `kube-config`.

`registry` - The host of the Docker registry. Eg. `docker.io`, `ghcr.io` etc. Note: If you're running commands relying on `docker`, you might want to use another Github action to login to your registry.

`registry-namespace` - The namespace (aka. user / organisation) on the Docker registry. Ie. the path that goes in between the registry host and the repository name of your Docker images.

# Example usage

Example of running `k deploy` to deploy the current git-sha of the checked out repository to `<application-name>`.

Assumes you have a `GITOPS_REPOSITORY_URL` secret containing your GitOps repo URL (including a personal access token if private) and a `KUBE_CONFIG` secret containing a Base64 encoded dump of a `kubectl` config file with access to your Kubernetes cluster.

```
on: push

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: reclaim-the-stack/k-action@master
        with:
          gitops-repository-url: ${{ secrets.GITOPS_REPOSITORY_URL }}
          kube-config: ${{ secrets.KUBE_CONFIG }}
      - uses: actions/checkout@v3
      - run: k deploy <application-name> --disable-image-verification
```
