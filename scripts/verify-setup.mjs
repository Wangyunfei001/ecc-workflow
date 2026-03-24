import { existsSync, readFileSync, statSync } from 'fs';
import { join, dirname, resolve } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const WORKFLOW_DIR = dirname(__dirname);

let MODE = 'core';
let STRICT = false;
let JSON_OUTPUT = false;
let TARGET_DIR = process.cwd();

const USER_HOME = process.env.HOME || process.env.USERPROFILE;
const USER_CURSOR_DIR = join(USER_HOME, '.cursor');
const HOMUNCULUS_DIR = join(USER_CURSOR_DIR, 'homunculus');

let ERRORS = 0;
let WARNS = 0;
let INFOS = 0;

function err(msg) {
  ERRORS++;
  if (!JSON_OUTPUT) console.log(`[ERROR] ${msg}`);
}

function warn(msg) {
  WARNS++;
  if (!JSON_OUTPUT) console.log(`[WARN] ${msg}`);
}

function info(msg) {
  INFOS++;
  if (!JSON_OUTPUT) console.log(`[INFO] ${msg}`);
}

function checkFile(path, level, message) {
  if (existsSync(path)) {
    info(`${message}: OK (${path})`);
  } else {
    if (level === 'error') err(`${message}: 缺失 (${path})`);
    else warn(`${message}: 缺失 (${path})`);
  }
}

function checkDir(path, level, message) {
  if (existsSync(path) && statSync(path).isDirectory()) {
    info(`${message}: OK (${path})`);
  } else {
    if (level === 'error') err(`${message}: 缺失 (${path})`);
    else warn(`${message}: 缺失 (${path})`);
  }
}

function checkPattern(path, pattern, level, message) {
  if (existsSync(path)) {
    const content = readFileSync(path, 'utf8');
    if (new RegExp(pattern).test(content)) {
      info(`${message}: OK (${path})`);
      return;
    }
  }
  if (level === 'error') err(`${message}: 缺失或不匹配 (${path})`);
  else warn(`${message}: 缺失或不匹配 (${path})`);
}

function main() {
  const args = process.argv.slice(2);
  while (args.length > 0) {
    const arg = args.shift();
    switch (arg) {
      case '--mode':
        MODE = args.shift();
        break;
      case '--strict':
        STRICT = true;
        break;
      case '--json':
        JSON_OUTPUT = true;
        break;
      case '--target':
        TARGET_DIR = args.shift();
        break;
      case '-h':
      case '--help':
        console.log(`用法: node verify-setup.mjs [--mode core|learning] [--strict] [--json] [--target <path>]`);
        process.exit(0);
        break;
      default:
        TARGET_DIR = arg;
        break;
    }
  }

  if (MODE !== 'core' && MODE !== 'learning') {
    console.error(`无效 mode: ${MODE} (仅支持 core|learning)`);
    process.exit(1);
  }

  if (!existsSync(TARGET_DIR)) {
    console.error(`目标目录不存在: ${TARGET_DIR}`);
    process.exit(1);
  }

  TARGET_DIR = resolve(TARGET_DIR);
  const PROJECT_CURSOR_DIR = join(TARGET_DIR, '.cursor');

  if (!JSON_OUTPUT) {
    console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    console.log(`  ECC Workflow 配置验证 (mode=${MODE})`);
    console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    console.log("\n[Group] Contract");
  }

  checkFile(join(WORKFLOW_DIR, '.cursor-plugin/plugin.json'), 'error', 'plugin manifest');
  checkFile(join(WORKFLOW_DIR, 'docs/architecture/task-graph-protocol.md'), 'error', 'task-graph protocol');
  checkDir(join(WORKFLOW_DIR, 'agents'), 'error', 'repo agents');
  checkDir(join(WORKFLOW_DIR, 'skills'), 'error', 'repo skills');
  checkDir(join(WORKFLOW_DIR, 'commands'), 'error', 'repo commands');
  checkDir(join(WORKFLOW_DIR, 'rules'), 'error', 'repo rules');
  checkDir(join(WORKFLOW_DIR, 'hooks'), 'error', 'repo hooks');
  checkFile(join(WORKFLOW_DIR, 'scripts/gate-check.mjs'), 'warn', 'gate-check.mjs 脚本');

  if (!JSON_OUTPUT) console.log("\n[Group] Install");
  checkDir(join(PROJECT_CURSOR_DIR, 'agents'), 'error', 'project agents');
  checkDir(join(PROJECT_CURSOR_DIR, 'skills'), 'error', 'project skills');
  checkDir(join(PROJECT_CURSOR_DIR, 'commands'), 'error', 'project commands');
  checkDir(join(PROJECT_CURSOR_DIR, 'rules'), 'error', 'project rules');
  checkFile(join(PROJECT_CURSOR_DIR, 'hooks.json'), 'error', 'project hooks.json');

  if (!JSON_OUTPUT) console.log("\n[Group] Hooks");
  checkFile(join(PROJECT_CURSOR_DIR, 'hooks/hooks.core.json'), 'error', 'layer file hooks.core.json');
  checkFile(join(PROJECT_CURSOR_DIR, 'hooks/hooks.compat.json'), 'warn', 'layer file hooks.compat.json');
  
  if (MODE === 'learning') {
    checkFile(join(PROJECT_CURSOR_DIR, 'hooks/hooks.learning.json'), 'warn', 'layer file hooks.learning.json');
  }

  const hooksJsonPath = join(PROJECT_CURSOR_DIR, 'hooks.json');
  if (existsSync(hooksJsonPath)) {
    try {
      const hooksData = JSON.parse(readFileSync(hooksJsonPath, 'utf8'));
      if (typeof hooksData.version === 'number') info('hooks version 字段合法');
      else err('hooks version 字段不合法（应为数字）');

      if (typeof hooksData.hooks === 'object' && hooksData.hooks !== null && !Array.isArray(hooksData.hooks)) {
        info('hooks 顶层对象合法');
      } else {
        err('hooks 顶层对象缺失或类型错误');
      }

      if (hooksData.hooks?.preToolUse) info('preToolUse 已配置');
      else warn('preToolUse 未配置');

      if (MODE === 'learning') {
        const hasObserveHook = hooksData.hooks?.preToolUse?.some(h => 
          (h.command || '').includes('observe.mjs') || (h.command || '').includes('observe.sh')
        );
        if (hasObserveHook) info('learning hook 已合并到 preToolUse');
        else warn('learning hook 可能未合并到 preToolUse');
      }
    } catch (e) {
      warn(`hooks.json 解析失败: ${e.message}`);
    }
  }

  if (MODE === 'learning') {
    if (!JSON_OUTPUT) console.log("\n[Group] Learning");
    checkDir(HOMUNCULUS_DIR, 'warn', 'homunculus 根目录');
    checkDir(join(HOMUNCULUS_DIR, 'instincts/personal'), 'warn', 'instincts/personal');
    checkDir(join(HOMUNCULUS_DIR, 'instincts/inherited'), 'warn', 'instincts/inherited');
    checkFile(join(HOMUNCULUS_DIR, 'observations.jsonl'), 'warn', 'observations.jsonl');
    
    const observeMjsPath = join(USER_CURSOR_DIR, 'hooks/observe.mjs');
    checkFile(observeMjsPath, 'warn', 'observe.mjs');
    if (existsSync(observeMjsPath)) {
      info("node/observe.mjs 环境存在");
      
      const content = readFileSync(observeMjsPath, 'utf8');
      if (/process\.stdin|input_raw|tool_name|tool_input|tool_output/.test(content)) {
        info("observe.mjs 能力探针通过（stdin/input_raw/tool fields）");
      } else {
        warn("observe.mjs 可能为旧版本（缺少 stdin/input_raw/tool 字段解析）");
      }
    }

    checkPattern(join(WORKFLOW_DIR, 'commands/orchestrate.md'), 'TaskGraph 协议', 'warn', 'orchestrate 协议段');
    checkPattern(join(WORKFLOW_DIR, 'commands/learn-project.md'), 'TaskGraph 协议', 'warn', 'learn-project 协议段');
    checkPattern(join(WORKFLOW_DIR, 'commands/analyze.md'), 'TaskGraph 协议', 'warn', 'analyze 协议段');
    checkPattern(join(WORKFLOW_DIR, 'commands/implement.md'), 'TaskGraph 协议', 'warn', 'implement 协议段');
    checkPattern(join(WORKFLOW_DIR, 'commands/review.md'), 'TaskGraph 协议', 'warn', 'review 协议段');
  } else {
    if (!JSON_OUTPUT) {
      console.log("\n");
      info("core 模式下跳过 learning 组检查");
    }
  }

  if (!JSON_OUTPUT) {
    console.log("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    console.log("  验证结果");
    console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    console.log(`ERROR: ${ERRORS}`);
    console.log(`WARN:  ${WARNS}`);
    console.log(`INFO:  ${INFOS}`);
  } else {
    console.log(JSON.stringify({ mode: MODE, errors: ERRORS, warnings: WARNS, infos: INFOS }));
  }

  if (ERRORS > 0) process.exit(1);
  if (STRICT && WARNS > 0) process.exit(1);
  process.exit(0);
}

main();