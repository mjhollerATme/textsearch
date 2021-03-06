#! /bin/bash

yesOrNo(){

  local yn="(y/n)"
  local message=$1
  local myvalue="false"

  while [ "$myvalue" != "y" ] && [ "$myvalue" != "n" ]
  do
    read -p "$message $yn" myvalue
    if [ "$myvalue" != "y" ] && [ "$myvalue" != "n" ] && [ ! -z "$myvalue" ];then
      echo "Please type 'y' (yes) or 'n' (no)">&2
    elif [ -z "$myvalue" ]; then
      myvalue="y"
    fi
  done

  echo $myvalue

}

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
  local storePath="${storeDir}${foldername}"
  mkdir "${storePath}"
  echo "${storePath}"
}

promtDirSetting(){

  local message=$1
  local allowEmptyDir=${2:-"false"}
  theDir="none"

  while [ ! -d "$theDir" ]
  do

    enter="none"
    read -p "$message" enter

    if [ "$enter" != "none" ];then
      dirPath=$(osascript -e 'tell application (path to frontmost application as text)
      set myFolder to choose folder
      POSIX path of myFolder
      end' -so)

      if [ -d "$dirPath" ];then
        if [ ! -z "$(ls -pR "$dirPath" | grep -v /)" ];then
          theDir="$dirPath"
        elif [ "$allowEmptyDir" == "true" ];then
          theDir="$dirPath"
        else
          theDir="none"
          message="The directory is empty. Please choose another one"
        fi
      fi
    fi

  done

  echo $theDir

}

# getDirSetting(){
#
#   local message=$1
#   local allowEmptyDir=${2:-"false"}
#   theDir="none"
#
#   while [ ! -d "$theDir" ]
#   do
#     read -e -p "$message" theDir
#     if [ "$theDir" == "" ];then
#       theDir=$(pwd)
#     elif [ ! -d "$theDir" ];then
#       echo "$theDir is not a directory"
#     elif [ "$allowEmptyDir" == "false" -a -d "$theDir" -a -z "$(ls -A "$theDir")" ];then
#       echo "The directory is empty"
#       theDir="none"
#     fi
#   done
#
# }

searchDir=$(promtDirSetting "Hit Enter to choose a Directory to search in" false)
echo " "
echo "  Directory to search in: $searchDir"
echo " "

storeDir=$(promtDirSetting "Hit Enter to choose a Directory to copy the results" true)
echo " "
echo "  Search results will be copied to: $storeDir"
echo " "


while [ ${#searchString} -lt 3 ]
do
  read -p "Enter a String to search for: " searchString
  if [ ${#searchString} -lt 3 ];then
    echo "Minimum 3 characters!"
  fi
done


recursiveSearch=$(yesOrNo "Do you want to search recursively in $searchDir?")
ignoreSearchDirectories=$(yesOrNo "Ignore Search directories?")

foldername=$(getFoldername "$searchString")
storePath=$(createFolder "$foldername")
searchlogPath="${storePath}/search.log"
touch "${searchlogPath}"

echo "–––––––––––––––––––––––––––––––––––"

if [ "$recursiveSearch" == "y" ];then
  searchInfo="Searching recursively for '$searchString' in documents in $searchDir and storing in $storePath"
else
  searchInfo="Searching for '$searchString' in documents in $searchDir and storing in $storePath"
fi
echo "$searchInfo"
echo "$searchInfo" >> "$searchlogPath"
echo "–––––––––––––––––" >> "$searchlogPath"

searchPattern=$(find $searchDir -type d -maxdepth 0)
if [ "$recursiveSearch" == "y" ];then
  searchPattern=$(find $searchDir -type d)
fi

echo " "
foundFiles=0
duplicateDiffFiles=0
duplicateFiles=0
searchStartTime=$(date +%s)

IFS=$'\n'
for i in $searchPattern
do

  # ignore this directory if has a search.log file inside or is empty
  if [ "$ignoreSearchDirectories" == "y" ] && [ -f "$i/search.log" ];then
    continue
  elif [ -z "$(ls -p "$i" | grep -v /)" ];then
    continue
  elif [ $storeDir -ef $i ];then #if this is the newly created folder for results
    continue
  else
    echo " "
    echo "––––––– Folder: $i –––––––"
    echo " "
  fi

  for currFilePath in $(find "$i" -type f -maxdepth 1 -not -path '*/\.*')
  do

    containsWord=$(grep -ni "$searchString" "$currFilePath")
    if [ ! -z "$containsWord" ];then

      foundFiles=$((foundFiles + 1))
      fileBase=$(basename "$currFilePath")
      existingFileCheck="${storePath}/$(basename "$currFilePath")"

      if [ ! -f "$existingFileCheck" ];then #if file with same name does not exist
        cp "$currFilePath" "$storePath" #2>/dev/null #copy file
        echo "File did not exist and was copied"
      elif [ -f "$existingFileCheck" ];then #if file exists
        n=1
        newFilePath="$existingFileCheck"
        isDifferent="true"
        filesToCompare=() # array of all numbered files

        while [ -f "$newFilePath" ] #solange eine Datei mit name x.ext existiert
        do

          # wenn die neue datei auch bereits existiert, wird sie dem vergleichsarray hinzugefügt
          filesToCompare+=("$newFilePath")

          #erste iteration: aktueller dateipfad wird mit existierender datei verflichen
          for currFileToCompare in ${filesToCompare[@]}
          do
            #wenn die aktuelle datei gleich ist mit einer Datei aus dem Array, wird sie nicht kopiert
            if [ "$(diff "$currFilePath" "$currFileToCompare")" == "" ];then #if same
              # if file to copy is not different to one of the files on array, set tp false
              isDifferent="false"
            fi
          done

          #erzeuge einen neuen Dateinamen mit +1
          filename="${fileBase%.*}"
          extension=$([[ "$fileBase" = *.* ]] && echo ".${fileBase##*.}" || echo '')
          newFileName="${filename} ${n}${extension}"
          newFilePath="${storePath}/${newFileName}"

          n=$((n + 1))

        done

        # echo "filesToCompare:"
        # printf '%s\n' "${filesToCompare[@]}"

        if [ "$isDifferent" == "true" ];then
          cp -n "$currFilePath" "$newFilePath" #copy file
          duplicateDiffFiles=$((duplicateDiffFiles + 1))
          echo "Duplicate exists but is different"
        else
          duplicateFiles=$((duplicateFiles + 1))
          echo "Duplicate exists and is not different"
        fi

      fi

      echo "Found '$searchString' in $currFilePath"

      echo "–––––––––––––––––" >> "$searchlogPath"
      echo "$currFilePath:" >> "$searchlogPath"
      echo "–––––––––––––––––" >> "$searchlogPath"
      echo "$containsWord" >> "$searchlogPath"
      echo "––––––––" >> "$searchlogPath"

    fi

  done
done

copiedFiles=$((foundFiles-duplicateFiles))
searchEndTime=$(date +%s)
runtime=$((searchEndTime-searchStartTime))
runtimeSeconds=$(date -r $runtime '+%s')

# runtimeFormatted=$(date -d @runtime '+%Y-%m-%d %H:%M:%S')
# searchDateFormatted=$(date -d @searchStartTime '+%Y-%m-%d %H:%M:%S')

echo " "
echo "––––––––––––––––––––––––––––––––––"
echo " "
echo "Search Time: $(date -r "$searchEndTime")"
echo "Runtime: $runtimeSeconds seconds"
echo " "

if [ $foundFiles -gt 0 ];then
  echo "Found $foundFiles Files matching '$searchString'."
  echo "$duplicateFiles of them were duplicates and were not copied."
  echo "$duplicateDiffFiles of them were duplicates, but with different content."
  echo "copied $copiedFiles files to:"
  echo "$storePath"

  openSearchlog=$(yesOrNo "Open search results folder and search.log?")
  if [ "$openSearchlog" == "y" ];then
    open "$storePath"
    open "$searchlogPath"
  fi
  echo " "
  echo "––––––––––––––––––––––––––––––––––"
  echo "You can find more details in search.log in the search results folder"
  echo " "
else
  echo "No Files found matching '$searchString'!"
  rm -r "$storePath"
  echo " "
  echo "––––––––––––––––––––––––––––––––––"
  echo "Finished."
  echo " "
fi
