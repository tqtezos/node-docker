#!/bin/sh
# Starts Tezos Node analytics processes
# Written by Luke Youngblood, luke@blockscale.net

export TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=Y

continuous() {
	while true
	do
		sleep 60
		tezos-client rpc get /network/peers | pipe2kinesis -region $region $analytics &
		[ $? -ne 0 ] && echo "pipe2kinesis returned $? instead of 0 as a return code..."
	done
}

# main

echo "Node analytics process starting, beginning the continuous loop at `date`..."
continuous
