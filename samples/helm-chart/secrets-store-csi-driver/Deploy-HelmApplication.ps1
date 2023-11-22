param (
    [parameter(Mandatory = $true)]
    [string] $TenantId,

    [parameter(Mandatory = $true)]
    [string] $SubscriptionId,

    [parameter(Mandatory = $true)]
    [string] $ResourceGroup,

    [parameter(Mandatory = $true)]
    [string] $HostName,

    [parameter(Mandatory = $true)]
    [string] $ClusterName,

    [parameter(Mandatory = $true)]
    [string] $NodePool,

    [parameter(Mandatory = $true)]
    [string] $Namespace,

    [parameter(Mandatory = $true)]
    [string] $ImageRepository,

    [parameter(Mandatory = $true)]
    [string] $AzureADWorkLoadIdentityName,

    [parameter(Mandatory = $true)]
    [string] $KeyVaultName,

    [parameter(Mandatory = $true)]
    [string] $StorageResourceGroup,

    [parameter(Mandatory = $true)]
    [string] $StorageStorageAccount,

    [parameter(Mandatory = $true)]
    [string] $StorageShareName,

    [parameter(Mandatory = $true)]
    [string] $StorageServer

)

if (!(Get-Module -Name "powershell-yaml" -ListAvailable)) {
    Install-Module -Name "powershell-yaml" -Scope CurrentUser -Force
}

az account set --subscription $SubscriptionId
az aks get-credentials --resource-group $ResourceGroup --name $ClusterName
kubelogin convert-kubeconfig -l azurecli

$chartRootDirectory = Join-Path $PSScriptRoot "chart"
$APP_HELM_VERSION = "1.0.$((Get-Date).ticks)"

Push-Location $chartRootDirectory

helm package $ChartRootDirectory --version $APP_HELM_VERSION --app-version $APP_HELM_VERSION

$applicationName = (Get-Content -Path "$chartRootDirectory/Chart.yaml" -Raw | ConvertFrom-Yaml).name

$serviceAccountClientId = (Get-AzADServicePrincipal -DisplayName $AzureADWorkLoadIdentityName).AppId

helm upgrade $applicationName "./$applicationName-$APP_HELM_VERSION.tgz" -n $Namespace --install `
                                --set serviceAccount.tenantId=$TenantId `
                                --set serviceAccount.name=$AzureADWorkLoadIdentityName `
                                --set serviceAccount.clientId=$serviceAccountClientId `
                                --set ingress.hostName=$HostName `
                                --set CSI.kvName=$KeyVaultName `
                                --set image.repository=$ImageRepository `
                                --set nodePool=$NodePool `
                                --set storage.resourceGroup=$StorageResourceGroup `
                                --set storage.storageAccount=$StorageStorageAccount `
                                --set storage.shareName=$StorageShareName `
                                --set storage.server=$StorageServer `
                                --atomic

Pop-Location