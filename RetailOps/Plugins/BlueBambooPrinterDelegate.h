//
//  BlueBambooPrinterDelegate.h
//  Starin
//
//  Created by Nathan Bruer on 11/20/12.
//  Copyright (c) 2012 Starin Marketing Inc. All rights reserved.
//
#define fileBlueBambooPrinterDelegate true
#import <Foundation/Foundation.h>
#ifndef fileBlueBambooPrinterObject
    #import "BlueBambooPrinterObject.h"
#endif
@class BlueBambooPrinterObject;
@protocol BlueBambooPrinterDelegate <NSObject>
@required
- (void) sendEvent: (BlueBambooPrinterObject *) printerObject: (NSString *) event: (NSArray *) args;
@end