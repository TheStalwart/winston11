param(
    [switch]$SkipInstallSelf = $false
)

function Install-Self {
    $expirationDate = (Get-Date).AddHours(-10)
    $upstreamWinstonScriptURL = "https://raw.githubusercontent.com/TheStalwart/winston11/refs/heads/main/Winston.ps1"
    
    # Running the script via `irm <URL> | iex` is considered force-update
    if (-not $PSCommandPath) {
        Write-Output "Force-updating."
        Invoke-WebRequest -Uri $upstreamWinstonScriptURL -OutFile $selfDestinationPath
        return [bool]$true
    }
    
    # If the destination copy doesn't exist, download it. Otherwise refresh if it's older than 10 hours.
    if (-not (Test-Path $selfDestinationPath)) {
        Write-Output "No existing copy of Winston.ps1 found, downloading."
        Invoke-WebRequest -Uri $upstreamWinstonScriptURL -OutFile $selfDestinationPath
        return [bool]$true
    }
    else {
        $lastWrite = (Get-Item $selfDestinationPath).LastWriteTime
        if ($expirationDate -gt $lastWrite) {
            Write-Output "Existing copy of Winston.ps1 is stale, refreshing."
            Invoke-WebRequest -Uri $upstreamWinstonScriptURL -OutFile $selfDestinationPath
            return [bool]$true
        }
    }

    return [bool]$false
}

<#
.SYNOPSIS
  Installs or updates essential utilities and diagnostic apps.
.DESCRIPTION
  If winget finds any packages out of date, it will update them.
#>
function Install-EssentialUtilities {
    winget install --id 7zip.7zip -e
    winget install --id REALiX.HWiNFO -e
    winget install --id CrystalDewWorld.CrystalDiskInfo -e
    winget install --id CrystalDewWorld.CrystalDiskMark -e
    winget install --id Guru3D.RTSS -e # Standalone frame rate limiter
    winget install --id PrimateLabs.Geekbench.6 -e # OpenCL and Vulkan benchmark
    winget install --id Unigine.HeavenBenchmark -e # DirectX 9 and 11 benchmark
    winget install --id Ookla.Speedtest.Desktop -e
    winget install --id WinDirStat.WinDirStat -e
}

function Install-WinCaffeine {
    $winCaffeineFileName = "WinCaffeine-1.2.0.0"
    $winCaffeinePath = "$appsDir\$winCaffeineFileName.exe"
    $winCaffeineDownloadURL = "https://wincaffeine.jonaskohl.de/download.php?version=latest"
    if (-not (Test-Path $winCaffeinePath)) {
        Invoke-WebRequest -Uri $winCaffeineDownloadURL -OutFile $winCaffeinePath
    }

    if (-not (Get-Process -Name "$winCaffeineFileName" -ErrorAction SilentlyContinue)) {
        & $winCaffeinePath
    }

    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WinCaffeine" -Value "$winCaffeinePath"
}

function Install-Rainmeter {
    winget install --id Rainmeter.Rainmeter -e

    # Configure Rainmeter to start with Windows
    $rainmeterExecutablePath = "$env:ProgramFiles\Rainmeter\Rainmeter.exe"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Rainmeter" -Value "$rainmeterExecutablePath"

    # Disable the default "Welcome" skin.
    # https://docs.rainmeter.net/manual/bangs/#DeactivateConfig
    & "$rainmeterExecutablePath" !DeactivateConfig "illustro\Welcome"

    # Game Mode does not have a way to enable it via command line or config file,
    # by design.
    # https://forum.rainmeter.net/viewtopic.php?t=33882
    # https://forum.rainmeter.net/viewtopic.php?t=37344
    # But it does store the setting somewhere,
    # can we reverse engineer it?
}

<#
.SYNOPSIS
  Installs Steam if not already present.
.DESCRIPTION
  Installer package only bootstrapts the installation.
  Steam client will download and install the rest when launched.
#>
function Install-Steam {
    $steamPath = "C:\Program Files (x86)\Steam\steam.exe"
    if (-not (Test-Path $steamPath)) {
        winget install --id Valve.Steam -e
    }
}

<#
.SYNOPSIS
  Installs Epic Games Launcher if not already present.
.DESCRIPTION
  Attempting to update an existing installation via winget results in an error,
  and the launcher has its own update mechanism, so we only install if not present.
#>
function Install-EpicGamesLauncher {
    $epicPath = "C:\Program Files (x86)\Epic Games\Launcher\Portal\Binaries\Win32\EpicGamesLauncher.exe"
    if (-not (Test-Path $epicPath)) {
        winget install --id EpicGames.EpicGamesLauncher -e
    }
}

function Main {
    $appsDir = "$env:USERPROFILE\Apps"
    if (-not (Test-Path $appsDir)) {
        New-Item -Path $appsDir -ItemType Directory | Out-Null
    }

    if (-not $SkipInstallSelf) {
        $selfDestinationPath = "$appsDir\Winston.ps1"
        if (Install-Self) {
            # execute the updated script and exit current instance
            & "$selfDestinationPath"
            exit 0
        }
    }

    Install-EssentialUtilities
    Install-WinCaffeine
    Install-Rainmeter
    Install-Steam
    Install-EpicGamesLauncher
}

Main
