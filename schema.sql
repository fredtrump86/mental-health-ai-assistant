-- 心理健康助手数据库结构
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE `ai_analysis_task`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `diary_id` bigint NOT NULL COMMENT '日记ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务状态：PENDING-待处理，PROCESSING-处理中，COMPLETED-已完成，FAILED-失败',
  `task_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务类型：AUTO-自动触发，MANUAL-手动触发，ADMIN-管理员触发，BATCH-批量触发',
  `priority` int NOT NULL DEFAULT 2 COMMENT '优先级：1-低，2-正常，3-高，4-紧急',
  `retry_count` int NOT NULL DEFAULT 0 COMMENT '重试次数',
  `max_retry_count` int NOT NULL DEFAULT 3 COMMENT '最大重试次数',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '错误信息',
  `started_at` datetime NULL DEFAULT NULL COMMENT '处理开始时间',
  `completed_at` datetime NULL DEFAULT NULL COMMENT '处理完成时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_diary_id`(`diary_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_task_type`(`task_type` ASC) USING BTREE,
  INDEX `idx_priority`(`priority` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_status_priority`(`status` ASC, `priority` ASC) USING BTREE,
  INDEX `idx_status_created_at`(`status` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_task_type_created_at`(`task_type` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_retry_status`(`status` ASC, `retry_count` ASC, `max_retry_count` ASC) USING BTREE,
  CONSTRAINT `fk_ai_task_diary` FOREIGN KEY (`diary_id`) REFERENCES `emotion_diary` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_ai_task_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI分析任务表' ROW_FORMAT = Dynamic;

CREATE TABLE `consultation_message`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `session_id` bigint NOT NULL COMMENT '会话ID',
  `sender_type` tinyint NOT NULL COMMENT '发送者类型 1:用户 2:AI助手',
  `message_type` tinyint NULL DEFAULT 1 COMMENT '消息类型 1:文本',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '消息内容',
  `emotion_tag` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '情绪标签',
  `ai_model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '使用的AI模型',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_session_message`(`session_id` ASC, `created_at` ASC) USING BTREE,
  CONSTRAINT `consultation_message_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `consultation_session` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '咨询消息表' ROW_FORMAT = Dynamic;

CREATE TABLE `consultation_session`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '会话ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `session_title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会话标题',
  `started_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `last_emotion_analysis` json NULL COMMENT '最后一次情绪分析结果(JSON格式)',
  `last_emotion_updated_at` datetime NULL DEFAULT NULL COMMENT '最后一次情绪分析更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_session`(`user_id` ASC, `started_at` ASC) USING BTREE,
  INDEX `idx_last_emotion_updated_at`(`last_emotion_updated_at` ASC) USING BTREE,
  CONSTRAINT `consultation_session_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '咨询会话表' ROW_FORMAT = Dynamic;

CREATE TABLE `emotion_diary`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '日记ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `diary_date` date NOT NULL COMMENT '日记日期',
  `mood_score` tinyint NOT NULL COMMENT '情绪评分(1-10)',
  `dominant_emotion` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '主要情绪',
  `emotion_triggers` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '情绪触发因素',
  `diary_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '日记内容',
  `sleep_quality` tinyint NULL DEFAULT NULL COMMENT '睡眠质量(1-5)',
  `stress_level` tinyint NULL DEFAULT NULL COMMENT '压力水平(1-5)',
  `ai_emotion_analysis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI情绪分析结果(JSON格式)',
  `ai_analysis_updated_at` datetime NULL DEFAULT NULL COMMENT 'AI分析更新时间',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `user_date_unique`(`user_id` ASC, `diary_date` ASC) USING BTREE,
  INDEX `idx_user_diary`(`user_id` ASC, `diary_date` ASC) USING BTREE,
  INDEX `idx_ai_analysis_time`(`ai_analysis_updated_at` ASC) USING BTREE,
  CONSTRAINT `emotion_diary_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '情绪日记表' ROW_FORMAT = Dynamic;

CREATE TABLE `knowledge_article`  (
  `id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '文章ID(UUID)',
  `category_id` bigint NOT NULL COMMENT '分类ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '文章标题',
  `summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '文章摘要',
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '文章内容',
  `cover_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '封面图片',
  `tags` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标签',
  `author_id` bigint NULL DEFAULT NULL COMMENT '作者ID',
  `read_count` int NULL DEFAULT 0 COMMENT '阅读次数',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态 1:已发布',
  `published_at` datetime NULL DEFAULT NULL COMMENT '发布时间',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `author_id`(`author_id` ASC) USING BTREE,
  INDEX `idx_category_article`(`category_id` ASC, `published_at` ASC) USING BTREE,
  INDEX `idx_title`(`title` ASC) USING BTREE,
  CONSTRAINT `knowledge_article_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `knowledge_category` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `knowledge_article_ibfk_2` FOREIGN KEY (`author_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '知识文章表' ROW_FORMAT = Dynamic;

CREATE TABLE `knowledge_category`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父分类ID',
  `category_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '分类名称',
  `category_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分类代码',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '分类描述',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态 0:禁用 1:启用',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `category_code`(`category_code` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  INDEX `idx_sort_order`(`sort_order` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '知识文章分类表' ROW_FORMAT = Dynamic;

CREATE TABLE `sys_file_info`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '文件ID，主键自增',
  `original_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '原始文件名（用户上传时的文件名）',
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '文件访问路径（服务器存储路径）',
  `file_size` bigint NOT NULL DEFAULT 0 COMMENT '文件大小，单位：字节',
  `file_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '文件类型（IMG/PDF/TXT/DOC/XLS等）',
  `business_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务类型（用于区分文件用途，如：avatar/document/attachment）',
  `business_id` char(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务对象ID（关联的业务数据主键）',
  `business_field` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务字段名（对应业务表中的字段名）',
  `upload_user_id` bigint NULL DEFAULT NULL COMMENT '上传用户ID（记录谁上传的文件）',
  `is_temp` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否临时文件（0:否 1:是）',
  `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态（0:删除 1:正常）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `expire_time` datetime NULL DEFAULT NULL COMMENT '过期时间（仅对临时文件有效）',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_business`(`business_type` ASC, `business_id` ASC) USING BTREE,
  INDEX `idx_upload_user`(`upload_user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_temp_expire`(`is_temp` ASC, `expire_time` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统文件信息表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码',
  `nickname` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像URL',
  `gender` tinyint NULL DEFAULT NULL COMMENT '性别 0:未知 1:男 2:女',
  `birthday` date NULL DEFAULT NULL COMMENT '生日',
  `user_type` tinyint NULL DEFAULT 1 COMMENT '用户类型 1:普通用户 2:管理员',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态 0:禁用 1:正常',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE,
  UNIQUE INDEX `phone`(`phone` ASC) USING BTREE,
  INDEX `idx_username`(`username` ASC) USING BTREE,
  INDEX `idx_user_type`(`user_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

CREATE TABLE `user_favorite`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `article_id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '文章ID',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `user_article_unique`(`user_id` ASC, `article_id` ASC) USING BTREE,
  INDEX `article_id`(`article_id` ASC) USING BTREE,
  CONSTRAINT `user_favorite_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `user_favorite_ibfk_2` FOREIGN KEY (`article_id`) REFERENCES `knowledge_article` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户收藏表' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
