#!/bin/bash
#
#
# ./run_tesi.sh > tesi/tesi.log 2>&1
# nohup ./run_tesi.sh > tesi/tesi.log 2>&1 &

#./run.sh --materiale=tesi --harrvest_from_override="2019-07-01" --jobs=5
# ./run.sh -m=tesi -f="2019-07-01" -j=3

# -a--ambiente=sviluppo|collaudo|esercizio \
# -m=|--materiale=tesi|riviste \
# -c=*|--concurrent_warc_jobs=*)
# [-d|--development] \
# [-f=|--harvest_from_override=YYYY-MM-GG] \
# [-j=|--jobs=] \                           default 3
# [-r=|--repositories_file=elenco_repos] \
# [-s=*|--start_from_block_override=*] \
# [-t=|--today_override=] \
# [-u=*|--warc_block_size_override=*]"      default 5

# --development "
# --today_override="2019_08_23
# --harrvest_from_override="2019-07-15"
# --warc_block_size_override=1
# --start_from_block_override

# ./run.sh --development -m=tesi --jobs=3
# --harrvest_from_override="2018-10-01"
./run.sh --ambiente=sviluppo --materiale=tesi --jobs=3 --concurrent_warc_jobs=3 --harrvest_from_override="1900-01-01"
