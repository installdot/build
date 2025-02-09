#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface MyBlockButton : UIButton
@property (nonatomic, assign) BOOL internetBlocked;
@end

@implementation MyBlockButton

// Toggle internet for the app when the button is clicked
- (void)toggleInternet {
    if (self.internetBlocked) {
        // Unblock internet (resume network)
        system("killall -CONT nehelper");
        system("killall -CONT mDNSResponder");
        system("killall -CONT rapportd");
        self.internetBlocked = NO;
        [self setTitle:@"BlockNet" forState:UIControlStateNormal];
    } else {
        // Block internet (pause network)
        system("killall -STOP nehelper");
        system("killall -STOP mDNSResponder");
        system("killall -STOP rapportd");
        self.internetBlocked = YES;
        [self setTitle:@"UnblockNet" forState:UIControlStateNormal];
    }
}

// Make the button draggable
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchLocation = [[touches anyObject] locationInView:self.superview];
    self.center = CGPointMake(touchLocation.x, touchLocation.y);
}

@end

%hook UIApplication
- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;

    // Ensure button is added only once
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (!keyWindow) return;

        MyBlockButton *button = [MyBlockButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(50, 100, 150, 50);
        [button setTitle:@"Block Internet" forState:UIControlStateNormal];
        [button addTarget:button action:@selector(toggleInternet) forControlEvents:UIControlEventTouchUpInside];
        
        button.backgroundColor = [UIColor redColor];
        button.layer.cornerRadius = 10;
        button.internetBlocked = NO;
        [keyWindow addSubview:button];
    });
}
%end
