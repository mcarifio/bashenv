#!/usr/bin/env bash

busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("restarted by $0")'

