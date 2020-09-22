#import "OSXAppHidhtlightDeledate.h"
#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#include <napi.h>

Napi::ThreadSafeFunction tsfn;

OSXAppHidhtlightDeledate *highlighter;

// Detect if the app's windows are on the active space or not
BOOL areWeOnActiveSpaceNative() {
  BOOL isOnActiveSpace = NO;
  for (NSWindow *window in [NSApp orderedWindows]) {
    isOnActiveSpace = [window isOnActiveSpace];
    if (isOnActiveSpace) {
      break;
    }
  }
  return isOnActiveSpace;
}

// Trigger the JS callback when active space changes
void listenForActiveSpaceChange(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();

  // Create a ThreadSafeFunction
  tsfn = Napi::ThreadSafeFunction::New(
      env,
      info[0].As<Napi::Function>(), // JavaScript function called asynchronously
      "Active Space",               // Name
      0,                            // Unlimited queue
      1                             // Only one thread will use this initially
  );

  // Create a native callback function to be invoked by the TSFN
  auto callback = [](Napi::Env env, Napi::Function jsCallback, BOOL *value) {
    // Call the JS callback
    jsCallback.Call({Napi::Boolean::New(env, *value)});

    // We're finished with the data.
    delete value;
  };

  // Subscribe to macOS spaces change event
  [[[NSWorkspace sharedWorkspace] notificationCenter]
      addObserverForName:NSWorkspaceActiveSpaceDidChangeNotification
                  object:NULL
                   queue:NULL
              usingBlock:^(NSNotification *note) {
                // Create new data
                BOOL *hasSwitchedToFullScreenApp =
                    new BOOL(!areWeOnActiveSpaceNative());

                // Perform a blocking call
                napi_status status =
                    tsfn.BlockingCall(hasSwitchedToFullScreenApp, callback);
                if (status != napi_ok) {
                  NSLog(@"Something went wrong, BlockingCall failed");
                }
              }];
}

void startHighlighting(const Napi::CallbackInfo &info) {
  NSLog(@"startHighlighting");

  Napi::Env env = info.Env();

  long sourceId = info[0].As<Napi::Number>().Int32Value();

  highlighter = [[OSXAppHidhtlightDeledate alloc] initWithWindowId:sourceId];
  [highlighter show];
}

void stopHighlighting(const Napi::CallbackInfo &info) {
  NSLog(@"stopHighlighting");

  [highlighter end];
  [highlighter release];
}

Napi::Object init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "listenForActiveSpaceChange"),
              Napi::Function::New(env, listenForActiveSpaceChange));

  exports.Set(Napi::String::New(env, "startHighlighting"),
              Napi::Function::New(env, startHighlighting));

  exports.Set(Napi::String::New(env, "stopHighlighting"),
              Napi::Function::New(env, stopHighlighting));

  return exports;
};

NODE_API_MODULE(mac_helper, init);