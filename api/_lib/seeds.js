// Real observations from Joshua's X bookmarks (wiki: src-x-bookmarks-2026-11-21).
// The daily generator starts from one per day, in order, from SEED_START, instead
// of a random group of people, and credits the post it came from.
// ponytail: day-indexed, no "used" state. A day the judge rejects the seed just
// moves on; past the end of the list the generator goes back to GEN_ANGLES.
const SEED_START = '2026-11-22';

const SEEDS = [
  { seed: 'Founders naming a new company cannot find a short .com that is unregistered or cheap; every 4 to 6 letter name they try is parked or priced at six figures.', src: 'https://x.com/zanehengsperger/status/2122117620522787129' },
  { seed: 'A small company opened one entry-level job and closed it an hour later after 650 applications, most of them sent automatically by AI tools.', src: 'https://x.com/Finance_Weights/status/2123098089993150534' },
  { seed: 'iOS developers running coding agents run out of RAM because every booted simulator takes 3 to 4 GB and agents leave them running.', src: 'https://x.com/grok/status/2123510361538105742' },
  { seed: 'Indie game developers spend days cleaning AI-made 3D models by hand: fixing topology, unwrapping UVs, painting textures and making low-detail versions.', src: 'https://x.com/0xKense1/status/2123879132090245223' },
  { seed: 'A solo founder priced their product from server costs and hourly rate, and later learned customers only cared what the problem cost them each week.', src: 'https://x.com/pggalaviz/status/2122105685970235743' },
  { seed: 'People who read research PDFs want to highlight a passage, ask what influenced it or who quotes it, and keep the answer as a note.', src: 'https://x.com/dela3499/status/2123162159043510779' },
  { seed: 'People who run AI models at home keep getting asked by friends with little money and old laptops which model will run on what they own.', src: 'https://x.com/luksamuk/status/2122083563843788950' },
  { seed: 'Freelance developers say coding is no longer the slow part; agreeing on specs with the client and getting design signed off is.', src: 'https://x.com/tako2539/status/2121553125689430327' },
  { seed: 'Small engineering teams lose hundreds of hours a week waiting on CI, and most of it is setup and queue time, not running tests.', src: 'https://x.com/pontusab/status/2123750671795261748' },
  { seed: 'A designer at a localization company could not find one font family that covers the scripts of 99 percent of the world, so they drew their own.', src: 'https://x.com/kevskgs/status/2121320016054473206' },
  { seed: 'Most home Macs sit idle all day while people pay for cloud AI compute by the hour.', src: 'https://x.com/AntSeed/status/2123824005274853562' }
];

function seedFor(date = new Date()) {
  const day = Math.floor((date.getTime() - Date.parse(SEED_START)) / 864e5);
  return day >= 0 && day < SEEDS.length ? SEEDS[day] : null;
}

module.exports = { SEEDS, SEED_START, seedFor };
