#!/bin/bash

source /home/peta/petalinux/settings.sh
petalinux-create -t project -s /home/peta/myd_czu3eg_core.bsp
cd /home/peta/myd_zu3eg4ev_2020
petalinux-build -c fsbl
