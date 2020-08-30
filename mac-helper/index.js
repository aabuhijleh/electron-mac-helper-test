const macHelper = require("bindings")("mac_helper");

// How to use?

// macHelper.areWeOnActiveSpace(); // true if at least one of your app's windows is on the active space

// Active space changes callback
// macHelper.listenForActiveSpaceChange((hasSwitchedToFullScreenApp) => {
//   console.log(
//     `Active space changed - hasSwitchedToFullScreenApp:[${hasSwitchedToFullScreenApp}]`
//   );
// });

module.exports = macHelper;
