# Ansible Labs

Welcome to Ansible Labs for the DevOps Academy 2023.

## How to use these Labs

To follow the exercises with Ansible you need to create your own environment for which you need to install VirtualBox as a type-2 hypervisor for virtualization and Vagrant for building your virtual environment.

You can install these tools the classic manual way:

* ### Install Oracle Virtual Box:  https://www.virtualbox.org/
* ### Install Vagrant: https://www.vagrantup.com/downloads.html


Or if you are using Windows you can install them with a script:
```powershell
$ScriptFromGit = Invoke-WebRequest https://git.davchev.com/DevOps_Academy/ansible-labs/raw/branch/master/install_CVV-stack.ps1

Invoke-Expression $($ScriptFromGit.Content)
```
> **_NOTE:_**
The script will automatically restart your machine❗

* ### In a new Directory copy this respository:
``` shell
git clone https://git.davchev.com/DevOps_Academy/ansible-labs.git
```
OR 

If you choose not to clone the given repository, you can create your own with the following structure:

``` shell
.
├── Ansible-basic-exercise.md
├── README.md
├── Vagrantfile
├── ansible-lab1
│   ├── README.md
│   └── hosts
├── ansible-lab2
│   ├── README.md
│   ├── hosts
│   └── inventory.yml
├── ansible-lab3
│   ├── README.md
│   ├── hosts
│   ├── playbook1.yml
│   └── templates
│       ├── index.html.j2
│       └── ports.conf.j2
├── ansible-lab4
│   ├── README.md
│   ├── handlers
│   │   └── main.yml
│   ├── hosts
│   ├── playbook1.yml
│   ├── tasks
│   │   └── apache2_install.yml
│   └── templates
│       ├── index.html.j2
│       └── ports.conf.j2
├── ansible-lab5
│   ├── README.md
│   ├── hosts
│   ├── playbook1.yml
│   └── roles
│       ├── apache2
│       │   ├── README.md
│       │   ├── defaults
│       │   │   └── main.yml
│       │   ├── handlers
│       │   │   └── main.yml
│       │   ├── meta
│       │   │   └── main.yml
│       │   ├── tasks
│       │   │   ├── apache2_install.yml
│       │   │   └── main.yml
│       │   ├── templates
│       │   │   ├── index.html.j2
│       │   │   └── ports.conf.j2
│       │   ├── tests
│       │   │   ├── inventory
│       │   │   └── test.yml
│       │   └── vars
│       │       └── main.yml
│       ├── common
│       │   ├── README.md
│       │   ├── defaults
│       │   │   └── main.yml
│       │   ├── handlers
│       │   │   └── main.yml
│       │   ├── meta
│       │   │   └── main.yml
│       │   ├── tasks
│       │   │   ├── install_tools.yml
│       │   │   └── main.yml
│       │   ├── tests
│       │   │   ├── inventory
│       │   │   └── test.yml
│       │   └── vars
│       │       └── main.yml
│       └── nginx
│           ├── README.md
│           ├── defaults
│           │   └── main.yml
│           ├── handlers
│           │   └── main.yml
│           ├── meta
│           │   └── main.yml
│           ├── tasks
│           │   ├── configure_nginx.yml
│           │   ├── install_packages.yml
│           │   └── main.yml
│           ├── templates
│           │   └── mysite.j2
│           ├── tests
│           │   ├── inventory
│           │   └── test.yml
│           └── vars
│               └── main.yml
├── hosts_file
└── install_CVV-stack.ps1

33 directories, 56 files
```

If you have successfully installed the necessary tools listed above, then you can proceed to the first lab below 👇.

## Ansible Lab 1 - Installation and Inventory file basics

Every beginning is difficult, and I hope you made it with the installations. The first lab is intended to set up the vagrant infrastructure you'll need to learn Ansible.

![Ansible_lab](https://git.davchev.com/DevOps_Academy/ansible-labs/media/branch/master/ansible-lab.jpg "Ansible-Lab")

As shown in the image above, our Ansible control will come from ansible-control through which we will be able to ssh and orchestrate the other machines.

### 1. Create the Vagrantfile

In this document, we will go slowly and create all the files and configurations in order. We will start with the Vagrant file. Create file named Vagrantfile with:

```shell
touch Vagrantfile
```
Then edit with your favorite editor such as vim, nano etc.
The code shown below is located in the <code>Vagrantfile</code> and is intended to provision the virtual machines we will need for these labs.

```shell
Vagrant.configure("2") do |config|
  # Define an array of servers with their respective hostname, IP address, and SSH port
  servers=[
    {
      :hostname => "loadbalancer",
      :box => "ubuntu/jammy64",
      :ip => "192.168.7.101",
      :ssh_port => '2341'
    },
    {
      :hostname => "db01",
      :box => "ubuntu/jammy64",
      :ip => "192.168.7.102",
      :ssh_port => '2342'
    },
    {
      :hostname => "web01",
      :box => "ubuntu/jammy64",
      :ip => "192.168.7.103",
      :ssh_port => '2343'
    },
    {
      :hostname => "web02",
      :box => "ubuntu/jammy64",
      :ip => "192.168.7.104",
      :ssh_port => '2344'
    },
    {
      :hostname => "ansible-control",
      :box => "ubuntu/jammy64",
      :ip => "192.168.7.105",
      :ssh_port => '2345'
    }
  ]

  # Loop through each machine in the servers array
  servers.each do |machine|
    # Define a Vagrant machine with the specified hostname
    config.vm.define machine[:hostname] do |node|
      # Set the Vagrant box to use
      node.vm.box = machine[:box]
      # Set the hostname of the virtual machine
      node.vm.hostname = machine[:hostname]

      # Configure a public network interface using the specified bridge interface
      node.vm.network :public_network, bridge: "enp0s8: Wi-Fi (AirPort)"
      # Configure a private network interface with the specified IP address
      node.vm.network :private_network, ip: machine[:ip]
      # Forward the host's SSH port to the guest machine
      node.vm.network "forwarded_port", guest: 22, host: machine[:ssh_port], id: "ssh"

      # Provision the machine with a shell script to modify the SSH configuration
      config.vm.provision "shell", inline: <<-SHELL
        sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
        systemctl restart sshd.service
      SHELL

      # Customize the VirtualBox provider settings for the machine
      node.vm.provider :virtualbox do |v|
        # Set the amount of memory to allocate to the machine
        v.customize ["modifyvm", :id, "--memory", 512]
        # Set the number of CPUs to allocate to the machine
        v.customize ["modifyvm", :id, "--cpus", 1]
        # Set the name of the virtual machine
        v.customize ["modifyvm", :id, "--name", machine[:hostname]]
        # Set the graphics controller to use
        v.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
        # Enable DNS resolution for NAT connections
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      end
    end
  end
end

```

This Vagrantfile defines an array of servers with their respective hostname, IP address, and SSH port. It then loops through each machine in the array and defines a Vagrant machine with the specified hostname, box, and network settings.

The network settings for each machine include a public network interface.

### 2. Create VMs using vagrant and ssh to our control server

  The following commands will setup Vagrant and connect to ansible-control server

     vagrant up --provider virtualbox
     vagrant ssh ansible-control


### 3. Create the /vagrant/hosts_file

  With the executed commands, create the /vagrant/hosts_file file:

     nano /vagrant/hosts_file

  Import the following content and save the file:

     192.168.7.101 loadbalancer
     192.168.7.102 db01
     192.168.7.103 web01
     192.168.7.104 web02
     192.168.7.105 ansible-control


### 4. Copy /vagrant/hosts_file to /etc/hosts

  The below command will copy hosts file on ansible-control

    sudo cp /vagrant/hosts_file /etc/hosts


### 5. Install Ansible

  Since we are now connected to the ansible-control machine we can install Ansible with:

     sudo apt update
     sudo apt install ansible -y


### 6. Create an inventory file named hosts

  Create the directory structure for the labs with the command:

    mkdir ansible-lab{1..5}

  Create the hosts file with the command:

    nano /vagrant/ansible-lab1/hosts

  add the following content:

    [control]
    ansible-control

    [proxy]
    loadbalancer

    [webservers]
    web01
    web02

    [database]
    db01

    [webstack:children]
    proxy
    webservers
    database

  With this command you will copy the pre-defined hosts file:

    sudo cp /vagrant/ansible-lab1/hosts /home/vagrant/hosts


### 7. Test out a command

  Now it is time to test if the setup works. You can do that we the following ad-hoc commands:

     ansible localhost -m command -a hostname
     ansible localhost -m command -a date

### 8. Generate SSH Keys and copy to hosts

  Run the below commands to create a SSH key and copy to all servers

     ssh-keygen
     ssh-copy-id localhost
     ssh-copy-id web01 && ssh-copy-id web02 && ssh-copy-id loadbalancer && ssh-copy-id db01

   > **_NOTE:_** Type yes to confirm and If it prompt for password it is the SSH pass which is: <code>vagrant</code>

### 9. Test running ad-hoc commands to all hosts

  Now we can run an ad-hoc command to the webstack group that we created and set

    ansible webstack -i /home/vagrant/hosts -m command -a hostname

You just set up a hostfile, installed ansible on ansible-control, generated an ssh key, and copied it to all virtual machines. Well done, your lab infrastructure is ready now.

## Ansible Lab 2 - Ad HOC tasks and Modules

### This lab is intended to introduce ad hoc tasks and modules

First you can sync the current ansible-lab state to the newly create lab structure:

    rsync -WaP /vagrant/ansible-lab1/ /vagrant/ansible-lab2/
    cd /vagrant/ansible-lab2/

and move to the second lab directory.

An Ansible ad hoc command uses the /usr/bin/ansible command-line tool to automate a single task on one or more managed nodes. ad hoc commands are quick and easy, but they are not reusable. 
So why learn about ad hoc commands? ad hoc commands demonstrate the simplicity and power of Ansible. The concepts you learn here will port over directly to the playbook language.

### 1. Ansible ad hoc command for checking the uptime of the hosts

  In this example, we are going to know the uptime of the hosts. Ansible provides two major modules to run the command over the host group or on the remote server.

  Which one to pick is not a big confusion if you know what are they and their capabilities.
  Here are the commands you can use to get the uptime. All three commands would yield you the same results.

    ansible all -i /home/vagrant/hosts -m command -a uptime
    ansible all -i /home/vagrant/hosts -m shell -a uptime
    ansible all -i /home/vagrant/hosts -a uptime

  as you could have already figured out -m is the module and -a should contain the command it should run which goes as an argument to command and shell.

### 2. Check the free memory or memory usage of  hosts using ansible ad hoc command

  The following ansible ad hoc command would help you get the free memory of all the hosts in the host groups.

  As you could see we are running the free -m command on the remote hosts and collecting the information.

    ansible all -a "free -m" -i /home/vagrant/hosts


### 3. Update and upgrade all machines

  Now that you're comfortable with a few ad hoc commands, you can move on to updating and upgrading your infrastructure. Because it's always good to be on the latest and greatest versions.

    ansible all -i /home/vagrant/hosts -m command -a 'sudo apt update'
    ansible all -i /home/vagrant/hosts -m command -a 'sudo apt upgrade -y'


### 4. Use APT module to install services

  In the next example, we will use the APT module. With it, we will install an Apache web server in the webservers group and a MySQL server in the database group.

  The important thing to note is that the packages will only be installed in the specific group that is specified in the command itself. If all is used, then that command will be executed on all defined machines.
    
    ansible all -i /home/vagrant/hosts --become -m apt -a "update_cache=yes"
    ansible all -i /home/vagrant/hosts --become -m apt -a "name=swapspace state=present"
    ansible all -i /home/vagrant/hosts --become -m apt -a "name=net-tools state=present"
    ansible webservers -i /home/vagrant/hosts --become -m apt -a "name=apache2 state=present"
    ansible database -i /home/vagrant/hosts --become -m apt -a "name=mysql-server state=present"

  For more examples and info you can also look at the official documentation: https://docs.ansible.com/ansible/latest/modules/apt_module.html

### 5. Use service module to manage services

  The service module is quite useful for checking the status, or restarting all services. In the next two examples, you will learn how to check if your MySQL server is active and running and then restart it.
    
    ansible database -i /home/vagrant/hosts -m service -a "name=mysql state=started"
    ansible database --become -i /home/vagrant/hosts -m service -a "name=mysql state=restarted"

  You can also check the documentation at: https://docs.ansible.com/ansible/latest/modules/service_module.html

### 6. Use ansible to reboot webstack

  By executing the following ad hoc command, you will restart the virtual machines from the webstack group.

    ansible webstack -i /home/vagrant/hosts --become -a "reboot --reboot"

  It is quite normal to receive a message "Failed to connect to the host via ssh: System is going down" because after executing the command our connection is interrupted because the machine itself is restarted.

These few examples were just an introduction to what can be done with Ansible and ad hoc commands.

Feel free to check out the official documentation for this at: https://docs.ansible.com/ansible/latest/command_guide/intro_adhoc.html

## Ansible Lab 3 - Playbooks, Templates and Handlers

Now, sync the current ansible-lab state to the newly create lab structure:

    rsync -WaP /vagrant/ansible-lab2/ /vagrant/ansible-lab3/
    cd /vagrant/ansible-lab3/

and move to the third lab directory.

In this lab, we will define playbook named playbook1.yml that is intended for installing the Apache2 web server.
With this playbook, we will try several scenarios to see how a YAML file is structured in which variables, tasks, and handlers are defined. Jinja templates (web template engine for Python) are used, which we will copy to your web01 and web02, that is, to the group of webservers.

### 1. Exam the playbook and look over the details of the YAML file

  Navigate to ansible-lab3 with the following command:

    cd /vagrant/ansible-lab3/

  Create the playbook with:

    nano playbook1.yml

  Add the following:

```shell
---
# This playbook is written in YAML and is used to automate the deployment of an Apache web server on a group of hosts. The playbook does the following:

# The hosts section specifies the group of hosts on which the playbook will be executed. In this case, it is set to "webservers", meaning the playbook will be executed on all the hosts in the "webservers" group.
# The become section is set to "yes", meaning that the playbook will run with administrative privileges.
# The vars section defines three variables: http_port, https_port, and html_welcome_msg. These variables can be used in the playbook to configure the Apache web server.
- hosts: webservers
  become: yes
  vars:
    http_port: 8000
    https_port: 4443
    html_welcome_msg: "Hello Scalefocus Academy!"
# The tasks section contains a list of tasks that the playbook will execute.
# The first task "ensure apache is at the latest version" uses the apt module to update the Apache2 package to the latest version.
  tasks:
  - name: ensure apache is at the latest version
    apt:
      name: apache2
      state: latest
# The second task "write the apache2 ports.conf config file" uses the template module to generate a configuration file for Apache. This configuration file (ports.conf) will specify the ports that Apache should listen on. The template for the file is stored in the "templates" directory and has a .j2 file extension, indicating that it is a Jinja2 template. The template file will be written to the "/etc/apache2/ports.conf" location on the target host.
  - name: write the apache2 ports.conf config file
    template:
      src: templates/ports.conf.j2
      dest: /etc/apache2/ports.conf
    notify:
    - restart apache
# The third task "write a basic index.html file" uses the template module to generate a basic HTML file that will be served by the Apache web server. The template for the file is stored in the "templates" directory and has a .j2 file extension. The template file will be written to the "/var/www/html/index.html" location on the target host.
  - name: write a basic index.html file
    template:
      src: templates/index.html.j2
      dest: /var/www/html/index.html
    notify:
    - restart apache
# The fourth task "ensure apache is running" uses the service module to start the Apache2 service if it is not already running.
  - name: ensure apache is running
    service:
      name: apache2
      state: started
# The handlers section contains a single handler "restart apache" that uses the service module to restart the Apache2 service. This handler is notified by the second and third tasks to restart the Apache service whenever a change is made to the ports.conf or index.html files.
  handlers:
    - name: restart apache
      service:
        name: apache2
        state: restarted
      listen: "restart apache"
```
    
    As you can see, there are comments left on the playbook itself explaining all the components and tasks in the playbook.

### 2. Check the Templates

  Two Jinja templates have been added to the playbook1.yml file, which you should create abd look at before running this playbook.

    mkdir /vagrant/ansible-lab3/templates
    touch /vagrant/ansible-lab3/templates/index.html.j2
    touch /vagrant/ansible-lab3/templates/ports.conf.j2

  creat and edit the index.html.j2

    nano /vagrant/ansible-lab3/templates/index.html.j2

  add the following HTML content:

    <html>

    <h1>{{ html_welcome_msg }} You have reached the {{ansible_facts['nodename']}} server.</h1>

    </html>

  creat and edit the index.html.j2

    nano /vagrant/ansible-lab3/templates/ports.conf.j2

  add the following Apache2 configuration file:

    # If you just change the port or add more ports here, you will likely also
    # have to change the VirtualHost statement in
    # /etc/apache2/sites-enabled/000-default.conf

    Listen {{ http_port }}

    <IfModule ssl_module>
            Listen {{ https_port }}
    </IfModule>

    <IfModule mod_gnutls.c>
            Listen {{ https_port }}
    </IfModule>

    # vim: syntax=apache ts=4 sw=4 sts=4 sr noet


  The <code>index.html.j2</code> is a simple HTML file with a message defined in the playbook.
  The <code>ports.conf.j2</code> template is intended as a configuration file for your new Apache servers. That is, it defines the HTTP and HTTPS ports of this service.

### 3. Run the playbook

  Now that we know what the playbook does, it's time to run it. This time we will use the ansible-playbook instead of ansible as before.

    ansible-playbook -i /home/vagrant/hosts playbook1.yml


### 4. Test connectivity to servers

  In this situation, it is best to use the curl command to check if your newly installed Apache servers are available and responsive with the templates you added.

    curl web01:8000
    curl web02:8000

In summary, this playbook will deploy an Apache web server on a group of hosts and configure it to listen on the specified ports and serve a basic HTML welcome message.

## Ansible Lab 4 - Re-usable playbooks, import_tasks, Roles and Ansible Galaxy

Now, sync the current ansible-lab state to the newly create lab structure:

    rsync -WaP /vagrant/ansible-lab3/ /vagrant/ansible-lab4/
    cd /vagrant/ansible-lab4/

and move to the fourth lab directory.

We are going to take the playbook that we are working on and sort of enhance it and make it a lot leaner. We can see that we're getting a lot of code in it and we only have our web servers set up yet. 

### 1. Re-usable playbooks, import_tasks

Therefore following the best practices we will rewrite the code from our defined playbook1.yml from ansible-lab3 by doing the following:

1. We will move tasks to a tasks subfolder

Create new directory tasks and new yml file apache2_install.
Then edit the playbook1.yml and move the tasks code to the newly created file.

```shell
mkdir tasks ; touch tasks/apache2_install.yml
```

2. Move handler to handler subfolder

Do the same as the tasks.

```shell
mkdir handlers ; touch handlers/main.yml
```

After we move around our code, we will use the import_tasks with the path of our new files. It should looks like this:

```shell
- hosts: webservers
  become: yes
  vars:
    http_port: 8000
    https_port: 4443
    html_welcome_msg: "Hello Scalefocus Academy!"
  tasks:
  - import_tasks: tasks/apache2_install.yml

  handlers:
  - import_tasks: handlers/main.yml
```

3. Run the playbook (optional for a test)

``` shell
ansible-playbook -i hosts -K playbook1.yml
```
If everything was green, then we can move on to one more topic in this lab, Ansible Roles and Ansible Galaxy.

### 2. Ansible Roles and Ansible Galaxy
---
Ansible Roles are a way to organize your playbooks and tasks into reusable units. A role is essentially a collection of related tasks, files, templates, and variables that can be easily shared and used across multiple playbooks.

Roles are useful for several reasons:

1. Reusability: You can use roles in multiple playbooks and projects, which saves time and effort.

2. Modularity: Roles make it easy to break down complex playbooks into smaller, more manageable units.

3. Organization: Roles provide a structured way to organize your playbooks and tasks, which makes it easier to understand and maintain them.

4. Collaboration: Roles can be shared with other teams or the community, which fosters collaboration and sharing of best practices.
---
In short, Ansible Roles provide a way to organize and reuse your Ansible code, making it more efficient, modular, and maintainable.

[ansible-galaxy](https://galaxy.ansible.com) is a repository of reusable Ansible roles and collections that are contributed by the community. It provides a central location where Ansible users can search for, download, and use existing roles, rather than starting from scratch.

Using Ansible Galaxy is straightforward. You can search for roles and collections on the Ansible Galaxy website, or you can use the ansible-galaxy command-line tool to search, download, and install roles and collections.

Overall, Ansible Galaxy provides a convenient and efficient way to find, share, and use Ansible roles and collections, making it an essential resource for any Ansible user.

Since our current status is to use imported tasks, the next step is to familiarize ourselves with the roles. The current tree in our directory on this point is the following:

``` shell
vagrant@ansible-control:/vagrant/ansible-lab4$ tree
.
├── README.md
├── handlers
│   └── main.yml
├── hosts
├── playbook1.yml
├── tasks
│   └── apache2_install.yml
└── templates
    ├── index.html.j2
    └── ports.conf.j2

3 directories, 7 files
```

Our goal is to change our playbook1.yml so it uses the Role functionality to setup apache2. We will proceed with the following:

1. Use ansible-galaxy to create Apache2 webserver role scaffolding
``` shell
cd /vagrant/ansible-lab4/
ansible-galaxy init roles/apache2
```
2. Move the tasks to the roles\webserver folder
``` shell
mv tasks/apache2_install.yml roles/apache2/tasks/
mv handlers/main.yml roles/apache2/handlers/main.yml
mv templates/ roles/apache2/
rmdir tasks/ handlers/
```
edit the <code>roles/apache2/tasks/main.yml</code> and add the following:
``` shell
---
# tasks file for roles/webservers
- include: apache2_install.yml
```
there is one more thing to do and that is to edit the current state of our playbook1.yml. We will change the task to roles and the playbook should look like this:

``` shell
- hosts: webservers
  become: yes
  vars:
    http_port: 8000
    https_port: 4443
    html_welcome_msg: "Hello Scalefocus Academy!"
  roles:
    - apache2
```

So far we created Apache2 Role, and move tasks/handlers/templates to new roles/apache2 structure. Modified the <code>roles/apache2/tasks/main.yml</code> and <code>playbook1.yml</code>. After these changes, our directory structure will look like this:

``` shell
vagrant@ansible-control:/vagrant/ansible-lab4$ tree
.
├── README.md
├── hosts
├── playbook1.yml
└── roles
    └── apache2
        ├── README.md
        ├── defaults
        │   └── main.yml
        ├── handlers
        │   └── main.yml
        ├── meta
        │   └── main.yml
        ├── tasks
        │   ├── apache2_install.yml
        │   └── main.yml
        ├── templates
        │   ├── index.html.j2
        │   └── ports.conf.j2
        ├── tests
        │   ├── inventory
        │   └── test.yml
        └── vars
            └── main.yml

9 directories, 14 files
```

3. Run the playbook
``` shell
ansible-playbook -i hosts -K playbook1.yml
```
Next, let's create another role with name 'common' and add it to 'web', 'loadbalancer' and 'database' servers.

4. Use ansible-galaxy to create 'common' and nginx role scaffolding
``` shell
ansible-galaxy init roles/common
ansible-galaxy init roles/nginx
```

5. Setup 'common' role tasks/main.yml and tasks/install_tools.yml

Let's define the task for our new 'common' role:
``` shell
nano roles/common/tasks/install_tools.yml
```
add the following:
``` shell
- name: "Install Common packages"
  apt: name={{ item }} state=latest
  with_items:
   - net-tools
   - tree
   - python3-pip

- name: Install pymysql python package
  pip:
    name: pymysql
```
after the creation of this task, we will add an include in the main.yml task:
``` shell
nano roles/common/tasks/main.yml
```
and enter the include:
``` shell
---
# tasks file for roles/common
- include: install_tools.yml
```

6. Setup the nginx role

Let's create the tasks files:

``` shell
nano roles/nginx/tasks/install_packages.yml
```

import the following and save the file:

``` shell
- name: "Install Nginx packages"
  apt:
    name: nginx
    state: present
```
another task to configure the Nginx:

``` shell
nano roles/nginx/tasks/configure_nginx.yml
```
add the content:

``` shell
- name: Deploy Nginx sites configuration
  template: src=mysite.j2 dest="/etc/nginx/sites-enabled/mysite"
  notify: restart nginx

- name: Remove defaults
  file: path="/etc/nginx/sites-enabled/default" state=absent
```
and let's include the new tasks that we just created into the main.yml:

``` shell
nano roles/nginx/tasks/main.yml
```
add the following:
``` shell
---
# tasks file for roles/nginx
- include: install_packages.yml
- include: configure_nginx.yml
```
Save.

Next is to configure the template and the handler:

``` shell
mkdir roles/nginx/templates
nano roles/nginx/templates/mysite.j2
```
paste the following:

``` shell
    upstream webservers {
        server 192.168.7.103:8000;
        server 192.168.7.104:8000;
    }

    server {
        listen 80;

        location / {   
                proxy_pass http://webservers;
        }
    }
```
Let's configure the Nginx handler so we can try what we've done.

``` shell
nano roles/nginx/handlers/main.yml
```

add the following code that will restart the Nginx:

``` shell
---
# handlers file for roles/nginx
- name: restart nginx
  service: name=nginx state=restarted
```
Finally, let's update the playbook1.yml file:

``` shell
# This playbook consists of two plays. 
# The first play targets the hosts with the tag "webservers".
- hosts: webservers
  become: yes
  vars:
    http_port: 8000
    https_port: 4443
    html_welcome_msg: "Hello Scalefocus Academy!"
  roles:
    - common
    - apache2
# The second play targets the hosts with the tag "proxy". 
- hosts: proxy
  become: yes
  roles:
    - common
    - nginx
```

Huh done. For now, we've configured the new roles and before we try our updated two-part playbook, our directory structure looks like this:

``` shell
vagrant@ansible-control:/vagrant/ansible-lab4$ tree
.
├── README.md
├── hosts
├── playbook1.yml
└── roles
    ├── apache2
    │   ├── README.md
    │   ├── defaults
    │   │   └── main.yml
    │   ├── handlers
    │   │   └── main.yml
    │   ├── meta
    │   │   └── main.yml
    │   ├── tasks
    │   │   ├── apache2_install.yml
    │   │   └── main.yml
    │   ├── templates
    │   │   ├── index.html.j2
    │   │   └── ports.conf.j2
    │   ├── tests
    │   │   ├── inventory
    │   │   └── test.yml
    │   └── vars
    │       └── main.yml
    ├── common
    │   ├── README.md
    │   ├── defaults
    │   │   └── main.yml
    │   ├── handlers
    │   │   └── main.yml
    │   ├── meta
    │   │   └── main.yml
    │   ├── tasks
    │   │   ├── install_tools.yml
    │   │   └── main.yml
    │   ├── tests
    │   │   ├── inventory
    │   │   └── test.yml
    │   └── vars
    │       └── main.yml
    └── nginx
        ├── README.md
        ├── defaults
        │   └── main.yml
        ├── handlers
        │   └── main.yml
        ├── meta
        │   └── main.yml
        ├── tasks
        │   ├── configure_nginx.yml
        │   ├── install_packages.yml
        │   └── main.yml
        ├── templates
        │   └── mysite.j2
        ├── tests
        │   ├── inventory
        │   └── test.yml
        └── vars
            └── main.yml

24 directories, 34 files
```

7. Run the playbook and test

``` shell
ansible-playbook -i hosts -K playbook1.yml
```

If everything is as it should be, we will get the desired yellow color.

```ansible
PLAY RECAP *********************************************************************************************************************************************************************************
loadbalancer               : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
web01                      : ok=6    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
web02                      : ok=6    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
Also I you can test the Nginx Loadbalancer with the following command:
```shell
for i in {1..10}; do curl loadbalancer; done
```
You should get an interesting result :) 

# Ansible Lab 5 - Variables, Ansible Vault

Before we make any changes sync the current ansible-lab state to the newly create lab structure:

    rsync -WaP /vagrant/ansible-lab4/ /vagrant/ansible-lab5/
    cd /vagrant/ansible-lab5/

and move to the fifth lab directory.

In this lab, we can add the MySQL role and get a database up and running, with the appropriate configuration.

1. Create mysql role using ansible-galaxy.
```shell
ansible-galaxy init roles/mysql
```
2. Create tasks, handlers and templates for new mysql role.

We will create the installation task:
```shell
nano roles/mysql/tasks/install_mysql.yml
```
and enter the following:
```shell
- name: Install MySQL server
  apt:
    name: mysql-server
    update_cache: yes

- name: Installing python module MySQL-python
  pip:
    name: PyMySQL

- name: Ensure mysql-server is running
  service:
    name: mysql
    state: started
```
We will create the configuration tasks:
```shell
nano roles/mysql/tasks/setup_mysql.yml
```
and paste:
```shell
- name: Create my.cnf configuration file
  template: src=templates/my.cnf.j2 dest=/etc/mysql/conf.d/mysql.cnf
  notify: restart mysql

- name: Configure MySQL server to listen on all interfaces
  lineinfile:
    path: /etc/mysql/mysql.conf.d/mysqld.cnf
    regexp: '^bind-address'
    line: 'bind-address = 0.0.0.0'
  notify:
    - restart mysql

- name: Configure MySQL root password
  mysql_user:
    login_user: root
    login_password: "{{ mysql_root_password }}"
    user: root
    password: "{{ mysql_root_password }}"
    host_all: yes
    host: "%"
    update_password: always
    login_unix_socket: /var/run/mysqld/mysqld.sock

- name: Restart the mysql-server
  service:
    name: mysql
    state: restarted

- name: "Create new database {{ mysql_database }}"
  mysql_db:
    name: "{{ mysql_database }}"
    state: present
    login_user: root
    login_password: "{{ mysql_root_password }}"

- name: "Create new user {{ mysql_user }} with all database privileges"
  mysql_user:
    name: "{{ mysql_user }}"
    password: "{{ mysql_password }}"
    priv: "{{ mysql_database }}.*:ALL"
    host: '%'
    state: present
    login_user: root
    login_password: "{{ mysql_root_password }}"

```
After we define the MySQL role tasks we need to import them in the main.yml file:

```shell
nano roles/mysql/tasks/main.yml
```
and include the created files:
```shell
---
# tasks file for roles/mysql
- include: install_mysql.yml
- include: setup_mysql.yml
```
Next is the template config:
```shell
mkdir roles/mysql/templates
nano roles/mysql/templates/my.cnf.j2
```
paste the following:
```shell
[mysql]    
bind-address = 0.0.0.0
```
Finally, create the restart handler:
```shell
nano roles/mysql/handlers/main.yml
```
insert the following code:
```shell
---
# handlers file for roles/mysql
- name: restart mysql
  service:
    name: mysql
    state: restarted
  listen: "restart mysql"
```
3. Set our vars and encrypt the important data

In this step, we will move the variables that were declared in the playlist itself to a separate directory and encrypt the MySQL password with the Ansible vault.

```shell
mkdir vars
nano vars/main.yml
```
add the variables:
```shell
---
http_port: 8000
https_port: 4443
html_welcome_msg: "Hello Scalefocus Academy!"
mysql_user: simple_user
mysql_password: "{{ vaultMySqlPassword }}"
mysql_root_password: "{{ vaultMySqlRootPassword }}"
```

As you can notice <code>mysql_password</code> is declared as a variable. That's because we have the plan to protect and encrypt it with Ansible Vault. For that, we will create another file:

```shell
nano vars/vault.yml
```
the info inside should look similar to this:

```shell
vaultMySqlPassword: "secretMySQLPassword"
vaultMySqlRootPassword: "secretRootMySQLPassword"
```
after you save the file you can encrypt by using the ansible-vault command:
```shell
ansible-vault encrypt vars/vault.yml
```
it will prompt you for an encryption password, so make sure you know what you enter.

You can always check the official documentation for more examples and info:
https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html

4. Modify the playbook1.yml and add our new play

```shell
nano playbook1.yml
```

after adding the third play the playbook should look like this:

```shell
- hosts: webservers
  become: yes
  vars_files:
    - vars/main.yml
  roles:
    - common
    - apache2

- hosts: proxy
  become: yes
  roles:
    - common
    - nginx

- hosts: database
  become: yes
  vars_files:
    - vars/main.yml
    - vars/vault.yml
  vars_prompt:
    - name: mysql_database
      prompt: Please enter the database name
      private: no
  roles:
    - common
    - mysql
```

5. Run playbook

Now, it is time to run our playbook1.yml and see if our MySQL server is provisioned and setup correctly.
```shell
ansible-playbook -i /home/vagrant/hosts -K playbook1.yml --ask-vault-password
```

6. Test a mysql connection to database

Connect to the remote server with the following command and verify that the user simple_user has been created:

```shell
mysql -h 192.168.7.102 -u simple_user -p
```
type the simple_user password. When it connects to the mysql shell list the databases to verify that the database is created.
```mysql
mysql> show databases;
```

## If it works as expected, then CONGRATULATIONS!

---
# Project idea: Deploying a web application with Ansible
As I announced, a small project with several conditions:

### Project requirements:

* You will need to write an Ansible playbook that deploys a web application to both the development and production stages.
* The playbook should use Ansible roles to organize the tasks required to deploy the web application.
* The playbook should use Ansible vault to store sensitive data, such as passwords and API keys.
* The playbook should use separate inventory files for the development and production stages, which will contain the IP addresses or hostnames of the servers in each stage.
* The playbook should use conditional statements to determine which tasks should be run based on the stage (development or production).
* The playbook should use Jinja2 templates to generate configuration files for the web application.
* The playbook should use handlers to restart the web server after configuration changes have been made.

### Sample project outline:

1. Create an inventory file for the development stage.
2. Create an inventory file for the production stage.
3. Create a playbook that includes the following tasks:
  - Use Ansible vault to encrypt sensitive data.
  - Install required software packages on the servers.
  - Configure the web server with the appropriate settings for the stage.
  - Generate configuration files for the web application using Jinja2 templates.
  - Restart the web server if configuration changes were made using handlers.
4. Create an Ansible role for the web server configuration.
5. Create an Ansible role for the database configuration (if applicable).
6. Create an Ansible role for the deployment of the web application.
7. Use conditional statements in the playbook to determine which tasks should be run based on the stage.
8. Test the playbook on the development stage.
9. Deploy the web application to the production stage.
10. Test the playbook on the production stage.

I hope this gives you an idea of what you can do for your project. Good luck with it!