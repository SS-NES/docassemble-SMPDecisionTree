#!/bin/bash
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

# Process flags.
while getopts c:a:t: flag; do
case "${flag}" in
    c) container=${OPTARG};;
    a) if [[ ${OPTARG} =~ ^[1-9][0-9]*$ ]]; then account=${OPTARG}; fi;; # Positive integers only.
    t) tmp=${OPTARG};;
esac
done; shift $(($OPTIND - 1));

if [ -z "${container}" ]; then
    container=$(docker ps -q | head -n1 | sed -e 's/\s.*$//')
fi

echo "Preparing playground for account ${account}..."
if ! [ -d "${tmp}" ]; then
    mkdir -p ${tmp}
fi
cpd () {
    if [ -d $1 ] && ! [ -z "$(ls -A $1)" ]; then
        echo "    '$1/*' to '$2'"
        if ! [ -d $2 ]; then mkdir -p $2; fi
        cp $1/* $2
    fi
}
data="docassemble/SMPDecisionTree/data"
cpd "${data}/questions"  "${tmp}/files/playground/${account}/"
cpd "${data}/sources"    "${tmp}/files/playgroundsources/${account}/"
cpd "${data}/static"     "${tmp}/files/playgroundstatic/${account}/"
cpd "${data}/templates"  "${tmp}/files/playgroundtemplate/${account}/"

echo "Copying playground from '${tmp}' to container ${container}..."
docker cp "${tmp}/files" "${container}:/usr/share/docassemble/"
docker exec ${container} chmod -R 755 /usr/share/docassemble/files
docker exec ${container} chown -R www-data:www-data /usr/share/docassemble/files

echo "DONE"
