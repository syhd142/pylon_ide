#!/usr/bin/env bash

# 设置IFS将分割符 设置为 换行符(\n)
OLDIFS=$IFS
IFS=$'\n' 

if [[ -r "$1/_prj/tag_list" ]]; then
    echo "file"
    fileArray=($(cat "$1/_prj/tag_list"))
fi

IFS=$OLDIFS
tLen=${#fileArray[@]}

generate_tag_file () {
    if [[ -d "$1" ]]; then
        tag_name=$(basename "$1")
        echo -e "--- generate "$tag_name"_tags ---\n"
        cd $1
        ctags --tag-relative  --fields=+aimS --languages=php -f $2/$tag_name"_tags"
        mv $2/$tag_name"_tags" $2/_prj/$tag_name"_tags"
        cd $2
        find $1/ -name '*.php'  >> $csfile
    fi

}

csfile="$1"/cscope.file

if [[ -r "$1"  ]]; then
    cd $1
    echo -e "\n--- generate tags ---\n"

    if [[ -r "_prj" ]]; then
        ctags --tag-relative --fields=+aimS -f _prj/tags 
    else
        ctags --fields=+aimS --languages=php 
    fi

    find . -name '*.php'  > $csfile
    find . -name '*.py'  > $csfile
    find . -name '*.html' >> $csfile
    find . -name '*.sh'   >> $csfile
    find . -name '*.conf' >> $csfile
    # find . -name '*.js'   >> $csfile
    find . -name '*.sql'  >> $csfile
    find . -name '*.css'  >> $csfile
    find . -name '*.tpl'  >> $csfile
    # find . -name '*.c'    >> $csfile
    # find . -name '*.h'    >> $csfile
    # find . -name '*.cpp'  >> $csfile

    # 捕获 pylon 框架源码路径，取yaml 文件中第一次匹配 PYLON 的行的 value 值，并去掉引号
    if [[ -r "$1/_rg/svc.yaml" ]]; then
        pylon_src=`awk 'BEGIN{count=0} /PYLON/{ if(count==0){print $NF;} count++}' _rg/svc.yaml | tr -d '"'`
    elif [[ -r "$1/_rg/res.yaml" ]]; then
        pylon_src=`awk 'BEGIN{count=0} /PYLON/{ if(count==0){print $NF;} count++}' _rg/res.yaml | tr -d '"'`
    fi

    if [[ -r $pylon_src ]]; then
        echo -e "--- generate pylon_tags ---\n"
        cd $pylon_src
        ctags --tag-relative  --fields=+aimS --languages=php -f $1/pylon_tags
        mv $1/pylon_tags $1/_prj/pylon_tags
        cd $1
        find $pylon_src/ -name '*.php'  >> $csfile
    fi

    # gerenate pylon_tag end

    for (( i=0; i<${tLen}; i++ ));
    do
        tag_dir="${fileArray[$i]}"
        if [[ -d "$tag_dir" ]]; then
            generate_tag_file $tag_dir $1
        fi
    done

    # 调用 cscope.files 文件生成 cscope.out
    echo -e "--- gererate cscope.out ---\n"
    cscope -b -i $csfile
    rm -rf $csfile
    if [[ -r "_prj" ]]; then
        mv cscope.out _prj/cscope.out
    fi   

    echo -e "--- 提示: 若需要为 cscope/ctags 添加额外目录，"
    echo -e "---       请将目录添加至项目根目录下的「_prj/tag_list」文件中，"
    echo -e "---       多个目录换行分隔即可。"

fi

