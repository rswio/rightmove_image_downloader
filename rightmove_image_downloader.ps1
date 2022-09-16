CLEAR

$url=Read-Host -Prompt 'Input a Right Move URL and press enter'

function GetStringBetweenTwoStrings($openingtag, $closingtag, $html)
{
    $pattern = "$openingtag(.*?)$closingtag"
    $result = [regex]::Match($html,$pattern).Groups[1].Value
    return $result
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
$webreq = Invoke-WebRequest $url
$html=$webreq.Content #| Out-File C:\temp\output.txt

$title=GetStringBetweenTwoStrings -openingtag "<title>" -closingtag "</title>" -html $html
$foldername="$((Get-Date).ToString('yyyyMMdd'))_$($title -replace " ","_")"

Write-Host $foldername

$saveto=".\RIGHTMOVE\$($foldername)"

[System.IO.Directory]::Exists($saveto)
if (!(Test-Path $saveto)) {
  Write-Warning "$saveto does not exist, it will be created now"
  New-Item -Path $saveto -ItemType Directory
}

Write-Host "Title: $title"
Write-Host "URL: $url"

$metatags = ([regex]'<meta property="og:image" ((.|\n|\r)+?)\/>').Matches($html)

[int]$int=1
ForEach ($metatag in $metatags)
{
    $imageurl=(($metatag -replace "`"/>","") -replace "<meta property=`"og:image`" content=`"","")
    Write-Host $imageurl

    Invoke-WebRequest -Uri $imageurl -OutFile "$($saveto)`\Image_$('{0:d2}' -f [int]$int).jpg" -TimeoutSec 1500
    $int++
}
