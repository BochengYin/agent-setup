#!/bin/bash
# setup.sh — 在一台新机器上装齐我的 agent 全家桶（Claude Code + Codex）
#
# 用法：./setup.sh
# 可重复跑（幂等）：已装过的会跳过或被 npx skills 自动更新。
#
# 前置依赖：node/npx、git、claude CLI、codex CLI；serena 需要 uv（https://docs.astral.sh/uv/）

set -uo pipefail

echo "════ 1/4 轻量 skills（装到共享目录，Claude Code 和 Codex 都能用）════"
# npx skills 会自动探测本机装了哪些 agent CLI，把 skill 装进各自的目录
npx -y skills add mattpocock/skills -s grill-me -s handoff -g -y
npx -y skills add anthropics/skills -s skill-creator -g -y
npx -y skills add mvanhorn/last30days-skill -g -y
npx -y skills add multica-ai/andrej-karpathy-skills -g -y

echo "════ 2/4 Superpowers 框架 ════"
# Claude Code 侧：官方 plugin marketplace
claude plugin marketplace add obra/superpowers-marketplace 2>/dev/null || true
claude plugin install superpowers@superpowers-marketplace || echo "（如已安装会报错，忽略）"

# Codex 侧：官方推荐方式 = clone + 共享目录 symlink（标注 experimental）
if [ ! -d "$HOME/.codex/superpowers" ]; then
  git clone --depth 1 https://github.com/obra/superpowers "$HOME/.codex/superpowers"
fi
mkdir -p "$HOME/.agents/skills"
[ -e "$HOME/.agents/skills/superpowers" ] || \
  ln -s "$HOME/.codex/superpowers/skills" "$HOME/.agents/skills/superpowers"

echo "════ 3/4 MCP servers → Claude Code（user 级，所有项目可用）════"
claude mcp add -s user context7        -- npx -y @upstash/context7-mcp || true
claude mcp add -s user playwright      -- npx @playwright/mcp@latest || true
claude mcp add -s user chrome-devtools -- npx -y chrome-devtools-mcp@latest || true
claude mcp add -s user serena \
  -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant || true

echo "════ 4/4 MCP servers → Codex（追加到 ~/.codex/config.toml）════"
if grep -q "mcp_servers.context7" "$HOME/.codex/config.toml" 2>/dev/null; then
  echo "config.toml 里已有 MCP 配置，跳过（如需更新请手动对照 mcp/codex-mcp.toml）"
else
  cat mcp/codex-mcp.toml >> "$HOME/.codex/config.toml"
  echo "已追加 4 个 MCP server 到 config.toml"
fi

echo ""
echo "完成。重启 claude / codex 后生效。"
echo "验证：claude 里跑 /plugin 看 superpowers；npx skills ls 看单品；claude mcp list 看 MCP。"
