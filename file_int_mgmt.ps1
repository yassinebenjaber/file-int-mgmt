param (
    [string]$Directory
)

$BASELINE_FILE = "baseline.txt"

# Function to calculate SHA-256 hash of a file
function Calculate-Hash {
    param (
        [string]$FilePath
    )
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $fileStream = [System.IO.File]::OpenRead($FilePath)
        $hashBytes = $sha256.ComputeHash($fileStream)
        $fileStream.Close()
        return [System.BitConverter]::ToString($hashBytes).Replace("-", "").ToLower()
    } catch {
        return $null
    }
}

# Function to collect a new baseline
function Collect-Baseline {
    param (
        [string]$Directory
    )
    $baseline = @{}
    Get-ChildItem -Path $Directory -Filter *.txt | ForEach-Object {
        $fileHash = Calculate-Hash -FilePath $_.FullName
        if ($fileHash) {
            $baseline[$_.Name] = $fileHash
        }
    }
    $baseline | ConvertTo-Json | Set-Content -Path $BASELINE_FILE
    Write-Host "New baseline collected and saved to $BASELINE_FILE" -ForegroundColor Cyan
}

# Function to monitor files using the saved baseline
function Monitor-Files {
    param (
        [string]$Directory
    )
    if (-not (Test-Path $BASELINE_FILE)) {
        Write-Host "No baseline found. Please collect a new baseline first." -ForegroundColor Red
        return
    }

    $baseline = Get-Content -Path $BASELINE_FILE | ConvertFrom-Json -AsHashtable

    Write-Host "Monitoring directory: $Directory" -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop monitoring..." -ForegroundColor Cyan

    while ($true) {
        $currentFiles = Get-ChildItem -Path $Directory -Filter *.txt
        $currentHashes = @{}

        # Calculate hashes for current files
        $currentFiles | ForEach-Object {
            $fileHash = Calculate-Hash -FilePath $_.FullName
            if ($fileHash) {
                $currentHashes[$_.Name] = $fileHash
            }
        }

        # Check for changes
        foreach ($filename in $baseline.Keys) {
            if (-not $currentHashes.ContainsKey($filename)) {
                Write-Host "File deleted: $filename" -ForegroundColor Red
            } elseif ($currentHashes[$filename] -ne $baseline[$filename]) {
                Write-Host "File modified: $filename" -ForegroundColor Yellow
            }
        }

        # Check for new files
        foreach ($filename in $currentHashes.Keys) {
            if (-not $baseline.ContainsKey($filename)) {
                Write-Host "File added: $filename" -ForegroundColor Green
            }
        }

        Start-Sleep -Seconds 1
    }
}

# Main script logic
if (-not (Test-Path $Directory)) {
    Write-Host "Directory does not exist: $Directory" -ForegroundColor Red
    exit
}

# Ask the user what they want to do
Write-Host "What would you like to do?"
Write-Host "A. Collect new Baseline"
Write-Host "B. Begin monitoring files with saved Baseline"
$choice = Read-Host "Enter your choice (A or B)"

switch ($choice.ToUpper()) {
    "A" {
        Collect-Baseline -Directory $Directory
    }
    "B" {
        Monitor-Files -Directory $Directory
    }
    default {
        Write-Host "Invalid choice. Please run the script again and select A or B." -ForegroundColor Red
    }
}
