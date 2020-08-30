#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#include <napi.h>

Napi::ThreadSafeFunction tsfn;

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

Napi::Boolean areWeOnActiveSpace(const Napi::CallbackInfo &info) {
  return Napi::Boolean::New(info.Env(), areWeOnActiveSpaceNative());
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

  // Create a native thread
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

Napi::Object init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "areWeOnActiveSpace"),
              Napi::Function::New(env, areWeOnActiveSpace));

  exports.Set(Napi::String::New(env, "listenForActiveSpaceChange"),
              Napi::Function::New(env, listenForActiveSpaceChange));

  return exports;
};

NODE_API_MODULE(mac_helper, init);