#!/bin/bash
# dic.sh - Data Integrity Check

SEP=":"
LOG="dic.log"

show_help()
{
  echo "\
SYNOPSIS
  $0 [OPTIONS] [OPTION PARAM] [PATH]

OPTIONS
  -h --help Shows this help.
  -s --sha  Computes hash values of files in the path.
  -c --cmp  Compares hash values of previous and current runs.
  -d --dup  Finds duplicates files in current hash values.
  -b --bak  Makes backup copy to following directory, e.g.:
            dic.sh -s -b /tmp /path-to-analyse"
  return 0
}

if [ $# -lt 2 ]; then 
  show_help
  exit 0
fi

# Counts amount of lines in a file passed as a parameter.
count()
{
  cat $1 | wc -l | xargs
}

# Calculates duration time for report.
duration()
{
  dur=`expr $(date +%s) - $1`
  printf "%d:%02d:%02d" \
         `expr $dur / 3600` \
         `expr $dur % 3600 / 60` \
         `expr $dur % 60`
}

# Copies files to a directory from last parameter.
backup()
{
  if [ $# -lt 2 ]; then
    return 0
  fi

  cp $@

  if [ $? -ne 0 ]; then
    echo "$NME: cp $@ failed." | tee -a $LOG
    return 1
  fi

  echo "$NME: cp $@." | tee -a $LOG
  return 0
}

DO_SHA=false
DO_CMP=false
DO_DUP=false
DO_BAK=false

# Analazies parameters and set gloabal variables.
while [[ $# > 1 ]]; do
  key="$1"
  shift

  case $key in
    -h|--help)
      show_help
      exit 0
      ;;
    -s|--sha)
      DO_SHA=true
      ;;
    -c|--cmp)
      DO_CMP=true
      ;;
    -d|--dup)
      DO_DUP=true
      ;;
    -b|--bak)
      # Reads next parameter.
      if [ -z "$1" ]; then
        echo "No directory for backup." | tee -a $LOG
        show_help
        exit 1
      fi
      if [ ! -d "$1" ]; then
        echo "Directory not found: $1." | tee -a $LOG
        show_help
        exit 1
      fi
      if [ ! -w "$1" ]; then
        echo "Directory $1 is not writable." | tee -a $LOG
        exit 1
      fi
      DO_BAK=true
      BAK_DIR=$1
      shift
      ;;
    *)
      echo "Unknown option: $key." | tee -a $LOG
      show_help
      exit 1
      ;;
  esac
done

if [ -z $1 ]; then
  show_help
  exit 0
fi

JOB=$(basename $1)
NME=$(date +"%Y%m%d%H%M%S")-$JOB
SHA=$NME-sha

PRV=$JOB-prv
CUR=$JOB-cur
RUN=$JOB-run

UNR=$NME-unr.txt  # List of unread files.
NEW=$NME-new.txt  # List of added files.
OLD=$NME-old.txt  # List of deleted files.
UNC=$NME-unc.txt  # List of unchanged files.
COR=$NME-cor.txt  # List of corrupted files.
DUP=$NME-dup.txt  # List of duplicated files.

# Builds hash value for each file in a directory passed by parameter.
sha()
{
  if (( $# != 1 )); then
    echo "$NME: invalid parameters: $@." | tee -a $LOG
    return 1
  fi

  if [ ! -d $1 ]; then
    echo "$NME: directory not found: $1." | tee -a $LOG
    return 1
  fi

  cnt=0
  beg="$(date +%s)"

  # Omits files from certain directory.
  find "$1" -type f -not -path "*/@eaDir/*" -print0 | tr '\0' '\n' |\
    while read file; do

      # Logs unreadable files.
      if [ ! -r "$file" ]; then
        echo "$(stat -c %A "$file")$SEP$file" >> $UNR
        continue
      fi

      # Gets file size.
      len=$(wc -c "$file" | cut -f 1 -d ' ')

      # Extracts last 40 symbols from openssl result string, SHA1 hash.
      sha=$(openssl dgst -sha1 "$file" 2>/dev/null | tail -c 41)

      # Cuts start path, remains only relative path.
      file=${file/"$1"/}

      # Deletes slash from the beginning if exists.
      file=${file#/}

      # Prints SHA1, file name, file size.
      echo "$sha$SEP$file$SEP$len" >> $SHA

      # Only standart output for process indication. Prints file number.
      ((cnt++))
      echo -ne "$NME: hashing `printf "%06.0f" $cnt` file.\r"
    done

  # Sorts resulted file.
  sort $SHA -o $SHA

  # Provides empty hash file if no hashed files.
  if [ ! -f $SHA ]; then
    touch $SHA
  fi

  # Prints amount of processed file.
  OUT="$NME: hashed `count $SHA`"
  if [ -s $UNR ]; then
    OUT="$OUT, unread `count $UNR`"
  fi

  OUT="$OUT files in `duration $beg`."
  echo $OUT | tee -a $LOG

  if $DO_BAK; then
    backup $SHA $BAK_DIR
  fi

  return 0
}

# Compares two hashed files.
cmp()
{
  if (( $# > 2 )) || (( $# < 1 )); then
    echo "$NME: invalid parameters: $@." | tee -a $LOG
    return 1
  fi

  if [ ! -f $1 ]; then
    echo "$NME: file $1 doesn't exist." | tee -a $LOG
    return 1
  fi

  if [ ! -f $2 ]; then
    echo "$NME: file $2 doesn't exist." | tee -a $LOG
    return 1
  fi

  cnt=0
  beg="$(date +%s)"

  # Prints three files for old, new and unchanged files.
  diff $1 $2 --new-line-format "3 %L" \
             --old-line-format "4 %L"\
             --unchanged-line-format "5 %L" |\
    while read -r fd line; do
      # Extracts file path which is in second column.
      echo "$line" | awk -F $SEP '{print $2}' >&$fd

      # Only standart output for process indication. Prints file number.
      ((cnt++))
      echo -ne "$NME: comparing `printf "%06.0f" $cnt` file.\r"
    done 3> $NEW 4> $OLD 5> $UNC

  # Sorts unchanged files.
  sort $UNC -o $UNC

  # Sorts added (new) files.
  sort $NEW -o $NEW

  # Sorts deleted (old) files.
  sort $OLD -o $OLD

  # Line intersection in old and new lists points to corrupted files.
  comm -12 $OLD $NEW > $COR

  OUT="$NME:"
  if [ -s $COR ]; then
    OUT="$OUT failed with cor `count $COR`"
  else
    OUT="$OUT succeed"
  fi

  OUT="$OUT, compared `count $1` with `count $2`, \
       new:`count $NEW`, old:`count $OLD`, unc:`count $UNC` \
       files in `duration $beg`."

  echo $OUT | tee -a $LOG

  if $DO_BAK; then
    backup $UNC $NEW $OLD $COR $BAK_DIR
  fi

  return 0
}

# Finds duplicate files.
dup()
{
  cnt=0
  lst=""
  dan="false"
  beg="$(date +%s)"

  # hash:file name:file size
  # Sorts following line by SHA1 hash:
  # 7c37a4f97bb6336af8a6dbd08fc38a6182b74d6c:test/d2/d2:3
  sort -t ":" -k1 $1 |\
    while read -r line; do
      # Extracts SHA1 hashes for current and last lines.
      i=$(echo $line | awk -F $SEP '{print $1}')
      j=$(echo $lst | awk -F $SEP '{print $1}')

      # Looks for the same SHA1 hash.
      if [ "$i" == "$j" ]; then

        # Prints corresponded file once.
        if [ $dan == "false" ]; then
          echo $lst | awk -F $SEP '{print $3" "$2}' >> $DUP
          dan="true"
        fi

        echo $line | awk -F $SEP '{print $3" "$2}' >> $DUP
      else
        # Separates between group of duplicated files.
        if [ $dan == "true" ]; then
          dan="false"
        fi
      fi

      # Remembers last procceded line.
      lst=$line

      # Only standart output for process indication. Prints file number.
      ((cnt++))
      echo -ne "$NME: finding duplicates `printf "%06.0f" $cnt` file.\r"
    done

  # Sorts duplicated files by file sizes.
  sort -nr -k1 $DUP -o $DUP

  OUT="$NME: found `count $DUP` duplicates \
       in `count $1` files in `duration $beg`."
  echo $OUT | tee -a $LOG

  if $DO_BAK; then
    backup $DUP $BAK_DIR
  fi

  return 0
}

# Starts here.
cd $(dirname "$0")

# Preserves single job.
if [ -f $RUN ]; then
  echo "$NME: $JOB is already running." | tee -a $LOG
  cd - >/dev/null
  exit 1
fi

# Signs that the process is started.
touch $RUN

if $DO_SHA; then
  # Cleans files from previous run.
  rm -f *-$JOB*.txt

  sha $1

  if [ $? -ne 0 ]; then
    # Removes single job running locker.
    rm $RUN

    cd - >/dev/null
    exit 1
  fi

  # Removes previous sha file if exists.
  if [ -f $PRV ]; then
    rm -f `readlink $PRV`
  fi

  # Switches current link to hash result to previous.
  if [ -f $CUR ]; then
    ln -sf `readlink $CUR` $PRV
  fi

  # Remembers current hash result.
  ln -sf $SHA $CUR
fi

if $DO_CMP; then
  cmp $PRV $CUR

  if [ $? -ne 0 ]; then
    # Removes single job running locker.
    rm $RUN

    cd - >/dev/null
    exit 1
  fi
fi

if $DO_DUP; then
  dup $CUR 

  if [ $? -ne 0 ]; then
    # Removes single job running locker.
    rm $RUN

    cd - >/dev/null
    exit 1
  fi
fi

# Removes single job running locker.
rm $RUN

cd - >/dev/null
exit 0
