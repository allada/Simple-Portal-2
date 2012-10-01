/****h* Functions
 FUNCTION
 In order to use Linea in your program, several steps have to be performed:
 - Include LineaSDK.h and libLineaSDK.a in your project.
 - Go to Frameworks and add ExternalAccessory framework
 - Edit your program plist file, add new element and select "Supported external accessory protocols" from the list, then add two items to it - \
 com.datecs.linea.pro.msr and com.datecs.linea.pro.bar
 *****/
/****h* Barcode Engine
 FUNCTION
 Functions for direct control of the barcode engine
 *****/
/****h* Security
 FUNCTION
 Starting from firmware 2.13, Linea provides strong cryptographic support for magnetic card data. The encryption is supported \
 on all Linea devices, from software point of view they are all the same, but provide different levels of hardware/firmware security.
 
 An overview of the security, provided by Linea (see each of the crypto functions for further detail):
 
 Hardware/Firmware: 
 
 For magnetic card encryption Linea is using AES256, which is the current industry standard encryption algorithm. The encryption key \
 resides in volatile, battery powered ram inside Linea's cpu (for Linea 1.5 onward) and is being lost if anyone tries to break in the \
 Linea device in order to prevent the key from being stolen. Magnetic card data, along with device serial number and some random bytes \
 (to ensure every packet will be different) are being sent to the iOS program in an encrypted way. 
 
 
 Software: 

 Currently there are 2 types of keys, that can be loaded into Linea: 
 - AUTHENTICATION KEY - used for device authentication (for example the program can lock itself to work with very specific Linea device) \
 and encryption of the firmware 
 - ENCRYPTION KEY - used for magnetic card data encryption. To use msr encryption, you don't need to set the AUTHENTICATION KEY. 
 
 Keys: The keys can be set/changed in two ways: 
 1. Using plain key data - this method is easy to use, but less secure, as it relies on program running on iPod/iPhone to have the key \
 inside, an attacker could compromise the system and extract the key from device's memory. Call @cryptoSetKey to set the keys this way. \
 If there is an existing key of the same type inside Linea, you have to pass it too. 
 
 2. Using encrypted key data - this method is harder to implement, but provides better security - the key data, encrypted with old key \
 data is sent from a server in secure environment to the program, running on the iOS, then the program forwards it to the Linea. \
 The program itself have no means to decrypt the data, so an attacker can't possibly extract the key. Refer to @cryptoSetKey documentation \
 for more detailed description of the loading process.
 
 The initial loading of the keys should always be done in a secure environment. 
 
 Magnetic card encryption:

 Once ENCRYPTION KEY is set, all magnetic card data gets encrypted, and is now sent via @magneticCardEncryptedData instead. The LineaDemo \
 program contains sample code to decrypt the data block and extract the contents - the serial number and track data.
 
 As with keys, card data can be extracted on the iOS device itself (less secure, the application needs to have the key inside) or be sent \
 to a secure server to be processed. Note, that the encrypted data contains Linea's serial number too, this can be used for Data Origin \
 Verification, to be sure someone is not trying to mimic data, coming from another device. 
 
 
 Demo program: the sample program now have "Encryption" tab, where key management can be tested: 
 
 - New AES 256 key - type in the key you want to set (or change to) 
 - Old AES 256 key - type in the previous key, or leave blank if you set the key for the first time 
 
 [SET AUTHENTICATION KEY] and [SET ENCRYPTION KEY] buttons allow you to use the key info in the text fields above to set the key. 
 
 - Decryption key - type in the key, which the demo program will use to try to decrypt card data. This field should contain the \
 ENCRYPTION KEY, or something random, if you want to test failed card data decryption.
 *****/
/****h* Delegates
 FUNCTION
 Delegate functions, that provide notifications on Linea status and response to requests
 *****/

typedef enum {
	BAR_ALL=0, 
	BAR_UPC,
	BAR_CODABAR,
	BAR_CODE25_NI2OF5,
	BAR_CODE25_I2OF5,
	BAR_CODE39,
	BAR_CODE93,
	BAR_CODE128,
	BAR_CODE11,
	BAR_CPCBINARY,
	BAR_DUN14,
	BAR_EAN2,
	BAR_EAN5,
	BAR_EAN8,
	BAR_EAN13,
	BAR_EAN128,
	BAR_GS1DATABAR,
	BAR_ITF14,
	BAR_LATENT_IMAGE,
	BAR_PHARMACODE,
	BAR_PLANET,
	BAR_POSTNET,
	BAR_INTELLIGENT_MAIL,
	BAR_MSI,
	BAR_POSTBAR,
	BAR_RM4SCC,
	BAR_TELEPEN,
	BAR_PLESSEY,
	BAR_PDF417,
	BAR_MICROPDF417,
	BAR_DATAMATRIX,
	BAR_AZTEK,
	BAR_QRCODE,
	BAR_MAXICODE,
	BAR_LAST
}BARCODES;

typedef enum {
	BAR_EX_ALL=0, 
	BAR_EX_UPCA,
	BAR_EX_CODABAR,
	BAR_EX_CODE25_NI2OF5,
	BAR_EX_CODE25_I2OF5,
	BAR_EX_CODE39,
	BAR_EX_CODE93,
	BAR_EX_CODE128,
	BAR_EX_CODE11,
	BAR_EX_CPCBINARY,
	BAR_EX_DUN14,
	BAR_EX_EAN2,
	BAR_EX_EAN5,
	BAR_EX_EAN8,
	BAR_EX_EAN13,
	BAR_EX_EAN128,
	BAR_EX_GS1DATABAR,
	BAR_EX_ITF14,
	BAR_EX_LATENT_IMAGE,
	BAR_EX_PHARMACODE,
	BAR_EX_PLANET,
	BAR_EX_POSTNET,
	BAR_EX_INTELLIGENT_MAIL,
	BAR_EX_MSI_PLESSEY,
	BAR_EX_POSTBAR,
	BAR_EX_RM4SCC,
	BAR_EX_TELEPEN,
	BAR_EX_UK_PLESSEY,
	BAR_EX_PDF417,
	BAR_EX_MICROPDF417,
	BAR_EX_DATAMATRIX,
	BAR_EX_AZTEK,
	BAR_EX_QRCODE,
	BAR_EX_MAXICODE,
	BAR_EX_RESERVED1,
	BAR_EX_RESERVED2,
	BAR_EX_RESERVED3,
	BAR_EX_RESERVED4,
	BAR_EX_RESERVED5,
	BAR_EX_UPCA_2,
	BAR_EX_UPCA_5,
	BAR_EX_UPCE,
	BAR_EX_UPCE_2,
	BAR_EX_UPCE_5,
	BAR_EX_EAN13_2,
	BAR_EX_EAN13_5,
	BAR_EX_EAN8_2,
	BAR_EX_EAN8_5,
	BAR_EX_CODE39_FULL,
	BAR_EX_ITA_PHARMA,
	BAR_EX_CODABAR_ABC,
	BAR_EX_CODABAR_CX,
	BAR_EX_SCODE,
	BAR_EX_MATRIX_2OF5,
	BAR_EX_IATA,
	BAR_EX_KOREAN_POSTAL,
	BAR_EX_CCA,
	BAR_EX_CCB,
	BAR_EX_CCC,
	BAR_EX_LAST
}BARCODES_EX;

#ifndef FINANCIALCARD_DEFINED
#define FINANCIALCARD_DEFINED
typedef struct
{
    NSString *accountNumber;
    NSString *cardholderName;
    int  exirationYear;
    int  exirationMonth;
    NSString *serviceCode;
    NSString *discretionaryData;
    NSString *firstName;
    NSString *lastName;
}financialCard; 
#endif

/**
 * Connection state
 */
#ifndef CONNSTATES_DEFINED
#define CONNSTATES_DEFINED
typedef enum {
	CONN_DISCONNECTED=0,
	CONN_CONNECTING,
	CONN_CONNECTED
}CONN_STATES;
#endif

typedef enum {
	MODE_SINGLE_SCAN=0,
	MODE_MULTI_SCAN
}SCAN_MODES;

typedef enum {
	BUTTON_DISABLED=0,
	BUTTON_ENABLED
}BUTTON_STATES;

typedef enum {
	MS_PROCESSED_CARD_DATA=0,
	MS_RAW_CARD_DATA
}MS_MODES;

typedef enum {
	BARCODE_TYPE_DEFAULT=0,
	BARCODE_TYPE_EXTENDED
}BT_MODES;

/*******************************************************************************
 * Printer types
 *******************************************************************************/
#define PRINTER_PP50		0
#define PRINTER_PP55		1
#define PRINTER_CMP10		2
#define PRINTER_DPP350		3
#define PRINTER_DPP250		4
#define PRINTER_PP60		5

/*******************************************************************************
 * Data channels
 *******************************************************************************/
#define CHANNEL_PRN			1
#define CHANNEL_SMARTCARD	2
#define CHANNEL_GPRS		5
#define CHANNEL_MIFARE		16

/*******************************************************************************
 * Print aligning
 *******************************************************************************/
#define ALIGN_LEFT			0
#define ALIGN_CENTER		1
#define ALIGN_RIGHT			2
/*******************************************************************************
 * BARCODE MODULE SPECIFIC CONSTANTS
 *******************************************************************************/ 
// Barcode Printing Types
/**
 * Prints UPC-A barcode
 */
#define BAR_PRN_UPCA		0
/**
 * Prints UPC-E barcode
 */
#define BAR_PRN_UPCE		1
/**
 * Prints EAN-13 barcode
 */
#define BAR_PRN_EAN13		2
/**
 * Prints EAN-8 barcode
 */
#define BAR_PRN_EAN8		3
/**
 * Prints CODE39 barcode
 */
#define BAR_PRN_CODE39		4
/**
 * Prints ITF barcode
 */
#define BAR_PRN_ITF			5
/**
 * Prints CODABAR barcode
 */
#define BAR_PRN_CODABAR		6
/**
 * Prints CODE93 barcode
 */
#define BAR_PRN_CODE93		7
/**
 * Prints CODE128 barcode
 */
#define BAR_PRN_CODE128		8
/**
 * Prints 2D PDF-417 barcode
 */
#define BAR_PRN_PDF417		9
/**
 * Prints CODE128 optimized barcode. Supported only on PP-60, DPP-350 and DPP-250 printers, it makes the barcode lot smaller especially when numbers only are used
 */
#define BAR_PRN_CODE128AUTO	10
/**
 * Prints EAN128 optimized barcode. Supported only on PP-60, DPP-350 and DPP-250 printers, it makes the barcode lot smaller especially when numbers only are used
 */
#define BAR_PRN_EAN128AUTO	11

// Barcode Text Positopn
#define BAR_TEXT_NONE		0
#define BAR_TEXT_ABOVE		1
#define BAR_TEXT_BELOW		2
#define BAR_TEXT_BOTH		3

/* Intensity Levels */
#define INTENSITY70				0
#define INTENSITY80				1
#define INTENSITY90				2
#define INTENSITY100			3
#define INTENSITY120			4
#define INTENSITY150			5

/* Font Sizes */
#define FONT_9X16				0
#define FONT_18X16				1
#define FONT_9X32				2
#define FONT_18X32				3
#define FONT_12X24				4
#define FONT_24X24				5
#define FONT_12X48				6
#define FONT_24X48				7
#define FONT_DEFAULT			FONT_12X24

/* Font Styles */
#define FONT_PLAIN				0
#define FONT_BOLD				1
#define FONT_ITALIC				2
#define FONT_UNDERLINE			4
#define FONT_INVERSE			8


/* ResetDefaults Flags */
#define RESET_PRINTSETTINGS		1
#define RESET_FONTSETTINGS		2
#define RESET_BARCODESETTINGS	4
#define RESET_DONTSETPRINTER	0x80

/* Align Flags */
#define ALIGN_LEFT				0
#define ALIGN_CENTER			1
#define ALIGN_RIGHT				2
#define TEXT_WORDWRAP			1

#define TEXT_ROTATE_0			0
#define TEXT_ROTATE_90			1
#define TEXT_ROTATE_180			2

#define LINESPACE_DEFAULT		0x22

#define BLACKMARK_TRESHOLD_DEFAULT	0x68

/* Encryptions */
#define ALG_AES256				0

/* Encryptions */
/**
 * Authentication key
 */
#define KEY_AUTHENTICATION 0
/**
 * Encryption key, if set magnetic card data will be encrypted
 */
#define KEY_ENCRYPTION 1


#ifndef FIRMWAREINFO_DEFINED
typedef struct firmwareInfo
{
	NSString *deviceName;
	NSString *deviceModel;
	NSString *firmwareRevision;
	int		  firmwareRevisionNumber;
}firmwareInfo;
#endif



@protocol LineaDelegate
@optional
/****f* Delegates/connectionState
 FUNCTION
 Notifies about the current connection state
 SYNTAX
 */
-(void)connectionState:(int)state;
/*
 INPUTS
 state - connection state, one of:
 * CONN_DISCONNECTED - there is no connection to Linea and the sdk will not try to make one
 * CONN_CONNECTING - Linea is not currently connected, but the sdk is actively trying to
 * CONN_CONNECTED - Linea is connected
 *****/

/****f* Delegates/buttonPressed
 FUNCTION
 Notification sent when some of the Linea's buttons is pressed
 SYNTAX
 */
-(void)buttonPressed:(int)which;
/*
 INPUTS
 which - button identifier, one of:
 * 0 - right scan button
 *****/

/****f* Delegates/buttonReleased
 FUNCTION
 Notification sent when some of the Linea's buttons is released
 SYNTAX
 */
-(void)buttonReleased:(int)which;
/*
 INPUTS
 which - button identifier, one of:
 * 0 - right scan button
 *****/

/****f* Delegates/barcodeData
 FUNCTION
 Notification sent when barcode is successfuly read
 SYNTAX
 */
-(void)barcodeData:(NSString *)barcode type:(int)type;
/*
 INPUTS
 barcode - string containing barcode data
 type - barcode type, one of the BAR_* constants
 *****/

/****f* Delegates/magneticCardData
 FUNCTION
 Notification sent when magnetic card is successfuly read
 SYNTAX
 */
-(void)magneticCardData:(NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3;
/*
 INPUTS
 track1 - data contained in track 1 of the magnetic card or nil
 track2 - data contained in track 2 of the magnetic card or nil
 track3 - data contained in track 3 of the magnetic card or nil
 *****/

/****f* Delegates/magneticCardRawData
 FUNCTION
 Notification sent when magnetic card is successfuly read
 SYNTAX
 */
-(void)magneticCardRawData:(NSData *)tracks;
/*
 INPUTS
 tracks - Contains the raw magnetic card data. These are the bits directly from the magnetic head. \
 The maximum length of a single track is 704 bits (88 bytes), so the command returns the 3 tracks as 3x88 bytes block
 *****/

/****f* Delegates/magneticCardEncryptedData
 FUNCTION
 Notification sent when magnetic card is successfuly read. The data is encrypted via the selected encryption algorithm. \
 After decryption, the result data will be as follows:
 - Random data (4 bytes)
 - Device identification text (16 ASCII characters, unused bytes are 0)
 - Processed track data in the format: 0xF1 <track1 data>, 0xF2 <track2 data> 0xF3 <track3 data>. It is possible some of the \
 tracks will be empty, then the identifier will not be present too, for example 0xF1 <track1 data> 0xF3 <track3 data>
 - End of track data (byte 0x00)
 - CRC16 (2 bytes) - the CRC is performed from the start of the encrypted block (the Random Data block) to the end of the track data (including the 0x00 byte).
 The data block is rounded to 16 bytes

 In the more secure way, where the decryption key resides in a server only, the card read process will look something like:
 - (User) swipes the card 
 - (iOS program) receives the data via @magneticCardEncryptedData and sends to the server
 - (iOS program)[optional] sends current Linea serial number along with the data received from @magneticCardEncryptedData. This can \
 be used for data origin verification
 - (Server) decrypts the data, extracts all the information from the fields
 - (Server)[optional] if the ipod program have sent Linea serial number before, the server compares the received serial number \
 with the one that's inside the encrypted block 
 - (Server) checks if the card data is the correct one, i.e. all needed tracks are present, card is the same type as required, etc \
 and sends back notification to the ipod program. 
 
 SYNTAX
 */
-(void)magneticCardEncryptedData:(int)encryption data:(NSData *)data;
/*
 INPUTS
 data - Contains the encrypted card data
 *****/

/****f* Delegates/magneticCardEncryptedRawData
 FUNCTION
 Notification sent when magnetic card is successfuly read. The raw card data is encrypted via the selected encryption algorithm. \
 After decryption, the result data will be as follows:
 - Random data (4 bytes)
 - Device identification text (16 ASCII characters, unused bytes are 0)
 - Track data: the maximum length of a single track is 704 bits (88 bytes), so track data contains 3x88 bytes
 - CRC16 (2 bytes) - the CRC is performed from the start of the encrypted block (the Random Data block) to the end of the track data.
 The data block is rounded to 16 bytes
 SYNTAX
 */
-(void)magneticCardEncryptedRawData:(int)encryption data:(NSData *)data;
/*
 INPUTS
 data - Contains the encrypted raw card data
 *****/
@end

@interface Linea : NSObject {
@private

@public
}

/****f* Functions/sharedDevice
 FUNCTION
 Creates and initializes new Linea class instance or returns already initalized one. Use this function, if you want to \
 access Linea from multiple classes
 SYNTAX
 */
+(id)sharedDevice;
/*
 INPUTS
 RESULT
 *****/

/****f* Functions/addDelegate
 FUNCTION
 Allows unlimited delegates to be added to a single Linea instance. This is useful in the case of global Linea \
 class and every view can use @addDelegate when the view is shown and @removeDelegate when no longer needs to monitor \
 Linea events
 SYNTAX
 */
-(void)addDelegate:(id)newDelegate;
/*
 INPUTS
 newDelegate - the delegate that will be notified of Linea events
 RESULT
 *****/

/****f* Functions/removeDelegate
 FUNCTION
 Removes delegate, previously added with @addDelegate
 SYNTAX
 */
-(void)removeDelegate:(id)newDelegate;
/*
 INPUTS
 newDelegate - the delegate to be removed
 RESULT
 *****/

/****f* Functions/connect
 FUNCTION
 Tries to connect to Linea in the background, connection status notifications will be passed through the delegate. \
 Once connect is called, it will automatically try to reconnect until disconnect is called.
 Note that "connect" call works in background and will notify the caller of connection success via connectionState \
 delegate. Do not assume the library has fully connected to the device after this call, but wait for the notification.
 SYNTAX
 */
-(void)connect;
/*
 INPUTS
 RESULT
 *****/

/****f* Functions/disconnect
 FUNCTION
 Stops the sdk from trying to connect to Linea and breaks existing connection.
 SYNTAX
 */
-(void)disconnect;
/*
 INPUTS
 RESULT
 *****/

/****f* Functions/barcodeType2Text
 FUNCTION
 Helper function to get the name of specific barcode type.
 SYNTAX
 */
-(NSString *)barcodeType2Text:(int)barcodeType;
/*
 INPUTS
 barcodeType - barcode type, one of the BAR_* constants
 RESULT
 NSPortTimeoutException if there is no connection to Linea 
 NSInvalidArgumentException if some of the input parameters are wrong
 *****/

/****f* Functions/startScan
 FUNCTION
 Starts barcode engine.
 In single scan mode the laser will be on until barcode is successfully read, the timeout elapses \
 (set via call to @setScanTimeout) or if stopScan is called.
 In multi scan mode the laser will stay on even if barcode is successfully read allowing series of \
 barcodes to be scanned within a single read session. The scanning will stop if no barcode is scanned \
 in the timeout interval (set via call to @setScanTimeout) or if stopScan is called.
 SYNTAX
 */
-(void)startScan;
/*
 INPUTS
 RESULT
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Functions/stopScan
 FUNCTION
 Stops ongoing scan started with @startScan
 SYNTAX
 */
-(void)stopScan;
/*
 INPUTS
 RESULT
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Functions/getScanTimeout
 FUNCTION
 Returns the current scan timeout. See @setScanTimeout for more detailed description.
 This setting is not persistent and is best to configure it upon connect.
 SYNTAX
 */
-(int)getScanTimeout;
/*
 INPUTS
 RESULT
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Functions/setScanTimeout
 FUNCTION
 Sets the scan timeout. This it the max time that the laser will be on in \
 single scan mode, or the time without scanning that will force the laser off in multi scan mode.
 This setting is not persistent and is best to configure it upon connect.
 SYNTAX
 */
-(void)setScanTimeout:(int)timeout;
/*
 INPUTS
 timeout - barcode engine timeout in seconds [1-60] or 0 to disable timeout. Default is 0
 RESULT
 NSPortTimeoutException if there is no connection to Linea 
 NSInvalidArgumentException if some of the input parameters are wrong
 *****/

/****f* Functions/getScanButtonMode
 FUNCTION
 Returns the current scan button mode. See @setScanButtonMode for more detailed description.
 This setting is not persistent and is best to configure it upon connect.
 SYNTAX
 */
-(int)getScanButtonMode;
/*
 INPUTS
 RESULT
 scan button mode, one of the:
 * BUTTON_DISABLED - Linea's button will become inactive
 * BUTTON_ENABLED - Linea's button will triger barcode scan when pressed
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Functions/setScanButtonMode
 FUNCTION
 Sets Linea's scan button mode.
 This setting is not persistent and is best to configure it upon connect.
 SYNTAX
 */
-(void)setScanButtonMode:(int)mode;
/*
 INPUTS
 mode - button mode, one of the:
 * BUTTON_DISABLED - Linea's button will become inactive
 * BUTTON_ENABLED (default) - Linea's button will triger barcode scan when pressed
 RESULT
 NSPortTimeoutException if there is no connection to Linea 
 NSInvalidArgumentException if some of the input parameters are wrong
 *****/

/****f* Functions/getScanMode
 FUNCTION
 Returns the current scan mode.
 This setting is not persistent and is best to configure it upon connect.
 SYNTAX
 */
-(int)getScanMode;
/*
 INPUTS
 RESULT
 scanning mode, one of the:
 * MODE_SINGLE_SCAN - Linea will deactivate the laser after a successful barcode scan
 * MODE_MULTI_SCAN - Linea will continue to scan even after successful barcode scan and will stop \
 when scan button is released, stopScan command is sent or there is no barcode scaned for several \
 seconds (set via call to @setScanTimeout)
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Functions/setScanMode
 FUNCTION
 Sets Linea's scan mode.
 This setting is not persistent and is best to configure it upon connect.
 SYNTAX
 */
-(void)setScanMode:(int)mode;
/*
 INPUTS
 mode - scanning mode, one of the:
 * MODE_SINGLE_SCAN (default) - Linea will deactivate the laser after a successful barcode scan
 * MODE_MULTI_SCAN - Linea will continue to scan even after successful barcode scan and will stop \
 when scan button is released, stopScan command is sent or there is no barcode scaned for several \
 seconds (set via call to @setScanTimeout)
 RESULT
 NSPortTimeoutException if there is no connection to Linea 
 NSInvalidArgumentException if some of the input parameters are wrong
 *****/

/****f* Functions/enableBarcode
 FUNCTION
 Enables or disables reading of specific barcode type.
 This setting is stored into the flash memory and will persists.
 SYNTAX
 */
-(void)enableBarcode:(int)barcodeType enabled:(BOOL)enabled;
/*
 INPUTS
 barcodeType - barcode type, one of the BAR_* constants with the exception of BAR_LAST. You can use BAR_ALL to enable or disable all barcode types at once
 enabled - enables or disables reading of that barcode type
 RESULT
 NSPortTimeoutException if there is no connection to Linea 
 NSInvalidArgumentException if some of the input parameters are wrong
 *****/

/****f* Functions/setScanBeep
 FUNCTION
 Sets Linea's beep, which is used upon successful barcode scan
 This setting is not persistent and is best to configure it upon connect.
 SYNTAX
 */
-(void)setScanBeep:(BOOL)enabled volume:(int)volume beepData:(int *)data length:(int)length;
/*
 INPUTS
 enabled - turns on or off beeping
 volume - controls the volume (0-100). Currently have no effect
 beepData - an array of integer values specifying pairs of tone(Hz) and duration(ms).
 length - length in bytes of beepData array
 RESULT
 NSPortTimeoutException if there is no connection to Linea 
 NSInvalidArgumentException if some of the input parameters are wrong
 COMMENTS
 A sample beep containing of 2 tones, each with 400ms duration, first one 2000Hz and second - 5000Hz \
 will look int beepData[]={2000,400,5000,400}
 *****/

/****f* Functions/getBatteryCapacity
 FUNCTION
 Returns Linea's battery capacity in percent
 NOTE: Reading battery voltages during charging (both Linea charing and Linea charging the iPod) is unreliable!
 SYNTAX
 */
-(int)getBatteryCapacity;
/*
 INPUTS
 RESULT
 Battery capacity in percent
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Functions/getBatteryVoltage
 FUNCTION
 Returns Linea's battery voltage
 NOTE: Reading battery voltages during charging (both Linea charing and Linea charging the iPod) is unreliable!
 SYNTAX
 */
-(int)getBatteryVoltage;
/*
 INPUTS
 RESULT
 Battery voltage in Volt*10, i.e. value of 45 means 4.5V
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Functions/isBarcodeEnabled
 FUNCTION
 Returns if the the engine is set to read the barcode type or not.
 SYNTAX
 */
-(BOOL)isBarcodeEnabled:(int)type;
/*
 INPUTS
 type - barcode type, one of the BAR_* constants with the exception of BAR_ALL and BAR_LAST
 RESULT
 NSInvalidArgumentException if some of the input parameters are wrong
 *****/

/****f* Functions/isBarcodeSupported
 FUNCTION
 Returns if the the engine can read the barcode type or not.
 SYNTAX
 */
-(BOOL)isBarcodeSupported:(int)type;
/*
 INPUTS
 type - barcode type, one of the BAR_* constants with the exception of BAR_ALL and BAR_LAST
 RESULT
 NSInvalidArgumentException if some of the input parameters are wrong
 *****/

/****f* Functions/playSound
 FUNCTION
 Makes Linea plays a sound using the built-in speaker
 SYNTAX
 */
-(void)playSound:(int)volume beepData:(int *)data length:(int)length;
/*
 INPUTS
 volume - controls the volume (0-100). Currently have no effect
 beepData - an array of integer values specifying pairs of tone(Hz) and duration(ms).
 length - length in bytes of beepData array
 RESULT
 NSPortTimeoutException if there is no connection to Linea 
 NSInvalidArgumentException if some of the input parameters are wrong
 COMMENTS
 A sample beep containing of 2 tones, each with 400ms duration, first one 2000Hz and second - 5000Hz \
 will look int beepData[]={2000,400,5000,400}
 *****/


/****f* Functions/msStartScan
 FUNCTION
 Enables reading of magnetic cards. Whenever a card is successfully read, the @magneticCardData delegate will be called.
 Current magnetic card heads used in Linea 1.0, 1.5 and 2.0 consume so little power, that there is no drawback in leaving \
 scanning enabled all the time.
 SYNTAX
 */
-(void)msStartScan;
/*
 INPUTS
 RESULT
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Functions/msStopScan
 FUNCTION
 Disables magnetic card scanning started with @msStartScan
 SYNTAX
 */
-(void)msStopScan;
/*
 INPUTS
 RESULT
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Functions/getScanMode
 FUNCTION
 Returns the current magnetic card data mode.
 This setting is not persistent and is best to configure it upon connect.
 SYNTAX
 */
-(int)getMSCardDataMode;
/*
 INPUTS
 RESULT
 card data mode, one of the:
 * MS_PROCESSED_CARD_DATA - card data will be processed and will be returned via call to @magneticCardData
 * MS_RAW_CARD_DATA - card data will not be processed and will be returned via call to @magneticCardRawData
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Functions/setMSCardDataMode
 FUNCTION
 Sets Linea's magnetic card data mode. 
 This setting is not persistent and is best to configure it upon connect.
 SYNTAX
 */
-(void)setMSCardDataMode:(int)mode;
/*
 INPUTS
 mode - magnetic card data mode:
 * MS_PROCESSED_CARD_DATA (default) - card data will be processed and will be returned via call to @magneticCardData
 * MS_RAW_CARD_DATA - card data will not be processed and will be returned via call to @magneticCardRawData
 RESULT
 NSPortTimeoutException if there is no connection to Linea 
 NSInvalidArgumentException if some of the input parameters are wrong
 *****/

/****f* Functions/getCharging
 FUNCTION
 Returns if Linea is charging the iOS device from it's own battery. Linea firmware versions prior to 2.13 will return true \
 if external charge is attached, 2.13 and later will return only if Linea's own battery is used for charging
 SYNTAX
 */
-(BOOL)getCharging;
/*
 INPUTS
 RESULT
 Returns true if charging is enabled.
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Functions/setCharging
 FUNCTION
 Enables or disables Lines's capability to charge the handheld from it's own battery. Charging can stop if Linea's battery goes too low. \
 When enabling or disabling the charge linea will force disconnect and reconnect.
 
 While Linea can act as external battery for the iPod, there are certain limitations if you decide to implement it. The internal battery is \
 not big enough, so if the iPod consumes a lot of power from it, it will go down very fast and force the firmware to cut the charge to prevent \
 going down to dangerous levels. The proper use of this charging function depends on how the program, running on the iPod, is used and how the \
 iPod is discharged
 
 There are two possible ways to use Linea's charge:
 1. Emergency mode - in the case iPod usage is designed in a way it will last long enough between charging sessions and using Linea's charge \
 is not generally needed, the charge can be used if the iPod for some reason goes too low (like <30%), so it is given some power to continue \
 working until next charging. An example will be store, where devices are being charged every night, but extreme usage on some iPod drains \
 the battery before the end of the shift.
 The problem with this way, is that the charging will not be efficient - when the iPod is low on battery, it consumes very high amounts, \
 so our battery's voltage drops very fast and we are forced to turn off the charge, even if we technically have lot of battery left.

 2. Max life mode - it is the case where both devices are required to operate as long as possible. Usually, the iPod's battery will be drained \
 way faster than Linea's, especially with wifi enabled programs and to keep both devices operating as long as possible, the charging should \
 be desinged in a way so iPod is able to use most of our battery. This is possible, if you start charging when iPod is almost full - at around \
 75-80% and cut it when it is full. This way the iPod will consume small amount of energy, allowing our battery to slowly be used almost \
 fully to charge it.
 In some cases, restrictions should be applied to this charging mode if you want to leave more battery in Linea - reading battery is unreliable \
 during charging, so it is better to decide before you start the charging, for example not start charging if Linea is below 40%.
 
 LineaDemo application contains sample implementation of max life mode charging.
 
 NOTE: Reading battery voltages during charging is unreliable!
 
 SYNTAX
 */
-(BOOL)setCharging:(BOOL)enabled;
/*
 INPUTS
 enabled - only TRUE is the supported option at the moment
 RESULT
 Returns true if operation succeeded. Enabling charge can fail if Linea's battery is low. Disabling charge will fail if there is external \
 charger or usb cable attached.
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Functions/getFirmwareFileInformation
 FUNCTION
 Returns information about the specified firmware file. Based on it, and the connected Linea's name, model and firmware version \
 you can chose to update or not the Linea's firmware
 SYNTAX
 */
-(void)getFirmwareFileInformation:(NSString *)path firmwareInfo:(struct firmwareInfo *)info;
/*
 INPUTS
 path - the full path and file name where the firmware file is located
 firmwareInfo - pointer to a structure, that will be filled with firmware file information - name, model and firmware version
 NSInvalidArgumentException if the firmware file is missing, can't be opened, damaged or contains invalid firmware version
 *****/

/****f* Functions/updateFirmware
 FUNCTION
 Updates Linea's firmware with specified firmware file. The firmware can only be upgraded or downgraded, if you send \
 the same firmware version, then no update process will be started.
 SYNTAX
 */
-(void)updateFirmware:(NSString *)path;
/*
 INPUTS
 path - the full path and file name where the firmware file is located
 NSPortTimeoutException if there is no connection to Linea or firmware update have failed
 NSInvalidArgumentException if the firmware file is missing, can't be opened, damaged or contains invalid firmware version
 COMMENTS
 Make sure the user does not interrupt the process or the device will be rendered unusable and can only be recovered via \
 the special firmware update cable
 *****/

/****f* Functions/getSyncButtonMode
 FUNCTION
 Returns the current sync button mode. See @setSyncButtonMode for more detailed description.
 This setting is stored into flash memory and will persists.
 SYNTAX
 */
-(int)getSyncButtonMode;
/*
 INPUTS
 RESULT
 sync button mode, one of the:
 * BUTTON_DISABLED - Linea's will not perform synchronization when you press and hold the button for 3 seconds
 * BUTTON_ENABLED - Linea's will perform synchronization when you press and hold the button for 3 seconds
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Functions/setSyncButtonMode
 FUNCTION
 Sets Linea's sync button mode.
 This setting is stored into flash memory and will persists.
 SYNTAX
 */
-(void)setSyncButtonMode:(int)mode;
/*
 INPUTS
 mode - button mode, one of the:
 * BUTTON_DISABLED - Linea's will not perform synchronization when you press and hold the button for 3 seconds
 * BUTTON_ENABLED (default) - Linea's will perform synchronization when you press and hold the button for 3 seconds
 RESULT
 NSPortTimeoutException if there is no connection to Linea 
 NSInvalidArgumentException if some of the input parameters are wrong
 *****/

/****f* Functions/msProcessFinancialCard
 FUNCTION
 Helper function to parse financial card and extract the data - name, number, expiration date.
 The function will extract as much information as possible, fields not found will be set to NULL/0.
 SYNTAX
 */
-(BOOL)msProcessFinancialCard:(financialCard *)data track1:(NSString *)track1 track2:(NSString *)track2;
/*
 INPUTS
 data - pointer to financialCard structure, where the extracted data will be stored
 track1 - track1 information or NULL
 track1 - track2 information or NULL
 RESULT
 TRUE if the card tracks represent valid financial card and data was extracted.
 NSInvalidArgumentException if some of the input parameters are wrong
 *****/

/****f* Functions/getBarcodeTypeMode
 FUNCTION
 Returns the current barcode type mode. See setBarcodeTypeMode for more detailed description.
 This setting will not persists.
 SYNTAX
 */
-(int)getBarcodeTypeMode;
/*
 INPUTS
 RESULT
 barcode type mode, one of the:
 * BARCODE_TYPE_DEFAULT - default barcode types, listed in BARCODES enumeration
 * BARCODE_TYPE_EXTENDED - extended barcode types, listed in BARCODES_EX enumeration
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Functions/setBarcodeTypeMode
 FUNCTION
 Sets barcode type mode. Linea can return barcode type from the default list (listed in BARCODES) \
 or extended one (listed in BARCODES_EX). The extended one is superset to the default, so current \
 programs will be mostly unaffected if they switch from default to extended (with the exception of \
 barcodes like UPC-A and UPC-E, which will be returned as UPC in the default list, but proper types \
 in the extended.
 This setting will not persists.
 SYNTAX
 */
-(BOOL)setBarcodeTypeMode:(int)mode;
/*
 INPUTS
 RESULT
 barcode type mode, one of the:
 * BARCODE_TYPE_DEFAULT (default) - default barcode types, listed in BARCODES enumeration
 * BARCODE_TYPE_EXTENDED - extended barcode types, listed in BARCODES_EX enumeration
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Security/cryptoRawGenerateRandomData
 FUNCTION
 Generates 16 byte block of random numbers
 SYNTAX
 */
-(NSData *)cryptoRawGenerateRandomData;
/*
 INPUTS
 RESULT
 16 bytes of random numbers
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Security/cryptoRawSetKey
 FUNCTION
 Note: RAW crypto functions are harder to use and require more code, but are created to allow no secret keys \
 to reside on the device, but all the operations can be execuded with data, sent from a secure server. See \
 @cryptoSetKey if you plan to use the key in the mobile device.
 
 Used to store AES256 keys into Linea internal memory. Valid keys that can be set:
 KEY_AUTHENTICATION - if set, you can use authentication functions - @cryptoRawAuthenticateLinea \
 or @cryptoAuthenticateLinea. Firmware updates will require authentication too
 KEY_ENCRYPTION - if set, magnetic card data will come encrypted via @magneticCardEncryptedData or \
 @magneticCardEncryptedRawData

 Generally the key loading process, using "Raw" commands, a program on the iOS device and a server which holds the keys \
 will look similar to:
 
 - (iOS program) calls @cryptoRawGenerateRandomData to get 16 bytes block of random data and send these to the server 
 - (Server) creates byte array of 48 bytes consisting of: [RANDOM DATA: 16 bytes][KEY DATA: 32 bytes] 
 - (Server) if there is current encryption key set on the Linea (if you want to change existing key) the server encrypts \
 the 48 bytes block with the OLD key 
 - (Server) sends the result data back to the program 
 - (iOS program) calls @cryptoRawSetKey with KEY_ENCRYPTION and the data it received from the server
 - (Linea) tries to decrypt the key data if there was already key present, then extracts the key, verifies the random data \
 and if everything is okay, sets the key 
 
 SYNTAX
 */
-(void)cryptoRawSetKey:(int)keyID encryptedData:(NSData *)encryptedData;
/*
 INPUTS
 encryptedData - 48 bytes that consists of 16 bytes random numbers received via call to @cryptoRawGenerateRandomData \
 and 32 byte AES256 key. If there has been previous key of the same type, then all 48 bytes should be encrypted \
 with it.
 RESULT
 NSPortTimeoutException if there is no connection to Linea
 NSInvalidArgumentException if old key is invalid
 *****/

/****f* Security/cryptoSetKey
 FUNCTION
 Used to store AES256 keys into Linea internal memory. Valid keys that can be set:
 KEY_AUTHENTICATION - if set, you can use authentication functions - @cryptoRawAuthenticateLinea \
 or @cryptoAuthenticateLinea. Firmware updates will require authentication too
 KEY_ENCRYPTION - if set, magnetic card data will come encrypted via @magneticCardEncryptedData or \
 @magneticCardEncryptedRawData
 SYNTAX
 */
-(void)cryptoSetKey:(int)keyID key:(NSData *)key oldKey:(NSData *)oldKey;
/*
 INPUTS
 key - 32 bytes AES256 key to set
 oldKey - 32 bytes AES256 key that was previously used, or null if there was no previous key. The old key \
 should match the new key, i.e. if you are setting KEY_ENCRYPTION, then you should pass the old KEY_ENCRYPTION.
 RESULT
 NSPortTimeoutException if there is no connection to Linea
 NSInvalidArgumentException if old key is invalid
 *****/

/****f* Security/cryptoRawAuthenticateLinea
 FUNCTION
 Note: RAW crypto functions are harder to use and require more code, but are created to allow no secret keys \
 to reside on the device, but all the operations can be execuded with data, sent from a secure server. See \
 @cryptoAuthenticateLinea if you plan to use the key in the mobile device.
 
 Encrypts a 16 bytes block of random data with the stored authentication key and returns the result.
 The idea: if a program wants to work with specific Linea device, it sets AES256 authentication key once, then \
 on every connect the program generates random 16 byte block of data, encrypts it internally with the said key, \
 then encrypts it with linea too and compares the result. If that Linea contains no key, or \
 the key is different, the resulting data will totally differ from the one generated.
 This does not block Linea from operation, what action will be taken if devices mismatch depends on the program.
 SYNTAX
 */
-(NSData *)cryptoRawAuthenticateLinea:(NSData *)randomData;
/*
 INPUTS
 data - 16 bytes block of data (presumably random bytes)
 RESULT
 Random data, encrypted with the Linea authentication key
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Security/cryptoAuthenticateLinea
 FUNCTION
 Note: Check out the @cryptoRawAuthenticateLinea function, if you want to not use the key inside the mobile device.
 
 Generates random data, uses the key to encrypt it, then encrypts the same data with the stored authentication key \
 inside Linea and returns true if both data matches.
 Encrypts a 16 bytes block of random data with the stored authentication key and returns the result.
 The idea: if a program wants to work with specific Linea device, it sets AES256 authentication key once, then \
 on every connect the program uses @cryptoAuthenticateLinea with that key. If Linea contains no key, or \
 the key is different, the function will return FALSE.
 This does not block Linea from operation, what action will be taken if devices mismatch depends on the program.
 SYNTAX
 */
-(BOOL)cryptoAuthenticateLinea:(NSData *)key;
/*
 INPUTS
 data - 32 bytes AES256 key
 RESULT
 TRUE if Linea contains the same authentication key
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Security/cryptoRawAuthenticateiPod
 FUNCTION
 Note: RAW crypto functions are harder to use and require more code, but are created to allow no secret keys \
 to reside on the device, but all the operations can be execuded with data, sent from a secure server. See \
 @cryptoAuthenticateiPod if you plan to use the key in the mobile device.
 
 Tries to decrypt random data, generated from @cryptoRawGenerateRandomData with the stored internal authentication \
 key and returns the result. This function is used so that Linea knows a "real" device is currently connected, before \
 allowing some functionality. Currently firmware update is protected by this function, once authentication key is set, \
 you have to use it or @cryptoAuthenticateiPod before you attempt firmware update, or it will error out.
 The idea (considering the iOS device does not have the keys inside, but depends on server):
 - (iOS program) generates random data using @cryptoRawGenerateRandomData and sends to the server
 - (Server) encrypts the random data with the same AES256 key that is in the Linea and sends back to the iOS program
 - (iOS program) uses cryptoRawAuthenticateiPod to authenticate with the data, an exception will be generated if authentication fails.
 SYNTAX
 */
-(void)cryptoRawAuthenticateiPod:(NSData *)encryptedRandomData;
/*
 INPUTS
 data - 16 bytes block of encrypted data
 RESULT
 NSInvalidArgumentException if Linea was not able to decrypt the data (wrong key/wrong random bytes)
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Security/cryptoAuthenticateiPod
 FUNCTION
 Note: Check out the cryptoRawAuthenticateiPod function, if you want to not use the key inside the mobile device.
 
 Generates random data, uses the key to encrypt it, then sends to Linea to verify against it's internal authentication \
 key. If both keys match, return value is TRUE. This function is used so that Linea knows a "real" device is currently connected, before \
 allowing some functionality. Currently firmware update is protected by this function, once authentication key is set, \
 you have to use it or @cryptoRawAuthenticateiPod before you attempt firmware update, or it will error out.
 SYNTAX
 */
-(BOOL)cryptoAuthenticateiPod:(NSData *)key;
/*
 INPUTS
 data - 32 bytes AES256 key
 RESULT
 TRUE if Linea contains the same authentication key
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Barcode Engine/barcodeEngineWrite
 FUNCTION
 Sends data directly to the barcode engine. Use this function with EXTREME care, you can easily render \
 your barcode engine useless.
 Refer to the barcode engine documentation on supported commands
 SYNTAX
 */
-(BOOL)barcodeEngineWrite:(void *)data length:(int)length;
/*
 INPUTS
 data - command buffer
 length - the number of bytes in data buffer
 RESULT
 TRUE if write operation succeeded
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Barcode Engine/barcodeEngineWrite
 FUNCTION
 Sends data directly to the barcode engine. Use this function with EXTREME care, you can easily render \
 your barcode engine useless.
 Refer to the barcode engine documentation on supported commands
 SYNTAX
 */
-(BOOL)barcodeEngineWrite:(NSString *)data;
/*
 INPUTS
 data - command string
 RESULT
 TRUE if write operation succeeded
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Barcode Engine/barcodeEngineRead
 FUNCTION
 Reads a response from the barcode engine.
 Refer to the barcode engine documentation on supported commands
 SYNTAX
 */
-(int)barcodeEngineRead:(void *)data length:(int)length timeout:(double)timeout;
/*
 INPUTS
 data - buffer, where the response will be stored
 length - the maximum number of bytes to store in length buffer
 timeout - the number of seconds to wait for response
 RESULT
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Barcode Engine/barcodeEnginePowerControl
 FUNCTION
 Allows basic control over the power to the barcode engine. By default Linea manages barcode engine by turning \
 it on when scan operation is needed, then turning off after 5 seconds of inactivity. There are situations, where \
 barcode engine should stay on to give better user experience, namely when using 2D barcode engine, which takes 1.7 seconds \
 to start. This function is ignored for 1D barcode engines.
 Be cautious using this function, if you pass TRUE to engineOn, the barcode engine will not turn off unless Linea is disconnected, \
 program closes connection or iPod/iPhone goes to sleep, so it can drain the battery if left for 10+ hours on.
 This setting does not persist, it is valid for current session only.
 SYNTAX
 */
-(void)barcodeEnginePowerControl:(BOOL)engineOn;
/*
 INPUTS
 engineOn - TRUE will keep the engine powered on until the function is called with FALSE. In case of FALSE, Linea will work the usual way - \
 powers on the engine just before scan operation. 
 RESULT
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/****f* Barcode Engine/barcodeOpticonSetParams
 FUNCTION
 Sends configuration parameters directly to the opticon barcode engine. Use this function with EXTREME care, \
 you can easily render your barcode engine useless.
 Refer to the barcode engine documentation on supported commands.
 The function encapsulates the data with the ESC and CR so you don't have to send them. It also sends Z2 \
 after the command to ensure settings are stored in the flash.
 You can send multiple parameters with a single call if you format them as follows:
 - commands that take 2 symbols can be sent without any delimiters, like: "C1C2C3"
 - commands that take 3 symbols should be prefixed by [, like: "C1[C2AC3" (in this case commands are C1, C2A and C3
 - commands that take 4 symbols should be prefixed by ], like: "C1C2]C3AB" (in this case commands are C1, C2 and C3AB
 SYNTAX
 */
-(BOOL)barcodeOpticonSetParams:(NSString *)data;
/*
 INPUTS
 data - command buffer
 length - the number of bytes in data buffer
 RESULT
 TRUE if write operation succeeded
 NSPortTimeoutException if there is no connection to Linea 
 *****/

/*
 BLUETOOTH/PRINTER SUPPORT IS STILL EXPERIMENTAL. CURRENT FUNCTION NAMES AND BEHAVIOR WILL MOST PROBABLY STAY, MORE WILL BE ADDED
 AND SOME FUNCTIONS HAVE KNOWN PROBLEMS
 */
-(void)btmClearReceive;
-(int)btmGetEnabled;
-(void)btmSetEnabled:(BOOL)enabled;
-(BOOL)btmWrite:(void *)data length:(int)length;
-(BOOL)btmWrite:(NSString *)data;
-(int)btmRead:(void *)data length:(int)length timeout:(double)timeout;
-(NSString *)btmReadLine:(double)timeout;
-(NSString *)btmGetLocalName;

-(NSArray *)btDiscoverDevices:(int)maxDevices maxTime:(double)maxTime codTypes:(int)codTypes;
-(NSString *)btGetDeviceName:(NSString *)address;
-(BOOL)btConnect:(NSString *)address pin:(NSString *)pin;

-(NSArray *)prnDiscoverPrinters:(double)maxTime;
-(NSArray *)prnDiscoverPrinters:(int)maxDevices maxTime:(double)maxTime;
-(BOOL)prnConnect:(NSString *)address pin:(NSString *)pin;
-(void)prnDisconnect;
-(void)prnFlushCache;

-(BOOL)prnWrite:(uint8_t *)data channel:(int)channel length:(int)length timeout:(double)timeout;
-(int)prnRead:(uint8_t *)data channel:(int)channel length:(int)length timeout:(double)timeout stop:(int)stop;


-(void)prnLogo;
-(void)prnText:(NSString *)textString;	
-(void)prnLineFeed;
-(void)prnLineFeed:(int)lines;
-(void)prnFeedPaper;
-(void)prnLineSpace:(int)lineSpace;
-(void)prnImage:(UIImage *)image align:(int)align;
/*
 BLUETOOTH/PRINTER SUPPORT IS STILL EXPERIMENTAL
 */

@property(assign) id delegate;
@property(readonly) int connstate;

@property(readonly) NSString *deviceName;
@property(readonly) NSString *deviceModel;
@property(readonly) NSString *firmwareRevision;
@property(readonly) NSString *hardwareRevision;
@property(readonly) NSString *serialNumber;

//SDK version number in format MAJOR*100+MINOR, i.e. version 1.15 will be returned as 115
@property(readonly) int sdkVersion;
@end

