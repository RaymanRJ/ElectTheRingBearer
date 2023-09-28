## Terraform:

To use the terraform, create a tf.conf file:
```
bucket="<<state-bucket>>"
region="<<state-bucket-target-region>>"
```

Initialize Terraform:
```shell
terraform init -backend-config=tf.conf
```

Apply Terraform:
```shell
terraform apply
```