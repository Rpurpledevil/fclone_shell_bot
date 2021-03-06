#!/bin/bash
#=============================================================
# https://github.com/cgkings/fclone_shell_bot
# File Name: fclone shell bot VPS专用
# Author: cgking
# Created Time : 2020.7.8
# Description:极速版-copy
# System Required: Debian/Ubuntu
# Version: final
#=============================================================

clear
IFS=$'\n' 
for input_id in $(cat ~/gclone_shell_bot/任务队列.txt)
do
    ls_info=`fclone lsd goog:{$input_id} --dump bodies -vv 2>&1`
    size_info=`fclone size goog:{$input_id} --checkers=200`
    rootname=$(echo "$ls_info" | awk 'BEGIN{FS="\""}/^{"id/{print $8}')
    idname=$(echo "$ls_info" | awk 'BEGIN{FS="\""}/^{"id/{print $4}')
    file_num=$(echo "$size_info" | awk 'BEGIN{FS=" "}/^Total objects/{print $3}')
    file_size=$(echo "$size_info" | awk 'BEGIN{FS=" "}/^Total size/{print $3,$4}')
    [ -z "$rootname" ] && echo "无效链接" && exit || [ $input_id != $idname ] && echo "链接无效，检查是否有权限" && exit
    echo -e "▣▣▣▣▣▣任务信息▣▣▣▣▣▣\n"
    echo -e "┋资源名称┋:"$rootname"\n"
    echo -e "┋资源地址┋:"$input_id"\n"
    echo -e "┋资源数量┋:"$file_num"\n"
    echo -e "┋资源大小┋:"$file_size"\n"
    echo -e "▣▣▣▣▣▣执行转存▣▣▣▣▣▣"
    fclone copy goog:{$input_id} goog:{myid}/"$rootname" --drive-server-side-across-configs --stats=1s --stats-one-line -vP --checkers=128 --transfers=256 --drive-pacer-min-sleep=1ms  --min-size 10M --check-first
    echo "|▉▉▉▉▉▉▉▉▉▉▉▉|100%  拷贝完毕"
    echo -e "▣▣▣▣▣▣执行比对▣▣▣▣▣▣"
    fclone check goog:{$input_id} goog:{myid}/"$rootname" --size-only --min-size 10M --checkers=128 --drive-pacer-min-sleep=1ms
    echo "|▉▉▉▉▉▉▉▉▉▉▉▉|100%  比对完毕"
    clear
done
: > ~/gclone_shell_bot/任务队列.txt
./fc.sh