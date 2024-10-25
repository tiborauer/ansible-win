INSTALLERPATH=$1
ROLESPATH=/etc/ansible/roles

# - add PPA:ansible
cp $INSTALLERPATH/ansible.gpg /usr/share/keyrings/
chmod 0644 /usr/share/keyrings/ansible.gpg
cp $INSTALLERPATH/ansible.sources /etc/apt/sources.list.d/
chmod 0644 /etc/apt/sources.list.d/ansible.sources
# - install
apt update
apt install ansible -y
ansible-galaxy role install --roles-path=$ROLESPATH idiv_biodiversity.lmod