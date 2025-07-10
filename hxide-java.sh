#!/usr/bin/env bash

run() {
    buffer_name=$1
    package=$(sed -n 's/^package \(.*\);/\1/p' $buffer_name)
    class=$(sed -n 's/^public class \([^{ ]*\).*/\1/p' "$buffer_name")
    main_module=$(echo "$buffer_name" | cut -d/ -f1)

    classpath=""
    if [[ -f pom.xml ]]; then
        if grep -q maven pom.xml; then
            classpath+=$(mvn dependency:build-classpath -Dmdep.outputFile=/dev/stdout -q -DincludeScope=runtime)
            mvn clean install -DskipTests
        fi

        if [[ -f $main_module/pom.xml ]]; then
            mvn -f $main_module/pom.xml spring-boot:run
        else
            mvn spring-boot:run
        fi
    elif [[ -f $main_module/pom.xml ]]; then
        mvn -f $main_module/pom.xml spring-boot:run
    else
        javac $buffer_name
        classpath+=$(dirname "$buffer_name")
        if [[ -n "$package" ]]; then
            java -cp $classpath $package.$class
        else
            java -cp $classpath $class
        fi
    fi
}

test() {
    local dir=$(dirname $1)

    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/pom.xml" ]]; then
            mvn -f "$dir/pom.xml" test
            return
        elif [[ -f "$dir/build.gradle" ]]; then
            cd "$dir" || exit 1
            chmod +x gradlew
            ./gradlew test
            return
        fi
        dir=$(dirname "$dir")
    done

    echo "No Maven or Gradle project found to run tests"
    exit 1
}

if [[ $1 == "run" ]]; then
    shift
    run "$@"
elif [[ $1 == "test" ]]; then
    shift
    test "$@"
else
    echo "Usage: $0 run <file> | test <dir>"
    exit 1
fi
