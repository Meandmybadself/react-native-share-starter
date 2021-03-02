#import "ShareViewController.h"
#import <React/RCTRootView.h>
#import <React/RCTBundleURLProvider.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define URL_IDENTIFIER (NSString *)kUTTypeURL

NSExtensionContext* extensionContext;

@implementation ShareViewController {
}

RCT_EXPORT_MODULE();

- (void) viewDidLoad {
  [super viewDidLoad];


  extensionContext = self.extensionContext; // global for later call to async promise
  
  // set up react native instance
  NSURL *jsCodeLocation;
  
  jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL: jsCodeLocation
                                               moduleName: @"Share"
                                               initialProperties: nil
                                                   launchOptions: nil];
  
  UIViewController *rootViewController = [UIViewController alloc];
  rootViewController.view = rootView;
  [self addChildViewController: rootViewController];
  
  rootViewController.view.frame = self.view.bounds;
  rootViewController.view.translatesAutoresizingMaskIntoConstraints = false;
  [[self view] addSubview:rootViewController.view];
  NSArray* constraints = [NSArray arrayWithObjects:
                          [rootViewController.view.leftAnchor constraintEqualToAnchor: self.view.leftAnchor],
                          [rootViewController.view.rightAnchor constraintEqualToAnchor: self.view.rightAnchor],
                          [rootViewController.view.topAnchor constraintEqualToAnchor: self.view.topAnchor],
                          [rootViewController.view.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor], nil
                        ];
  [NSLayoutConstraint activateConstraints:constraints];
  
  [self didMoveToParentViewController: self];
  
}

RCT_REMAP_METHOD(getParameters,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    [self extractData: extensionContext withCallback:^(NSDictionary* result, NSException* err) {
        if(err) {
            reject(@"error", err.description, nil);
        } else {
            resolve(result);
        }
    }];
}

- (void) extractData: (NSExtensionContext *)context withCallback:(void(^)(NSDictionary* result, NSException *exception))callback {
  @try {

    
    // get items shared
    NSExtensionItem *item = [context.inputItems firstObject];
    __block NSItemProvider *provider = item.attachments.firstObject;
    
    if([provider hasItemConformingToTypeIdentifier:URL_IDENTIFIER]) {
      [provider loadItemForTypeIdentifier:URL_IDENTIFIER options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
        NSURL *url = (NSURL *)item;
        NSDictionary *result = @{@"data": [url absoluteString], @"type": @"url"};
        if(callback) {
            callback(result, nil);
        }
      }];
      
      return;
      
    }
    
    if(callback) {
      callback(nil, [NSException exceptionWithName:@"Error" reason:@"couldn't find provider" userInfo:nil]);
    }
  }
  @catch (NSException *exception) {
  }
}

@end
