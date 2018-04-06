$BarCode = Read-Host "What is the barcode?"

$script:letters = @{
    "01" = "A"
    "02" = "B"
    "03" = "C"
    "04" = "D"
    "05" = "E"
    "06" = "F"
    "07" = "G"
    "08" = "H"
    "09" = "I"
    "10" = "J"
    "11" = "K"
    "12" = "L"
    "13" = "M"
    "14" = "N"
    "15" = "O"
    "16" = "P"
    "17" = "Q"
    "18" = "R"
    "19" = "S"
    "20" = "T"
    "21" = "U"
    "22" = "V"
    "23" = "W"
    "24" = "X"
    "25" = "Y"
    "26" = "Z"
}

function NumericPin {
    switch ($Barcode){
        {$BarCode[10] -eq '5'} {Write-Output "13 Digit, 0 Zeros"}
        {$BarCode[10] -eq '4'} {Write-Output "12 Digit, 1 Zeros"}
        {$BarCode[10] -eq '3'} {Write-Output "11 Digit, 2 Zeros"}
        {$BarCode[10] -eq '2'} {Write-Output "10 Digit, 3 Zeros"}
        {$BarCode[10] -eq '1'} {Write-Output "9 Digit, 4 Zeros"}
    }
}

function AlphanumicPin {
    $firstLetter = $BarCode[9] + $BarCode[10]
    $secondLetter = $BarCode[11] + $BarCode[12]
    $thirdLetter = $BarCode[13] + $BarCode[14]

    $firstLetter = $script:letters[$firstLetter]
    $secondLetter = $script:letters[$secondLetter]
    $thirdLetter = $script:letters[$thirdLetter]
    $PIN = $firstLetter + $secondLetter + $thirdLetter + $BarCode[15..23]
    $PIN = $PIN.replace(' ','')

    Write-Output "First Letter: $firstLetter"
    Write-Output "Second Letter: $secondLetter"
    Write-Output "Third Letter: $thirdLetter"
    Write-Output "PIN: $PIN"
}

switch ($Barcode){
    {$BarCode[9] -eq '9'} {NumericPin -BarCode = $BarCode}
    {$BarCode[9] -ne '9'} {AlphanumicPin -BarCode = $BarCode}
    Default {Write-Warning "Not a recognized format"}
}