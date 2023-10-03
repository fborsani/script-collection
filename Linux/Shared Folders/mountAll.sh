#!/bin/bash
/usr/bin/vmhgfs-fuse .host:/ /home/devel/shares -o subtype=vmhgfs-fuse,uid=1000,gid=1000,umask=770


