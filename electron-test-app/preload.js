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

  const resultEl = document.getElementById("result");
  setInterval(async () => {
    const result = await ipcRenderer.invoke("areWeOnActiveSpace");
    resultEl.innerHTML += result + "<br>";
  }, 1000);
});
