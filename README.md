<div
  align="center">
  <image
    src="image/logo.svg"
    alt="grub-btrfsd logo"
    width="720px"
    height="480px"
    style="display: block; margin: 0 auto;"
  />
</div>

<h2
  align="center"
  style="font-size: 32px; margin-top: 1em;"
  >
  Introduction
</h2>

**GRUB-BTRFSD** is a fork of the original [grub-btrfs](https://github.com/Antynea/grub-btrfs) project that is designed to work with the [btrfs](https://btrfs.wiki.kernel.org/index.php/Main_Page) filesystem. It provides a way to automatically generate GRUB menu entries for Btrfs snapshots, making it easier to boot into different snapshots of your system.

> **Warning**: booting read-only snapshots can be tricky. If you wish to use read-only snapshots, `/var/log` or even `/var` must be on a separate subvolume. Otherwise, make sure your snapshots are writable. See [this ticket](https://github.com/Antynea/grub-btrfs/issues/92) for more info.

For now refer to the original [documentation](https://github.com/Antynea/grub-btrfs/blob/master/initramfs/readme.md) for more information on how to use grub-btrfsd with read-only snapshots.

<h2
  align="center"
  style="font-size: 32px; margin-top: 1em;"
  >Available Features
</h2>

- Lists snapshots in the configured snapshot directories (e.g. Snapper, Timeshift, Yabsnap or custom directories).
- Detects if `/boot` is a separate partition (e.i. `uefi`).
- Detects kernel, initramfs and binary microcode files.
- Create GRUB menu entries for all detected snapshots.
- Detect the type/tags/triggers and descriptions/comments of Snapper/Timeshift/Yabsnap snapshots.
- Supports booting into read-only snapshots (if configured correctly).
- Automatically updates the GRUB menu when a new snapshot is created or deleted.

<h2
  align="center"
  style="font-size: 32px; margin-top: 1em;"
  >📦 Installation
</h2>

<h3
  style="font-size: 24px; margin-top: 1em;"
  >
  - Debian/Ubuntu -
</h3>

To install **grub-btrfsd** on Debian/Ubuntu follow these steps:

1. Add the repository to your sources list:

    ```bash
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/HowToNebie.gpg] https://repository.howtonebie.com/ stable main" |
    sudo tee /etc/apt/sources.list.d/howtonebie.list
    ```

2. Import the GPG key:

    ```bash
    wget -qO - https://repository.howtonebie.com/key/HowToNebie.gpg | sudo gpg --dearmor -o /usr/share/keyrings/HowToNebie.gpg
    ```

3. Update and install the package:

    ```bash
    sudo apt update && sudo apt install -y grub-btrfsd
    ```

<h3
  style="font-size: 24px; margin-top: 1em;"
  >
  - Kali Linux -
</h3>

**grub-btrfs** is available in the Kali Linux repositories. To install it, run:

```bash
sudo apt install -y grub-btrfs
```

Booting into read-only snapshots is fully supported when choosing btrfs as the file system during a standard Kali Linux installation following [this walk-through](https://www.kali.org/docs/installation/btrfs/).

<h2
  align="center"
  style="font-size: 32px; margin-top: 1em;"
  >Manual Usage of GRUB-BTRFSD
</h2>

To manually generate grub snapshot entries you can run `sudo /etc/grub.d/41_snapshots-btrfs` which updates `grub-btrfs.cfg`. You then need to regenerate the GRUB configuration by running one of the following command `sudo update-grub`.

<h2
  align="center"
  style="font-size: 32px; margin-top: 1em;"
  >Customization
</h2>

You have the possibility to modify many parameters in `/etc/default/grub-btrfsd`. For further information see [default](man/grub-btrfsd-conf.8.md) configuration or `man grub-btrfsd-conf`.

In most cases you will not need to change anything in the configuration file unless you **btrfs** was set up with LUKS encryption or you want to change the default snapshot directory from `/.snapshots` to something else.

<h2
  align="center"
  style="font-size: 32px; margin-top: 1em;"
  >GRUB-BTRFSD Daemon Customization
</h2>

**GRUB-BTRFSD** comes with a daemon script that automatically updates the grub menu when it sees a snapshot being created or deleted in a directory it is given via command line. You must install `inotify-tools` before you can use grub-btrfsd.

The daemon can be configured by passing different command line arguments to it. The available arguments are:

<h3
  style="font-size: 24px; margin-top: 1em;"
  >
  Usage: <code>grub-btrfsd [OPTIONS]* SNAPSHOTS_DIRS</code>
</h3>

This argument specifies the (space separated) paths where grub-btrfsd looks for newly created snapshots and snapshot deletions. It is usually defined by the program used to make snapshots.
E.g. for Snapper or Yabsnap this would be `/.snapshots`. It is possible to define more than one directory here, all directories will inherit the same settings (recursive etc.).
This argument is not necessary to provide if `--timeshift-auto` is set.

**`-c / --no-color`**

> Disable colors in output.

**`-l / --log-file`**

> This arguments specifies a file where grub-btrfsd should write log messages.

**`-r / --recursive`**

> Watch the snapshots directory recursively

**`-s / --syslog`**

> Write log messages to syslog instead of a file. This is useful if you want to see the log messages in your system log viewer (e.g. `journalctl`).

**`-o / --timeshift-old`**

>Look for snapshots in `/run/timeshift/backup/timeshift-btrfs` instead of `/run/timeshift/$PID/backup/timeshift-btrfs.` This is to be used for Timeshift versions <22.06. You must also use `--timeshift-auto` if using this option.

**`-t / --timeshift-auto`**

> This is a flag to activate the auto-detection of the path where Timeshift stores snapshots. Newer versions (>=22.06) of Timeshift mount their snapshots to `/run/timeshift/$PID/backup/timeshift-btrfs`. Where `$PID` is the process ID of the currently running Timeshift session. The PID changes every time Timeshift is opened. grub-btrfsd can automatically take care of the detection of the correct PID and directory if this flag is set. In this case the argument `SNAPSHOTS_DIRS` has no effect.

**`-v / --verbose`**

> Let the log of the daemon be more verbose

**`-h / --help`**

> Displays a short help message.

<h2
  align="center"
  style="font-size: 32px; margin-top: 1em;"
  >
  Auto Updating GRUB Menu with Snapshots Changes
</h2>

**GRUB-BTRFSD** uses the `inotify`-system to monitor directories for changes. This means that it can automatically update the GRUB menu when a new snapshot is created or deleted, without the need to manually run the `grub-btrfsd` script. There is no need to enable this feature, it is enabled by default when you installed through the package manager.

The default directory that is monitored is `/.snapshots`, which is the default directory for [Snapper](https://snapper.io/), [Yabsnap](https://github.com/hirak99/yabsnap), [btrfs-snapshot](https://github.com/MichaelSchaecher/btrfs-snapshot). If you are using a different directory for your snapshots, you can configure the daemon to watch that directory instead. See the instructions below for how to do this.

<h3
  style="font-size: 24px; margin-top: 1em;"
  >
  GRUB-BTRFSD Daemon Instructions
</h3>

There should be no need to start the daemon manually, however, if is not running you can start it with: `sudo systemctl enable --now grub-btrfsd`.

<h3
  style="font-size: 24px; margin-top: 1em;"
  >
  Using Different Snapshot Directories
</h3>

By default the daemon is watching the directory `/.snapshots`. If the daemon should watch a different directory, it can be edited with `
sudo systemctl edit --full grub-btrfsd`. You need to edit the `/.snapshots` part in the line that says `ExecStart=/usr/bin/grub-btrfsd --syslog /.snapshots`.

This is what the file should look like afterwards:

``` ini
[Unit]
Description = Regenerate grub-btrfsd.cfg

[Service]
Type=simple
LogLevelMax=notice
# Set the possible paths for `grub-mkconfig`
Environment="PATH=/sbin:/bin:/usr/sbin:/usr/bin"
# Load environment variables from the configuration
EnvironmentFile=/etc/default/grub-btrfs/config
# Start the daemon, usage of it is:
# grub-btrfsd [-h, --help] [-t, --timeshift-auto] [-l, --log-file LOG_FILE] SNAPSHOTS_DIRS
# SNAPSHOTS_DIRS         Snapshot directories to watch, without effect when --timeshift-auto
# Optional arguments:
# -t, --timeshift-auto  Automatically detect Timeshifts snapshot directory
# -o, --timeshift-old   Activate for timeshift versions <22.06
# -l, --log-file        Specify a logfile to write to
# -v, --verbose         Let the log of the daemon be more verbose
# -s, --syslog          Write to syslog
ExecStart=/usr/bin/grub-btrfsd --syslog /your/custom/snapshots/dir

[Install]
WantedBy=multi-user.target
```

When done, the services should be reloaded, `sudo systemctl daemon-reload`, and the service restarted with `sudo systemctl restart grub-btrfsd`.

<h3
  style="font-size: 24px; margin-top: 1em;"
  >
  Using Timeshift with GRUB-BTRFSD
</h3>

If installed via the package manager, **GRUB-BTRFSD** will automatically detect if **[Timeshift](https://github.com/linuxmint/timeshift)** is installed and will automatically use the correct **SystemD** service file to start the daemon. This means that you do not need to do anything special to use Timeshift with **GRUB-BTRFSD**.

<h2
  align="center"
  style="font-size: 32px; margin-top: 1em;"
  >
  Snapshots With LUKS Encryption
</h2>

The modules required to boot into snapshots with LUKS encryption are not loaded by default, this is because most users do not use disk encryption. To enable support for encrypted snapshots, you need to enable the `GRUB_BTRFS_ENABLE_CRYPTODISK` variable in `/etc/default/grub-btrfsd/config` to load the necessary modules and execute the steps to mount the encrypted root after selecting the snapshot.

<h2
  align="center"
  style="font-size: 32px; margin-top: 1em;"
  >
  Troubleshooting
</h2>

For troubleshooting, please refer to the original [grub-btrfs issues](https://github.com/Antynea/grub-btrfs/issues). For any issues related to installation, configuration or usage of **GRUB-BTRFSD**, please open a new issue on the [grub-btrfsd repository](https://github.com/MichaelSchaecher/grub-btrfsd/issues).

When requesting help or reporting bugs in grub-btrfsd, please run `grub-btrfsd --version` to get the currently running version of **GRUB-BTRFSD**. This is important to include in your ticket, as it helps us to identify the version you are using and to reproduce the issue.

<h2
  align="center"
  style="font-size: 32px; margin-top: 1em;"
  >
  Running GRUB-BTRFSD in Verbose Mode
</h2>

If you have problems with the daemon, you can run it with the `--verbose`-flag. To do so you can run:

``` bash
sudo /usr/bin/grub-btrfsd --verbose --timeshift-auto` (for timeshift)
# or
sudo /usr/bin/grub-btrfsd /.snapshots --verbose` (for snapper/yabsnap)
```

Or pass `--verbose` to the daemon using the Systemd .service file or the OpenRC conf.d file respectively.

For additional information on the daemon and its arguments, run `grub-btrfsd -h` or `man grub-btrfsd`
