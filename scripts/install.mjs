import { cp, mkdir, readFile, writeFile, stat, readdir } from 'fs/promises';
import { join, dirname, resolve } from 'path';
import { fileURLToPath } from 'url';
import { existsSync, constants } from 'fs';
import { access } from 'fs/promises';
import { createInterface } from 'readline';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const WORKFLOW_DIR = dirname(__dirname);

let TARGET_DIR = process.cwd();
let ENABLE_LEARNING = false;
let DRY_RUN = false;
let VERIFY_AFTER = false;
let VERIFY_ONLY = false;
let MARKETPLACE_MODE = true;

const colors = {
  red: '\x1b[0;31m',
  green: '\x1b[0;32m',
  yellow: '\x1b[1;33m',
  blue: '\x1b[0;34m',
  nc: '\x1b[0m'
};

function printHelp() {
  console.log(`ECC Workflow 安装脚本 v4.0

用法:
  node install.mjs [选项] [目标项目路径]

选项:
  --marketplace       使用官方核心模式（默认）
  --enable-learning   启用 continuous-learning 增强层
  --dry-run           仅打印将执行动作，不写入文件
  --verify-after      安装后自动运行验证脚本
  --verify            仅执行验证（转调 scripts/verify-setup.mjs）
  --enable-hooks      兼容旧参数，等价于 --enable-learning
  -h, --help          显示帮助`);
}

async function runCmd(desc, action) {
  if (DRY_RUN) {
    console.log(`[dry-run] ${desc}`);
  } else {
    await action();
  }
}

async function copyComponent(src, dst, name) {
  if (!existsSync(src)) {
    console.log(`  ${colors.yellow}⚠ 跳过 ${name}：源目录不存在 ${src}${colors.nc}`);
    return;
  }
  await runCmd(`mkdir -p "${dst}" && cp -R "${src}/." "${dst}/"`, async () => {
    await mkdir(dst, { recursive: true });
    await cp(src, dst, { recursive: true });
  });
  console.log(`  ✓ ${name} 已复制`);
}

async function composeProjectHooks(hooksSrcDir, hooksOut) {
  const coreFile = join(hooksSrcDir, 'hooks.core.json');
  const compatFile = join(hooksSrcDir, 'hooks.compat.json');
  const learningFile = join(hooksSrcDir, 'hooks.learning.json');

  if (!existsSync(coreFile)) {
    console.log(`  ${colors.red}✗ 缺少 core hooks 文件: ${coreFile}${colors.nc}`);
    return false;
  }

  if (DRY_RUN) {
    let layers = "core+compat";
    if (ENABLE_LEARNING) layers = "core+compat+learning";
    console.log(`[dry-run] compose hooks layers => ${layers} -> ${hooksOut}`);
    return true;
  }

  try {
    const readJson = async (p) => {
      if (!existsSync(p)) return null;
      return JSON.parse(await readFile(p, 'utf-8'));
    };

    const core = await readJson(coreFile);
    const compat = await readJson(compatFile);
    let learning = null;
    if (ENABLE_LEARNING) {
      learning = await readJson(learningFile);
    }

    const merged = { version: 1, hooks: { preToolUse: [], postToolUse: [], beforeSubmitPrompt: [], stop: [] } };
    const mergeHooks = (source) => {
      if (!source?.hooks) return;
      ['preToolUse', 'postToolUse', 'beforeSubmitPrompt', 'stop'].forEach(k => {
        if (source.hooks[k]) {
          merged.hooks[k] = [...merged.hooks[k], ...source.hooks[k]];
        }
      });
    };

    mergeHooks(core);
    mergeHooks(compat);
    if (learning) mergeHooks(learning);

    await writeFile(hooksOut, JSON.stringify(merged, null, 2));
  } catch (err) {
    console.log(`  ${colors.yellow}⚠ JSON 合并失败，已降级为仅复制 core hooks: ${err.message}${colors.nc}`);
    await cp(coreFile, hooksOut);
  }
  return true;
}

async function main() {
  const args = process.argv.slice(2);
  while (args.length > 0) {
    const arg = args.shift();
    switch (arg) {
      case '--marketplace':
        MARKETPLACE_MODE = true;
        break;
      case '--enable-learning':
      case '--enable-hooks':
        ENABLE_LEARNING = true;
        break;
      case '--dry-run':
        DRY_RUN = true;
        break;
      case '--verify-after':
        VERIFY_AFTER = true;
        break;
      case '--verify':
        VERIFY_ONLY = true;
        break;
      case '-h':
      case '--help':
        printHelp();
        process.exit(0);
        break;
      default:
        TARGET_DIR = arg;
        break;
    }
  }

  if (VERIFY_ONLY) {
    const verifyMode = ENABLE_LEARNING ? 'learning' : 'core';
    const verifyScript = join(__dirname, 'verify-setup.mjs');
    console.log(`运行 node ${verifyScript} --mode ${verifyMode} --target ${TARGET_DIR}`);
    const { spawnSync } = await import('child_process');
    const res = spawnSync(process.execPath, [verifyScript, '--mode', verifyMode, '--target', TARGET_DIR], { stdio: 'inherit' });
    process.exit(res.status ?? 0);
  }

  if (!existsSync(TARGET_DIR)) {
    console.log(`${colors.red}错误：目标目录不存在: ${TARGET_DIR}${colors.nc}`);
    process.exit(1);
  }

  TARGET_DIR = resolve(TARGET_DIR);

  const USER_HOME = process.env.HOME || process.env.USERPROFILE;
  const USER_CURSOR_DIR = join(USER_HOME, '.cursor');
  const HOMUNCULUS_DIR = join(USER_CURSOR_DIR, 'homunculus');
  const PROJECT_CURSOR_DIR = join(TARGET_DIR, '.cursor');
  
  const d = new Date();
  const dateStr = d.getFullYear() + String(d.getMonth()+1).padStart(2,'0') + String(d.getDate()).padStart(2,'0') + String(d.getHours()).padStart(2,'0') + String(d.getMinutes()).padStart(2,'0') + String(d.getSeconds()).padStart(2,'0');
  const BACKUP_DIR = join(PROJECT_CURSOR_DIR, '.ecc-backup', dateStr);

  console.log(`${colors.green}=====================================${colors.nc}`);
  console.log(`${colors.green}   ECC Workflow 安装脚本 v4.0 (Node) ${colors.nc}`);
  console.log(`${colors.green}=====================================${colors.nc}`);
  console.log();
  console.log(`${colors.blue}模式:${colors.nc} marketplace(core) = ${MARKETPLACE_MODE}, learning = ${ENABLE_LEARNING}`);
  console.log(`${colors.blue}目标项目:${colors.nc} ${TARGET_DIR}`);
  console.log(`${colors.blue}dry-run:${colors.nc} ${DRY_RUN}`);
  console.log();

  if (!DRY_RUN) {
    const rl = createInterface({ input: process.stdin, output: process.stdout });
    const answer = await new Promise(resolve => rl.question('确认执行安装？[Y/n] ', resolve));
    rl.close();
    if (answer.trim() && !/^[Yy]$/.test(answer.trim())) {
      console.log(`${colors.yellow}安装取消${colors.nc}`);
      process.exit(0);
    }
  }

  console.log(`${colors.green}[1/5] 创建目录与备份...${colors.nc}`);
  await runCmd(`mkdir -p "${PROJECT_CURSOR_DIR}"/* && mkdir -p "${BACKUP_DIR}"`, async () => {
    for (const d of ['agents', 'skills', 'commands', 'rules', 'hooks', 'templates']) {
      await mkdir(join(PROJECT_CURSOR_DIR, d), { recursive: true });
    }
    await mkdir(BACKUP_DIR, { recursive: true });
  });

  for (const d of ['agents', 'skills', 'commands', 'rules', 'hooks', 'templates']) {
    const p = join(PROJECT_CURSOR_DIR, d);
    if (existsSync(p) && !DRY_RUN) {
      await cp(p, join(BACKUP_DIR, d), { recursive: true }).catch(() => {});
    }
  }
  console.log(`  ✓ 备份目录: ${BACKUP_DIR}`);

  console.log(`${colors.green}[2/5] 复制核心组件（根目录映射）...${colors.nc}`);
  await copyComponent(join(WORKFLOW_DIR, 'agents'), join(PROJECT_CURSOR_DIR, 'agents'), 'agents');
  await copyComponent(join(WORKFLOW_DIR, 'skills'), join(PROJECT_CURSOR_DIR, 'skills'), 'skills');
  await copyComponent(join(WORKFLOW_DIR, 'commands'), join(PROJECT_CURSOR_DIR, 'commands'), 'commands');
  await copyComponent(join(WORKFLOW_DIR, 'rules'), join(PROJECT_CURSOR_DIR, 'rules'), 'rules');
  await copyComponent(join(WORKFLOW_DIR, 'hooks'), join(PROJECT_CURSOR_DIR, 'hooks'), 'hooks');
  await copyComponent(join(WORKFLOW_DIR, 'templates'), join(PROJECT_CURSOR_DIR, 'templates'), 'templates');

  if (existsSync(join(WORKFLOW_DIR, 'hooks'))) {
    await composeProjectHooks(join(WORKFLOW_DIR, 'hooks'), join(PROJECT_CURSOR_DIR, 'hooks.json'));
    console.log(`  ✓ 项目级 hooks 已按分层合成: .cursor/hooks.json`);
  }

  console.log(`${colors.green}[3/5] 处理 learning 增强层...${colors.nc}`);
  if (ENABLE_LEARNING) {
    await runCmd(`mkdir -p "${USER_CURSOR_DIR}/hooks" && mkdir -p "${HOMUNCULUS_DIR}"/*`, async () => {
      await mkdir(join(USER_CURSOR_DIR, 'hooks'), { recursive: true });
      for (const d of ['instincts/personal', 'instincts/inherited', 'evolved/agents', 'evolved/skills', 'evolved/commands', 'observations.archive', 'exports']) {
        await mkdir(join(HOMUNCULUS_DIR, d), { recursive: true });
      }
      const obsFile = join(HOMUNCULUS_DIR, 'observations.jsonl');
      if (!existsSync(obsFile)) await writeFile(obsFile, '');
    });

    const observeMjs = join(WORKFLOW_DIR, 'skills/continuous-learning/hooks/observe.mjs');
    const observeSh = join(WORKFLOW_DIR, 'skills/continuous-learning/hooks/observe.sh');
    const batchObsMjs = join(WORKFLOW_DIR, 'scripts/batch-observations.mjs');
    const instinctDecayMjs = join(WORKFLOW_DIR, 'scripts/instinct-decay.mjs');

    if (existsSync(observeMjs) || existsSync(observeSh)) {
      await runCmd(`cp observe.mjs/sh and other hooks`, async () => {
        if (existsSync(observeMjs)) {
          await cp(observeMjs, join(USER_CURSOR_DIR, 'hooks/observe.mjs'));
        }
        if (existsSync(observeSh)) {
          await cp(observeSh, join(USER_CURSOR_DIR, 'hooks/observe.sh'));
          await import('fs/promises').then(fs => fs.chmod(join(USER_CURSOR_DIR, 'hooks/observe.sh'), 0o755)).catch(()=>{});
        }
        if (existsSync(batchObsMjs)) {
          await cp(batchObsMjs, join(USER_CURSOR_DIR, 'hooks/batch-observations.mjs'));
        }
        if (existsSync(instinctDecayMjs)) {
          await cp(instinctDecayMjs, join(USER_CURSOR_DIR, 'hooks/instinct-decay.mjs'));
        }
      });
      console.log(`  ✓ observe.mjs (和 observe.sh 及相关 hooks) 已安装到 ~/.cursor/hooks/`);
    } else {
      console.log(`  ${colors.yellow}⚠ 未找到 observe.mjs/sh，跳过${colors.nc}`);
    }
  } else {
    console.log(`  ${colors.yellow}⚠ 未启用 learning 模式（如需启用请加 --enable-learning）${colors.nc}`);
  }

  console.log(`${colors.green}[4/5] 写入项目辅助文件...${colors.nc}`);
  const codemapsDir = join(TARGET_DIR, 'docs', 'CODEMAPS');
  await runCmd(`mkdir -p "${codemapsDir}"`, async () => {
    await mkdir(codemapsDir, { recursive: true });
  });

  const overviewFile = join(codemapsDir, 'overview.md');
  if (!existsSync(overviewFile)) {
    if (DRY_RUN) {
      console.log(`[dry-run] create docs/CODEMAPS/overview.md`);
    } else {
      await writeFile(overviewFile, `# 项目代码地图\n\n## 目录结构\n\n请根据实际项目补充目录与模块说明。\n`);
    }
    console.log(`  ✓ docs/CODEMAPS/overview.md`);
  }

  console.log(`${colors.green}[5/5] 完成与下一步...${colors.nc}`);
  console.log(`  • 已安装核心组件到 ${PROJECT_CURSOR_DIR}`);
  if (ENABLE_LEARNING) {
    console.log(`  • 已启用 learning 增强目录: ${HOMUNCULUS_DIR}`);
  }
  console.log(`  • 备份路径: ${BACKUP_DIR}`);

  if (VERIFY_AFTER) {
    const verifyMode = ENABLE_LEARNING ? 'learning' : 'core';
    console.log(`\n${colors.blue}运行安装后验证（mode=${verifyMode}）...${colors.nc}`);
    const verifyScript = join(__dirname, 'verify-setup.mjs');
    if (DRY_RUN) {
      console.log(`[dry-run] node "${verifyScript}" --mode "${verifyMode}" --target "${TARGET_DIR}"`);
    } else {
      const { spawnSync } = await import('child_process');
      spawnSync(process.execPath, [verifyScript, '--mode', verifyMode, '--target', TARGET_DIR], { stdio: 'inherit' });
    }
  }

  console.log(`\n${colors.green}安装流程结束。${colors.nc}`);
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});