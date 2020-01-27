#!/bin/bash

#
# Quorum shell command file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

# Run Quorum.
geth --datadir node/data --nodiscover --istanbul.blockperiod 5 --syncmode full --mine --minerthreads 1 --verbosity 5 --networkid 10 --rpc --rpcaddr 0.0.0.0 --rpcport ${RPC_PORT} --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul --emitcheckpoints --port ${QUORUM_PORT} &> node.log &

# Wait a bit for start-up.
sleep 10

# Unlock the account which is used to create contracts.
printf 'personal.unlockAccount(eth.accounts[0], "password", 0);' > unlock.in

until geth attach node/data/geth.ipc < unlock.in; do
  sleep 5
done

rm unlock.in

# Sleep forever.
sleep infinity