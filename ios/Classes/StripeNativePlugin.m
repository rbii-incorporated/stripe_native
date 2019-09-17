#import "StripeNativePlugin.h"
#import <stripe_native/stripe_native-Swift.h>

@implementation StripeNativePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftStripeNativePlugin registerWithRegistrar:registrar];
}
@end
