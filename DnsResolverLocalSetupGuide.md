# Setting Up Azure DNS Resolver as Local DNS Server

This document provides step-by-step instructions on how to set up an Azure DNS
Resolver as your local DNS server. This will allow you to resolve DNS to Azure
resources from your local machine.

It also addresses possible issues and provides troubleshooting steps.

The document assumes you have admin rights on your local machine and that you
have the Azure VPN client installed and configured. If you do not have the Azure
VPN client installed and configured, please refer to the
[Azure VPN Client Setup Guide](C:\Users\dbraga\Documents\Uniphar\repos\devops-guidelines\AzureVpnClientSetup.md)

## Step 1: Connect to Azure VPN

Before you can use the Azure DNS Private Resolver, you must connect to the
Azure VPN.

For more detailed instructions on how to setup and connect to the Azure VPN,
please refer to the [Azure VPN Client Setup Guide](C:\Users\dbraga\Documents\Uniphar\repos\devops-guidelines\AzureVpnClientSetup.md).

## Step 2: Change Local DNS Server IP Address

The DevOps team have prepared a PowerShell script that takes an environment as
the input and sets up the Azure DNS Private Resolver for that environment as
your local DNS server.

The script can be downloaded here: [Set-DnsPrivateResolver.ps1](https://github.com/Uniphar/devops-azure/blob/main/src/adhoc/Set-DnsPrivateResolver.ps1)

**Note:** You must have access to the `devops-azure` github repository.

After you have connected to the Azure VPN, you can run the script to change your
local DNS server IP address to the Azure DNS Private Resolver.

For the changes to work, you will need to run PowerShell **with administrative privileges**.

Then, run the script using the environment you wish to connect to as a
parameter. For example, if you with to connect to the dev DNS Private resolver
use following command:

```powershell
.\Set-DnsPrivateResolver.ps1 dev
```

The script accepts `dev`, `test`, and `prod` as valid inputs for the environment
parameter.

**Important note:** The environment you choose must match the environment of the
hub to which you are connected via VPN. For example, if you are connected to the
dev VPN, you must use the dev environment parameter.

## Step 3: Do the Necessary Work

At this point, you should be able to resolve DNS to the Azure resources you
need. Access to the internet should also be unaffected.

## Step 4: Reset Local DNS Server IP Address

After you are done, you must revert the DNS settings back to their original.
Since the DNS Private Resolver is in the azure network, you will not be able to
use it to resolve DNS once you disconnect from the VPN.

To rever the DNS setting back to the original, you can run the
`Set-DnsPrivateResolver.ps1` script again again with the `-Reset` switch. This
restore your local DNS Server IP address to the default value:

```powershell
.\Set-DnsPrivateResolver.ps1 -Reset
```

## Step 5: Disconnect from Azure VPN

Once you've finished setting up your DNS, you can disconnect from the Azure VPN.

Remember to test your new DNS settings to ensure everything is working as expected.

For more information on how to use the Azure VPN client, please refer to the
[Azure VPN Client Setup Guide](C:\Users\dbraga\Documents\Uniphar\repos\devops-guidelines\AzureVpnClientSetup.md)
or the [Microsoft Documentation](https://learn.microsoft.com/en-us/azure/vpn-gateway/openvpn-azure-ad-client)
on this subject.

## Possible Issues

If you run the script before connecting to the Azure VPN, DNS resolution will
not work. You will need to run the script again after connecting to the VPN.

This is because you need DNS resolution in order to successfuly connect to the
VPN, and since the Azure DNS Private Resolver is in the Azure network, it is not
accessible until you connect to the VPN. The Azure VPN client application may
be showing `"connected"`, but if you try to run `Test-NetConnection` to
resource in the Azure network, it will fail.

To fix this, you can try following these steps:

1. Disconnect from the Azure VPN.
2. Run the script again with the `-Reset` switch (see step 4).
3. Connect to the Azure VPN.
4. Run the script again with the environment parameter (see step 2).
5. Retest DNS resolution.

If you are still having issues, try restarting your computer and following the
steps again.
