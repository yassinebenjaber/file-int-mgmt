param (
    [string]$Directory
)

$HASH_FILE = "hashes.json"

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

# Function to generate hashes for all files in the directory
function Generate-Hashes {
    param (
        [string]$Directory
    )
    $hashes = @{}
    Get-ChildItem -Path $Directory -Filter *.txt | ForEach-Object {
        $fileHash = Calculate-Hash -FilePath $_.FullName
        if ($fileHash) {
            $hashes[$_.Name] = $fileHash
        }
    }
    $hashes | ConvertTo-Json | Set-Content -Path $HASH_FILE
    Write-Host "Hashes saved to $HASH_FILE" -ForegroundColor Cyan
}

# Function to verify file integrity
function Verify-Hashes {
    param (
        [string]$Directory
    )
    if (-not (Test-Path $HASH_FILE)) {
        Write-Host "No hashes found. Please generate hashes first." -ForegroundColor Red
        return
    }

    $savedHashes = Get-Content -Path $HASH_FILE | ConvertFrom-Json
    $currentHashes = @{}
    Get-ChildItem -Path $Directory -Filter *.txt | ForEach-Object {
        $fileHash = Calculate-Hash -FilePath $_.FullName
        if ($fileHash) {
            $currentHashes[$_.Name] = $fileHash
        }
    }

    # Check for modified, deleted, and added files
    $modifiedFiles = @()
    $deletedFiles = @()
    $addedFiles = @()

    foreach ($filename in $savedHashes.PSObject.Properties.Name) {
        if (-not $currentHashes.ContainsKey($filename)) {
            $deletedFiles += $filename
        } elseif ($currentHashes[$filename] -ne $savedHashes.$filename) {
            $modifiedFiles += $filename
        }
    }

    foreach ($filename in $currentHashes.Keys) {
        if (-not $savedHashes.PSObject.Properties.Name.Contains($filename)) {
            $addedFiles += $filename
        }
    }

    if ($modifiedFiles.Count -gt 0 -or $deletedFiles.Count -gt 0 -or $addedFiles.Count -gt 0) {
        if ($modifiedFiles.Count -gt 0) {
            Write-Host "Modified files: $($modifiedFiles -join ', ')" -ForegroundColor Yellow
        }
        if ($deletedFiles.Count -gt 0) {
            Write-Host "Deleted files: $($deletedFiles -join ', ')" -ForegroundColor Red
        }
        if ($addedFiles.Count -gt 0) {
            Write-Host "Added files: $($addedFiles -join ', ')" -ForegroundColor Green
        }
    } else {
        Write-Host "No changes detected." -ForegroundColor Cyan
    }
}

# Function to monitor the directory in real-time
function Monitor-Directory {
    param (
        [string]$Directory
    )

    # Create a FileSystemWatcher object
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $Directory
    $watcher.Filter = "*.txt"
    $watcher.IncludeSubdirectories = $false
    $watcher.EnableRaisingEvents = $true

    # Define actions for events
    $action = {
        $eventType = $EventArgs.ChangeType
        $filePath = $EventArgs.FullPath
        $fileName = Split-Path $filePath -Leaf

        switch ($eventType) {
            "Changed" {
                Write-Host "File modified: $fileName" -ForegroundColor Yellow
                Verify-Hashes -Directory $Directory
            }
            "Created" {
                Write-Host "File added: $fileName" -ForegroundColor Green
                Verify-Hashes -Directory $Directory
            }
            "Deleted" {
                Write-Host "File deleted: $fileName" -ForegroundColor Red
                Verify-Hashes -Directory $Directory
            }
            "Renamed" {
                Write-Host "File renamed: $fileName" -ForegroundColor Magenta
                Verify-Hashes -Directory $Directory
            }
        }
    }

    # Register events
    Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $action
    Register-ObjectEvent -InputObject $watcher -EventName Created -Action $action
    Register-ObjectEvent -InputObject $watcher -EventName Deleted -Action $action
    Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action $action

    Write-Host "Monitoring directory: $Directory" -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop monitoring..." -ForegroundColor Cyan

    # Keep the script running
    try {
        while ($true) {
            Start-Sleep -Seconds 1
        }
    } finally {
        # Clean up
        Unregister-Event -SourceIdentifier $watcher.Changed
        Unregister-Event -SourceIdentifier $watcher.Created
        Unregister-Event -SourceIdentifier $watcher.Deleted
        Unregister-Event -SourceIdentifier $watcher.Renamed
        $watcher.Dispose()
    }
}

# Main script logic
if (-not (Test-Path $Directory)) {
    Write-Host "Directory does not exist: $Directory" -ForegroundColor Red
    exit
}

# Generate initial hashes
Generate-Hashes -Directory $Directory

# Start monitoring the directory
Monitor-Directory -Directory $Directory