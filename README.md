# 1. Setting up the VMs
## Considerations
- HyperV-related files are stored in _D:\HyperV_
- All repos (including this one) are cloned in _D:\Projects_
- specs for the VMs: 
    - hardware: CPU: 2, RAM: 2GB, HDD: 10GB
    - OS: Ubuntu 24.04 LTS
- network: The VMs use a virtual network (switch+NAT) to ensure static IPs while also providing internet access to the VMs
    - Switch: HyperVSwitch
    - NAT: HyperVNAT
    - Nameserver: 10.12.0.1 
    - Gateway: 8.8.8.8
    - VMs:
        - Control: hostname: control, IP: 10.12.0.101
        - Client: hostname: vm-01, IP: 10.12.0.111
- user: Service account "service" is created with only SSH access using the RSA private key encoded in the repo
- software space: Software space is created at _D:\HyperV\software_ and mounted at the VMs' _/software_


## Steps
1. Enable Hyper-V (PowerShell as Administrator)
    ```powershell
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Tools-All -All
    ```

2. Connect the VMs with the (Windows) host and the internet
    1. Create virtual network for the VMs
        ```powershell
        New-VMSwitch -SwitchName HyperVSwitch -SwitchType Internal
        New-NetIPAddress -IPAddress 10.12.0.1 -PrefixLength 24 -InterfaceAlias "vEthernet (HyperVSwitch)"
        New-NetNAT -Name HyperVNAT -InternalIPInterfaceAddressPrefix 10.12.0.0/24
        ```
    2. Ensure that VMs can reach the software space on host
        1. Search and open the "Windows Defender Firewall with Advanced Security" in the Start
        2. Inbound Rules -> File and Printer Sharing (SMB-In), Public
        3. Double click
        4. General tab -> Click "Enabled"
        5. Scope tab -> Remote IP address -> These IP addresses
        6. (Optional) Replace "Local subnet" to IP range 10.12.0.101-10.12.0.119 to restrict access

3. Clone repo for provisioning
    ```shell
    git clone https://github.com/tiborauer/hyperv-cloudinit
    ```

4. Provision VMs (PowerShell as Administrator)
    ```powershell
    cd D:\Projects\hyperv-cloudinit
    % Client must be started first, so that its SSH fingerprint can be automatically added to the control
    .\New-HyperVCloudImageVM.ps1 -VMProcessorCount 2 -VMMemoryStartupBytes 2GB -VHDSizeBytes 10GB -VMName "vm-01" -ImageVersion "24.04" -VirtualSwitchName "HyperVSwitch" -VMGeneration 2 -VMMachine_StoragePath "D:\HyperV" -NetAddress 10.12.0.101/24 -NetGateway 10.12.0.1 -NameServers "8.8.8.8" -CustomUserDataYamlFile "D:\Projects\ansible-win\cloud-init\vm-client.yml"

    .\New-HyperVCloudImageVM.ps1 -VMProcessorCount 2 -VMMemoryStartupBytes 2GB -VHDSizeBytes 10GB -VMName "control" -ImageVersion "24.04" -VirtualSwitchName "HyperVSwitch" -VMGeneration 2 -VMMachine_StoragePath "D:\HyperV" -NetAddress 10.12.0.111/24 -NetGateway 10.12.0.1 -NameServers "8.8.8.8" -CustomUserDataYamlFile "D:\Projects\ansible-win\cloud-init\vm-control.yml"
    ```

# 2. Set up control VM (as service user)
## 2.1. Set up ansible-vault
N.B.: You hav to use the same vault-id (if any) and password as for the encryption
```bash
./utils/vault-keyring.py --set
```