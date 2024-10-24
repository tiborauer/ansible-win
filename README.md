# 1. Setting up the VMs
## Considerations
- HyperV-related files are stored in D:\HyperV
- All repos (including this one) are cloned in D:\Projects
- specs for the VMs: 
    - hardware: CPU: 2, RAM: 2GB, HDD: 10GB
    - OS: Ubuntu 24.04 LTS
- network: The VMs use a virtual network switch to ensure static IPs while also providing internet access to the VMs
    - Nameserver and Gateway: 192.168.0.1
    - VMs:
        - Control: hostname: control, IP: 192.168.0.100
        - Client: hostname: vm-01, IP: 192.168.0.101

## Steps
1. Enable Hyper-V (PowerShell as Administrator)
    ```powershell
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Tools-All -All
    ```

2. Create an external virtual network switch (if you do not have one already)
    1. Open Hyper-V Manager -> Virtual Switch Manager
    2. Virtual Switcher -> New virtual network switch
    3. Select "External"
    4. Click "Create Virtual Switch"
    5. Specify a name, e.g., "HyperV External Switch" and leave the rest default
    6. Click "Ok"

3. Clone repo for provisioning
    ```shell
    git clone https://github.com/tiborauer/hyperv-cloudinit
    ```

4. Provision VMs (PowerShell as Administrator)
    ```powershell
    cd D:\Projects\hyperv-cloudinit
    .\New-HyperVCloudImageVM.ps1 -VMProcessorCount 2 -VMMemoryStartupBytes 2GB -VHDSizeBytes 10GB -VMName "control" -ImageVersion "24.04" -VirtualSwitchName "HyperV External Switch" -VMGeneration 2 -VMMachine_StoragePath "D:\HyperV" -NetAddress 192.168.0.100/24 -NetGateway 192.168.0.1 -NameServers "192.168.0.1" -CustomUserDataYamlFile "D:\Projects\ansible-win\cloud-init\vm-control.yml" -ShowVmConnectWindow
    .\New-HyperVCloudImageVM.ps1 -VMProcessorCount 2 -VMMemoryStartupBytes 2GB -VHDSizeBytes 10GB -VMName "vm-01" -ImageVersion "24.04" -VirtualSwitchName "HyperV External Switch" -VMGeneration 2 -VMMachine_StoragePath "D:\HyperV" -NetAddress 192.168.0.101/24 -NetGateway 192.168.0.1 -NameServers "192.168.0.1" -CustomUserDataYamlFile "D:\Projects\ansible-win\cloud-init\vm-client.yml" -ShowVmConnectWindow
    ```

# 2. Set up head VM (as service user)
## 2.1. Install required tools
```bash
# Keyring to store Ansible vault password
sudo apt install python3-pip
sudo pip install keyring keyrings.cryptfile --break-system-packages

# Ansible
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

# Additional packages
ansible-galaxy role install idiv_biodiversity.lmod
```

## 2.2. Set up ansible-vault
```
./utils/vault-keyring.py --set
```

## 2.3. Set up passwordless SSH
```bash
ansible-playbook -i inventory.yaml setup-head.yaml --vault-id @utils/vault-keyring.py
ssh-copy-id -i ~/.ssh/id_ansible -p 2001 localhost
```



