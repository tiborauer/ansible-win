# 1. Setting up the VMs
## 1.1. Enable WSL 2
1. PowerShell as Administrator:
    ```powershell
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    ```
2. Restart
3. Update Linux kernel: https://aka.ms/wsl2kernel
4. PowerShell as Administrator:
    1. wsl --set-default-version 2
5. Install distro from Microsoft Store (e.g., Ubuntu-24.04)

## 1.2. Prepare two instances
### Architecture
- WSL-related files (e.g., virtual disk) are stored in C:\WSL (create if not exists)
- head VM is called _ansible-control_
- base VM is called _vm-01_

### Steps
1. Export and remove the standard VM
    ```powershell
    mkdir C:\WSL\images
    wsl --export Ubuntu-24.04 C:\WSL\images\ubuntu-24.04.tar
    wsl --shutdown
    wsl --unregister Ubuntu-24.04
    ```
2. Create two instances
    ```powershell
    wsl --import ansible-control C:\WSL\ansible-control C:\WSL\images\ubuntu-24.04.tar
    wsl --import vm-01 C:\WSL\vm-01 C:\WSL\images\ubuntu-24.04.tar
    ```
3. Set hostnames (both VMs)
    1. nano /etc/wsl.conf
    2. add the lines hostname=your-new-host-name and generateHosts=false under [network]
    3. wsl --shutdown

# 2. Set up head VM
## 2.1. Install required tools (as root)
```bash
apt update
apt upgrade

# Keyring to store Ansible vault password
apt install python3-pip
pip install keyring keyrings.cryptfile --break-system-packages

# Ansible
apt install software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt install ansible
```

## 1.4. Create service user
### Architecture
- service user is called _service_
- service user is full passwordless sudoer

### Steps (as root)
1. Create service user
    ```bash
    adduser -home /home/service service
    echo 'service ALL=(root) NOPASSWD: ALL' >/etc/sudoers.d/service
    ```
2. Set default
    1. sudo nano /etc/wsl.conf
    2. add the lines default=service under [user]
    3. wsl --shutdown

# 2. Set up passwordless SSH
## 2.1. Install OpenSSH (both VMs)
