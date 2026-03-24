import { readdirSync, statSync, readFileSync, writeFileSync } from 'fs';
import { join } from 'path';

const HOMUNCULUS_DIR = process.env.HOMUNCULUS_DIR || join(process.env.HOME || process.env.USERPROFILE, '.cursor', 'homunculus');
const PERSONAL_DIR = join(HOMUNCULUS_DIR, 'instincts', 'personal');

if (!existsSync(PERSONAL_DIR)) {
  console.log('No personal instincts directory found. Skipping decay.');
  process.exit(0);
}

// Check last run
const stateFile = join(HOMUNCULUS_DIR, '.instinct-decay-state');
const now = Date.now();
const ONE_WEEK = 7 * 24 * 60 * 60 * 1000;

if (existsSync(stateFile)) {
  const lastRun = parseInt(readFileSync(stateFile, 'utf8'), 10);
  if (now - lastRun < ONE_WEEK) {
    // Hasn't been a week yet
    process.exit(0);
  }
}

let files = [];
try {
  files = readdirSync(PERSONAL_DIR).filter(f => f.endsWith('.md'));
} catch (e) {
  process.exit(0);
}

let decayedCount = 0;

for (const file of files) {
  const filePath = join(PERSONAL_DIR, file);
  const content = readFileSync(filePath, 'utf8');
  
  // Find confidence using regex
  const confMatch = content.match(/^confidence:\s*([0-9.]+)/m);
  if (confMatch) {
    let conf = parseFloat(confMatch[1]);
    
    // Check evidence to see if it hasn't been observed recently
    // Basic heuristic: check file modified time
    const stats = statSync(filePath);
    if (now - stats.mtimeMs > ONE_WEEK) {
      // Decay confidence by 0.05
      conf = Math.max(0.1, conf - 0.05);
      const newContent = content.replace(/^confidence:\s*[0-9.]+/m, `confidence: ${conf.toFixed(2)}`);
      writeFileSync(filePath, newContent, 'utf8');
      decayedCount++;
    }
  }
}

writeFileSync(stateFile, now.toString(), 'utf8');

if (decayedCount > 0) {
  console.log(`[Instinct Decay] Decayed confidence for ${decayedCount} old instinct(s).`);
}

function existsSync(path) {
  try {
    statSync(path);
    return true;
  } catch (e) {
    return false;
  }
}