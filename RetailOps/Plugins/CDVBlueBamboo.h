//
//  CDVBlueBamboo.h
//
//  Created by Nathan Bruer.
//  Copyright (c) 2012 Allada Inc. All rights reserved.
//
#define fileCDVBlueBamboo true
#ifndef LOG
	#define LOG(s, ...) NSLog(@"<%s : (%d)> %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#endif
#import <Cordova/CDVPlugin.h>
#import <ExternalAccessory/ExternalAccessory.h>
#import "BlueBambooPrinterObject.h"

#ifndef fileBlueBambooPrinterDelegate
    #import "BlueBambooPrinterDelegate.h"
#endif

@interface CDVBlueBamboo : CDVPlugin <BlueBambooPrinterDelegate>{
}
extern NSString * const BlueBambooProtocolString;

@property (retain) NSString* callbackId;
@property (retain) NSMutableDictionary* printers;
- (void) printImage:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void) printText:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void) sendRawData:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void) sendEvent: (BlueBambooPrinterObject *) printerObject: (NSString *) event: (NSArray *) args;
@end
