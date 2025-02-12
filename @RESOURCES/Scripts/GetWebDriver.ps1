﻿###########################################################
#  By Proliantaholic https://proliantaholic.blogspot.com  #
###########################################################

param (
    [string]$ScriptsPath = ".",
    [string]$BrowserType = "Chrome"
)

[Console]::OutputEncoding = [Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$global:ProgressPreference = 'SilentlyContinue'

if (!(Test-Path -Path $ScriptsPath\ObsData\)) {
    mkdir $ScriptsPath\ObsData\ > $null 2>&1
}

$DriverList = @{ 'Chrome' = 'chromedriver'; 'Edge' = 'msedgedriver'; 'Firefox' = 'geckodriver' }
$DriverVersionPattern = "(?<=[d|D]river.)\d+(\.\d+)+ "
if ($DriverExists = Test-Path -Path "$ScriptsPath\ObsData\$($DriverList[$BrowserType]).exe") {
    $DriverVersion = & $ScriptsPath\ObsData\$($DriverList[$BrowserType]).exe -V
    $DriverVersion = [regex]::Match($DriverVersion, $DriverVersionPattern).captures.groups[0].value
}

$SeleniumDLLExists = Test-Path -Path $ScriptsPath\ObsData\WebDriver.dll

switch ($BrowserType) {
    "Chrome" {
        $ErrorActionPreference = "Stop"
        try {
            $VerMajor = (Get-Item ([regex]::Replace((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe').'(default)','(\\Chrome.*\\Application)','\Chrome\Application'))).VersionInfo.ProductVersion -replace '^(.+?)\..*$', '$1'
            $BrowserExists = $True
        }
        catch {
            Write-Host "ChromeNotFound"
            Exit
        }
        $ErrorActionPreference = "Continue"
        break
    }
    "Edge" {
        $ErrorActionPreference = "Stop"
        try {
            $VerMajor = (Get-Item ([regex]::Replace((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe').'(default)','(\\Edge.*\\Application)','\Edge\Application'))).VersionInfo.ProductVersion -replace '^(.+?)\..*$', '$1'
            $BrowserExists = $True
        }
        catch {
            Write-Host "EdgeNotFound"
            Exit
        }
        $ErrorActionPreference = "Continue"
        break
    }
    "Firefox" {
        $ErrorActionPreference = "Stop"
        try {
            $VerFirefox = (Get-Item (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe').'(Default)').VersionInfo.ProductVersion -replace '^(.+?)\..*$', '$1'
            $BrowserExists = $True
        }
        catch {
            Write-Host "FirefoxNotFound"
            Exit
        }
        $ErrorActionPreference = "Continue"
        break
    }
    default {
        # 不支援的瀏覽器
        Write-Host "BrowserNotFound"
        Exit
    }
}

if (!(Test-Connection 8.8.8.8 -Quiet) 2>$null) {
    # 網路連線異常
    if ($BrowserExists -and $DriverExists -and $SeleniumDLLExists) {
        Write-Host "Skip"
    }
    else {
        Write-Host "Stop"
    }
    Exit
}

switch ($BrowserType) {
    "Chrome" {
        # Chrome WebDriver
        $ChromeURL = "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json"
        if ($DriverExists) {
            try {
                $data = Invoke-RestMethod -Method Get -Uri $ChromeURL
                $DownVer = $data.channels.Stable.version
            }
            catch {
                $Download = $False
                break
            }
            if ([System.Version]$DownVer -gt [System.Version]$DriverVersion) {
                $Download = $True
                Remove-Item "$ScriptsPath\ObsData\$($DriverList[$BrowserType]).exe" -Force
            }
            else {
                $Download = $False
            }
        }
        else {
            $Download = $True
        }
        if ($Download) {
            if ($VerMajor -ge 115) {
                if (!$DriverExists) {
                    try {
                        $data = Invoke-RestMethod -Method Get -Uri $ChromeURL
                    }
                    catch {
                        Write-Host "Stop"
                        Exit
                    }
                }
                if ([System.Environment]::Is64BitOperatingSystem) {
                    $ChromeFile = "chromedriver-win64.zip"
                    for ($i=($data.channels.Stable.downloads.chromedriver.platform.length -1); $i -ge 0; $i--) {
                        if ($data.channels.Stable.downloads.chromedriver.platform[$i] -eq "win64") {
                            $DownURL = $data.channels.Stable.downloads.chromedriver[$i].url
                            break
                        }
                    }
                }
                else {
                    $ChromeFile = "chromedriver-win32.zip"
                    for ($i=($data.channels.Stable.downloads.chromedriver.platform.length -1); $i -ge 0; $i--) {
                        if ($data.channels.Stable.downloads.chromedriver.platform[$i] -eq "win32") {
                            $DownURL = $data.channels.Stable.downloads.chromedriver[$i].url
                            break
                        }
                    }
                }
            }
            else {
                $ChromeOlderURL = "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$VerMajor"
                $ChromeFile = "chromedriver_win32.zip"
                $DownVer = (Invoke-WebRequest -UseBasicParsing -Uri $ChromeOlderURL).Content
                $DownURL = "https://chromedriver.storage.googleapis.com/$DownVer/" + $ChromeFile
            }
            (New-Object -TypeName System.Net.WebClient).DownloadFile($DownURL, "$ScriptsPath\$ChromeFile")
            Expand-Archive "$ScriptsPath\$ChromeFile" "$ScriptsPath\WebDriverTemp" -Force
            if ($VerMajor -ge 115) {
                if ([System.Environment]::Is64BitOperatingSystem) {
                    Move-Item "$ScriptsPath\WebDriverTemp\chromedriver-win64\chromedriver.exe" "$ScriptsPath\ObsData" -Force
                }
                else {
                    Move-Item "$ScriptsPath\WebDriverTemp\chromedriver-win32\chromedriver.exe" "$ScriptsPath\ObsData" -Force
                }
            }
            else {
                Move-Item "$ScriptsPath\WebDriverTemp\chromedriver.exe" "$ScriptsPath\ObsData" -Force
            }
            Remove-Item "$ScriptsPath\$ChromeFile" -Force
            Remove-Item "$ScriptsPath\WebDriverTemp" -Recurse -Force
        }
        break
    }
    "Edge" {
        # Microsoft Edge (Chromium) WebDriver
        $EdgeURL = "https://msedgedriver.azureedge.net/LATEST_RELEASE_$($VerMajor)_WINDOWS"
        if ($DriverExists) {
            try {
                $VerString = [System.Text.Encoding]::Unicode.GetString((Invoke-WebRequest -UseBasicParsing -Uri $EdgeURL).Content)
                $DownVer = $VerString.substring(1, ($VerString.length - 3))
            }
            catch {
                $Download = $False
                break
            }
            if ([System.Version]$DownVer -gt [System.Version]$DriverVersion) {
                $Download = $True
                Remove-Item "$ScriptsPath\ObsData\$($DriverList[$BrowserType]).exe" -Force
            }
            else {
                $Download = $False
            }
        }
        else {
            $Download = $True
        }
        if ($Download) {
            if (!$DriverExists) {
                try {
                    $data = [System.Text.Encoding]::Unicode.GetString((Invoke-WebRequest -UseBasicParsing -Uri $EdgeURL).Content)
                    $DownVer = $data.substring(1, ($data.length - 3))
                }
                catch {
                    Write-Host "Stop"
                    Exit
                }
            }
            if ([System.Environment]::Is64BitOperatingSystem) {
                $EdgeFile = "edgedriver_win64.zip"
                $DownURL = "https://msedgedriver.azureedge.net/$($DownVer)/" + $EdgeFile
            }
            else {
                $EdgeFile = "edgedriver_win32.zip"
                $DownURL = "https://msedgedriver.azureedge.net/$($DownVer)/" + $EdgeFile
            }
            (New-Object -TypeName System.Net.WebClient).DownloadFile($DownURL, "$ScriptsPath\$EdgeFile")
            Expand-Archive "$ScriptsPath\$EdgeFile" "$ScriptsPath\WebDriverTemp" -Force
            Move-Item "$ScriptsPath\WebDriverTemp\msedgedriver.exe" "$ScriptsPath\ObsData" -Force
            Remove-Item "$ScriptsPath\$EdgeFile" -Force
            Remove-Item "$ScriptsPath\WebDriverTemp" -Recurse -Force
        }
        break
    }
    "Firefox" {
        # Firefox WebDriver
        $FirefoxURL = "https://github.com/mozilla/geckodriver/releases/latest"
        if ($DriverExists) {
            try {
                $data = Invoke-WebRequest -UseBasicParsing -Uri $FirefoxURL
                $DownVer = [regex]::Match($data.Content,'<title>Release\s(.*)\s.*\smozilla.*</title>').captures.groups[1].value
            }
            catch {
                $Download = $False
                break
            }
            if ([System.Environment]::Is64BitOperatingSystem) {
                $FirefoxFile = "geckodriver-v" + $DownVer + "-win64.zip"
                $DownURL = "https://github.com/mozilla/geckodriver/releases/download/v" + $DownVer + "/" + $FirefoxFile
            }
            else {
                $FirefoxFile = "geckodriver-v" + $DownVer + "-win32.zip"
                $DownURL = "https://github.com/mozilla/geckodriver/releases/download/v" + $DownVer + "/" + $FirefoxFile
            }
            if ([System.Version]$DownVer -gt [System.Version]$DriverVersion) {
                $Download = $True
                Remove-Item "$ScriptsPath\ObsData\$($DriverList[$BrowserType]).exe" -Force
            }
            else {
                $Download = $False
            }
        }
        else {
            $Download = $True
        }
        if ($Download) {
            if (!$DriverExists) {
                try {
                    $data = Invoke-WebRequest -UseBasicParsing -Uri $FirefoxURL
                    $DownVer = [regex]::Match($data.Content,'<title>Release\s(.*)\s.*\smozilla.*</title>').captures.groups[1].value
                }
                catch {
                    Write-Host "Stop"
                    Exit
                }
                if ([System.Environment]::Is64BitOperatingSystem) {
                    $FirefoxFile = "geckodriver-v" + $DownVer + "-win64.zip"
                    $DownURL = "https://github.com/mozilla/geckodriver/releases/download/v" + $DownVer + "/" + $FirefoxFile
                }
                else {
                    $FirefoxFile = "geckodriver-v" + $DownVer + "-win32.zip"
                    $DownURL = "https://github.com/mozilla/geckodriver/releases/download/v" + $DownVer + "/" + $FirefoxFile
                }
            }
            (New-Object -TypeName System.Net.WebClient).DownloadFile($DownURL, "$ScriptsPath\$FirefoxFile")
            Expand-Archive "$ScriptsPath\$FirefoxFile" "$ScriptsPath\WebDriverTemp" -Force
            Move-Item "$ScriptsPath\WebDriverTemp\geckodriver.exe" "$ScriptsPath\ObsData" -Force
            Remove-Item "$ScriptsPath\$FirefoxFile" -Force
            Remove-Item "$ScriptsPath\WebDriverTemp" -Recurse -Force
        }
        break
    }
}

# Selenium
$SeleniumURL = "https://www.nuget.org/packages/Selenium.WebDriver"
if ($SeleniumDLLExists) {
    try {
        $data = Invoke-WebRequest -UseBasicParsing -Uri $SeleniumURL
        $DownVer = [regex]::Match($data.Content, '.*<a href="/packages/Selenium.WebDriver.*title="(.*)"').captures.groups[1].value
    }
    catch {
        $Download = $False
        break
    }
    $DriverVersion = (Get-Item "$ScriptsPath\ObsData\WebDriver.dll").VersionInfo.ProductVersion
    if ($DownVer -gt $DriverVersion) {
        $Download = $True
        Remove-Item "$ScriptsPath\ObsData\WebDriver.dll" -Force
    }
    else {
        $Download = $False
    }
}
else {
    $Download = $True
}
if ($Download) {
    if (!$SeleniumDLLExists) {
        try {
            $data = Invoke-WebRequest -UseBasicParsing -Uri $SeleniumURL
            $DownVer = [regex]::Match($data.Content, '.*<a href="/packages/Selenium.WebDriver.*title="(.*)"').captures.groups[1].value
        }
        catch {
            Write-Host "Stop"
            Exit
        }
    }
    # $DownVer = "4.0.0-beta2"   # 下載特定版本: comment $data, $DownVer
    $DownURL = "https://www.nuget.org/api/v2/package/Selenium.WebDriver/" + $DownVer
    $SeleniumFile = "selenium.webdriver.$DownVer.nupkg"
    (New-Object -TypeName System.Net.WebClient).DownloadFile($DownURL, "$ScriptsPath\$SeleniumFile")
    Rename-Item "$ScriptsPath\$SeleniumFile" "$ScriptsPath\$SeleniumFile.zip"
    Expand-Archive "$ScriptsPath\$SeleniumFile.zip" "$ScriptsPath\WebDriverTemp" -Force
    Move-Item "$ScriptsPath\WebDriverTemp\lib\netstandard2.0\WebDriver.dll" "$ScriptsPath\ObsData" -Force
    Remove-Item "$ScriptsPath\$SeleniumFile.zip" -Force
    Remove-Item "$ScriptsPath\WebDriverTemp" -Recurse -Force
}

$global:ProgressPreference = 'Continue'
Write-Host "Kick"
