# Creating a new service

Due to the way that Terraform workspaces are implemented, the remote backend is stored in the root account, as such
you need to go and create a new role for your service to assume when accessing the backend, this is stored in the
[Infrastructure](https://gitlab.com/mediacodex/infrastructure/-/blob/master/terraform/service-states.tf) repository.

While you technically need to know the ARN of the new service's deploy user in order to create the backend role,
you can be reasonably safe in assuming the naming scheme on the Infrastructure side since it won't try to check the
principle actually exists until the policy is used.
