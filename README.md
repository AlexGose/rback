# Rback

##  Introduction

Rback is a [Bash](https://www.gnu.org/software/bash/) wrapper script for [Rsync](https://rsync.samba.org/) backups on [Ubuntu 20.04](https://releases.ubuntu.com/focal/) Linux.  Although there are numerous Rsync-based Bash backup scripts, Rback's collection of features is unique as far as the author can tell (please open an [issue](https://github.com/AlexGose/rback/issues) if you feel otherwise).

One of the distinguishing features of Rback is greater control over the structure of your backup snapshot folders, saving space while giving you quick access to past versions of your files at varying intervals of time that you specify.

Consider the following problem.  You have files on your computer's hard drive that need to be backed up regularly in case the hard drive fails.  You would also like to have frequent backups made in case you accidentally delete or modify a file.  So, you decide to have backups made every five minutes to avoid losing too much data when you accidentally delete a file.  Unfortunately, frequent backups like this would quickly use up all the space on your backup hard drive.

A practical solution to this problem is to backup files every five minutes but only keep the most recent past hour of those backups.  You may also want backups every 20 minutes for the most recent past 5 hours and backups every hour between the past 4th and 24th hours.  This is in addition to daily, weekly, and monthly backups that are stored over intervals of time with varying degrees of overlap.  Most Bash backup scripts cannot easily accommodate this type of custom backup scheme, but Rback is specifically designed for it.

Rback has a number of other benefits.  Detailed metadata, including elapsed time, update intervals, and timestamps for each snapshot, can be stored in each snapshot folder name.  This avoids the need for metadata files, which can be corrupted or lost.  Rback has an extensive set of [bats-core](https://github.com/bats-core/bats-core) tests and [Gherkin](https://cucumber.io/docs/gherkin/reference/) feature files.  The project also strives to conform to the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html).  This makes the project source code easier to read, modify, and maintain.

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
