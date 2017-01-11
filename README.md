# Coding 
Ruby Rails搭建的一个web版代码生成工具。

原先是用Ruby写的，后来因为需要使用的人需要本地安装ruby和相关包，干脆用rails写了一个放服务器上，需要使用只要访问即可。已在日常开发中使用，由于保密问题，把很多代码删除只保留最简单的entity生成。
作用：

* 生成meta对象和so对象(没有任何查询条件，自行添加)
* 生成dao接口和dao实现类以及mapper配置文件等
* 其他类似类似service的代码（暂未开发）
* 在dao中默认生成了几个方法和默认实现,自行阅读。

### Coding的优缺点
#### 优点
* 提高开发效率，自动生成代码！更加专注于业务逻辑，减少一些重复工作和低级的拼写错误。
* 代码简洁、代码风格统一。
* 不影响原来的代码！原有的方式照样可以使用。
* 模板不适用可以自己改代码，只要会一点[rbTenjin](http://www.kuwata-lab.com/tenjin/rbtenjin-users-guide.html)

## 最后
讲一下思路：
1. 连接数据库，根据表名获取相应的字段、类型等信息。
2. 解析自己需要的东西，如db中是bill_no，java对象里应该是billNo。
3. 选择一款模板引擎，如Java 可以用freeMarker，python可以用Mako, ruby可以用rbtenjin
4. 根据需求编写然后生成模板即可，最后将生成的结果手动搬到项目中。

纯粹练手，后来还是在项目中使用了，Rails这东西真的很方便... 然后工具提高生产力。
