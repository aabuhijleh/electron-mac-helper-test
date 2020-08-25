{
  "targets": [
    { 
      "cflags!": [ "-fno-exceptions" ],
      "cflags_cc!": [ "-fno-exceptions" ],
      "include_dirs" : [
        "<!@(node -p \"require('node-addon-api').include\")"
      ],
      "target_name": "mac_helper",
      "sources": [ "src/mac-helper.mm" ],
      "xcode_settings": {
        "OTHER_CPLUSPLUSFLAGS": ["-std=c++11", "-stdlib=libc++", "-mmacosx-version-min=10.10"],
        "OTHER_LDFLAGS": ["-framework CoreFoundation -framework IOKit -framework AppKit"]
      },
      'defines': [ 'NAPI_DISABLE_CPP_EXCEPTIONS' ]
    }
  ]
}