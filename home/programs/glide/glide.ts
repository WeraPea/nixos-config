// Config docs:
//
//   https://glide-browser.app/config
//
// API reference:
//
//   https://glide-browser.app/api
//
// Default config files can be found here:
//
//   https://github.com/glide-browser/glide/tree/main/src/glide/browser/base/content/plugins
//
// Most default keymappings are defined here:
//
//   https://github.com/glide-browser/glide/blob/main/src/glide/browser/base/content/plugins/keymaps.mts

// a lot taken from https://github.com/glide-browser/glide/discussions/63

glide.keymaps.del("normal", "<A-h>");
glide.keymaps.del("normal", "<C-j>");
glide.keymaps.del("normal", "<C-k>");
glide.keymaps.del("normal", "<A-l>");

glide.keymaps.set("normal", "<A-h>", "tab_prev");
glide.keymaps.set("normal", "<A-l>", "tab_next");

glide.keymaps.set("normal", "<A-j>", "back");
glide.keymaps.set("normal", "<A-k>", "forward");

glide.keymaps.set("normal", "J", "back");
glide.keymaps.set("normal", "K", "forward");

glide.keymaps.set("normal", "x", when_editing("motion x", "tab_close"));
glide.keymaps.set(
  "normal",
  "X",
  when_editing("motion X", async () => await browser.sessions.restore()),
);
glide.keymaps.set(
  "normal",
  "u",
  when_editing("undo", async () => await browser.sessions.restore()),
);

glide.keymaps.set("normal", "r", when_editing("r", "reload"));
glide.keymaps.set("normal", "R", when_editing(null, "reload_hard"));
glide.keymaps.set("normal", "<C-r>", "config_reload");
glide.keymaps.set("normal", "t", when_editing(null, "tab_new"));
glide.keymaps.set("normal", "T", when_editing(null, "commandline_show tab "));
glide.keymaps.set("normal", "/", "keys <D-f>");

glide.keymaps.set(
  "normal",
  "yt",
  when_editing(
    null,
    async ({ tab_id }) => await browser.tabs.duplicate(tab_id),
  ),
);
glide.keymaps.set(
  "normal",
  "p",
  when_editing(null, async () => {
    const url = await navigator.clipboard.readText();
    await browser.tabs.update({ url });
  }),
);
glide.keymaps.set(
  "normal",
  "P",
  when_editing(null, async () => {
    const url = await navigator.clipboard.readText();
    await browser.tabs.create({ url });
  }),
);

// glide.autocmds.create("ModeChanged", "command:*", blur);
glide.autocmds.create("ModeChanged", "command:*", focus_page);

glide.keymaps.set(
  "normal",
  "<Esc>",
  when_editing(
    async () => {
      // for <D-f> find in this page
      await glide.keys.send("<Esc>", { skip_mappings: true });

      // defocus the editable element
      await focus_page();
      // blur();
    },
    async () => {
      await glide.keys.send("<Esc>", { skip_mappings: true });

      // additional actions you want to perform on esc, like:
      await glide.excmds.execute("clear");
    },
  ),
);

glide.keymaps.set("normal", "gi", async () => {
  await glide.excmds.execute("focusinput last");
  if (!(await glide.ctx.is_editing())) {
    await glide.keys.send("gI");
  }
});

async function focus_page() {
  // HACK: defocus the editable element by focusing the address bar and then refocusing the page
  await glide.keys.send("<F6>", { skip_mappings: true });
  await sleep(100);
  // check insert mode for address bar
  if (glide.ctx.mode === "insert") {
    await glide.keys.send("<F6>", { skip_mappings: true });
  }
}

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function when_editing(
  editing_action: glide.ExcmdString | glide.KeymapCallback | null,
  non_editing_action: glide.ExcmdString | glide.KeymapCallback | null,
): glide.KeymapCallback {
  return async (props) => {
    const action = (await glide.ctx.is_editing())
      ? editing_action
      : non_editing_action;

    if (!action) return;

    if (typeof action === "string") {
      await glide.excmds.execute(action);
    } else {
      await action(props);
    }
  };
}

