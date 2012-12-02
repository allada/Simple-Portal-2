//
//  CDVBlueBamboo.m
//
//  Created by Nathan Bruer on 11/14/12.
//  Copyright (c) 2012 Allada Inc. All rights reserved.
//
// Cleans buffer after the buffer gets to this size. (default .5 meabyte)

#import "CDVBlueBamboo.h"

@implementation CDVBlueBamboo
@synthesize callbackId, printers;

NSString * const BlueBambooProtocolString = @"com.bluebamboo.p25i";

NSMutableArray *accessoryList;


- (CDVPlugin*) initWithWebView:(UIWebView*)theWebView {
    self.printers = [[NSMutableDictionary alloc] init];
    accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
    self = [super initWithWebView:theWebView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChange:) name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChange:) name:EAAccessoryDidDisconnectNotification object:nil];
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    return self;
}
/**
 * Finds printer accessories
 */
- (NSArray *) findPrinters{
    NSMutableArray *ary = [NSMutableArray array];
    EAAccessory *obj;
    BlueBambooPrinterObject *printObj;
    for(obj in accessoryList){
        if ([[obj protocolStrings] containsObject:BlueBambooProtocolString]){
            [ary addObject:[obj macAddress]];
            if(![self.printers objectForKey:[obj macAddress]]){
                printObj = [[BlueBambooPrinterObject alloc] init:obj:self];
                [self.printers setObject:printObj forKey:[obj macAddress]];
            }
        }
    }
    return ary;
}
- (void) connectionChange: (NSNotification *) notification{
    NSString *notificationName = [notification name];
    int i = 0;
    BlueBambooPrinterObject *printObj;
    EAAccessory *accessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    if([notificationName isEqualToString:@"EAAccessoryDidConnectNotification"]){
        // Device connected check to see if it's a printer
        [accessoryList addObject:accessory];
        NSArray *ary = [accessory protocolStrings];
        for(NSString *str in ary){
            if([str isEqualToString:BlueBambooProtocolString]){
                LOG(@"Printer Connected: %@", [accessory macAddress]);
                if((printObj = [self.printers objectForKey:[accessory macAddress]])){
                    // Notify instance that printer is back
                    [printObj printerConnected:accessory];
                }else{
                    printObj = [[BlueBambooPrinterObject alloc] init:accessory:self];
                    [self.printers setObject:printObj forKey:[accessory macAddress]];
                }
                [self sendEvent:printObj:@"PrinterConnected":nil];
                break;
            }
        }
    }else if([notificationName isEqualToString:@"EAAccessoryDidDisconnectNotification"]){
        for(EAAccessory *rmAccessory in accessoryList){
            if([rmAccessory connectionID] == [accessory connectionID]){
                break;
            }
            i++;
        }
        if(i < [accessoryList count]){
            [accessoryList removeObjectAtIndex:i];
        }
        NSArray *ary = [accessory protocolStrings];
        for(NSString *str in ary){
            if([str isEqualToString:BlueBambooProtocolString]){
                LOG(@"Printer Disconnected: %@", [accessory macAddress]);
                if((printObj = [self.printers objectForKey:[accessory macAddress]])){
                    [self sendEvent:printObj:@"PrinterDisconnected":nil];
                    [printObj printerDisconnected];
                }
            }
        }
    }
}

- (void) printImage:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options{
    NSString *localCallbackId = [arguments objectAtIndex:0];
    NSString *printerSN = [arguments objectAtIndex:1];
    NSString *javascript = nil;
    UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[arguments objectAtIndex:2]]]];
    NSMutableArray *returnArgs = [[NSMutableArray alloc] init];
    if(img){
        BlueBambooPrinterObject *printer;
        if((printer = [self.printers objectForKey:printerSN])){
            int printId = [printer printImage:img];
            if(!printId){
                [returnArgs addObject:@"No print id returned"];
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsArray:returnArgs];
                javascript = [pluginResult toErrorCallbackString:localCallbackId];
            }else{
                [returnArgs addObject:[NSNumber numberWithInt:printId]];
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:returnArgs];
                javascript = [pluginResult toSuccessCallbackString:localCallbackId];
            }
        }else{
            [returnArgs addObject:@"Printer not found or not initiated"];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsArray:returnArgs];
            javascript = [pluginResult toErrorCallbackString:localCallbackId];
        }
    }else{
        [returnArgs addObject:@"Invalid image"];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsArray:returnArgs];
        javascript = [pluginResult toErrorCallbackString:localCallbackId];
    }
    [self writeJavascript:[NSString stringWithFormat:@"window.setTimeout(function(){%@;},0);", javascript]];
    [returnArgs release];
}
- (void) printText:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options{
    NSString *localCallbackId = [arguments objectAtIndex:0];
    NSString *printerSN = [arguments objectAtIndex:1];
    NSString *javascript = nil;
    NSString *data = [arguments objectAtIndex:2];
    NSMutableArray *returnArgs = [[NSMutableArray alloc] init];
    if([data length]){
        BlueBambooPrinterObject *printer;
        if((printer = [self.printers objectForKey:printerSN])){
            int printId = [printer printText:data];
            if(!printId){
                [returnArgs addObject:@"No print id returned"];
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsArray:returnArgs];
                javascript = [pluginResult toErrorCallbackString:localCallbackId];
            }else{
                [returnArgs addObject:[NSNumber numberWithInt:printId]];
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:returnArgs];
                javascript = [pluginResult toSuccessCallbackString:localCallbackId];
            }
        }else{
            [returnArgs addObject:@"Printer not found or not initiated"];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsArray:returnArgs];
            javascript = [pluginResult toErrorCallbackString:localCallbackId];
        }
    }else{
        [returnArgs addObject:@"Text is empty"];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsArray:returnArgs];
        javascript = [pluginResult toErrorCallbackString:localCallbackId];
    }
    [self writeJavascript:[NSString stringWithFormat:@"window.setTimeout(function(){%@;},0);", javascript]];
    [returnArgs release];
}
- (void) sendRawData:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options{
    NSString *localCallbackId = [arguments objectAtIndex:0];
    NSString *printerSN = [arguments objectAtIndex:1];
    NSString *javascript = nil;
    NSString *data = [arguments objectAtIndex:2];
    NSMutableArray *returnArgs = [[NSMutableArray alloc] init];
    if([data length]){
        BlueBambooPrinterObject *printer;
        if((printer = [self.printers objectForKey:printerSN])){
            int printId = [printer printRawData:data];
            if(!printId){
                [returnArgs addObject:@"No print id returned"];
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsArray:returnArgs];
                javascript = [pluginResult toErrorCallbackString:localCallbackId];
            }else{
                [returnArgs addObject:[NSNumber numberWithInt:printId]];
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:returnArgs];
                javascript = [pluginResult toSuccessCallbackString:localCallbackId];
            }
        }else{
            [returnArgs addObject:@"Printer not found or not initiated"];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsArray:returnArgs];
            javascript = [pluginResult toErrorCallbackString:localCallbackId];
        }
    }else{
        [returnArgs addObject:@"Text is empty"];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsArray:returnArgs];
        javascript = [pluginResult toErrorCallbackString:localCallbackId];
    }
    [self writeJavascript:[NSString stringWithFormat:@"window.setTimeout(function(){%@;},0);", javascript]];
    [returnArgs release];

}
- (void) monitor:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    self.callbackId = [arguments objectAtIndex:0];
    NSArray *ary = [NSArray arrayWithObjects:@"PrinterList", [self findPrinters], nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:ary];
    [pluginResult setKeepCallbackAsBool: true];
    NSString *javaScript = [pluginResult toSuccessCallbackString:self.callbackId];
    [self writeJavascript:javaScript];
}
- (void) unmonitor:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString *javaScript = nil;
    NSString *localCallbackId = [arguments objectAtIndex:0];
    if(self.callbackId){
        self.callbackId = nil;
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:nil];
        javaScript = [pluginResult toSuccessCallbackString:localCallbackId];
    }else{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsArray:nil];
        javaScript = [pluginResult toErrorCallbackString:localCallbackId];
    }
    [self writeJavascript:javaScript];
}
- (void) sendEvent: (BlueBambooPrinterObject *) printerObject: (NSString *) event: (NSArray *) args{
    if(self.callbackId){
        NSMutableArray *sendArray = [[NSMutableArray alloc] init];
        [sendArray addObject:event];
        [sendArray addObject:[[printerObject BlueBambooAccessory] macAddress]];
        if(args){
            [sendArray addObjectsFromArray:args];
        }
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:sendArray];
        [pluginResult setKeepCallbackAsBool: true];
        NSString *javaScript = [pluginResult toSuccessCallbackString:self.callbackId];
        [self writeJavascript:javaScript];
        [sendArray release];
    }
}
- (void) dealloc{
    for(BlueBambooPrinterObject *printer in self.printers){
        [printer release];
    }
    [accessoryList release];
    [self.printers release];
    [super dealloc];
}
/*
- (void) test:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* localCallbackId = [arguments objectAtIndex:0];
    CDVPluginResult* pluginResult = nil;
    NSString* javaScript = nil;
    uint8_t tmp[] = {
        0x55, 0x66, 0x77, 0x88, //Inital Frame Bits
        0x44,                   // Tells printer to print

        //0x1d, 0x6B, 0x02, 0x00,      // Ean-13 Barcode (0x00 is the length of data to follow up to 13 characters)
        //0x1d, 0x6B, 0x08, 0x00,      // Ean-8 Barcode (0x00 is the length of data to follow up to 8 characters)
        //0x1d, 0x6B, 0x0C, 0x00,      // UPC-A Barcode (0x00 is the length of data to follow up to 14 characters)
        //0x1d, 0x6B, 0x08, 0x00,      // UPC-E Barcode (0x00 is the length of data to follow up to 8 characters)
        //0x1d, 0x6B, 0x49, 0x00,      // Code128 Barcode (0x00 is the length of data to follow up to 255 characters)

        //0x1d, 0x6B, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 // PDF417 Barcode ... \
            A     B     C     D     E     F     G     H     I \
            A, B - Tells it is'a  pdf417 barcode \
            C    - Can be 0x10 or 0x11. 0x10 is Expand 3 times, 3 data symbols per row. 0x11 Expand 2 times, 7 data symbols per row. \
            D, E - Data words per row (0 means auto select) \
            F, G - Rows (0 means auto select) up to 90 \
            H, I - Data length (up to 500)
        //0x1b, 0x32, 0x00,            // Sets the default line space (0x00 is the space size up to 0xFF in hrizontal motion units.)
        //0x1b, 0x33, 0x00,            // Sets line space (see above) does not affect current line.
        //0x1b, 0x4b, 0x00,            // Sets to ACP or UTF8 encoding 0x00 must be 0x30 or 0x31 where 0x30 is ACP
        //0x1b, 0x52, 0x00,            // Sets internation character set. 0x00 must be 0x00, 0x30 or 0x65. 0x00 is none, 0x30 ISO/IEC 8859-15, 0x65 is UTF8.
        //0x1b, 0x21, 0x00,            // Sets print mode. 0x00 must be between 0 and 255. each bit in the 0x00 byte equals a different flag as described: \
            bit 0 - if 0 selects 32 dot font (24 char per line) if 1 selects 24 dot font (36 char per line) \
            bit 1 - undefined \
            bit 2 - undefined \
            bit 3 - undefined \
            bit 4 - if 1 double-height mode \
            bit 5 - if 1 double-width mode \
            bit 6 - undefined \
            bit 7 - if 1 underline is on.
        //0x1b, 0x2d, 0x00,             // Turns underline mode on/off 0x00 must be 0, 1, 2, 48, 49, 50. 0 & 48 underline off. 1 & 49 turns underline to 1 dot thick. 2 & 50 turns underline mode to 2 dot thick.
        //0x1d, 0x21, 0x00,             // Set char size. 0x00 is the size. First 4 bits are the height last 4 bits are the height. default is 0x00.
        //0x1d, 0x42, 0x00,             // Turn on/off printing reverse mode (black on white or reversed) 0x00 must be 0 or 1. 0 is off 1 is on.
        //0x1b, 0x63, 0x35, 0x00,       // Enables or disables buttons on printer 0x00 is the flag to turn them on or off
        //0x1b, 0x24, L, H,             // Sets absolute position. L represents 
        
        
        
        
        //0x0d, 0X35, 0x30, 0x30, 0x30, 0x33, 0X35, 0x37, 0x37, 0x30, 0x33, 0X30, 0x31, 0x38
        //0x0A, 0x0D,             // Tells printer to line feed (CRLF)
        //0x1B, 0x4A, 0x01,       // Tells printer to print and feed paper 0x01 motion units.
        //0x1B, 0x64, 0x01,       // Tells printer to feed 0x01 lines
        //0x1D, 0x6B,
        
        //0x1b, 0x4b, 0x31, //
        //0x1b, 0x21, 0x41,
        //0x1b, 0x2d, 0x01,
        //0x1d, 0x42, 0x00,
        //0x57, 0x65, 0x6c, 0x63, 0x6f,
        //0x6d, 0x65, 0x20, 0x74, 0x6f, 0x20, 0x62, 0x6c,
        //0x75, 0x65, 0x62, 0x62, 0x6d, 0x62, 0x6f, 0x6f,
        //0x53, 0x72, 0xc1
    };
    //tmp[0] = 0X55; tmp[1]=0x66; tmp[2]=0x77; tmp[3]=0x88; tmp[4]=0x44;
    //tmp[5] = 65; tmp[6] = 65; tmp[7] = 65; tmp[8] = 65; tmp[9] = 65; tmp[10] = 65;
    //tmp[11] = 65; tmp[12] = 65; tmp[13] = 65; tmp[14] = 65; tmp[15] = 65; tmp[16] = 65;
    //tmp[17] = 65; tmp[18] = 65; tmp[19] = 65; tmp[20] = 65; tmp[21] = 65; tmp[22] = 65;
    [self sendToStream:tmp:sizeof(tmp)];
    //free(tmp);

    NSMutableArray *returnArgs = [[NSMutableArray alloc] init];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:returnArgs];
    javaScript = [pluginResult toSuccessCallbackString:localCallbackId];
    [self writeJavascript:[NSString stringWithFormat:@"window.setTimeout(function(){%@;},0);", javaScript]];
}
 */
@end
