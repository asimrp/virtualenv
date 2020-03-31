#!/bin/bash

# Adjust this to point to your greenplum installation directory.
#export PATH=/home/heikki/gpdb.master/bin:$PATH
export PATH=./bin:$PATH

export LD_LIBRARY_PATH=~/gpdb/orca-install/lib

BASE_PORT=40000
MASTER_PORT=5432

set -e

# Adjust this to set the number of segment servers to set up. Two is the
# minimum that makes sense.
NUM_SEGMENTS=3

initdb -k -n -D data-master
#initdb -n -D data-master

cat >> data-master/postgresql.conf <<EOF
max_connections=150
shared_buffers=64MB
#max_fsm_relations=10
#max_fsm_pages = 10000
port=$MASTER_PORT
listen_addresses='127.0.0.1, ::1'
EOF

for (( i=0; i<$NUM_SEGMENTS; i++ ))
do
    #bin/initdb -D data-seg$i
    # It's faster to copy the freshly-initdb'd master cluster than run initdb..
    cp -a data-master data-seg$i
done

cat >> data-master/postgresql.conf <<EOF
gp_dbid=1
gp_contentid=-1
#gp_num_contents_in_cluster=$NUM_SEGMENTS
fsync=off
optimizer=off
EOF

for (( i=0; i<$NUM_SEGMENTS; i++ ))
do
  cat >> data-seg$i/postgresql.conf <<EOF
gp_dbid=$(($i + 2))
gp_contentid=$i
#gp_num_contents_in_cluster=$NUM_SEGMENTS
port=$(($BASE_PORT + $i))
fsync=off
EOF
done

ABSPATH=$(realpath .)

postgres --single -D data-master postgres <<EOF
insert into gp_segment_configuration (dbid, content, role, preferred_role, mode, status, port, hostname, address) values (1, -1, 'p', 'p', 's', 'u', $MASTER_PORT, 'localhost', 'localhost');
insert into gp_segment_configuration (dbid, content, role, preferred_role, mode, status, port, hostname, address) select g+1, g-1, 'p', 'p', 's', 'u', $BASE_PORT+g-1, 'localhost', 'localhost' from generate_series(1, $NUM_SEGMENTS) g;
--insert into pg_filespace_entry values (3052, 1, '$ABSPATH/data-master');
--insert into pg_filespace_entry select 3052, g+1, '$ABSPATH/data-seg' || (g-1) from generate_series(1, $NUM_SEGMENTS) g;
--insert into gp_fault_strategy values ('n');
EOF

for (( i=0; i<$NUM_SEGMENTS; i++ ))
do
postgres --single -D data-seg$i postgres <<EOF
insert into gp_segment_configuration (dbid, content, role, preferred_role, mode, status, port, hostname, address) values (1, -1, 'p', 'p', 's', 'u', $MASTER_PORT, 'localhost', 'localhost');
insert into gp_segment_configuration (dbid, content, role, preferred_role, mode, status, port, hostname, address) select g+1, g-1, 'p', 'p', 's', 'u', $BASE_PORT+g-1, 'localhost', 'localhost' from generate_series(1, $NUM_SEGMENTS) g;
--insert into pg_filespace_entry values (3052, 1, '$ABSPATH/data-master');
--insert into pg_filespace_entry select 3052, g+1, '$ABSPATH/data-seg' || (g-1) from generate_series(1, $NUM_SEGMENTS) g;
--insert into gp_fault_strategy values ('n');
EOF
done

