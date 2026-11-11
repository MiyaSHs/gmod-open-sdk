#!/bin/bash

if [ "$1" = "64" ]; then
  echo "64x Build"
  devtools/bin/vpc +jolt /linux64 /define:PLATFORM_64BITS /define:GAME_SDK2013 /define:GAME_GMOD /define:SWDS /mksln jolt
else
  echo "32x Build"
  devtools/bin/vpc +jolt /define:GAME_SDK2013 /define:GAME_GMOD /define:SWDS /define:DEDICATED /mksln jolt
fi