#!/usr/bin/env node

/**
 * Pandoc filter to replace emoji text with inline PDF images
 * using pre-cached emoji PDFs stored in assets/emojis/
 * 
 * This is meant for LaTeX output (PDF generation).
 */

"use strict";

const pandoc = require("pandoc-filter");
const fs = require("fs");
const path = require("path");

const EMOJI_DIR = path.resolve(__dirname, "assets/emojis");

/**
 * Converts an emoji character into its Twemoji-style codepoint name.
 * e.g. 👨‍👩‍👧‍👦 => "1f468_200d_1f469_200d_1f467_200d_1f466"
 */
function emojiToFilename(emoji) {
  return [...emoji].map(c => c.codePointAt(0).toString(16)).join("_");
}

/**
 * Check if a cached emoji PDF exists, return full path
 */
function resolveEmojiPdfPath(codepoint) {
  const variants = [
    `twemoji_${codepoint}.pdf`,
    `noto_${codepoint}.pdf`
  ];
  for (const name of variants) {
    const full = path.join(EMOJI_DIR, name);
    if (fs.existsSync(full)) return full;
  }
  return null;
}

/**
 * Replace emoji characters with inline image nodes
 */
function replaceEmojis(text, format) {
  const result = [];

  // Match emoji using Unicode regex
  const regex = /\p{Emoji_Presentation}|\p{Extended_Pictographic}/gu;
  let lastIndex = 0;

  for (const match of text.matchAll(regex)) {
    const index = match.index;
    const emoji = match[0];

    if (index > lastIndex) {
      result.push(pandoc.Str(text.slice(lastIndex, index)));
    }

    const codepoint = emojiToFilename(emoji);
    const filePath = resolveEmojiPdfPath(codepoint);

    if (filePath && format === "latex") {
      const latex = `\\includegraphics[height=1em]{${filePath.replace(/\\/g, "/")}}`;
      result.push(pandoc.RawInline("latex", latex));
    } else {
      // Fallback to raw emoji if PDF not found or format is not LaTeX
      result.push(pandoc.Str(emoji));
    }

    lastIndex = index + emoji.length;
  }

  if (lastIndex < text.length) {
    result.push(pandoc.Str(text.slice(lastIndex)));
  }

  return result;
}

// Main filter
function action({ t: type, c }, format) {
  if (type === "Str") {
    return replaceEmojis(c, format);
  }
}

pandoc.stdio(action);

