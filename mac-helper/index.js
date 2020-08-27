const macHelper = require("bindings")("mac_helper");

console.log(macHelper.areWeOnActiveSpace());

macHelper.listenForActiveSpaceChange((message) => {
  console.log("Success! We got a message from native code:", message);
});

module.exports = macHelper;
