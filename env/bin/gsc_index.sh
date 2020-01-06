#!/bin/bash
# generate source code index

file_list=sc_files.list
workdir=`pwd`
workdir=${workdir//\//\\\/}
search_dir="."
droid_dir=(art bionic bootable device external frameworks hardware libcore \
           libnativehelper packages system)

function usage()
{
cat << EOF
usage: gsc_index.sh [-a dir] or [-c dir]
  -a dir    generate ctags and cscope index for android specific source code dir
  -c dir    generate ctags and cscope index for current source code dir
EOF
}

function cleanup
{
    echo "remove cscope index and ctags files..."
    rm cscope.in.out > /dev/null 2>&1
    rm cscope.out > /dev/null 2>&1
    rm cscope.po.out > /dev/null 2>&1
    rm .tags > /dev/null 2>&1
}

function generate_index
{
    find ${search_dir} -type f -iname "*.[h|c]*" -o -iname "*.java" > ${file_list}

    # generate ctags index
    sed -i -e "s/^\.\{0,1\}\/\{0,1\}/$workdir\//g" ${file_list}
    ctags -aR -h ".h.H.hh.hpp.hxx.h++.inc.def" --output-format=e-ctags -L ${file_list} -f .tags

    # generate cscope index
    # cscope needs file path starts with double quote(")
    sed -i 's/^/"/;s/$/"/' ${file_list}
    cscope -bkqUv -i ${file_list}

    # delete file list
    rm ${file_list}
}

OPTIND=1

while getopts ":acr" args;
do
    case $args in
    a)
        cleanup
        echo "generate android source code index..."
        search_dir=${droid_dir[@]}
        generate_index;;
    c)
        cleanup
        echo "generate source code index in current directory..."
        generate_index;;
    r)
        cleanup
        exit 1;;
    *)
        echo "unknown parameter!"
        exit 1;;
    esac
done

if [ $# -eq 0 -o $OPTIND -eq 1 ]; then
    usage
    exit 1
fi
