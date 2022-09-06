# Rback

# Usage

```console
$ src/rback -h

Usage: rback -h
       rback -- UNIT START INTERVAL LIMIT SRC DEST
       rback -- UNIT1 START1 INTERVAL1 LIMIT1 UNIT2 START2 INTERVAL2 DEST
  OPTIONS
    -h                  Display this help message
  ARGS
    UNIT                Unit of time (minute, hour, day, week, month, etc.)
    START               Integer elapsed start time, time for first snapshot
    INTERVAL            Integer interval of elapsed time between snapshots
    LIMIT               Integer limit of elapsed time, time for last snapshot
    SRC                 Path to source directory or file(s) to be backed up
    DEST                Path to backup folder where snapshots will be stored
```
