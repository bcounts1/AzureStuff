# Subnet Matrix Script
Simple Script that allows you to export NSG and UDR config across every subnet in very VNET within a subscription. This is helpful to keep track of what UDRs and NSGs are in use within each Virtual Network

**Example:**
.\get-SubnetUDR.ps1 -subscription MySubscription

Outputs:
- VNET Name
- Subnet Name
- RoutTable
- NetworkSecurityGroup
