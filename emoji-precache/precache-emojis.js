#!/usr/bin/env node

"use strict";

const fs = require("fs");
const https = require("https");
const path = require("path");
const shell = require("shelljs");
const twemoji = require("twemoji");

const EMOJI_DIR = path.resolve(__dirname, "assets/emojis");
const NOTO_INDEX_URL = "https://api.github.com/repos/googlefonts/noto-emoji/git/trees/main?recursive=1";
const NOTO_BASE = "https://raw.githubusercontent.com/googlefonts/noto-emoji/main/svg/";

const ALL_EMOJIS = [...new Set(
  // Sample full string of emojis to cover most of Unicode
  "😀😃😄😁😆😅😂🤣😊😇🙂🙃😉😌😍🥰😘😗😙😚😋😛😝😜🤪🤨🧐🤓😎🥸🤩🥳😏😒😞😔😟😕🙁☹️😣😖😫😩🥺😢😭😤😠😡🤬🤯😳🥵🥶😱😨😰😥😓🤗🤔🤭🤫🤥😶😐🫡🫥😑😬🫨🙄😯😦😧😮😲🥱😴🤤😪😵😵‍💫🤐🫠🫢🫣🤢🤮🤧😷🤒🤕🤑😈👿"
)].join("")  // Can be extended arbitrarily
;

const inkscape = shell.which("inkscape");
if (!inkscape) {
  console.error("❌ Inkscape not found in PATH.");
  process.exit(1);
}

function ensureDirSync(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

async function download(url, dest) {
  if (fs.existsSync(dest)) return;
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    https.get(url, (res) => {
      if (res.statusCode !== 200) return reject(new Error(`HTTP ${res.statusCode} for ${url}`));
      res.pipe(file);
      file.on("finish", () => file.close(resolve));
    }).on("error", (err) => {
      fs.unlink(dest, () => {});
      reject(err);
    });
  });
}

function convertToPdf(svgPath) {
  const pdfPath = svgPath.replace(/\.svg$/, ".pdf");
  if (fs.existsSync(pdfPath)) return;
  shell.exec(`"${inkscape}" --export-type=pdf "${svgPath}"`, { silent: true });
}

async function fetchNotoList() {
  return new Promise((resolve, reject) => {
    https.get(NOTO_INDEX_URL, {
      headers: { "User-Agent": "node" }
    }, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => {
        try {
          const files = JSON.parse(data).tree
            .filter(f => f.path.startsWith("svg/emoji_u") && f.path.endsWith(".svg"))
            .map(f => f.path.replace("svg/", ""));
          resolve(files);
        } catch (err) {
          reject(err);
        }
      });
    }).on("error", reject);
  });
}

function extractTwemojiUrls(emojiStr) {
  const urls = new Set();
  twemoji.parse(emojiStr, {
    folder: "svg",
    ext: ".svg",
    callback: (icon, options, variant) => {
      urls.add(`https://twemoji.maxcdn.com/v/latest/svg/${icon}.svg`);
      return "";
    }
  });
  return [...urls];
}

(async () => {
  ensureDirSync(EMOJI_DIR);

  // 1. TWEMOJI
  console.log("📥 Fetching Twemoji emoji URLs...");
  const twemojiUrls = extractTwemojiUrls(ALL_EMOJIS);
  console.log(`🔤 ${twemojiUrls.length} Twemoji emojis to process.`);

  let count = 0;
  for (const url of twemojiUrls) {
    const filename = url.split("/").pop();
    const name = filename.replace(".svg", "");
    const svgPath = path.join(EMOJI_DIR, `twemoji_${name}.svg`);

    try {
      process.stdout.write(`⬇️  [Twemoji ${++count}/${twemojiUrls.length}] ${filename}... `);
      await download(url, svgPath);
      convertToPdf(svgPath);
      console.log("✅");
    } catch (e) {
      console.warn(`❌ Failed ${filename}: ${e.message}`);
    }
  }

  // 2. NOTO
  console.log("📥 Fetching Noto emoji index...");
  const notoFiles = await fetchNotoList();
  console.log(`🗂️ ${notoFiles.length} Noto emojis to process.`);

  count = 0;
  for (const file of notoFiles) {
    const base = path.basename(file);
    const name = base.replace(/^emoji_u/, "").replace(/[^a-zA-Z0-9]/g, "_").replace(".svg", "");
    const svgPath = path.join(EMOJI_DIR, `noto_${name}.svg`);
    const url = NOTO_BASE + file;

    try {
      process.stdout.write(`⬇️  [Noto ${++count}/${notoFiles.length}] ${base}... `);
      await download(url, svgPath);
      convertToPdf(svgPath);
      console.log("✅");
    } catch (e) {
      console.warn(`❌ Failed ${base}: ${e.message}`);
    }
  }

  console.log("🎉 Emoji cache complete. All SVGs and PDFs are in: assets/emojis/");
})();

