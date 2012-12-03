LineaBrowser = function (){
    var deligates = {
    buttonPress: [],
    buttonRelease: [],
    barcodeData: [],
    magneticCardData: [],
    magneticCardRawData: [],
    magneticCardEncryptedData: [],
    magneticCardEncryptedRawData: [],
    connectionState: [],
    creditCardData: []
    };
    var scopes = {
    buttonPress: [],
    buttonRelease: [],
    barcodeData: [],
    magneticCardData: [],
    magneticCardRawData: [],
    magneticCardEncryptedData: [],
    magneticCardEncryptedRawData: [],
    connectionState: [],
    creditCardData: []
    };
    var emptyFn = function (){};
    var errorFn = function (params){
        //alert(params);
    };
    var landingPage = '';
    var commandQueue = '';
    var addToQueue = function (command, args){
        cordova.exec(emptyFn, errorFn, "LineaDevice", command, args);
    };
    return {
        version: 2,
        emptyFn: emptyFn,
        errorFn: errorFn,
        //CONN_STATES
    CONN_DISCONNECTED:0,
    CONN_CONNECTING:1,
    CONN_CONNECTED:2,
        //SCAN_MODES
    MODE_SINGLE_SCAN:0,
    MODE_MULTI_SCAN:1,
        //BUTTON_STATES
    BUTTON_DISABLED:0,
    BUTTON_ENABLED:1,
        //MS_MODES
    MS_PROCESSED_CARD_DATA:0,
    MS_RAW_CARD_DATA:1,
        //BT_MODES
    BARCODE_TYPE_DEFAULT:0,
    BARCODE_TYPE_EXTENDED:1,
        
        
        
    BAR_TYPES: {
    BAR_ALL: 0,
    BAR_UPC: 1,
    BAR_CODABAR: 2,
    BAR_CODE25_NI2OF5: 3,
    BAR_CODE25_I2OF5: 4,
    BAR_CODE39: 5,
    BAR_CODE93: 6,
    BAR_CODE128: 7,
    BAR_CODE11: 8,
    BAR_CPCBINARY: 9,
    BAR_DUN14: 10,
    BAR_EAN2: 11,
    BAR_EAN5: 12,
    BAR_EAN8: 13,
    BAR_EAN13: 14,
    BAR_EAN128: 15,
    BAR_GS1DATABAR: 16,
    BAR_ITF14: 17,
    BAR_LATENT_IMAGE: 18,
    BAR_PHARMACODE: 19,
    BAR_PLANET: 20,
    BAR_POSTNET: 21,
    BAR_INTELLIGENT_MAIL: 22,
    BAR_MSI: 23,
    BAR_POSTBAR: 24,
    BAR_RM4SCC: 25,
    BAR_TELEPEN: 26,
    BAR_PLESSEY: 27,
    BAR_PDF417: 28,
    BAR_MICROPDF417: 29,
    BAR_DATAMATRIX: 30,
    BAR_AZTEK: 31,
    BAR_QRCODE: 32,
    BAR_MAXICODE: 33,
    BAR_LAST: 34,
        
    BAR_EX_ALL:0,
    BAR_EX_UPCA:1,
    BAR_EX_CODABAR:2,
    BAR_EX_CODE25_NI2OF5:3,
    BAR_EX_CODE25_I2OF5:4,
    BAR_EX_CODE39:5,
    BAR_EX_CODE93:6,
    BAR_EX_CODE128:7,
    BAR_EX_CODE11:8,
    BAR_EX_CPCBINARY:9,
    BAR_EX_DUN14:10,
    BAR_EX_EAN2:11,
    BAR_EX_EAN5:12,
    BAR_EX_EAN8:13,
    BAR_EX_EAN13:14,
    BAR_EX_EAN128:15,
    BAR_EX_GS1DATABAR:16,
    BAR_EX_ITF14:17,
    BAR_EX_LATENT_IMAGE:18,
    BAR_EX_PHARMACODE:19,
    BAR_EX_PLANET:20,
    BAR_EX_POSTNET:21,
    BAR_EX_INTELLIGENT_MAIL:22,
    BAR_EX_MSI_PLESSEY:23,
    BAR_EX_POSTBAR:24,
    BAR_EX_RM4SCC:25,
    BAR_EX_TELEPEN:26,
    BAR_EX_UK_PLESSEY:27,
    BAR_EX_PDF417:28,
    BAR_EX_MICROPDF417:29,
    BAR_EX_DATAMATRIX:30,
    BAR_EX_AZTEK:31,
    BAR_EX_QRCODE:32,
    BAR_EX_MAXICODE:33,
    BAR_EX_RESERVED1:34,
    BAR_EX_RESERVED2:35,
    BAR_EX_RESERVED3:36,
    BAR_EX_RESERVED4:37,
    BAR_EX_RESERVED5:38,
    BAR_EX_UPCA_2:39,
    BAR_EX_UPCA_5:40,
    BAR_EX_UPCE:41,
    BAR_EX_UPCE_2:42,
    BAR_EX_UPCE_5:43,
    BAR_EX_EAN13_2:44,
    BAR_EX_EAN13_5:45,
    BAR_EX_EAN8_2:46,
    BAR_EX_EAN8_5:47,
    BAR_EX_CODE39_FULL:48,
    BAR_EX_ITA_PHARMA:49,
    BAR_EX_CODABAR_ABC:50,
    BAR_EX_CODABAR_CX:51,
    BAR_EX_SCODE:52,
    BAR_EX_MATRIX_2OF5:53,
    BAR_EX_IATA:54,
    BAR_EX_KOREAN_POSTAL:55,
    BAR_EX_CCA:56,
    BAR_EX_CCB:57,
    BAR_EX_CCC:58,
    BAR_EX_LAST:59
    },
        /**
         * Clears the queue of commands about to be sent to the LineaBrowser app.
         */
    clearCommandQueue: function(){
        commandQueue = '';
        window.location.href = 'javascript:void(0);';
    },
        /**
         * Adds an event listener to the specified event.
         * @param {String} event The event name to attach function to.
         * @param {Function} fn The function to execute when event fires.
         */
    on: function (event, fn, scope){
        if(typeof deligates[event] == 'undefined'){
            throw "LineaBrowser.on: first argument must be a valid event.";
            return false;
        }
        if(!(fn instanceof Function)){
            throw "LineaBrowser.on: second argument must be of type function.";
            return false;
        }
        deligates[event].push(fn);
        scopes[event].push(scope || window);
        return true;
    },
        /**
         * Removes an event listener.
         * @param {String} event The event name to search for function in.
         * @param {Function} fn The function to remove.
         */
    un: function (event, fn){
        if(typeof deligates[event] == 'undefined'){
            throw "LineaBrowser.un: first argument must be a valid event.";
            return false;
        }
        var len = deligates[event].length;
        for(var i=0;i<len;i++)
            if(deligates[event][i] === fn){
                deligates[event].splice(i, 1);
                scopes[event].splice(i, 1);
                return true;
            }
        return false;
    },
        /**
         * Enables or disables the specified barcode.
         * @param {Integer} barcodeType The specified barcode of LineaBrowser.BAR_TYPES.*
         * @param {Boolean} enabled Weather the barcode will be enabled or disabled.
         */
    enableBarcode: function (barcodeType, enabled){
        barcodeType = parseInt(barcodeType) || 0;
        enabled = (enabled)?1:0;
        addToQueue('enableBarcode', [barcodeType, enabled]);
        return true;
    },
        /**
         * Plays a sound though the Linea device.
         * @param {Integer} volume The volume to play sound at (Currently the Linea device does not support other values than 0 or 100).
         * @param {Array} beepData An array of data to play.
         * @example LineaBrowser.playSound(100, [1000, 200, 4000, 100, 100, 500]); // This will play as the following: 1000mhz @ 200ms, 4000mhz @ 100ms, 100mhz @ 500ms
         */
    playSound: function (volume, beepData){
        volume = parseInt(volume) || 0;
        if(!(beepData instanceof Array)){
            throw "Error on LineaBrowser.playSound: second argument must be an array";
            return false;
        }
        var len = beepData.length;
        for(var i=0;i<len;i++)
            beepData[i] = parseInt(beepData[i]) || 0;
        addToQueue('playSound', [volume, beepData]);
        return true;
    },
        /**
         * Turns on the barcode lazer (it will accept barcodes).
         */
    startScan: function (){
        addToQueue('startScan', []);
        return true;
    },
        /**
         * Turns off the barcode lazer (it will stop accepting barcodes).
         */
    stopScan: function (){
        addToQueue('stopScan', []);
        return true;
    },
        /**
         * Used to turn off the lazer after a the specified amount of time has passed without scanning a barcode.
         * @param {Integer} timeout The time in seconds to turn off lazer on no barcode scan (0 will never timeout).
         */
    setScanTimeout: function (timeout){
        timeout = parseInt(timeout) || 0;
        addToQueue('setScanTimeout', [timeout]);
        return true;
    },
        /**
         * Used to specifiy weather the button on the device will activate the lazer when pressed. (the buttonPress and buttonRelease event will still fire)
         * @param {Integer} mode One of the following: LineaBrowser.BUTTON_DISABLED or LineaBrowser.BUTTON_ENABLED
         */
    setScanButtonMode: function (mode){
        mode = (mode)?1:0;
        addToQueue('setScanButtonMode', [mode]);
        return true;
    },
        /**
         * Used to tell the barcode engine to go into persistant scanning or not. Persistant scanning will keep
         * the lazer active even when a barcode is scanned allowing you to scan multiple barcodes in sequence
         * without having to keep pressing and depressing the button.
         * @param {Integer} mode The mode the barcode engine goes into. Should be on of the following: LineaBrowser.MODE_SINGLE_SCAN or LineaBrowser.MODE_MULTI_SCAN.
         */
    setScanMode: function (mode){
        mode = (mode)?1:0;
        addToQueue('setScanMode', [mode]);
        return true;
    },
        /**
         * Sets the beep settings for when a barcode is successfully scanned.
         * @param {Boolean} Weather the beep should play or not.
         * @param {Integer} Volume to play the sound at (Currently the Linea device does not support this).
         * @param {Array} Beep data to send (see LineaBrowser.playSound for more info)
         */
    setScanBeep: function (enabled, volume, beepData){
        enabled = (enabled)?1:0;
        volume = parseInt(volume) || 0;
        if(!(beepData instanceof Array)){
            throw "Error on LineaBrowser.playSound: second argument must be an array";
            return false;
        }
        if(!(beepData instanceof Array)){
            throw "Error on LineaBrowser.setScanBeep: forth argument must be an array";
            return false;
        }
        var len = beepData.length;
        for(var i=0;i<len;i++)
            beepData[i] = parseInt(beepData[i]) || 0;
        addToQueue('setScanBeep', [enabled, volume, beepData]);
        return true;
    },
        /**
         * Hides the config bar at the bottom of the screen to give more realestate or to make your own. (this will resize the window size)
         * DEPRICATED
         */
    hideConfigBar:function (){
        //addToQueue('hideConfigBar', []);
        return false;
    },
        /**
         * Shows the config bar at the bottom of the screen. (this will resize the window size)
         * DEPRICATED
         */
    showConfigBar: function (){
        //addToQueue('showConfigBar', []);
        return false;
    },
        /**
         * Sets the mode which the card reader data is returned. If MS_PROCESSED_CARD_DATA is used it will return with magneticCardData event
         * if MS_RAW_CARD_DATA is used it will return the card data with magenticCardRawData.
         * @param {Integer} mode The mode to use. (should be one of the following LineaBrowser.MS_PROCESSED_CARD_DATA or LineaBrowser.MS_RAW_CARD_DATA)
         */
    setMSCardDataMode: function (mode){
        mode = parseInt(mode) || 0;
        addToQueue('setMSCardDataMode', [mode]);
        return true;
    },
        /**
         * Sets which barcode type subset is used for returning. If BARCODE_TYPE_DEFAULT is used it will use
         * LineaBrowser.BAR_TYPES.*(^_EX) (without the _EX extension). If BARCODE_TYPE_EXTENDED is used it wil
         * return barcode types using LineaBrowser.BAR_TYPES.*_EX (with the _EX extension).
         * @param {Integer} mode The mode to return the barcode type as. (Should be one of LineaBrowser.BARCODE_TYPE_DEFAULT or LineaBrowser.BARCODE_TYPE_EXTENDED)
         */
    setBarcodeTypeMode: function (mode){
        mode = parseInt(mode) || 0;
        addToQueue('setBarcodeTypeMode', [mode]);
        return true;
    },
        /**
         * This function will be fired when the button is pressed on the LineaDevice. You may attach a listener to this by calling:
         * <code>
         *  LineaBrowser.on('buttonPressed', function (button){
         *      // Your Code
         *  });
         * </code>
         * The first parameter is which button was pressed, however it will always return 0 currently.
         * @private
         */
    buttonPressed: function (){
        var len = deligates.buttonPress.length;
        for(var i=0;i<len;i++)
            deligates.buttonPress[i].apply(scopes.buttonPress[i], arguments);
    },
        /**
         * This function will be fired when the button is released on the LineaDevice. You may attach a listener to this by calling:
         * <code>
         *  LineaBrowser.on('buttonReleased', function (button){
         *      // Your Code
         *  });
         * </code>
         * The first parameter is which button was pressed, however it will always return 0 currently.
         * @private
         */
    buttonReleased: function (){
        var len = deligates.buttonRelease.length;
        for(var i=0;i<len;i++)
            deligates.buttonRelease[i].apply(scopes.buttonRelease[i], arguments);
    },
        /**
         * This function will be fired when a card is successfully read on the LineaDevice. You may attach a listener to this by calling:
         * <code>
         *  LineaBrowser.on('magneticCardData', function (track1, track2, track3){
         *      // Your Code
         *  });
         * </code>
         * The parameters passed are track1, track2, and track3.
         * @private
         */
    magneticCardData: function (){
        var len = deligates.magneticCardData.length;
        for(var i=0;i<len;i++)
            deligates.magneticCardData[i].apply(scopes.magneticCardData[i], arguments);
    },
        /**
         * Currently not fully supported!
         */
    magneticCardRawData: function (){
        var len = deligates.magneticCardRawData.length;
        for(var i=0;i<len;i++)
            deligates.magneticCardRawData[i].apply(scopes.magneticCardRawData[i], arguments);
    },
        /**
         * Currently not fully supported!
         */
    magneticCardEncryptedData: function (){
        var len = deligates.magneticCardEncryptedData.length;
        for(var i=0;i<len;i++)
            deligates.magneticCardEncryptedData[i].apply(scopes.magneticCardEncryptedData[i], arguments);
    },
        /**
         * Currently not fully supported!
         */
    magneticCardEncryptedRawData: function (){
        var len = deligates.magneticCardEncryptedRawData.length;
        for(var i=0;i<len;i++)
            deligates.magneticCardEncryptedRawData[i].apply(scopes.magneticCardEncryptedRawData[i], arguments);
    },
        /**
         * This function will be fired when a barcode is successfully read on the LineaDevice. You may attach a listener to this by calling:
         * <code>
         *  LineaBrowser.on('barcodeData', function (barcode, type){
         *      // Your Code
         *  });
         * </code>
         * The first argument is the barcode's data as a string and the second argument is the
         * barcode type as an integer which should correspond to the number in LineaBrowser.BAR_TYPES.*(_EX)?
         * @private
         */
    barcodeData: function (){
        var len = deligates.barcodeData.length;
        for(var i=0;i<len;i++)
            deligates.barcodeData[i].apply(scopes.barcodeData[i], arguments);
    },
        /**
         * This function will be fired when the LineaDevice changes connection state. You may attach a listener to this by calling:
         * <code>
         *  LineaBrowser.on('connectionState', function (state){
         *      // Your Code
         *  });
         * </code>
         * The first parameter is the state corresponding to LineaBrowser.CONN_* for which state it was changed into.
         * @private
         */
    connectionState: function (){
        var len = deligates.connectionState.length;
        for(var i=0;i<len;i++)
            deligates.connectionState[i].apply(scopes.connectionState[i], arguments);
    },
        /**
         * This function will be fired when the LineaDevice reads a credit card. You may attach a listener to this by calling:
         * <code>
         *  LineaBrowser.on('creditCardData', function (accountNumber, cardholderName, experationYear, experationMonth, serviceCode, discretionaryData, firstName, lastName){
         *      // Your Code
         *  });
         * </code>
         * See above for the parameters passed and their names.
         * @private
         */
    creditCardData: function (){
        var len = deligates.creditCardData.length;
        for(var i=0;i<len;i++)
            deligates.creditCardData[i].apply(scopes.creditCardData[i], arguments);
    },
    eventDelegate: function (event){
        if(LineaBrowser[event[0]]){
            // This is needed because arguments is not a true array it's a fake array so we need to clone it.
            var args = [];
            for(var i=1;i<event.length;i++){
                args.push(event[i]);
            }
            
            LineaBrowser[event[0]].apply(LineaBrowser, args);
        }
    }
};
}();
document.addEventListener('deviceready', function (){
    cordova.exec(LineaBrowser.eventDelegate, LineaBrowser.errorFn, "LineaDevice", "monitor", []);
}, false);
if(window.onLineaBrowserLoad)
    window.onLineaBrowserLoad();
window.onLineaBrowserLoad = null;