#!/bin/bash

TAG_ROOT_PATH="/home/bwu/taghome/"
TAG_PROJECT_NAME="sofia"
TARGET_PATH=`pwd`
TAG_DIRS=
TAG_ARCH="arm"

usage()
{
    echo "                                                                                      "
    echo "Usage: `basename $0` [options]                                                        "
    echo "options:                                                                              "
    echo "      -a   specify architecture, suport arm & x86                                     "
    echo "      -d   specify directory to store tag files                                       "
    echo "      -p   specify project name                                                       "
    echo "      -sd  specify source directories, preferably less equal 3                        "
    echo "                                                                                      "
    echo "example:                                                                              "
    echo "       tag_gen_intel [[-p sofia_lte] [-sd secure_vm mobilevisor testfwk]]             "
    exit
}


if [ $# -eq 0 ] || [ $# -eq 2 ] ;then
    usage
    exit
fi

while [ $# -gt 0 ]
do
    case $1 in
    "-a")
        shift
        if [ $# -le 0 ] || [[ "$1" == "-"* ]] ;then
            echo "please specify architecture"
            exit
        else
            TAG_ARCH=$1
        fi
        shift
    ;;

    "-d")
        shift
        if [ $# -le 0 ] || [[ "$1" == "-"* ]] ;then
            echo "please specifi tag root directory"
            exit
        else
            TAG_ROOT_PATH=$1
        fi
        shift
    ;;
    
    "-p")
        shift
        if [ $# -le 0 ] || [[ "$1" == "-"* ]] ;then
            echo "please specify project name"
            exit
        else
            TAG_PROJECT_NAME=$1
        fi
        shift
    ;;

    "-sd")
        shift
        if [ $# -le 0 ] ;then
            echo "please specify source directory"
            exit
        fi

        count=0
        while [ $# -gt 0 ]
        do
            if [[ "$1" == "-"* ]] ;then
                break
            else
                TAG_DIRS[$count]=$1
                ((count++))
            shift
            fi
        done
    ;;

    *)
        echo "invalid args"
        usage
    ;;

    esac
    
done

TAG_PROJECT_PATH=$TAG_ROOT_PATH$TAG_PROJECT_NAME"/"
[[ -d $TAG_PROJECT_PATH ]] && rm -rf $TAG_PROJECT_PATH
mkdir -p $TAG_PROJECT_PATH

#pushd $TAG_PROJECT_PATH 

for tag_dir in ${TAG_DIRS[*]}
do
    if [ ! -d $tag_dir ] ;then
        echo "The specified fold does not exist, please check."
        exit
    fi
done

rm -rf cscope.files

pushd $TAG_PROJECT_PATH 
for tag_dir in ${TAG_DIRS[*]}
do
    find -L $TARGET_PATH"/"$tag_dir -iname "vmlinux.lds" -o -iname "[mM]akefile" -o -iname "*.[cChHsS]" -o -iname "*.[aA]sm" -o -iname "*.[iI]nc" -o -iname "*.[cC]pp">> cscope.file
done

if [ $TAG_ARCH == "arm" ] ;then
    echo "sed start, arm arch"
    sed -e '/\/tests\/\|Documentation\/\|\/test\/\|\/arch\/[bcfhimnopstux]\|\/arch\/arm64\|\/arch\/arc\|\/arch\/avr32\|\/arch\/alpha\|\/arch\/xtensa/'d cscope.file > cscope.files
    echo "sed end"
else
    echo "sed start, intel arch"
    sed -e '/\/tests\/\|\/test\/\|\/arch\/[abcfhmnopstu]\|\/arch\/xtensa/'d cscope.file > cscope.files
    echo "sed end"
fi

rm -rf cscope.file

echo "cscope file gen"
cscope -Rbq -i cscope.files
echo "cscope file ready"
echo "ctag file gen"
ctags -L cscope.files
echo "ctag file ready"
popd
