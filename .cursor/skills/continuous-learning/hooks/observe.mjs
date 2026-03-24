#!/usr/bin/env node

/**
 * ECC 工作流观察脚本
 * 用于捕获工具调用并记录到 observations.jsonl
 * 使用方法: node observe.mjs [pre|post]
 */

import { appendFile, mkdir, stat, rename } from 'fs/promises';
import { join } from 'path';
import { existsSync } from 'fs';

const HOMUNCULUS_DIR = process.env.HOMUNCULUS_DIR || join(process.env.HOME || process.env.USERPROFILE, '.cursor', 'homunculus');
const OBSERVATIONS_FILE = join(HOMUNCULUS_DIR, 'observations.jsonl');
const MAX_FILE_SIZE_MB = 10;

async function ensureDirectories() {
  const dirs = [
    HOMUNCULUS_DIR,
    join(HOMUNCULUS_DIR, 'instincts', 'personal'),
    join(HOMUNCULUS_DIR, 'instincts', 'inherited'),
    join(HOMUNCULUS_DIR, 'evolved', 'agents'),
    join(HOMUNCULUS_DIR, 'evolved', 'skills'),
    join(HOMUNCULUS_DIR, 'evolved', 'commands'),
    join(HOMUNCULUS_DIR, 'observations.archive')
  ];
  for (const dir of dirs) {
    await mkdir(dir, { recursive: true });
  }
}

async function checkAndArchive() {
  if (existsSync(OBSERVATIONS_FILE)) {
    try {
      const stats = await stat(OBSERVATIONS_FILE);
      const maxSize = MAX_FILE_SIZE_MB * 1024 * 1024;
      if (stats.size > maxSize) {
        const now = new Date();
        const dateStr = now.toISOString().replace(/[:T-]/g, '').slice(0, 14); // YYYYMMDDHHMMSS
        const archiveName = `observations-${dateStr}.jsonl`;
        const archivePath = join(HOMUNCULUS_DIR, 'observations.archive', archiveName);
        await rename(OBSERVATIONS_FILE, archivePath);
        process.stderr.write(`Archived observations to ${archiveName}\n`);
      }
    } catch (err) {
      // Ignore stat or rename errors
    }
  }
}

async function recordObservation(phase) {
  let payload = {};
  
  // Read stdin if not TTY
  if (!process.stdin.isTTY) {
    try {
      const chunks = [];
      for await (const chunk of process.stdin) {
        chunks.push(chunk);
      }
      const stdinData = Buffer.concat(chunks).toString('utf-8').trim();
      if (stdinData) {
        payload = JSON.parse(stdinData);
      }
    } catch (err) {
      // Ignore stdin parse errors, maybe not JSON
    }
  }

  const timestamp = new Date().toISOString();
  const tool_name = payload.tool_name ?? payload.toolName ?? payload.tool?.name ?? process.env.TOOL_NAME ?? 'unknown';
  
  let rawInput = payload.tool_input ?? payload.toolInput ?? payload.input ?? process.env.TOOL_INPUT;
  let tool_input = {};
  let input_raw = null;

  if (typeof rawInput === 'object' && rawInput !== null) {
    tool_input = rawInput;
  } else if (typeof rawInput === 'string') {
    try {
      tool_input = JSON.parse(rawInput);
    } catch (err) {
      input_raw = rawInput;
    }
  }

  const tool_output = String(payload.tool_output ?? payload.toolOutput ?? payload.output ?? process.env.TOOL_OUTPUT ?? '');
  const user_prompt = String(payload.user_prompt ?? payload.userPrompt ?? payload.prompt ?? process.env.USER_PROMPT ?? '');
  
  // Create YYYYMMDD format for default session id
  const now = new Date();
  const defaultSessionId = `${now.getFullYear()}${String(now.getMonth() + 1).padStart(2, '0')}${String(now.getDate()).padStart(2, '0')}`;
  const session_id = payload.session_id ?? payload.sessionId ?? process.env.SESSION_ID ?? defaultSessionId;

  const entry = {
    timestamp,
    phase,
    session_id,
    tool: tool_name,
    input: tool_input,
    input_raw,
    output_preview: tool_output.slice(0, 200),
    user_prompt_preview: user_prompt.slice(0, 200)
  };

  if (!entry.input_raw) {
    delete entry.input_raw; // Match jq output closely if it was null
  }

  try {
    await appendFile(OBSERVATIONS_FILE, JSON.stringify(entry) + '\n');
  } catch (err) {
    process.stderr.write(`Error writing observation: ${err.message}\n`);
  }
}

async function main() {
  const phase = process.argv[2] || 'unknown';

  if (!['pre', 'post'].includes(phase)) {
    process.stderr.write('Usage: node observe.mjs [pre|post]\n');
    process.exit(1);
  }

  await ensureDirectories();

  if (phase === 'pre') {
    await checkAndArchive();
  }

  await recordObservation(phase);
}

main().catch(err => {
  process.stderr.write(`Unexpected error: ${err.message}\n`);
  process.exit(1);
});
