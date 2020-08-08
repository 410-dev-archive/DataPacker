# DataPacker
Secure & Simple Backup tool



### Disclaimer



### What does this backup?

- User directory which contains:
  - Desktop
  - Documents
  - Downloads
  - Music
  - Pictures
- Installed Applications
  - Apps installed with package installer will not be backed up properly.



### What are the things that cannot be backed up?

- Operating System
- Other disk partitions
- User library
  - Application data
  - Preferences



### Why are thy not backed up?

- Those are too large to back up.
- Those data contains sensitive information (Not related to privacy, but to system), so overwriting them with old data may cause system failure.



### FAQ

- The backup / restore is taking very long.
  - A: Don't worry, because the apps and user files can be larger than you expect, which can make the copy time long. It may take up to several hours to complete the backup.
- After pressing the start button, the app don't respond until the backup is done.
  - A: It is normal. The software is intentionally designed to become not responsive when running backup, due to spare of system resources.
- The password changes after I press start button. (Becomes super long)
  - A: It is intentionally designed to convert the original password to longer one for security reason. For example, if your password is "hello", then it is converted something like this: b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86. (This is not the actual output!)
- I cannot open the backup file in Finder.
  - A: The answer is same as above.
- Can I use my computer while backing up / restoring?
  - A: You may use your computer ONLY WHILE RUNNING BACKUP. You may not use while restoring. (Restoring takes significantly less amount of time compare to backup, so please wait.)

