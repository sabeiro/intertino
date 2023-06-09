-- phpMyAdmin SQL Dump
-- version 4.2.8.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Feb 25, 2015 at 10:42 PM
-- Server version: 5.5.30-1.1
-- PHP Version: 5.4.4-14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `kotoba`
--

-- --------------------------------------------------------

--
-- Table structure for table `login`
--

CREATE TABLE IF NOT EXISTS `login` (
`id_login` int(1) NOT NULL,
  `username_login` varchar(10) NOT NULL,
  `password_login` varchar(40) NOT NULL
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `login`
--

INSERT INTO `login` (`id_login`, `username_login`, `password_login`) VALUES
(1, 'admin', '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8'),
(7, 'jac', '195ed606a71c4d4770994d6ed57adfcb'),
(4, 'sabeiro', 'c0ba6c31076662fc7e4b1b8c8709e73cd9311224'),
(8, 'jac', '*727CD7DD2EFFB3F3125F912FC3A6306EEDB7C4B'),
(2, 'alberto', 'de8d063874da616ca32530466c5a1069a7a085f0'),
(6, 'luca', '492bf7683748242bdf1d79371a31a898c715020b'),
(9, 'jac', '2c0aad3a5962eced1511a7f86ad4b8d579155b6b'),
(10, 'pulito', '05ad063d44249b97e2021663b739ba38ab5e28bf');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `login`
--
ALTER TABLE `login`
 ADD PRIMARY KEY (`id_login`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `login`
--
ALTER TABLE `login`
MODIFY `id_login` int(1) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
