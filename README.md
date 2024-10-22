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
- VMs share the IP by WSL-design; therefore, they can be acessed using different ports only
- head VM is called _ansible-control_ and uses port 2000
- base VM is called _vm-01_ and uses port 2001
- service user is called _service_
- service user is full passwordless sudoer

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
    1. `nano /etc/wsl.conf`
    2. add the lines hostname=your-new-host-name and generateHosts=false under [network]
    3. `nano /etc/hosts`
    4. make sure that line with IP address 127.0.1.1 maps it to your hostname
    5. `wsl --shutdown`
4. Set SSH (both VMs)
    ```bash
    apt update
    apt upgrade
    apt install openssh-server
    sed -i -E 's,^#?Port.*$,Port <port number>,' /etc/ssh/sshd_config
    ```
5. Create service user
    ```bash
    adduser -home /home/service service
    echo 'service ALL=(root) NOPASSWD: ALL' >/etc/sudoers.d/service
    echo 'sudo service ssh status || sudo service ssh start' >> /home/service/.bashrc
    ```
6. Set default
    1. `nano /etc/wsl.conf`
    2. add the lines default=service under [user]
    3. `wsl --shutdown`

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



