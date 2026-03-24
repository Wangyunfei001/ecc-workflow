import { writeFileSync, mkdirSync, existsSync } from 'fs';
import { join, resolve } from 'path';

function printHelp() {
  console.log(`用法: node snapshot-context.mjs [选项]
选项:
  --phase <string>   当前阶段名称
  --decisions <str>  以逗号分隔的决策列表
  --artifacts <str>  以逗号分隔的产物文件列表
  --open <str>       未解决的问题
  --next <str>       下一步行动
  -h, --help         显示帮助`);
}

let phase = 'unknown';
let decisions = [];
let artifacts = [];
let openQuestions = '无';
let nextAction = '无';

const args = process.argv.slice(2);
while (args.length > 0) {
  const arg = args.shift();
  switch (arg) {
    case '--phase':
      phase = args.shift() || 'unknown';
      break;
    case '--decisions':
      decisions = (args.shift() || '').split(',').map(s => s.trim()).filter(Boolean);
      break;
    case '--artifacts':
      artifacts = (args.shift() || '').split(',').map(s => s.trim()).filter(Boolean);
      break;
    case '--open':
      openQuestions = args.shift() || '无';
      break;
    case '--next':
      nextAction = args.shift() || '无';
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

const docsDir = resolve('docs');
const snapshotsDir = join(docsDir, '.context-snapshots');

if (!existsSync(snapshotsDir)) {
  mkdirSync(snapshotsDir, { recursive: true });
}

const timestamp = new Date().toISOString().replace(/[:T]/g, '-').slice(0, 19);
const filename = `phase-${phase}-${timestamp}.md`;
const filepath = join(snapshotsDir, filename);

const content = `# Context Snapshot: ${phase}

**Date**: ${new Date().toISOString()}
**Phase**: ${phase}

## Decisions Made
${decisions.length > 0 ? decisions.map(d => `- ${d}`).join('\n') : '- (None)'}

## Artifacts Produced
${artifacts.length > 0 ? artifacts.map(a => `- \`${a}\``).join('\n') : '- (None)'}

## Open Questions
- ${openQuestions}

## Next Action
- ${nextAction}
`;

writeFileSync(filepath, content, 'utf8');

console.log(`✓ Snapshot saved to ${filepath}`);
