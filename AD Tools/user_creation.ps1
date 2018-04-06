#Defind the Variables
$count = 0
$Password = Read-Host -AsSecureString -Prompt 'What is the password'
$Expiration = ""
$Environment = ""
$status = ""

#Try to import the CSV and create the accounts
try {
    Import-Csv '' | ForEach-Object {
    $UserName = $_.Name
    $Expiration = $_.Expiration
    $Description = $_.Description
    $UserPrincipleName = "$UserName@"
        try {
            New-ADUser -Name $UserName -AccountPassword $Password -PassThru -Path '' -AccountExpirationDate $Expiration -Description $Description -GivenName $UserName -Surname $UserName -DisplayName $UserName -SamAccountName $UserName -UserPrincipalName $UserPrincipleName | Enable-ADAccount
            $count += 1
        }
        catch {
            $count = $count
        }
    }
}
catch {
    Write-Object "Error importing CSV"
}

#Determine the environment being run in
if ($env:UserDomain -Match "") {
    $Environment = "Testing Environment"
}
elseif ($env:UserDomain -Match "") {
    $Environment = "Production Environment"
}
else {
    $Environment = "Unknown Environment"
}

#Determine the status
if ($count -eq 0) {
    $status = "There was an error"
}
else {
    $status = "Accounts were created"
}

#Variables for posting to Microsoft Teams
$url = ""
$body = ConvertTo-Json -Depth 4 @{
    title = "Gen Accounts Update"
    text = "$count accounts changed"
    sections = @(
        @{
            activityTitle = "Account Creation"
            activitySubtitle = "$Environment"
            activityText = "$status"
        },
        @{
            title = 'Details'
            facts = @(
                @{
                    name = 'User running script:'
                    value = $env:UserName
                },
                @{
                    name = 'Number of accounts:'
                    value = $count
                },
                @{
                    name = 'Expiration Date:'
                    value = $Expiration
                }
            )
        }
    )
}

#Post to Microsoft Teams
Invoke-RestMethod -Method 'Post' -Uri $url -Body $body -ContentType 'application/json'