# 测试
# ./test.sh -d 1  
# ./test.sh -s 1
# ./test.sh -f 1    
aa="abcd"
while getopts ":d:s:" opt;do case $opt in d) aa=2;; s) aa=3;; ?) aa=4;; esac done
echo $aa