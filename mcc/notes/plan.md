# MCC integration experiment

## Goal

Use the Vagrant k0s/podman environment as a prototype for gradually preparing MCC deployment through containers and Helm.

## Baseline

- k0s VM is running
- podman VM is running
- kubectl works from the k0s VM
- helm works from the k0s VM
- original hello-world examples are kept unchanged

## First milestones

1. Keep original workshop files untouched.
2. Create separate MCC Helm/chart workspace.
3. Decide which MCC component to test first.
4. Start with one dependency, not the full MCC stack.
5. Document every change.

## Milestone: MCC test chart reachable from Windows

The `mcc-test` chart is reachable from Windows through:

`http://test-mcc.aura.local:30123`

Access path:

Windows hosts entry:
- `127.0.0.1 test-mcc.aura.local`

Vagrant:
- forwards host port `30123` to k0s VM guest port `30123`

k0s:
- ingress-nginx exposes HTTP on NodePort `30123`
- ingress host is `test-mcc.aura.local`
- backend service is `hello-kubernetes-svc` in namespace `mcc-test`

Verified page message:

`MCC test chart is deployed from my own workspace`