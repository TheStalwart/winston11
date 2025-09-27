<#
.SYNOPSIS
  Installs essential diagnostic apps.
.DESCRIPTION
  If winget finds any packages out of date, it will update them.
#>
function Install-EssentialDiagnosticApps {
    winget install --id REALiX.HWiNFO -e
    winget install --id CrystalDewWorld.CrystalDiskInfo -e
    winget install --id CrystalDewWorld.CrystalDiskMark -e
}
}

function Main {
    Install-EssentialDiagnosticApps
}

Main
