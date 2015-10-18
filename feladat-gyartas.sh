#!/bin/bash
IFS=$(echo -en "\n\b")

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
		/bin/sleep 0.1
	done
}

#Packet Tracer starter with opening source file
function start {
	log "Starting Packet Tracer opening $1"
	packettracer $1 &>/dev/null &
	sleep 10 #should be enough
	enter
}

#Set focus to the desired window
function focus {
	log "searching for $1"	
	title=$1
	pt_window=`xdotool search --name "$1"`
	sleep 5
	log "activating window $1"
	xdotool windowactivate $pt_window
	sleep 5
	log "setting focus to $1"
	xdotool windowfocus $pt_window
	sleep 5
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
	killall -9 PacketTracer6
	sleep 3
}

#Switch to Answer Network page in Activity Wizard
function switch_to_answer_network {
	log "switch_to_answer_network"
	xdotool key "alt+a"
	sleep 1
}

#Custom tab function, repeat count as parameter
function tab {
	log "pressing $1 tabs"
	for i in `seq $1 -1 1`
	do
		echo -ne "$i "
		xdotool key Tab
		/bin/sleep 1
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
		/bin/sleep 1
	done
	echo ""

}

#Congratulation message modifier
function fix_answer {
	answer=$1
	log "fix_answer to $answer"
	tab 4
	right 3
	tab 1
	xdotool key "ctrl+a"
	sleep 1
	type "<div style=\'font-family: \"Courier New\", Courier, monospace;'><center>Gratulálok, sikeresen teljesítetted a feladatot, íme a bekülendő kód:<br/><br/><h1>Flag{$answer}</h1><br/></br/>A kódot az alábbi weboldalon tudod beküldeni:<br/><a href="http://clab.inf.u-szeged.hu/kurzusok/cisco/beadando-feladat/">http://clab.inf.u-szeged.hu/kurzusok/cisco/beadando-feladat/</a></div>"
	sleep 1
}

#Switch to password page
function switch_to_password {
	log "switch_to_password"
	xdotool key "alt+p"
	sleep 1
}

#Change password of the .pka file
function fix_password {
	password=$1
	log "changing password to $password"
	tab 9
	type "$password"
	tab 1
	type "$password"
	tab 1
	log "enabling password"
	xdotool type " "
	sleep 1
}

#Switch to save as page
function switch_to_save_as {
	log "switch_to_save_as"
	xdotool key "alt+w"
	sleep 1
	tab 6
	xdotool type " "
	sleep 1
}

#Save file as a custom name
function save_as {
	filename=$1
	log "save_as $1"
	type "$1"
	sleep 1
	enter
	log "waiting file to be saved"
	sleep 10
	log "sync"
	sync
	sleep 5
}

#Create an output file from parameters
function create {
	log "create $1/$2 $3 $4 $5"
	cleanup
	start "$1/$2"
	focus "Cisco Packet Tracer Instructor"
	activate_activity_wizard
	switch_to_answer_network
	focus "Activity Wizard"
	fix_answer "$3"
	switch_to_password
	fix_password "$4"
	switch_to_save_as
	save_as "$5"
	cleanup
}

#Log messages to console as well as the log file
function log {
	prefix=`date +"[%Y-%m-%d_%H:%M:%S]"`
	echo "$prefix $1" | tee -ai $logfile
}

#Generate lot of out files from an input and a repeat count
function generate {
	log "generate $1/$2 $3"
	for gen in `seq -w 1 $3`
	do
		flaggg=`pwgen -A -B -0 16 -1`
		passss=`pwgen -A -B -0 16 -1`
		echo "out_${gen}_$2,$flaggg,$passss" | tee -ai $dbfile
		time create "$1" "$2" "$flaggg" "$passss" "out_${gen}_$2"
		allnumber=$(($3*$pkanumber))
		currentnumber=$(($pkacounter*$3-$3+10#$gen))
		percent=$((100*$currentnumber/$allnumber))
		log "STATUS: [$percent%] [Version: $gen/$3] [PKA: $pkacounter/$pkanumber] [All: $currentnumber/$allnumber]"
	done
}

#init
workdir="/home/jv/Desktop/cisco"
logfile=`date +"%Y-%m-%d_%H:%M:%S.log"`
dbfile=`date +"%Y-%m-%d_%H:%M:%S.csv"`
touch $logfile
touch $dbfile
echo "outputfilename,flag,password" > $dbfile

log "Cleaning output files"
rm -rf $workdir/out_*

pkas=`ls $workdir -1 -v | grep pka | grep -v out_`
pkanumber=`ls $workdir -1 -v | grep pka | grep -v out_|wc -l`
pkacounter=0
log $pkas
for pka in $pkas
do
	pkacounter=$(($pkacounter+1))
	time generate "$workdir" "$pka" 1
done
