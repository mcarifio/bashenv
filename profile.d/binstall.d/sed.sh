#!/usr/bin/env bash

sed -i 's/\$(path.basename "\$0")/\$(path.basename "$(realpath -Lm "\$0")")/' $@
