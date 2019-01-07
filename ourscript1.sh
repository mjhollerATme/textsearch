#! /bin/bash

getDirSetting(){

  local readStr=$1
  local allowEmptyDir=${2:-"false"}
  local theDir=""

  while [ ! -d "$theDir" ]
  do
    read -p "$readStr" theDir
    if [ "$theDir" == "" ];then
      theDir="."
    elif [ ! -d "$theDir" ];then
      echo "$theDir is not a directory"
    elif [ "$allowEmptyDir" == "false" -a -d "$theDir" -a -z "$(ls -A $theDir)" ];then
      echo "The directory is empty"
      theDir=""
    fi
  done
  echo $theDir

}

searchDir=$(getDirSetting "Enter a Directory to search for (default is the current directory): " false)
echo "Selected search directory: $searchDir"

storeDir=$(getDirSetting "Where to Store the results? (default is the search directory): " true)
echo "Search results will be stored in: $storeDir"

while [ ${#searchString} -lt 3 ]
do
  read -p "Enter a String to search for: " searchString
  if [ ${#searchString} -lt 3 ];then
    echo "Minimum 3 characters"
  fi
done

echo "Searching for $searchString in documents in $searchDir and storing in $searchDir"

read -p "Do you want to search recursively in $searchDir? (y/n)";

recursiveSearch="false"
if [ $REPLY == "y" ];then
  recursiveSearch="true"
fi

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

foldername=$(getFoldername "$searchString")

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

storePath=$(createFolder "$foldername")
echo "$storePath"

searchPattern=$(find "$searchDir/*")
if [ $recursiveSearch == "true" ];then
  searchPattern=$(find $searchDir -name "*")
fi

for myfile in $searchPattern
do

  if [ -f "$myfile" ];then
    #echo "$myfile"
    containsWord=$(grep -ni "$searchString" $myfile)
    if [ ! -z "$containsWord" ];then
      echo "$(basename $myfile): Found String"



      dir="$searchString"
      mkdir $dir
      cp "$myfile" $dir
      echo " \n*****************" >> $dir/"$myfile"
      echo "moved inside $dir"
    else
      echo "$(basename $myfile): String not found"
    fi
  else
    echo "$myfile is NOT a file"
    echo " "
  fi
  echo "–––––––––––––––––––––"
done
