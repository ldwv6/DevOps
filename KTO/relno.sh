#!/bin/sh

bindir=`dirname $0`
rootdir=`realpath $bindir/..`
cd $rootdir

today=`date +%Y%m%d`

logdir=$rootdir/logs
logfile=$logdir/relno-$today.log


git pull >$logfile 2>&1
if [ $? -ne 0 ]; then
  echo "Git pull failed!" 1>&2
  exit 1
fi


CMD=$1; shift
case $CMD in
  new)
    comment="$1"; shift
    if [ -z "$comment" ]; then
      echo "Comment가 지정되지 않았습니다." 1>&2
      exit 1
    fi

    cur_relno=`head -1 data/relno.txt`

    date=`echo $cur_relno | sed -e 's/-.*$//'`
    seq=`echo $cur_relno | sed -e 's/^.*-//'`

    if [ "$date" = "$today" ]; then
      seq=`expr $seq + 1`
    else
      date=$today
      seq=1
    fi

    new_relno=`printf "%s-%02d" $date $seq`
    comment1=`echo $comment | sed -e 's!"!\\"!g'`
    comment2=`echo $comment | sed -e 's!"!\\\\"!g'`

    echo $new_relno >data/relno.txt
    echo "{\"relno\":\"${new_relno}\",\"comment\":\"${comment2}\"}" >data/relno.json

    echo "RELNO: ${new_relno}" 1>&2
    echo "COMMENT: ${comment}" 1>&2

    (git add data/relno.txt data/relno.json && \
    git commit -m "${new_relno}: ${comment1}" && \
    git push origin master) 1>&2

    head -1 data/relno.txt
    ;;

  release)
    cur_relno=`head -1 data/relno.txt`

    date=`echo $cur_relno | sed -e 's/-.*$//'`
    seq=`echo $cur_relno | sed -e 's/^.*-//'`



    if [[ "$date" = "$today" && "$seq" = "00" ]]; then
      echo "$date 오늘 정규 반영이 이미 진행되었습니다. 다시한번 확인필요!!" 1>&2
      exit 1
    else
      date=$today
      seq=0
      new_relno=`printf "%s-%02d" $date $seq`

      comment="$date 운영서버 정규반영"

      echo $new_relno >data/relno.txt
      echo "{\"relno\":\"${new_relno}\",\"comment\":\"${comment}\"}" >data/relno.json

      echo "RELNO: ${new_relno}" 1>&2
      echo "COMMENT: ${comment}" 1>&2

      (git add data/relno.txt data/relno.json && \
      git commit -m "${new_relno}: ${comment}" && \
      git push origin master) 1>&2

      head -1 data/relno.txt
    fi
    ;;

  get)
    head -1 data/relno.txt
    ;;

  json)
    cat data/relno.json
    ;;



  *)
    echo "relno { get | json | new comment }"
    ;;
esac
