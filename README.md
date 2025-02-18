# File Integrity Management Tool (FIM)

A PowerShell script to monitor and verify the integrity of files in a directory using SHA-256 hashing. This tool detects changes such as file modifications, deletions, additions, and renames, providing real-time alerts with color-coded outputs.

## Features
- **Generate Hashes**: Create SHA-256 hashes for all `.txt` files in a directory and save them to a JSON file.
- **Verify Integrity**: Compare current file hashes with saved hashes to detect changes.
- **Real-Time Monitoring**: Monitor the directory for changes in real-time and receive instant alerts.
- **Color-Coded Alerts**:
  - **Yellow**: Modified files.
  - **Red**: Deleted files.
  - **Green**: Added files.
  - **Magenta**: Renamed files.
- **JSON Storage**: Hashes are stored in `hashes.json` for future comparisons.

## Requirements
- **PowerShell 5.1** or later.
- **.NET Framework** (for SHA-256 hashing).

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yassinebenjaber/file-int-mgmt.git
2. Navigate to the project directory:
   ```bash
   cd file-int-mgmt
  ## Usage
1. Generate Hashes + Integrity Verification + Real-time monitoring:
   To generate SHA-256 hashes for all .txt files in a directory and save them to hashes.json:
   ```bash
   .\file_int_mgmt.ps1 -Directory "C:\path\to\directory"
2. Output:
If no changes are detected, the script will output: No changes detected (in cyan).

If changes are detected, the script will report:

 - Modified files: Files with changed content (in yellow).

 - Deleted files: Files that are missing (in red).

 - Added files: New files in the directory (in green).

 - Renamed files: Files that have been renamed (in magenta).
     
<h2>Languages and Utilities Used</h2>

- <b>PowerShell ISE</b>
- <b>Python
  
<h2>Environments Used </h2>

- <b>Windows 11</b>



<h2>Program walk-through:</h2>

<p align="center">
Flow chart demonstrating the FIM : <br/>
<img src="https://imgur.com/YsKkgTb.png" height="80%" width="80%" alt="Disk Sanitization Steps"/>
<br />
<p align="center" >
Testing folder before demonstration<br/>
 <img src="https://imgur.com/Rx4tgry.png" height="80%" width="80%" alt="Disk Sanitization Steps"/>
<br />
  <p align="center" >
Executing the script / Folder after demonstration<br/>
 <img src="https://imgur.com/FiBpyod.png" height="80%" width="80%" alt="Disk Sanitization Steps"/>
<br />
<br />

https://imgur.com/9XbWlyi

</p>

<!--
 ```diff
- text in red
+ text in green
! text in orange
# text in gray
@@ text in purple (and bold)@@
```
--!>
