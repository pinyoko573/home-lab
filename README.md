# home-lab-scripts

![Diagram](https://github.com/user-attachments/assets/859cdd43-ddc8-4a77-bd0a-d4bdaf069690)

Easily deploy a security lab environment using automation scripts designed to simulate on attacks and faciliate log ingestion for analysis and detection!

These scripts are tested on virtual machines (e.g. VMware Workstation), but they can also be run on physical machines or cloud-based virtual instances.

Simply install the operating system, setup remote configurations, choose the intended tasks, edit the variables on *inventory.yml*, *site.yml* and */group_vars* and you're good to go!

## Ansible

### Getting Started

To add or remove tasks, modify the tasks of the host groups in *site.yml* to your needs.

Be sure to modify the hosts and variables in ***inventory.yml*** and ***/group_vars*** before running!

To run, enter `ansible-playbook site.yml -i inventory.yml [-l win_dc]`

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

#### Setup
| Platform | Task                  | Description                                                   | Automated |
| -------- | --------------------- | ------------------------------------------------------------- | --------- |
| Ubuntu   | ubuntu_changehostname | Changes the host name                                         |           |
| Ubuntu   | ubuntu_azurearc       | Onboard machine to Azure Arc                                  |           |
| Ubuntu   | ubuntu_joindomain     | Joins an Active Directory domain                              |           |
| Ubuntu   | ubuntu_mysql          | Installs MySQL server                                         |           |
| Ubuntu   | ubuntu_rsyslog        | Provides information on installing rsyslog                    | No        |
| Ubuntu   | ubuntu_wordpress      | Installs WordPress                                            |           |
| Windows  | win_changehostname    | Sets WinRM service to Auto and changes the host name          |           |
| Windows  | win_azurearc          | Onboard machine to Azure Arc                                  |           |
| Windows  | win_joindomain        | Joins an Active Directory domain                              |           |
| Windows  | win_createdomain      | Creates an Active Directory Domain Controller as a new forest |           |
| Windows  | win_eventcollector    | Configures Windows Event Collector                            |           |
| Windows  | win_eventforwarder    | Provides GPO settings to configure Windows Event Forwarder    | No        |
| Windows  | win_joindomain        | Joins an Active Directory domain                              |           | 

#### Attack Simulations
1. Kerberoasting
  - Description
    - Kerberoasting is an attack where an attacker targets on service accounts by:
      1. Enumerate service accounts with SPNs from the domain controller
      2. Using the authenticated user's ticket-granting ticket (TGT) to request for a Kerberos ticket-granting service (TGS) for every SPN, with the TGS's encryption type to be RC4, a weak cryptography algorithm.
      3. Attempt to brute force the password hash in TGS to obtain the plaintext password of the service account.
  - Assumptions
    - Attacker is within the AD network and has an authenticated user account.
  - Detections
    - Look for Windows events with ID 4768 and 4769, with the ticket encryption type RC4 (0x17).

2. AS-REP Roasting (todo)

## Terraform

### Azure Sentinel

#### Setup
Performs:
- Creation of resource group
- Creation of log analytics workspace (LAW), data collection rules (DCRs)
- Onboard Azure Arc machines (Windows & Linux) and install Azure Monitor Agents
- Add Azure Arc machines to Data sources in DCR
- Onboard LAW to Microsoft Sentinel

#### Detection
1. Microsoft Sentinel analytic rules for Kerberoasting (todo)