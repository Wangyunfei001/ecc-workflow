import { execSync } from 'child_process';
import { readFileSync, existsSync } from 'fs';
import { resolve } from 'path';

function printHelp() {
  console.log(`用法: node check-spec-code-alignment.mjs [选项]
选项:
  --staged           检查 Git 暂存区的文件
  --spec <path>      指定要对齐的 Spec 文件 (如未指定则尝试推断)
  -h, --help         显示帮助`);
}

let checkStaged = false;
let specPath = '';

const args = process.argv.slice(2);
while (args.length > 0) {
  const arg = args.shift();
  switch (arg) {
    case '--staged':
      checkStaged = true;
      break;
    case '--spec':
      specPath = args.shift() || '';
      break;
    case '-h':
    case '--help':
      printHelp();
      process.exit(0);
      break;
    default:
      console.error(`未知参数: ${arg}`);
      printHelp();
      process.exit(1);
  }
}

function getStagedFiles() {
  try {
    const output = execSync('git diff --name-only --cached', { encoding: 'utf-8' });
    return output.split('\n').filter(Boolean);
  } catch (e) {
    console.error("无法获取暂存区文件，请确保在 Git 仓库中执行。");
    return [];
  }
}

console.log("=== Spec 与代码一致性检查 ===");

const filesToCheck = checkStaged ? getStagedFiles() : [];

if (checkStaged && filesToCheck.length === 0) {
  console.log("暂存区没有文件，跳过检查。");
  process.exit(0);
}

if (specPath && !existsSync(resolve(specPath))) {
  console.error(`指定的 Spec 文件不存在: ${specPath}`);
  process.exit(1);
}

// 这是一个轻量级扫描演示
// 在实际工程中，这里可以连接 LLM API 或者做更深度的 AST 校验
// 目前提供基础的文件变更提醒

console.log("检测到的变更文件:");
filesToCheck.forEach(f => console.log(`  - ${f}`));

if (specPath) {
  console.log(`\n目标 Spec: ${specPath}`);
  const specContent = readFileSync(resolve(specPath), 'utf-8');
  console.log(`Spec 大小: ${specContent.length} 字节`);
  
  // 假装进行了一致性扫描
  console.log("\n[提示] 请确认以上代码变更完全遵守了 Spec 中定义的数据模型和接口规范。");
  console.log("[注意] 若偏离了 Spec，请先修改 Spec 并重新经过 Gate 4 审批。");
} else {
  console.log("\n[提示] 未显式指定 Spec 文件。建议提交前确保所有的实现均有对应的 Spec 支撑。");
}

console.log("\n检查完成 (Advisory Only)。");
process.exit(0);