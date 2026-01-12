#!/bin/bash

gawk -f nyasm.awk $* | gawk -f nyasm.awk - $*
