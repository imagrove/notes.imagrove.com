# 嵌入式入门手记

`https://notes.imagrove.com` · 维护人：吕绪帆（Imagrove 硬件团队成员）

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
hugo.toml                        站点配置（站名、导航、首页文案）
themes/PaperMod/                 外观主题
layouts/partials/comments.html   文章页底部的评论区（提示文字想改就改这个文件）
.github/workflows/               自动部署
.github/scripts/                 提交前的自动检查
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

bash .github/scripts/guard.sh                        # ④ 本地能扫的先扫掉（客户名库不在这台机器上，见 §8）

git add content/posts/ static/images/
git commit -m "add: 第一天装 Arduino 环境"
git push                                             # ⑤
```

① 那步是最容易翻车的地方：你在网页上改过东西、或者另一台机器提交过，不先拉就直接 push 会被拒绝（`non-fast-forward`）。养成动笔前先 `git pull --rebase` 的习惯，就不会遇到。

**文件名会变成网址**，所以用英文小写加短横线：`first-day-arduino.md` → `/posts/first-day-arduino/`。用中文也能跑通，但网址会变成一串 `%E7%AC%AC...`，不好复制也不好分享。

**文章发出去以后别再改文件名。** 评论区是按网址对应留言的（`/posts/first-day-arduino/` 这一页 ↔ 那一条讨论串），改了名等于换了一个新页面：旧留言留在原来那条串里看不到，新页面评论区是空的。写错了要改内容，直接编辑文件，名字不动。

**文章顺序由 frontmatter 里的 `date` 决定，跟文件名无关。** 不需要在文件名前面加日期。

推送后约 1 分钟生效。但这里有个顺序要注意：**先扫后发**——只有 Actions 里 `guard` 和 `build`、`deploy` 三个都绿了，文章才真的上去。护栏把你拦下时，网站不会坏，线上就是上一次的内容，**只有你这篇不出现**。所以推完去 **Actions** 看一眼，不要只看本地没报错就以为发了。

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

第 1 条最容易漏，而且**本地扫不出来**（客户名词库只存在线上，见 §8）——它是硬门禁，写之前就得过滤掉。第 3 条可以靠工具：本地跑一遍 `bash .github/scripts/guard.sh`，它和线上是同一份脚本，邮箱/手机号/IP/凭据这类本地过了就不会被拦。

---

## 7. 沉淀规则（每周五，30 分钟）

日志是原料。只写日志不提炼，半年后这个站就是一堆没人看得懂的流水账。

**每周五做一件事**：翻本周文章，把重复出现两次以上的坑合并成一篇避坑笔记，标题写「现象」而不是「记录」。

- 好：`ESP32 烧录失败：Failed to connect to ESP32`
- 差：`这周遇到的一些问题`

标签写对，同类文章会自动归到一起（`/tags/` 页面）。不需要建分类目录。

> 判断标准：**别人能不能只看这一篇就避开你踩过的坑？** 能，就合格了。

---

## 8. 自动护栏（硬门禁）

每次 push，`hugo.yml` 里按顺序跑三个 job，前一个绿了才跑下一个：

| job | 做什么 | 失败会怎样 |
|---|---|---|
| `guard` | 扫敏感信息 | **后面两个 job 直接跳过，这篇不发布** |
| `build` | 构建站点 | 构建失败标红，日志指出哪个文件第几行 |
| `deploy` | 推到 Pages | 罕见，通常是权限或 Pages 配置问题 |

失败模式说清楚：`guard` 标红**不会把网站弄坏**。Pages 继续服务上一次成功部署的产物，你打开站点看到的还是旧内容，只是你这篇不在里面。

### 客户名词库

名单配在 Secrets 的 `GUARD_KEYWORDS`（2026-11-20 配，17 词：客户品牌/公司名 + 内部产品代号）。匹配是**字面量、忽略大小写**，把客户名写成全小写也拦得住。

它**只在线上生效**：名单存 Secrets（不能进仓库，否则护栏自己就是泄漏源），你本地跑 `guard.sh` 只能扫邮箱、手机号、IP、私钥、凭据这类正则。所以本地绿了不等于能发布，客户名那关要等 CI。想先扫一遍就跑：

```bash
bash .github/scripts/guard.sh
```

### 踩雷之后怎么解除

日志会直接打印命中的文件、行号和词。分两种情况：

**A. 命中客户名 / 内部代号** —— 只有一条路：**把那个词改掉**。写成「某个中亚客户」「某台香薰机控制器」，不指认具体客户，然后 `git push`，门禁自己就开了。

如果你写的其实是通用技术词、只是跟某个客户名撞车（比如 `BMC` 指基板管理控制器），那不是你的错，但你本地改不了词库 —— 找管理员删词，他改完还要重跑一次部署，否则文章仍然没上去。

**B. 命中邮箱 / 手机号 / IP / 凭据** —— 真信息删掉或换成占位符（`= <你的token>`）；**确实是要展示的反面教材**，在该行末尾加注释豁免：

```cpp
// 反面教材：password=123456 绝对不能这么写 <!-- guard-allow -->
```

**`guard-allow` 不能用来处理客户名。** 我实测过：豁免只让扫描闭眼，那个词照样出现在页面正文里，RSS 的 description 还会把注释转义成一串看得见的文字。词没被删掉，只是检查瞎了——等于白脱敏。所以词库命中这条路已经从脚本里拿掉了，加了注释也照样拦。

---

## 9. 本地预览（可选）

想先看一眼自己写的长什么样再提交：

```bash
brew install hugo       # 只装一次
hugo server -D          # -D 表示连草稿一起显示
# 打开 http://localhost:1313
```

装的时候注意：`brew install hugo` 装的是最新版（本机现在已经是 **0.170.1**），而线上构建锁在 **Hugo 0.152.2**（写死在 `.github/workflows/hugo.yml` 的 `HUGO_VERSION`）。也就是说本地预览和线上产物不是同一个 Hugo 构建出来的。日常写文章没问题，但**本地能跑、线上构建失败**时，先怀疑这个版本差。找管理员处理，别自己去改 workflow 里的版本号——线上版本是和管理员本机一起对齐的，动了要连 PaperMod 的兼容性补丁一起重验。

不装 Hugo 也完全不影响你写作——线上构建出来的效果就是最终效果。

---

## 10. 读者反馈在哪看

每篇文章下面都有一个评论区。读者用 GitHub 账号登录后留言，问的是「这一步我卡住了」「你这个报错我也遇到了」。

**留言不在这个仓库里**，在评论区专用仓 [`imagrove/notes-community`](https://github.com/imagrove/notes-community) 的 **Discussions** 标签页。想收今天的反馈，去那一个页面看，不用在文章之间翻。

有人回复了你的评论区，GitHub 会在你登录 `notes-community` 后通过右上角铃铛和邮件通知你——所以**第一次去把那个仓库点 Watch（Ignore 以外的档）**，否则留言你看不见。

处理动作只有三种：

- 读者说的坑你能改 → 改文章正文，再写一篇「这个坑我更新了」没意义，直接原地改
- 读者问的你也答不上来 → 这条就是下周该做的事，记进你自己的待办
- 单纯骂一句 / 广告 → 不用管，也不用来删（留言在那个仓库里，你没有它的管理权限，也不该有）

一篇不想开评论区的文章，在它开头的字段里加一行 `comments: false`。全站开关在 `hugo.toml` 的 `params.comments`，改成 `false` 就是所有文章都不出评论区——这行归管理员管。

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
| **Enforce HTTPS** | ✅ 已开。证书签发后 GitHub 自动置为 enforced，`http://` 现在 301 跳 `https://`，产物里 `rel=canonical` 也是 https |
| 协作者（维护者 Write 权限） | ⚠️ 已发邀请给 `L119601`（invitation id 345032820，权限 `push` = Write），**等他接受**。接受入口：https://github.com/imagrove/notes.imagrove.com/invitations 。邀请 7 天过期，过期后重发即可；imagrove 组未强制 2FA，不会卡他 |
| Hugo 版本锁 | `0.152.2`，写死在 `hugo.yml` 的 `HUGO_VERSION`，与本机一致 |
| PaperMod 兼容性补丁 | ⚠️ 技术债。主题 v8.0 对本机 Hugo 0.152.2 有两处不兼容，已手改进仓库：3 个 `layouts/partials/templates/*.html` 去掉多余的 `partials/` 前缀；`opengraph.html` / `twitter_cards.html` 删掉已被移除的 `site.Social` 分支。**将来 Hugo 升到 0.158+ 时可换回官方原版主题** |
| 主题引入方式 | vendor 进仓库（无 submodule、无 `.git`），构建不依赖外网 |
| **脱敏硬门禁** | ✅ 2026-11-20 并入 `hugo.yml` 作首个 job（`build: needs: guard` → `deploy: needs: build`），独立的 `guard.yml` 已删除（免得每次 push 扫两遍）。已用临时私有仓实测：`guard` 失败时 `build` 与 `deploy` 均为 `skipped`，不会把带敏感词的内容发出去 |
| **评论区（Giscus）** | ✅ 2026-11-24 接入，与 drone / tutorial 站同构。宿主仓 `imagrove/notes-community`（Public 空仓，Issues + Discussions 都开，只用 General 分类）；实现只在 `layouts/partials/comments.html`（主题 `single.html` 自带 `comments` 钩子，未改主题）+ `hugo.toml` 的 `params.comments = true`。`data-mapping=pathname`、界面语言 `zh-CN`、明暗主题跟随站点的 `body.dark`、点「加载评论区」才加载 iframe。只有 `.Section == "posts"` 出评论区，关于页/归档页/标签页不挂。写死在 partial 里的两个 id：repo `R_kgDOV4_iNw`、category `DIC_kwDOV4_iN84DLzi0`（换宿主仓才要动，取法见 partial 头部注释） |

要改域名时，四处必须同步（缺一会出现页面能开但链接跳回旧域名）：`hugo.toml` 的 `baseURL`（结尾斜杠不能少）、`static/CNAME`、Pages 面板的 Custom domain、DNS 记录。改完重跑一次构建，确认产物里 `rel=canonical` 已是新域名。

> 阿里云云解析本身不做代理，所以没有橙云/灰云开关。但这个 zone 将来要迁 Cloudflare（NS 现在还指向 `dns13/dns14.hichina.com`），**迁过去时 `notes` 这条必须保持灰云（仅 DNS）**：橙云会代理回源 `imagrove.github.io`，然后被 301 跳到 `notes.imagrove.com` 形成绕圈，页面直接坏。

**客户名词库维护**：已配 Settings → Secrets → `GUARD_KEYWORDS`（英文逗号分隔，17 词）。Secret 是**只写不读**的，写进去就再也拉不回来，所以词表的权威副本存在管理员本机：

```
~/.config/credentials/guard-keywords.imagrove.txt   （权限 600，无尾换行，与 Secret 逐字节一致）
```

新成交客户要加词时，先改这个文件，再同步进 Secret。名单**绝不写进仓库任何文件**（这是 public 仓库，护栏自己不能变成客户名单泄漏源）：

```bash
# 改完文件后，从权威文件直接重设
gh secret set GUARD_KEYWORDS --repo imagrove/notes.imagrove.com < ~/.config/credentials/guard-keywords.imagrove.txt
```

**重设 Secret 后必须再触发一次构建**，`gh workflow run hugo.yml`。因为护栏是在构建前跑的，上一次被拦下的那篇并不会因为词库改了就自己上线；不重跑，维护者会以为已经好了而文章其实还在门外。

收词规则：只收**拉丁字母标识符**（客户品牌名、公司名、内部产品代号）。纯中文词（如“香薰机控制器”）不收——铁律一本来就允许写“某个客户的香薰机控制器项目”，拦它就是把护栏变成捣乱工具。

两个已知代价，都是当下的，不是未来的：
- **短词会误伤**。`BMC` 在台账里是客户名，同时又是基板管理控制器的通用缩写。现在它是硬门禁，一旦他在文章里正当用到这个词，整站会停止更新（不砸站，但新文章发不出去）。要么删词，要么改成更长的全名降低撞车概率。
- **词库命中无豁免通道**。`guard.sh` 的词库分支已经不再识别 `guard-allow`，因为豁免只让扫描闭眼、那个词照样发布（页面正文与 RSS），等于白脱敏。误伤只能靠删词或改措辞。
