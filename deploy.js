#!/usr/bin/env node

const fs = require('fs');
const solc = require('solc');
const Web3 = require('web3');
const Tx = require('ethereumjs-tx');
const Wallet = require('ethereumjs-wallet');

const RPC_HOST = "https://rinkeby.infura.io";

const web3 = new Web3(new Web3.providers.HttpProvider(RPC_HOST));

// Create private key from seed
const GEN_PASSPHRASE = "synapse";
const GEN_PRIVATE_KEY = new Buffer("a8c972d3a687e2f573b7bb28441ad60ac22d55a837734831766f6564cadd1212", 'hex');
const GEN_ADDRESS = "0x45801305B7d516AfF0fF8420314e48De58F2C6cf";

const MINIMUM_STAKE_AMOUNT = 100000000;
const GAME_PRICE_GEN = 100000000;

function compileContracts() {
    // Compile the source code
    var input = {sources: {
        'Nasdex.sol': fs.readFileSync('Nasdex.sol').toString(),
    }
}

    //console.log(input.toString());
    const output = solc.compile(input, 1);
console.log(output.errors);

    var result = {};

    for (var k in  output.contracts) {
        const contractKey = k.split(':').pop();
        const bytecode = output.contracts[k].bytecode;
        const abi = JSON.parse(output.contracts[k].interface);
        result[contractKey] = {
            bytecode: bytecode,
            abi: abi
        }
    }

    return result;
}

// Synchrone
function sendRawTransaction(data) {
    const rawTx = {
        nonce: web3.toHex(web3.eth.getTransactionCount(GEN_ADDRESS)),
        gasPrice: web3.toHex(web3.eth.gasPrice),
        gasLimit: web3.toHex(4700000),
        data: data,
        from: GEN_ADDRESS
    };

    const tx = new Tx(rawTx);
    tx.sign(GEN_PRIVATE_KEY);
    const serializedTx =  tx.serialize();
    const rawTransaction = '0x' + serializedTx.toString('hex');

    const txHash = web3.eth.sendRawTransaction(rawTransaction);

    // Wait transaction to be mined
    waitForTransactionReceipt(txHash);

    return txHash
}

function sleep(seconds){
    var waitUntil = new Date().getTime() + seconds*1000;
    while(new Date().getTime() < waitUntil) true;
}

function waitForTransactionReceipt(txHash) {
    var receipt = web3.eth.getTransactionReceipt(txHash);
    // If no receipt, try again in 1 block
    while (receipt == null) {
        sleep(5);
        receipt = web3.eth.getTransactionReceipt(txHash);
    }
}

function getContractAddress(txHash) {
    const receipt = web3.eth.getTransactionReceipt(txHash)
    if (receipt) return receipt.contractAddress;
}

function publishContract(compiledContract) {
    // Get contract data
    const data = web3.eth.contract(compiledContract.abi).new.getData({
        data: '0x' + compiledContract.bytecode
    });
    // Send Transaction
    const txHash = sendRawTransaction(data);
    // Returns contract specs
    return {
        address: getContractAddress(txHash),
        abi: compiledContract.abi
    }
}


compiledContracts = compileContracts();

const deployedSpec = publishContract(compiledContracts['Nasdex']);

const genSpecs = JSON.stringify({
    GenAddress: GEN_ADDRESS,
    SimpleBank: deployedSpec,
}, null, 4);

const genSpecsFilename = 'deployed_specs_' + Date.now() + '.js'
const genSpecsJS = 'DEPLOYED_SPECS = ' + genSpecs + ';'
fs.writeFileSync(genSpecsFilename, genSpecsJS, 'utf8');
console.log(genSpecsJS);
