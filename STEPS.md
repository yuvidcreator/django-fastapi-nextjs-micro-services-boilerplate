# Enterprise Grade Ful Stack Django-FastAPI-NextJS web app boilerplate



### Quick checklist to bootstrap (actionable)

* Provision the Terraform remote state bucket (run `bootstrap-create-state.sh` locally or via short-lived CLI).
* Push the infra code to `infra/` in your monorepo and protect `production` branches.
* Create GitHub repo OIDC trust and an IAM role with the trust condition limited to your repo and branch (follow GitHub AWS OIDC docs). [GitHub Docs](https://docs.github.com/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services?utm_source=chatgpt.com)
* Wire up GitHub Actions workflows (plan + apply). Use environment protection rules for `apply`.
* Deploy EKS (terraform apply on staging). Then install ArgoCD (argocd bootstrap) and apply `applicationset.yaml`.
* Use ApplicationSet to deploy per-service Helm charts from `/charts`.


### Short list of references (for audit & future-proofing)

* Terraform + AWS prescriptive guidance & module structure. [AWS Documentation](https://docs.aws.amazon.com/pdfs/prescriptive-guidance/latest/terraform-aws-provider-best-practices/terraform-aws-provider-best-practices.pdf?utm_source=chatgpt.com)
* Amazon EKS Kubernetes version lifecycle & upgrade guidance. [AWS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html?utm_source=chatgpt.com)
* GitHub Actions OIDC → AWS trust example and steps. [GitHub Docs](https://docs.github.com/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services?utm_source=chatgpt.com)
* Terraform S3 backend and locking notes. [HashiCorp Developer**+1**](https://developer.hashicorp.com/terraform/language/backend/s3?utm_source=chatgpt.com)
* ArgoCD ApplicationSet docs. [argo-cd.readthedocs.io](https://argo-cd.readthedocs.io/en/latest/user-guide/application-set/?utm_source=chatgpt.com)
