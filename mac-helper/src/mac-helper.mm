#include <napi.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

Napi::String AreWeOnActiveSpace(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();

  BOOL isOnActiveSpace = NO;
  for (NSWindow * window in  [NSApp orderedWindows]) {
      isOnActiveSpace = [window isOnActiveSpace];
      if( isOnActiveSpace ){
          break;
      }
  }

  return Napi::String::New(env, isOnActiveSpace ? "Yes" : "No");
}

Napi::Object init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "areWeOnActiveSpace"), Napi::Function::New(env, AreWeOnActiveSpace));
  return exports;
};

NODE_API_MODULE(mac_helper, init);