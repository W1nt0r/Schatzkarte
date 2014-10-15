//
//  SolutionLogger.m
//  Metalldetektor
//
//  Created by Sebastian Hunkeler on 17.07.13.
//  Copyright (c) 2013 HSR. All rights reserved.
//

#import "SolutionLogger.h"

#define LOGBOOK_SCHEME @"appquest"

@implementation SolutionLogger
{
    UIViewController* _viewController;
    NSString* _taskName;
    NSString* _solution;
}

- (id)initWithViewController:(UIViewController*)viewController
{
    self = [super init];
    if (self) {
        _viewController = viewController;
    }
    return self;
}


- (void)logSolution:(NSString*)solution taskName:(NSString*)taskname
{
    NSString* encodedSolution = [solution stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString* encodedTaskname = [taskname stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSString* path = [NSString stringWithFormat:@"%@://%@/%@",LOGBOOK_SCHEME,encodedTaskname, encodedSolution];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]];
}

-(void)logSolutionFromQRCode:(NSString*)taskName
{
    [self logSolutionFromQRCode:taskName solution:nil];
}

-(void)logSolutionFromQRCode:(NSString*)taskName solution:(NSString *)solution
{
    _solution = solution;
    _taskName = taskName;
    ZBarReaderViewController *reader = [[ZBarReaderViewController alloc] init];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMask(UIInterfaceOrientationMaskPortrait);
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: ZBAR_NONE config: ZBAR_CFG_ENABLE to: 0];
    [scanner setSymbology: ZBAR_QRCODE config: ZBAR_CFG_ENABLE to: 1];
    [_viewController presentViewController:reader animated:YES completion:nil];
}

#pragma mark - QRCode Reader

- (void) imagePickerController: (UIImagePickerController*)reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    
    NSString* result = symbol.data;
    NSMutableString* finalSolution = [NSMutableString stringWithString:result];
    if(_solution){
        [finalSolution appendFormat:@":%@",_solution];
    }
    _solution = [finalSolution stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    [reader dismissViewControllerAnimated:YES completion:^{
        [self logSolution:_solution taskName:_taskName];
    }];
}

@end
