CREATE TABLE IF NOT EXISTS contents (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    type TINYINT
-- 0: user, 1: collection, 2: post, 3: draft, 4: novel_page, 5: pic_page, 6: audio_track,
-- 7: video_clip, 8: comment, 9: import, 10: export, 11: report, 12: media_job
    );

CREATE TABLE IF NOT EXISTS users(
    id BIGINT PRIMARY KEY,
    username VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    role TINYINT DEFAULT 0 NOT NULL, -- 0: USER, 1: MODERATOR, 2: ADMIN
    display_name VARCHAR(30),
    bio VARCHAR(200),
    icon_url TEXT,
    follower_count INT DEFAULT 0 NOT NULL,
    followee_count INT DEFAULT 0 NOT NULL,
    like_count INT DEFAULT 0 NOT NULL,
    spread_count INT DEFAULT 0 NOT NULL,
    comment_count INT DEFAULT 0 NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME DEFAULT NULL,

    FOREIGN KEY (id) REFERENCES contents(id) ON DELETE CASCADE

);

CREATE TABLE IF NOT EXISTS user_settings (
    user_id BIGINT PRIMARY KEY,
    suffix TINYINT DEFAULT 0 NOT NULL, -- 0: none, 1: kun, 2: chan
    FF_display TINYINT DEFAULT 1 NOT NULL, -- 0:hidden, 1: public
    publish_micro_post TINYINT DEFAULT 1 NOT NULL, -- 0:hidden, 1: public
    publish_novel_post TINYINT DEFAULT 1 NOT NULL, -- 0:hidden, 1: public
    publish_pic_post TINYINT DEFAULT 1 NOT NULL, -- 0:hidden, 1: public
    publish_audio_post TINYINT DEFAULT 1 NOT NULL, -- 0:hidden, 1: public
    publish_video_post TINYINT DEFAULT 1 NOT NULL, -- 0:hidden, 1: public
    consume_micro_post TINYINT DEFAULT 1 NOT NULL, -- 0:hidden, 1: consume
    consume_novel_post TINYINT DEFAULT 1 NOT NULL, -- 0:hidden, 1: consume
    consume_pic_post TINYINT DEFAULT 1 NOT NULL, -- 0:hidden, 1: consume
    consume_audio_post TINYINT DEFAULT 1 NOT NULL, -- 0:hidden, 1: consume
    consume_video_post TINYINT DEFAULT 1 NOT NULL, -- 0:hidden, 1: consume
    notify_followed TINYINT DEFAULT 1 NOT NULL, -- 0: OFF, 1: ON
    notify_commented TINYINT DEFAULT 1 NOT NULL, -- 0: OFF, 1: ON
    notify_liked TINYINT DEFAULT 1 NOT NULL, -- 0: OFF, 1: ON
    notify_spread TINYINT DEFAULT 1 NOT NULL, -- 0: OFF, 1: ON
    notify_completed TINYINT DEFAULT 1 NOT NULL, -- 0: OFF, 1: ON
    repeat TINYINT DEFAULT 0 NOT NULL, -- 0: OFF, 1: one_track, 2: ALL
    shuffle  TINYINT DEFAULT 0 NOT NULL, -- 0: OFF, 1: ON

    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE

);

CREATE TABLE IF NOT EXISTS posts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    visibility TINYINT DEFAULT 0 NOT NULL, -- 0: public, 1: except_followers, 2: followers, 3: private
    pinned TINYINT DEFAULT 0 NOT NULL, -- 0: false, 1: true
    media_type TINYINT DEFAULT 0 NOT NULL, -- 0: MICRO_POST, 1: NOVEL_POST, 2: PIC_POST, 3: AUDIO_POST, 4: VIDEO_POST
    like_count INT DEFAULT 0 NOT NULL,
    spread_count INT DEFAULT 0 NOT NULL,
    comment_count INT DEFAULT 0 NOT NULL,
    complete_count INT DEFAULT 0 NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    deleted_at DATETIME DEFAULT NULL,

    FOREIGN KEY (id) REFERENCES contents(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    INDEX idx_userId_createdAt (user_id, deleted_at, created_at),
    INDEX idx_mediaType_createdAt (media_type, created_at),
    INDEX idx_mediaType_likeCount (media_type, like_count),
    INDEX idx_mediaType_spreadCount (media_type, spread_count),
    INDEX idx_mediaType_commentCount (media_type, comment_count)
    );

CREATE TABLE IF NOT EXISTS drafts (
    id BIGINT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    media_type TINYINT NOT NULL -- 0: MICRO_POST, 1: NOVEL_POST, 2: PIC_POST, 3: AUDIO_POST, 4: VIDEO_POST
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (id) REFERENCES contents(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS micro_posts(
    post_id	BIGINT PRIMARY KEY,
    body VARCHAR(150) NOT NULL,
    image_url1 TEXT,
    image_url2 TEXT,
    image_width INT,
    image_height INT,

    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS novel_posts (
    post_id	BIGINT PRIMARY KEY,
    collection_id BIGINT DEFAULT NULL,
    writing_mode TINYINT DEFAULT 0 NOT NULL, -- 0: HORIZONTAL, 1: VERTICAL
    page_direction TINYINT DEFAULT 0 NOT NULL, -- 0: LtoR, 1: RtoL
    description	VARCHAR(150),
    episode_title VARCHAR(30) DEFAULT "無題" NOT NULL,
    order_in_collection INT NOT NULL,
    total_pages	INT NOT NULL,

    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (collection_id) REFERENCES collections(id),

    INDEX idx_collectionId_orderInCollection (collection_id, order_in_collection)
);

CREATE TABLE IF NOT EXISTS novel_pages (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    novel_post_id BIGINT NOT NULL,
    page_number	INT NOT NULL,
    content	TEXT,
    sort_order INT NOT NULL,
    like_count INT DEFAULT 0 NOT NULL,
    comment_count INT DEFAULT 0 NOT NULL,

    FOREIGN KEY (id) REFERENCES contents(id),
    FOREIGN KEY (novel_post_id) REFERENCES novel_posts(post_id) ON DELETE CASCADE,

    INDEX idx_novelPostId_sortOrder (novel_post_id, sort_order)
);

CREATE TABLE IF NOT EXISTS pic_posts (
    post_id	BIGINT PRIMARY KEY,
    collection_id BIGINT DEFAULT NULL,
    page_direction TINYINT DEFAULT 0 NOT NULL, -- 0: LtoR, 1: RtoL
    description	VARCHAR(150),
    episode_title VARCHAR(30) DEFAULT "無題" NOT NULL,
    order_in_collection INT NOT NULL,
    total_pages	INT NOT NULL,

    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (collection_id) REFERENCES collections(id),

    INDEX idx_collectionId_orderInCollection (collection_id, order_in_collection)
);

CREATE TABLE IF NOT EXISTS pic_pages (
    id BIGINT PRIMARY KEY,
    pic_post_id	BIGINT NOT NULL,
    image_url TEXT NOT NULL,
    width INT NOT NULL,
    height INT NOT NULL,
    sort_order INT NOT NULL,
    like_count INT DEFAULT 0 NOT NULL,
    comment_count INT DEFAULT 0 NOT NULL,

    FOREIGN KEY (id) REFERENCES contents(id),
    FOREIGN KEY (pic_post_id) REFERENCES pic_posts(post_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS audio_posts (
    post_id	BIGINT PRIMARY KEY,
    description	VARCHAR(150),
    total_duration INT NOT NULL,

    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS audio_tracks (
    id BIGINT PRIMARY KEY,
    audio_post_id BIGINT NOT NULL,
    collection_id BIGINT DEFAULT NULL,
    audio_url TEXT NOT NULL,
    duration INT NOT NULL,
    sort_order INT NOT NULL,
    track_title VARCHAR(30) DEFAULT "無題" NOT NULL,
    order_in_collection INT,
    like_count INT DEFAULT 0 NOT NULL,
    comment_count INT DEFAULT 0 NOT NULL,
    completed_count INT DEFAULT 0 NOT NULL,

    FOREIGN KEY (id) REFERENCES contents(id),
    FOREIGN KEY (audio_post_id) REFERENCES audio_posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (collection_id) REFERENCES collections(id),

    INDEX idx_collectionId_orderInCollection (collection_id, order_in_collection)
);

CREATE TABLE IF NOT EXISTS video_posts (
    post_id BIGINT PRIMARY KEY,
    description VARCHAR(150),
    total_duration INT NOT NULL,

    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS video_clips (
    id BIGINT PRIMARY KEY,
    video_post_id BIGINT NOT NULL,
    collection_id BIGINT NOT NULL,
    video_url TEXT NOT NULL,
    duration INT NOT NULL,
    thumbnail_url TEXT NOT NULL,
    clip_title VARCHAR(30) DEFAULT "無題" NOT NULL,
    aspect_ratio TINYINT NOT NULL, -- 0: horizontal (16:9), 1: vertical (9:16), 2: square (1:1), 3: free
    width INT,
    height INT,
    sort_order INT NOT NULL,
    order_in_collection INT,
    like_count INT DEFAULT 0 NOT NULL,
    comment_count INT DEFAULT 0 NOT NULL,
    completed_count INT DEFAULT 0 NOT NULL,


    FOREIGN KEY (id) REFERENCES contents(id),
    FOREIGN KEY (video_post_id) REFERENCES video_posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (collection_id) REFERENCES collections(id),

    INDEX idx_collectionId_orderInCollection (collection_id, order_in_collection)
);

CREATE TABLE IF NOT EXISTS media_jobs (
    id BIGINT PRIMARY KEY,
    post_id	BIGINT NOT NULL,
    job_type TINYINT NOT NULL, -- 0: transcode, 1: thumbnail, 2: waveform
    status TINYINT, -- 0: PENDING, 1: PROCESSING, 2: COMPLETED, 3: FAILED
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    finished_at DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (id) REFERENCES contents(id),
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS collections (
    id BIGINT PRIMARY KEY,
    user_id	BIGINT NOT NULL,
    content_id BIGINT DEFAULT NULL,
    thumbnail_url TEXT NOT NULL,
    title VARCHAR(50),
    media_type TINYINT NOT NULL,
    description VARCHAR(200),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    follower_count INT DEFAULT 0 NOT NULL,
    like_count INT DEFAULT 0 NOT NULL,
    comment_count INT DEFAULT 0 NOT NULL,
    completed_count INT DEFAULT 0 NOT NULL,
    spread_count INT DEFAULT 0 NOT NULL,

    FOREIGN KEY (id) REFERENCES contents(id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (content_id) REFERENCES contents(id),
    FOREIGN KEY (media_type) REFERENCES contents(type),

    INDEX idx_userId_createdAt (user_id, created_at)
);

CREATE TABLE IF NOT EXISTS follows (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    follower_id	BIGINT NOT NULL,
    followee_id	BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (followee_id, follower_id),

    FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (followee_id) REFERENCES users(id) ON DELETE CASCADE,

    INDEX idx_followerId_followeeId (follower_id, followee_id)
);

CREATE TABLE IF NOT EXISTS follow_types (
    follow_id BIGINT NOT NULL,
    follow_type TINYINT NOT NULL, -- 0: MICRO_POST, 1: NOVEL_POST, 2: PIC_POST, 3: AUDIO_POST, 4: VIDEO_POST 5: COLLECTION
    PRIMARY KEY (follow_id, follow_type)
    FOREIGN KEY (follow_id) REFERENCES follows(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS conflicts (
    user_id BIGINT,
    target_user_id BIGINT,
    type TINYINT, -- 0: block, 1: mute
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    PRIMARY KEY (user_id, target_user_id, type),

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (target_user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS comments (
    id BIGINT PRIMARY KEY,
    user_id	BIGINT NOT NULL,
    pinned TINYINT DEFAULT 0 NOT NULL, -- 0: false, 1: true
    target_id BIGINT NOT NULL,
    parent_id BIGINT,
    body VARCHAR(150) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    like_count INT DEFAULT 0 NOT NULL,
    spread_count INT DEFAULT 0 NOT NULL,
    comment_count INT DEFAULT 0 NOT NULL,

    FOREIGN KEY (id) REFERENCES contents(id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (target_id) REFERENCES contents(id),
    FOREIGN KEY (parent_id) REFERENCES comments(id) ON DELETE CASCADE,

    INDEX idx_targetId_createdAt (target_id, created_at),
    INDEX idx_userId_createdAt (user_id, created_at),
    INDEX idx_parentId_createdAt (parent_id, created_at)
);

CREATE TABLE IF NOT EXISTS likes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    target_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (target_id) REFERENCES contents(id) ON DELETE CASCADE,

    UNIQUE (target_id, user_id),

    INDEX idx_userId_createdAt (user_id, created_at),
    INDEX idx_targetId_createdAt(target_id, created_at)
);

CREATE TABLE IF NOT EXISTS spreads (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    target_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (target_id) REFERENCES contents(id) ON DELETE CASCADE,

    UNIQUE (target_id, user_id),

    INDEX idx_userId_createdAt (user_id, created_at),
    INDEX idx_targetId_createdAt(target_id, created_at)
);

CREATE TABLE IF NOT EXISTS consumptions (
    user_id BIGINT PRIMARY KEY,
    target_id BIGINT NOT NULL,
    last_position INT DEFAULT NULL,
    is_completed TINYINT DEFAULT 0 NOT NULL, -- 0: false, 1: true

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (target_id) REFERENCES contents(id) ON DELETE CASCADE,

    UNIQUE (target_id, user_id),

    INDEX idx_targetID_isCompleted (target_id, is_completed)
);

CREATE TABLE IF NOT EXISTS imports (
    id BIGINT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    status TINYINT DEFAULT 0 NOT NULL, -- 0: PENDING, 1: PROCESSING, 2: COMPLETED, 3: FAILED
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (id) REFERENCES contents(id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS exports (
    id BIGINT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    status TINYINT DEFAULT 0 NOT NULL, -- 0: PENDING, 1: PROCESSING, 2: COMPLETED, 3: FAILED
    file_url TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (id) REFERENCES contents(id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS notifications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    actor_id BIGINT NOT NULL,
    target_id BIGINT NOT NULL,
    action_type TINYINT NOT NULL, --0: like, 1: spread, 2: comment, 3: follow, 4: post, 5: complete 6: private post
    is_read TINYINT DEFAULT 0 NOT NULL, -- 0: false, 1: true
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (actor_id) REFERENCES users(id),
    FOREIGN KEY (target_id) REFERENCES contents(id) ON DELETE CASCADE,

    UNIQUE (actor_id, target_id, action_type),

    INDEX idx_userId_createdAt (user_id, created_at)
);

CREATE TABLE IF NOT EXISTS reports (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    reporter_id BIGINT NOT NULL,
    target_id BIGINT NOT NULL,
    reason TINYINT NOT NULL, -- 0: SPAM, 1: HARASSMENT, 2: HATE_SPEECH, 3: SEXUAL_CONTENT, 4: VIOLENCE, 5: ILLEGAL_CONTENT, 6: COPYRIGHT, 7: MISINFORMATION
    status TINYINT NOT NULL, -- 0: NEW, 1: REVIEWING, 2: WAITING, 3: RESOLVED
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (reporter_id) REFERENCES users(id),
    FOREIGN KEY (target_id) REFERENCES contents(id) ON DELETE CASCADE,

    UNIQUE (target_id, reporter_id),

    INDEX idx_targetId_reason (target_id, reason),
    INDEX idx_status_createdAt (status, created_at)
);

CREATE TABLE IF NOT EXISTS moderation_actions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    report_id BIGINT NOT NULL,
    moderator_id BIGINT NOT NULL,
    action_type TINYINT NOT NULL, -- 0: nothing, 1: warn, 2: delete, 3: suspend, 4: ban
    note TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE,
    FOREIGN KEY (moderator_id) REFERENCES users(id),

    UNIQUE (report_id, moderator_id, action_type)
);

CREATE TABLE IF NOT EXISTS passkeys (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    credential_id VARBINARY(255) NOT NULL,
    public_key TEXT NOT NULL,
    sign_count INT NOT NULL,
    transports VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_used_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    UNIQUE (credential_id),

    INDEX idx_userId (user_id)
);

CREATE TABLE IF NOT EXISTS refresh_tokens (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    token_hash CHAR(64) NOT NULL,
    user_agent VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    expires_at DATETIME NOT NULL,
    revoked_at DATETIME DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    UNIQUE (token_hash),

    INDEX idx_userId (user_id),
    INDEX idx_expiresAt (expires_at)
);

CREATE TABLE IF NOT EXISTS api_limits (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    status TINYINT NOT NULL, -- 0: active 1: rate_limited 2: suspended 3: banned
    reason VARCHAR(200),
    limited_until DATETIME, -- NULL == 無制限
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    INDEX idx_useId (user_id)
);