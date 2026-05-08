# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

## Product Manager Workspace

### 需求文档目录
- **本地路径**: `/Users/moonviz/.openclaw/workspace/product-manager-agent-workspace`
- **GitHub 仓库**: `git@github.com:moonvision-ai/product-manager-agent-workspace.git`
- **用途**: 所有产品需求文档的统一存放位置

### 文档结构
```
documents/
├── 00-Inbox/          # 待整理的草稿和需求
├── 01-Projects/       # 进行中的项目需求
├── 02-Documents/      # 已确定的需求文档
├── 03-Archive/        # 已完成或废弃的需求
└── Templates/         # 需求文档模板
```

---

## Software Engineer Workspace

### 技术方案仓库
- **本地路径**: `/Users/moonviz/.openclaw/workspace/software-engineer-agent-workspace`
- **GitHub 仓库**: `git@github.com:moonvision-ai/software-engineer-agent-workspace.git`
- **用途**: 提交调研结果和技术方案文档

---

Add whatever helps you do your job. This is your cheat sheet.