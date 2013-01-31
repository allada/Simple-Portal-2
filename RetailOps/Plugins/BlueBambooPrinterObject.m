//
//  BlueBambooPrinterObject.m
//  Starin
//
//  Created by Nathan Bruer on 11/20/12.
//  Copyright (c) 2012 Starin Marketing Inc. All rights reserved.
//
#define MAX_IMAGE_WIDTH 0x30
#define MAX_HEIGHT_PACKET 41
#define MAX_BYTES_SEND 2000

#define MAX_SMALL_IMG_WIDTH = 0x18
#define MAX_SMALL_IMG_HEIGHT_PACKET = 83

#import "BlueBambooPrinterObject.h"

@implementation BlueBambooPrinterObject
@synthesize BlueBambooAccessory, BlueBambooSession, eventDispatcherId;

int const CleanBufferSize = 0x7FFFF;
uint8_t *printBuffer;
int totalNumChunks = 0;
int printBufferSize = 0;
id <BlueBambooPrinterDelegate> eventDelegate;
int printBufferPosition = 0;
NSMutableDictionary * printBufferChunks;
bool outStreamIsReady = false;
bool inStreamIsReady = false;

- (BlueBambooPrinterObject *) init: (EAAccessory *) accessory: (id <BlueBambooPrinterDelegate>) delegate{
    self = [super init];
    self.BlueBambooAccessory = accessory;
    eventDelegate = delegate;
    printBufferChunks = [[NSMutableDictionary alloc] init];
    return self;
}
- (int) bufferNumChunks{
    return [printBufferChunks count];
}
- (int) bufferSize{
    return printBufferSize;
}
/**
 * Cleans buffer and returns the space that was freed up
 */
- (int) cleanBuffer{
    int totalCount = 0;
    int newStartPos = 0;
    int curBytes;
    NSArray *keys = [printBufferChunks allKeys];
    for(NSString *key in keys){
        curBytes = [[printBufferChunks objectForKey:key] intValue];
        totalCount += curBytes;
        if(totalCount <= printBufferPosition){
            if(totalCount - curBytes <= printBufferPosition){
                newStartPos = printBufferPosition - (totalCount - curBytes);
                break;
            }else{
                [printBufferChunks removeObjectForKey:key];
            }
        }
    }
    uint8_t *tmpBuffer;
    tmpBuffer = malloc(printBufferSize - printBufferPosition + newStartPos);
    memcpy((uint8_t *) tmpBuffer, (uint8_t *) (printBuffer + printBufferPosition - newStartPos), printBufferSize - printBufferPosition + newStartPos);
    printBufferSize = printBufferSize - printBufferPosition + newStartPos;
    printBuffer = (uint8_t *) realloc(printBuffer, printBufferSize);
    int tmpPrintBufferPosition = printBufferPosition - newStartPos;
    printBufferPosition = newStartPos;
    memcpy(printBuffer, tmpBuffer, printBufferSize);
    free(tmpBuffer);
    return tmpPrintBufferPosition;
}
- (void) initPrinter{
    if(!self.BlueBambooSession){
        LOG(@"Connecting to printer");
        self.BlueBambooSession = [[EASession alloc] initWithAccessory:self.BlueBambooAccessory forProtocol:BlueBambooProtocolString];
        [self openInStream];
    }
}

- (bool) removeFromQueue:(int) key{
    if([printBufferChunks objectForKey:[NSString stringWithFormat:@"%d", key]] != nil){
        int totalCount = 0;
        int curBytes;
        
        NSArray *keys = [printBufferChunks allKeys];
        for(NSString *iKey in keys){
            curBytes = [[printBufferChunks objectForKey:iKey] intValue];
            totalCount += curBytes;
            if([iKey intValue] == key){
                if(printBufferPosition > totalCount - curBytes){
                    return false;
                }
                [printBufferChunks removeObjectForKey:iKey];
                break;
            }
        }
        totalCount -= curBytes;
        
        memcpy((uint8_t *) printBuffer + totalCount, (uint8_t *) printBuffer + totalCount + curBytes, printBufferSize - curBytes);
        printBufferSize -= curBytes;
        printBuffer = (uint8_t *) realloc(printBuffer, printBufferSize);
        return true;
    }
    return false;
}
/**
 * Returns a referencable integer to be able to delete print jobs.
 */
- (int) sendToStream: (uint8_t *) data: (int) length{
    totalNumChunks++;
    [printBufferChunks setValue:[NSNumber numberWithInt:length] forKey:[NSString stringWithFormat:@"%d", totalNumChunks]];
    printBuffer = (uint8_t *) realloc(printBuffer, printBufferSize + length);
    memcpy((uint8_t *) (printBuffer + printBufferSize), data, length);
    printBufferSize = printBufferSize + length;
    if(printBufferPosition < printBufferSize){
        [self initPrinter];
    }
    return totalNumChunks;
}
- (void) closeSession{
    [self closeInStream];
    [self closeOutStream];
    LOG(@"Closing Session");
    [self.BlueBambooSession release];
    self.BlueBambooSession = nil;
}
- (void) closeInStream{
    if(inStreamIsReady){
        LOG(@"Closing instream");
        inStreamIsReady = false;
        [[self.BlueBambooSession inputStream] close];
        [[self.BlueBambooSession inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[self.BlueBambooSession inputStream] setDelegate:nil];
    }
}
- (void) closeOutStream{
    if(outStreamIsReady){
        LOG(@"Closing outstream");
        outStreamIsReady = false;
        [[self.BlueBambooSession outputStream] close];
        [[self.BlueBambooSession outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[self.BlueBambooSession outputStream] setDelegate:nil];
    }
}
- (void) openInStream{
    if(!inStreamIsReady){
        [[self.BlueBambooSession inputStream] setDelegate:self];
        [[self.BlueBambooSession inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[self.BlueBambooSession inputStream] open];
    }
}
- (void) openOutStream{
    if(!outStreamIsReady){
        [[self.BlueBambooSession outputStream] setDelegate:self];
        [[self.BlueBambooSession outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[self.BlueBambooSession outputStream] open];
    }
}
/**
 * Returns number of bytes written to stream
 */
- (int) sendBuffer{
    // Cleans up buffer if it's too large to to keep memory from going ape-shit.
    if(printBufferSize >= CleanBufferSize){
        [self cleanBuffer];
    }
    if(outStreamIsReady && printBufferPosition < printBufferSize){
        int totalCount = 0;
        int curBytes = 0;
        NSArray *keys = [printBufferChunks allKeys];
        keys = [keys sortedArrayUsingComparator:^(id obj1, id obj2) {
            int nObj1 = [obj1 intValue];
            int nObj2 = [obj2 intValue];
            if(nObj1 > nObj2){
                return (NSComparisonResult)NSOrderedDescending;
            }
            if(nObj1 < nObj2){
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        for(NSString *key in keys){
            curBytes = [[printBufferChunks objectForKey:key] intValue];
            totalCount += curBytes;
            if(totalCount > printBufferPosition){
                break;
            }else{
                //[printBufferChunks removeObjectForKey:key];
            }
        }
        int bytesWritten = [[self.BlueBambooSession outputStream] write: (const uint8_t *) (printBuffer + printBufferPosition) maxLength:(MAX_BYTES_SEND>curBytes?curBytes:MAX_BYTES_SEND)];
        LOG(@"Sent %d bytes to printer", bytesWritten);
        if((MAX_BYTES_SEND>curBytes?curBytes:MAX_BYTES_SEND) == bytesWritten){
            [self closeOutStream];
        }
        printBufferPosition += bytesWritten;
        return bytesWritten;
    }
    return 0;
}
- (void) stream:(NSStream *)theStream handleEvent:(NSStreamEvent) streamEvent{
    uint8_t buff[100];
    unsigned int len;
	switch(streamEvent)
	{
		case NSStreamEventOpenCompleted:
            // Can be input or output stream
            if(theStream == [self.BlueBambooSession outputStream]){
                LOG(@"Output stream opened");
            }else{
                LOG(@"Input stream opened");
                inStreamIsReady = true;
                [self openOutStream];
            }
            break;
		case NSStreamEventHasBytesAvailable:
            // Is always input stream
            len = [[self.BlueBambooSession inputStream] read:buff maxLength:100];
            if(len > 0){
                if(buff[4] == 0x03 && buff[5] == 0x00){
                    int totalCount = 0;
                    int curBytes = 0;
                    NSArray *keys = [printBufferChunks allKeys];
                    keys = [keys sortedArrayUsingComparator:^(id obj1, id obj2) {
                        int nObj1 = [obj1 intValue];
                        int nObj2 = [obj2 intValue];
                        if(nObj1 > nObj2){
                            return (NSComparisonResult)NSOrderedDescending;
                        }
                        if(nObj1 < nObj2){
                            return (NSComparisonResult)NSOrderedAscending;
                        }
                        return (NSComparisonResult)NSOrderedSame;
                    }];
                    NSString *foundKey = nil;
                    for(NSString *key in keys){
                        curBytes = [[printBufferChunks objectForKey:key] intValue];
                        totalCount += curBytes;
                        if(totalCount > printBufferPosition){
                            foundKey = key;
                            break;
                        }
                    }
                    if(foundKey && eventDelegate){
                        NSArray *eventAry = [NSArray arrayWithObject:[NSNumber numberWithInt:[foundKey intValue]]];
                        [eventDelegate sendEvent:self:@"PrintingDone":eventAry];
                    }
                    [self closeSession];
                    if(printBufferPosition < printBufferSize){
                        LOG(@"More to print...");
                        [self initPrinter];
                    }else{
                        LOG(@"Print complete");
                    }
                }
            }
			break;
		case NSStreamEventHasSpaceAvailable:
            LOG(@"Printer ready to receive data");
            outStreamIsReady = true;
            [self sendBuffer];
			break;
		case NSStreamEventErrorOccurred:
			// Error!
            LOG(@"Error");
			break;
		default:
            LOG(@"ERROR maybe device disconnected?");
            [self closeSession];
            // Try to connect again
            if(printBufferPosition < printBufferSize){
                [self initPrinter];
            }
            break;
	}
}
-(uint8_t *) makeBitImg: (UIImage *) image: (int *) len: (int *) width{
    NSData *newData = UIImageJPEGRepresentation(image, 1.0);
    image = [UIImage imageWithData:newData];
    int imgW = image.size.width;
    int imgH = image.size.height;
    *width = MAX_IMAGE_WIDTH < imgW / 8 ? MAX_IMAGE_WIDTH : ceilf((float) imgW / 8);
    uint8_t *data = (uint8_t *) calloc(imgH, *width);
    UInt8 r = 0, g = 0, b = 0;
    int x = 0, y = 0;
    CGDataProviderRef dataProvider = CGImageGetDataProvider(image.CGImage);
    CFDataRef imageData = CGDataProviderCopyData(dataProvider);
    size_t bytesPerRow = CGImageGetBytesPerRow(image.CGImage);
    UInt8 *pixels = (UInt8*) CFDataGetBytePtr(imageData); //RGB of image
    for(;y<imgH;y++){
        for(x=0;x<imgW && x<*width * 8;x++){
            UInt8 *tmp = pixels + y * bytesPerRow + x * 4;
            r = *(tmp + 3);
            g = *(tmp + 2);
            b = *(tmp + 1);
            
            data[y * *width + ((int) x / 8)] <<= 1;
            if((77 * r + 28 * g + 151 * b) / 256 < 200) {
                data[y * *width + ((int) x / 8)] += 1;
            }
        }
    }
    *len = *width * imgH;
    return data;
}
-(void) printerConnected: (EAAccessory *) accessory{
    self.BlueBambooAccessory = accessory;
    if(printBufferPosition < printBufferSize){
        [self initPrinter];
    }
}
-(void) printerDisconnected{
    [self closeSession];
    self.BlueBambooAccessory = nil;
}
-(int) printImage: (UIImage *) img{
    int len, width, printId = 0;
    uint8_t *bin_image = [self makeBitImg:img:&len:&width];
    [img release];
    
    const uint8_t headerData[] = {
        0x55, 0x66, 0x77, 0x88, 0x44, 0x1B, 0x58, 0x31,
        width, 0x00
    };
    int max_height_packet = (MAX_BYTES_SEND - sizeof(headerData)) / width;
    uint8_t *newImg = malloc(max_height_packet * width + sizeof(headerData));
    memcpy(newImg, headerData, sizeof(headerData));
    int curLen = len;
    do{
        newImg[sizeof(headerData) - 1] = curLen > max_height_packet * width?max_height_packet:curLen / width;
        memcpy(newImg + sizeof(headerData), bin_image + (len - curLen), (curLen > max_height_packet * width)?max_height_packet * width:curLen);
        printId = [self sendToStream:newImg:((curLen > max_height_packet * width)?max_height_packet * width:curLen) + sizeof(headerData)];
        curLen -= max_height_packet * width;
    }while(curLen > 0);
    
    free(bin_image);
    free(newImg);
    return printId;
}
- (int) printText: (NSString *) text{
    NSData *dText = [text dataUsingEncoding:NSUTF8StringEncoding];
    const void *bytes = [dText bytes];
    int len = [dText length];
    const uint8_t headerData[] = {
        0x55, 0x66, 0x77, 0x88, 0x44
    };
    uint8_t *data = malloc(sizeof(headerData) + len);
    memcpy(data, headerData, sizeof(headerData));
    memcpy(data + sizeof(headerData), bytes, len);
    int printId = [self sendToStream:data:sizeof(headerData) + len];
    free(data);
    return printId;
}
- (int) printRawData: (NSString *) text{
    NSData *dText = [text dataUsingEncoding:NSUTF8StringEncoding];
    int printId = [self sendToStream:(uint8_t *)[dText bytes]:[dText length]];
    return printId;
}
- (void) dealloc{
    [self closeSession];
    [printBufferChunks release];
    [super dealloc];
}
@end
