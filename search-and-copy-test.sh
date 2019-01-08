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
  local storePath="${storeDir}${foldername}"
  mkdir "${storePath}"
  echo "${storePath}"
}


searchDir="./testdata/"
storeDir="./testdata/searches/"
searchString="Lorem"
recursiveSearch="y"
ignoreSearchDirectories="n"

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
duplicateFiles=0
copiedFiles=0
IFS=$'\n'
for i in $searchPattern
do

  # ignore this directory if has a search.log file inside or is empty
  if [ "$ignoreSearchDirectories" == "y" ] && [ -f "$i/search.log" ];then
    continue
  elif [ -z "$(ls -p "$i" | grep -v /)" ];then
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
        copiedFiles=$((copiedFiles + 1))
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
          duplicateFiles=$((duplicateFiles + 1))
          echo "File did exist but was different"
        else
          echo "File was not different"
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

echo " "
echo "––––––––––––––––––––––––––––––––––"
echo " "
if [ $foundFiles -gt 0 ];then
  echo "Found $foundFiles Files matching '$searchString'. $duplicateFiles of them were duplicates, copied $copiedFiles files to:"
  echo "$storePath"
else
  echo "No Files found matching '$searchString'!"
  rm -r "$storePath"
fi
echo " "
echo "––––––––––––––––––––––––––––––––––"
echo "Done."
