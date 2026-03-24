import { readFileSync, existsSync } from 'fs';
import { resolve, extname } from 'path';

function printHelp() {
  console.log(`用法: node gate-check.mjs [选项] <文档路径>
选项:
  --gate <number>    指定 Gate 阶段 (1-4)。不指定则自动推断。
  --min-score <num>  通过的最低分数百分比 (默认 80)
  --json             输出 JSON 格式结果
  -h, --help         显示帮助`);
}

let targetFile = '';
let gateNum = 0;
let minScore = 80;
let jsonOutput = false;

const args = process.argv.slice(2);
while (args.length > 0) {
  const arg = args.shift();
  switch (arg) {
    case '--gate':
      gateNum = parseInt(args.shift() || '0', 10);
      break;
    case '--min-score':
      minScore = parseInt(args.shift() || '80', 10);
      break;
    case '--json':
      jsonOutput = true;
      break;
    case '-h':
    case '--help':
      printHelp();
      process.exit(0);
      break;
    default:
      if (!arg.startsWith('-')) {
        targetFile = arg;
      }
      break;
  }
}

if (!targetFile) {
  console.error("错误: 缺少文档路径");
  printHelp();
  process.exit(1);
}

const resolvedPath = resolve(targetFile);
if (!existsSync(resolvedPath)) {
  console.error(`错误: 文件不存在 -> ${resolvedPath}`);
  process.exit(1);
}

const content = readFileSync(resolvedPath, 'utf8');

if (!gateNum) {
  if (resolvedPath.includes('/requirements/')) gateNum = 1;
  else if (resolvedPath.includes('/plans/')) gateNum = 2;
  else if (resolvedPath.includes('/architecture/') || resolvedPath.includes('/adrs/')) gateNum = 3;
  else if (resolvedPath.includes('/specs/')) gateNum = 4;
  else {
    console.error("无法自动推断 Gate 阶段，请通过 --gate 指定。");
    process.exit(1);
  }
}

let score = 0;
let total = 0;
const details = [];

function check(condition, desc) {
  total++;
  if (condition) {
    score++;
    details.push({ check: desc, pass: true });
  } else {
    details.push({ check: desc, pass: false });
  }
}

// 启发式检查
check(/status:\s*approved/i.test(content), "Frontmatter 包含 status: approved");

if (gateNum === 1) { // 需求
  check(/验收标准/i.test(content), "包含'验收标准'章节");
  check(/范围外|不在范围/i.test(content), "包含'范围外'描述");
  check(/用户场景/i.test(content), "包含'用户场景'描述");
  check(/约束/i.test(content), "包含'约束'描述");
} else if (gateNum === 2) { // 计划
  check(/任务拆解|任务清单/i.test(content), "包含'任务拆解'");
  check(/依赖/i.test(content), "包含'依赖'分析");
  check(/风险/i.test(content), "包含'风险'评估");
} else if (gateNum === 3) { // 架构
  check(/架构方案|系统设计/i.test(content), "包含架构方案说明");
  check(/决策|决议/i.test(content), "包含决策说明");
} else if (gateNum === 4) { // 规格
  check(/数据模型/i.test(content), "包含'数据模型'定义");
  check(/API|接口/i.test(content), "包含'API/接口'定义");
  check(/错误处理/i.test(content), "包含'错误处理'");
  check(/边界/i.test(content), "包含'边界情况'");
}

const pct = total === 0 ? 0 : Math.round((score * 100) / total);
const passed = pct >= minScore;

if (jsonOutput) {
  console.log(JSON.stringify({
    file: targetFile,
    gate: gateNum,
    score,
    total,
    percentage: pct,
    passed,
    details
  }));
} else {
  console.log(`Gate ${gateNum} 检查报告: ${targetFile}`);
  console.log(`得分: ${pct}% (${score}/${total})`);
  details.forEach(d => {
    console.log(`  ${d.pass ? '✓' : '✗'} ${d.check}`);
  });
  
  if (passed) {
    console.log(`结果: 状态 [通过] (>= ${minScore}%)`);
  } else {
    console.log(`结果: 状态 [拦截] (低于 ${minScore}%)`);
  }
}

process.exit(passed ? 0 : 1);