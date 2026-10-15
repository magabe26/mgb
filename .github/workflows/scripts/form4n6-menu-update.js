#!/usr/bin/env node

'use strict';

const fs = require('fs');
const QSP = require('./qsimpleparser.js');

const stR = QSP.string;
const any = QSP.any;
const digit = QSP.digit;

const NECTA_PAGE = 'https://www.necta.go.tz/results/view/'; // + ResultsType
const GITHUB_FILE = 'https://github.com/magabe26/mgb/blob/master/'; // + GithubFile
const REPORT_FILE = 'menu_update_report.txt';
const CONFIG_FILE = 'auto-menu-update.config'; // 0 = hakuna kilichofeli, 1 = kuna kilichofeli
const ENTRY_TAG = 'RESULTS'; // <RESULTS><A HREF="...">2025</A></RESULTS>

// Faili moja (mgb2_6.xml) lina makundi mawili: CSEE (Form 4) na ACSEE (Form 6).
// Kila ResultsType inasasisha kundi lake tu, kwa kutambua '/csee/' au '/acsee/' kwenye link.
const resultsFiles = [
  { ResultsType: 'csee', GithubFile: 'mgb2_6.xml' },
  { ResultsType: 'acsee', GithubFile: 'mgb2_6.xml' }
];

const SOURCES = resultsFiles.map(({ ResultsType, GithubFile }) => ({
  name: ResultsType,
  url: NECTA_PAGE + ResultsType,
  file: GithubFile,
  kind: ResultsType
}));

// ------------------------------------------------------------------ parsers

// http........htm  (herufi yoyote isipokuwa < na >)
const linkParser = stR('http', false)
  .seq(any(stR('.htm', false), '<>').plus())
  .seq(stR('.htm', false));

// Mwaka: tarakimu 4 zinazoanza na 19 au 20 (mfano 2025)
const yearParser = stR('19').or(stR('20')).seq(digit().repeat(2));
// Msururu wowote wa tarakimu
const digitRun = digit().plus();

// <RESULTS> ... </RESULTS>
const entryEnd = stR('</' + ENTRY_TAG + '>', false);
const entryParser = stR('<' + ENTRY_TAG, false).seq(any(entryEnd).star()).seq(entryEnd);

const crlf = stR('\r\n');
const newLine = QSP.newLine();
const blank = QSP.spaceOptional();

// ---------------------------------------------------------------- functions

/** Mwaka wa kwanza uliopo popote kwenye link (msururu wa tarakimu 4 kamili), au 0. */
function getYear(link) {
  for (const run of digitRun.allStringMatches(link)) {
    const year = yearParser.parse(run);
    if (year.isSuccess() && year.success().end() === run.length) return Number(run);
  }
  return 0;
}

/** Nafasi tupu zilizo kabla ya `pos` kwenye mstari wake (kama hakuna kingine). */
function indentAt(xml, pos) {
  const before = xml.slice(0, pos);
  const lastBreak = newLine.lastMatch(before);
  const lead = before.slice(lastBreak.isSuccess() ? lastBreak.success().end() : 0);
  const spaces = blank.parse(lead);
  return spaces.isSuccess() && spaces.success().end() === lead.length ? lead : '';
}

/**
 * Je, link hii ni ya aina `kind` (mfano 'csee')? Inatafuta '/csee/' kwenye link, kwa hiyo
 * '/acsee/' haichanganywi na '/csee/'. Bila `kind`, kila link inakubaliwa.
 */
function isKind(link, kind) {
  return !kind || link.toLowerCase().includes('/' + kind.toLowerCase() + '/');
}

/**
 * Inaongeza link kwenye XML, mwaka mpya juu. Muundo wa kipengele na mgawanyo
 * kati ya vipengele (mistari tupu, nafasi) vinanakiliwa kutoka kwenye faili lenyewe.
 * Kama mwaka tayari upo kwenye XML (hata kwa host tofauti), haiongezwi tena.
 * Kama `kind` imetolewa, vipengele vya aina hiyo tu ndivyo vinavyotumika (kuiga muundo,
 * kukagua mwaka, na kuchagua mahali pa kuingiza), kwa faili lenye makundi kadhaa.
 */
function addLinkToMenuXML(year, link, xml, kind) {
  const entries = entryParser.allMatches(xml)
    .filter((e) => isKind(linkParser.firstStringMatch(e.value()), kind));
  if (entries.length === 0) {
    throw new Error('hakuna <' + ENTRY_TAG + '>' + (kind ? ' ya ' + kind : '') + ' kwenye XML la kuiga muundo');
  }

  const yearOf = (entry) => getYear(linkParser.firstStringMatch(entry.value()));
  if (entries.some((e) => yearOf(e) === year)) return xml;

  const template = entries[0].value();
  const templateLink = linkParser.firstStringMatch(template);
  if (templateLink === '') throw new Error('<' + ENTRY_TAG + '> ya kwanza haina link ya .htm');
  const templateYear = String(getYear(templateLink));

  // mwaka wa kiolezo -> mwaka mpya, kisha link ya kiolezo -> link mpya
  const withYear = templateYear === '0'
    ? template
    : digitRun.replaceInMapped(template, (run) => (run === templateYear ? String(year) : run));
  const block = linkParser.replaceInMapped(withYear, () => link);

  const between = entries.length > 1
    ? xml.slice(entries[0].end(), entries[1].start())
    : (crlf.hasMatch(xml) ? '\r\n' : '\n') + indentAt(xml, entries[0].start());

  const older = entries.find((e) => yearOf(e) < year);
  if (older) {
    const at = older.start();
    return xml.slice(0, at) + block + between + xml.slice(at);
  }
  const last = entries[entries.length - 1];
  return xml.slice(0, last.end()) + between + block + xml.slice(last.end());
}

/**
 * Maelezo kamili ya kosa la fetch. "fetch failed" peke yake haitoshi: sababu halisi
 * (ETIMEDOUT, ECONNRESET, ENOTFOUND, UNABLE_TO_VERIFY_LEAF_SIGNATURE...) iko kwenye
 * `cause`, na Node ikijaribu anwani kadhaa (IPv4/IPv6) kila moja iko kwenye `cause.errors`.
 */
function describe(e) {
  const parts = [e.message];
  const cause = e.cause;
  if (cause) {
    if (cause.code) parts.push(cause.code);
    if (cause.message && cause.message !== e.message) parts.push(cause.message);
    for (const sub of cause.errors || []) {
      const where = sub.address ? sub.address + (sub.port ? ':' + sub.port : '') : '';
      parts.push([sub.code, where, sub.message].filter(Boolean).join(' '));
    }
  }
  return parts.join(' | ');
}

/** Inapakua ukurasa (majaribio 3). */
async function get(url) {
  let why = '';
  for (let attempt = 1; attempt <= 3; attempt++) {
    try {
      const res = await fetch(url, {
        headers: { 'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' },
        signal: AbortSignal.timeout(30000)
      });
      if (!res.ok) throw new Error('HTTP ' + res.status);
      return await res.text();
    } catch (e) {
      why = describe(e);
      console.error('  jaribio ' + attempt + ' limeshindwa: ' + why);
      if (attempt < 3) await new Promise((r) => setTimeout(r, 5000 * attempt));
    }
  }
  throw new Error('kupakua ukurasa kumeshindwa: ' + why);
}

/** Inasasisha faili moja. Inarudisha { links, added }. */
async function update({ url, file, kind }) {
  if (!url || !file) throw new Error('kila chanzo kinahitaji url na file');
  if (!fs.existsSync(file)) throw new Error('faili ' + file + ' halipo kwenye repo');

  const html = await get(url);
  const original = fs.readFileSync(file, 'utf8');
  let output = original;
  const links = [];
  const added = [];

  linkParser.replaceInMapped(html, (link) => {
    const year = getYear(link);
    if (year !== 0 && isKind(link, kind)) {
      links.push(link);
      const before = output;
      output = addLinkToMenuXML(year, link, output, kind);
      if (output !== before) added.push(link);
    }
    return link;
  }, 0, -1);

  if (links.length === 0) {
    throw new Error('hakuna link ya matokeo (http...htm zenye mwaka' + (kind ? ' na /' + kind + '/' : '') + ') kwenye ukurasa');
  }
  if (output !== original) fs.writeFileSync(file, output);
  return { links, added };
}

/** Inaendesha vyanzo vyote kimoja baada ya kingine; kimoja kikifeli vingine vinaendelea. */
async function run(sources) {
  const results = [];
  for (const source of sources) {
    const result = { name: source.name || source.file, url: source.url, file: source.file, links: [], added: [] };
    console.log('[' + result.name + '] ' + source.url + '  ->  ' + source.file);
    try {
      const done = await update(source);
      result.links = done.links;
      result.added = done.added;
      result.status = done.added.length ? 'IMESASISHWA' : 'HAKUNA MABADILIKO';
    } catch (e) {
      result.status = 'IMEFELI';
      result.error = e.message;
      console.error('  ERROR: ' + e.message);
    }
    for (const link of result.added) console.log('  + ' + link);
    results.push(result);
  }
  return results;
}

/** "2026-10-13 10:57:00 UTC | 2026-10-13 13:57:00 EAT" */
function stamp(date) {
  const pad = (n) => String(n).padStart(2, '0');
  const fmt = (d) => d.getUTCFullYear() + '-' + pad(d.getUTCMonth() + 1) + '-' + pad(d.getUTCDate()) + ' ' +
    pad(d.getUTCHours()) + ':' + pad(d.getUTCMinutes()) + ':' + pad(d.getUTCSeconds());
  return fmt(date) + ' UTC | ' + fmt(new Date(date.getTime() + 3 * 3600 * 1000)) + ' EAT';
}

function buildReport(results, when) {
  const count = (status) => results.filter((r) => r.status === status).length;
  const lines = [
    'RIPOTI YA KUSASISHA MENU ZA NECTA',
    'Imeendeshwa: ' + stamp(when),
    'Jumla: ' + results.length + ' | Imesasishwa: ' + count('IMESASISHWA') +
      ' | Hakuna mabadiliko: ' + count('HAKUNA MABADILIKO') + ' | Imefeli: ' + count('IMEFELI'),
    ''
  ];
  for (const r of results) {
    lines.push('[' + r.name + '] ' + r.status);
    lines.push('  ukurasa : ' + r.url);
    lines.push('  faili   : ' + r.file + '  (' + GITHUB_FILE + r.file + ')');
    if (r.error) {
      lines.push('  kosa    : ' + r.error);
    } else {
      const years = r.links.map(getYear).join(', ');
      lines.push('  links   : ' + r.links.length + (years ? '  (miaka: ' + years + ')' : ''));
      for (const link of r.added) lines.push('  imeongezwa: ' + link);
    }
    lines.push('');
  }
  return lines.join('\n');
}

/** Inaandika 0 au 1 kwenye config. Inaandika tu kama thamani imebadilika. */
function writeConfig(failed) {
  const value = failed ? '1' : '0';
  let eol = '';
  try {
    const current = fs.readFileSync(CONFIG_FILE, 'utf8');
    if (current.trim() === value) return;                 // hakuna mabadiliko
    eol = current.endsWith('\r\n') ? '\r\n' : current.endsWith('\n') ? '\n' : '';
  } catch (e) { /* faili halipo, litaundwa */ }
  fs.writeFileSync(CONFIG_FILE, value + eol);
  console.log('[config] ' + CONFIG_FILE + ' = ' + value);
}

async function main() {
  const startedAt = new Date();
  let results = [];
  let failed = true; // ikitokea kosa lisilotarajiwa, tunaweka 1
  try {
    results = await run(SOURCES);
    failed = results.some((r) => r.status === 'IMEFELI');
    const report = buildReport(results, startedAt);
    fs.writeFileSync(REPORT_FILE, report);
    console.log('\n' + report);
  } catch (e) {
    console.error('KOSA LISILOTARAJIWA: ' + (e && e.stack || e));
  } finally {
    writeConfig(failed);
  }
  process.exit(failed ? 1 : 0);
}

if (require.main === module) main();

module.exports = { run, buildReport, getYear, addLinkToMenuXML, SOURCES };
