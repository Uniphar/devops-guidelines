# DevOps Service Models

## DevOps hosted

When projects adhere to the set of principles and technical stack that we use in
the DevOps team, the project is fully owned by the DevOps team.

For VM projects, these are VMs that are fully automated and orchestrated and
that have no external access enabled, thus no human intervention on any
configuration that these VMs require.

### Windows VM automation

For Windows VMs we use Desired State Configuration to orchestrate. We already
have a pipeline in place to deploy DSC specs and custom modules, that essentially
pushes to an Azure Automation account that we then attach VMs to.

Mode detailed documentation on how to produce DSC on our technical stack is
detailed in [Windows DSC overview](./winVMsDSC.md)

### Linux VM automation

For Linux VMs we use [Ansible Playbooks](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html)
and we deploy them through github actions, with the options to use self-hosted
agents that are deployed in our Kubernetes clusters and have access to internal
IP only VMs.

We will accept any linux destribution that is available in Azure, and we will also
accept, when required, destributions that have license costs against them like [RHEL](https://learn.microsoft.com/en-us/azure/virtual-machines/workloads/redhat/redhat-imagelist).

Playbooks that need access to software, need to download from common Azure Storage
options (blob or files) into the target VM. The playbook will run from a blank state
of the chosen Linux distribution.

### Automation projects executed by 3rd party vendors

When automation projects are executed by vendors, they need conform to:

- Coding standards and principles need to adhere to [Uniphar's DevOps Guidelines](./README.md).
- All code developed for Uniphar will exists and be maintained in Uniphar owned
  github repositories. The intellectual property of this code is also owned by Uniphar.
- All  version control, reporting, requirements management, project management,
  automated builds, testing and release management capabilities. will need to be
  managed in line with Uniphar requirements.
- All code produced may need to be peer reviewed by suitable Uniphar staff.
- All configurations  may need to be peer reviewed by suitable Uniphar staff.
- All software delivered will need to be accepted by the Uniphar Devops team, in
  a format that aligns to our Devops strategy.
- All tememetry will need to vonfirm to Uniphar standards and technical stack,
  or be agreed upfront.

Before delivery, the automation needs to run on a blank (just re-created) DEV
environment and the vendor needs to be available to solve any issues with promoting
the automation to TEST and PROD.

The vendor will have full access to the DEV environment including RDP/SSH.

## External hosted

For externally hosted projects, we will build the infrastructure and the vendor
will manage the installation of the software. However the vendor will own the
servers and will be responsible for any observability or alerting related to the
proper function of the servers applications.

Part of the infrastructure project will be backups and restores will be done by DevOps.

The only task that DevOps will do in this scenario is to rebuild the infrastructure
when required by the vendor.
