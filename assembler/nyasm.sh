#!/bin/bash

gawk -f nyasm.awk $1 | gawk -f nyasm.awk - $1
