#import "box.mm"
#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#include <napi.h>

// just testing importing and using an Objective-C class
void test() {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  Box *box1 = [[Box alloc] init]; // Create box1 object of type Box
  Box *box2 = [[Box alloc] init]; // Create box2 object of type Box

  double volume = 0.0; // Store the volume of a box here

  // box 1 specification
  box1.height = 5.0;

  // box 2 specification
  box2.height = 10.0;

  // volume of box 1
  volume = [box1 volume];
  NSLog(@"Volume of Box1 : %f", volume);

  // volume of box 2
  volume = [box2 volume];
  NSLog(@"Volume of Box2 : %f", volume);

  [pool drain];
}

Napi::String AreWeOnActiveSpace(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();

  BOOL isOnActiveSpace = NO;
  for (NSWindow *window in [NSApp orderedWindows]) {
    isOnActiveSpace = [window isOnActiveSpace];
    if (isOnActiveSpace) {
      break;
    }
  }

  return Napi::String::New(env, isOnActiveSpace ? "Yes" : "No");
}

Napi::Object init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "areWeOnActiveSpace"),
              Napi::Function::New(env, AreWeOnActiveSpace));

  test();
  return exports;
};

NODE_API_MODULE(mac_helper, init);