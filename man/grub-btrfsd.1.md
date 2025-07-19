---
title: GRUB-BTRFSD
section: 1
header: User Commands
footer: grub-btrfsd(1)
date: 2025-03-29
author:
    - Michael Lee Schaecher
    - Pascal Jäger
---

# NAME

grub-btrfsd - An OpenRC daemon to automatically update the grub menu
with _grub-btrfs__(8)

when a new btrfs snapshot is created.

# SYNOPSIS

`grub-btrfsd [-h, --help] [-c, --no-color] [-r, --recursive] [-s, --syslog] [-t, --timeshift-auto] [-o, --timeshift-old] [-v, --verbose] SNAPSHOTS_DIRS`

# DESCRIPTION

Grub-btrfsd is a shell script which is meant to be run as a daemon. Grub-btrfsd watches a directory where btrfs-snapshots are created or deleted via inotifywait and runs grub-mkconfig (if grub-mkconfig never ran before since grub-btrfs was installed) or `/etc/grub.d/41_snapshots-btrfs` (when grub-mkconfig ran before with grub-btrfs installed) when something in that directory changes.

# OPTIONS

## `SNAPSHOTS_DIRS`

This argument specifies the (space separated) paths where grub-btrfsd looks for newly created snapshots and snapshot deletions. It is usually defined by the program used to make snapshots. E.g. for Snapper this would be `/.snapshots`. It is possible to define more than one directory here, all directories will inherit the same settings (recursive etc.). This argument is not necessary to provide if `--timeshift-auto` is set.

_-r_  _--recursive_
: Watch snapshot directories recursively. This is useful if the snapshots are stored in subdirectories of the specified directories. If this flag is not set, only the specified directories are watched.

_-s_, _--syslog_
: Write the output of the daemon to syslog (NOTE: this option will be deprecated in the future. Making the daemon write to syslog the default behavior). If this flag is not set no logging is done. However, messages are printed to stdout and stderr.

_-t_, _--timeshift-auto_
: This is a flag to activate the auto detection of the path where Timeshift stores snapshots. Newer versions (\>=22.06) of Timeshift mount their snapshots to `/run/timeshift/$PID/backup/timeshift-btrfs`. Where `$PID` is the process ID of the currently running Timeshift session. The PID is changing every time Timeshift is opened. grub-btrfsd can automatically take care of the detection of the correct PID and directory if this flag is set. In this case the argument `SNAPSHOTS_DIRS` has no effect.

_-o_, _--timeshift-old_
: Look for snapshots in `/run/timeshift/backup/timeshift-btrfs` instead of `/run/timeshift/$PID/backup/timeshift-btrfs`. This is to be used for Timeshift versions \<22.06.

_-v_, _--verbose_
: Enable verbose output for the `inotifywait` command. This will print the events that are being watched for, which can be useful for debugging purposes.

_-h_, _--help_
: Displays a short help message.

# CONFIGURATION

The daemon is usually configured via the file `/etc/conf.d/grub-btrfsd` on openrc-init systems and `sudo systemctl edit --full grub-btrfsd` on systemd systems. In this file the arguments (See OPTIONS), that OpenRC passes to the daemon when it is started, can be configured.

## NOTES

A common configuration for Snapper would be to set `SNAPSHOTS_DIR` to `/.snapshots` and not to set `--timeshift-auto`. For Timeshift `--timeshift-auto` is set to true and `SNAPSHOTS_DIR` can be left as is.

# FILES

`/etc/conf.d/grub-btrfsd` `/usr/lib/systemd/system/grub-btrfsd.service`

# SEE ALSO

_btrfs_(8) _btrfs-subvolume_(8) _grub-btrfsd-conf_(8) _grub-mkconfig_(8)
_inotifywait_(1) _openrc_(8) _rc-service_(8) _timeshift_(1)

# COPYRIGHT

Copyright (c) 2022 Pascal Jäger
Copyright (c) 2025 Michael Lee Schaecher
