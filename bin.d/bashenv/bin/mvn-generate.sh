#!/usr/bin/env bash

# more info: mvn archetype:help -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4 -Ddetail=true -Dgoal=generate

artifactId=${1:?'need project name'}
outputDirectory=${2:-${HOME}/IdeaProjects}
target=${outputDirectory}/${artifactId}
                  
mvn archetype:generate -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4 -DinteractiveMode=false -DgroupId=${USER} -DartifactId=${artifactId} -DoutputDirectory=${outputDirectory}

ext=${target}/.mvn
mkdir -v -p ${ext}
cat<<EOF > ${ext}/extensions.xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- https://raw.githubusercontent.com/takari/polyglot-maven-examples/master/kotlin/.mvn/extensions.xml -->
<extensions>
  <extension>
    <groupId>io.takari.polyglot</groupId>
    <artifactId>polyglot-kotlin</artifactId>
    <version>0.4.4</version>
  </extension>
</extensions>
EOF

cd ${target}
for d in $(find . -type d -name java); do mkdir -v -p ${d//java/kotlin} ; done
mvn io.takari.polyglot:polyglot-translate-plugin:translate -Dinput=pom.xml -Doutput=pom.kts
xz pom.xml


