//  BlueBambooPrinterObject.h
//  Starin
//
//  Created by Nathan Bruer on 11/20/12.
//  Copyright (c) 2012 Starin Marketing Inc. All rights reserved.
//
#define fileBlueBambooPrinterObject true
#ifndef LOG
	#define LOG(s, ...) NSLog(@"<%s : (%d)> %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#endif
#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>
#import "CDVBlueBamboo.h"
#ifndef fileBlueBambooPrinterDelegate
    #import "BlueBambooPrinterDelegate.h"
#endif

@interface BlueBambooPrinterObject : NSObject <NSStreamDelegate>
extern int const CleanBufferSize;
@property (assign) EAAccessory *BlueBambooAccessory;
@property (assign) EASession *BlueBambooSession;
@property (readonly) int bufferSize;
@property (readonly) int bufferNumChunks;
@property (retain) NSString *eventDispatcherId;

- (BlueBambooPrinterObject *) init: (EAAccessory *) accessory: (id <BlueBambooPrinterDelegate>) delegate;

- (int) cleanBuffer;
- (void) printerConnected: (EAAccessory *) accessory;
- (void) printerDisconnected;
- (int) printImage: (UIImage *) img;
- (int) printText: (NSString *) text;
- (int) printRawData: (NSString *) text;
@end