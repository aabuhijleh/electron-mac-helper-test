const { ipcRenderer } = require("electron");

// All of the Node.js APIs are available in the preload process.
// It has the same sandbox as a Chrome extension.
window.addEventListener("DOMContentLoaded", () => {
  const replaceText = (selector, text) => {
    const element = document.getElementById(selector);
    if (element) element.innerText = text;
  };

  for (const type of ["chrome", "node", "electron"]) {
    replaceText(`${type}-version`, process.versions[type]);
  }
});

ipcRenderer.on("ACTIVE_SPACE_CHANGE", (event, hasSwitchedToFullScreenApp) => {
  const resultEl = document.getElementById("result");
  resultEl.innerHTML +=
    `Active space changed - hasSwitchedToFullScreenApp:[${hasSwitchedToFullScreenApp}]` +
    "<br>";
});
