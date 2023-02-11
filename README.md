# Rback

##  Introduction

Rback is a [Bash](https://www.gnu.org/software/bash/) wrapper script for [Rsync](https://rsync.samba.org/) backups on [Ubuntu 20.04](https://releases.ubuntu.com/focal/) Linux.  Although there are numerous Rsync-based Bash backup scripts, Rback's collection of features is unique as far as the author can tell (please open an [issue](https://github.com/AlexGose/rback/issues) if you feel otherwise). See the [Rsync-based Bash Backup Scripts](#rsync-based-bash-backup-scripts) section below for more background information.

One of the distinguishing features of Rback is greater control over the structure of your backup snapshot folders, saving space while giving you quick access to past versions of your files at varying intervals of time that you specify.

Consider the following problem.  You have files on your computer's hard drive that need to be backed up regularly in case the hard drive fails.  You would also like to have frequent backups made in case you accidentally delete or modify a file.  So, you decide to have backups made every five minutes to avoid losing too much data when you accidentally delete a file.  Unfortunately, frequent backups like this would quickly use up all the space on your backup hard drive.

A practical solution to this problem is to backup files every five minutes but only keep the most recent past hour of those backups.  You may also want backups every 20 minutes for the most recent past 5 hours and backups every hour between the past 4th and 24th hours.  This is in addition to daily, weekly, and monthly backups that are stored over intervals of time with varying degrees of overlap.  Most Bash backup scripts cannot easily accommodate this type of custom backup scheme, but Rback is designed for it.

## Features and Benefits

- No metadata files
- Supports complex snapshot folder structure
- Extensive bats-core tests
- Gherkin feature files
- Rsync-based for speed
- [Hard links](https://en.wikipedia.org/wiki/Free_and_open-source_software) for space savings
- Strives for Google Shell Style Guide conformance
- [Free and open source](https://en.wikipedia.org/wiki/Free_and_open-source_software)

Rback has a number of benefits.  Detailed metadata, including elapsed time, update intervals, and timestamps for each snapshot, can be stored in each snapshot folder name.  This avoids the need for metadata files, which can be corrupted or lost.  Rback has an extensive set of [bats-core](https://github.com/bats-core/bats-core) tests and [Gherkin](https://cucumber.io/docs/gherkin/reference/) feature files.  The project also strives to conform to the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html).  This makes the project source code easier to read, modify, and maintain.

## Installation

Download the [src/rback](src/rback) file from this repository, or clone the repository if you want to run the tests:

```
git clone https://github.com/AlexGose/rback.git
cd rback
```

Make the script file executable:

```
chmod a+x src/rback
```

## Getting Started

To automate rotation and backups, set up a [Cron](https://en.wikipedia.org/wiki/Cron) job:

```
crontab -e
```

Add the following line to the end of the file to make backup snapshots every five minutes that will be kept for the most recent past hour:

```
*/5   *   *   *   *   /path/to/rback -- minute 5 5 60 /path/to/your/files /path/to/backup/folder
```

To keep snapshots every 20 minutes for the most recent 5 hours, also add this line to the end of the file:

```
*/20   *   *   *   *  /path/to/rback -r -- minute 20 20 300 minute 20 5 /path/to/backup/folder
```

To keep snapshots every hour between the past 4th and 24th hours, also add this line to the end of the file:

```
0   *   *   *   *   /path/to/rback -r -- hour 4 1 24 minute 240 20 /path/to/backup/folder
```

Save and close the file.

## Usage

```console
$ src/rback -h

Usage: rback -h
       rback [ -v ] [ -a ] \
           [ [ --delete-excluded ] --exclude-file <filename> ] \
           -- UNIT START INTERVAL LIMIT SRC1 [ SRC2 [ ... ] ] DEST
       rback -r [ -v ] [ -a ] \
           [ [ --delete-excluded ] --exclude-file <filename> ] \
           -- UNIT1 START1 INTERVAL1 LIMIT1 UNIT2 START2 INTERVAL2 DEST
  OPTIONS
    -h, --help            Display this help message
    -r, --rotate          Rotate snapshots.  Update snapshots without back up
    -v, --verbose         Enable logging.  Verbose output with timestamps
    -x, --exclude-file    Flag for exclusion file passed to Rsync
    -d, --delete-excluded Flag for deleting excluded backup files and folders
    -a, --add-timestamps  Flag to append timestamps to snapshot folder names
  ARGS
    UNIT                  Unit of time (minute, hour, day, week, month, etc.)
    START                 Integer elapsed start time, time for first snapshot
    INTERVAL              Integer interval of elapsed time between snapshots
    LIMIT                 Integer limit of elapsed time, time for last snapshot
    SRC                   Path to source directory or file(s) to be backed up
    DEST                  Path to backup folder where snapshots will be stored
```

## Docker

If you have [Docker](https://docker.com) installed, then build the Docker image using the [Dockerfile](Dockerfile):

```
docker build -t rbacktest .
```

Run the tests in the container:

```
docker run -it --rm -v "${PWD}:/code" --name rbacktest rbacktest
```

## Rsync-based Bash Backup Scripts

Over the past 20 years, many people have written backup programs using Rsync.  The [mikerubel.org](http://www.mikerubel.org/computers/rsync_snapshots/) website lists several in the "Contributed Codes" section.  The website also includes Bash code with detailed commentary.  This is a particularly useful resource if you want to write your own backup program, which is a great way to learn about [Unix-based filesystems](https://en.wikipedia.org/wiki/Unix_filesystem), [hard links](https://en.wikipedia.org/wiki/Hard_link), Bash, and Rsync.

Rsync-based Bash backup scripts continue to be widely used today.  Some are recently developed and very popular, like [rsync-time-backup](https://github.com/laurent22/rsync-time-backup).  These scripts tend to be simple, usually only several hundred lines of code, making the source code easier to read and modify.

Since Bash and Rsync are often available by default on Linux systems, these scripts can be used across many [distributions](https://en.wikipedia.org/wiki/Linux_distribution) without installing additional software.  Rsync provides fast back ups, including those to or from remote machines.

Snapshots based on hard links give the illusion of complete copies of all files for each snapshot, without taking up as much space as full copies.  This allows you to navigate backed up files using the familiar `cd` command or your preferred file manager program, such as [nautilus](https://gitlab.gnome.org/GNOME/nautilus). Opening and viewing files on the backup drive can be done in the same way as you would have on your machine's hard drive just before the backup snapshot was made.

## Acknowledgments

Thank you to the people who contributed to the projects mentioned here.

## Author

Alexander H Gose

## License

[MIT License](LICENSE)
