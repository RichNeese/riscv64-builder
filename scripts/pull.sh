#!/bin/bash

git pull --rebase --no-edit git@github.com:beagleboard/image-builder.git master
git pull --rebase --no-edit git@github.com:beagleboard/image-builder.git master --tags
git pull --rebase --no-edit git@github.com:RobertCNelson/omap-image-builder.git master
git pull --rebase --no-edit git@github.com:RobertCNelson/omap-image-builder.git master --tags

