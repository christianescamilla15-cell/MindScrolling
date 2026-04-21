// Canvas-based quote image export utility

const CATEGORY_COLORS = {
  philosophy: "#F59E0B",
  stoicism:   "#14B8A6",
  discipline: "#F97316",
  reflection: "#A78BFA",
};

/**
 * Wraps text within a given max width, returning an array of lines.
 */
function wrapText(ctx, text, maxWidth) {
  const words = text.split(" ");
  const lines = [];
  let current = "";

  for (const word of words) {
    const test = current ? `${current} ${word}` : word;
    if (ctx.measureText(test).width > maxWidth && current) {
      lines.push(current);
      current = word;
    } else {
      current = test;
    }
  }
  if (current) lines.push(current);
  return lines;
}

/**
 * Exports a quote as a 1080x1080 PNG image and triggers a download.
 * @param {Object} quote - { text, author, category }
 */
export async function exportQuoteImage(quote) {
  const SIZE = 1080;
  const PADDING = 90;
  const ACCENT_BAR_WIDTH = 6;
  const ACCENT_BAR_HEIGHT = 200;

  const canvas = document.createElement("canvas");
  canvas.width = SIZE;
  canvas.height = SIZE;
  const ctx = canvas.getContext("2d");

  // Background: dark gradient
  const bg = ctx.createLinearGradient(0, 0, SIZE, SIZE);
  bg.addColorStop(0, "#0f0f13");
  bg.addColorStop(1, "#1a1a21");
  ctx.fillStyle = bg;
  ctx.fillRect(0, 0, SIZE, SIZE);

  // Subtle radial glow at bottom
  const accentColor = CATEGORY_COLORS[quote.category] || "#14B8A6";
  const glow = ctx.createRadialGradient(SIZE / 2, SIZE, 0, SIZE / 2, SIZE, SIZE * 0.7);
  glow.addColorStop(0, `${accentColor}22`);
  glow.addColorStop(1, "transparent");
  ctx.fillStyle = glow;
  ctx.fillRect(0, 0, SIZE, SIZE);

  // Left accent bar
  const barY = (SIZE - ACCENT_BAR_HEIGHT) / 2;
  ctx.fillStyle = accentColor;
  ctx.beginPath();
  ctx.roundRect(PADDING, barY, ACCENT_BAR_WIDTH, ACCENT_BAR_HEIGHT, 3);
  ctx.fill();

  // Opening quote mark
  ctx.fillStyle = `${accentColor}cc`;
  ctx.font = `italic 140px 'Georgia', serif`;
  ctx.textAlign = "left";
  ctx.fillText("\u201C", PADDING + 30, SIZE / 2 - 60);

  // Quote text (multi-line, serif italic)
  const textX = PADDING + 30;
  const textMaxWidth = SIZE - textX - PADDING;
  ctx.font = `italic 52px 'Georgia', serif`;
  ctx.fillStyle = "#F5F0E8";
  ctx.textAlign = "left";

  const lines = wrapText(ctx, quote.text, textMaxWidth);
  const lineHeight = 74;
  const totalTextHeight = lines.length * lineHeight;

  // Vertically center the text block (roughly)
  let textY = (SIZE - totalTextHeight) / 2 - 20;
  // Clamp so we don't go too high
  if (textY < SIZE * 0.28) textY = SIZE * 0.28;

  for (let i = 0; i < lines.length; i++) {
    ctx.fillText(lines[i], textX, textY + i * lineHeight);
  }

  // Closing quote mark
  const lastLineY = textY + (lines.length - 1) * lineHeight;
  ctx.fillStyle = `${accentColor}cc`;
  ctx.font = `italic 140px 'Georgia', serif`;
  const lastLineWidth = ctx.measureText(lines[lines.length - 1]).width;
  // Closing quote only if it fits, otherwise at end of last line
  const closeQuoteX = Math.min(textX + lastLineWidth + 8, SIZE - PADDING - 80);
  ctx.fillText("\u201D", closeQuoteX, lastLineY + 20);

  // Divider line
  const dividerY = lastLineY + 56;
  ctx.strokeStyle = `${accentColor}66`;
  ctx.lineWidth = 1.5;
  ctx.beginPath();
  ctx.moveTo(textX, dividerY);
  ctx.lineTo(textX + 60, dividerY);
  ctx.stroke();

  // Author
  ctx.font = `500 34px 'Arial', sans-serif`;
  ctx.fillStyle = "rgba(255,255,255,0.45)";
  ctx.textAlign = "left";
  ctx.fillText(`\u2014 ${quote.author}`, textX, dividerY + 44);

  // "MindScroll" watermark bottom right
  ctx.font = `400 24px 'Arial', sans-serif`;
  ctx.fillStyle = "rgba(255,255,255,0.15)";
  ctx.textAlign = "right";
  ctx.fillText("MindScroll", SIZE - PADDING, SIZE - PADDING);

  // Trigger download
  canvas.toBlob((blob) => {
    if (!blob) return;
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "mindscroll-quote.png";
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    setTimeout(() => URL.revokeObjectURL(url), 10000);
  }, "image/png");
}
