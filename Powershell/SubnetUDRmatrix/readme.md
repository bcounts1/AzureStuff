# Subnet Matrix Script
A simple script that allows you to audit NSG and UDR config across every subnet in very VNET within a subscription. The output can be exported into a spreadsheet or a database for tracking purposes.

**Example:**
.\get-SubnetUDR.ps1 -subscription MySubscription

Outputs:
- VNET
- Subnet
- RoutTable
- NetworkSecurityGroup
