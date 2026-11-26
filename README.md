**心理健康 AI 助手**

自主开发的前后端分离 AI 应用，采用 Spring Boot、Spring AI 和 Vue 3，围绕日常情绪记录与心理支持场景，提供 AI 多轮对话、情绪日记、心理知识阅读和管理后台。

**主要功能**

- AI 对话通过 SSE 增量展示回复，支持咨询会话和历史消息查询。
- 会话上下文采用最近 30 条消息的滑动窗口，聊天记录保存到 MySQL。
- 情绪日记记录评分、主要情绪、触发因素、睡眠质量和压力水平，并异步生成分析结果。
- 知识库提供文章分类、阅读和收藏，后台支持内容和用户管理。
- 统计接口聚合情绪趋势、咨询记录及用户活跃情况，前端使用 ECharts 展示。

**技术栈**

| 部分 | 技术 |
| --- | --- |
| 后端 | Java 17、Spring Boot 3.4.1、Spring AI 1.0.0 |
| 数据访问 | MyBatis-Plus 3.5.7、MySQL |
| 身份处理 | JWT、BCrypt |
| 前端 | Vue 3、Vite、Pinia、Element Plus、Axios |
| 可视化 | ECharts、Three.js |
| 模型接口 | DeepSeek 官方 OpenAI 兼容接口 |
| 测试 | JUnit 5、Mockito |

**代码结构**

```text
.
├── springboot/
│   ├── src/main/java/org/example/springboot/
│   │   ├── controller/
│   │   ├── service/
│   │   ├── mapper/
│   │   ├── entity/
│   │   ├── DTO/
│   │   ├── AiService/
│   │   └── config/
│   ├── src/main/resources/application.yml
│   └── src/test/
├── vue3/
│   └── src/
│       ├── views/
│       ├── api/
│       ├── components/
│       ├── router/
│       └── store/
└── schema.sql
```

**核心调用流程**

AI 咨询由 Vue 页面发起请求，Controller 校验身份并调用 Spring AI，模型增量输出经 SSE 返回浏览器，完整回复保存到 MySQL。情绪日记保存后触发异步分析，结构化结果和任务状态写回数据库，供页面查询。

**本地启动**

准备 JDK 17、Maven 3.9、Node.js 与 npm、MySQL。以下命令适用于 Git Bash，前后端分别使用一个终端。

1. 启动本机 MySQL，进入仓库根目录并连接数据库。

   ```bash
   mysql -h 127.0.0.1 -P 3306 -u root -p --default-character-set=utf8mb4
   ```

2. 在 MySQL 命令行创建一个空数据库并导入表结构。

   ```sql
   CREATE DATABASE mental_health_assistant CHARACTER SET utf8mb4;
   USE mental_health_assistant;
   SOURCE schema.sql
   SHOW TABLES;
   EXIT;
   ```

   初始化文件包含 9 张业务表的结构。首次启动时业务数据为空，可通过注册页创建普通用户，管理端演示需自行准备管理员账号及知识文章。图片可在本地通过上传功能添加。

3. 在后端终端设置运行参数。

   ```bash
   read -rs -p "MySQL password: " SPRING_DATASOURCE_PASSWORD
   printf '\n'
   export SPRING_DATASOURCE_PASSWORD

   read -rs -p "DeepSeek API Key: " SPRING_AI_OPENAI_APIKEY
   printf '\n'
   export SPRING_AI_OPENAI_APIKEY

   export JWT_SECRET="$(node -e "process.stdout.write(require('node:crypto').randomBytes(32).toString('hex'))")"

   cd springboot
   mvn.cmd spring-boot:run
   ```

   Linux 和 macOS 使用 `mvn spring-boot:run`。模型默认配置为 `deepseek-v4-pro`，需使用个人 DeepSeek API Key，并确认账户可用模型及额度。数据库地址、端口和账号可在 `application.yml` 中调整。

4. 在另一个终端进入仓库的前端目录。

   ```bash
   cd vue3
   npm.cmd ci
   npm.cmd run dev
   ```

   Linux 和 macOS 使用 `npm ci` 和 `npm run dev`。

| 入口 | 地址 |
| --- | --- |
| 用户前台 | http://localhost:8800 |
| 后端健康检查 | http://localhost:1235/health |
| 管理后台 | http://localhost:8800/back/dashboard |

**测试与验证**

在 `springboot` 目录运行以下命令。

```bash
mvn.cmd test-compile
mvn.cmd -Dtest=UserServiceTest test
```

最近一次核心功能验证覆盖注册登录、日记保存、真实模型流式回复、消息持久化、文章收藏与取消收藏，以及统计接口查询。本项目的用户服务 20 项单元测试与前端生产构建均已通过。构建使用了 4 GB 的 Node.js 堆内存上限，部分前端分块仍有体积告警。集成测试和全量自动化测试仍需继续完善。

**配置约定**

数据库密码、模型 API Key 和 JWT 签名密钥通过环境变量提供。上传目录由应用在运行时维护。本地配置和新增密钥文件应遵循 `.gitignore` 的约定。
