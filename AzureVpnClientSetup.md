# Configure the Azure VPN client

## Pre-requisites

Make sure you have been added to the [uni-sec-VPN_Users](https://portal.azure.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/82ab6a21-ece0-4ac0-b411-67774c886ead/menuId/) group in Azure AD.
If you haven't been added, please contact the DevOps team.

## Download and install the VPN client application

You can get the latest version of the Azure VPN client application from any of
the following options:

- Using Client Install files: <https://aka.ms/azvpnclientdownload>.
- With winget, running the following command: `winget install 9NP355QT2SQB -s msstore`
- Microsoft Store.

## Import the VPN client profile configuration file

The more convenient way to setup the VPN client is to import the VPN client
profile configuration file. This file contains all the information needed to
connect to the VPN gateway.

These profile configuration files are XML files that can be found by navigating to
`\\unicoreplatform.file.core.windows.net\vpnxmls` in file explorer. If you have
correctly been added to the Azure VPN Users Entra ID Group, you should be able
to access the files without being prompted to authenticate. You may need to wait for
your group membership to propagate, but if after an hour you still cannot
access the share, please contact the TechOps team and confirm weather you are in
the group.

The file for each of the Azure Hub VPN gateways is inside the folder with the
corresponding environment name.

After you have acquired the profile configuration file, you can import it into
the VPN client application by following these steps:

### 1. On the Azure VPN client application, select the **Import** option on the bottom left

![Step 1](./img/VpnClient/VpnClientSetup1.png)

### 2. Browse to the profile xml file and select it. With the file selected, select **Open**

![Step 2](./img/VpnClient/VpnClientSetup2.png)

### 3. Optionally, you may edit the connection name. Then select **Save**

![Step 3](./img/VpnClient/VpnClientSetup3.png)

### 4. The following screen will show. Select **OK**

![Step 4](./img/VpnClient/VpnClientSetup4.png)

### 5. The VPN client application will now show the connection profile. Select **Connect** to connect to the VPN

![Step 5](./img/VpnClient/VpnClientSetup5.png)

### 6. You will be prompted to authenticate with your account. Complete the necessary actions

### 7. Once connected, the icon will turn green and say **Connected**

![Step 7](./img/VpnClient/VpnClientSetup7.png)

For more detailed information, please refer to the
[Microsoft Documentation](https://learn.microsoft.com/en-us/azure/vpn-gateway/openvpn-azure-ad-client)
on this subject.
