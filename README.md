# File Integrity Management Tool

A simple Python script to monitor and verify the integrity of files using SHA-256 hashing. This tool detects unauthorized changes to files, such as modifications, deletions, or additions, which could be caused by malware or accidental actions.

## Features
- Generate SHA-256 hashes for files in a directory.
- Save hashes to a JSON file for future comparison.
- Verify file integrity by comparing current hashes with saved hashes.
- Detect and report changes, including:
  - **Modified files**: Changes to file content.
  - **Deleted files**: Files that are no longer present.
  - **Added files**: New files in the directory.

## Requirements
- Python 3.x

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yassinebenjaber/file-int-mgmt.git
2. Navigate to the project directory:
   ```bash
   cd file-int-mgmt
  ## Usage
1. Generate Hashes:
   To generate hashes for files in a directory and save them to hashes.json:
   ```bash
   python file_int_mgmt.py --generate /path/to/directory
2. Verify Intergreity:
   To verify the integrity of files by comparing their current hashes with the saved hashes:
   ```bash
   python file_int_mgmt.py --verify /path/to/directory
3. Output:
   If no changes are detected, the script will output: **All files are intact**.

   If changes are detected, the script will report:

     Modified files: Files with changed content.

     Deleted files: Files that are missing.

     Added files: New files in the directory.
     
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
Python function and demontrtaion<br/>
 <img src="https://imgur.com/zfn2fYL.png" height="80%" width="80%" alt="Disk Sanitization Steps"/>
<br />
<br />



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
