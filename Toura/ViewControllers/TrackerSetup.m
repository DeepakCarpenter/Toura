//
//  TrackerSetupViewController.m
//  Toura
//
//  Created by Pairmi, Vikram (US - Bengaluru) on 12/2/17.
//  Copyright © 2017 TechMusketeers. All rights reserved.
//

#import "TrackerSetup.h"
#import "Constants.h"

@interface TrackerSetup ()

@property(nonatomic) ARImageTrackerManager *imageTrackerManager;

@end

@implementation TrackerSetup

@synthesize imageTrackerManager;

+ (id)sharedManager{
    static TrackerSetup *trackerSetup = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         trackerSetup = [[self alloc] init];
        [trackerSetup setupTrackableContent];
    });
    return trackerSetup;
}

- (void)setupTrackableContent {
    //Setup imageTrackableSet
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"udaipur" ofType:@"KARMarker"];
    ARImageTrackableSet *imageTrackableSet = [[ARImageTrackableSet alloc] initWithPath:filePath];
    
    //Setup TrackerManager
    imageTrackerManager = [ARImageTrackerManager getInstance];
    [imageTrackerManager initialise];
    [imageTrackerManager toggleParallelDetection:YES];
    [imageTrackerManager setMaximumSimultaneousTracking:10];
    [imageTrackerManager start];
    
    [imageTrackerManager addTrackableSet:imageTrackableSet];
    
    //Setup Gesture recognizers
    for (ARImageTrackable *imageTrackable in imageTrackableSet.trackables) {
        
        imageTrackable.name = UDAIPUR_MARKER_NAME;
        [imageTrackable allowRecoveryMode];
        
        [imageTrackable addTrackingEventTarget:self action:@selector(trackerDetected:) forEvent:ARImageTrackableEventDetected];
        [imageTrackable addTrackingEventTarget:self action:@selector(trackerLost:) forEvent:ARImageTrackableEventLost];
    }
    
    //3D Model Tracker
    [self setupFortModelTrackable];
}

- (void)setupFortModelTrackable {
    //Setup Single Markers
    ARImageTrackable *fortModelTrackable = [[ARImageTrackable alloc] initWithImage:[UIImage imageNamed:@"fort.png"] name:@"fortModel"];
    [imageTrackerManager addTrackable:fortModelTrackable];
    
    [fortModelTrackable allowRecoveryMode];
    [fortModelTrackable addTrackingEventTarget:self action:@selector(trackerDetected:) forEvent:ARImageTrackableEventDetected];
    [fortModelTrackable addTrackingEventTarget:self action:@selector(trackerLost:) forEvent:ARImageTrackableEventLost];
}

#pragma mark - Event detection methods

- (void)trackerDetected:(ARImageTrackable *)imageTrackable {
    // Initialise image node
    ARImageNode *imageNode = [[ARImageNode alloc] initWithBundledFile:@"Overlay.png"];
    
    // Add image node to image trackable
    [imageTrackable.world addChild:imageNode];
    
    // Image scale
    float scale = (float)imageTrackable.width / imageNode.texture.width;
    [imageNode rotateByDegrees:0 axisX:0.0 y:1.0 z:0.0];
    [imageNode scaleByUniform:scale];
    
    // Hide image node
    [imageNode setVisible:YES];
    
    [self.delegate detectedTrackable:imageTrackable];
}

- (void)trackerLost:(ARImageTrackable *)imageTrackable {
    [self.delegate lostTrackable:imageTrackable];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
