const { ipcRenderer, desktopCapturer } = require("electron");

// All of the Node.js APIs are available in the preload process.
// It has the same sandbox as a Chrome extension.
window.addEventListener("DOMContentLoaded", async () => {
  const replaceText = (selector, text) => {
    const element = document.getElementById(selector);
    if (element) element.innerText = text;
  };

  for (const type of ["chrome", "node", "electron"]) {
    replaceText(`${type}-version`, process.versions[type]);
  }

  const sources = await desktopCapturer.getSources({
    types: ["window", "screen"],
  });

  console.log(sources);

  const sourceList = document.getElementById("sources");

  for (const source of sources) {
    const child = document.createElement("li");
    child.innerHTML = `name:[${source.name}]` + `, id:[${source.id}]`;
    child.addEventListener("click", () => {
      handleHighlightClick(source.id);
    });
    sourceList.appendChild(child);
  }
});

function handleHighlightClick(sourceId) {
  console.log("handleHighlightClick", sourceId);
  const parsedSourceId = sourceId.split(":")[1];
  ipcRenderer.send("handleHighlightClick", parsedSourceId);
}

ipcRenderer.on("ACTIVE_SPACE_CHANGE", (event, hasSwitchedToFullScreenApp) => {
  const resultEl = document.getElementById("result");
  resultEl.innerHTML +=
    `Active space changed - hasSwitchedToFullScreenApp:[${hasSwitchedToFullScreenApp}]` +
    "<br>";
});
