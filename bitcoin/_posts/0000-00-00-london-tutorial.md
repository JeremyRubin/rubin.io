---
comments: True
disqusId: 3df8c67051ffb4335ba41f34ad5b0c42499a976c
layout: post
title: London Advancing Bitcoin Tutorial
subtitle: "Content for Following Along!"
date: 2021-03-04
hashtags: [Bitcoin, Covenants, Sapio]
---

Other people have followed this tutorial with some success:

https://gnusha.org/ctv-bip-review/2022-02-22.log

If you're having a problem, see above log where people have had issues. Common problems include:

1. Not building latest sapio binary
1. Not having the correct clang version (>=12)
1. brew installing clang somewhere else (try /opt/homebrew, but also /usr/local/Cellar)
1. xargs not liking something (working to debug it, you can open the JSONs with vi and do by hand some of the steps).


----------

1. Install JQ (json manipulating tool) if you don't have it / other things
   needed to run a bitcoin node.
2. Set up a signet node. 

Build this branch https://github.com/JeremyRubin/bitcoin/tree/checktemplateverify-signet-23.0-alpha


You'll likely want settings like this in
   your bitcoin.conf too:
```toml
[signet]
# generate this yourself                                                                                                                    rpcauth=generateme:fromtherpcauth.pyfile     
txindex=1
signetchallenge=512102946e8ba8eca597194e7ed90377d9bbebc5d17a9609ab3e35e706612ee882759351ae 
rpcport=18332
rpcworkqueue=1000
fallbackfee=0.0002
```

Get coins https://faucet.ctvsignet.com/ / DM me

2. Follow the install instructions on
   https://learn.sapio-lang.org/ch01-01-installation.html You can skip the the
   sapio-studio part / pod part and just do the Local Quickstart up until
   "Instantiate a contract from the plugin". You'll also want to run cargo
   build --release from the root directory to build the sapio-cli.


3. Open up the site https://rjsf-team.github.io/react-jsonschema-form/
4. Run sapio-cli contract api --file
   plugin-example/target/wasm32-unknown-unknown/debug/sapio_wasm_plugin_example.wasm
5. Copy the resulting JSON into the RJSF site
6. Fill out the form as you wish. You should see a JSON like
```json
{
  "context": {
    "amount": 3,
    "network": "Signet",
    "effects": {
      "effects": {}
    }
  },
  "arguments": {
    "TreePay": {
      "fee_sats_per_tx": 1000,
      "participants": [
        {
          "address": "tb1pwqchwp3zur2ewuqsvg0mcl34pmcyxzqn9x8vn0p5a4hzckmujqpqp2dlma",
          "amount": 1
        },
        {
          "address": "tb1pwqchwp3zur2ewuqsvg0mcl34pmcyxzqn9x8vn0p5a4hzckmujqpqp2dlma",
          "amount": 1
        }
      ],
      "radix": 2
    }
  }
}
```
You may have to delete some extra fields (that site is a little buggy).

Optionally, just modify the JSON above directly.

7. Copy the JSON and paste it into a file ARGS.json
8. Find your sapio-cli config file (mine is at
   ~/.config/sapio-cli/config.json). Modify it to look like (enter your rpcauth
   credentials):
```json
{
  "main": null,
  "testnet": null,
  "signet": {
    "active": true,
    "api_node": {
      "url": "http://0.0.0.0:18332",
      "auth": {
        "UserPass": [
          "YOUR RPC NAME",
          "YOUR PASSWORD HERE"
        ]
      }
    },
    "emulator_nodes": {
      "enabled": false,
      "emulators": [],
      "threshold": 1
    },
    "plugin_map": {}
  },
  "regtest": null
}
```

9. Create a contract template:
```bash
cat ARGS.json| ./target/release/sapio-cli contract create  --file plugin-example/target/wasm32-unknown-unknown/debug/sapio_wasm_plugin_example.wasm  | jq > UNBOUND.json
```
10. Get a proposed funding & binding of the template to that utxo:

```bash
cat UNBOUND.json| ./target/release/sapio-cli contract bind | jq > BOUND.json
```
11. Finalize the funding tx:

```bash
cat BOUND.json | jq ".program[\"funding\"].txs[0].linked_psbt.psbt" | xargs echo | xargs -I% ./bitcoin-cli -signet utxoupdatepsbt % |  xargs -I% ./bitcoin-cli -signet walletprocesspsbt % | jq ".psbt" | xargs -I% ./bitcoin-cli -signet finalizepsbt % | jq ".hex"
```

12. Review the hex transaction/make sure you want this contract... and then
    send to network:
```
./bitcoin-cli -signet sendrawtransaction 020000000001015e69106b2eb00d668d945101ed3c0102cf35aba738ee6520fc2603bd60a872ea0000000000feffffff02e8c5eb0b000000002200203d00d88fd664cbfaf8a1296d3f717625595d2980976bbf4feeb
10ab090180ccdcb3faefd020000002251208f7e5e50ce7f65debe036a90641a7e4d719d65d621426fd6589e5ec1c5969e200140a348a8711cb389bdb3cc0b1050961e588bb42cb5eb429dd0a415b7b9c712748fa4d5d
fe2bb9c4dc48b31a7e3d1a66d9104bbb5936698f8ef8a92ac27a650663500000000
```


13. Send the other transactions:

```
cat BOUND.json| jq .program | jq ".[].txs[0].linked_psbt.psbt" | xargs -I% ./target/release/sapio-cli psbt finalize --psbt %  | xargs -I% ./bitcoin-cli -signet sendrawtransaction %
```



Now what?

- Maybe load up the Sapio Studio and try it through the GUI?
- Modify the congestion control tree code and recompile it?
- How big of a tree can you make (I did about 6000 last night)?
- Try out other contracts?
