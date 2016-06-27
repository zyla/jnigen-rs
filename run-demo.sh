#!/bin/bash

set -e

cd $(dirname $0)

(cd j2rs && stack build)
(cd j2rs && stack exec j2rs) < java.txt > src/java.rs

cargo build
javac main.java X.java
exec java -Djava.library.path=target/debug main
