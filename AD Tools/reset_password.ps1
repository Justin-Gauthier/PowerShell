#Define variables
$count = 0
$Password = Read-Host -AsSecureString -Prompt 'What is the password'
$Expiration = ""
$Environment = ""
$status = ""

#Import and interate through the CSV file to update the listed accounts
try {
    Import-Csv '' | ForEach-Object {
    $UserName = $_.Name
    $Expiration = $_.Expiration
        try {
            Set-ADAccountPassword -Identity $UserName -Reset -NewPassword $Password
            Set-ADUser -Identity $UserName -AccountExpirationDate $Expiration
            $count += 1
        }
        catch {
            $count = $count
        }
    }
}
catch {
    Write-Output "Error importing CSV"
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
    $status = "Accounts were updated"
}

#Variables for posting to Microsoft Teams
$url = ""
$body = ConvertTo-Json -Depth 4 @{
    title = "Gen Accounts Update"
    text = "$count accounts changed"
    sections = @(
        @{
            activityTitle = "Password Reset"
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