---
- name: Create EC2 with required configuration
  hosts: localhost
  gather_facts: false
  vars_files:
    - vars.yml

  tasks:
    - name: Create security group
      amazon.aws.ec2_group:
        name: "{{ security_group_name }}"
        description: "Allow SSH, HTTP, HTTPS"
        region: "{{ region }}"
        rules:
          - proto: tcp
            from_port: 22
            to_port: 22
            cidr_ip: 0.0.0.0/0
          - proto: tcp
            from_port: 80
            to_port: 80
            cidr_ip: 0.0.0.0/0
          - proto: tcp
            from_port: 443
            to_port: 443
            cidr_ip: 0.0.0.0/0
        rules_egress:
          - proto: -1
            cidr_ip: 0.0.0.0/0

    - name: Create EC2 key pair
      amazon.aws.ec2_key:
        name: "{{ key_name }}"
        region: "{{ region }}"
        state: present
      register: keypair

    - name: Save private key
      copy:
        content: "{{ keypair.key.private_key }}"
        dest: "./{{ key_name }}.pem"
        mode: '0400'
      when: keypair.changed

    - name: Launch EC2 instance
      amazon.aws.ec2_instance:
        name: "ansible-ec2"
        key_name: "{{ key_name }}"
        instance_type: "{{ instance_type }}"
        region: "{{ region }}"
        image_id: "{{ ami_id }}"
        security_groups: ["{{ security_group_name }}"]
        block_device_mappings:
          - device_name: /dev/sda1
            ebs:
              volume_size: "{{ disk_size }}"
              volume_type: gp2
        wait: yes
      register: ec2

    - debug:
        msg: "EC2 created: Public IP is {{ ec2.instances[0].public_ip_address }}"
