-- 035_science_tech_en.sql
-- MindScrolling — Science Mode: Technology batch (English)
-- 250 quotes: computing, AI, internet, robotics, space tech, biotech, nanotech,
--   renewable energy, digital revolution, innovation, automation, cybersecurity,
--   VR, blockchain, IoT, machine learning, cloud computing
--
-- All rows:
--   category       = 'philosophy'
--   lang           = 'en'
--   swipe_dir      = 'down'
--   pack_name      = 'free'
--   is_premium     = false
--   content_type   = 'science'
--   sub_category   = 'technology'
--   is_hidden_mode = true
--   locked_by      = 'science'
-- Run in Supabase SQL Editor

BEGIN;

-- ══════════════════════════════════════════════════════════════════════════════
-- TECHNOLOGY — ENGLISH (250 quotes)
-- ══════════════════════════════════════════════════════════════════════════════

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by) VALUES

-- Alan Turing (1–12)
(gen_random_uuid(), 'We can only see a short distance ahead, but we can see plenty there that needs to be done.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'A computer would deserve to be called intelligent if it could deceive a human into believing it was human.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Sometimes it is the people no one imagines anything of who do the things that no one can imagine.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','perseverance'], true, 'science'),
(gen_random_uuid(), 'Those who can imagine anything can create the impossible.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','curiosity'], true, 'science'),
(gen_random_uuid(), 'The question is not whether machines can think, but whether men do.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Science is a differential equation. Religion is a boundary condition.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Mathematical reasoning may be regarded as the exercise of a combination of ingenuity and patience.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'If a machine is expected to be infallible, it cannot also be intelligent.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The original question, can machines think, is too meaningless to deserve discussion.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'I''m not after a powerful brain — just a mediocre one, something like the President of AT&T.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','humor'], true, 'science'),
(gen_random_uuid(), 'We are not interested in the fact that the brain has the consistency of cold porridge.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'A computer is not intelligent unless it can imitate human thought.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','logic'], true, 'science'),

-- Ada Lovelace (13–22)
(gen_random_uuid(), 'The analytical engine weaves algebraical patterns just as the Jacquard loom weaves flowers and leaves.', 'Ada Lovelace', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','curiosity'], true, 'science'),
(gen_random_uuid(), 'I am in a charming state of confusion.', 'Ada Lovelace', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'That brain of mine is something more than merely mortal, as time will show.', 'Ada Lovelace', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','perseverance'], true, 'science'),
(gen_random_uuid(), 'Mathematical science shows what is. It is the language of unseen relations between things.', 'Ada Lovelace', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The engine can arrange and combine its numerical quantities exactly as if they were letters or any other general symbols.', 'Ada Lovelace', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Imagination is the Discovering Faculty, pre-eminently. It is that which penetrates into the unseen worlds around us.', 'Ada Lovelace', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','curiosity'], true, 'science'),
(gen_random_uuid(), 'The more I study, the more insatiable do I feel my genius for it to be.', 'Ada Lovelace', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'I am never satisfied that I understand anything; my comprehension is an infinitesimal fraction of all I want to understand.', 'Ada Lovelace', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The science of operations is the science of everything.', 'Ada Lovelace', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'I do not believe that my father was such a poet as I shall be an analyst.', 'Ada Lovelace', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','perseverance'], true, 'science'),

-- Nikola Tesla (23–32)
(gen_random_uuid(), 'The present is theirs; the future, for which I really worked, is mine.', 'Nikola Tesla', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['perseverance','wisdom'], true, 'science'),
(gen_random_uuid(), 'If you want to find the secrets of the universe, think in terms of energy, frequency and vibration.', 'Nikola Tesla', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The day science studies non-physical phenomena, it will make more progress in a decade than in all previous centuries.', 'Nikola Tesla', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'Our virtues and our failings are inseparable, like force and matter. When they separate, man is no more.', 'Nikola Tesla', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['wisdom','reflection'], true, 'science'),
(gen_random_uuid(), 'No thrill can match what the inventor feels watching a creation of the mind unfold into success.', 'Nikola Tesla', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','curiosity'], true, 'science'),
(gen_random_uuid(), 'Be alone, that is the secret of invention; be alone, that is when ideas are born.', 'Nikola Tesla', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','focus'], true, 'science'),
(gen_random_uuid(), 'Of all the frictional resistances, the one that most retards human movement is ignorance.', 'Nikola Tesla', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'Today''s scientists think deeply instead of clearly. One must be sane to think clearly, but one can think deeply and be insane.', 'Nikola Tesla', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'What one man calls God, another calls the laws of physics.', 'Nikola Tesla', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'Every living being is an engine geared to the wheelwork of the universe.', 'Nikola Tesla', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),

-- Steve Jobs (33–44)
(gen_random_uuid(), 'Innovation distinguishes between a leader and a follower.', 'Steve Jobs', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','leadership'], true, 'science'),
(gen_random_uuid(), 'Technology is nothing. What''s important is that you have a faith in people, that they''re basically good and smart.', 'Steve Jobs', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['wisdom','leadership'], true, 'science'),
(gen_random_uuid(), 'The people who are crazy enough to think they can change the world are the ones who do.', 'Steve Jobs', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','perseverance'], true, 'science'),
(gen_random_uuid(), 'Work fills a large part of life. The only way to be truly satisfied is to do what you believe is great work.', 'Steve Jobs', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','perseverance'], true, 'science'),
(gen_random_uuid(), 'Stay hungry, stay foolish.', 'Steve Jobs', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','perseverance'], true, 'science'),
(gen_random_uuid(), 'I want to put a ding in the universe.', 'Steve Jobs', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','perseverance'], true, 'science'),
(gen_random_uuid(), 'The computer is the most remarkable tool that we''ve ever come up with. It''s the equivalent of a bicycle for our minds.', 'Steve Jobs', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','curiosity'], true, 'science'),
(gen_random_uuid(), 'Creativity is just connecting things.', 'Steve Jobs', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Quality is more important than quantity. One home run is much better than two doubles.', 'Steve Jobs', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','wisdom'], true, 'science'),
(gen_random_uuid(), 'We''re just enthusiastic about what we do.', 'Steve Jobs', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','focus'], true, 'science'),
(gen_random_uuid(), 'Real artists ship.', 'Steve Jobs', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','perseverance'], true, 'science'),
(gen_random_uuid(), 'Details matter, it''s worth waiting to get it right.', 'Steve Jobs', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','wisdom'], true, 'science'),

-- Bill Gates (45–54)
(gen_random_uuid(), 'Information technology and business are becoming inextricably interwoven.', 'Bill Gates', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'The internet is becoming the town square for the global village of tomorrow.', 'Bill Gates', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'We overestimate change in two years and underestimate change in ten.', 'Bill Gates', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Software is a great combination between artistry and engineering.', 'Bill Gates', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','curiosity'], true, 'science'),
(gen_random_uuid(), 'Intellectual property has the shelf life of a banana.', 'Bill Gates', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'If you can''t make it good, at least make it look good.', 'Bill Gates', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','wisdom'], true, 'science'),
(gen_random_uuid(), 'In this business, by the time you realize you''re in trouble, it''s too late to save yourself.', 'Bill Gates', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['wisdom','perseverance'], true, 'science'),
(gen_random_uuid(), 'Your most unhappy customers are your greatest source of learning.', 'Bill Gates', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['learning','wisdom'], true, 'science'),
(gen_random_uuid(), 'Success is a lousy teacher. It seduces smart people into thinking they can''t lose.', 'Bill Gates', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['wisdom','reflection'], true, 'science'),
(gen_random_uuid(), 'Be nice to nerds. Chances are you''ll end up working for one.', 'Bill Gates', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),

-- Elon Musk (55–66)
(gen_random_uuid(), 'When something is important enough, you do it even if the odds are not in your favor.', 'Elon Musk', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['perseverance','courage'], true, 'science'),
(gen_random_uuid(), 'The first step is to establish that something is possible; then probability will occur.', 'Elon Musk', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','perseverance'], true, 'science'),
(gen_random_uuid(), 'A feedback loop is critical — constantly reflect on what you''ve done and how you could do it better.', 'Elon Musk', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'Persistence is very important. You should not give up unless you are forced to give up.', 'Elon Musk', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['perseverance','focus'], true, 'science'),
(gen_random_uuid(), 'If something is important enough, even if the odds are stacked against you, you should still do it.', 'Elon Musk', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','perseverance'], true, 'science'),
(gen_random_uuid(), 'You want to be extra rigorous about making the best possible thing you can. Find everything that''s wrong with it and fix it.', 'Elon Musk', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','perseverance'], true, 'science'),
(gen_random_uuid(), 'I could either watch it happen or be a part of it.', 'Elon Musk', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','perseverance'], true, 'science'),
(gen_random_uuid(), 'Failure is an option here. If things are not failing, you are not innovating enough.', 'Elon Musk', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','perseverance'], true, 'science'),
(gen_random_uuid(), 'It''s OK to have your eggs in one basket as long as you control what happens to that basket.', 'Elon Musk', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','wisdom'], true, 'science'),
(gen_random_uuid(), 'Work like hell. I mean you just have to put in 80 to 100 hour weeks every week.', 'Elon Musk', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','perseverance'], true, 'science'),
(gen_random_uuid(), 'The path to the CEO''s office should run through engineering and design, not finance or marketing.', 'Elon Musk', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'I think we are at the dawn of a new era in commercial space exploration.', 'Elon Musk', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','perseverance'], true, 'science'),

-- Tim Berners-Lee (67–76)
(gen_random_uuid(), 'The web does not just connect machines, it connects people.', 'Tim Berners-Lee', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'We need diversity of thought in the world to face the new challenges.', 'Tim Berners-Lee', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'The web is more a social creation than a technical one. I designed it for a social effect — to help people work together.', 'Tim Berners-Lee', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Data is a precious thing and will last longer than the systems themselves.', 'Tim Berners-Lee', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The web was meant to be a collaborative space for communication through shared information.', 'Tim Berners-Lee', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'Anyone who has lost track of time when using a computer knows the flow state.', 'Tim Berners-Lee', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','focus'], true, 'science'),
(gen_random_uuid(), 'I want the web to reflect our hopes, not just our fears.', 'Tim Berners-Lee', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','wisdom'], true, 'science'),
(gen_random_uuid(), 'The domain of ignorance is still very, very large.', 'Tim Berners-Lee', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'Openness and sharing knowledge is what drives the web.', 'Tim Berners-Lee', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'The web is for everyone and collectively we hold the power to change it.', 'Tim Berners-Lee', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','wisdom'], true, 'science'),

-- Grace Hopper (77–86)
(gen_random_uuid(), 'The most dangerous phrase in the language is, we''ve always done it this way.', 'Grace Hopper', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','wisdom'], true, 'science'),
(gen_random_uuid(), 'A ship in port is safe, but that''s not what ships are for.', 'Grace Hopper', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','perseverance'], true, 'science'),
(gen_random_uuid(), 'Humans are allergic to change. They love to say, we''ve always done it this way.', 'Grace Hopper', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','wisdom'], true, 'science'),
(gen_random_uuid(), 'Leadership is a two-way street, loyalty up and loyalty down.', 'Grace Hopper', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['leadership','wisdom'], true, 'science'),
(gen_random_uuid(), 'You manage things; you lead people.', 'Grace Hopper', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['leadership','wisdom'], true, 'science'),
(gen_random_uuid(), 'One accurate measurement is worth a thousand expert opinions.', 'Grace Hopper', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'If it''s a good idea, go ahead and do it. It is much easier to apologize than it is to get permission.', 'Grace Hopper', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','perseverance'], true, 'science'),
(gen_random_uuid(), 'I had a running compiler and nobody would touch it. They told me computers could only do arithmetic.', 'Grace Hopper', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','perseverance'], true, 'science'),
(gen_random_uuid(), 'We flood people with information. A human must turn that information into intelligence or knowledge.', 'Grace Hopper', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The most important thing I''ve accomplished, other than building the compiler, is training young people.', 'Grace Hopper', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['learning','wisdom'], true, 'science'),

-- Ray Kurzweil (87–96)
(gen_random_uuid(), 'The Singularity Is Near.', 'Ray Kurzweil', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'We are the only species that seeks to understand itself.', 'Ray Kurzweil', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'Artificial intelligence will reach human levels by around 2029.', 'Ray Kurzweil', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'The pace of technological change is exponential, not linear.', 'Ray Kurzweil', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Information technology understands biology ever more deeply — and biology itself is becoming an information technology.', 'Ray Kurzweil', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'We will successfully reverse-engineer the human brain within the next 25 years.', 'Ray Kurzweil', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','perseverance'], true, 'science'),
(gen_random_uuid(), 'Death is a great injustice, and I think we have the tools now to overcome it.', 'Ray Kurzweil', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','curiosity'], true, 'science'),
(gen_random_uuid(), 'Technology is the continuation of evolution by other means.', 'Ray Kurzweil', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The future will be far more surprising than most observers realize.', 'Ray Kurzweil', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Intelligence is the most powerful force in the universe.', 'Ray Kurzweil', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),

-- Arthur C. Clarke (97–106)
(gen_random_uuid(), 'Any sufficiently advanced technology is indistinguishable from magic.', 'Arthur C. Clarke', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The only way of discovering the limits of the possible is to venture a little way past them into the impossible.', 'Arthur C. Clarke', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','curiosity'], true, 'science'),
(gen_random_uuid(), 'I don''t believe in astrology; I''m a Sagittarius and we''re skeptical.', 'Arthur C. Clarke', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'When an elderly scientist says something is possible, he is right. When he says it is impossible, he is probably wrong.', 'Arthur C. Clarke', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The greatest tragedy in mankind''s entire history may be the hijacking of morality by religion.', 'Arthur C. Clarke', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'Two possibilities exist: either we are alone in the Universe or we are not. Both are equally terrifying.', 'Arthur C. Clarke', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'Reading computer manuals without the hardware is as frustrating as reading sex manuals without the software.', 'Arthur C. Clarke', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','humor'], true, 'science'),
(gen_random_uuid(), 'The Information Age offers much to mankind, and I would like to think that we will rise to the challenges it presents.', 'Arthur C. Clarke', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'New ideas pass through three stages: impossible, not worth doing, and I knew it was a good idea all along.', 'Arthur C. Clarke', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','perseverance'], true, 'science'),
(gen_random_uuid(), 'Before you become entranced by gadgets and screens, remember that information is not knowledge.', 'Arthur C. Clarke', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),

-- Isaac Asimov (107–116)
(gen_random_uuid(), 'The true delight is in the finding out rather than in the knowing.', 'Isaac Asimov', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Science introduced poorly to children can turn them away from it for life. How we teach matters enormously.', 'Isaac Asimov', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'The saddest aspect of life right now is that science gathers knowledge faster than society gathers wisdom.', 'Isaac Asimov', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Violence is the last refuge of the incompetent.', 'Isaac Asimov', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['wisdom','reflection'], true, 'science'),
(gen_random_uuid(), 'It is not so much where my motivation comes from but rather how it manages to survive.', 'Isaac Asimov', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['perseverance','reflection'], true, 'science'),
(gen_random_uuid(), 'Humanity''s future among the stars is too important to be lost to folly and superstition.', 'Isaac Asimov', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Any planet is Earth to those that live on it.', 'Isaac Asimov', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'The core of science fiction — its essence — has become crucial to human survival, whatever the critics may say.', 'Isaac Asimov', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','wisdom'], true, 'science'),
(gen_random_uuid(), 'To insult someone we call him bestial. For deliberate cruelty and nature, human might be the greater insult.', 'Isaac Asimov', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['reflection','wisdom'], true, 'science'),
(gen_random_uuid(), 'Life is pleasant. Death is peaceful. It''s the transition that''s troublesome.', 'Isaac Asimov', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['reflection','wisdom'], true, 'science'),

-- Marshall McLuhan (117–126)
(gen_random_uuid(), 'The medium is the message.', 'Marshall McLuhan', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The new electronic interdependence recreates the world in the image of a global village.', 'Marshall McLuhan', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'We look at the present through a rear-view mirror. We march backwards into the future.', 'Marshall McLuhan', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'The name of a man is a numbing blow from which he never recovers.', 'Marshall McLuhan', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['reflection','wisdom'], true, 'science'),
(gen_random_uuid(), 'Societies are shaped more by the nature of their media than by the content communicated through them.', 'Marshall McLuhan', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Art is anything you can get away with.', 'Marshall McLuhan', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','wisdom'], true, 'science'),
(gen_random_uuid(), 'All media exist to invest our lives with artificial perceptions and arbitrary values.', 'Marshall McLuhan', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'Advertising is the greatest art form of the twentieth century.', 'Marshall McLuhan', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','curiosity'], true, 'science'),
(gen_random_uuid(), 'Money is the poor man''s credit card.', 'Marshall McLuhan', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Publication is a self-invasion of privacy.', 'Marshall McLuhan', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['reflection','wisdom'], true, 'science'),

-- Buckminster Fuller (127–136)
(gen_random_uuid(), 'To change something, build a new model that makes the existing model obsolete.', 'Buckminster Fuller', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','wisdom'], true, 'science'),
(gen_random_uuid(), 'I am a passenger on the spaceship Earth.', 'Buckminster Fuller', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'Dare to be naive.', 'Buckminster Fuller', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','curiosity'], true, 'science'),
(gen_random_uuid(), 'Either war is obsolete or men are.', 'Buckminster Fuller', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','wisdom'], true, 'science'),
(gen_random_uuid(), 'There is nothing in a caterpillar that tells you it''s going to be a butterfly.', 'Buckminster Fuller', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Teach children that the sun does not rise and set — it is the Earth that revolves around the sun.', 'Buckminster Fuller', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'We are called to be architects of the future, not its victims.', 'Buckminster Fuller', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','perseverance'], true, 'science'),
(gen_random_uuid(), 'God, to me, it seems, is a verb, not a noun.', 'Buckminster Fuller', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'Do more and more with less and less until eventually you can do everything with nothing.', 'Buckminster Fuller', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Nature is trying very hard to make us succeed, but nature does not depend on us. We are not the only experiment.', 'Buckminster Fuller', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),

-- Vint Cerf (137–144)
(gen_random_uuid(), 'The internet is a reflection of our society and that mirror is going to be reflecting what we see.', 'Vint Cerf', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'The internet is for everyone.', 'Vint Cerf', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The internet is the world''s largest library. It''s just that all the books are on the floor.', 'Vint Cerf', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','humor'], true, 'science'),
(gen_random_uuid(), 'I want to see the internet be a successful platform for communication, collaboration, and creativity.', 'Vint Cerf', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','curiosity'], true, 'science'),
(gen_random_uuid(), 'Access to the internet really is a basic right for people.', 'Vint Cerf', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','wisdom'], true, 'science'),
(gen_random_uuid(), 'Privacy is a component of freedom. It''s a component of democracy.', 'Vint Cerf', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','wisdom'], true, 'science'),
(gen_random_uuid(), 'Technology changes rapidly but people change slowly.', 'Vint Cerf', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The packet-switching idea was just the internet''s first surprise — there were many more to come.', 'Vint Cerf', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),

-- Marc Andreessen (145–152)
(gen_random_uuid(), 'Software is eating the world.', 'Marc Andreessen', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'In a world where everything connects, context is king.', 'Marc Andreessen', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The internet is the great equalizer.', 'Marc Andreessen', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Computers split jobs in two: those who tell computers what to do, and those who are told by computers what to do.', 'Marc Andreessen', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'I''m a huge optimist. I think the future is going to be better than most people think.', 'Marc Andreessen', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','perseverance'], true, 'science'),
(gen_random_uuid(), 'The amount of energy necessary to refute bullshit is an order of magnitude bigger than to produce it.', 'Marc Andreessen', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Product market fit means being in a good market with a product that can satisfy that market.', 'Marc Andreessen', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','wisdom'], true, 'science'),
(gen_random_uuid(), 'The thing I have learned at Netscape is that companies need to start building their next-generation products on the web.', 'Marc Andreessen', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),

-- Jeff Bezos (153–162)
(gen_random_uuid(), 'If you double the number of experiments you do per year you''re going to double your inventiveness.', 'Jeff Bezos', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','curiosity'], true, 'science'),
(gen_random_uuid(), 'We are stubborn on vision. We are flexible on details.', 'Jeff Bezos', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','perseverance'], true, 'science'),
(gen_random_uuid(), 'Work hard, have fun, make history.', 'Jeff Bezos', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','perseverance'], true, 'science'),
(gen_random_uuid(), 'A brand for a company is like a reputation for a person. You earn reputation by trying to do hard things well.', 'Jeff Bezos', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','wisdom'], true, 'science'),
(gen_random_uuid(), 'Your margin is my opportunity.', 'Jeff Bezos', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','wisdom'], true, 'science'),
(gen_random_uuid(), 'It''s not an experiment if you know it''s going to work.', 'Jeff Bezos', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'I knew that if I failed I wouldn''t regret that, but I knew the one thing I might regret is not trying.', 'Jeff Bezos', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','perseverance'], true, 'science'),
(gen_random_uuid(), 'One of the only ways to get out of a tight box is to invent your way out.', 'Jeff Bezos', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','perseverance'], true, 'science'),
(gen_random_uuid(), 'If you never want to be criticized, for goodness''s sake don''t do anything new.', 'Jeff Bezos', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','perseverance'], true, 'science'),
(gen_random_uuid(), 'Three ideas drive Amazon: put the customer first, invent, and be patient.', 'Jeff Bezos', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','wisdom'], true, 'science'),

-- Satya Nadella (163–170)
(gen_random_uuid(), 'Our industry does not respect tradition — it only respects innovation.', 'Satya Nadella', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Don''t be a know-it-all, be a learn-it-all.', 'Satya Nadella', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'The key to innovation is the quality of the questions you ask.', 'Satya Nadella', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','curiosity'], true, 'science'),
(gen_random_uuid(), 'Every company is a software company. You have to start thinking and operating like a digital company.', 'Satya Nadella', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Clarity, energy, and success will come when you are in touch with what makes you, you.', 'Satya Nadella', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','reflection'], true, 'science'),
(gen_random_uuid(), 'Culture eats strategy for breakfast.', 'Satya Nadella', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['leadership','wisdom'], true, 'science'),
(gen_random_uuid(), 'We need to build empathy with customers and partners.', 'Satya Nadella', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'To innovate, you have to be willing to fail publicly.', 'Satya Nadella', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','perseverance'], true, 'science'),

-- Sundar Pichai (171–178)
(gen_random_uuid(), 'A happy person is not happy because everything is right, but because their attitude toward everything is right.', 'Sundar Pichai', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['reflection','wisdom'], true, 'science'),
(gen_random_uuid(), 'Wear your failure as a badge of honor.', 'Sundar Pichai', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','perseverance'], true, 'science'),
(gen_random_uuid(), 'I''ve always been optimistic about India''s potential to be a leader in technology.', 'Sundar Pichai', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Wear your failure as a badge of honor. Failure is the foundation of innovation.', 'Sundar Pichai', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','perseverance'], true, 'science'),
(gen_random_uuid(), 'Computing is not about computers any more. It is about living.', 'Sundar Pichai', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'I think AI is one of the most important things humanity is working on.', 'Sundar Pichai', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'Technology doesn''t have a plan. People have plans. Technology amplifies those plans.', 'Sundar Pichai', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Mobile is the future, and there''s no such thing as communication overload if the communication is relevant.', 'Sundar Pichai', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),

-- Tim Cook (179–186)
(gen_random_uuid(), 'The sidelines are not where you want to live your life. The world needs you in the arena.', 'Tim Cook', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','perseverance'], true, 'science'),
(gen_random_uuid(), 'Be a yardstick of quality. Some people aren''t used to an environment where excellence is expected.', 'Tim Cook', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','wisdom'], true, 'science'),
(gen_random_uuid(), 'I''m a big believer that opportunity can be created. You don''t have to sit around and wait for it.', 'Tim Cook', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','perseverance'], true, 'science'),
(gen_random_uuid(), 'We are at the beginning of a massive change in how people interact with technology.', 'Tim Cook', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Privacy is a fundamental human right and a core value.', 'Tim Cook', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','wisdom'], true, 'science'),
(gen_random_uuid(), 'Do you know what the most important skill of the 21st century is? It is the ability to learn new skills.', 'Tim Cook', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'Creativity is the most powerful force in the universe.', 'Tim Cook', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Open this door and you''ll find a place where technology and the liberal arts intersect.', 'Tim Cook', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','curiosity'], true, 'science'),

-- Larry Page (187–194)
(gen_random_uuid(), 'If you''re not doing some things that are crazy, then you''re doing the wrong things.', 'Larry Page', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','courage'], true, 'science'),
(gen_random_uuid(), 'Especially in technology, we need revolutionary change, not incremental change.', 'Larry Page', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','perseverance'], true, 'science'),
(gen_random_uuid(), 'You don''t need to have a 100-person company to develop that idea.', 'Larry Page', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','focus'], true, 'science'),
(gen_random_uuid(), 'Always deliver more than expected.', 'Larry Page', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','wisdom'], true, 'science'),
(gen_random_uuid(), 'My goal is for Google to lead, not follow.', 'Larry Page', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['leadership','perseverance'], true, 'science'),
(gen_random_uuid(), 'You can try to control people, or you can try to have a system that works well.', 'Larry Page', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['wisdom','leadership'], true, 'science'),
(gen_random_uuid(), 'Excellence matters, and technology advances so fast that the potential for improvement is tremendous.', 'Larry Page', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','focus'], true, 'science'),
(gen_random_uuid(), 'Small groups of people can have a really huge impact.', 'Larry Page', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','wisdom'], true, 'science'),

-- Sergey Brin (195–200)
(gen_random_uuid(), 'We want Google to be the third half of your brain.', 'Sergey Brin', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Obviously everyone wants to be successful, but I want to be looked back on as being very innovative.', 'Sergey Brin', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','perseverance'], true, 'science'),
(gen_random_uuid(), 'I''d like to see anyone be able to access any information they want.', 'Sergey Brin', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'Solving big problems is easier than solving little problems.', 'Sergey Brin', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','wisdom'], true, 'science'),
(gen_random_uuid(), 'Technology should help people do things better.', 'Sergey Brin', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'We do need people who think outside the box. My role is to enable that.', 'Sergey Brin', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','leadership'], true, 'science'),

-- Mark Zuckerberg (201–208)
(gen_random_uuid(), 'In a fast-changing world, the only strategy guaranteed to fail is not taking risks.', 'Mark Zuckerberg', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','perseverance'], true, 'science'),
(gen_random_uuid(), 'Move fast and break things. Unless you are breaking stuff, you are not moving fast enough.', 'Mark Zuckerberg', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','perseverance'], true, 'science'),
(gen_random_uuid(), 'People don''t care what someone says about you. They care about what you build.', 'Mark Zuckerberg', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','perseverance'], true, 'science'),
(gen_random_uuid(), 'The question is not what we want to know about people, but what people want to tell about themselves.', 'Mark Zuckerberg', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'My goal was never just to create a company. What I care about is the social mission.', 'Mark Zuckerberg', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','wisdom'], true, 'science'),
(gen_random_uuid(), 'In a world where information can be shared instantly across the globe, every person can be a creator.', 'Mark Zuckerberg', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','curiosity'], true, 'science'),
(gen_random_uuid(), 'Building a mission and building a business go hand in hand.', 'Mark Zuckerberg', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','perseverance'], true, 'science'),
(gen_random_uuid(), 'The most important thing is that we keep moving forward.', 'Mark Zuckerberg', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['perseverance','focus'], true, 'science'),

-- Kevin Kelly (209–218)
(gen_random_uuid(), 'The internet is the world''s largest experiment in anarchy, with fond hopes for democracy.', 'Kevin Kelly', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The internet is a machine for generating new questions.', 'Kevin Kelly', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'Technology wants to be free, but it has a long past of being unfree.', 'Kevin Kelly', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The nature of technology is that it favors no one.', 'Kevin Kelly', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'Every technology will create its own new dilemmas. And the solutions to those dilemmas will create new technologies.', 'Kevin Kelly', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The technium is the greater sphere of technology, which is now almost a living organism itself.', 'Kevin Kelly', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'The secret of life is to have a task you devote everything to — every minute, your whole life.', 'Kevin Kelly', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus','wisdom'], true, 'science'),
(gen_random_uuid(), 'Productivity is for robots. What humans are for is something else entirely.', 'Kevin Kelly', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'We are at that very point in time when a 400-year-old age is dying and another is struggling to be born.', 'Kevin Kelly', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The greatest force in the economy today is not money or technology — it is the desire of every person to be significant.', 'Kevin Kelly', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),

-- Stewart Brand (219–226)
(gen_random_uuid(), 'Information wants to be free.', 'Stewart Brand', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Once a new technology rolls over you, if you''re not part of the steamroller, you''re part of the road.', 'Stewart Brand', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','wisdom'], true, 'science'),
(gen_random_uuid(), 'We are as gods and might as well get good at it.', 'Stewart Brand', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','wisdom'], true, 'science'),
(gen_random_uuid(), 'How you can fight climate change and make money at the same time is the fundamental question of our age.', 'Stewart Brand', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','perseverance'], true, 'science'),
(gen_random_uuid(), 'The long run is the only run that matters.', 'Stewart Brand', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['perseverance','wisdom'], true, 'science'),
(gen_random_uuid(), 'Technology is anything that wasn''t around when you were born.', 'Stewart Brand', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The digital revolution is far more significant than the invention of writing or even of printing.', 'Stewart Brand', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'Stay hungry. Stay foolish. Stay curious.', 'Stewart Brand', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','perseverance'], true, 'science'),

-- Jaron Lanier (227–238)
(gen_random_uuid(), 'The most important thing about a technology is how it changes people.', 'Jaron Lanier', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'If you are not paying for it, you''re not the customer; you''re the product being sold.', 'Jaron Lanier', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Virtual reality is the first medium that doesn''t narrow the human spirit.', 'Jaron Lanier', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity','curiosity'], true, 'science'),
(gen_random_uuid(), 'The problem with social networks is that they are designed to make you unhappy.', 'Jaron Lanier', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'The deep tragedy of technology is that it doesn''t take tragedy into account.', 'Jaron Lanier', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'Algorithms are opinions embedded in code.', 'Jaron Lanier', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'You can think of the internet as a vast machine for generating illusions and measuring their effectiveness.', 'Jaron Lanier', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'The cloud is just someone else''s computer.', 'Jaron Lanier', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','humor'], true, 'science'),
(gen_random_uuid(), 'We are in early days of digital technology. The problems we face are the problems of immaturity.', 'Jaron Lanier', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','learning'], true, 'science'),
(gen_random_uuid(), 'Free software is a political project. Open source is a technical project.', 'Jaron Lanier', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The internet is the most liberating tool for humanity ever invented, and also the best for surveillance and control.', 'Jaron Lanier', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'Don''t be evil. That''s a very important principle.', 'Jaron Lanier', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','wisdom'], true, 'science'),

-- AI, Automation, Machine Learning — thematic quotes (239–250)
(gen_random_uuid(), 'Machine learning is the last invention that humanity will ever need to make.', 'Nick Bostrom', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The question of whether a computer can think is no more interesting than the question of whether a submarine can swim.', 'Edsger Dijkstra', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'The art of programming is the art of organizing complexity.', 'Edsger Dijkstra', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Computer science is no more about computers than astronomy is about telescopes.', 'Edsger Dijkstra', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Beware of bugs in the above code; I have only proved it correct, not tried it.', 'Donald Knuth', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','humor'], true, 'science'),
(gen_random_uuid(), 'Premature optimization is the root of all evil.', 'Donald Knuth', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Programs must be written for people to read, and only incidentally for machines to execute.', 'Harold Abelson', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The internet is the great equalizer — it gives the powerless the power to be heard.', 'Clay Shirky', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','wisdom'], true, 'science'),
(gen_random_uuid(), 'The future is already here — it''s just not evenly distributed.', 'William Gibson', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Cyberspace is the new frontier, and it''s a frontier worth exploring and protecting.', 'John Perry Barlow', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['courage','curiosity'], true, 'science'),
(gen_random_uuid(), 'Robots will neither save nor destroy us. We will do that ourselves.', 'Rodney Brooks', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','reflection'], true, 'science'),
(gen_random_uuid(), 'The blockchain is to trust what the internet was to communication.', 'Don Tapscott', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity','wisdom'], true, 'science')

ON CONFLICT (text, author) DO NOTHING;

COMMIT;
