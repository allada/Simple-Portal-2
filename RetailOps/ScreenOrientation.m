//
//  ScreenOrientation.m
//
//  Created by Simon Cruise on 30/08/2012.
//

#import "ScreenOrientation.h"

@implementation ScreenOrientation

- (void)set:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    NSMutableArray *returnArgs = [[NSMutableArray alloc] init];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:returnArgs];
    NSString *javaScript = [pluginResult toSuccessCallbackString:[arguments objectAtIndex:0]];
    [self writeJavascript:[NSString stringWithFormat:@"window.setTimeout(function(){%@;},0);", javaScript]];
    [returnArgs release];
    returnArgs = nil;
    

    NSMutableArray *allowed = [NSMutableArray array];
    NSString *targetOrientation = [options objectForKey:@"key"];
    int statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    int statusBarWidth = [[UIApplication sharedApplication] statusBarFrame].size.width;
    int orentation = [[UIApplication sharedApplication] statusBarOrientation];
    if([targetOrientation isEqualToString:@"landscape"]) {
        if(UIDeviceOrientationIsLandscape(orentation)){
            return;
        }
        [allowed addObject:[NSNumber numberWithInt:UIDeviceOrientationLandscapeRight]];
        //appDelegate.viewController.allowedOrientations = allowed;
        [[UIApplication sharedApplication] setStatusBarOrientation:UIDeviceOrientationLandscapeRight animated:YES];
        [[[appDelegate viewController] view] setTransform: CGAffineTransformMakeRotation(M_PI * 1.5)];
        [[[appDelegate viewController] view] setFrame:CGRectMake(statusBarHeight, 0, [[appDelegate viewController] view].frame.size.height-statusBarHeight, [[appDelegate viewController] view].frame.size.width+statusBarHeight)];
        
        [UIView commitAnimations];
    }
    if([targetOrientation isEqualToString:@"portrait"]) {
        if(UIDeviceOrientationIsPortrait(orentation)){
            return;
        }
        //if (![appDelegate.viewController.allowedOrientations containsObject:[NSNumber numberWithInt:UIDeviceOrientationPortrait]]) {
            [allowed addObject:[NSNumber numberWithInt:UIDeviceOrientationPortrait]];
            //[appDelegate viewController.allowedOrientations = allowed;
            [[UIApplication sharedApplication] setStatusBarOrientation:UIDeviceOrientationPortrait animated:YES];
            [[[appDelegate viewController] view] setTransform: CGAffineTransformMakeRotation(0)];
            [[[appDelegate viewController] view] setFrame:CGRectMake(0, statusBarWidth, [[appDelegate viewController] view].frame.size.height+statusBarWidth, [[appDelegate viewController] view].frame.size.width-statusBarWidth)];
        
            [UIView commitAnimations];
             
        //}
    }

}


@end
