# agent-setup

我的 Agent 配置中心：Claude Code + Codex 共用的 skills 和 MCP 清单。
新机器上 `git clone` 之后跑 `./setup.sh`，一条命令装齐。

每一项都是 2026-06 有意识挑选加入的，不是机器配置的全量倒灌。
增删任何东西都要更新下面的清单（是什么 + 为什么要它）。

## Skills 清单

| Skill | 来源 | 为什么要它 |
|---|---|---|
| **Superpowers**（框架） | [obra/superpowers](https://github.com/obra/superpowers) 223K★ | 完整开发方法论：头脑风暴→写计划→TDD→subagent 执行→系统化 debug。社区第一框架 |
| **grill-me** | [mattpocock/skills](https://github.com/mattpocock/skills) | 写码前把计划问透，所有决策点敲定才动手。治"对齐不足直接开写" |
| **handoff** | 同上 | 把 session 压缩成交接文档，新 session 无损续命。轻量 context 管理 |
| **skill-creator** | [anthropics/skills](https://github.com/anthropics/skills)（官方） | 造自己 skill 的标准工具——自进化 harness 的基础设施 |
| **last30days** | [mvanhorn/last30days-skill](https://github.com/mvanhorn/last30days-skill) | 跨 Reddit/X/HN 调研话题近 30 天动态 |
| **Karpathy 规则** | [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) | ~70 行行为规则：先想后写、能简则简、外科手术式改动 |

## MCP 清单

| Server | 来源 | 为什么要它 |
|---|---|---|
| **context7** | [upstash/context7](https://github.com/upstash/context7) 57K★ | 写代码时注入最新库文档，治 API 幻觉 |
| **playwright** | [microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp) 33.7K★ | 浏览器自动化 / E2E 测试 |
| **chrome-devtools** | [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) 43K★ | 真实浏览器 debug、性能分析（侧重 debug，和 playwright 互补） |
| **serena** | [oraios/serena](https://github.com/oraios/serena) 25K★ | LSP 语义检索/编辑，大仓库导航 |

## 怎么用

```bash
git clone git@github.com:BochengYin/agent-setup.git && cd agent-setup
./setup.sh        # 装 skills（共享目录，两个 CLI 通吃）+ 注册 MCP
```

前置依赖：node、git、claude CLI、codex CLI、uv（serena 用）。

## 机制说明

- **skills 一份两用**：SKILL.md 是开放标准（agentskills.io），`npx skills add -g`
  装进共享目录后 Claude Code 和 Codex 都能发现。repo 不 vendor skill 源码，
  只记录来源，更新走 `npx skills update`
- **MCP 要配两份**：Claude 走 `claude mcp add -s user`，Codex 走
  `config.toml`（脚本自动追加 [mcp/codex-mcp.toml](mcp/codex-mcp.toml)）
- **Superpowers 对 Codex 标注 experimental**，出问题就删掉
  `~/.agents/skills/superpowers` 这个 symlink，Claude 侧不受影响
- 密钥永远不进 git；目前清单里所有东西都无需密钥

## 安全须知

skills 本质是会被 agent 执行的指令。新增 skill 前先读一遍它的 SKILL.md，
只从点名的来源装，不要 `--skill '*'` 全量装陌生仓库。
