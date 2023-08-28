# DSC for Windows VMs

At times, specific workflows require custom VMs to be deployed. This would be the case when applications/workloads cannot be containerised and deployed to our Kubernetes clusters. 

Custom VMs can then host these specific applications/workloads - but they often require specific configuration - dependencies installed, OS features enabled, critical files present etc. 

For Windows VMs, these configurations are implemented as DSC (Desired State Configuration) scripts. DSC scripts are applied against the VMs during provisioning and can be re-applied at any time.

For further technical information about DSC, please refer to [Microsoft documentation](https://learn.microsoft.com/en-us/powershell/dsc/getting-started/wingettingstarted?view=dsc-1.1).

## Lifecycle

1. DSC script is developed via its dedicated repository and CI/CD. It gets published to a dedicated Azure Automation Account (AA) resource.
   1. Each script must be imported (*Import-AzAutomationDscConfiguration*) and compiled (*Start-AzAutomationDscCompilationJob*). You can use ( *Get-AzAutomationDscCompilationJob*) to wait for the compilation job to finish. 

    Each environment has its own automation account instance.
    Each specific configuration has its dedicated, unique name.

1. VM(s) are provisioned using bicep and respective CI/CD pipeline.

1. VMs are joined to an environmental Azure Automation Account (AA) during provisioning. Azure Automation Account resource provides support for DSC and serves as a central repository for DSC scripts and orchestrates their execution against connected VMs so that the VMs are up to date with the latest configuration.

We utilize Powershell Az.Automation Module to interact with DSC functions. Key cmdlet is [Register-AzAutomationDscNode](https://learn.microsoft.com/en-us/powershell/module/az.automation/register-azautomationdscnode?view=azps-10.2.0). This registers VM instance against a specific DSC configuration in a referenced Azure Automation Account.

### VMs/DSC pipelines interaction

We recommend having separate pipeline for VM provisioning and DSC configuration. This is to ensure that VMs are provisioned and configured in a consistent manner. 

The main benefit is that it allows for VMs an DSC configuration script to have different release cadence. 

When VMs are provisioned, DSC workflow can be triggered using your repository features (e.g. GitHub's workflow trigger) from the VM pipeline- for given enviroment. This ensures DSC configuration is available and applied.

Subsequently, DSC configuration changes can be detected via your repository triggers (i.e. file changed) and DSC workflow can be triggered across all environments - ensuring that any future DSC change is captured and deployed.