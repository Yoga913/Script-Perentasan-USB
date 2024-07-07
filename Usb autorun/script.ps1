# Mengumpulkan informasi sistem
$system_info = @{
    'OS' = $(Get-CimInstance Win32_OperatingSystem).Caption;
    'Version' = $(Get-CimInstance Win32_OperatingSystem).Version;
    'Architecture' = $(Get-CimInstance Win32_OperatingSystem).OSArchitecture;
    'ComputerName' = $(Get-CimInstance Win32_OperatingSystem).CSName;
    'LastBootTime' = $(Get-CimInstance Win32_OperatingSystem).LastBootUpTime;
    'InstalledUpdates' = $(Get-HotFix | Sort-Object -Property InstalledOn -Descending | Select-Object -First 5).Description;
    'NetworkInfo' = $(Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq $true}).IPAddress;
    'FirewallStatus' = $(Get-NetFirewallProfile | Where-Object { $_.Enabled -eq $true }).Name;
    'UserAccounts' = $(Get-LocalUser | Where-Object { $_.Enabled -eq $true }).Name;
    'RunningProcesses' = $(Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 5).Name;
}

# Menyiapkan teks permintaan untuk API GPT
$prompt_text = "Given the detailed system information: OS: $($system_info.OS), Version: $($system_info.Version), Architecture: $($system_info.Architecture), Computer Name: COMPUTER_NAME_PLACEHOLDER, Last Boot Time: $($system_info.LastBootTime), Installed Updates: $($system_info.InstalledUpdates), Network Info: NETWORK_INFO_PLACEHOLDER, Firewall Status: $($system_info.FirewallStatus), User Accounts: USER_ACCOUNTS_PLACEHOLDER, Running Processes: $($system_info.RunningProcesses), provide a pentesting report identifying potential vulnerabilities in English, formatted in HTML with headers and bullet points for recommendations."

# Menyiapkan array pesan untuk API GPT
$messages = @(
    @{ 'role' = 'system'; 'content' = 'You are analyzing detailed system information for potential vulnerabilities.' },
    @{ 'role' = 'user'; 'content' = $prompt_text }
)

# Menyiapkan header untuk permintaan API GPT
$headers = @{ 
    'Authorization' = 'Bearer YOUR_OPENAI_API_KEY'; 
    'Content-Type' = 'application/json' 
}

# Mengirim permintaan ke API GPT dan menyimpan respons
$response = Invoke-RestMethod -Uri 'https://api.openai.com/v1/chat/completions' -Method POST -Headers $headers -Body (@{ model = 'gpt-3.5-turbo'; messages = $messages } | ConvertTo-Json)

# Membuat konten HTML dari respons API
$htmlContent = @"
<html>
<head>
<title>Perentasan USB Autorun-GPT</title>
<style>
body {font-family: Arial, sans-serif; margin: 40px;}
h2 {color: #333; border-bottom: 2px solid #eee; padding-bottom: 10px;}
h3 {color: #555; margin-top: 20px;}
p, ul {margin-bottom: 20px;}
</style>
</head>
<body>
<h2>Laporan Perentasan</h2>
$($response.choices[0].message.content)
</body>
</html>
"@

# Menyimpan konten HTML ke file di desktop
Set-Content -Path $env:USERPROFILE\Desktop\Pentesting_Report.html -Value $htmlContent

# Mengganti placeholder dengan nilai aktual dan menyimpan kembali file HTML
(Get-Content $env:USERPROFILE\Desktop\Pentesting_Report.html).Replace('COMPUTER_NAME_PLACEHOLDER', $system_info.ComputerName).Replace('NETWORK_INFO_PLACEHOLDER', ($system_info.NetworkInfo -join ', ')).Replace('USER_ACCOUNTS_PLACEHOLDER', ($system_info.UserAccounts -join ', ')) | Set-Content $env:USERPROFILE\Desktop\Pentesting_Report.html
