//
//  SolutionLogger.h
//  Metalldetektor
//
//  Created by Sebastian Hunkeler on 17.07.13.
//  Copyright (c) 2013 HSR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBarSDK.h"

@interface SolutionLogger : NSObject<ZBarReaderDelegate>

-(id)initWithViewController:(UIViewController*)viewController;

-(void)logSolution:(NSString*)solution taskName:(NSString*)taskname;

/**
 * Sends a solution to the logbook by using a text, read from a QR Code
 * appended by a custom solution string.
 * @param taskName The name of the task for which the solution should be logged
 * @param solution A custom string that denotes the solution to the task
 **/
-(void)logSolutionFromQRCode:(NSString*)taskName solution:(NSString*)solution;

-(void)logSolutionFromQRCode:(NSString*)taskName;

@end
