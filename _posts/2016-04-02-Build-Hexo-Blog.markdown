---
layout:     post
comments:   true
title:      "Hexo简单操作命令"
subtitle:   "\"Hexo命令\""
date:       2016-04-02 12:00:00
author:     "donnieSky"
header-img: "img/post-bg-hexo.jpg"
catalog:	true
tags:
    - Hexo
---

# Hexo操作记录

> 简单记录一下今天利用[Hexo][2]发布文章的相关操作

----

> * 修改`post`预设格式
> * 生成文章
> * 导航栏添加自定义页面

相关个人博客的搭建可以参考[使用GitHub和Hexo搭建免费静态Blog][1]

## 修改`post`预设格式
> 建议按照个人习惯修改`hexo\scaffolds`中的`post.md`

```code
---
title: {{ title }}
date: {{ date }}
categories:
description:
---
```

## 生成文章
> 文章如包含中文可以修改编码为`UTF-8`,避免乱码

1.使用命令生成初始文章，文件名之间有空格的    话会自动加`-` **中横线**

```code
hexo n "my post"  #双引号中填写要生成的文章名
```

2.在`hexo\source\_posts`中编辑生成出来的`my-post`文件

```code
---
title: my post  #可以改成中文的，如"我的文章"
date: 2016-04-02 22:13:43  #发表日期，可以自定义修改排序
categories: blog  #自定义文章分类
---
#这里是正文，用Markdown书写
```

3.本地预览文章内容，登录`localhost:4000`查看效果

```code
hexo s
```

4.发布内容到`public`文件夹中，然后手动复制同步`GitHub`

```code
hexo clean
hexo g
```

## 导航栏添加自定义页面

1.命令手动生成自定义页面

```code
hexo n page "about"
```

2.编辑`hexo/source/about/index.md`内容
3.修改你主题下的`themes/你的主题/_config.yml`文件

```code
menu:
  关于: /about
```

### Hexo简写命令

```code
hexo n #生成文章，或者source\_posts手动编辑
hexo s #本地发布预览效果
hexo g #生成public静态文件
```

相关内容可以参考[我博客的GitHub项目][3]


  [1]: http://wsgzao.github.io/post/hexo-guide/ 
  
  [2]: https://hexo.io/
  
  [3]: https://github.com/donniesky/donniesky.github.io

  [4]: http://mrfu.me/

  [5]: http://huangxuan.me/

  [6]: https://github.com/BlackrockDigital/startbootstrap-clean-blog-jekyll

  [7]: https://github.com/MrFuFuFu/mrfufufu.github.io