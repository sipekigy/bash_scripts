#!/bin/bash
# Gyula Sipeki
# daily snapshot task and dynamic removal

VMID_LIST=$(vim-cmd vmsvc/getallvms|grep -E "*\.vmx"|cut -d " " -f1)
#VMID_LIST=40


for VMID in $VMID_LIST; do
   SNAPSHOTS=$(vim-cmd vmsvc/snapshot.get $VMID | grep "Snapshot Id" | cut -d ":" -f 2 || echo 0)
   echo "$SNAPSHOTS"
   SNAPSHOT_COUNTER=$(echo -e "$SNAPSHOTS"| wc -l)
   OLDEST_SNAPSHOT_ID=$(echo -e "$SNAPSHOTS"| head -n 1)

   while [ $SNAPSHOT_COUNTER -gt 3 ]
   do
     vim-cmd vmsvc/snapshot.remove $VMID $OLDEST_SNAPSHOT_ID
     SNAPSHOTS=$(vim-cmd vmsvc/snapshot.get $VMID | grep "Snapshot Id" | cut -d ":" -f 2)
     SNAPSHOT_COUNTER=$(echo -e "$SNAPSHOTS"| wc -l)
     OLDEST_SNAPSHOT_ID=$(echo -e "$SNAPSHOTS"| head -n 1)
   done

   sleep 60
   vim-cmd vmsvc/snapshot.create $VMID auto-snap-$(date -I)


done

