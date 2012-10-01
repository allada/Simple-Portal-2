//
//  CDVLineaDevice.h
//  RetailOps
//
//  Created by Nathan Bruer.
//  Copyright (c) 2012 Starin Marketing Inc. All rights reserved.
//
#import <Cordova/CDVPlugin.h>
#import <Foundation/NSNull.h>
#import "LineaSDK.h"
#import <ExternalAccessory/ExternalAccessory.h>
@interface CDVLineaDevice : CDVPlugin {
    Linea *linea;
    int lineaConnectionState;
}
@property (retain) NSString* callbackId;

- (void) connectLinea:(NSNotification *)notification;
- (void) disconnectLinea:(NSNotification *)notification;

// Start JS Callable Functions
- (void) enableBarcode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) playSound:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) startScan:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) stopScan:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setScanTimeout:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setScanMode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setScanBeep:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setScanButtonMode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setMSCardDataMode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setBarcodeTypeMode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
// End JS Callable Functions
@end
