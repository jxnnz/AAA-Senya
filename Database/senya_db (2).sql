-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 23, 2025 at 05:31 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `senya_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `accounts`
--

CREATE TABLE `accounts` (
  `user_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `hash_password` varchar(255) NOT NULL,
  `role` enum('user','admin') DEFAULT 'user',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_login` timestamp NULL DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `accounts`
--

INSERT INTO `accounts` (`user_id`, `name`, `email`, `hash_password`, `role`, `created_at`, `last_login`, `status`) VALUES
(7, 'Alexies s. Nilo', 'niloalexies@gmail.com', '$2b$12$vbtYTyVaoRvh9ewfd.CLhud9QNix9PmPKJmNApy0/pYcV.lmNqtF6', 'admin', '2025-04-13 07:03:22', '2025-04-22 19:16:45', 'active'),
(8, 'Cristina Alipio', 'cristina@gmail.com', '$2b$12$fnlfs2U0.UqgmTLt5bzZ.OC54nRxrYh0IousFK6UECzmGSM97EfPK', 'user', '2025-04-14 02:37:08', '2025-04-22 02:09:25', 'active'),
(9, 'Julia Rose Arenas', 'rose@example.com', '$2b$12$QI2by3ghsv.rWtFNjdKosO6fJIuWj4SNK2UN/WGjtV569QPJ841yO', 'user', '2025-04-14 03:33:33', '2025-04-13 20:11:06', 'active'),
(10, 'Julia Rose Arena', 'juliarose@gmail.com', '$2b$12$0jlmiOpFRBsWAmIWr2fbYepd5HA6R.yDWWhc9CgaIx/cbk042ORtG', 'user', '2025-04-14 05:04:32', '2025-04-22 03:10:30', 'active'),
(11, 'Jenny Amplogio', 'jenny@gmail.com', '$2b$12$f4NPyUM3ZM5d05iaJ0ABAumq03PpbyCfgp/vqnWkL9HWqHpQle962', 'user', '2025-04-21 14:14:04', '2025-04-22 19:26:04', 'active'),
(12, 'Kim Sunoo', 'sunsun@gmail.com', '$2b$12$spDh4mkNfcoI9cHE7BMkTu2V0xyz1AyqTMDPK8HjYxBLVBzlyvY9y', 'user', '2025-04-22 09:28:44', '2025-04-22 02:03:26', 'active');

-- --------------------------------------------------------

--
-- Table structure for table `heart_packages`
--

CREATE TABLE `heart_packages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `hearts_amount` int(11) NOT NULL,
  `ruby_cost` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `heart_packages`
--

INSERT INTO `heart_packages` (`id`, `name`, `hearts_amount`, `ruby_cost`) VALUES
(1, 'Single Heart', 1, 10),
(2, 'Triple Hearts', 3, 30),
(3, 'Full Hearts', 5, 45);

-- --------------------------------------------------------

--
-- Table structure for table `lessons`
--

CREATE TABLE `lessons` (
  `id` int(11) NOT NULL,
  `unit_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `rubies_reward` int(11) DEFAULT 0,
  `order_index` int(11) DEFAULT 0,
  `status` enum('active','draft','archived') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `archived` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `lessons`
--

INSERT INTO `lessons` (`id`, `unit_id`, `title`, `description`, `rubies_reward`, `order_index`, `status`, `created_at`, `updated_at`, `archived`) VALUES
(4133, 8, 'Lesson 1: Introduction', 'Objective: Learn frequently used words in daily conversations related to communication and\r\nlearning.\r\n', 20, 1, 'active', '2025-04-20 14:05:12', '2025-04-20 17:29:27', 1),
(4135, 8, 'Lesson 2: The Alphabet (A-M)', 'Objective: Learn the first half of the fingerspelled alphabet. ', 20, 2, 'active', '2025-04-20 14:10:40', '2025-04-20 17:29:05', 0),
(4136, 8, 'Lesson 3: The Alphabet (N-Z)', 'Objective: Learn the second half of the fingerspelled alphabet.', 20, 3, 'active', '2025-04-20 14:11:26', '2025-04-20 16:00:12', 1),
(4137, 9, 'Lesson 1: Basic Greetings & Expressions', 'Objective: Learn common greetings and polite expressions for daily use. ', 20, 1, 'active', '2025-04-20 14:13:59', '2025-04-20 14:13:59', 0),
(4138, 9, 'Lesson 2: Introducing Yourself & Asking Questions', 'Objective: Say your name, introduce yourself, and ask for someone\'s name. ', 20, 2, 'active', '2025-04-20 14:14:33', '2025-04-20 14:14:33', 0),
(4139, 8, 'Lesson 3: D-F', 'Learn D to F', 20, 3, 'active', '2025-04-20 16:00:44', '2025-04-20 16:00:44', 0),
(4140, 8, 'Lesson 1', '', 20, 1, 'active', '2025-04-21 02:40:03', '2025-04-21 02:40:03', 0),
(4141, 8, 'Lesson 4', '', 0, 0, 'active', '2025-04-21 11:35:02', '2025-04-21 11:35:06', 1),
(4142, 10, 'test', 'hey', 5, 1, 'active', '2025-04-21 11:55:17', '2025-04-21 11:55:17', 0);

-- --------------------------------------------------------

--
-- Table structure for table `practice_games`
--

CREATE TABLE `practice_games` (
  `id` int(11) NOT NULL,
  `level_id` int(11) NOT NULL,
  `game_identifier` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `practice_games`
--

INSERT INTO `practice_games` (`id`, `level_id`, `game_identifier`, `name`, `description`, `created_at`, `updated_at`) VALUES
(1, 10, 'matching', 'Matching Game', 'Match signs with their meanings', '2025-04-21 03:55:11', '2025-04-21 03:55:11'),
(2, 10, 'identification', 'Sign Identification', 'Identify the correct meaning for each sign', '2025-04-21 03:55:11', '2025-04-21 03:55:11'),
(3, 11, 'speed', 'Speed Challenge', 'Identify signs as quickly as possible', '2025-04-21 03:55:11', '2025-04-21 03:55:11'),
(4, 11, 'sequence', 'Sequence Memory', 'Remember and reproduce sequences of signs', '2025-04-21 03:55:11', '2025-04-21 03:55:11'),
(5, 12, 'advanced-matching', 'Advanced Matching', 'Match multiple signs in context', '2025-04-21 03:55:11', '2025-04-21 03:55:11'),
(6, 12, 'sentence', 'Sentence Building', 'Build complete sentences using signs', '2025-04-21 03:55:11', '2025-04-21 03:55:11');

-- --------------------------------------------------------

--
-- Table structure for table `practice_levels`
--

CREATE TABLE `practice_levels` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `required_progress` int(11) DEFAULT NULL,
  `order_index` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `practice_levels`
--

INSERT INTO `practice_levels` (`id`, `name`, `description`, `required_progress`, `order_index`, `created_at`, `updated_at`) VALUES
(10, 'Beginner', 'Learn basic sign language gestures', 0, 0, '2025-04-21 03:47:59', '2025-04-21 03:47:59'),
(11, 'Intermediate', 'Practice common phrases and expressions', 30, 1, '2025-04-21 03:47:59', '2025-04-21 03:47:59'),
(12, 'Advanced', 'Master complex conversations and storytelling', 50, 2, '2025-04-21 03:47:59', '2025-04-21 03:47:59');

-- --------------------------------------------------------

--
-- Table structure for table `signs`
--

CREATE TABLE `signs` (
  `id` int(11) NOT NULL,
  `text` varchar(255) NOT NULL,
  `video_url` varchar(512) NOT NULL,
  `difficulty_level` enum('beginner','intermediate','advanced') DEFAULT 'beginner',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `archived` tinyint(1) DEFAULT 0,
  `lesson_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `signs`
--

INSERT INTO `signs` (`id`, `text`, `video_url`, `difficulty_level`, `created_at`, `archived`, `lesson_id`) VALUES
(21, 'Hello', 'https://senya-video-server.senya-videos.workers.dev/64a14fa7-d5f3-4c38-9ac2-6304399e950f.mp4', 'beginner', '2025-04-20 14:24:51', 1, 4133),
(22, 'Hello', 'https://senya-video-server.senya-videos.workers.dev/7d8bd968-e56b-4a49-82cc-f6c342f29f86.mp4', 'beginner', '2025-04-20 14:28:44', 0, 4133),
(23, 'hi', 'https://senya-video-server.senya-videos.workers.dev/63741218-f47c-48e0-a6b4-61b287c52fb3.mp4', 'beginner', '2025-04-20 14:29:42', 0, 4133),
(24, 'whats up', 'https://senya-video-server.senya-videos.workers.dev/8ffba843-83e9-46c3-8a98-e38a1e5d4caa.mp4', 'intermediate', '2025-04-20 14:30:20', 0, 4133),
(25, 'A', 'https://senya-video-server.senya-videos.workers.dev/f9ee0114-f9b8-432b-bf49-d84f7f8caff2.mp4', 'advanced', '2025-04-20 14:39:35', 0, 4135),
(26, 'B', 'https://senya-video-server.senya-videos.workers.dev/486630ec-259c-49e1-aab6-37c88d5aa6b9.mp4', 'advanced', '2025-04-20 14:40:04', 0, 4135),
(27, 'C', 'https://senya-video-server.senya-videos.workers.dev/25375861-aa75-406f-b6de-2d7b59470316.mp4', 'advanced', '2025-04-20 14:40:29', 0, 4135),
(31, 'How You', 'https://senya-video-server.senya-videos.workers.dev/2195dc8a-3bb1-4ddd-abc7-3d20d1b3904d.mp4', 'advanced', '2025-04-20 14:43:18', 0, 4137),
(32, 'You Good?', 'https://senya-video-server.senya-videos.workers.dev/b35854bb-10bb-4f20-b67b-e4833f2d4975.mp4', 'advanced', '2025-04-20 14:43:43', 0, 4137),
(33, 'I\'m Deaf', 'https://senya-video-server.senya-videos.workers.dev/d3a3580f-d125-4f49-bca3-c51ce05c3e08.mp4', 'beginner', '2025-04-20 14:47:46', 0, 4138),
(34, 'I\'m Hearing', 'https://senya-video-server.senya-videos.workers.dev/dc573eca-b0a3-45fe-88be-2405da08a95d.mp4', 'intermediate', '2025-04-20 14:48:16', 0, 4138),
(35, 'D', 'https://senya-video-server.senya-videos.workers.dev/c49cb2aa-e110-406d-826f-e8c1491e2cce.mp4', 'advanced', '2025-04-20 16:01:29', 0, 4139),
(36, 'Hello', 'https://senya-video-server.senya-videos.workers.dev/bcbe04fd-cdda-49f3-be4f-8d3cdf8c74b6.mp4', 'intermediate', '2025-04-21 02:41:22', 0, 4140),
(37, 'HI', 'https://senya-video-server.senya-videos.workers.dev/f956d16b-fed1-4ce8-8f0b-3c18420bab26.mp4', 'intermediate', '2025-04-21 02:42:07', 0, 4140),
(38, 'E', 'https://senya-video-server.senya-videos.workers.dev/82273b0e-cdc3-4bea-9741-32a7a63efba0.mp4', 'advanced', '2025-04-21 02:46:59', 0, 4139),
(39, 'F', 'https://senya-video-server.senya-videos.workers.dev/34e7ef37-d2dd-4191-b6d3-6bb874ff396f.mp4', 'advanced', '2025-04-21 02:47:28', 0, 4139),
(40, 'test', 'https://senya-video-server.senya-videos.workers.dev/9ddbbd66-9c92-4ff6-9cff-4b5d079e7016.mp4', 'beginner', '2025-04-21 12:13:01', 0, 4142);

-- --------------------------------------------------------

--
-- Table structure for table `units`
--

CREATE TABLE `units` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `order_index` int(11) DEFAULT 0,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `archived` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `units`
--

INSERT INTO `units` (`id`, `title`, `description`, `order_index`, `status`, `created_at`, `updated_at`, `archived`) VALUES
(8, 'Unit 1: The Basics', '', 1, 'active', '2025-04-20 14:04:24', '2025-04-20 14:04:24', 0),
(9, 'Unit 2: Daily Greetings & Expressions', '', 2, 'active', '2025-04-20 14:12:59', '2025-04-20 14:12:59', 0),
(10, 'Lesson 3', 'test', 3, 'active', '2025-04-21 11:55:00', '2025-04-21 11:55:00', 0);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `profile_url` varchar(512) DEFAULT NULL,
  `progress` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`progress`)),
  `rubies` int(11) DEFAULT 0,
  `hearts` int(11) DEFAULT 5,
  `streak` int(11) DEFAULT 0,
  `certificate` tinyint(1) DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `hearts_last_updated` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_lesson_date` timestamp NULL DEFAULT NULL,
  `streak_updated_today` tinyint(1) DEFAULT 0,
  `last_challenge_date` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `profile_url`, `progress`, `rubies`, `hearts`, `streak`, `certificate`, `updated_at`, `hearts_last_updated`, `last_lesson_date`, `streak_updated_today`, `last_challenge_date`) VALUES
(7, '/static/images/profiles/7/d9b0c14a-cb8b-4cdb-b2cc-2b3e8b2dc1be.png', '{}', 80, 5, 3, 1, '2025-04-22 15:38:24', '2025-04-22 07:38:23', '2025-04-21 04:09:42', 0, '2025-04-22 00:37:06'),
(8, NULL, '{}', 15, 5, 0, 0, '2025-04-22 10:09:26', '2025-04-22 02:07:08', NULL, 0, NULL),
(9, NULL, '{}', 20, 0, 1, 0, '2025-04-14 04:19:28', '2025-04-14 03:33:33', '2025-04-13 20:19:01', 0, NULL),
(10, '/static/images/profiles/10/448bbbcf-cd55-43a3-a15f-6cc0ea305e68.png', '{}', 242, 3, 3, 1, '2025-04-22 11:38:52', '2025-04-22 03:34:32', '2025-04-21 19:54:26', 0, '2025-04-19 18:34:26'),
(11, NULL, '{}', 115, 4, 3, 1, '2025-04-23 03:28:23', '2025-04-22 19:24:04', '2025-04-22 19:27:44', 0, '2025-04-22 19:27:52'),
(12, NULL, '{}', 70, 4, 1, 0, '2025-04-22 09:54:01', '2025-04-22 09:28:44', '2025-04-22 01:53:31', 0, '2025-04-22 01:54:01');

-- --------------------------------------------------------

--
-- Table structure for table `user_practice_progress`
--

CREATE TABLE `user_practice_progress` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `level_id` int(11) DEFAULT NULL,
  `game_id` int(11) DEFAULT NULL,
  `high_score` int(11) DEFAULT NULL,
  `progress` int(11) DEFAULT NULL,
  `completed` tinyint(1) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `user_practice_progress`
--

INSERT INTO `user_practice_progress` (`id`, `user_id`, `level_id`, `game_id`, `high_score`, `progress`, `completed`, `created_at`, `updated_at`) VALUES
(1, 7, 10, 1, 143, 100, 1, '2025-04-21 03:59:34', '2025-04-21 04:00:12'),
(2, 10, 10, 1, 144, 100, 1, '2025-04-21 04:11:32', '2025-04-21 04:11:32'),
(3, 10, 10, 2, 85, 85, 1, '2025-04-21 04:11:50', '2025-04-21 04:11:50'),
(4, 10, 12, 6, 148, 100, 1, '2025-04-21 06:28:14', '2025-04-21 09:47:57'),
(5, 10, 11, 4, 0, 0, 0, '2025-04-21 06:31:00', '2025-04-21 06:31:00'),
(6, 10, 11, 3, 184, 100, 1, '2025-04-21 06:32:51', '2025-04-21 08:31:08'),
(7, 10, 12, 5, 0, 0, 0, '2025-04-21 09:44:56', '2025-04-21 09:44:56'),
(8, 7, 10, 2, 61, 61, 0, '2025-04-21 11:12:20', '2025-04-21 15:36:45'),
(9, 7, 11, 3, 0, 0, 0, '2025-04-22 03:45:24', '2025-04-22 03:45:24'),
(10, 7, 11, 4, 0, 0, 0, '2025-04-22 03:45:27', '2025-04-22 03:45:27'),
(11, 11, 10, 2, 59, 59, 0, '2025-04-23 03:26:56', '2025-04-23 03:26:56');

-- --------------------------------------------------------

--
-- Table structure for table `user_progress`
--

CREATE TABLE `user_progress` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `lesson_id` int(11) DEFAULT NULL,
  `progress` int(11) DEFAULT NULL,
  `completed` tinyint(1) DEFAULT NULL,
  `last_question` int(11) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `user_progress`
--

INSERT INTO `user_progress` (`id`, `user_id`, `lesson_id`, `progress`, `completed`, `last_question`, `updated_at`) VALUES
(21, 10, 4133, 100, 1, 2, '2025-04-20 14:49:24'),
(22, 10, 4135, 100, 1, 2, '2025-04-20 15:03:38'),
(23, 7, 4135, 100, 1, 2, '2025-04-22 15:31:10'),
(24, 7, 4139, 100, 1, 2, '2025-04-21 12:11:21'),
(25, 7, 4137, 100, 1, 1, '2025-04-21 02:35:55'),
(26, 7, 4140, 83, 1, 1, '2025-04-22 15:32:57'),
(27, 10, 4140, 100, 1, 1, '2025-04-22 11:39:07'),
(28, 10, 4139, 100, 1, 2, '2025-04-21 06:27:53'),
(29, 10, 4137, 100, 1, 1, '2025-04-22 10:08:18'),
(30, 10, 4138, 100, 1, 1, '2025-04-22 03:54:09'),
(31, 7, 4138, 100, 1, 1, '2025-04-22 03:53:32'),
(32, 7, 4142, 67, 0, 0, '2025-04-21 13:17:42'),
(33, 11, 4140, 100, 1, 1, '2025-04-22 13:16:04'),
(34, 10, 4142, 100, 1, 0, '2025-04-22 03:54:26'),
(35, 11, 4135, 100, 1, 2, '2025-04-22 08:03:29'),
(36, 11, 4139, 100, 1, 2, '2025-04-22 08:03:55'),
(37, 11, 4138, 100, 1, 1, '2025-04-22 10:16:25'),
(38, 12, 4140, 100, 1, 1, '2025-04-22 09:45:23'),
(39, 12, 4135, 100, 1, 2, '2025-04-22 09:53:04'),
(40, 12, 4139, 100, 1, 2, '2025-04-22 09:53:31'),
(41, 12, 4137, 17, 0, 0, '2025-04-22 10:04:05'),
(42, 11, 4137, 100, 1, 1, '2025-04-22 10:10:02'),
(43, 11, 4142, 100, 1, 0, '2025-04-23 03:27:44');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `heart_packages`
--
ALTER TABLE `heart_packages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `lessons`
--
ALTER TABLE `lessons`
  ADD PRIMARY KEY (`id`),
  ADD KEY `unit_id` (`unit_id`);

--
-- Indexes for table `practice_games`
--
ALTER TABLE `practice_games`
  ADD PRIMARY KEY (`id`),
  ADD KEY `level_id` (`level_id`);

--
-- Indexes for table `practice_levels`
--
ALTER TABLE `practice_levels`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `signs`
--
ALTER TABLE `signs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `units`
--
ALTER TABLE `units`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `title` (`title`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `user_practice_progress`
--
ALTER TABLE `user_practice_progress`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `level_id` (`level_id`),
  ADD KEY `game_id` (`game_id`);

--
-- Indexes for table `user_progress`
--
ALTER TABLE `user_progress`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `lesson_id` (`lesson_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accounts`
--
ALTER TABLE `accounts`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `heart_packages`
--
ALTER TABLE `heart_packages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `lessons`
--
ALTER TABLE `lessons`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4143;

--
-- AUTO_INCREMENT for table `practice_games`
--
ALTER TABLE `practice_games`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `practice_levels`
--
ALTER TABLE `practice_levels`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `signs`
--
ALTER TABLE `signs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `units`
--
ALTER TABLE `units`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `user_practice_progress`
--
ALTER TABLE `user_practice_progress`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `user_progress`
--
ALTER TABLE `user_progress`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `lessons`
--
ALTER TABLE `lessons`
  ADD CONSTRAINT `lessons_ibfk_1` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`);

--
-- Constraints for table `practice_games`
--
ALTER TABLE `practice_games`
  ADD CONSTRAINT `practice_games_ibfk_1` FOREIGN KEY (`level_id`) REFERENCES `practice_levels` (`id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `accounts` (`user_id`);

--
-- Constraints for table `user_practice_progress`
--
ALTER TABLE `user_practice_progress`
  ADD CONSTRAINT `user_practice_progress_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `accounts` (`user_id`),
  ADD CONSTRAINT `user_practice_progress_ibfk_2` FOREIGN KEY (`level_id`) REFERENCES `practice_levels` (`id`),
  ADD CONSTRAINT `user_practice_progress_ibfk_3` FOREIGN KEY (`game_id`) REFERENCES `practice_games` (`id`);

--
-- Constraints for table `user_progress`
--
ALTER TABLE `user_progress`
  ADD CONSTRAINT `user_progress_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `accounts` (`user_id`),
  ADD CONSTRAINT `user_progress_ibfk_2` FOREIGN KEY (`lesson_id`) REFERENCES `lessons` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
