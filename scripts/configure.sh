#!/bin/bash -ex

cwd="$(dirname $0)/.."

function usage {
    local base_name=$(basename $0)
    echo "Usage:"
    echo "  $base_name -p <project>"
    echo "  $base_name -f <filename>"
}

project="oss"
variables="$cwd/variables"

while getopts "p:f:" opt; do
    case $opt in
        "p" )
            project="$OPTARG"
            ;;
        "f" )
            variables="$OPTARG"
            ;;
        * )
            usage
            exit 1
            ;;
    esac
done

project_dir="$cwd/projects/$project"
replaces="$project_dir/.variables"

mkdir -p "$project_dir/configs"
mkdir -p "$project_dir/data"

cat $variables | sed -r 's,([^=]+)=(.*),s|\1|\2|g,g' > $replaces

pushd $cwd > /dev/null
    configs="$(find configs -type f -not -path '*/\.*')"
popd > /dev/null

for conf in $configs; do
    mkdir -p "$(dirname $project_dir/$conf)"
    cat $conf | sed -f $replaces > "$project_dir/$conf"
done

echo "Configuration files were created"
