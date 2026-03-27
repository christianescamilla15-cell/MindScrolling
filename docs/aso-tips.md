# MindScrolling -- ASO (App Store Optimization) Tips

---

## 1. Keyword Density Recommendations

### Title (30 chars max)
- "MindScrolling" is unique and brandable -- good for discoverability once established.
- The title alone does not contain generic keywords, so the short description must compensate.

### Short Description (80 chars max)
- Pack your top 2-3 keywords here: "scroll", "wisdom", "quotes".
- Google indexes the short description heavily. Every word counts.

### Full Description
- **Primary keywords** (use 3-5 times each): quotes, philosophy, wisdom, mindfulness, self-improvement
- **Secondary keywords** (use 2-3 times each): stoicism, motivation, daily quotes, reflection, personal growth
- **Long-tail phrases** (use 1-2 times each): anti-doom-scrolling, philosophical quotes app, swipe quotes, wisdom feed
- Place the most important keywords in the **first 3 lines** (the visible preview before "Read more").
- Avoid keyword stuffing. Google penalizes unnatural repetition. Aim for readable prose that naturally includes your terms.

### Keyword Research Tools
- Google Play Console's "Store listing experiments" (A/B test titles and descriptions)
- AppTweak, Sensor Tower, or Mobile Action for competitor keyword analysis
- Google Trends to validate search volume for terms like "philosophy quotes" vs "wisdom quotes"

---

## 2. Screenshot Best Practices

### Technical Specs
- **Phone:** 1080 x 1920 px minimum (16:9), recommended 1284 x 2778 px (iPhone 14 Pro Max size works for both stores)
- **Tablet (optional):** 2048 x 2732 px
- Upload 8 screenshots (the maximum) -- use all of them

### Design Guidelines
- **First 2 screenshots** are critical. They appear in search results. Lead with your strongest value proposition.
- Add **text captions** above or below the device frame. Keep them short (5-7 words max).
- Use **consistent brand colors** and typography across all screenshots.
- Show **real app content**, not placeholder data.
- Include a **device frame** (phone mockup) for professionalism.
- Use **contrasting background colors** between screenshots so they stand out when swiping in the store.

### Recommended Order
1. Hero shot with value proposition ("Scroll with purpose")
2. Core mechanic (4-direction swipe)
3. Social proof or stats ("13,000+ quotes")
4. Philosophy Map (unique differentiator)
5. Vault (utility)
6. Daily Challenge (engagement)
7. Dark mode (aesthetic appeal)
8. Premium (conversion)

### Tools
- Figma or Canva for screenshot mockups
- screenshots.pro or AppMockUp for device frames
- Use store listing experiments to A/B test screenshot order

---

## 3. Description Formatting Tips

### Structure for Readability
- Use **ALL CAPS headers** for section breaks (Google Play renders plain text, no markdown).
- Keep paragraphs to 2-3 sentences maximum.
- Use line breaks liberally. Walls of text kill conversion.
- Lead with a **hook question** ("What if every scroll made you wiser?").

### First 3 Lines Rule
- Google Play shows approximately 80-100 characters before the "Read more" fold.
- Your opening line must convey the core value proposition immediately.
- Do not waste the first line on your app name (it is already displayed above).

### Call to Action
- End with a clear CTA: "Download now and start scrolling with purpose."
- Mention the price model early to set expectations ("$4.99 one-time, no subscriptions").

### Localization
- Maintain separate, fully localized descriptions (not machine-translated).
- Adapt cultural references. Spanish-speaking audiences may respond differently to philosophical school names.
- Use Google Play Console's localization feature to manage EN and ES listings independently.

---

## 4. Review Strategy

### Launch Phase (First 30 Days)
- **Goal:** Reach 10-20 genuine reviews as fast as possible. Apps with fewer than 5 reviews have significantly lower conversion.
- Ask friends, family, and beta testers to leave honest reviews on Day 1.
- Focus on getting reviews that mention keywords naturally ("great philosophy quotes app").

### In-App Review Prompt
- Use the Google In-App Review API (`in_app_review` Flutter package).
- **When to trigger:** After a positive signal -- e.g., user saves 10th quote to Vault, completes 7-day streak, or finishes Daily Challenge.
- **When NOT to trigger:** On first open, after a crash, during onboarding, or more than once per 30 days.
- Never incentivize reviews (violates Play Store policy).

### Responding to Reviews
- Reply to every review within 48 hours, positive or negative.
- For negative reviews: acknowledge the issue, state what you are doing about it, invite them to email for direct support.
- For positive reviews: thank them and mention an upcoming feature to build anticipation.

### Long-Term
- Aim for a 4.5+ star average. Below 4.0 significantly hurts discoverability.
- Track review sentiment monthly. Common complaints should feed directly into your sprint backlog.

---

## 5. Update Frequency Recommendations

### Ideal Cadence
- **First 3 months:** Update every 2 weeks. Google rewards active development with better ranking.
- **After 3 months:** Monthly updates minimum.
- **Ongoing:** Never go longer than 6 weeks without an update.

### What Counts as an Update
- New features (even small ones)
- Bug fixes
- Content additions (new quote packs)
- Performance improvements
- Localization additions

### Update Strategy
- Each update is an opportunity to change your "What's new" text -- use it to re-engage lapsed users via notifications.
- Stagger feature releases. Ship one improvement per update rather than batching. This gives you more frequent updates and more "What's new" cycles.
- Coordinate updates with marketing pushes (social media, blog posts).

---

## 6. Additional ASO Factors

### Feature Graphic
- **Size:** 1024 x 500 px
- This is the banner shown at the top of your store listing. Make it eye-catching.
- Include app name, tagline, and a visual hint of the app experience.
- Do not include text smaller than 24px -- it will not be readable on phone screens.

### App Icon
- Test your icon at 16x16 px. If it is not recognizable at that size, simplify it.
- Avoid text in the icon (too small to read in search results).
- Use bold colors that stand out against both light and dark backgrounds.

### Video (Optional but Recommended)
- YouTube link, 30 seconds to 2 minutes.
- Show the app in use within the first 5 seconds.
- Include captions (many users browse with sound off).
- Landscape orientation recommended.

### Install Size
- Keep the APK/AAB under 50 MB. Larger apps have higher abandonment during download, especially in markets with slower connections.

### Crash Rate
- Google uses Android Vitals (ANR rate, crash rate) as a ranking signal.
- Target: less than 1% crash rate, less than 0.5% ANR rate.
- Monitor Firebase Crashlytics from day one.
