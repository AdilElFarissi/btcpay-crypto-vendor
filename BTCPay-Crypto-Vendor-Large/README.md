# BTCPay Crypto Vendor Large
![Screenshot of the BTCPay Crypto Vendor Large version.](/Illustrations/BTCPay_Crypto_Vendor_Large.jpg)

## Version Notes:
BTCPay Crypto Vendor v0.1.
The script in this items use the new osGetInventoryNames OSSL function available since OpenSim v0.9.3. This item will not work in the older versions of OpenSim.

## Upload and Re-Linking:
BTCPay Crypto Vendor files are provided as Firestorm Viewer backup  .oxp files.  So, open firestorm and login/TP somewhere where you can build or rez objects... Click **Build** in the top menu and select **Upload** and select **Import Linkset**... navigate to the folder where the vendor file is and select it to upload... Let the magic happen :)

Unfortunately, due to a technical issue in Opensim, uploading linksets does not keep the links order and you have to unlink and relink the vendor in order for it to work. It's easy to do, just unlink the vendor... click and hold SHIFT and select the elements in this order: 
1. The Background prim.
2. The **Purchase** button.
3. The **Description** button.
4. The **right navigation** button.
5. The **left navigation** button.
6. The mini screens : Side by side, from right to left in each level from bottom to top in the right side and the same in the left side.
7. Finally the main screen which must be the root prim.
 
Click the **Link** button in your editor... Now you have just to port and setup the script, add items and voila! 

## About BTCPay Server:
### What is BTCPay Server?

BTCPay Server is a free, open-source & self-hosted cryptocurrencies payment gateway and automated invoicing software that allows self-sovereign individuals and businesses to accept cryptocurrencies payments online or in person without any fees or third-parties. You can install it aside your Opensim or in a VPS and use it in private or shared modes...

At checkout, a customer is presented with an invoice that she/he pay from her/his wallet directly to your own wallet. BTCPay Server follows the status of the invoice through the blockchain and informs you when the payment has been settled so that you can fulfill the order... In our case, the vendor deliver the purchased item.

I strongly recommend you to read the BTCPay documentation before the usage of this vendor here:

[https://docs.btcpayserver.org/Guide/](https://docs.btcpayserver.org/Guide/)

If you can't or don't want to install BTCPay, you can use a public instance provided by third-party hosts but read this first:

[https://docs.btcpayserver.org/Deployment/ThirdPartyHosting/](https://docs.btcpayserver.org/Deployment/ThirdPartyHosting/)

You can find some third-party hosts here:

[https://directory.btcpayserver.org/filter/hosts](https://directory.btcpayserver.org/filter/hosts)

### Training and Practice.

BTCPay team offers a demo platform linked to the Bitcoin (Test-net) where you can try and use for training with fake BTCs (free coins). Is what i used to develop this vendor... So, create an account here and follow the docu to setup your store to get your storeID. You can also setup a Hot Wallet (bad practice in production) to receive BTC test coins...
[https://testnet.demo.btcpayserver.org/register](https://testnet.demo.btcpayserver.org/register)

## Setting The Vendor:
**The very first thing to do is:**
- Click right the vendor and select "Edit" in the menu, in the editor switch to the "Content" tab...

- Click right the "BTCPay_Crypto_Vendor_v0.1" script and select "Properties"...

- In the properties window, **deselect "Modify" and "Copy" to prevent that the others open and read the script where your store ID is!**. The exposure of the store ID is not a risk or a threat because the most a malicious person can do with it is to create invoices, but it is better to keep it secret.

Next, open the script and modify the needed parameters...
- Set your BTCPay Server URL where you have installed it or your host URL... By default i set it to the BTCPay test-net for the demo.

- Set the IP of the BTCPay URL/server. This is used to filter the incoming HTTP for security. If you don't know it, use this:

https://www.nslookup.io/website-to-ip-lookup/

- Set your store ID: You can get your store ID from your BTCPay account. Click "Settings" in the left menu... the store ID is the first thing in the page. In the same page scroll down and **activate "Allow anyone to create invoice"**... scroll down and click save. Copy/Paste the store ID from BTCPay to the script.

- Set the fiat currency to display. This setting affects the calculation of the equivalent in cryptos based on the current rate... sometime its give more coins using USD... sometime EUR or GBP. You can set one of all the the fiat currencies supported by the data source (see in BTCPay: Settings>Rates). eg: USD, EUR, GBP...

- Set the crypto that you want to receive as payment. you can set here one of all the cryptos supported by BTCPay and you have set in your BTCPay wallets section. eg: BTC, DOGE, LTC, XMR... By default, BTCPay use Kraken as data source, you can see the available pairs here :

[https://support.kraken.com/articles/kraken-markets](https://support.kraken.com/articles/kraken-markets)

[https://docs.btcpayserver.org/FAQ/Altcoin/#which-coins-does-btcpay-server-support](https://docs.btcpayserver.org/FAQ/Altcoin/#which-coins-does-btcpay-server-support)

- Optional: Set the other parameters if needed. Read the parameters  comments for more infos.

## Add items:
For each product you need 2 items: the object to sale and a representative image.
1. Set the same name to your texture as your object but prefixed with "img_". For example:<pre>
Object name: My Nice Product
Texture name: img_My Nice Product</pre>

2. Set the price and some info about your product in the description of your texture separated by "#". This description will be visible to the avatars in the chat when they click the [Description] button. For example:
<pre>3.25#My item to sell description.</pre>

3. Place your object and texture in the content of the root prim (main screen). There is 2 ways to do that:
- Method 1: Click and hold CTRL in your keyboard, select your object and texture and drag both to the main screen and drop... The screen will show an orange halo if you did it well.

- Method 2: Click right The BTCPay Crypto Vendor and select "Edit" in the menu... In the editor click "Contents" tab... Next, select your object and texture and drag both from your inventory to the contents tab.

That it!, 
Theoretically you can add an unlimited number of objects but as you know and experienced, when we exceed 100 objects(+textures) we start to have problems loading the contents of the buttons... as a solution i added an admin menu allowing you to manage, make a backup and delete objects without having to open the contents tab.

## Usage:
1- Use the navigation buttons to browse the contents...

2- Select an item in the mini screens...

3- Click [Description] to get the item infos...

4- Click the main screen or [Purchase] button to buy the selected item.

5- Enjoy :)

## The BTCPay Crypto Vendor License:
The BTCPay Crypto Vendor is open source and provided for FREE & FULL PERM under The MIT license, is a license that lets you to remix, tweak, and build upon this work, as long as you credit the original author and share your changes (if you want!) under the same license...
In less words... Keep it free and make it (if you can) better for the others...

## About The Author:
Adil El Farissi, known as Web Rain in SL and OSGrid, I am an eternal amateur in action, hobbyist programmer, virtual worlds builder and crypto enthusiast... 
Between my modest contributions to the OpenSim saga there is the LinkInventory functions allowing the linked prims contents manipulations and the some security functions like the AES encryptor/decryptor...
Feel free to visit my Github for more open source stuff:

https://github.com/AdilElFarissi

Note: I am not affiliated or work with/for Opensimulator , BTCPay, NSL... I just add my magic touch where i feel it is necessary for the common good.

## My Tip-Jars:
Usually nobody cares about the developers and the creators of the free and open source contents... but if you think that my work deserves more than a simple thank you, consider making a small donation using paypal or others here:

BTC: bc1ququ5vxy3yfpqn6dd5p4xfnk35ljfgem2jf2tf2

LTC: LL6dMuxLCWy6rB7h3AHCR5nkvdV6SoFNEk

ETH: 0xa3E82b8D653Db863dBB557C8Ed8A01f6570bd990

USDT ETH Network: 0xa3E82b8D653Db863dBB557C8Ed8A01f6570bd990

USDT SOL Network: 4NzQh2wW8yxsmQzs5mVdQaaRkcpvvuonj439sQ67DgDv

DOGE: DFPrdKUtYJS8jqPpmECypdQPumCykK5jHp

XMR: 4AEJf5HiQkiiafQRzV2gmfJjUHEKUSgetjb7bqn7fQQ7GfJe21nmE29GMBhV1z6pvC45yVKVkvAH97cp4bkPpJHH4m3gZfQ

Thank You Very Much :)


