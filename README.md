btrfs-sync
==========

Smart and easy sync of BTRFS snapshots, locally or through SSH. 

![Example](resources/btrfs-sync.gif)

Can be used in conjunction with [btrfs-snp](https://web.archive.org/web/20220531110945/https://ownyourbits.com/2017/12/27/schedule-btrfs-snapshots-with-btrfs-snp/)

```log
# btrfs-sync --verbose --delete /home/user/.snapshots user@server:/media/USBdrive/home-snapshots
* Skip existing '/home/user/.snapshots/monthly_2018-01-09_200102'
* Skip existing '/home/user/.snapshots/monthly_2018-02-08_200102'
* Skip existing '/home/user/.snapshots/weekly_2018-02-09_140102'
* Skip existing '/home/user/.snapshots/weekly_2018-02-16_150102'
* Skip existing '/home/user/.snapshots/weekly_2018-02-23_150102'
* Skip existing '/home/user/.snapshots/weekly_2018-03-02_180102'
* Skip existing '/home/user/.snapshots/daily_2018-03-03_000101'
* Skip existing '/home/user/.snapshots/daily_2018-03-04_080101'
* Skip existing '/home/user/.snapshots/daily_2018-03-05_100102'
* Skip existing '/home/user/.snapshots/daily_2018-03-06_100102'
* Skip existing '/home/user/.snapshots/daily_2018-03-07_110102'
* Synchronizing '/home/user/.snapshots/hourly_2018-03-08_090101' using seed '.snapshots/hourly_2018-03-07_090101'...
time elapsed [0:00:24] | rate [11.1MiB/s] | total size [ 132MiB]
* Synchronizing '/home/user/.snapshots/hourly_2018-03-08_100101' using seed '.snapshots/hourly_2018-03-09_090101'...
time elapsed [0:01:05] | rate [11.1MiB/s] | total size [ 275MiB]
* Deleting non existent snapshots...
Delete subvolume (no-commit): '/media/USBdrive/home-snapshots/hourly_2018-03-08_090101'
Delete subvolume (no-commit): '/media/USBdrive/home-snapshots/hourly_2018-03-08_100101'
```

## Features

- Simple syntax
- Progress indication
- Support for _xz_ or _pbzip2_ compression in order to save bandwidth.
- Retention policy
- Automatic incremental synchronization
- Cron friendly

## Usage

The syntax is similar to that of _scp_

```log
Usage:
  btrfs-sync [options] <src> [<src>...] [[user@]host:]<dir>

  -k|--keep NUM     keep only last <NUM> sync'ed snapshots
  -d|--delete       delete snapshots in <dst> that don't exist in <src>
  -z|--xz           use xz     compression. Saves bandwidth, but uses one CPU
  -Z|--pbzip2       use pbzip2 compression. Saves bandwidth, but uses all CPUs
  -q|--quiet        don't display progress
  -v|--verbose      display more information
  -h|--help         show usage

<src> can either be a single snapshot, or a folder containing snapshots
<user> requires privileged permissions at <host> for the 'btrfs' command
```

## Examples 

### Manual

Synchronize snapshots of _home_ to a USB drive

```bash
# btrfs-sync /home/user/.snapshots /media/USBdrive/home-snapshots
```

Synchronize snapshots of _home_ to a USB drive in another machine

```bash
# btrfs-sync /home/user/.snapshots user@server:/media/USBdrive/home-snapshots
```

Synchronize one snapshot of _home_ to a USB drive in another machine

```bash
# btrfs-sync /home/user/.snapshots/monthly_2018-02-08_200102 user@server:/media/USBdrive/home-snapshots
```

Synchronize only monthly snapshots of _home_ to a USB drive in another machine

```bash
# btrfs-sync /home/user/.snapshots/monthly_* user@server:/media/USBdrive/home-snapshots
```

### Cron 

Daily synchronization over the internet, keep only last 50

```bash
cat > /etc/cron.daily/btrfs-sync <<EOF
#!/bin/bash
/usr/local/sbin/btrfs-sync --quiet --keep 50 --xz /home user@host:/path/to/snaps
EOF
chmod +x /etc/cron.daily/btrfs-sync
```

Daily synchronization in LAN, mirror snapshot directory

```bash
cat > /etc/cron.daily/btrfs-sync <<EOF
#!/bin/bash
/usr/local/sbin/btrfs-sync --quiet --delete /home user@host:/path/to/snaps
EOF
chmod +x /etc/cron.daily/btrfs-sync
```

## Installation

Get the script and make it executable. You can do this in two lines, but better inspect it first. Don’t trust anyone blindly.

```bash
sudo wget https://raw.githubusercontent.com/nachoparker/btrfs-sync/master/btrfs-sync -O /usr/local/sbin/btrfs-sync
sudo chmod +x /usr/local/sbin/btrfs-sync
```

It is recommended to set up a designated user for receiving the snapshots that has sudoers access to the btrfs command.

- Create a btrfs user at the both ends

```bash
sudo adduser btrfs
```

- Create a public key in your sending machine

```bash
sudo -u btrfs ssh-keygen
```

- Give passwordless access to the btrfs user at the remote machine.

```bash
sudo -u btrfs ssh-copy-id btrfs@<ip>
```

- Give permissions to the btrfs user to use the btrfs on both ends. Create a file

```bash
visudo /etc/sudoers.d/90_btrfs-sync
```

with the contents

```bash
btrfs ALL=(root:nobody) NOPASSWD:NOEXEC: /bin/btrfs
```

If you want to run it from cron, you might have to install it first because some distributions have already completely replaced it by systemd timers.

This was the case for me in Arch Linux. In my case, I installed cronie.

cronie logs the output to the system log by default, but you can set an email system if you want old style cron mails.

Also, note that you can use chronic if you only want logging to occur only if something goes wrong.

More at [ownyourbits.com](https://web.archive.org/web/20220528151742/https://ownyourbits.com/2018/03/09/easy-sync-of-btrfs-snapshots-with-btrfs-sync/)
