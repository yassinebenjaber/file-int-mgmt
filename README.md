# File Integrity Monitoring (FIM) Tool

## Description
In this project i made a tool that monitors file integrity by tracking changes in a specified directory. It uses SHA-256 hashing to identify unauthorized file changes, ensuring data integrity and security. The tool can detect file additions, deletions, modifications, and renames in real-time.

## How It Works
1. **Baseline Collection**:  
   - The tool scans the target directory and records the SHA-256 hash of each file.  
   - This baseline serves as the reference point for future monitoring.  

2. **Real-Time Monitoring**:  
   - The tool continuously monitors the directory for changes.  
   - It compares the current file hashes with the baseline to detect any anomalies.  

3. **Change Detection**:  
   The tool detects and reports the following events:  
   - **File Added**: A new file is detected.  
   - **File Modified**: An existing file's content has changed.  
   - **File Renamed**: A file is renamed while retaining the same hash.  
   - **File Deleted**: A file present in the baseline is no longer found.  

4. **User Interaction**:  
   - On execution, the tool prompts the user to either collect a new baseline or start monitoring.  
   - The monitoring process runs indefinitely, displaying file activity in real-time.  

## Technologies Used
- **PowerShell**: Scripting language for automation and file integrity calculations.  
- **SHA-256 Hashing**: Ensures reliable detection of file changes.  

## Environment
- **Operating System**: Windows 10 or later.  
- **Target Directory**: Configurable for any directory containing `.txt` files.  

## Practical Use Cases
- Monitoring sensitive files for unauthorized modifications.  
- Detecting accidental or malicious file deletions.  
- Verifying file integrity in shared or critical directories.  

## Limitations
- Only monitors `.txt` files (can be modified to include other file types).  
- Requires PowerShell 5.1 or later.  

This tool provides a simple yet effective way to enhance file integrity monitoring, supporting proactive security measures.  
---
*Start by running this command*:
.\file_int_mgmt.ps1 -Directory "c:\target directory"





<h2>Program walk-through:</h2>

<p align="center">
Flow chart demonstrating the FIM : <br/>
<img src="https://imgur.com/YsKkgTb.png" height="80%" width="80%" alt="Disk Sanitization Steps"/>
<br />
<p align="center" >
Target folder before demonstration<br/>
 <img src="https://imgur.com/Rx4tgry.png" height="80%" width="80%" alt="Disk Sanitization Steps"/>
<br />
  <p align="center" >
Executing the script / Folder after demonstration<br/>
 <img src="https://imgur.com/FiBpyod.png" height="80%" width="80%" alt="Disk Sanitization Steps"/>
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
