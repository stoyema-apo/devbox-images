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
    # Configure Windows 11 Start Menu and Taskbar
    - resource: Microsoft.Windows.Developer/WindowsRegistry
      id: disable-widgets
      directives:
        description: Disable Windows Widgets
      settings:
        path: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Deskmon
        valueType: DWORD
        valueName: EnableFeeds
        valueData: 0

    - resource: Microsoft.Windows.Developer/WindowsRegistry
      id: disable-search-highlights
      directives:
        description: Disable Search Highlights
      settings:
        path: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search
        valueType: DWORD
        valueName: EnableDynamicContentInWSB
        valueData: 0

    - resource: Microsoft.Windows.Developer/WindowsRegistry
      id: disable-news-interests
      directives:
        description: Disable News and Interests
      settings:
        path: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds
        valueType: DWORD
        valueName: EnableFeeds
        valueData: 0

    - resource: Microsoft.Windows.Developer/WindowsRegistry
      id: disable-taskbar-ads
      directives:
        description: Disable Taskbar Ads
      settings:
        path: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced
        valueType: DWORD
        valueName: ShowSyncProviderNotifications
        valueData: 0

    - resource: Microsoft.Windows.Developer/WindowsRegistry
      id: left-align-start-default
      directives:
        description: Set Start Menu alignment to left (Default User)
      settings:
        path: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced
        valueType: DWORD
        valueName: TaskbarAl
        valueData: 0

    - resource: Microsoft.Windows.Developer/PowerShell
      id: configure-default-user-profile
      directives:
        description: Configure settings in default user profile
      settings:
        command: |
          # Load default user profile registry
          $defaultUserPath = "C:\Users\Default\NTUSER.DAT"
          reg load "HKU\DefaultUser" $defaultUserPath
          
          # Set taskbar alignment to left
          reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /t REG_DWORD /d 0 /f
          
          # Unload default user profile
          reg unload "HKU\DefaultUser"

    - resource: Microsoft.Windows.Developer/WindowsRegistry
      id: disable-explorer-ads
      directives:
        description: Disable Explorer Ads
      settings:
        path: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced
        valueType: DWORD
        valueName: ShowSyncProviderNotifications
        valueData: 0

    - resource: Microsoft.Windows.Developer/WindowsRegistry
      id: disable-suggested-content
      directives:
        description: Disable Suggested Content in Settings
      settings:
        path: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager
        valueType: DWORD
        valueName: SubscribedContent-338393Enabled
        valueData: 0

    - resource: Microsoft.Windows.Developer/WindowsRegistry
      id: disable-content-delivery
      directives:
        description: Disable Content Delivery Manager
      settings:
        path: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent
        valueType: DWORD
        valueName: DisableWindowsConsumerFeatures
        valueData: 1

    - resource: Microsoft.Windows.Developer/PowerShell
      id: configure-additional-settings
      directives:
        description: Configure additional settings in default user profile
      settings:
        command: |
          # Load default user profile registry
          $defaultUserPath = "C:\Users\Default\NTUSER.DAT"
          reg load "HKU\DefaultUser" $defaultUserPath
          
          # Disable Content Delivery Manager features
          reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d 0 /f
          reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "FeatureManagementEnabled" /t REG_DWORD /d 0 /f
          reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f
          reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f
          reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338393Enabled" /t REG_DWORD /d 0 /f
          
          # Unload default user profile
          reg unload "HKU\DefaultUser"
          
          # Set machine-wide policies
          New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Force
          Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord
          
          # Disable Windows Consumer Features globally
          New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force
          Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Value 1 -Type DWord
