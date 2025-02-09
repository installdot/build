#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface NetBlocker : NSObject
+ (void)injectButton;
@end

@implementation NetBlocker

static UIButton *toggleButton;
static BOOL isBlocked = NO;

+ (void)injectButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (!keyWindow) return;

        // Create a draggable button
        toggleButton = [UIButton buttonWithType:UIButtonTypeSystem];
        toggleButton.frame = CGRectMake(100, 100, 80, 40);
        toggleButton.backgroundColor = [UIColor redColor];
        [toggleButton setTitle:@"Block" forState:UIControlStateNormal];
        [toggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        toggleButton.layer.cornerRadius = 10;
        toggleButton.clipsToBounds = YES;

        // Add button action
        [toggleButton addTarget:self action:@selector(toggleInternet) forControlEvents:UIControlEventTouchUpInside];

        // Enable dragging
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
        [toggleButton addGestureRecognizer:panGesture];

        [keyWindow addSubview:toggleButton];
    });
}

// Function to block/unblock internet
+ (void)toggleInternet {
    isBlocked = !isBlocked;

    if (isBlocked) {
        [toggleButton setTitle:@"Unblock" forState:UIControlStateNormal];
        toggleButton.backgroundColor = [UIColor greenColor];

        // Kill network services
        system("killall -STOP nehelper");
        system("killall -STOP mDNSResponder");
        system("killall -STOP rapportd");

        NSLog(@"[NetBlocker] Internet Blocked!");
    } else {
        [toggleButton setTitle:@"Block" forState:UIControlStateNormal];
        toggleButton.backgroundColor = [UIColor redColor];

        // Resume network services
        system("killall -CONT nehelper");
        system("killall -CONT mDNSResponder");
        system("killall -CONT rapportd");

        NSLog(@"[NetBlocker] Internet Restored!");
    }
}

// Make button draggable
+ (void)handleDrag:(UIPanGestureRecognizer *)gesture {
    UIView *draggedView = gesture.view;
    CGPoint translation = [gesture translationInView:draggedView.superview];

    if (gesture.state == UIGestureRecognizerStateChanged) {
        draggedView.center = CGPointMake(draggedView.center.x + translation.x, draggedView.center.y + translation.y);
        [gesture setTranslation:CGPointZero inView:draggedView.superview];
    }
}

@end

%hook UIApplication

- (void)didFinishLaunching {
    %orig;
    [NetBlocker injectButton];
}

%end
