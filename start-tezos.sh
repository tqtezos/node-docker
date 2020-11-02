#!/bin/sh
# Starts the Tezos node client
# Written by Luke Youngblood, luke@blockscale.net

init_node() {
	tezos-node identity generate 26
	tezos-node config init "$@" \
		--rpc-addr="[::]:$rpcport" \
		--net-addr="[::]:$netport" \
		--connections=$connections \
		--network=$network \
		--history-mode=archive \
		--cors-origin='*' \
		--cors-header 'Origin, X-Requested-With, Content-Type, Accept, Range'
	cat /home/tezos/.tezos-node/config.json
}

start_node() {
	tezos-node run
    if [ $? -ne 0 ]
	then
    	echo "Node failed to start; exiting."
    	exit 1
	fi
}

s3_sync() {
	# If the current1 key exists, node1 is the most current set of blockchain data
	echo "A 404 error below is expected and nothing to be concerned with."
	aws s3api head-object --request-payer requester --bucket $chainbucket --key current1
	if [ $? -eq 0 ]
	then
		s3key=node1
	else
		s3key=node2
	fi
	aws s3 sync --request-payer requester --region $region s3://$chainbucket/$s3key /home/tezos/.tezos-node
}

# main

init_node
s3_sync
start_node
