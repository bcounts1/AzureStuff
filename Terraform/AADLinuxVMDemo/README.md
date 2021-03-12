# AAD Linux VM Authentication Demo

The purpose of this demo is to easily experiment with the **preview** AAD authentication feature for Linux VMs. You can find more information on this feature [here](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/login-using-aad).

## Whats deployed in this demo?

1x Vnet \
2x Subnets \
1x Public IP address \
1x Linux VM \
1x NSG \
1x RSA key

## Instructions

The key to enabling this feature is the installation of the **AADLoginForLinux** extension. After deployment you can do the following steps to configure access:

1.) Enable RBAC access to a user or group to the **Virtual Machine Administrator Login** or **Virtual Machine User Login** roles.

2.) From your SSH client, connect with the following string: **ssh UPN@PublicIPAddress

3.) You will be prompted to sign in with a device login code at https://microsoft.com/devicelogin 

This feature is in preview and comes with a set of limitation. Please review the documentation linked above for additional FAQ on what is currently supported. 