# k8s-demo

# initial thoughts - 12 PM
This doesn't look hard. Seems like they want me to show I know:
* how state in GCP can be managed with a Terraform modules written for each resource type
* how users could pass in variables & have sane defaults injected
* how identity/access management works
Hopefully I can get through this without having to make a GCP account!

# writing the terraform module - 12:15 PM
They want me to bind/manage k8s RBAC in a similar way/schema to one of these [Google submodules](https://registry.terraform.io/modules/terraform-google-modules/iam/google/7.2.0), which looks easy because there's dozens of examples.

However, it looks like they want my module to be able to accept this [example input](https://gist.github.com/termleech/b33723d3c9fd3284ded14744a8d3f589):
```
module "rbac_binding" {
  source = "./modules/rbac_binding"

  namespaces = ["ns1", "ns2"]

  bindings = {
    "cluster-admin" = [
      "Group:test_sa_group@domain.com",
      "User:someone@domain.com",
      "ServiceAccount:service@google.com",
    ]

    "cluster-viewer" = [
      "Group:test_sa_group2@ domain .com",
      "User:someone2@domain.com",
      "ServiceAccount:service2@google.com",
    ]
  }
}
```
This seems to be written for setting up two (2) different Admin accounts using the `ServiceAccount` submodule. So I guess I have to use the [ServiceAccount submodule](https://github.com/terraform-google-modules/terraform-google-iam/tree/v7.4.0/examples/service_account).

# first attempt @ terraform module - 12:45 PM
I think I need to be using [this example] as my foundation. So at this point I'm going to:
1. clone it
2. overwrite `variables.tf` with the above input
3. do `brew install` & `terraform init` type things to get it all set up

5. tweak the module so it looks right
6. hopefully do some `terraform validate`-type command so I don't have to actually run this in GCP.

# notes on first attempt - 1 PM
This is going to be crude but here's the stuff I did:
1. `brew tap & install`
2. `git clone` & `terraform init`
3. checked out this [Get Started w/ Terraform on Google Cloud](https://learn.hashicorp.com/collections/terraform/gcp-get-started).
4. decided to use Google's SDK's b/c why not:
     - `brew install --cask google-cloud-sdk` - 300MB is a little extra but I'm not tripping
     - `gcloud init` - redirects to nice UI window for auth
     - `gcloud auth application-default login` - it'll give Terraform access to my creds to create stuff
5. back out and clone the [example repo](https://github.com/hashicorp/learn-terraform-provision-gke-cluster) to take a peek

     



```
Note: Try to simplify this module above using Terraform 0.13+ features i.e. for_each count for defined namespaces.
Please create two yamls in a private gist that accomplish the following:
- Deployment with 2 pods using argoproj/rollouts-demo:blue image exposed as 8080
- Setup pods from this deployment to have "net.ipv4.tcp_congestion_control" with value "bbr"
- Setup pods from this deployment to have anti affinity so they cannot be in the same zone and on the same node
- Add Container-native LB in GKE exposing created deployment on port 80 using NEGs
- Configuration of http -> https redirection on GCP ingress/svc level
Assuming you have Calico installed on the cluster, how would you ban this deployment from reaching Kubernetes API? (Note: We don't expect you to install Calico if you didn't work on it so far. If you don't have experience with it yet please propose a rough idea how you'd write such a rule based on Calico documentation alone).
```
