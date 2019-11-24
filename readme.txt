# Windows fix troubles with Docker (virtualization)
https://docs.docker.com/docker-for-windows/troubleshoot/#virtualization-must-be-enabled

# How to enable Hyper-V on Windows for Docker
https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v

# IF solutions not work with Hyper-V
1. https://stackoverflow.com/questions/39684974/docker-for-windows-error-hardware-assisted-virtualization-and-data-execution-p
2. https://blogs.technet.microsoft.com/canitpro/2015/09/08/step-by-step-enabling-hyper-v-for-use-on-windows-10/


# How to add ssh key pn Windows
https://stackoverflow.com/a/18683544

# Windows auto-launch ssh keys on open GitBash
https://help.github.com/en/github/authenticating-to-github/working-with-ssh-key-passphrases#auto-launching-ssh-agent-on-git-for-windows

# Run laradock commands with "winpty" on the beginning
winpty docker-compose exec mariadb bash

# Windows fix bash error: $'\r': command not found
# One time need to do for file
sed -i 's/\r$//' bash_scripts/composer_dev_install.sh

#Then you can run as usually, but without an error
bash bash_scripts/composer_dev_install.sh
