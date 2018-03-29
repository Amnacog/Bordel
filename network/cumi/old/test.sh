#!/bin/bash

function kf {
	kill -9 $pid
}

function fd {
	while read a; do
		echo $a
		sleep 2 ; kf
	done
}

nc localhost `cat masterport` | fd &
pid=$!

sleep 30
