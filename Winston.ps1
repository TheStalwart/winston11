<#
.SYNOPSIS
  Installs or updates essential diagnostic apps.
.DESCRIPTION
  If winget finds any packages out of date, it will update them.
#>
function Install-EssentialDiagnosticApps {
    winget install --id REALiX.HWiNFO -e
    winget install --id CrystalDewWorld.CrystalDiskInfo -e
    winget install --id CrystalDewWorld.CrystalDiskMark -e
    winget install --id Guru3D.RTSS -e
}

function Install-WinCaffeine {
    $appsDir = "$env:USERPROFILE\Apps"
    if (-not (Test-Path $appsDir)) {
        New-Item -Path $appsDir -ItemType Directory | Out-Null
    }

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
    Install-EssentialDiagnosticApps
    Install-WinCaffeine
    Install-Steam
    Install-EpicGamesLauncher
}

Main
