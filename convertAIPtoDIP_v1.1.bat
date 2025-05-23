::Created by Keith Pendergrass, digital archivist at Baker Library Special Collections and Archives (BLSCA), to transform an Archival Information Package (AIP) organized as a BagIt bag into a Dissemination Information Package (DIP) by validating the BagIt bag, optionally deleting all restricted files found in the accompanying restricted files manifest and all files in the reading room delivery only manifest, removing the BagIt metadata files, removing any empty directories, adding a README file for users, and renaming the AIP directory with the DIP name.

::NOTE: This is a Windows batch file and will run only on Windows operating systems.

::Dependences: Python (https://www.python.org/) and bagit-python (https://github.com/LibraryOfCongress/bagit-python). Python version requirement is found in the bagit-python README file on GitHub. The bagit-python directory must be at C:\Program Files or you must change the directory location of the BagIt search under "echo --Searching for Bagit...".

::There are two optional file manifests that will enable the script's file deletion functions. The manifest files must be text files with the relative path from the "documentation" directory for each file to delete, and each file path on a new line. The manifest files must follow the naming convention of [AIP_ID]_Restricted-Files.txt and [AIP_ID]_RR-Only-Files.txt, where you replace the text inside the brackets with your AIP Identifier and remove the brackets. The script will create log files of the deletion process. [AIP-ID]_Deleted-Files.txt documents the files that the script successfully deleted from the AIP and [AIP-ID]_Deletion-Errors.txt logs any files that were not deleted. [AIP-ID]_Deleted-Files_RR-Only.txt and [AIP-ID]_Deletion-Errors_RR-Only.txt do the same, respectively, for deleting reading room delivery only files when providing remote access. If you do not have manifests of files to delete, the script will simply skip these steps.

::As directory names that held restricted files may also be sensitive, the convertAIPtoDIP script deletes any empty directories in the AIP. NOTE: This will delete all empty directories, not just those made empty by the file deletion process. If you do not want this script to do this, simply remove or comment out the "call :CleanEmptyDir" command and all lines of the corresponding subroutine.

::IMPORTANT: The script expects the internal directory structure required by Harvard's Digital Repository Service (Harvard's preservation repository) for deposits of zip files. Within the zip file, the AIP will be in the "content" directory and the convertAIPtoDIP script will be in the "documentation" directory. To facilitate updates to the restricted file and reading room delivery only manifests, they are stored outside of the zip file. If you have a different directory structure, you will need to modify the section following "echo --Searching for AIP...".

::TO RUN: Download the AIP zip file from your preservation repository and unpack. If available, download the restricted file and reading room delivery only manifests from the preservation repository and add to the unpacked AIP in the "documentation" directory based on these rules: always add the restricted file manifest, add the reading room delivery only manifest if providing remote access. Run the convertAIPtoDIP script and follow the terminal prompts, as needed. See the accompanying readme file for more details.


::Last updated: 2025-05-23
::Version: 1.1

::Version notes:
::1.1 
::Includes two bug fixes and one enhancement.

::Bug fix: Added quotation marks around all instances of the %AIPLocation% variable to handle spaces in the full path of the AIP directory.

::Bug fix: Removed the /s flag from the del command in the sections that delete files from the restricted file list and reading room only file list. The flag was included in error and results in unintended deletion of files with the same name nested in a lower directory. It also results in a script error when the del command deletes lower-nested files via the /s flag when those files are also in the file list(s) for deletion, as the file(s) no longer exist when the del command attempts to delete them.

::Enhancement: Changed the way the del command output gets logged in the sections that delete files from the restricted file list and reading room only file list. In version 1.0, the script relied on the standard output (stdout) and standard error (stderr) of the del command to populate the success and error logs. Version 1.1 more robustly confirms file deletion by first using the stderr of the del command and then independently checking for the existence of each file in the file list; if the file does not exist, the path is logged to the success log, if it does exist, it is logged to the error log.
::NOTE: In cases where a file path for deletion does not exist in the AIP (e.g., the path in the list contains a typo), the script will log the path in both the success and error logs (success because the file path does not exist in the AIP and error because the del command prints the path as stderr when it cannot find the file). In all cases, the error log is the definitive log.


@echo off

::Set variables for the AIP ID, Collection Name, DIP name, DIP Manifest delivery URN, and convertAIPtoDIP script location. Update the first four prior to packaging and deposit, replacing the text within brackets and removing the brackets. Do not alter the convertAIPtoDIPLocation variable.
::NOTE: If you do not have a downloadable DIP manifest, remove the DIPManifest variable and remove the "Born-Digital File List" section of the README file.
setlocal
set "AIPID=[123456789_AIP_####]"
set "CollectionName=[collection name]"
set "DIPName=[collection-name]_access-copies"
set "DIPManifest=[DRS-FDS-URN]"
set "convertAIPtoDIPLocation=%~dp0"


::Variables created automatically in the body of the script:
::AIPLocation for the full path of the AIP directory
::ISODate and shortTime to set the date in the ISO date format of yyyy-mm-dd and time as hh:mm AM/PM (instead of the Windows default date variable of mm/dd/yyyy and default time variable of hh:mm:ss.mm).


echo --Searching for AIP...
echo.

::Change to the "content" directory of the unpacked zip file. Search for the AIP directory and set the full path as the AIPLocation variable.
cd "../content"

for /f "delims=" %%a in ('dir /s /b /a:d "*%AIPID%*"') do (
if exist "%%~a" set "AIPLocation=%%~a"
)


echo --Searching for BagIt...
echo.

::Change path to the local C:\ drive, change directory to "C:\Program Files", then search for the bagit-python directory. If found, change to that directory. This allows for multiple locations or versions of python on different staff computers and for running the script from any drive. Update this section if your bagit-python directory is in a location other than "C:\Program Files".
C:

cd "C:\Program Files"

for /f "delims=" %%c in ('dir /s /b /a:d "*bagit-python*"') do (
if exist "%%~c" cd "%%~c"
)

::The above two directory searches do not contain error reporting. There is a Windows OS "File not found" error that is printed to terminal. If either search fails, the BagIt validation will fail and throw an error message.


echo --Validating BagIt bag...
echo.

::Validate the bag against its manifest.
bagit.py --validate "%AIPLocation%"

::Throw an error message for any validation errors, stop the script, and exit the script after user input. Display a success message and continue if validation is successful.
if %errorlevel% neq 0 (
echo. & echo --ERROR ON BAG VALIDATION. TAKE A SCREENSHOT OF THIS WINDOW AND CONTACT THE DIGITAL ARCHIVIST. & echo. & echo After saving the screenshot, press any key to exit... & pause>nul & exit
) else (
echo. & echo --Success! Completed bag validation. & echo.
)


echo.
echo --Deleting restricted files according to the restricted files manifest...

::Change location to the convertAIPtoDIP script directory, which also contains the restricted files manifest.
cd /d %convertAIPtoDIPLocation%

::If [AIP_ID]_Restricted-Files.txt exists, delete all files listed in [AIP_ID]_Restricted-Files.txt and log the results to [AIP_ID]_Deleted-Files.txt (successful deletion) or [AIP_ID]_Deletion-Errors.txt (errors on deletion).
if exist %AIPID%_Restricted-Files.txt (
for /f "delims=" %%d in (%AIPID%_Restricted-Files.txt) do (
del /f /q "%%d" 2>> %AIPID%_Deletion-Errors.txt
if exist "%%d" (
echo %%d >> %AIPID%_Deletion-Errors.txt
) else (
echo %%d >> %AIPID%_Deleted-Files.txt
))

::Throw an error message for any file deletion errors, stop the script, and exit the script after user input. Display a success message and continue if file deletion is successful, or display a no files to delete message and continue if [AIP_ID]_Restricted-Files.txt is not present.
for %%e in (%AIPID%_Deletion-Errors.txt) do (
if not %%~ze==0 (echo --WARNING! CHECK %AIPID%_DELETION-ERRORS.TXT FOR FILES THAT WERE NOT DELETED. TAKE A SCREENSHOT OF THIS WINDOW AND CONTACT THE DIGITAL ARCHIVIST. & echo. & echo After saving the screenshot, press any key to exit... & pause>nul & exit
) else (
echo --Success! Completed restricted file deletion.
))) else (
echo --No restricted files to delete.
)


echo.
echo --Deleting files according to the reading room delivery only manifest...

::If [AIP_ID]_RR-Only-Files.txt exists, delete all files listed in [AIP_ID]_RR-Only-Files.txt and log the results to [AIP_ID]_Deleted-Files_RR-Only.txt (successful deletion) or [AIP_ID]_Deletion-Errors_RR-Only.txt (errors on deletion).
if exist %AIPID%_RR-Only-Files.txt (
for /f "delims=" %%d in (%AIPID%_RR-Only-Files.txt) do (
del /f /q "%%d" 2>> %AIPID%_Deletion-Errors_RR-Only.txt
if exist "%%d" (
echo %%d >> %AIPID%_Deletion-Errors_RR-Only.txt
) else (
echo %%d >> %AIPID%_Deleted-Files_RR-Only.txt
))

::Throw an error message for any file deletion errors, stop the script, and exit the script after user input. Display a success message and continue if file deletion is successful, or display a no files to delete message and continue if [AIP_ID]_RR-Only-Files.txt is not present.
for %%e in (%AIPID%_Deletion-Errors_RR-Only.txt) do (
if not %%~ze==0 (echo --WARNING! CHECK %AIPID%_DELETION-ERRORS_RR-Only.TXT FOR FILES THAT WERE NOT DELETED when creating a package for remote access. TAKE A SCREENSHOT OF THIS WINDOW AND CONTACT THE DIGITAL ARCHIVIST. & echo. & echo After saving the screenshot, press any key to exit... & pause>nul & exit
) else (
echo --Success! Completed reading room only file deletion.
))) else (
echo --No files to delete for remote access.
)


echo.
echo.
echo --Deleting empty folders...

::Call the clean empty directories subroutine.
call :CleanEmptyDir


echo.
echo --Deleting BagIt metadata files and renaming AIP directory...

::Delete the four required BagIt metadata files.
del "%AIPLocation%"\bag-info.txt
del "%AIPLocation%"\bagit.txt
del "%AIPLocation%"\manifest-md5.txt
del "%AIPLocation%"\tagmanifest-md5.txt


::Set variables for ISODate (yyyy-mm-dd) and shortTime (hh:mm AM/PM) for use in the README file.
set "ISODate=%date:~10,4%-%date:~4,2%-%date:~7,2%"

for /f "tokens=*" %%h in ('time /t') do (
set "shortTime=%%h"
)


::Add a README file for users to the AIPLocation directory.
::IMPORTANT: Update the README file to reflect your organization's process and policies, especially template text in brackets and the DISCLAIMER and NOTICE sections.
echo Using the Materials> "%AIPLocation%"\README.txt
echo.>> "%AIPLocation%"\README.txt
echo In the %DIPName%\data folder, you will find all born-digital files that are open for research. [Your organization] created this access copy of born-digital materials in the %CollectionName% on demand by downloading a preservation copy from [Your organization's digital repository], and then validating the completeness and integrity of the files and deleting any restricted files using a script. The script completed these automated actions on %ISODate% at %shortTime%.>> "%AIPLocation%"\README.txt
echo.>> "%AIPLocation%"\README.txt
echo This collection may contain files in obsolete formats that do not open or render with modern software, or files that require specialized software for access, rendering, and use. [Your organization] can provide rendering software that will render a majority of file formats for use on a computer in [your organization's reading room].>> "%AIPLocation%"\README.txt
if exist %AIPID%_RR-Only-Files.txt (
echo.>> "%AIPLocation%"\README.txt
echo.>> "%AIPLocation%"\README.txt
echo Sensitive and Confidential Information>> "%AIPLocation%"\README.txt
echo.>> "%AIPLocation%"\README.txt
echo Following internal guidelines for access to potentially sensitive or confidential information, [your organization] has limited the access of some files in this collection to [your organization's reading room]. Those files are marked in the born-digital file list noted below and were removed from this remote access copy by the automated script.>> "%AIPLocation%"\README.txt
)
echo.>> "%AIPLocation%"\README.txt
echo.>> "%AIPLocation%"\README.txt
echo Born-Digital File List>> "%AIPLocation%"\README.txt
echo.>> "%AIPLocation%"\README.txt
echo A detailed list of these files with technical metadata is available as a downloadable digital object attached to the collection's finding aid, and is available directly via this link: %DIPManifest%.>> "%AIPLocation%"\README.txt
echo.>> "%AIPLocation%"\README.txt
echo.>> "%AIPLocation%"\README.txt
echo Authenticity>> "%AIPLocation%"\README.txt
echo.>> "%AIPLocation%"\README.txt
echo [Your organization] attests to the authenticity and integrity of the digital files in this access copy and can document provenance, chain of custody, and file fixity information including checksums.>> "%AIPLocation%"\README.txt
echo.>> "%AIPLocation%"\README.txt
echo.>> "%AIPLocation%"\README.txt
echo Original Media Photographs>> "%AIPLocation%"\README.txt
echo.>> "%AIPLocation%"\README.txt
echo Photographs of each original media object are included in the %DIPName%\data\Photographs-of-original-storage-media folder. The photographs capture all creator-supplied labels on the media objects. [Your organization] does not retain original media objects after preservation of the extracted files.>> "%AIPLocation%"\README.txt
echo.>> "%AIPLocation%"\README.txt
echo.>> "%AIPLocation%"\README.txt
echo.----------------------------------------------------------------------->> "%AIPLocation%"\README.txt
echo DISCLAIMER: [Your organization] has scanned the files contained in the %DIPName%\data folder for viruses and other malware prior to deposit in [Your organization's preservation repository], using industry-standard malware definitions available at the time of the scan. [Your organization] does not assume any responsibility or liability for any claim, loss, damage, or other adversity arising from your access to or use of the files in the %DIPName%\data folder (together “Claims”). You voluntarily assume all risks arising from your access to and use of these files, and you hereby release [Your organization] from all Claims. Your access to or use of any single file in the %DIPName%\data folder constitutes acceptance of the terms and conditions set forth herein.>> "%AIPLocation%"\README.txt
echo.----------------------------------------------------------------------->> "%AIPLocation%"\README.txt
echo NOTICE: The copyright law of the United States (Title 17, United States Code) governs the making of reproductions of copyrighted materials. Under certain conditions specified in the law, libraries and archives are authorized to furnish a reproduction. One of the specified conditions is that the reproduction is not to be “used for any purpose other than private study, scholarship, or research.” If a user makes a request for, or later uses, a reproduction for purposes in excess of this “fair use,” that user may be liable for copyright infringement. The user agrees to defend, indemnify, and hold harmless [your organization] against all claims, demands, costs, and expenses incurred by copyright infringement or any other legal or regulatory cause of action arising from the use of [your organization's] materials.>> "%AIPLocation%"\README.txt
echo.----------------------------------------------------------------------->> "%AIPLocation%"\README.txt


::Rename the AIP directory to the DIP name.
ren "%AIPLocation%" %DIPName%

echo --Success! Completed BagIt metadata file deletion and AIP directory renaming.
echo.
echo.
echo --Collection is ready for research access.
if exist %AIPID%_Restricted-Files.txt (
echo See %convertAIPtoDIPLocation%%AIPID%_Deleted-Files.txt for a log of deleted restricted files.
)
if exist %AIPID%_RR-Only-Files.txt (
echo See %convertAIPtoDIPLocation%%AIPID%_Deleted-Files_RR-Only.txt for a log of deleted reading room only files.
)
echo.
echo.
echo.
echo.


::Maintain the terminal window for review.
echo Press any key to exit...
pause>nul

::End the script and close the terminal window.
exit



:CleanEmptyDir
::Clean empty directories subroutine. Find all empty directories and write them to a text file. This only finds the lowest level empty directory if there are nested empty directories, which necessitates a loop of the commands to find and delete empty directories.
for /r "%AIPLocation%" /d %%f in (.) do (
dir /b "%%f" | findstr "^" >nul || echo %%~ff >> %AIPID%_Directories-to-Delete.txt
)

::Delete all empty directories listed in the [AIP_ID]_Directories-to-Delete.txt file, suppressing the error message when [AIP_ID]_Directories-to-Delete.txt is not found.
(
for /f "delims=" %%g in (%AIPID%_Directories-to-Delete.txt) do (
rmdir /q "%%g"
)
)2>nul


::Check for the [AIP_ID]_Directories-to-Delete.txt file. If present, delete the file and restart the CleanEmptyDir subroutine. If not present, report success message and exit to the main routine.
if exist %AIPID%_Directories-to-Delete.txt (
del %AIPID%_Directories-to-Delete.txt & call :CleanEmptyDir
) else (
echo --Success! Completed empty folder deletion. & echo.
)

::End the subroutine.
exit /b