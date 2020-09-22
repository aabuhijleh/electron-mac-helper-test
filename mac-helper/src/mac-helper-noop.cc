#include <napi.h>

Napi::Object init(Napi::Env env, Napi::Object exports) {
    return exports;
};

NODE_API_MODULE(mac_helper, init);