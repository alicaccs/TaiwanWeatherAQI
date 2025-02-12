###########################################################
#  By Proliantaholic https://proliantaholic.blogspot.com  #
###########################################################

param (
    [string]$ObsDataPath = ".",
    [string]$BrowserType = "Chrome",
    [string]$StationId = "46692", # 臺北
    [string]$CountyId = "63", # 臺北市
    [string]$TownId = "6300500" # 臺北市中正區
)

[Console]::OutputEncoding=[Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$global:ProgressPreference = 'SilentlyContinue'
$URL = "https://www.cwb.gov.tw/V8/C/W/OBS_Station.html?ID=$StationId"

if (!(Test-Connection 8.8.8.8 -Quiet) 2>$null) {
    # 網路連線異常
    $StationName = "網路連線異常"
    $obsDataStatus = "網路連線異常"
    $obsDataRowCount = "0"
    $mmdd = Get-Date -Format 'MM/dd'
    $HHMM = Get-Date -Format 'HH:mm'
    $tem = ""
    $weather = "-"
    $weatherL1 = ""
    $weatherL2 = ""
    $w1 = " -"
    $w2 = "-"
    $w3 = "-"
    $visible = "-"
    $hum = "-"
    $pre = "-"
    $rain = "-"
    $sunlight = "-"
    $SSTimeSunRize = $(Get-Date -Format 'yyyy/MM/dd ') + "06:00"
    $SSTimeSunSet  = $(Get-Date -Format 'yyyy/MM/dd ') + "18:00"
    if (((Get-Date) -ge (Get-Date -Date $SSTimeSunRize)) -and (((Get-Date) -lt (Get-Date -Date $SSTimeSunSet)))) {
        $DayOrNight = 'DAY'
    } else {
        $DayOrNight = 'NIGHT'
    }
    $TownId = "體感溫度異常"
    $TownName = ""
    $ApptTemp = ""
    $ApptTempTime = "-"
    $PoP6h = ""
    Write-Host $StationId","$StationName","$obsDataStatus","$obsDataRowCount","$mmdd","$HHMM","$tem","$weather","$weatherL1","$weatherL2","$w1","$w2","$w3","$visible","$hum","$pre","$rain","$sunlight"," -NoNewline
    Write-Host $SSTimeSunRize","$SSTimeSunSet","$DayOrNight","$TownId","$TownName","$ApptTemp","$ApptTempTime","$PoP6h"," -NoNewline
    Write-Host 資料來源:中央氣象局全球資訊網","$URL"," -NoNewline
    Write-Host $ObsDataPath","$BrowserType","
    Exit
}

$DriverList = @{ 'Chrome' = 'chromedriver.exe'; 'Edge' = 'msedgedriver.exe'; 'Firefox' = 'geckodriver.exe' }
$WebDriverExe = $DriverList[$BrowserType]
Add-Type -Path "$($ObsDataPath)\WebDriver.dll"

switch ($BrowserType)
{
    'Chrome'  {
                  $BrowserOptions = New-Object OpenQA.Selenium.Chrome.ChromeOptions
                  $BrowserOptions.AddArguments([string[]]('headless', 'incognito', 'blink-settings=imagesEnabled=false'))
                  $BrowserOptions.PageLoadStrategy = "eager"

                  $service = [OpenQA.Selenium.Chrome.ChromeDriverService]::CreateDefaultService($ObsDataPath, $WebDriverExe)
                  $service.HideCommandPromptWindow = $true

                  $BrowserDriver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($service, $BrowserOptions)
                  break
              }
    'Edge'    {
                  $BrowserOptions = New-Object OpenQA.Selenium.Edge.EdgeOptions
                  $BrowserOptions.AddArguments([string[]]('headless', 'inprivate', 'blink-settings=imagesEnabled=false'))
                  $BrowserOptions.PageLoadStrategy = "eager"

                  $service = [OpenQA.Selenium.Edge.EdgeDriverService]::CreateDefaultService($ObsDataPath, $WebDriverExe)
                  $service.HideCommandPromptWindow = $true

                  $BrowserDriver = New-Object OpenQA.Selenium.Edge.EdgeDriver($service, $BrowserOptions)
                  break
              }
    'Firefox' {
                  $BrowserOptions = New-Object OpenQA.Selenium.Firefox.FirefoxOptions
                  $BrowserOptions.AddArguments([string[]]('--headless', '--private', '--blink-settings=imagesEnabled=false'))
                  $BrowserOptions.PageLoadStrategy = "eager"

                  $service = [OpenQA.Selenium.Firefox.FirefoxDriverService]::CreateDefaultService($ObsDataPath, $WebDriverExe)
                  $service.HideCommandPromptWindow = $true

                  $BrowserDriver = New-Object OpenQA.Selenium.Firefox.FirefoxDriver($service, $BrowserOptions)
                  break
              }
}

try {
    $BrowserDriver.Navigate().GoToURL($URL)
    for ($i=0; $i -lt 6; $i++) {
        if ($BrowserDriver.ExecuteScript('return document.readyState') -ne "complete") {
            Start-Sleep -Seconds 1
        } else {
            break
        }
    }
    $obsData = $BrowserDriver.FindElements('css selector', '#StationData').GetAttribute('outerHTML')
}
catch {
    $message1 = $_.Exception
    try {
        $BrowserDriver.Navigate().Refresh()
        for ($i=0; $i -lt 6; $i++) {
            if ($BrowserDriver.ExecuteScript('return document.readyState') -ne "complete") {
                Start-Sleep -Seconds 1
            } else {
                break
            }
        }
        $obsData = $BrowserDriver.FindElements('css selector', '#StationData').GetAttribute('outerHTML')
    }
    catch {
        $message2 = $_.Exception
    }
}

switch ($obsDataRowCount = $BrowserDriver.FindElements('xpath', '//*[@id="obstime"]/tr').Count)
{
    0       {   # 無觀測資料或無此測站
                $obsDataStatus = "無觀測資料"
                $time = "-"
                $mmdd = Get-Date -Format 'MM/dd'
                $HHMM = Get-Date -Format 'HH:mm'
                $tem = ""
                $weather = "-"
                $weatherL1 = ""
                $weatherL2 = ""
                $w1 = " -"
                $w2 = "-"
                $w3 = "-"
                $visible = "-"
                $hum = "-"
                $pre = "-"
                $rain = "-"
                $sunlight = "-"
                break
            }
    1       {   # 測站儀器故障, 儀器調校中
                $obsDataStatus =  $BrowserDriver.FindElements('css selector', '#obstime > tr:nth-child(1)').Text
                $time = "-"
                $mmdd = Get-Date -UFormat '%m/%d'
                $HHMM = Get-Date -UFormat '%H:%M'
                $weather = "-"
                $weatherL1 = ""
                $weatherL2 = ""
                if ($obsDataStatus -eq "儀器故障") {
                    $tem = "故障"
                    $w1 = ""
                    $w2 = "儀器故障"
                    $w3 = "故障"
                    $visible = "故障"
                    $hum = "故障"
                    $pre = "儀器故障"
                    $rain = "儀器故障"
                    $sunlight = "儀器故障"
                } else {
                    $tem = "調校"
                    $w1 = ""
                    $w2 = "調校中"
                    $w3 = "調校"
                    $visible = "調校"
                    $hum = "調校"
                    $pre = "調校中"
                    $rain = "調校中"
                    $sunlight = "儀器調校中"
                }
                break
            }
    default {   # 正常 (10分鐘更新150列, 1小時更新25列)
                $obsDataStatus = "正常"
                $time = $BrowserDriver.FindElement('xpath', '//*[@id="obstime"]/tr/th[@headers="time"]').Text -match '(?<mmdd>.*)\r\n(?<HHMM>.*)'
                $mmdd = $Matches.mmdd
                $HHMM = $Matches.HHMM
                $tem = $BrowserDriver.FindElement('xpath', '//*[@id="obstime"]/tr[1]/td[@headers="temp"]').Text
                try {
                    $tem = [regex]::Match($tem,"^(儀器)(故障|調校)(.*)").groups.captures[2].value
                }
                catch {
                    $tem = ($tem + "°" ) -replace '(^-°$)', ''
                }
                if (($BrowserDriver.FindElements('xpath', '//*[@id="obstime"]/tr[1]/td[@headers="weather"]/img').Count) -ne 0) { 
                    $weather = $BrowserDriver.FindElement('xpath', '//*[@id="obstime"]/tr[1]/td[@headers="weather"]/img').getAttribute('title')
                    try {
                        $weatherTemp = [regex]::Match($weather,"^(晴|多雲|陰)(.*)")
                        $weatherL1 = $weatherTemp.captures.groups[1].value
                        $weatherL2 = $weatherTemp.captures.groups[2].value
                    }
                    catch {
                        $weatherL1 = $weather
                        $weatherL2 = ""
                    }
                } else {
                    $weather = "-"
                    $weatherL1 = ""
                    $weatherL2 = ""
                }
                $w1 = $BrowserDriver.FindElement('xpath', '//*[@id="obstime"]/tr[1]/td[@headers="w-1"]/span[@class="wind"]').getAttribute('innerHTML')
                if ($w1 -match "^(?!儀器.*)") {
                    $w1 = $w1 -replace '^風向不定$', '不定'
                    $w1 = " " + $($w1 -replace '^－$', '-') # Replace Unicode minus sign U+FF0D "－" ef bc 8d
                } else {
                    $w1 = ""
                }
                $w2 = $BrowserDriver.FindElement('xpath', '//*[@id="obstime"]/tr[1]/td[@headers="w-2"]/span[@class="wind_1 is-active"]').getAttribute('innerHTML')
                try { $w2 = [regex]::Match($w2,"^(儀器)(調校中)(.*)").groups.captures[2].value } catch {}
                $w3 = $BrowserDriver.FindElement('xpath', '//*[@id="obstime"]/tr[1]/td[@headers="w-3"]/span[@class="wind_1 is-active"]').getAttribute('innerHTML')
                try { $w3 = [regex]::Match($w3,"^(儀器)(故障|調校)(.*)").groups.captures[2].value } catch {}
                $visible = $BrowserDriver.FindElement('css selector', '#obstime > tr:nth-child(1) > td:nth-child(7)').getAttribute('innerHTML')
                try { $visible = [regex]::Match($visible,"^(儀器)(故障|調校)(.*)").groups.captures[2].value } catch {}
                $hum = $BrowserDriver.FindElement('css selector', '#obstime > tr:nth-child(1) > td:nth-child(8)').getAttribute('innerHTML')
                try { $hum = [regex]::Match($hum,"^(儀器)(故障|調校)(.*)").groups.captures[2].value } catch { $hum = $hum -replace '(?!^-$)(.+)', '$1%' }
                $pre = $BrowserDriver.FindElement('css selector', '#obstime > tr:nth-child(1) > td:nth-child(9)').getAttribute('innerHTML')
                try { $pre = [regex]::Match($pre,"^(儀器)(調校中)(.*)").groups.captures[2].value } catch {}
                $rain = $BrowserDriver.FindElement('css selector', '#obstime > tr:nth-child(1) > td:nth-child(10)').getAttribute('innerHTML')
                try { $rain = [regex]::Match($rain,"^(儀器)(調校中)(.*)").groups.captures[2].value } catch {}
                $sunlight = $BrowserDriver.FindElement('css selector', '#obstime > tr:nth-child(1) > td:nth-child(11)').getAttribute('innerHTML')
                break
            }
}

if ($obsDataStatus -ne "無觀測資料") {
    try {
        $StationName = [regex]::Match($obsData,"data-cstname=`"(.*)`" data-estname").captures.groups[1].value
    }
    catch {
        $StationName = "$StationId $obsDataStatus"
    }
} else {
    $StationName = "無觀測資料或無此測站"
}

# SSTime
if ($StationName -ne "無觀測資料或無此測站") {
    $SSTimeURL = "https://www.cwb.gov.tw/V8/C/W/County/MOD/SunMoon/$($CountyId)_SunMoon.html"
} else {
    $SSTimeURL = "https://www.cwb.gov.tw/V8/C/W/County/MOD/SunMoon/63_SunMoon.html"
}
$Now = Get-Date
$NowMonthDay = $Now.ToString('MM/dd')
$NowYear = $Now.ToString('yyyy/')
try {
        $Header = 'P01','PStationName','PDataStatus','P04','P05','P06','P07','P08','P09','P10','P11','P12','P13','P14','P15','P16','PSSTimeSunRize','PSSTimeSunSet','P19','P20','P21','P22','P23','P24','P25','P26','P27','P28','P29','P30'
        $P = Import-Csv "$ObsDataPath\ObsData.txt" -Header $Header -Encoding Unicode
        if ((([datetime]$P.PSSTimeSunRize).DayOfYear -ne $Now.DayOfYear) -or ($P.PDataStatus -eq "網路連線異常") -or ($P.PStationName -ne $StationName)) {
            try {
                $SSTPageSource = (Invoke-WebRequest -UseBasicParsing -Uri $SSTimeURL).Content
                $SSTPageSource -match '(?s)''panel-heading''>(?<SSTimeMonthDay>.*)</div>.*<td>(?<SSTimeSunRize>.*)</td>.*<td>(?<SSTimeSunSet>.*)</td>.*<td>.*</td>.*<td>.*</td>' | Out-Null
                $SSTimeMonthDay = $Matches.SSTimeMonthDay
                $SSTimeSunRize = $Matches.SSTimeSunRize
                $SSTimeSunSet = $Matches.SSTimeSunSet
                if ("" -eq $SSTimeSunRize) {
                    $SSTimeMonthDay = $NowMonthDay
                    $SSTimeSunRize = "06:00"
                    $SSTimeSunSet = "18:00"
                }
            }
            catch {
                $SSTimeMonthDay = $NowMonthDay
                $SSTimeSunRize = "06:00"
                $SSTimeSunSet = "18:00"
            }
            $SSTimeSunRize = $NowYear + $SSTimeMonthDay + " " + $SSTimeSunRize
            $SSTimeSunSet = $NowYear + $SSTimeMonthDay+ " " + $SSTimeSunSet
        } else {
            $SSTimeSunRize = $P.PSSTimeSunRize
            $SSTimeSunSet = $P.PSSTimeSunSet
        }
}
catch {
    try {
        $SSTPageSource = (Invoke-WebRequest -UseBasicParsing -Uri $SSTimeURL).Content
        $SSTPageSource -match '(?s)''panel-heading''>(?<SSTimeMonthDay>.*)</div>.*<td>(?<SSTimeSunRize>.*)</td>.*<td>(?<SSTimeSunSet>.*)</td>.*<td>.*</td>.*<td>.*</td>' | Out-Null
        $SSTimeMonthDay = $Matches.SSTimeMonthDay
        $SSTimeSunRize = $Matches.SSTimeSunRize
        $SSTimeSunSet = $Matches.SSTimeSunSet
        if ("" -eq $SSTimeSunRize) {
            $SSTimeMonthDay = $NowMonthDay
            $SSTimeSunRize = "06:00"
            $SSTimeSunSet = "18:00"
        }
    }
    catch {
        $SSTimeMonthDay = $NowMonthDay
        $SSTimeSunRize = "06:00"
        $SSTimeSunSet = "18:00"
    }
    $SSTimeSunRize = $NowYear + $SSTimeMonthDay + " " + $SSTimeSunRize
    $SSTimeSunSet = $NowYear + $SSTimeMonthDay+ " " + $SSTimeSunSet
}

# DAY or NIGHT
if (($Now -ge [datetime]$SSTimeSunRize) -and (($Now - [datetime]$SSTimeSunSet).TotalMinutes -lt -15)) {
    $DayOrNight = 'DAY'
} else {
    $DayOrNight = 'NIGHT'
}

# ApptTemp and PoP6h
if ($StationName -ne "無觀測資料或無此測站") {
    $ApptTempURL = "https://www.cwb.gov.tw/V8/C/W/Town/Town.html?TID=$($TownId)"
    try {
        $BrowserDriver.Navigate().GoToURL($ApptTempURL)
        for ($i=0; $i -lt 6; $i++) {
            if ($BrowserDriver.ExecuteScript('return document.readyState') -ne "complete") {
                Start-Sleep -Seconds 1
            } else {
                break
            }
        }
        $TownName = [regex]::Match($BrowserDriver.Title,'(.*) - ').captures.groups[1].value
        $ApptTemp = $BrowserDriver.FindElement('xpath', '/html/body/div[2]/main/div/div[1]/table/tbody/tr/td[3]/span/span[1]').getAttribute('innerHTML')
        $ApptTemp = $ApptTemp -replace '(?!^-$)(.+)', '$1°'
        $ApptTemp = $ApptTemp -replace '(^-$)', ''
        $ApptTempTime = $BrowserDriver.FindElement('xpath', '/html/body/div[2]/main/div/div[1]/table/tbody/tr/td[1]/span').getAttribute('innerHTML')
        $ApptTempTime = [regex]::Match($ApptTempTime,'.*<br>.*<br>(.*)').captures.groups[1].value
        $PoP6h = $BrowserDriver.FindElement('xpath', '/html/body/div[2]/main/div/div[2]/div[3]/div[1]/div[1]/table[1]/tbody/tr[5]/td[1]').getAttribute('innerHTML')
    }
    catch {
        $message3 = $_.Exception
        $BrowserDriver.Navigate().Refresh()
        for ($i=0; $i -lt 6; $i++) {
            if ($BrowserDriver.ExecuteScript('return document.readyState') -ne "complete") {
                Start-Sleep -Seconds 1
            } else {
                break
            }
        }
        try {
            $TownName = [regex]::Match($BrowserDriver.Title,'(.*) - ').captures.groups[1].value
            $ApptTemp = $BrowserDriver.FindElement('xpath', '/html/body/div[2]/main/div/div[1]/table/tbody/tr/td[3]/span/span[1]').getAttribute('innerHTML')
            $ApptTemp = $ApptTemp -replace '(?!^-$)(.+)', '$1°'
            $ApptTemp = $ApptTemp -replace '(^-$)', ''
            $ApptTempTime = $BrowserDriver.FindElement('xpath', '/html/body/div[2]/main/div/div[1]/table/tbody/tr/td[1]/span').getAttribute('innerHTML')
            $ApptTempTime = [regex]::Match($ApptTempTime,'.*<br>.*<br>(.*)').captures.groups[1].value
            $PoP6h = $BrowserDriver.FindElement('xpath', '/html/body/div[2]/main/div/div[2]/div[3]/div[1]/div[1]/table[1]/tbody/tr[5]/td[1]').getAttribute('innerHTML')
        }
        catch {
            $message4 = $_.Exception
            $TownId = "體感溫度異常"
            $TownName = ""
            $ApptTemp = ""
            $ApptTempTime = "-"
            $PoP6h = ""
        }
    }
} else {
    $TownId = "體感溫度異常"
    $TownName = ""
    $ApptTemp = ""
    $ApptTempTime = "-"
    $PoP6h = ""
}

$global:ProgressPreference = 'Continue'
$BrowserDriver.Quit()

Write-Host $StationId","$StationName","$obsDataStatus","$obsDataRowCount","$mmdd","$HHMM","$tem","$weather","$weatherL1","$weatherL2","$w1","$w2","$w3","$visible","$hum","$pre","$rain","$sunlight"," -NoNewline
Write-Host $SSTimeSunRize","$SSTimeSunSet","$DayOrNight","$TownId","$TownName","$ApptTemp","$ApptTempTime","$PoP6h"," -NoNewline
Write-Host 資料來源:中央氣象局全球資訊網","$URL"," -NoNewline
Write-Host $ObsDataPath","$BrowserType","


# $StationId       ->  [ObsData1StationId]             ; 測站站號
# $StationName     ->  [ObsData2StationName]           ; 測站站名 
# $obsDataStatus   ->  [ObsData3DataStatus]            ; 測站狀態 (正常, 儀器故障, 儀器調校中, 網路連線異常)
# $obsDataRowCount ->  [ObsData4DataRowCount]          ; 觀測資料列數 (判斷測站狀態依據)
# $mmdd            ->  [ObsData5DataTimemmdd]          ; 觀測時間 (月日)
# $HHMM            ->  [ObsData6DataTimeHHMM]          ; 觀測時間 (時分)
# $tem             ->  [ObsData7TEMP]                  ; 溫度
# $weather         ->  [ObsData8Weather]               ; 天氣狀況
# $weatherL1       ->  [ObsData9WeatherL1]             ; 天氣描述Line1 (雲量)
# $weatherL2       ->  [ObsData10WeatherL2]            ; 天氣描述Line2 (天氣現象)
# $w1              ->  [ObsData11WindDirection]        ; 風向
# $w2              ->  [ObsData12Wind]                 ; 風力(級)
# $w3              ->  [ObsData13Gust]                 ; 陣風(級)
# $visible         ->  [ObsData14Visibility]           ; 能見度(公里)
# $hum             ->  [ObsData15HUMD]                 ; 相對濕度(%)
# $pre             ->  [ObsData16AtmosphericPressure]  ; 海平面氣壓(百帕)
# $rain            ->  [ObsData17Rain1day]             ; 當日累積雨量(毫米)
# $sunlight        ->  [ObsData18Sunlight]             ; 日照時數
# $SSTimeSunRize   ->  [ObsData19SSTimeSunRize]        ; 日出時刻 yyyy/MM/dd HH:mm -> HH:mm
# $SSTimeSunSet    ->  [ObsData20SSTimeSunSet]         ; 日沒時刻 yyyy/MM/dd HH:mm -> HH:mm
# $DayOrNight      ->  [ObsData21DayOrNight]           ; 白天夜晚 (DAY, NIGHT)
# $TownId          ->  [ObsData22TownId]               ; 測站區鄉鎮代碼
# $TownName        ->  [ObsData23TownName]             ; 測站區鄉鎮名稱
# $ApptTemp        ->  [ObsData24ApptTemp]             ; 體感溫度
# $ApptTempTime    ->  [ObsData25ApptTempTime]         ; 體感溫度預報時間
# $PoP6h           ->  [ObsData26PoP6h]                ; 六小時降雨機率

# 資料來源:中央氣象局全球資訊網  ->  [ObsData27DataSource]   ; 資料來源聲明
# $URL                           ->  [ObsData28URL]          ; 資料來源URL
# $ObsDataPath                   ->  [ObsData29ObsDataPath]  ; ObsData路徑
# $BrowserType                   ->  [ObsData30BrowserType]  ; 瀏覽器 (Edge, Chrome, Firefox)
