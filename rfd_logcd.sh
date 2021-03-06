#!/sbin/busybox sh

while ! busybox grep "/mnt/external_sd" /proc/mounts > /dev/null
do
	busybox sleep 1
done

srcd=/mnt/ram/
dstd=/mnt/external_sd/dumps
busybox rm $dstd/dump.* 
busybox rm /mnt/external_sd/RetroFreak/Games/* 
busybox rm -rf /mnt/external_sd/RetroFreak/Saves/* 
busybox mkdir -p /mnt/external_sd/sram/
busybox mkdir -p /mnt/external_sd/dumps/

# copy log files(/mnt/ram/log/*) to SD(/retrofd/log) if new ones exist
while : ;
do
	busybox find $srcd -maxdepth 1 -type f | busybox sed -e 's/.*\///' | while read logfile
	do
		[ -f "$dstd/$logfile" ] || busybox sleep 5 && busybox cp "$srcd/$logfile" "$dstd/${eromdump}"  
	done
	                   # copy SRAM remove first 24 bits from file and decompress SRAM. crc232 is in bits 16-24 not checked with this code.
                            eromdump=`busybox ls /mnt/external_sd/RetroFreak/Games/`
                            fnesramdump="`busybox find "/mnt/external_sd/RetroFreak/Saves/" -name *.sav | busybox awk -F "/" '{print$8}'`"
                            if [ ! -z "${fnesramdump}" ]
                               then
                                  esramdump=`busybox find /mnt/external_sd/RetroFreak/Saves/ -name *.sav`
    				  busybox tail -c +25 "${esramdump}" > /mnt/external_sd/sram/out.sav-24
                                  busybox printf "\x1f\x8b\x08\x00\x00\x00\x00\x00" | busybox cat - /mnt/external_sd/sram/out.sav-24 | busybox gzip -dc >  "/mnt/external_sd/sram/${fnesramdump}"
                                  busybox rm -rf /mnt/external_sd/RetroFreak/Saves/*
                                  busybox rm /mnt/external_sd/sram/out.sav-24
                            fi
                            busybox rm /mnt/external_sd/RetroFreak/Games/*
                            busybox rm $dstd/dump.* 
	busybox sleep 1
done
