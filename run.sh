#!/bin/bash

if [ "$UID" -ne 0 ]; then
  echo "this must be run as root"
  exit 1
fi

working_dir="/root/aol_bounce_hot_patch"
engine_script="$working_dir/reactivate-engine-bounces.sh"
studio_script="$working_dir/reactivate-studio-bounces.rb"

mkdir -p $working_dir
cd $working_dir

if [ -e "/var/hvmail" ]; then
  if [ -e "/var/hvmail/apache/htdocs/ss" ]; then
    echo "Processing GreenArrow Engine and GreenArrow Studio 3 ..."
  else
    echo "Processing GreenArrow Engine ..."
  fi

  curl -fsSL https://raw.githubusercontent.com/drhinternet/aol_bounce_hot_patch/master/reactivate-engine-bounces.sh > $engine_script
  chmod u+x $engine_script
  $engine_script
fi

if [ -e "/var/hvmail/studio" ]; then
  echo "Processing GreenArrow Studio 4 ..."

  curl -fsSL https://raw.githubusercontent.com/drhinternet/aol_bounce_hot_patch/master/reactivate-studio-bounces.rb > $studio_script
  chmod u+x $studio_script

  cd /var/hvmail/studio
  cp -a $studio_script script/reactivate-bounced-subscribers

  if [ ! -e "doc/VERSION.tag" ]; then
    echo "Cannot determine GreenArrow Studio 4's version number. This script will not process its bounces."
  else
    script/reactivate-bounced-subscribers          \
      --no-dry-run                                 \
      --require-start-time '2015-09-01 00:00 CDT'  \
      --require-end-time '2016-04-01 00:00 CDT'    \
      --require-bounce-text-sql-like '%521 5.2.1 :  (CON:B1)  https://postmaster.aol.com/error-codes#554conb1' \
      --print-subscriber                           \
      --print-sql                                  \
      >> /var/hvmail/log/aol_reactivation_studio.log 2>&1
  fi
fi

rm -rf $working_dir

echo "Processing complete! The bad bounces generated from this incident have been cleaned up."
