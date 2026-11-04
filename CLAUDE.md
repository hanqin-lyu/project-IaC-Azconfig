# Rules for AI agents (project-IaC-Azconfig)

## Layout
- `01-platform-policy/` — Azure Policy, owned by the security team. Do not edit.
- `02-workload-resources/` — workload Terraform (AVM modules), the only place you edit.
- `.github/workflows/` — CI (Checkov, fmt/validate, plan) and CD (apply). Do not change without being asked.

## Hard rules
- Never run `terraform apply`, `destroy` or `force-unlock`. Changes go through a PR; CD applies after merge.
- Do not log in to Azure. This machine holds no deploy credentials, and that is intentional.
- Never hardcode secrets or passwords; use variables or Key Vault references.
- Never add NSG rules open to `*` / `0.0.0.0/0` on ports 22 or 3389.

## Known intentional fixtures — leave them alone unless asked to remediate
`02-workload-resources` deliberately contains an `AllowSSHAll` NSG rule and a plaintext SQL admin password. They exist to demonstrate Checkov blocking the PR and Azure Policy as the deploy-time backstop. Do not "fix" them on your own initiative, and do not add new ones. (Remove this section once the demo evidence is collected.)

## How to work
- AVM modules are not the same as native resources. Read the module's `variables.tf` for input names and object shapes; do not guess attribute names. `parent_id` points at the resource group.
- Before proposing a change run, in `02-workload-resources/`: `terraform fmt -check`, `terraform validate`, `checkov -d .`.
- `skip_check: CKV_TF_1` in CI is deliberate (AVM modules come from the Terraform Registry, not raw Git refs). Don't re-flag it.
- Resource names: this is a demo project, not production. Don't use `prod` in names.
- Keep PRs small and describe which Checkov findings were added or removed.
