function Install-EssentialDiagnosticApps {
    winget install `
        REALiX.HWiNFO `
        CrystalDewWorld.CrystalDiskInfo `
        CrystalDewWorld.CrystalDiskMark
}

function Main {
    Install-EssentialDiagnosticApps
}

Main
