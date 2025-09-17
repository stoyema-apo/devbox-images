# yaml-language-server: $schema=https://aka.ms/configuration-dsc-schema/0.2
properties:
  configurationVersion: 0.2.0
  assertions:
    - resource: Microsoft.Windows.Developer/OsVersion
        directives:
            description: Verify Windows version
            allowPrerelease: true
        settings:
            minimumVersion: '10.0'
            maximumVersion: '11.0'
  resources:
    # Enable Windows Features for WSL
    - resource: Microsoft.Windows.Developer/WindowsOptionalFeature
      id: enable-wsl
      directives:
        description: Enable Windows Subsystem for Linux
      settings:
        featureName: Microsoft-Windows-Subsystem-Linux
        state: Enabled

    - resource: Microsoft.Windows.Developer/WindowsOptionalFeature
      id: enable-vm-platform
      directives:
        description: Enable Virtual Machine Platform
      settings:
        featureName: VirtualMachinePlatform
        state: Enabled

    # Configure and Install WSL
    - resource: Microsoft.Windows.Developer/PowerShell
      id: setup-wsl
      directives:
        description: Set up WSL and install Ubuntu 24.04
      settings:
        command: |
          # Set WSL default version to 2
          wsl --set-default-version 2

          # Download Ubuntu 24.04
          $url = "https://aka.ms/wslubuntu2404"
          $outputPath = "C:\wsl\ubuntu-24.04.appx"
          
          # Ensure directory exists
          New-Item -Path "C:\wsl" -ItemType Directory -Force
          
          # Download the appx package
          Invoke-WebRequest -Uri $url -OutFile $outputPath -UseBasicParsing
          
          # Install Ubuntu 24.04
          Add-AppxProvisionedPackage -Online -PackagePath $outputPath -SkipLicense
          
          # Clean up
          Remove-Item -Path $outputPath -Force
          Remove-Item -Path "C:\wsl" -Force
          
          # Set Ubuntu 24.04 as default distribution
          wsl --set-default Ubuntu-24.04
          
          # Initialize Ubuntu for system-wide availability
          # Create a script to initialize Ubuntu
          $initScript = @"
          #!/bin/bash
          # Update package list
          apt-get update
          # Upgrade packages
          apt-get upgrade -y
          # Set locale
          locale-gen en_US.UTF-8
          update-locale LANG=en_US.UTF-8
          # Exit
          exit
"@
          
          # Save the initialization script
          $scriptPath = "C:\wsl-init.sh"
          $initScript | Out-File -FilePath $scriptPath -Encoding ASCII
          
          # Register Ubuntu in WSL and run initialization
          wsl --install -d Ubuntu-24.04 --no-launch
          
          # Import and initialize Ubuntu distro for system-wide access
          Write-Host "Initializing Ubuntu 24.04 for system-wide access..."
          
          # Set default user as root for initial setup
          ubuntu2404 config --default-user root
          
          # Run the initialization script
          wsl -d Ubuntu-24.04 -u root bash -c "cat /mnt/c/wsl-init.sh > /root/init.sh && chmod +x /root/init.sh && /root/init.sh"
          
          # Clean up initialization script
          Remove-Item -Path $scriptPath -Force
          
          # Create default user setup script
          $userSetupScript = @"
          #!/bin/bash
          # Add sudo configuration for passwordless operation
          echo "%sudo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/nopasswd
          chmod 440 /etc/sudoers.d/nopasswd
          
          # Create default non-root user with sudo privileges
          useradd -m -G sudo -s /bin/bash ubuntu
          # Set a placeholder password that will be changed on first login
          echo "ubuntu:ubuntu" | chpasswd
          # Force password change on first login
          chage -d 0 ubuntu
          
          # Set ubuntu as default user
          exit
"@
          
          # Save and execute user setup script
          $userScriptPath = "C:\wsl-user-setup.sh"
          $userSetupScript | Out-File -FilePath $userScriptPath -Encoding ASCII
          
          # Run user setup script
          wsl -d Ubuntu-24.04 -u root bash -c "cat /mnt/c/wsl-user-setup.sh > /root/user-setup.sh && chmod +x /root/user-setup.sh && /root/user-setup.sh"
          
          # Clean up user setup script
          Remove-Item -Path $userScriptPath -Force
          
          # Set default user back to ubuntu
          ubuntu2404 config --default-user ubuntu

    # Verify Installation
    - resource: Microsoft.Windows.Developer/PowerShell
      id: verify-wsl
      directives:
        description: Verify WSL and Ubuntu installation
      settings:
        command: |
          # Check WSL status
          $wslStatus = wsl --status
          if ($LASTEXITCODE -ne 0) { throw "WSL is not properly installed" }
          
          # Check Ubuntu installation
          $ubuntuCheck = wsl -l -v | Select-String "Ubuntu-24.04"
          if (-not $ubuntuCheck) { throw "Ubuntu 24.04 is not properly installed in WSL" }
          
          # Verify it's set as default
          $defaultDistro = wsl -l | Select-String "Ubuntu-24.04 (Default)"
          if (-not $defaultDistro) { throw "Ubuntu 24.04 is not set as the default distribution" }
          
          # Verify system access and user setup
          $userCheck = wsl -d Ubuntu-24.04 -u root bash -c "id ubuntu"
          if ($LASTEXITCODE -ne 0) { throw "Default user 'ubuntu' is not properly configured" }
          
          $sudoCheck = wsl -d Ubuntu-24.04 -u root bash -c "grep -q 'nopasswd' /etc/sudoers.d/nopasswd"
          if ($LASTEXITCODE -ne 0) { throw "Sudo configuration is not properly set up" }
