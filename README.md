# 嵌入式入门手记

`https://notes.imagrove.com` · Imagrove 硬件团队

这是一个博客。你写一篇 Markdown，提交，一分钟后就出现在网站上。没有第二步。

---

## 最省事的写法（不需要装任何东西）

1. 打开这个链接，直接进新建文件页：

   ```
   https://github.com/imagrove/notes.imagrove.com/new/main/content/posts
   ```

   （仓库建好后如果名字不是 `notes.imagrove.com`，把链接里的仓库名换掉）

2. 文件名随意，比如 `first-day-arduino.md`。**建议用英文小写加短横线**，因为它会变成网址的一部分（`/posts/first-day-arduino/`）。

3. 内容先复制 `templates/日志模板.md`，再改成你的。

4. 拉到底，点 **Commit changes**。

网站会自动重建。提交后约 1 分钟，就能在 `https://notes.imagrove.com/posts/你设的网址/` 看到。

## 每篇开头这六个字段

```yaml
---
title: "第一天：把 Arduino 环境装起来"
date: 2026-11-19
draft: false
description: "装 IDE、装驱动、认串口，点亮第一个 LED"
tags: ["Arduino", "环境搭建"]
categories: ["日志"]
---
```

| 字段 | 说明 |
|---|---|
| `title` | 标题，**加引号**。标题里有冒号时不加引号会构建失败 |
| `date` | 日期，`2026-11-19` 这种格式。排序靠它，不是文件名 |
| `draft` | `false` 才发布。想先存着就写 `true` |
| `description` | 一句话摘要，列表页显示 |
| `tags` | 标签，用来串联同类文章。不用提前规划，写的时候顺手加 |
| `categories` | 统一写 `日志` |

**这是唯一会写错的地方。** 90% 的构建失败都是这三件事：`title` 里有冒号没加引号、`date` 格式不对、`tags` 少了方括号。

---

## 目录结构

```
content/posts/        ← 你只碰这里，所有文章都放这
static/images/        ← 图片放这，文件名带日期
templates/日志模板.md  ← 复制这个开始写
```

下面这些**不用你动**：

```
hugo.toml             站点配置
themes/PaperMod/      外观主题
.github/workflows/    自动部署
.github/scripts/      提交时的自动检查
```

新文章直接丢进 `content/posts/`，不需要改任何配置。没有分类目录，也不用想"这篇该放哪"。

---

## 三条脱敏铁律

这个站**完全公开**，搜索引擎会抓，**而且 git 历史删不掉**。提交了不该有的东西，删文件、force push 都没用。

所以规则是**写之前就过滤**，不是发布前再检查。

### 铁律一：客户零出现

不写客户公司名、项目代号、询盘号、报价数字。要提到就用代称：

| 别写 | 写成 |
|---|---|
| `XX 科技的温控器项目` | `某个客户的温控器项目` |
| `第 4 轮报价 / 12.8 美金` | 不写价格 |
| 客户联系人姓名 | `对接人` |

### 铁律二：截图只贴公开物

可以贴：芯片和开发板的官方图、你自己搭的电路、你自己画的示意图、串口打印、报错截屏。

**绝对不贴**：客户后台、聊天记录、客户的原理图或 PCB、报价单、邮件、公司内部系统界面。

原理图上有客户 logo 或项目代号，先裁掉。

### 铁律三：凭据零出现

IP、域名、WiFi 密码、token、API key、设备序列号，一律用占位符：

```
服务器地址：<你的IP>
WiFi 名称：  <你的SSID>
token：      <你的token>
```

---

## 提交前 60 秒自检

- [ ] 没有客户公司名、项目代号、价格
- [ ] 截图里没有后台、聊天记录、客户图纸、logo
- [ ] 没有真实 IP / 密码 / token / 序列号
- [ ] `title` 加了引号，`date` 是 `2026-11-19` 格式，`tags` 是 `["x"]`
- [ ] 代码能跑（贴上去跑不通的代码比不贴更误导人）

---

## 沉淀规则（每周五，30 分钟）

日志是原料。只写日志不提炼，半年后这个站就是一堆没人看得懂的流水账。

**每周五做一件事**：翻本周文章，把重复出现两次以上的坑合并成一篇避坑笔记，标题写「现象」而不是「记录」。

- 好：`ESP32 烧录失败：Failed to connect to ESP32`
- 差：`这周遇到的一些问题`

标签写对，同类文章会自动归到一起（`/tags/` 页面）。不需要建分类目录。

> 判断标准：**别人能不能只看这一篇就避开你踩过的坑？** 能，就合格了。

---

## 自动护栏

每次提交，GitHub 会跑两个检查：

| 检查 | 做什么 | 失败会怎样 |
|---|---|---|
| `hugo.yml` | 构建站点 | 构建失败会标红，日志指出第几行出错 |
| `guard.yml` | 扫敏感信息 | 命中邮箱/手机号/内网 IP/凭据/客户名库就标红 |

护栏命中但确实是教学示例的，在该行末尾加注释豁免：

```cpp
// 反面教材：password=123456 绝对不能这么写 <!-- guard-allow -->
```

本地可以先跑一遍（和 CI 是同一份脚本）：

```bash
bash .github/scripts/guard.sh
GUARD_KEYWORDS="客户A,客户B" bash .github/scripts/guard.sh
```

---

## 本地预览（可选，不是必须）

装了 Hugo 才需要。没装就跳过，直接用 GitHub 网页写。

```bash
brew install hugo       # macOS，只装一次
hugo server -D          # -D 表示连草稿一起显示
# 打开 http://localhost:1313
```

---

## 管理员：首次部署（只做一次）

1. 建仓库 `imagrove/notes.imagrove.com`，**Public**（Pages 对 public 仓库免费）
2. 把本目录内容推上去
3. 仓库 **Settings → Pages**：
   - **Source 必须选 `GitHub Actions`**（默认是 `Deploy from a branch`，选它 Hugo 不会被编译，你只会看到一个空页面）
   - Custom domain 填 `notes.imagrove.com`
4. 在 Cloudflare 的 `imagrove.com` zone 加记录：
   - 类型 `CNAME`，名称 `notes`，内容 `imagrove.github.io`
   - **先不要开橙云**（代理），等 Pages 那边证书签发成功再考虑
5. 回 Pages 页面勾选 **Enforce HTTPS**
6. 加协作者：Settings → Collaborators，把实习生拉进来，给 **Write** 权限

之后他提交，GitHub 自动构建发布，你不用管。

**可选**：Settings → Secrets → `GUARD_KEYWORDS` 填客户名/项目代号（英文逗号分隔），护栏会额外扫这些词。

---

## 常见问题

**提交了但网站没更新？**
去仓库的 **Actions** 标签页看最近一次运行。红色就是失败了，点进去看日志。

**页面能打开但完全没有样式？**
`hugo.toml` 里的 `baseURL` 结尾少了斜杠，或者被改坏了。找管理员。

**想改站名、导航、配色？**
`hugo.toml`。改完提交，本地 `hugo server` 能立刻看到效果。

**写错了想改？**
直接编辑文件再提交一次。

**提交了客户信息怎么办？**
立刻联系管理员。**你自己删不掉 git 历史**，需要专业处理。

**这篇写得烂会怎样？**
不会怎样。这是记录，不是发表。写烂了下篇写好点就行。
