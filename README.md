# Rback

# Usage

```console
$ src/rback -h

Usage: rback -h
       rback [ -v ] [ [ --delete-excluded ] --exclude-file <filename> ] \
           -- UNIT START INTERVAL LIMIT SRC1 [ SRC2 [ ... ] ] DEST
       rback -r [ -v ] [ [ --delete-excluded ] --exclude-file <filename> ] \
           -- UNIT1 START1 INTERVAL1 LIMIT1 UNIT2 START2 INTERVAL2 DEST
  OPTIONS
    -h, --help            Display this help message
    -r, --rotate          Rotate snapshots.  Update snapshots without back up
    -v, --verbose         Enable logging.  Verbose output with timestamps
    -x, --exclude-file    Flag for exclusion file passed to Rsync
    -d, --delete-excluded Flag for deleting excluded backup files and folders
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
