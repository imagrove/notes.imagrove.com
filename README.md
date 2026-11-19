# 嵌入式入门手记

`https://notes.imagrove.com` · 维护人：吕绪帆（Imagrove 硬件团队）

这是一个博客。你写一篇 Markdown，`git push`，一分钟后就出现在网站上。

这份 README 是写给你（维护者）的。前半部分是你天天要用的，最后那节「管理员：部署配置」不用你管，放着只是免得下次换人接手时又要重新摸索。

**你随时可以改这份 README。** 写得不顺、漏了步骤、哪句看不懂，直接改了提交——这是你的地盘。

---

## 1. 文章放在哪儿

仓库克隆下来之后，你只碰两个地方：

```
content/posts/        ← 所有文章都放这里，一篇一个 .md 文件
static/images/        ← 图片放这里，文件名带日期
```

```
templates/日志模板.md  ← 每次复制这个开始写
```

下面这些**不用你动**（动了也不会坏，只是没必要）：

```
hugo.toml             站点配置（站名、导航、首页文案）
themes/PaperMod/      外观主题
.github/workflows/    自动部署
.github/scripts/      提交前的自动检查
```

新文章直接丢进 `content/posts/`，**不需要改任何配置，也不需要挑目录**。这个站没有分类文件夹，只有时间线——放哪都不算放错。

---

## 2. 一次性准备（只做一次）

**装 git，注册 GitHub 账号，然后找管理员把你加成协作者**（Settings → Collaborators，权限 `Write`）。没这步你 push 不上去。

挑个地方克隆：

```bash
git clone https://github.com/imagrove/notes.imagrove.com.git
cd notes.imagrove.com
```

HTTPS 地址第一次 `push` 会让你登录 GitHub。如果它报 `Authentication failed`，最省事的做法是装 GitHub 官方的 `gh` 命令行并登录一次：

```bash
brew install gh
gh auth login          # 选 GitHub.com → HTTPS → 浏览器登录
```

想用 SSH 也行，把克隆地址换成 `git@github.com:imagrove/notes.imagrove.com.git`，前提是你已经在 GitHub 上添加过本机的公钥。

---

## 3. 写一篇的完整动作

```bash
git pull --rebase                                    # ① 先拉最新，别攒着

cp templates/日志模板.md content/posts/first-day-arduino.md   # ② 复制模板
# 打开这个文件，改字段、写正文                        # ③

bash .github/scripts/guard.sh                        # ④ 本地跑一遍脱敏检查

git add content/posts/ static/images/
git commit -m "add: 第一天装 Arduino 环境"
git push                                             # ⑤
```

① 那步是最容易翻车的地方：你在网页上改过东西、或者另一台机器提交过，不先拉就直接 push 会被拒绝（`non-fast-forward`）。养成动笔前先 `git pull --rebase` 的习惯，就不会遇到。

**文件名会变成网址**，所以用英文小写加短横线：`first-day-arduino.md` → `/posts/first-day-arduino/`。用中文也能跑通，但网址会变成一串 `%E7%AC%AC...`，不好复制也不好分享。

**文章顺序由 frontmatter 里的 `date` 决定，跟文件名无关。** 不需要在文件名前面加日期。

推送后约 1 分钟生效。想看有没有成功，去仓库的 **Actions** 标签页。

---

## 4. 每篇开头这七个字段

```yaml
---
title: "第一天：把 Arduino 环境装起来"
date: 2026-11-19
draft: false
author: "吕绪帆"
description: "装 IDE、装驱动、认串口，点亮第一个 LED"
tags: ["Arduino", "环境搭建"]
categories: ["日志"]
---
```

| 字段 | 说明 |
|---|---|
| `title` | 标题，**加引号**。标题里有冒号时不加引号会构建失败 |
| `date` | 日期，`2026-11-19` 这种格式。排序靠它，不是文件名 |
| `draft` | `false` 才发布。想先存着没写完就写 `true` |
| `author` | 署名。写你的名字——**署名权靠这一行成立**，不靠 git 提交记录 |
| `description` | 一句话摘要，列表页显示 |
| `tags` | 标签，用来串联同类文章。不用提前规划，写的时候顺手加 |
| `categories` | 统一写 `日志` |

**这是唯一会写错的地方。** 90% 的构建失败都是这三件事：`title` 里有冒号没加引号、`date` 格式不对、`tags` 少了方括号。

正文的六段式（今天要做什么 / 实际做了什么 / 遇到的问题 & 怎么解决 / 我理解的关键概念 / 还没搞懂的 / 明天）不是八股，是为了让你半年后回看时找得到东西。写不满的段直接删掉。

图片这样引用：

```markdown
![接线图](/images/2026-11-19-led.png)
```

---

## 5. 三条脱敏铁律

这个站**完全公开**，搜索引擎会抓，**而且 git 历史删不掉**。提交了不该有的东西，删文件、force push 都没用，历史里永远在。

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

## 6. 提交前 60 秒自检

- [ ] 没有客户公司名、项目代号、价格
- [ ] 截图里没有后台、聊天记录、客户图纸、logo
- [ ] 没有真实 IP / 密码 / token / 序列号
- [ ] `title` 加了引号，`date` 是 `2026-11-19` 格式，`tags` 是 `["x"]`
- [ ] 代码能跑（贴上去跑不通的代码比不贴更误导人）

第 3 条最容易漏，所以本地先跑一遍 `bash .github/scripts/guard.sh`——它和线上检查是同一份脚本，本地过了基本就不会被拦。

---

## 7. 沉淀规则（每周五，30 分钟）

日志是原料。只写日志不提炼，半年后这个站就是一堆没人看得懂的流水账。

**每周五做一件事**：翻本周文章，把重复出现两次以上的坑合并成一篇避坑笔记，标题写「现象」而不是「记录」。

- 好：`ESP32 烧录失败：Failed to connect to ESP32`
- 差：`这周遇到的一些问题`

标签写对，同类文章会自动归到一起（`/tags/` 页面）。不需要建分类目录。

> 判断标准：**别人能不能只看这一篇就避开你踩过的坑？** 能，就合格了。

---

## 8. 自动护栏

每次提交，GitHub 会跑两个检查：

| 检查 | 做什么 | 失败会怎样 |
|---|---|---|
| `hugo.yml` | 构建站点 | 构建失败会标红，日志指出第几行出错 |
| `guard.yml` | 扫敏感信息 | 命中邮箱/手机号/内网 IP/凭据/客户名库就标红 |

护栏命中但确实是教学示例的，在该行末尾加注释豁免：

```cpp
// 反面教材：password=123456 绝对不能这么写 <!-- guard-allow -->
```

本地先跑（可选，带客户名库一起扫）：

```bash
bash .github/scripts/guard.sh
GUARD_KEYWORDS="客户A,客户B" bash .github/scripts/guard.sh
```

---

## 9. 本地预览（可选）

想先看一眼自己写的长什么样再提交：

```bash
brew install hugo       # 只装一次
hugo server -D          # -D 表示连草稿一起显示
# 打开 http://localhost:1313
```

装的时候注意：本机和线上都锁在 **Hugo 0.152.2**，`brew install hugo` 装的是最新版（比它新），日常写文章没问题，但如果本地能跑、线上构建失败，先怀疑版本差。找管理员处理。

不装 Hugo 也完全不影响你写作——线上构建出来的效果就是最终效果。

---

## 常见问题

**提交了但网站没更新？**
去仓库的 **Actions** 标签页看最近一次运行。红色就是失败了，点进去看日志；日志里一般会指出是哪个 `.md` 文件的第几行。

**`git push` 被拒绝（`non-fast-forward` / `rejected`）？**
你没先拉。`git pull --rebase` 然后再 `git push`。

**页面能打开但完全没有样式？**
`hugo.toml` 里的 `baseURL` 结尾少了斜杠，或者被改坏了。找管理员。

**想改站名、导航、配色？**
`hugo.toml`。改完本地 `hugo server` 看效果，确认了再提交。

**写错了想改？**
直接编辑文件再提交一次，一分钟后线上就是新的。

**提交了客户信息怎么办？**
立刻联系管理员，不要自己删。**你自己删不掉 git 历史**，需要专业处理。

**这篇写得烂会怎样？**
不会怎样。这是记录，不是发表。写烂了下篇写好点就行。

---

## 管理员：部署配置（已做完，不用维护者管）

2026-11-19 首次部署完成，当前真实状态：

| 项 | 状态 |
| :--- | :--- |
| 仓库 `imagrove/notes.imagrove.com`（Public） | ✅ 已建 |
| Settings → Pages → Source = `GitHub Actions` | ✅ 已设（`build_type: workflow`） |
| Pages 自定义域名 | ✅ 已登记 `notes.imagrove.com` |
| DNS 解析 | ✅ 已加，在**阿里云**（不在 Cloudflare）：`CNAME notes → imagrove.github.io`，TTL 600 |
| 构建与线上访问 | ✅ 全路由 200，样式正常 |
| **Enforce HTTPS** | ⚠️ 未勾——证书刚在下发，勾选会报 `a certificate has not yet been issued`。签发后先勾选，**再重跑一次构建**（这次产物里 `canonical` 固化成了 `http://`，不重建会一直带着 http） |
| 协作者（维护者 Write 权限） | ⚠️ 待加 |
| Hugo 版本锁 | `0.152.2`，写死在 `hugo.yml` 的 `HUGO_VERSION`，与本机一致 |
| PaperMod 兼容性补丁 | ⚠️ 技术债。主题 v8.0 对本机 Hugo 0.152.2 有两处不兼容，已手改进仓库：3 个 `layouts/partials/templates/*.html` 去掉多余的 `partials/` 前缀；`opengraph.html` / `twitter_cards.html` 删掉已被移除的 `site.Social` 分支。**将来 Hugo 升到 0.158+ 时可换回官方原版主题** |
| 主题引入方式 | vendor 进仓库（无 submodule、无 `.git`），构建不依赖外网 |

要改域名时，四处必须同步（缺一会出现页面能开但链接跳回旧域名）：`hugo.toml` 的 `baseURL`（结尾斜杠不能少）、`static/CNAME`、Pages 面板的 Custom domain、DNS 记录。改完重跑一次构建，确认产物里 `rel=canonical` 已是新域名。

> 阿里云云解析本身不做代理，所以没有橙云/灰云开关。但这个 zone 将来要迁 Cloudflare（NS 现在还指向 `dns13/dns14.hichina.com`），**迁过去时 `notes` 这条必须保持灰云（仅 DNS）**：橙云会代理回源 `imagrove.github.io`，然后被 301 跳到 `notes.imagrove.com` 形成绕圈，页面直接坏。

**可选**：Settings → Secrets → `GUARD_KEYWORDS` 填客户名/项目代号（英文逗号分隔），护栏会额外扫这些词。**不要硬编码进仓库**——这是个 public 仓库，护栏自己不能成为泄漏源。
