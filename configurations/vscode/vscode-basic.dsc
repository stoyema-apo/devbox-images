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
    # Install Notepad++
    - resource: Microsoft.WinGet.DSC/WinGetPackage
        id: notepadplus
        directives:
            description: Install Notepad++
            allowPrerelease: false
        settings:
            id: Notepad++.Notepad++
            source: winget
            scope: machine
    # Install VS Code
    - resource: Microsoft.WinGet.DSC/WinGetPackage
        id: vscode
        directives:
            description: Install Visual Studio Code
            allowPrerelease: false
        settings:
            id: Microsoft.VisualStudioCode
            source: winget
            scope: machine
    # Install VS Code Extensions
    - resource: Microsoft.VisualStudio.Code.DSC/Extension
        id: vscode-python
        directives:
            description: Install Python extension for VS Code
            allowPrerelease: false
        settings:
            id: ms-python.python
    - resource: Microsoft.VisualStudio.Code.DSC/Extension
        id: vscode-wsl
        directives:
            description: Install WSL extension for VS Code
            allowPrerelease: false
        settings:
            id: ms-vscode-remote.remote-wsl
