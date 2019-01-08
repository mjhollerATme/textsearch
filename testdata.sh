#! /bin/bash

rm -r "./testdata"
mkdir "./testdata"
mkdir "./testdata/searches"

for i in {1..6}
do
  touch "./testdata/my-text-$i.txt"
  echo "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed
  diam nonumy eirmod tempor invidunt ut labore et dolore magna
  aliquyam erat, sed diam voluptua. At vero eos et accusam et
  justo duo dolores et ea rebum. Stet clita kasd gubergren, no
  sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum
  dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod
  tempor invidunt ut labore et dolore magna aliquyam erat, sed diam
  voluptua. At vero eos et accusam et justo duo dolores et ea rebum.
  Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum
  dolor sit amet." > "./testdata/my-text-$i.txt"
done

mkdir "./testdata/testdata-inner-diff"

for i in {1..6}
do
  touch "./testdata/testdata-inner-diff/my-text-$i.txt"
  echo "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed
  diam nonumy eirmod tempor invidunt ut labore et dolore magna
  aliquyam erat, sed diam voluptua. At vero eos et accusam et
  justo duo dolores et ea rebum. Stet clita kasd gubergren, no
  sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum
  dolor sit amet." > "./testdata/testdata-inner-diff/my-text-$i.txt"
done

mkdir "./testdata/testdata-inner-dupl"

for i in {1..6}
do
  touch "./testdata/testdata-inner-dupl/my-text-$i.txt"
  echo "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed
  diam nonumy eirmod tempor invidunt ut labore et dolore magna
  aliquyam erat, sed diam voluptua. At vero eos et accusam et
  justo duo dolores et ea rebum. Stet clita kasd gubergren, no
  sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum
  dolor sit amet." > "./testdata/testdata-inner-dupl/my-text-$i.txt"
done

mkdir "./testdata/testdata-inner-diff2"

for i in {1..6}
do
  touch "./testdata/testdata-inner-diff2/my-text-$i.txt"
  echo "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed
  diam nonumy eirmod tempor invidunt ut labore et dolore magna
  aliquyam erat, sed diam voluptua. At vero<asdfsdf eos et accusam et
  justo duo dolores et ea rebum. Stet clita kasd gubergren, no
  sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum
  dolor sit amet.olores et ea rebum. Stet clita kasd gubergren, no
  sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum
  dolor sit ametolores et ea rebum. Stet clita kasd gubergren, no
  sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum
  dolor sit amet" > "./testdata/testdata-inner-diff2/my-text-$i.txt"
done

mkdir "./testdata/testdata-inner-diff3"

for i in {1..6}
do
  touch "./testdata/testdata-inner-diff3/my-text-$i.txt"
  echo "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed
  diam nonumy ei amet. Lorem ipsum
  dolor sit ametolores et ea rebum. Stet clita kasd gubergren, no
  sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum
  dolor sit amet" > "./testdata/testdata-inner-diff3/my-text-$i.txt"
done

# mkdir "./testdata/testdata-inner3"
#
# for i in {1..6}
# do
#   touch "./testdata/testdata-inner3/my-text-$i.txt"
#   echo "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed
#   diam nonumy eirmod tempor invidunt ut labore et dolore magna
#   aliquyam erat." > "./testdata/testdata-inner3/my-text-$i.txt"
# done
