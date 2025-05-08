#!/usr/bin/env bash

main_file=$(rg -l 'public static void main')
package=$(sed -n 's/^package \(.*\);/\1/p' $main_file)
class=$(sed -n 's/^public class \(.*\) {/\1/p' $main_file)

classpath=$(mvn -q compile exec:exec -Dexec.executable=echo -Dexec.args="%classpath")

java -classpath "$classpath" "$package.$class"

