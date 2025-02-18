# Detection script for multiple Microsoft Visual C++ Redistributables

# List of Redistributables to check
$VCRedists = @(
    @{Name="Microsoft Visual C++ 2005 Redistributable"; Version="8.0.56336"; Arch="Both"},
    @{Name="Microsoft Visual C++ 2005 Redistributable"; Version="8.0.61001"; Arch="Both"},
    @{Name="Microsoft Visual C++ 2008 Redistributable"; Version="9.0.21022"; Arch="32-Bit"},
    @{Name="Microsoft Visual C++ 2008 Redistributable"; Version="9.0.30729"; Arch="Both"},
    @{Name="Microsoft Visual C++ 2008 Redistributable"; Version="9.0.30729.17"; Arch="Both"},
    @{Name="Microsoft Visual C++ 2008 Redistributable"; Version="9.0.30729.4048"; Arch="Both"},
    @{Name="Microsoft Visual C++ 2008 Redistributable"; Version="9.0.30729.6161"; Arch="32-Bit"},
    @{Name="Microsoft Visual C++ 2010 Redistributable"; Version="10.0.30319"; Arch="32-Bit"},
    @{Name="Microsoft Visual C++ 2010 Redistributable"; Version="10.0.40219"; Arch="Both"},
    @{Name="Microsoft Visual C++ 2012 Redistributable"; Version="11.0.51106"; Arch="32-Bit"},
    @{Name="Microsoft Visual C++ 2012 Redistributable"; Version="11.0.61030"; Arch="Both"},
    @{Name="Microsoft Visual C++ 2013 Redistributable"; Version="12.0.30501"; Arch="64-Bit"},
    @{Name="Microsoft Visual C++ 2013 Redistributable"; Version="12.0.40649"; Arch="Both"},
    @{Name="Microsoft Visual C++ 2013 Redistributable"; Version="12.0.40660"; Arch="Both"},
    @{Name="Microsoft Visual C++ 2013 Redistributable"; Version="12.0.40664"; Arch="Both"}
)

# Get all installed programs from registry
$InstalledPrograms = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
                                       "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" `
                        -ErrorAction SilentlyContinue

# Check for each Redistributable
$Detected = @()
foreach ($Redist in $VCRedists) {
    $EscapedName = [regex]::Escape($Redist.Name)  # Escape special characters like `+`

    $Found = $InstalledPrograms | Where-Object {
        $_.DisplayName -match $EscapedName -and $_.DisplayVersion -eq $Redist.Version
    }

    if ($Found) {
        $Detected += "$($Redist.Name) ($($Redist.Version) $($Redist.Arch))"
    }
}

# Output result for Intune
if ($Detected.Count -gt 0) {
    Write-Output "Detected: $($Detected -join ', ')"
    exit 0  # Detection success
} else {
    Write-Output "No matching Visual C++ Redistributables found."
    exit 1  # Detection failed
}
