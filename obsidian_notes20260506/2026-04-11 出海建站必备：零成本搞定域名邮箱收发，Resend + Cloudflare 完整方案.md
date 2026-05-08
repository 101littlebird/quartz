---
date: 2026-04-11T09:59:16
tags: []
---

出海建站必备：零成本搞定域名邮箱收发，Resend + Cloudflare 完整方案

sitin

@sitinme

·

22小时

之前写过两篇关于邮件的文章，一篇讲怎么用 Resend 搭邮件发送（注册验证、付款收据），一篇讲怎么做 Newsletter 订阅系统。

但有个问题一直没解决：用户怎么回复你？

网站上写个 support@yourdomain.com，用户真发邮件过来，你收不到。因为 Resend 只管发，不管收。

最近给网站配邮件收件的时候，发现 Cloudflare 有个免费功能叫 Email Routing，专门解决这个问题。配一次，永久免费，5 分钟搞定。

先理清楚：发和收是两件事

很多人搞混了。

发件 = Resend。你的系统主动给用户发邮件：注册验证码、付款成功通知、Newsletter。这个之前的文章讲过了。

收件 = Cloudflare Email Routing。用户主动给你发邮件：客服咨询、商务合作、问题反馈。今天讲这个。

两个加一起，你的域名邮箱就完整了。

Cloudflare Email Routing 是什么

简单说就是邮件转发。有人给你的域名邮箱发邮件，Cloudflare 帮你转到你的 Gmail 或者 QQ 邮箱。

你不需要搭邮件服务器，不需要装 Postfix，不需要买企业邮箱。Cloudflare 免费帮你干这个事。

几个关键点：

免费，没有付费门槛。最多 200 条转发规则，够用了。

不存邮件内容。Cloudflare 只做转发，不存储不读取，隐私没问题。

前提是你的域名得在 Cloudflare 托管。如果域名不在 Cloudflare，需要先把 NS 记录改过去。不过做出海的基本都在用 Cloudflare，这个应该不是问题。

配置步骤

整个过程 5 分钟。

第一步：进入 Email Routing

Cloudflare 后台左侧菜单，找到 Email Service → Email Routing。如果是新版 UI，在 Compute 分类下面。

选你的域名，点 Done 启用。Cloudflare 会自动添加需要的 MX 记录和 TXT 记录，不用手动配 DNS。

第二步：添加目标邮箱

点 Destination addresses，添加你的个人邮箱（比如你的 Gmail）。Cloudflare 会发一封验证邮件，点确认就行。

这一步是告诉 Cloudflare：转发过来的邮件发到哪里。

第三步：创建转发规则

点 Create address，填两个东西：

Custom address 填 support（就是 @ 前面的部分）。

Destination 选你刚验证的个人邮箱。

保存。完了。

现在有人给这个地址发邮件，你的 Gmail 就能收到。

实际用法

我们的一个出海网站配了这几个地址：

support@ 客服邮箱，放在网站的联系我们页面和页脚。

noreply@ 这个不配收件，只用 Resend 发出去。

你还可以配 hello@、contact@、billing@ 这些，都转到同一个 Gmail 就行。

如果开启 Catch-all，所有没有匹配到具体规则的邮件都会被兜底转发。比如有人手误发到 supprrt@，你也能收到。不过 Catch-all 也会接收到垃圾邮件，看你自己取舍。

和 Resend 的配合

两个一起用的完整方案：

系统发的邮件走 Resend。发件地址用 noreply@mail.yourdomain.com（子域名，之前文章讲过为什么）。

用户回复走 Cloudflare Email Routing。Resend 发邮件时设置 replyTo 为你的域名邮箱，用户点回复，邮件就到你的 Gmail 了。

代码里就是一个字段的事：

await resend.emails.send({ from: 'YourApp ', to: userEmail, replyTo: 'support@yourdomain.com',  // 用户回复到这里 subject: '付款成功', html: emailHtml, })

这样用户收到的邮件，点回复，邮件就到你的 Gmail 了。全程免费。

进阶：用 Gmail 回复时显示域名邮箱

有个问题，用户发邮件过来，你在 Gmail 里收到了，但回复的时候发件人显示的是你的 Gmail 地址，不是域名邮箱。

想让回复也显示域名邮箱，需要在 Gmail 里配置 Send As。

Gmail 设置 → 账号和导入 → 用这个地址发送邮件 → 添加其他电子邮件地址 → 填你的域名邮箱 → SMTP 用 Resend 的：

SMTP 服务器：smtp.resend.com 端口：465（SSL） 用户名：resend 密码：你的 Resend API Key

操作流程都在下面了。

配完之后，你在 Gmail 回复邮件时可以选择用域名邮箱作为发件人，对外看起来就很专业。

想同时转发到多个邮箱怎么办

实际场景里我想让客服邮件同时进 Gmail 和飞书邮箱——Gmail 用来回复，飞书用来存档和团队查看。

但 Cloudflare Email Routing 一条规则只能指向一个目标邮箱，不支持多选。

解决办法是用 Gmail 的筛选器再转发一次：

Cloudflare 把 support@ 转到 Gmail

Gmail 里创建一个筛选器，条件是 to: support@yourdomain.com，动作是 Forward to 飞书邮箱

完成后邮件会自动转两份

Gmail 筛选器的入口在搜索框右边的漏斗图标，点 Create filter，To 字段填你的域名邮箱，下一步勾选 Forward it to 并选择目标。注意飞书邮箱要先在 Gmail 设置里作为转发地址添加并验证过。

踩过的坑

Cloudflare 新版 UI 的 Done 按钮点不了。 我遇到过这个问题，换了几个浏览器都不行。后来发现是域名权限问题，不是 bug。如果你是团队协作，确保你的 Cloudflare 账号对这个域名有 DNS 编辑权限。用域名所有者的账号操作就没问题。

已有 MX 记录冲突。 如果你的域名之前配过其他邮件服务的 MX 记录（比如 Google Workspace），开启 Email Routing 时 Cloudflare 会提示冲突。需要先删掉旧的 MX 记录。如果你还在用那个邮件服务，就不要开 Email Routing，会冲突。

飞书邮箱、企业微信邮箱这些国内企业邮箱大概率不支持第三方 SMTP 别名。 我一开始想直接在飞书邮箱里配个 support@ 的发件身份，折腾半天发现飞书只支持同域名下的邮箱别名，不支持用 Resend SMTP 作为第三方发件身份。最后还是得用 Gmail。所以配 Send As 的时候优先选 Gmail，不要在国内企业邮箱上浪费时间。

Gmail Send As 的验证邮件要走 Cloudflare 转发。 配 Send As 时 Gmail 会发一封验证码邮件到 support@yourdomain.com，这封邮件会先到 Cloudflare，再转发到你 Gmail 自己。所以要先把 Cloudflare Email Routing 和 Gmail 筛选器都配好，Send As 才能完成验证。顺序不能乱。

成本

零。

Cloudflare Email Routing 完全免费，没有封数限制（转发不算在 Resend 的配额里）。

Resend 发件免费版每月 3000 封。

两个加一起，独立开发者在邮件这块不用花一分钱。

总结

三篇文章看下来，独立开发者的邮件方案就是：

Resend 负责发件（系统通知、Newsletter），之前两篇讲过了。

Cloudflare Email Routing 负责收件（客服、商务），今天这篇。

Gmail Send As 负责回复（让回复也显示域名邮箱），今天也讲了。

全免费，不用买企业邮箱，不用搭邮件服务器。5 分钟配好，一劳永逸。

欢迎关注，这个账号还会持续分享更多AI编程、出海工具、实战经验、踩坑记录。想了解更多可以加我 vx: 257735 聊。 

想发布自己的文章？升级为 Premium

sitin@sitinme

增长黑客/ 社群运营/AI 出海赚美刀 对爬虫和RPA机器人有一点研究，http://aigocode.com 擅长用AI搞点副业 / vx： 257735
