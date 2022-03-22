---
comments: True
disqusId: afb241a07d7f7822917a9d80fa861998e3d47fb3
layout: post
title: Sapio Studio Tutorial for CTV Meeting #6
subtitle: "On Your Mark Get Set GOOOOOO"
date: 2022-03-22
hashtags: [Bitcoin, Covenants, Sapio]
---

Other people have followed this tutorial with some success:

Common sticking points include:

1. Not building latest sapio binary before starting
1. Not building latest sapio-studio project before starting
1. Not having the correct clang version (>=12)
1. brew installing clang somewhere else (try /opt/homebrew, but also /usr/local/Cellar)

----------
1. Set up a signet node. 

Build this branch https://github.com/JeremyRubin/bitcoin/tree/checktemplateverify-signet-23.0-alpha


You'll likely want settings like this in
   your bitcoin.conf too:
```toml
[signet]
server = 1
txindex=1
signetchallenge=512102946e8ba8eca597194e7ed90377d9bbebc5d17a9609ab3e35e706612ee882759351ae 
rpcport=18332
rpcworkqueue=1000
fallbackfee=0.0002
addnode=50.18.75.225
minrelaytxfee=0
```

3. You'll need to create a new wallet, if you've not done it before

```bash
./bitcoin-cli -signet createwallet sapio-studio-tutorial # If you've done this before fine
./bitcoin-cli -signet getnewaddress
```

2. Get coins to your address https://faucet.ctvsignet.com/ / DM me for more

2. Follow the install instructions on
   https://learn.sapio-lang.org/ch01-01-installation.html You can skip the the
   sapio-studio part / pod part and just do the Local Quickstart up until
   "Instantiate a contract from the plugin".
2. run cargo build --release from the root directory to build the sapio-cli.

## Start Up Sapio Studio
1. Get [Yarn](https://yarnpkg.com/getting-started/install)
2. Install Sapio Studio
```bash
git clone --depth 1 git@github.com:sapio-lang/sapio-studio.git && cd sapio-studio
yarn install
```
3. Start react server
```bash
yarn start-react
```
Leave that running in  tab

4. Start electron server
```bash
yarn start-electron
```

Once it launches this is what you should see:
![](/public/img/bitcoin/sapio-studio-tut-ctv6/1-sapio-studio-init.png)
Go ahead and click on settings to configure the sapio cli for the first time.
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.16.35-AM.png)
First, let's configure our sapio-cli. Go head and do "Configured Here" and leave
everything blank. Click on the select file and point sapio studio to your (freshly done) release build of sapio-cli.

Click Save Settings.
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.17.37-AM.png)

Now, you should see the following confirmation.
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.18.09-AM.png)

Next let's configure your node. Clikc select file and point it to your
.cookie file and then configure the node as Signet & set the RPC port to whatever you used. Save it.
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.18.59-AM.png)

Click test connection -- it should tell you... something.
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.19.39-AM.png)

Navigate back to wallet. You should see some balance or something (assuming you did the faucet).
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.20.12-AM.png)

Next, click "Load WASM Plugin" and find your plugin-example/target/wasm32-unknown-unknown/debug/*.wasm files. Go ahead and pick the jamesob vault one.
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.20.41-AM.png)

Next, click Create new contract.
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.21.17-AM.png)

You'll see a little applet for the JameVault. Look at that handsome guy!
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.22.07-AM.png)

Next, we need to create some Taproot keys for this -- gonna need some command line action:

```bash
./bitcoin-cli -signet getaddressinfo $(./bitcoin-cli -signet getnewaddress "vault_project" "bech32m")
```

and then copy the witness program. do this twice -- one for cold one for hot.
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.27.25-AM.png)

Now click on your applet and start filling it out. You can get new addresses by clicking on Bitcoin Node (just not keys yet)
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.35.18-AM.png)
n.b. sometimes things are in btc, sometimes in sats. c'est la vie.
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.35.48-AM.png)
finish up and click submit
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.36.02-AM.png)
If all is right, you should see a contract get created!
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.36.17-AM.png)
To actually create it, click on the parent txn and then sign it...
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.36.51-AM.png)
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.37.00-AM.png)
and then broadcast it (with real money you'll want to verify before doing this)
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.37.03-AM.png)
it'll now pop up in the mempool.
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.37.14-AM.png)
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.37.25-AM.png)
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.44.38-AM.png)
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-10.44.57-AM.png)
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-11.53.45-AM.png)
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-11.53.54-AM.png)
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-11.47.10-AM.png)
![](/public/img/bitcoin/sapio-studio-tut-ctv6/Screen-Shot-2022-03-22-at-11.47.20-AM.png)
