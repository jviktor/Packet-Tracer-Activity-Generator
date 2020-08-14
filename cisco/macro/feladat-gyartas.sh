#!/bin/bash
IFS=$(echo -en "\n\b")

neptunkod=()

#Smart sleep function with countdown in terminal, use integer parameters only!!!
function sleep {
	for i in `seq $1 -1 1`
	do
		echo -ne "$i "
		/bin/sleep 1
	done
	echo ""
}

#Custom type function, xdotool type is unreliable
function type {
	log "Typing $1"
	for char in `echo "$1" | grep -o .`
	do
		xdotool type "$char"
		/bin/sleep 0.01
	done
}

#Packet Tracer starter with opening source file
function start {
	log "Starting Packet Tracer opening $1"
	packettracer $1 &>/dev/null &
	sleep 20 #should be enough
	enter
}

#Set focus to the desired window
function focus {
	user=(whoami)
	log "searching for $1"
#	workdir="/home/${user}/Desktop/cisco"
#	pkas=`ls $workdir -1 -v | grep pka | grep -v out_`
	pt_window=`xdotool search --name "$1"`
	sleep 1
#	log "activating window $1"
#	xdotool windowactivate $pt_window
#	sleep 5
	log "setting focus to $1"
	xdotool windowfocus $pt_window
	sleep 3
}

#Custom function for pressing enter
function enter {
	log "pressing enter"
	xdotool key Return
	sleep 1
}

#Open Activity Wizard in PT using default .pka pass
function activate_activity_wizard {
	log "activate_activity_wizard"
	xdotool key "ctrl+w"
	sleep 1
	log "typing password"	
	type "PT_ccna5"
	sleep 1
	enter
}

#Agressively shut down PT
function cleanup {
	log "killing Packet Tracer"
	killall -9 PacketTracer7
	sleep 3
}

#Custom tab function, repeat count as parameter
function tab {
	log "pressing $1 tabs"
	for i in `seq $1 -1 1`
	do
		echo -ne "$i "
		xdotool key Tab
		/bin/sleep 0.1
	done
	echo ""

}

#Custom right key function, repeat count as parameter
function right {
	log "pressing $1 rights"
	for i in `seq $1 -1 1`
	do
		echo -ne "$i "
		xdotool key Right
		/bin/sleep 0.1
	done
	echo ""

}


#Custom left key function, repeat count as parameter
function left {
	log "pressing $1 lefts"
	for i in `seq $1 -1 1`
	do
		echo -ne "$i "
		xdotool key Left
		/bin/sleep 0.1
	done
	echo ""

}

#Congratulation message modifier
function fix_answer {
	log "switch_to_answer_network"
	xdotool key "alt+a"
	sleep 1
	focus "Activity Wizard"
	answer=$1
	log "fix_answer to $answer"
	tab 19
	right 4
	tab 1
	xdotool key "ctrl+a"
	sleep 3
	type "<font face="courier" size="3"><center>Gratulalok, sikeresen teljesitetted a feladatot, ime a bekuldendo kod:<br/><br/><h1>Flag{$answer}</h1><br/></br/>A kodot az alabbi weboldalon tudod bekuldeni:<br/><a href="http://clab.inf.u-szeged.hu/kurzusok/cisco/beadando-feladat/" target="_blank">http://clab.inf.u-szeged.hu/kurzusok/cisco/beadando-feladat/</a></font>"
	sleep 1
}

#Change password of the .pka file
function fix_password {
	log "switch_to_password"
	xdotool key "alt+p"
	sleep 1
	password=$1
	log "changing password to $password"
	tab 8
	type "$password"
	tab 1
	type "$password"
	tab 1
	log "enabling password"
	xdotool type " "
	sleep 1
}

#Save file as a custom name
function save_as {
	log "switch_to_save_as"
	xdotool key "alt+w"
	sleep 1
	tab 9
	xdotool type " "
	sleep 10
	filename=$1
	log "save_as $filename"
#	type "$filename"
#	sleep 1
#	tab 2
#	enter
	log "waiting file to be saved"
	sleep 10
	usrname=$(id -u -n)
	ls 
	mv /home/$usrname/Desktop/cisco/$filename /home/$usrname/Desktop/cisco/final
}

#Create an output file from parameters
function create {
	log "create $1/$2 $3 $4 $5"
	focus "Activity Wizard"
	fix_answer "$3"
	fix_password "$4"
	save_as "$5"
}

#Log messages to console as well as the log file
function log {
	prefix=`date +"[%Y-%m-%d_%H:%M:%S]"`
	echo "$prefix $1" | tee -ai $logfile
}

#Generate lot of out files from an input and a repeat count
function generate {
	datum=`date | cut -d' ' -f2,3`
#	for gen in `seq -w 0 $3`
#	do
		log "generate $1/$2 $3"
        	cleanup
        	start "$1/$2"
        	focus "netacad.com Login"
        	tab 1
        	enter
        	sleep 16
        	killall -9 firefox
        	focus "netacad.com Login"
        	enter
        	focus "User Profile"
		sleep 10
        	tab 1
        	enter
        	tab 1
        	enter
        	focus "Cisco Packet Tracer - $1/$2"
        	activate_activity_wizard

		flaggg=`pwgen -A -B -0 16 -1`
		passss=`pwgen -A -B -0 16 -1`
		number=$(echo "$2" | cut -d" " -f1 | cut -d"_" -f3)

		echo "INSERT INTO \`pka\` VALUES ($3,'${neptunkod[$4]}','$number','$2','$flaggg','$passss','0')" >> cra_dump_${datum}.sql
		echo "$4,$2,$flaggg,$passss" | tee -ai $dbfile
		time create "$1" "$2" "$flaggg" "$passss" "$2"
		#allnumber=$(($3*$pkanumber))
		#currentnumber=$(($pkacounter*$3-$3+10#$gen))
		#percent=$((100*$currentnumber/$allnumber))
		#log "STATUS: [$percent%] [Version: $4/$3] [PKA: $pkacounter/$pkanumber] [All: $currentnumber/$allnumber]"
		sleep 20
		cleanup
#	done
#	enter
}

#init
usrname=$(id -u -n)
workdir="/home/$usrname/Desktop/cisco/origin"
logfile=`date +"%Y-%m-%d_%H:%M:%S.log"`
dbfile=`date +"%Y-%m-%d_%H:%M:%S.csv"`
touch $logfile
touch $dbfile
echo "neptun,outputfilename,flag,password" > $dbfile

log "Cleaning output files"
rm -rf $workdir/../final/out_*
pkas=`ls $workdir -1 -v | grep pka`
pkacounter=0
realarraysize=$(expr ${#neptunkod[@]} - 1)
log $pkas
#touch ls.txt
#for pka in $pkas
#do
#	for gen in `seq -w 0 $realarraysize`
#        do
#                cp -r $workdir/$pka $workdir/../out_${gen}_$pka
#		echo "out_${gen}_$pka" >> ls.txt
#        done
#done

out_pkas=`ls $workdir/.. -1 -v | grep out_`
#out_pkas=$(cat ls.txt)

#ls $workdir/.. | grep out_

#exit 0

#pkanumber=`ls $workdir -1 -v | grep pka |wc -l`
setnumber=0
for pka in $out_pkas
do
	pkacounter=$(($pkacounter+1))
	time generate "$workdir/.." "$pka" $pkacounter $setnumber
	if [ $setnumber -eq $realarraysize ]; then
		setnumber=0;
	elif [ $setnumber -lt $realarraysize ]; then
		setnumber=$(expr $setnumber + 1);
	fi
done
#rm ls.txt
