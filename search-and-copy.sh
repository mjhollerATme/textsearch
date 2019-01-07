#! /bin/bash

getFoldername(){
  local strMaxlength=16
  local mystring=$1
  #local strLength=$(echo -n "$mystring" | wc -c)
  local strLength=${#mystring}
  if [ $strLength -gt $strMaxlength ];then
    local cutLength=$((strLength-strMaxlength))
    mystring=${mystring:0:$strLength-$cutLength}
    mystring+='...'
  fi
  foldername="Search \"$mystring\""
  echo $foldername
}

createFolder(){
  local foldername=$1
  local _foldername=$1
  local i=1
  while [ -d "${storeDir}/${foldername}" ]
  do
    foldername="$_foldername $i"
    i=$((i + 1))
  done
  mkdir "${storeDir}/${foldername}"
  echo "${storeDir}/${foldername}"
}

getDirSetting(){

  local message=$1
  local allowEmptyDir=${2:-"false"}
  theDir="none"

  while [ ! -d "$theDir" ]
  do
    read -e -p "$message" theDir
    if [ "$theDir" == "" ];then
      theDir=$(pwd)
    elif [ ! -d "$theDir" ];then
      echo "$theDir is not a directory"
    elif [ "$allowEmptyDir" == "false" -a -d "$theDir" -a -z "$(ls -A $theDir)" ];then
      echo "The directory is empty"
      theDir="none"
    fi
  done

}

getDirSetting "Enter a Directory to search for (default is the current directory): " false
searchDir=$theDir
echo "Directory to search in: $searchDir"

getDirSetting "Where to Store the results? (default is the search directory): " true
storeDir=$theDir
echo "Search results will be copied to: $storeDir"

while [ ${#searchString} -lt 3 ]
do
  read -p "Enter a String to search for: " searchString
  if [ ${#searchString} -lt 3 ];then
    echo "Minimum 3 characters"
  fi
done

read -p "Do you want to search recursively in $searchDir? (y/n)"
recursiveSearch="false"
if [ -z "$REPLY" -o "$REPLY" == "y" -o "$REPLY" == "yes" ];then
  recursiveSearch="true"
fi

foldername=$(getFoldername "$searchString")
storePath=$(createFolder "$foldername")

if [ $recursiveSearch == "true" ];then
  echo "Searching recursively for '$searchString' in documents in $searchDir and storing in $storePath"
else
  echo "Searching for '$searchString' in documents in $searchDir and storing in $storePath"
fi

searchPattern=$(find $searchDir -maxdepth 1 -name "*" -type f -not -path '*/\.*')
if [ $recursiveSearch == "true" ];then
  searchPattern=$(find $searchDir -name "*" -type f -not -path '*/\.*')
fi

echo "–––––––––––––––––––––––––––––––––––"
foundFiles=0
IFS=$'\n'
for myfile in $searchPattern
do

  containsWord=$(grep -ni "$searchString" $myfile)
  if [ ! -z "$containsWord" ];then

    foundFiles=$((foundFiles + 1))
    cp "$myfile" $storePath
    echo "Found '$searchString' in $(basename $myfile)"

  fi

done

if [ $foundFiles -gt 0 ];then
  echo "Copied $foundFiles Files matching '$searchString' to:"
  echo "$storePath"
else
  echo "No Files found matching '$searchString'!"
  rm -r $storePath
fi
echo "–––––––––––––––––––––––––––––––––––"
echo "Done."
