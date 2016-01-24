# arch-study-1

## Cluster infrastructure
Terraform source inspired by [https://github.com/hashicorp/terraform/tree/master/examples/aws-two-tier](https://github.com/hashicorp/terraform/tree/master/examples/aws-two-tier).

Pipe traffic
```bash
ssh -N -f -i "arch-study-1.pem" -L 8500:localhost:8500 ubuntu@54.153.118.193
```

## Docker host AMI

```bash
cd docker-host

packer build \
  -var docker_version=1.9.1 \
  -var source_ami=ami-df6a8b9b \
  -var aws_region=us-west-1 \
  -var aws_access_key=$AWS_ACCESS_KEY_ID \
  -var aws_secret_key=$AWS_SECRET_ACCESS_KEY \
  docker-host.json
```

Packer source inspired by [https://github.com/d11wtq/docker-ami-packer](https://github.com/d11wtq/docker-ami-packer).
