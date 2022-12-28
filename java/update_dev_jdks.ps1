$JDK_VERSIONS = "8", "11", "17", "19"

$ZipFile="tmp.zip"
$BASE_DEST="${Env:USERPROFILE}\local_jdks"
$CORRETTO_URL="https://corretto.aws/downloads/latest"
$TEMURIN_URL="https://api.adoptium.net/v3/binary/latest"
$MSFT_URL="https://aka.ms/download-jdk"

function Unpack-And-Update {
    if (-not (Test-Path -LiteralPath ${DEST}_TMP)) {
        New-Item -ItemType "directory" -Path ${DEST}_TMP | Out-Null
    }
    tar xf ${ZipFile} --strip-components=1 -C ${DEST}_TMP
    Remove-Item -LiteralPath $DEST -Force -Recurse
    Move-Item -Path ${DEST}_TMP -Destination $DEST
    Remove-Item -LiteralPath $ZipFile
}

# update amazon corretto and eclipse temurin JDKs
foreach ($VERSION in $JDK_VERSIONS)
{
    $DEST="$BASE_DEST\corretto\$VERSION"
    $CORRETTO_PATH="amazon-corretto-${VERSION}-x64-windows-jdk.zip"
    if (-not (Test-Path -LiteralPath $DEST)) {
        New-Item -ItemType "directory" -Path $DEST | Out-Null
    }
    Write-Host "Fetching Corretto ${VERSION}..." -NoNewline
    Invoke-RestMethod -Uri $CORRETTO_URL/$CORRETTO_PATH -OutFile $ZipFile
    Write-Host "extracting..." -NoNewline
    Unpack-And-Update
    [System.Environment]::SetEnvironmentVariable("CORRETTO_${VERSION}_JDK", "$DEST", "User")
    Write-Host "done!"

    $DEST="$BASE_DEST\temurin\$VERSION"
    $TEMURIN_PATH="$VERSION/ga/windows/x64/jdk/hotspot/normal/eclipse"
    if (-not (Test-Path -LiteralPath $DEST)) {
        New-Item -ItemType "directory" -Path $DEST | Out-Null
    }
    Write-Host "Fetching Temurin ${VERSION}..." -NoNewline
    Invoke-RestMethod -Uri "${TEMURIN_URL}/${TEMURIN_PATH}?project=jdk" -OutFile $ZipFile
    Write-Host "extracting..." -NoNewline
    Unpack-And-Update
    [System.Environment]::SetEnvironmentVariable("TEMURIN_${VERSION}_JDK", "$DEST", "User")
    Write-Host "done!"

    If ($VERSION -eq "17") {
        $DEST="$BASE_DEST\msft\$VERSION"
        if (-not (Test-Path -LiteralPath $DEST)) {
            New-Item -ItemType "directory" -Path $DEST | Out-Null
        }
        Write-Host "Fetching Microsoft ${VERSION}..." -NoNewline
        Invoke-RestMethod -Uri "$MSFT_URL/microsoft-jdk-$VERSION-windows-x64.zip" -Outfile $ZipFile
        Write-Host "extracting..." -NoNewline
        Unpack-And-Update
        [System.Environment]::SetEnvironmentVariable("MSFT_${VERSION}_JDK", "$DEST", "User")
        Write-Host "done!"
    }
}

