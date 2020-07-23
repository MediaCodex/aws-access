# AWS-Access

Central repo for managing deployment users/roles.

## Creating a new service

Due to the way that Terraform workspaces are implemented, the remote backend is stored in the root account, as such
you need to go and create a new role for your service to assume when accessing the backend, this is stored in the
[Infrastructure](https://gitlab.com/mediacodex/infrastructure/-/blob/master/terraform/service-states.tf) repository.

While you technically need to know the ARN of the new service's deploy user in order to create the backend role,
you can be reasonably safe in assuming the naming scheme on the Infrastructure side since it won't try to check the
principle actually exists until the policy is used.

## First deployment

While most of the resources are defined in such a way as to be independent of other services to avoid race-conditions, there are a few
resources that reply on the outputs from other services, as such they cannot be created without causing a lovely chicken-and-egg scenario
for the order in which to deploy said services.

To make life significantly easier any resources that rely on sub-services can be disabled by changing a single variable to `true`, while
this does force you to deploy this repo twice for a new cloud, that in significantly less effort than any alternatives. The variable can
even be set via the CI env so you don't have to commit any changes, just run the pipeline twice.

| Default value | TF Var         | Env Var               |
| ------------- | -------------- | --------------------- |
| `false`       | `first_deploy` | `TF_VAR_first_deploy` |
