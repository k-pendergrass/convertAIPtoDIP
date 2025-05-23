# convertAIPtoDIP

## Overview

convertAIPtoDIP.bat is a Windows batch script that works with two optional file manifests to convert an Archival Information Package (AIP) organized as a BagIt bag into a Dissemination Information Package (DIP) by validating the BagIt bag, optionally deleting all restricted files found in the accompanying restricted files manifest and/or all files in the reading room delivery only manifest, removing the BagIt metadata files, removing any empty directories, adding a README file for users, and renaming the AIP directory with the DIP name.

Keith Pendergrass, digital archivist at Baker Library Special Collections and Archives (BLSCA), wrote the script to allow BLSCA to create AIPs with nested directory hierarchies and deposit them as BagIt bags within Zip files into Harvard’s preservation repository, which at the time accepted only files in flat hierarchies. Using the two optional file manifests, the script also allowed BLSCA collection managers to make machine-actionable access and delivery restriction decisions at the file level.

For more information, see the slide deck for the BitCurator Forum 2024 lightning talk "[A low-tech solution for mediated delivery of born-digital materials](https://docs.google.com/presentation/d/1Rh08JJz5AlNjeF-wO6vVvpN2Do7MzPDQUpfAEYS23iw)". 


**IMPORTANT:** You must update the README section within the script file to reflect your organization's process and policies, especially template text in brackets and the "DISCLAIMER" and "NOTICE". This section provides a guide for what you may want to include in your organization’s README file for users.


## Dependencies

convertAIPtoDIP.bat requires pre-installation of Python (https://www.python.org/) and bagit-python (https://github.com/LibraryOfCongress/bagit-python). The Python version requirement is found in the bagit-python README file on GitHub.


## Operating System Compatibility

As a Windows batch file, convertAIPtoDIP.bat will run only on Windows operating systems.


## Installation

convertAIPtoDIP.bat does not require installation. As long as you’ve already installed Python and bagit-python, convertAIPtoDIP.bat will run in Windows Terminal simply by double-clicking on the script.

Note: While convertAIPtoDIP.bat itself does not require administrator privileges, your organization may require admin privileges to run any scripts or command line processes. Additionally, you will likely need admin privileges to install Python and bagit-python.


## User Interface

Command Line Interface: convertAIPtoDIP.bat uses the Windows Terminal application to run commands and display progress and error messages.


## File and Directory Structure

As it was written for BLSCA use, convertAIPtoDIP.bat expects the directory structure that Harvard’s preservation repository requires for Zip file deposits. The Zip file contains two top-level directories: a “content” directory that contains the AIP BagIt bag and a “documentation” directory that contains the convertAIPtoDIP.bat script. The optional file manifests should remain outside of the Zip file to allow for easier updates to restrictions, and should then go in the “documentation” directory next to convertAIPtoDIP.bat when preparing to run the script.

After unpacking the Zip file and adding the optional file manifests, the structure should match the following, where files are in brackets and directories are not:
```
├───content
│   └───AIP BagIt bag
│       ├───data
│       │   └───[preserved files and directories]
│       └───[BagIt metadata files]
└───documentation
    ├───[convertAIPtoDIP.bat]
    └───[optional file manifests]
```

If you are using either of the two optional manifest files, they must be text files that contain the relative path from the “documentation” directory for each file to delete; each file path must be on a new line. The manifest files must follow the naming convention of [AIP_ID]_Restricted-Files.txt and [AIP_ID]_RR-Only-Files.txt, where you replace the text inside the brackets with your AIP Identifier and remove the brackets. The AIP Identifier must then match that given as the local variable “AIPID” (see the "Updating the Script Prior to Deposit" section below.)

The script uses the manifest files as machine-actional access and delivery restrictions. You should add any files that have access restrictions to [AIP_ID]_Restricted-Files.txt and any files that you can deliver only in the reading room (that is, you cannot deliver them to remote users) to [AIP_ID]_RR-Only-Files.txt. The script will delete all files in these manifests when present in the “documentation” directory. Follow these rules to determine which manifests to add if they exist: always add the restricted file manifest, add the reading room delivery only manifest if providing remote access, do not add the reading room delivery only manifest if providing delivery in the reading room.  

If these files are not present, the script will skip the file deletion actions.

After running the script, you should expect the following structure, where files are in brackets and directories are not:
```
├───content
│   └───DIP
│       ├───data
│       │   └───[preserved files and directories]
│       └───[readme file for users]
└───documentation
    ├───[convertAIPtoDIP.bat]
    ├───[file deletion logs]
    └───[optional file manifests]
```

**NOTE:** For delivery to users, provide only the DIP directory and its contents.


## Updating the Script Prior to Deposit

**IMPORTANT: You must update the README section within the script file to reflect your organization's process and policies, especially template text in brackets and the "DISCLAIMER" and "NOTICE". This section provides a guide for what you may want to include in your organization’s README file for users.**

Additionally, prior to depositing the script within the AIP into your preservation repository, you should update the first four local variables within the script so that you or others in your organization can simply download the AIP and double-click on the script to run it. Those variables are:  
>set "AIPID=[123456789_AIP_####]"  
set "CollectionName=[collection name]"  
set "DIPName=[collection-name]_access-copies"  
set "DIPManifest=[DRS-FDS-URN]"  

In all cases, replace the text within brackets and remove the brackets. You do not need to follow the naming conventions within the brackets for the script to run properly; update them to suit your local conventions. If you do not have a downloadable DIP manifest, remove the DIPManifest variable and remove the "Born-Digital File List" section of the README file for users.

**NOTE:** Do not alter the convertAIPtoDIPLocation variable that follows these four in the script.


## Running the Script

1.	Download a copy of the AIP from your preservation repository.
2.	If storing your AIP as a Zip file, unpack the file.
3.	If you have restricted file and reading room delivery only manifests, download them and add them to the “documentation” directory.
    - The script will delete all files in these manifests when present, so add them with these rules: always add the restricted file manifest, add the reading room delivery only manifest if providing remote access.
    - If one or both file manifests are not present, the script will simply skip the corresponding deletion steps.
4.	Double-click on convertAIPtoDIP.bat.
5.	The script will begin executing in Windows Terminal.
    - Note: While convertAIPtoDIP.bat itself does not require administrator privileges, your organization may require admin privileges to run any scripts or command line processes.
6.	Follow progress and respond to prompts, which occur only on errors or at the end of the script.
    - Note: BagIt validation time is dependent on the size of the bag and the performance of the computer, networking, and storage you are using. It may take some time to complete for large bags.


## Messaging

convertAIPtoDIP.bat displays progress and error messages in Windows Terminal. Bagit-python displays the progress and results of the validate command, while other script commands execute silently.


## Logging

convertAIPtoDIP.bat logs the results of file deletion process to two sets of logs: [AIP-ID]_Deleted-Files.txt documents the files that the script successfully deleted from the AIP and [AIP-ID]_Deletion-Errors.txt logs any files that were not deleted. [AIP-ID]_Deleted-Files_RR-Only.txt and [AIP-ID]_Deletion-Errors_RR-Only.txt do the same, respectively, for deleting reading room delivery only files when providing remote access. The script names all files by replacing [AIP-ID] with your “AIPID” local variable. The script creates these files in the “documentation” directory.

**NOTE:** Due to how the script checks for successful file deletion, in cases where a file path for deletion does not exist in the AIP (e.g., the path in the list contains a typo), the script will log the path in both the success and error logs (success because the file path does not exist in the AIP and error because the delete command prints an error when it cannot find the file). In all cases, the error log is the definitive log.


## Contributing to Development

The community is invited to contribute to further development by forking a new repository or submitting bug reports and feature requests.

Current development requests include:
Creating a Python version for use across operating systems.


## Change Logs

convertAIPtoDIP.bat version 1.0.0 is the first public release. Change logs are not available for internal beta versions. Going forward, change logs for new versions will be maintained in this space.

Version 1.1.0 -- Includes two bug fixes and one enhancement.

Bug fix: Added quotation marks around all instances of the %AIPLocation% variable to handle spaces in the full path of the AIP directory.

Bug fix: Removed the /s flag from the del command in the sections that delete files from the restricted file list and reading room only file list. The flag was included in error and results in unintended deletion of files with the same name nested in a lower directory. It also results in a script error when the del command deletes lower-nested files via the /s flag when those files are also in the file list(s) for deletion, as the file(s) no longer exist when the del command attempts to delete them.

Enhancement: Changed the way the del command output gets logged in the sections that delete files from the restricted file list and reading room only file list. In version 1.0, the script relied on the standard output (stdout) and standard error (stderr) of the del command to populate the success and error logs. Version 1.1 more robustly confirms file deletion by first using the stderr of the del command and then independently checking for the existence of each file in the file list; if the file does not exist, the path is logged to the success log, if it does exist, it is logged to the error log.

**NOTE:** In cases where a file path in a file list for deletion does not exist in the AIP (e.g., the path in the list contains a typo), the script will log the path in both the success and error logs (success because the file path does not exist in the AIP and error because the del command prints the path as stderr when it cannot find the file). In all cases, the error log is the definitive log.



## License

![CC BY-NC-SA image](https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Cc-by-nc-sa_icon.svg/120px-Cc-by-nc-sa_icon.svg.png)  
[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)

Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International

This license requires that re-users give credit to the creator. It allows re-users to distribute, remix, adapt, and build upon the material in any medium or format, for noncommercial purposes only. If others modify or adapt the material, they must license the modified material under identical terms.


## Disclaimer

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
