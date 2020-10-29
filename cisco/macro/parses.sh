#/bin/bash

#cat 2020-felev-1.sql | cut -d' ' -f4 | cut -d',' -f1 | cut -d'(' -f2
#INSERT INTO `pka` VALUES (325,'ADH4QV','3.2.1.8','out_17_3.2.1.8 Packet Tracer - Configuring RIPv2_RSE.pka','poisheizoghafaef','hohgaijevaquiefu','0')
#INSERTI=$(cat /home/user/Desktop/cisco/macro/2020-felev-1.sql | cut -d' ' -f-4 | head -$i | tail -1)
#INSERTII=$(cat /home/user/Desktop/cisco/macro/2020-felev-1.sql | cut -d' ' -f5- | cut -d',' -f2- | head -$i | tail -1)

for i in $(seq 1 396)
do
	INSERTII=$(cat /home/user/Desktop/cisco/macro/2020-felev-1.sql | cut -d' ' -f5- | cut -d',' -f2- | grep _ITN | head -$i | tail -1)

	echo "INSERT INTO \`pka\` VALUES ($i,$INSERTII" >> /home/user/Desktop/cisco/macro/final.sql
done

for i in $(seq 1 836)
do
        INSERTII=$(cat /home/user/Desktop/cisco/macro/2020-felev-1.sql | cut -d' ' -f5- | cut -d',' -f2- | grep _RSE | head -$i | tail -1)
	j=$(expr $i + 396)
        echo "INSERT INTO \`pka\` VALUES ($j,$INSERTII" >> /home/user/Desktop/cisco/macro/final.sql
done

