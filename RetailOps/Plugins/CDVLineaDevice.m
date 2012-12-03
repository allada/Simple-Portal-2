//
//  CDVLineaDevice.m
//  RetailOps
//
//  Created by Nathan Bruer.
//  Copyright (c) 2012 Starin Marketing Inc. All rights reserved.
//

#import "CDVLineaDevice.h"

@implementation CDVLineaDevice
@synthesize callbackId;

- (CDVPlugin*) initWithWebView:(UIWebView*)theWebView {
    NSLog(@"initing Linea Device Plugin");
    self = [super initWithWebView:theWebView];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(disconnectLinea:)
        name:UIApplicationWillResignActiveNotification
        object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(connectLinea:)
     name:UIApplicationDidBecomeActiveNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(disconnectLinea:)
     name:UIApplicationWillTerminateNotification
     object:nil];
    [self connectLinea: nil];
    return self;
}

- (void) connectLinea:(NSNotification *)notification {
    NSLog(@"Connecting to linea device");
    if(linea == nil)
        linea = [Linea sharedDevice];
	[linea addDelegate:self];
	[linea connect];
}
- (void) disconnectLinea:(NSNotification *)notification {
    NSLog(@"Disconnecting from linea device");
    [linea disconnect];
    [linea removeDelegate:self];
}

// End Functions extended over from ViewController
/**
 * Definer micros to save code space on argument checking.
 */
#ifndef BEGIN_ARGCHECKWRAPPER
#define BEGIN_ARGCHECKWRAPPER(required_args, lineaConnectedCheck) \
    int i; \
    NSString* localCallbackId = [arguments objectAtIndex:0]; \
    CDVPluginResult* pluginResult = nil; \
    NSString* javaScript = nil; \
    NSMutableArray *returnArgs = [[NSMutableArray alloc] init]; \
    @try { \
        if (lineaConnectedCheck && [linea connstate] != CONN_CONNECTED) { \
            [NSException raise:@"NoDevice" format:@"Linea Device is currently not connected"]; \
        } \
        if([arguments count] < required_args) { \
            [NSException raise:@"InvalidArgument" format:@"Function requires %i arguments and %i arguments passed",required_args, [arguments count]]; \
        } \
        for (i=0;i<required_args;i++) { \
            if([arguments objectAtIndex: i+1] == nil) { \
                [NSException raise:@"InvalidArgument" format:@"Argument %i cannot be null",i]; \
            } \
        }
#define END_ARGCHECKWRAPPER \
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:returnArgs]; \
        javaScript = [pluginResult toSuccessCallbackString:localCallbackId]; \
    } @catch (id exception){ \
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_JSON_EXCEPTION messageAsString:[exception reason]]; \
        javaScript = [pluginResult toErrorCallbackString:localCallbackId]; \
    } \
    [returnArgs release]; \
    [self writeJavascript:[NSString stringWithFormat:@"window.setTimeout(function(){%@;},0);", javaScript]];
#define IF_NULLOBJ(item) item ? item : [NSNull null]

#endif
// Begin callable functions from javascript
/*
 * The following functions are called from the plugin handler of PhoneGap. These functions pass *arguments from the javascript and any options along with it.
 * *arguments is an array of all arguments the javascript function passed. arguments[0] is always the localCallbackId and all subsiquent items is the actual data.
 */
- (void) configureAllSettings:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(0, true)
    NSLog(@"Configuring");
    int i=0;
    if(options){
        if([options objectForKey:@"SCAN_BEEP"] && [options objectForKey:@"SCAN_BEEP_ENABLED"]){
            NSArray *sounds = [options objectForKey:@"SCAN_BEEP"];
            int count = [sounds count];
            int *newAry = malloc(sizeof(int) * count);
            for(;i<count;i++){
                newAry[i] = [[sounds objectAtIndex:i] intValue];
            }
            [linea setScanBeep:(bool) [[options objectForKey:@"SCAN_BEEP_ENABLED"] boolValue] volume:100 beepData:newAry length:sizeof(int) * count];
            free(newAry);
        }

        if([options objectForKey:@"SCAN_MODE"]){
            [linea setScanMode:[[options objectForKey:@"SCAN_MODE"] intValue]];
        }
        if([options objectForKey:@"BUTTON_ENABLED"]){
            [linea setScanButtonMode:[[options objectForKey:@"BUTTON_ENABLED"] intValue]];
        }
        if([options objectForKey:@"MS_MODE"]){
            [linea setMSCardDataMode:[[options objectForKey:@"MS_MODE"] intValue]];
        }
        if([options objectForKey:@"BARCODE_TYPE"]){
            [linea setBarcodeTypeMode:[[options objectForKey:@"BARCODE_TYPE"] intValue]];
        }
        if([options objectForKey:@"BARCODE_ENGINE_POWER"]){
            [linea barcodeEnginePowerControl:[[options objectForKey:@"BARCODE_ENGINE_POWER"] boolValue]];
        }
        if([options objectForKey:@"CHARGING"]){
            [linea setCharging:[[options objectForKey:@"CHARGING"] boolValue]];
        }

        if([options objectForKey:@"barcodeStatus"]){
            NSDictionary *barcodesEnabled = [options objectForKey:@"barcodeStatus"];
            int lastI;
            if([linea getBarcodeTypeMode] == BARCODE_TYPE_EXTENDED){
                lastI = BAR_EX_LAST;
            }else{
                lastI = BAR_LAST;
            }

            for(i = 0;i<lastI;i++){
                if([linea isBarcodeSupported:i] && [barcodesEnabled objectForKey:[NSString stringWithFormat:@"%i", i]] != nil){
                    [linea enableBarcode:i enabled:[[barcodesEnabled objectForKey:[NSString stringWithFormat:@"%i", i]] boolValue]];
                }
            }
        }
    }
    END_ARGCHECKWRAPPER
}
/**
 * Enables a specific barcode.
 * @arguments[1] int        Barcode Type
 * @arguments[2] boolean    Enabled or not
 */
- (void) enableBarcode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(2, true)
    NSLog(@"%i %i", [[arguments objectAtIndex: 1] intValue], [[arguments objectAtIndex: 2] intValue]);
    [linea enableBarcode:[[arguments objectAtIndex: 1] intValue] enabled:[[arguments objectAtIndex: 2] boolValue]];
    END_ARGCHECKWRAPPER
}
/**
 * Plays a sound.
 * @arguments[1] int        Volume (Currently the Linea Device does not support this)
 * @arguments[2] array      Array of frequentcy and durations. [freqency,duration,frequency,duration, ...]
 */
- (void) playSound:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(2, true)
    NSArray *sounds = [arguments objectAtIndex:2];
    int count = [sounds count];
    int *newAry = malloc(sizeof(int) * count);
    int i=0;
    for(;i<(count > 10 ? 10 : count);i++){
        newAry[i] = [[sounds objectAtIndex:i] intValue];
    }
    [linea playSound:(int) [[arguments objectAtIndex:1] intValue] beepData:newAry length:sizeof(int) * (count > 10 ? 10 : count)];
    free(newAry);
    if(count > 10){
        [NSException raise:@"InvalidArgument" format:@"You may only send 5 sounds though this function at a time, you tried to send %i. The remaining sounds where truncated.", count];
    }
    END_ARGCHECKWRAPPER
}
/**
 * Starts the lazer.
 */
- (void) startScan:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(0, true)
    NSLog(@"Started Scan");
    [linea startScan];
    END_ARGCHECKWRAPPER
}
/**
 * Stops the lazer.
 */
- (void) stopScan:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(0, true)
    NSLog(@"Stopped Scan");
    [linea stopScan];
    END_ARGCHECKWRAPPER
}
/**
 * Sets the timeout of the lazer if no barcode has been scanned.
 * @arguments[1] int        Seconds to wait.
 */
- (void) setScanTimeout:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(1, true)
    NSLog(@"Set Scanout Timeout");
    [linea setScanTimeout:(int) [[arguments objectAtIndex:1] intValue]];
    END_ARGCHECKWRAPPER
}
/**
 * Weather the scan engine should work in persistent scan mode or single scan mode.
 * @arguments[1] int        Integer value of MODE_SINGLE_SCAN or MODE_MULTI_SCAN
 */
- (void) setScanMode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(1, true)
    NSLog(@"Set Scan Mode");
    [linea setScanMode:(int) [[arguments objectAtIndex:1] intValue]];
    END_ARGCHECKWRAPPER
}
/**
 * Sets the beep sound when a barcode is scanned.
 * @arguments[1] boolean    Enabled or not.
 * @arguments[2] int        Volume (currently not supported by linea device)
 * @arguments[3] array      Array of frequentcy and durations. [freqency,duration,frequency,duration, ...]
 */
- (void) setScanBeep:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(3, true)
    NSLog(@"Set Scan Beep");
    NSArray *sounds = [arguments objectAtIndex:3];
    int count = [sounds count];
    int *newAry = malloc(sizeof(int) * count);
    int i=0;
    for(;i<count;i++){
        newAry[i] = [[sounds objectAtIndex:i] intValue];
    }
    [linea setScanBeep:(bool) [[arguments objectAtIndex:1] boolValue] volume:(int) [[arguments objectAtIndex:2] intValue] beepData:newAry length:sizeof(int) * count];
    free(newAry);
    END_ARGCHECKWRAPPER
}
/**
 * Enables the button for scanning or not
 * @arguments[1] int        Int value of BUTTON_DISABLED or BUTTON_ENABLED
 */
- (void) setScanButtonMode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(1, true)
    NSLog(@"Set Scan Button Mode");
    [linea setScanButtonMode:(int) [[arguments objectAtIndex:1] intValue]];
    END_ARGCHECKWRAPPER
}
/**
 * Sets how to read the card.
 * @arguments[1] int    Int value for MS_PROCESSED_CARD_DATA or MS_RAW_CARD_DATA
 */
- (void) setMSCardDataMode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSLog(@"Set MS Card Data Mode");
    BEGIN_ARGCHECKWRAPPER(1, true)
    [linea setMSCardDataMode:(int) [[arguments objectAtIndex:1] intValue]];
    END_ARGCHECKWRAPPER
}
/**
 * Sets weather to read barcode as extended barcode types
 * @arguments[1] int    Int value for BARCODE_TYPE_DEFAULT or BARCODE_TYPE_EXTENDED
 */
- (void) setBarcodeTypeMode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(1, true)
    NSLog(@"Set Barcode Type Mode");
    [linea setBarcodeTypeMode:(int) [[arguments objectAtIndex:1] intValue]];
    END_ARGCHECKWRAPPER
}
/**
 * Gets current scan button mode
 */
- (void) getScanButtonMode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(0, true)
    [returnArgs addObject:[NSNumber numberWithInt:[linea getScanButtonMode]]];
    END_ARGCHECKWRAPPER
}
/**
 * Gets current scan mode
 */
- (void) getScanMode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(0, true)
    [returnArgs addObject:[NSNumber numberWithInt:[linea getScanMode]]];
    END_ARGCHECKWRAPPER
}
/**
 * Gets Battery Capacity in percent
 */
- (void) getBatteryCapacity:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(0, true)
    [returnArgs addObject:[NSNumber numberWithInt:[linea getBatteryCapacity]]];
    END_ARGCHECKWRAPPER
}
/**
 * Gets Battery Voltage
 */
- (void) getBatteryVoltage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(0, true)
    [returnArgs addObject:[NSNumber numberWithInt:[linea getBatteryVoltage]]];
    END_ARGCHECKWRAPPER
}
/**
 * Check if Barcode is Enabled
 */
- (void) isBarcodeEnabled:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(1, true)
    [returnArgs addObject:[NSNumber numberWithBool:[linea isBarcodeEnabled:[[arguments objectAtIndex:1] intValue]]]];
    END_ARGCHECKWRAPPER
}
/**
 * Check if Barcode is Supported
 */
- (void) isBarcodeSupported:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(1, true)
    [returnArgs addObject:[NSNumber numberWithBool:[linea isBarcodeSupported:[[arguments objectAtIndex:1] intValue]]]];
    END_ARGCHECKWRAPPER
}
/**
 * Get MS Card Mode
 */
- (void) getMSCardDataMode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(0, true)
    [returnArgs addObject:[NSNumber numberWithInt:[linea getMSCardDataMode]]];
    END_ARGCHECKWRAPPER
}
/**
 * Get Charging
 */
- (void) getCharging:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(0, true)
    [returnArgs addObject:[NSNumber numberWithBool:[linea getCharging]]];
    END_ARGCHECKWRAPPER
}
/**
 * Set Charging
 */
- (void) setCharging:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(1, true)
    NSLog(@"Set Charge Mode");
    [linea setCharging:[[arguments objectAtIndex:1] boolValue]];
    END_ARGCHECKWRAPPER
}
/**
 * Get Sync Button Mode
 */
- (void) getSyncButtonMode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(0, true)
    [returnArgs addObject:[NSNumber numberWithInt:[linea getSyncButtonMode]]];
    END_ARGCHECKWRAPPER
}
/**
 * Get Financial Info From Credit Card
 */
- (void) msProcessFinancialCard:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(2, true)
    financialCard *data;
    NSString *track1 = [arguments objectAtIndex:1];
    NSString *track2 = [arguments objectAtIndex:2];
    [linea msProcessFinancialCard:data track1:track1 track2:track2];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          IF_NULLOBJ(data->accountNumber), @"accountNumber",
                          IF_NULLOBJ(data->cardholderName), @"cardholderName",
                          IF_NULLOBJ(data->discretionaryData), @"discretionaryData",
                          data->exirationMonth ? [NSNumber numberWithInt:data->exirationMonth] : [NSNull null], @"exirationMonth",
                          data->exirationYear ? [NSNumber numberWithInt:data->exirationYear] : [NSNull null], @"exirationYear",
                          IF_NULLOBJ(data->firstName), @"firstName",
                          IF_NULLOBJ(data->lastName), @"lastName",
                          IF_NULLOBJ(data->serviceCode), @"serviceCode",
                          nil
                          ];
    [returnArgs addObject:dict];
    END_ARGCHECKWRAPPER
}
/**
 * Get Barcode Type Mode
 */
- (void) getBarcodeTypeMode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(0, true)
    [returnArgs addObject:[NSNumber numberWithInt:[linea getBarcodeTypeMode]]];
    END_ARGCHECKWRAPPER
}
/**
 * Barcode engine Power Control
 */
- (void) barcodeEnginePowerControl:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(1, true)
    NSLog(@"Set Barcode Engine Control");
    bool engineOn = [[arguments objectAtIndex:1] boolValue];
    [linea barcodeEnginePowerControl:engineOn];
    END_ARGCHECKWRAPPER
}
- (void) getConnectionState:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(0, false)
    [returnArgs addObject:[NSNumber numberWithInt:lineaConnectionState]];
    END_ARGCHECKWRAPPER
}
/**
 * Barcode Type 2 Text
 */
- (void) barcodeType2Text:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(1, true)
    [returnArgs addObject:[linea barcodeType2Text:[[arguments objectAtIndex:1] intValue]]];
    END_ARGCHECKWRAPPER
}


// Non-device driven functions
/**
 * Sets which function will be used to monitor events from linea device.
 */
- (void) monitor:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    self.callbackId = [arguments objectAtIndex:0];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:nil];
    [pluginResult setKeepCallbackAsBool: true];
    NSString *javaScript = [pluginResult toSuccessCallbackString:self.callbackId];
    [self writeJavascript:javaScript];
}
/**
 * Unsets the function used to monitor events from the linea device.
 */
- (void) unmonitor:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BEGIN_ARGCHECKWRAPPER(0, true)
    self.callbackId = nil;
    END_ARGCHECKWRAPPER
}
// End callabale functions from javascript
#ifndef BEGIN_JSINJECTWARPPER
#define BEGIN_JSINJECTWARPPER \
    if(self.callbackId != nil){ \
        NSMutableArray *returnArgs = [[NSMutableArray alloc] init];
#define END_JSINJECTWRAPPER \
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:returnArgs]; \
        [result setKeepCallbackAsBool:true]; \
        [super writeJavascript:[result toSuccessCallbackString:self.callbackId]]; \
        [returnArgs release]; \
    }
#define NIL2EMPTYSTR(str) str == nil?@"":str
#endif
// Begin called functions from Linea Device
/**
 * Event fired when barcode is scanned
 * @returns [(string) 'barcodeData', (string) barcode, (int) barcodeType]
 */
- (void)barcodeData:(NSString *)barcode type:(int)type {
    BEGIN_JSINJECTWARPPER
    NSNumber *objType = [NSNumber numberWithInt:type]; // Convert to object because int is not an object and NSArray requires objects.
    [returnArgs addObject:@"barcodeData"];
    [returnArgs addObject:NIL2EMPTYSTR(barcode)];
    [returnArgs addObject:objType];
    END_JSINJECTWRAPPER
}
/**
 * Event fired when card is swipped.
 * @returns [(string) 'magenticCardData', (string) track1, (string) track2, (string) track3]
 */
- (void)magneticCardData:(NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3 {
    BEGIN_JSINJECTWARPPER
    [returnArgs addObject:@"magneticCardData"];
    [returnArgs addObject:NIL2EMPTYSTR(track1)];
    [returnArgs addObject:NIL2EMPTYSTR(track2)];
    [returnArgs addObject:NIL2EMPTYSTR(track3)];
    END_JSINJECTWRAPPER
}
/**
 * Event fired when card is swiped and raw mode is enabled.
 * @returns [(string) 'magneticCardRawData', (string) rawData]
 */
- (void)magneticCardRawData:(NSData *)tracks {
    BEGIN_JSINJECTWARPPER
    [returnArgs addObject:@"magneticCardRawData"];
    [returnArgs addObject:[NSString stringWithUTF8String:[tracks bytes]]];
    END_JSINJECTWRAPPER
}
/**
 * Event fired when button is pressed
 * @returns [(string) 'buttonPressed', (int) whichButton]
 */
- (void)buttonPressed:(int)which {
    NSLog(@"Button pressed");
    BEGIN_JSINJECTWARPPER
    NSNumber *objWhich = [NSNumber numberWithInt:which]; // Convert to object because int is not an object and NSArray requires objects.
    [returnArgs addObject:@"buttonPressed"];
    [returnArgs addObject:objWhich];
    END_JSINJECTWRAPPER
}
/**
 * Event fired when button is released
 * @returns [(string) 'buttonReleased', (int) whichButton]
 */
- (void)buttonReleased:(int)which {
    NSLog(@"Button Released");
    BEGIN_JSINJECTWARPPER
    NSNumber *objWhich = [NSNumber numberWithInt:which]; // Convert to object because int is not an object and NSArray requires objects.
    [returnArgs addObject:@"buttonReleased"];
    [returnArgs addObject:objWhich];
    END_JSINJECTWRAPPER
}
/**
 * Event fired when device connection state changed.
 * @returns [(string) 'buttonReleased', (int) state]
 */
-(void)connectionState:(int)state {
    NSLog(@"Status Changed: %i", state);
    lineaConnectionState = state;
    if (state == CONN_CONNECTED) {
        [linea msStartScan];
    }
    BEGIN_JSINJECTWARPPER
    NSNumber *objState = [NSNumber numberWithInt:state]; // Convert to object because int is not an object and NSArray requires objects.
    [returnArgs addObject:@"connectionState"];
    [returnArgs addObject:objState];
    END_JSINJECTWRAPPER
}
// End called functions from Linea Device
@end
