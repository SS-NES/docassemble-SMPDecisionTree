#!/usr/bin/env bash
#Copyright 2025 Netherlands eScience Center
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

# Push this repository to playground in locally running docker container.

container=""
account=1
tmp="container"
rm_tmp=1

# Process flags.
while getopts a:c:kt: flag; do
case "${flag}" in
    a) if [[ ${OPTARG} =~ ^[1-9][0-9]*$ ]]; then account=${OPTARG}; fi;; # Positive integers only.
    c) container=${OPTARG};;
    k) rm_tmp=0;;
    t) tmp=${OPTARG}; rm_tmp=0;;
esac
done; shift $(($OPTIND - 1));

if [ -z "${container}" ]; then
    container=$(docker ps -q | head -n1 | sed -e 's/\s.*$//')
fi

# Copy the contents of one directory into another,
# possibly creating the destination and its parent directories.
# Also prints the directory copied.
cpd () {
    if [ -d $1 ] && ! [ -z "$(ls -A $1)" ]; then
        echo "    '$1/*' to '$2'"
        if ! [ -d $2 ]; then mkdir -p $2; fi
        cp $1/* $2
    fi
}


echo "Preparing playground for account ${account}..."
if ! [ -d "${tmp}" ]; then
    mkdir -p ${tmp}
fi
data="docassemble/SMPDecisionTree/data"
cpd "${data}/questions"  "${tmp}/files/playground/${account}/"
cpd "${data}/sources"    "${tmp}/files/playgroundsources/${account}/"
cpd "${data}/static"     "${tmp}/files/playgroundstatic/${account}/"
cpd "${data}/templates"  "${tmp}/files/playgroundtemplate/${account}/"


echo "Copying playground from '${tmp}' to container ${container}..."
docker cp "${tmp}/files" "${container}:/usr/share/docassemble/"
docker exec ${container} chmod -R 755 /usr/share/docassemble/files
docker exec ${container} chown -R www-data:www-data /usr/share/docassemble/files


if [ ${rm_tmp} == 1 ]; then
    echo "Removing temporary directory."
    rm -rf "${tmp}/"
fi

echo "DONE"
