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

# Pull playground from locally running docker container to this repository.

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


echo "Copying playgrounds from container ${container} to '${tmp}'..."
if ! [ -d "${tmp}" ]; then
    mkdir -p ${tmp}
fi
docker cp "${container}:/usr/share/docassemble/files/" "${tmp}"
echo "Accounts listed: $(ls ${tmp}/files/playground/)"


echo "Copying playground data from account ${account}..."
data="docassemble/SMPDecisionTree/data"
cpd "${tmp}/files/playground/${account}"          "${data}/questions/"
cpd "${tmp}/files/playgroundsources/${account}"   "${data}/sources/"
cpd "${tmp}/files/playgroundstatic/${account}"    "${data}/static/"
cpd "${tmp}/files/playgroundtemplate/${account}"  "${data}/templates/"


if [ ${rm_tmp} == 1 ]; then
    echo "Removing temporary directory."
    rm -rf "${tmp}/"
fi

echo "DONE"
