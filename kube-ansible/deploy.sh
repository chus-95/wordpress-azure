#!/bin/bash

# Execute Kubernetes deploy playbook
ansible-playbook -i hosts kubernetes_deploy.yml

# Execute app deploy playbook
ansible-playbook -i hosts app_deploy.yml