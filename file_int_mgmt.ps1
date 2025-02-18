param (
    [string]$Directory
)

$BASELINE_FILE = "C:\test\baseline.txt"

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
        # Exclude baseline.txt from the baseline
        if ($_.Name -ne "baseline.txt") {
            $fileHash = Calculate-Hash -FilePath $_.FullName
            if ($fileHash) {
                $baseline[$_.Name] = $fileHash
            }
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

    try {
        $baselineContent = Get-Content -Path $BASELINE_FILE -Raw -ErrorAction Stop
        if ([string]::IsNullOrEmpty($baselineContent)) {
            Write-Host "Baseline file is empty. Please collect a new baseline." -ForegroundColor Red
            return
        }

        # Convert JSON to a PowerShell object (compatible with PowerShell 5.1)
        $baseline = $baselineContent | ConvertFrom-Json -ErrorAction Stop
        if (-not $baseline) {
            throw "Baseline is empty or invalid."
        }

        # Convert the object to a hashtable
        $baselineHashtable = @{}
        $baseline.PSObject.Properties | ForEach-Object {
            $baselineHashtable[$_.Name] = $_.Value
        }
    } catch {
        Write-Host "Failed to load baseline. The file may be corrupted or inaccessible. Please collect a new baseline." -ForegroundColor Red
        Write-Host "Error details: $_" -ForegroundColor Red
        return
    }

    Write-Host "Monitoring directory: $Directory" -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop monitoring..." -ForegroundColor Cyan

    # Track notified changes to avoid spamming
    $notifiedChanges = @{}

    while ($true) {
        $currentFiles = Get-ChildItem -Path $Directory -Filter *.txt
        $currentHashes = @{}

        # Calculate hashes for current files (excluding baseline.txt)
        $currentFiles | ForEach-Object {
            if ($_.Name -ne "baseline.txt") {
                $fileHash = Calculate-Hash -FilePath $_.FullName
                if ($fileHash) {
                    $currentHashes[$_.Name] = $fileHash
                }
            }
        }

        # Check for deleted files
        foreach ($filename in $baselineHashtable.Keys) {
            if (-not $currentHashes.ContainsKey($filename)) {
                if (-not $notifiedChanges.ContainsKey("deleted_$filename")) {
                    Write-Host "File deleted: $filename" -ForegroundColor Red
                    $notifiedChanges["deleted_$filename"] = $true
                }
            }
        }

        # Check for modified or renamed files
        foreach ($filename in $currentHashes.Keys) {
            if ($baselineHashtable.ContainsKey($filename)) {
                if ($currentHashes[$filename] -ne $baselineHashtable[$filename]) {
                    if (-not $notifiedChanges.ContainsKey("modified_$filename")) {
                        Write-Host "File modified: $filename" -ForegroundColor Yellow
                        $notifiedChanges["modified_$filename"] = $true
                    }
                }
            } else {
                # Check if the file is a rename (same hash as a deleted file)
                $isRenamed = $false
                foreach ($baselineFile in $baselineHashtable.Keys) {
                    if ($currentHashes[$filename] -eq $baselineHashtable[$baselineFile]) {
                        if (-not $notifiedChanges.ContainsKey("renamed_$baselineFile")) {
                            Write-Host "File renamed: $baselineFile -> $filename" -ForegroundColor Magenta
                            $notifiedChanges["renamed_$baselineFile"] = $true
                            $isRenamed = $true
                            break
                        }
                    }
                }
                if (-not $isRenamed -and -not $notifiedChanges.ContainsKey("added_$filename")) {
                    Write-Host "File added: $filename" -ForegroundColor Green
                    $notifiedChanges["added_$filename"] = $true
                }
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
