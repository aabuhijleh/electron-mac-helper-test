#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#include <napi.h>

// detect if our Electron app's windows are on the active space or not
Napi::String areWeOnActiveSpace(const Napi::CallbackInfo &info) {
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

// reference to JS callback
Napi::FunctionReference cb;

// trigger JS callback
void triggerCallback() {
  const Napi::Env env = cb.Env();
  const Napi::String message = Napi::String::New(env, "space changed");
  const std::vector<napi_value> args = {message};
  cb.Call(args);
}

// setup the JS callback to be triggered later
void listenForActiveSpaceChange(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();

  cb = Napi::Persistent(info[0].As<Napi::Function>());
  cb.SuppressDestruct();

  triggerCallback(); // this works!

  // subscribe to macOS spaces change event
  [[[NSWorkspace sharedWorkspace] notificationCenter]
      addObserverForName:NSWorkspaceActiveSpaceDidChangeNotification
                  object:NULL
                   queue:NULL
              usingBlock:^(NSNotification *note) {
                triggerCallback(); // this is never called!
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