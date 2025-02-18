# Detection Script for Sweet32 Vulnerability

$CipherKey = "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002"
$SCHANNELKey = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168"
$NonCompliant = $false  # Compliance flag

# Check if the cipher policy key exists
if (Test-Path $CipherKey) {
    $CipherProperties = Get-ItemProperty -Path $CipherKey -ErrorAction SilentlyContinue
    if ($CipherProperties -and $CipherProperties.PSObject.Properties.Name -contains "Functions") {
        $CipherList = $CipherProperties.Functions
        if ($CipherList -match "TLS_RSA_WITH_3DES_EDE_CBC_SHA") {
            Write-Output "❌ Vulnerable cipher found: TLS_RSA_WITH_3DES_EDE_CBC_SHA"
            $NonCompliant = $true
        } else {
            Write-Output "✅ No vulnerable ciphers found in policy."
        }
    } else {
        Write-Output "❌ 'Functions' value is missing in the registry. This may indicate non-compliance."
        $NonCompliant = $true
    }
} else {
    Write-Output "ℹ️ Cipher policy registry key is missing. This does NOT necessarily indicate vulnerability."
}

# Check if the SCHANNEL cipher setting exists
if (Test-Path $SCHANNELKey) {
    $EnabledValue = (Get-ItemProperty -Path $SCHANNELKey -Name Enabled -ErrorAction SilentlyContinue).Enabled
    if ($EnabledValue -eq 1) {
        Write-Output "❌ 3DES cipher is explicitly enabled in SCHANNEL."
        $NonCompliant = $true
    } else {
        Write-Output "✅ 3DES cipher is NOT enabled in SCHANNEL."
    }
} else {
    Write-Output "✅ SCHANNEL registry key for 3DES is missing. This typically means 3DES is disabled."
}

# Return compliance status
if ($NonCompliant) {
    Exit 1  # Non-compliant
}

Write-Output "🎉 System is fully compliant with TLS security requirements."
Exit 0  # Compliant
