# home-lab-scripts

Automation scripts for setting up a security lab to simulate on attacks and/or log ingestion.

These scripts are tested on virtual machines (e.g. VMware Workstation), but you can also try it on a physical machine or cloud virtual machine.

## Ansible

### Getting Started

To add/remove tasks, modify site.yml with the task name.

Be sure to modify the hosts and vars in ***inventory.yml*** and ***/group_vars*** before running.

#### Windows
Tested platforms
- Windows Server 2022
- Windows 11

Instructions
1. To perform tasks on a Windows machine, enable the Windows Remote Management (WinRM) protocol by running `winrm quickconfig`.
2. A password is mandatory for authentication using WinRM. `Ctrl+Alt+Delete` -> Change password to assign a password.
3. Ensure that Network Location for the network adapter is set to **Private** to prevent any Firewall issues.
4. (For Windows Server) If you encounter a SID duplicate error when joining a domain, run `%WINDIR%\system32\sysprep\sysprep.exe /generalize /restart /oobe /quiet`

#### Linux
Tested platforms
- Ubuntu Server 24.04.3

Instructions
1. Generate a SSH key pair for installing public key on control node and private key on managed node using `ssh-keygen -f ~/.ssh/<control node computer name> -t ed25519`
2. Copy the SSH public key to the control node: `ssh-copy-id -i ~/.ssh/control_node.pub ubuntu@192.168.100.1`
3. Start the ssh-agent program and copy the private key to the agent in order to skip the passphrase prompt `ssh-agent $SHELL && ssh-add ~/.ssh/control_node`

### Available Tasks
| Platform | Task               | Description                                                   | Automated |
| -------- | ------------------ | ------------------------------------------------------------- | --------- |
| Ubuntu   | ubuntu             | Changes the host name                                         |           |
| Ubuntu   | ubuntu_azurearc    | Onboard machine to Azure Arc                                  |           |
| Ubuntu   | ubuntu_joindomain  | Joins an Active Directory domain                              |           |
| Ubuntu   | ubuntu_mysql       | Installs MySQL server                                         |           |
| Ubuntu   | ubuntu_rsyslog     | Provides information on installing rsyslog                    | No        |
| Ubuntu   | ubuntu_wordpress   | Installs WordPress                                            |           |
| Windows  | win                | Sets WinRM service to Auto and changes the host name          |           |
| Windows  | win_joindomain     | Joins an Active Directory domain                              |           |
| Windows  | win_createdomain   | Creates an Active Directory Domain Controller as a new forest |           |
| Windows  | win_eventcollector | Configures Windows Event Collector                            |           |
| Windows  | win_eventforwarder | Provides GPO settings to configure Windows Event Forwarder    | No        |
| Windows  | win_joindomain     | Joins an Active Directory domain                              |           | 

## Terraform

### Azure Sentinel

Performs:
- Creation of resource group
- Creation of log analytics workspace (LAW), data collection rules (DCRs)
- Onboard Azure Arc machines (Windows & Linux) and install Azure Monitor Agents
- Add Azure Arc machines to Data sources in DCR
- Onboard LAW to Sentinel