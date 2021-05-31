# EDLUnlock
The name says it all.

Requirements:
-------
- An Android device in EDL mode
- Common sense to not fvck it up

Supported platforms:
-------
- Windows only, for now.

Usage:
-------
- Double click on `EDLUnlock.cmd`, then follow the instructions. <br>
Inside the repo there already is a `.mbn` file + the partition (with its specific `rawprogram0.xml` file) for unlocking a Mi A1 (tissot) thru EDL mode.

How it works:
-------
After some tries (almost 30 lol), found out that the `devinfo` partition (at least on my tissot, my test device) handles bootloader unlock by having a different hex pattern.
Here's an example.

Unlocked bootloader: <br>
![image](https://user-images.githubusercontent.com/19226770/120165641-0f724b00-c1fc-11eb-8af5-839e57b08e65.png)

Locked bootloader: <br>
![image](https://user-images.githubusercontent.com/19226770/120165766-32046400-c1fc-11eb-9cda-5533183fdb75.png)

The same procedure *could* be potentially applied to any other QCOM device (*with a bit of risk*).

Credits:
--------
Huge thanks to @CosmicDan-Android for his [Mi A1 LowLevel Backup/Restore/Flasher tool](https://github.com/CosmicDan-Android/MiA1LowLevelBackupRestoreTool)
