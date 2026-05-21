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

