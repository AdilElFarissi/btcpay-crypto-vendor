/* BTCPay Server Multi Products Vendor Script for experimental and educational proposes.

THIS SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SCRIPT OR THE USE OR OTHER DEALINGS IN THE SCRIPT.
By Adil El Farissi (Web Rain @SL @OSG). */

string BTCPayServerURL = "https://testnet.demo.btcpayserver.org";
string HttpInAllowedIP = "172.81.181.89";
string storeID = "BVhCURCQPEe6mUSBuwvUciYvy15ikx42g1Vizx8YBG1f";

// Set the fiat or crypto currency to display eg, USD or EUR... if set to the same as defaultPaymentMethod, the invoice will be in cryptos only.
string currency = "GBP";

// The cryptocurrency code (ticker) of the crypto that you want to recive as payment. This value depend on your BTCPay server settings and Altcoins support... Default is Bitcoin "BTC", If your BtcPay instance support Litecoin Dogecoin and Monero you can set "LTC" or "DOGE" or "XMR"... (Cryptos only here!)
string defaultPaymentMethod = "BTC";

// If you want to recive notifications by Email, set it here or leave empty.
string notificationEmail = "";

// If you want to redirect your user to a webpage after a payment, set an URL here or leave empty. You can add here some GET parameters to pass data to the destination... eg, avatar name or UUID...
string redirectURL = "";

//Advanced Options: Specify additional query string parameters that should be appended to the checkout page once the invoice is created. For example, lang=da-DK would load the checkout page in Danish by default. 
string checkoutQueryString = "";

// If set to TRUE will inform you about the recived payments in the chat.
integer notifications = TRUE;

/* Show or hide the text over the vendor. TRUE/FALSE*/
integer showHoverText = TRUE;

// Change the hover text color
vector hoverColor = <1,1,0>;

// Guide for the users... feel free to change if needed
string guide = "\n1- Use the navigation buttons to browse the contents...\n2- Select an item in the mini screens...\n3- Click the [Description] button to get the item infos...\n4- Click the main screen or [Purchase] button to buy the selected item with "+defaultPaymentMethod+".\n5- Open the invoice page and proceed to the payment from your wallet.\nThe invoice page will inform you about the progress of the transaction...\nOnce confirmed, you will receive your item.\n# Enjoy :)";

// Guide for the purchase process.
string buyGuide = "\nThe purchase process is easy and uncomplicated:\n\n1- Read the product infos...\n\n2- Click the [Buy] button. The system will calculate the equivalent of the fiat price in the supported crypto based on the current rates and show it in next step. If you have enough coins in your wallet, click [Yes], this will request your invoice from BTCPay and provide you the payment link.\n\n3- Open the invoice page and use your wallet to pay to the provided address. If you have a mobile wallet you can scan the QR code or copy/paste the amount and the address to your wallet.\n\n4- Once your payment is made, this vendor will inform you and it is only a matter of time for it to be confirmed and for you to receive your item. This delay is caused by the generation time of the blockchain blocks and unfortunately beyond our control... Please be patient.\n";

// The number of the mini screens
integer miniScreens = 6;

/*** The following dont need change ***/
key IPNEndpointRequest_id = NULL_KEY;
key requestRates_id = NULL_KEY;
key requestInvoice_id = NULL_KEY;
string IPNEndpointURL = "";
string orderID = ""; 
key avatar = NULL_KEY;
integer active = FALSE;
string invoiceID = "";
string invoiceURL = "";
string productName = "";
string productDescription = "";
string price = "0";
integer channel;
integer CListener;
integer isOutOfService = FALSE;
string errorLog = "";
string txStatus = "";
string item;
list namesList;
integer actual = 0;


BuildItemsLists(){
    namesList = [];
    list names = osGetInventoryNames(INVENTORY_TEXTURE);
    for(integer i=0; i<llGetListLength(names); i++){
        if(osStringStartsWith(llList2String(names, i) ,"img_",0)){
            list desc = llParseString2List(osGetInventoryDesc(llList2String(names, i)),["#"],[]);
            if(llList2Float(desc,0) > 0){ 
                namesList += llList2String(names, i);
            }
            else{
                llOwnerSay("\nMissing price in:\n"+ llList2String(names, i)+"\nPlease set the price in "+currency+" in the description of this texture in this format:\nprice#product description\neg;\n5.99#My very nice item to sale...");
            }
        }
    }
    if(namesList == []){
        isOutOfService = TRUE;
        errorLog = "Missing Items! Please add some items to sale and their respective textures inside the content of this vendor.";
        ResetDisplay();
        reset();
    }
    else{
        isOutOfService = FALSE;
        reset();
    }
}
    
ResetDisplay(){
    actual = 0;
    integer a = actual;
    integer b = actual + miniScreens;
    integer l = 2;
    for(; a < b; a++) {
        item = llList2String(namesList, a);
        if(item == ""){
            llSetLinkPrimitiveParamsFast(l,[
            PRIM_TEXTURE, 0,"ComingSoonTexture", <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0,
            PRIM_COLOR,ALL_SIDES, <1.0,1.0,1.0>, 1.0,
            PRIM_FULLBRIGHT,ALL_SIDES,FALSE,
            PRIM_FULLBRIGHT,0,TRUE]);
            l++;
        }
        else{
            llSetLinkPrimitiveParamsFast(l,[
            PRIM_TEXTURE, 0,item, <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0,
            PRIM_COLOR,ALL_SIDES, <1.0,1.0,1.0>, 1.0,
            PRIM_FULLBRIGHT,ALL_SIDES,TRUE,
            PRIM_FULLBRIGHT,0,TRUE]);
            l++;
        }
    }
    if(namesList != []){
        llSetLinkPrimitiveParamsFast(2,[
            PRIM_COLOR,ALL_SIDES, <1.0, 0.0, 0.0>, 1.0,
            PRIM_COLOR, 0, <1.0, 1.0, 1.0>, 1.0,
            PRIM_FULLBRIGHT,ALL_SIDES,TRUE]);
        llSetTexture(llList2String(namesList, 0),0);
        updateProductInfo();
        llSetLinkPrimitiveParamsFast((miniScreens+6),[PRIM_TEXT,productName+ "\nPrice: "+price+" "+currency+" in "+defaultPaymentMethod,<1.0, 1.0, 0.0>, 1.0]);
        }
        else{
            llSetTexture("MainTexture",0);
        }
    actual = a;
}

GoNext(){
    integer a;
    integer b;
    integer l = 2;
    if ( actual < llGetListLength(namesList)){
        a = actual;
    }else{
        a = 0;
        actual = 0;
    }
    b = actual + miniScreens;

    for(; a < b; a++) { 
        item = llList2String(namesList, a);
        if(item == ""){                         
            llSetLinkPrimitiveParamsFast(l,[
            PRIM_TEXTURE, 0,"ComingSoonTexture", <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0,
            PRIM_COLOR,ALL_SIDES, <1.0,1.0,1.0>, 1.0,
            PRIM_FULLBRIGHT,ALL_SIDES,FALSE,
            PRIM_FULLBRIGHT,0,TRUE]);
            l++;
        }
        else{
            llSetLinkPrimitiveParamsFast(l,[
            PRIM_TEXTURE, 0, item, <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0,
            PRIM_COLOR,ALL_SIDES, <1.0,1.0,1.0>, 1.0,
            PRIM_FULLBRIGHT,ALL_SIDES,FALSE,
            PRIM_FULLBRIGHT,0,TRUE]);
            l++;
        }
    }
    actual = a;
}

GoBack(key ID){
    integer a;
    integer b;
    integer l = 2;                
    a = actual-(miniScreens*2);
    b = actual-miniScreens;
    if ( a < 0){
        a = 0;
        b = miniScreens;
        actual = 0;
    }
    
    for(; a < b; a++){
        item = llList2String(namesList, a);
        if(item == ""){                 
            llSetLinkPrimitiveParamsFast(l,[
            PRIM_TEXTURE, 0,"ComingSoonTexture", <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0,
            PRIM_COLOR,ALL_SIDES, <1.0,1.0,1.0>, 1.0,
            PRIM_FULLBRIGHT,ALL_SIDES,FALSE,
            PRIM_FULLBRIGHT,0,TRUE]);
            l++;
        }
        else{
            llSetLinkPrimitiveParamsFast(l,[
            PRIM_TEXTURE, 0,item, <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0,
            PRIM_COLOR,ALL_SIDES, <1.0,1.0,1.0>, 1.0,
            PRIM_FULLBRIGHT,ALL_SIDES,FALSE,
            PRIM_FULLBRIGHT,0,TRUE]);
            l++;
        }
    }
    
    if (actual == 0){
        if(namesList != []){
        llSetLinkPrimitiveParamsFast(2,[
            PRIM_COLOR,ALL_SIDES, <1.0, 0.0, 0.0>, 1.0,
            PRIM_COLOR, 0, <1.0, 1.0, 1.0>, 1.0,
            PRIM_FULLBRIGHT,ALL_SIDES,TRUE]);
        llSetTexture(llList2String(namesList, 0),0);
        llInstantMessage(ID, "You are at the top of the available products!");
        }
    }
    
    if( a <= 0 ){
        actual = llGetListLength(namesList);
    }
    else{
        actual = a;
    }       
}

reset(){
    requestInvoice_id = NULL_KEY;
    IPNEndpointRequest_id = NULL_KEY;
    orderID = ""; 
    avatar = NULL_KEY;
    active = FALSE;
    invoiceID = "";
    invoiceURL = "";
    txStatus = "";
    llReleaseURL(IPNEndpointURL);
    IPNEndpointURL = "";
    llListenRemove(CListener);
    llSetTimerEvent(0);
    llSetLinkPrimitiveParamsFast((miniScreens+6),[
            PRIM_TEXT, "",hoverColor, 1.0]);
    if (!isOutOfService && showHoverText){
       llSetLinkPrimitiveParamsFast((miniScreens+6),[
            PRIM_TEXT, defaultPaymentMethod+" Cryptocurrency Vendor\nPowered By BTCPay Server.",hoverColor, 1.0]);
    }else{
        llSetLinkPrimitiveParamsFast((miniScreens+6),[
                PRIM_TEXT, "Out Of Service!",<1,0,0>, 1.0]);
    }
}

requestCurrentRate(){
    requestRates_id = llHTTPRequest(
        BTCPayServerURL +"/api/rates?storeId="+ storeID +"&currencyPairs="+ defaultPaymentMethod +"_"+ currency,
        [
            HTTP_METHOD,"GET",
            HTTP_MIMETYPE,"application/json",
            HTTP_BODY_MAXLENGTH,16384
        ],"");
}

requestInvoice(){
    string formData = "";
    formData += "storeId="+ llEscapeURL(storeID);
    formData += "&price="+ llEscapeURL(price);
    formData += "&currency="+ llEscapeURL(currency);
    formData += "&defaultPaymentMethod="+ llEscapeURL(defaultPaymentMethod);
    formData += "&orderId="+ llEscapeURL(orderID);
    formData += "&checkoutDesc="+  llEscapeURL("Thank you "+ llKey2Name(avatar) +" for purchasing:"+ productName +".");
    formData += "&serverIpn="+ llEscapeURL(IPNEndpointURL);   
    if (redirectURL != ""){
        formData += "&browserRedirect="+ llEscapeURL(redirectURL);
    }
    if (notificationEmail != ""){
        formData += "&notifyEmail="+ llEscapeURL(notificationEmail);
    }
    if (checkoutQueryString != ""){
        formData += "&checkoutQueryString="+ llEscapeURL(checkoutQueryString);
    }
    formData += "&jsonResponse=true";
    requestInvoice_id = llHTTPRequest(BTCPayServerURL+"/api/v1/invoices",[HTTP_METHOD,"POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded",HTTP_BODY_MAXLENGTH,16384],formData);
}

updateProductInfo(){
    string texture = llGetTexture(0);
    list data = llParseString2List(osGetInventoryDesc(texture),["#"],[]);
    productName = "";
    productDescription = "";
    if(osStringStartsWith(texture ,"img_",0)){
        productName = osStringReplace(texture, "img_", "");
        price = llStringTrim(llList2String(data,0),STRING_TRIM);
        productDescription = llList2String(data,1);

    }
}
showBuyMenu(){
    llSetLinkPrimitiveParamsFast((miniScreens+6),[PRIM_TEXT, "Processing...",<1.000, 0.522, 0.2>, 1.0]);
    llDialog(avatar,"\nThank you for purchasing: "+ productName +".\n\nProduct Description:\n"+ productDescription +"\nPrice: "+ price +" "+ currency +" in "+defaultPaymentMethod+"\n\nPlease click [Buy] to confirm, click [Close] to cancel or [Infos] for more informations.\n the amount of " + defaultPaymentMethod +" to send will be automatically calculated and displayed in the next step and in the invoice page.",["Buy","Info","Close"],channel);
}

default{
    state_entry(){
        for(integer i=1;i<(miniScreens +2);i++){
            llSetLinkPrimitiveParamsFast(i,[
            PRIM_COLOR,ALL_SIDES, <1.0,1.0,1.0>,1.0,
            PRIM_FULLBRIGHT,ALL_SIDES,FALSE,
            PRIM_FULLBRIGHT,0,TRUE]);
        }      
        BuildItemsLists();
        ResetDisplay();
    }
    
    changed(integer change){
        if (change & CHANGED_INVENTORY){
            BuildItemsLists();
            ResetDisplay();
            reset();
        }
    }
    
    touch_start(integer detected){
        integer l = llDetectedLinkNumber(0);
        channel = ((integer)llFrand(123456.0) +1) * -1;
        CListener = llListen( channel, "", "", "");
        if(l==1 || l==(miniScreens+5)){
            if (isOutOfService){
                ResetDisplay();
                if (llDetectedKey(0) == llGetOwner()){
                    avatar = llGetOwner();
                    llOwnerSay("\nWarning: This vendor is OUT OF SERVICE!\nError: "+errorLog+"\nRead the Guide for more details");
                    llDialog(avatar,"\nWarning: This Vendor is OUT OF SERVICE!\n[Reset]: Click to make available.\n[Log Error]: Click to view the saved error.\n[Close]: Close this box without enabling the vendor.",["Reset","Log Error","Close","Guide"],channel);
                }           
                llInstantMessage(llDetectedKey(0),"\nWarning: This vendor is OUT OF SERVICE!\nPlease secondlife:///app/agent/"+llGetOwner()+"/im for support if needed.");
            }
            else{
                if(llGetTexture(0) == "MainTexture" || llGetTexture(0) == "ComingSoonTexture"){
                    llInstantMessage(llDetectedKey(0),"\nWelcome to "+llGetRegionName()+ guide);
                }
                else if (avatar == NULL_KEY){ 
                    updateProductInfo();
                    avatar = llDetectedKey(0);
                    IPNEndpointRequest_id = llRequestURL();
                    orderID = "sale_"+ llMD5String((string)llGenerateKey(), (integer)llFrand(123456789.0));
                    active = TRUE;
                    txStatus = "new";
                    llSetTimerEvent(120);
                    if (avatar == llGetOwner()){
                        llSetLinkPrimitiveParamsFast((miniScreens+6),[PRIM_TEXT, "Administration Mode...",<1, 0, 0>, 1.0]);
                        llDialog(llGetOwner(), "\n[Guide]: Give you a documentation notecard.\n[Buy Test]: Opens the purchase menu.\n[Get]: Give you the selected item.\n[Remove]: Removes the selected item.\n[Backup]: Give you a copy of the item and texture.",["Remove","Backup","Close","Guide","Buy Test","Get"], channel);  
                    }
                    else{
                        showBuyMenu();
                    }
                }
                else if (avatar != NULL_KEY && avatar != llDetectedKey(0)){ 
                    llInstantMessage(llDetectedKey(0), "This device is in use!/nPlease wait...");
                }
                else if (active && avatar == llDetectedKey(0) && invoiceID == ""){ 
                    updateProductInfo();
                    showBuyMenu();
                }
                else if (active && avatar == llDetectedKey(0) && invoiceID != "" && invoiceURL != ""){ 
                llInstantMessage(avatar, "\nTransaction in progress in wait of your payment...");
                llLoadURL(avatar, "Click to open the payment page.\nYour invoice ID is : "+ invoiceID +"\nThank you for your purchase!", invoiceURL);
                }
            }
        }
        else if(l>1 && l<(miniScreens+2) && !isOutOfService){
            integer i;
            for (i=2; i<(miniScreens+2); i++){
                llSetLinkPrimitiveParamsFast(i,[PRIM_COLOR,ALL_SIDES, <1.0,1.0,1.0>, 1.0,
                PRIM_FULLBRIGHT,ALL_SIDES,FALSE,
                PRIM_FULLBRIGHT,0,TRUE]);
            }
            llSetLinkPrimitiveParamsFast(l,[
            PRIM_COLOR,ALL_SIDES, <1.0, 0.0, 0.0>, 1.0,
            PRIM_COLOR, 0, <1.0, 1.0, 1.0>, 1.0,
            PRIM_FULLBRIGHT,ALL_SIDES,TRUE]);
            list params= llGetLinkPrimitiveParams(l,[PRIM_TEXTURE, 0]);
            llSetLinkPrimitiveParamsFast(LINK_ROOT,[
            PRIM_TEXTURE, 0,llList2String(params,0), <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0,
            PRIM_FULLBRIGHT,0,TRUE]);
            if(llGetTexture(0) == "MainTexture" || llGetTexture(0) == "ComingSoonTexture"){
                llSetLinkPrimitiveParamsFast((miniScreens+6),[PRIM_TEXT,"Product Not Available Yet!",<1.0, 1.0, 0.0>, 1.0]);
                }
                else{
                    updateProductInfo();
                    llSetLinkPrimitiveParamsFast((miniScreens+6),[PRIM_TEXT,productName+ "\nPrice: "+price+" "+currency+" in "+defaultPaymentMethod,<1.0, 1.0, 0.0>, 1.0]);
                }
        }
        else if(l==(miniScreens+2)){
            GoBack(llDetectedKey(0));
        }
        else if(l==(miniScreens+3)){
            GoNext();
        }
        else if(l==(miniScreens+4)){
            if(llGetTexture(0) == "MainTexture" || llGetTexture(0) == "ComingSoonTexture" ){
                llInstantMessage(llDetectedKey(0),"\nWelcome to "+llGetRegionName()+ guide);
            }
            else{
                updateProductInfo();
                llInstantMessage(llDetectedKey(0),"\nItem Name:\n"+ productName +"\nPrice: "+ price +" "+ currency +"\nItem Description:\n"+ productDescription+"\nPayment with: "+defaultPaymentMethod);
            }
        }
    }
    
    http_request(key id, string method, string body){
        if (id == IPNEndpointRequest_id && method == URL_REQUEST_GRANTED){
            IPNEndpointURL = body;
            llHTTPResponse(id, 200, ""); 
        }     
        else if (id != IPNEndpointRequest_id && llGetHTTPHeader(id, "x-remote-ip") == HttpInAllowedIP){
            if (method == "POST" && llJsonGetValue(body, ["orderId"]) == orderID &&  llJsonGetValue(body, ["id"]) == invoiceID){
                string status = llJsonGetValue(body, ["status"]);
                if(status == "expired" || status == "invalid"){
                    llInstantMessage(avatar, "Operation Fail!\nInvoice ID: "+ invoiceID +" status is "+ status +".\nPlease try again or contact "+ llKey2Name(llGetOwner()) +" and provide your invoice ID: \n"+ invoiceID +"\nif you did a payment.");
                    if (notifications){
                        llOwnerSay("\nWarning: Invoice ID: "+ invoiceID +" expired!\n"+ llKey2Name(avatar) +" did not pay in time...");
                    }
                    llHTTPResponse(id, 200, "");
                    reset();          
                }
                else if(status == "paid"){
                    llSetLinkPrimitiveParamsFast((miniScreens+6),[
                PRIM_TEXT, "Processing: Waiting Confirmations...",<1, 0.5, 0>, 1.0]);
                    llInstantMessage(avatar, "\nThank you for your purchase.\nInvoice ID: "+ invoiceID +" is paid and in wait of the usual confirmations.");
                    if (notifications){
                        llOwnerSay("\n"+ llKey2Name(avatar) +" purchased "+ productName +" for "+ price +" "+ currency +"!\nYou have recived: "+ llJsonGetValue(body, ["btcPrice"]) +" "+ defaultPaymentMethod +".\nInvoice ID: "+ invoiceID +" Paid (waiting confirmations).");
                    }
                    txStatus = "paid";
                    llSetTimerEvent(60);
                    llHTTPResponse(id, 200, "");
                }
                else if(status == "confirmed" || status == "complete"){
                    llInstantMessage(avatar, "\nThank you for your purchase!\nInvoice ID: "+ invoiceID +" was fully paid and confirmed.");
                    llGiveInventory(avatar, productName);
                    if (notifications){
                        llOwnerSay("\nInvoice ID: " + invoiceID +" Confirmed.");
                    }
                    llHTTPResponse(id, 200, "");
                    reset();
                }
            }
        }    
        llHTTPResponse(id, 200, ""); 
    }
    
    http_response(key id, integer status, list metaData, string Response){
        if (status == 200 ){
            if (id == requestRates_id){
                string rateJson = llJsonGetValue(Response, [0]);
                if(rateJson != JSON_INVALID){
                    string currencyName = llJsonGetValue(rateJson, ["name"]);
                    string rate =  llJsonGetValue(rateJson, ["rate"]);
                    float cryptoAmount = (float)price / (float)rate;
                    llDialog(avatar,"\nThank you for your purchase!\nThe price " + price +" "+ currencyName +"s at the current rate of " + rate +" "+ currency +" per "+ defaultPaymentMethod +", this do ~"+ (string)cryptoAmount + " " + defaultPaymentMethod +".\n\nDo you have enough coins in your wallet ?",["Yes","Close"],channel);
                }
                else{
                    llInstantMessage(avatar,"\nThere is a problem with the BTCPay server: The rates data source is unavailable!.\nPlease try again after some minutes...");
                    llOwnerSay("\nDetected problem with BTCPay server!.\nError:\nRates data source is unavailable.\nStatus :"+ status);
                    reset();            
                }            
            }
            else if (id == requestInvoice_id){ 
                invoiceID = llJsonGetValue(Response, ["invoiceId"]);
                invoiceURL = llJsonGetValue(Response, ["invoiceUrl"]);
                if (invoiceID == "" || invoiceURL == ""){
                    isOutOfService = TRUE;
                    llOwnerSay("\nDetected problem with BtcPay server!. This vendor is OUT OF SERVICE.\nWarning: Empty invoiceID or invoiceURL.\nStatus :"+ status +"\n"+ Response);
                    errorLog = Response;
                    reset();
                }
                else {
                llLoadURL(avatar, "Click to open the payment page.\nYour invoice ID is : "+ invoiceID +"\nThank you for your purchase!", invoiceURL);
                llSetLinkPrimitiveParamsFast((miniScreens+6),[
                PRIM_TEXT, "Processing: Waiting Your Payment...",<1, 0.5, 0>, 1.0]);
                llInstantMessage(avatar, "\nYour invoice ID is : \n"+ invoiceID +"\nYou may need it in case of problem.\nThank you for your purchase!");
                }
            }
        }
        else {
            isOutOfService = TRUE;
            string error = llJsonGetValue( llJsonGetValue(Response, ["Store"]),0);
            if (error == ""){ error = Response;}
            llOwnerSay("\nDetected problem with BtcPay server!. This vendor is OUT OF SERVICE.\nStatus :"+ status +"\n"+ error);
           errorLog = error;
           reset();
           
        }
    }
    
    listen(integer channel, string name, key id, string Box){
        if(avatar == llGetOwner()){
            if(Box == "Remove"){ 
                llRemoveInventory(productName);
                llRemoveInventory("img_"+productName);
                BuildItemsLists();
                ResetDisplay();
                reset();
            }
            else if(Box == "Backup"){ 
                llGiveInventoryList(avatar, "Backup_"+productName,[productName,"img_"+productName]);
                reset();
            }
            else if(Box == "Get"){ 
                llGiveInventory(avatar,productName);
                reset();
            }
            else if(Box == "Guide"){ 
                llGiveInventory(avatar,"BTCPay Crypto Vendor Guide");
                reset();
            }
             else if (Box == "Buy Test"){
                showBuyMenu();
            }
            else if (Box == "Close"){ reset();}
            else if (Box == "Buy"){
                requestCurrentRate();
            }
            else if (Box == "Info"){
                updateProductInfo();
                llInstantMessage(avatar,buyGuide);
                reset();
            }
            else if (Box == "Yes"){
                requestInvoice();
            }
            else if (Box == "Reset" && isOutOfService && avatar == llGetOwner()){
                if(namesList!=[]){
                isOutOfService = FALSE;
                reset();
                }
                else{reset();}
            }
            else if (Box == "Log Error" && avatar == llGetOwner()){
                if (errorLog == ""){
                    llOwnerSay("No errors to log");
                } 
                else{
                    llOwnerSay(errorLog);
                }
            }
        }
    }
    
    timer(){
        if(active && invoiceID == "" && txStatus == "new"){
            llInstantMessage(avatar,"\nOperation timeout!\nPlease click the vendor again to retry.");
            reset();
        }
        else if (active && txStatus == "paid"){
            llInstantMessage(avatar,"\nTransaction in progress...\nWaiting peers confirmations.");
            llSetTimerEvent(60);
        }
    }
}

/*
# My Tip-Jars:
Usually nobody cares about the developers and the creators of the free and open source contents... but if you think that my work deserves more than a simple thank you, consider making a small donation using paypal or others here:

BTC: bc1ququ5vxy3yfpqn6dd5p4xfnk35ljfgem2jf2tf2
LTC: LL6dMuxLCWy6rB7h3AHCR5nkvdV6SoFNEk
ETH: 0xa3E82b8D653Db863dBB557C8Ed8A01f6570bd990
USDT ETH Network: 0xa3E82b8D653Db863dBB557C8Ed8A01f6570bd990
USDT SOL Network: 4NzQh2wW8yxsmQzs5mVdQaaRkcpvvuonj439sQ67DgDv
DOGE: DFPrdKUtYJS8jqPpmECypdQPumCykK5jHp
XMR: 4AEJf5HiQkiiafQRzV2gmfJjUHEKUSgetjb7bqn7fQQ7GfJe21nmE29GMBhV1z6pvC45yVKVkvAH97cp4bkPpJHH4m3gZfQ

Thank You Very Much :)
*/