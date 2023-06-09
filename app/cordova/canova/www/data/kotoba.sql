-- phpMyAdmin SQL Dump
-- version 4.2.8.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Feb 25, 2015 at 10:39 PM
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
-- Table structure for table `wa_addetto`
--

CREATE TABLE IF NOT EXISTS `wa_addetto` (
  `id` int(11) NOT NULL,
  `name` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `wa_addetto`
--

INSERT INTO `wa_addetto` (`id`, `name`) VALUES
(1, 'Addetto_1'),
(2, 'Addetto_2'),
(3, 'Addetto_3'),
(4, 'Addetto_4'),
(5, 'Addetto_5'),
(6, 'Addetto_6'),
(7, 'Addetto_7');

-- --------------------------------------------------------

--
-- Table structure for table `wa_pulito`
--

CREATE TABLE IF NOT EXISTS `wa_pulito` (
  `id` int(11) DEFAULT NULL,
  `addetto` varchar(60) NOT NULL,
  `pullman` varchar(60) NOT NULL,
  `pulizia` varchar(60) NOT NULL,
  `data` date NOT NULL,
  `manutenzione` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `wa_pulito`
--

INSERT INTO `wa_pulito` (`id`, `addetto`, `pullman`, `pulizia`, `data`, `manutenzione`) VALUES
(4, 'Brunilde', 'pullman 255', 'pulizia3', '2014-10-15', 1),
(5, 'Lavinia', 'pullman 255', 'pulizia2', '2014-10-29', 1),
(6, 'Teodolinda', 'pullman 355', 'pulizia2', '2014-10-29', 1),
(7, 'Teodolinda', 'pullman 450', 'pulizia2', '2014-10-29', 1),
(9, 'Sigismonda', 'pullman 355', 'pulizia2', '2015-01-25', 1);

-- --------------------------------------------------------

--
-- Table structure for table `wa_pulizia`
--

CREATE TABLE IF NOT EXISTS `wa_pulizia` (
  `id` int(11) NOT NULL,
  `name` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `wa_pulizia`
--

INSERT INTO `wa_pulizia` (`id`, `name`) VALUES
(1, 'F1'),
(2, 'F2'),
(3, 'F3');

-- --------------------------------------------------------

--
-- Table structure for table `wa_pullman`
--

CREATE TABLE IF NOT EXISTS `wa_pullman` (
  `id` int(11) NOT NULL,
  `name` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `wa_pullman`
--

INSERT INTO `wa_pullman` (`id`, `name`) VALUES
(1,'134_Urbano'),
(2,'162_Urbano'),
(3,'163_Urbano'),
(4,'180_Noleggio'),
(5,'181_Urbano'),
(6,'182_Urbano'),
(7,'183_Noleggio'),
(8,'186_Noleggio'),
(9,'187_Noleggio'),
(10,'188_Noleggio'),
(11,'202_Noleggio'),
(12,'203_Urbano'),
(13,'204_Urbano'),
(14,'205_Urbano'),
(15,'206_Urbano'),
(16,'207_Urbano'),
(17,'208_AMRR'),
(18,'209_AMRR'),
(19,'210_AMRR'),
(20,'218_Urbano'),
(21,'219_Urbano'),
(22,'221_Urbano'),
(23,'222_Urbano'),
(24,'223_Urbano'),
(25,'224_Urbano'),
(26,'225_Urbano'),
(27,'234_Noleggio'),
(28,'255_AMRR'),
(29,'265_Urbano'),
(30,'266_Urbano'),
(31,'267_AMRR'),
(32,'268_Provincia_TO'),
(33,'271_Provincia_TO'),
(34,'272_AMRR'),
(35,'277_Provincia_TO'),
(36,'278_Urbano'),
(37,'279_Urbano'),
(38,'280_Urbano'),
(39,'281_Urbano'),
(40,'282_Urbano'),
(41,'283_AMRR'),
(42,'291_AMRR'),
(43,'292_Urbano'),
(44,'301_Noleggio'),
(45,'302_Urbano'),
(46,'303_Urbano'),
(47,'304_Urbano'),
(48,'305_Urbano'),
(49,'306_Urbano'),
(50,'307_Urbano'),
(51,'308_Noleggio'),
(52,'309_Urbano'),
(53,'310_Urbano'),
(54,'311_Urbano'),
(55,'312_Urbano'),
(56,'313_Urbano'),
(57,'314_Urbano'),
(58,'315_Urbano'),
(59,'324_Urbano'),
(60,'325_Urbano'),
(61,'326_Urbano'),
(62,'330_Urbano'),
(63,'332_Urbano'),
(64,'335_Urbano'),
(65,'338_Noleggio'),
(66,'339_Urbano'),
(67,'340_Noleggio'),
(68,'341_Noleggio'),
(69,'342_Urbano'),
(70,'343_Urbano'),
(71,'344_Urbano'),
(72,'346_Urbano'),
(73,'347_Urbano'),
(74,'348_Noleggio'),
(75,'349_Urbano'),
(76,'350_Urbano'),
(77,'351_Urbano'),
(78,'352_Urbano'),
(79,'354_Noleggio'),
(80,'355_Urbano'),
(81,'356_Urbano'),
(82,'357_Urbano'),
(83,'358_Urbano'),
(84,'359_Urbano'),
(85,'360_Urbano'),
(86,'361_Urbano'),
(87,'362_Urbano'),
(88,'363_Urbano'),
(89,'364_Urbano'),
(90,'365_Urbano'),
(91,'366_Urbano'),
(92,'375_AMRR'),
(93,'377_AMRR'),
(94,'378_AMRR'),
(95,'379_Provincia_TO'),
(96,'380_Noleggio'),
(97,'381_Provincia_TO'),
(98,'382_Noleggio'),
(99,'383_AMRR'),
(100,'384_AMRR'),
(101,'386_AMRR'),
(102,'387_AMRR'),
(103,'389_Noleggio'),
(104,'391_AMRR'),
(105,'392_AMRR'),
(106,'393_AMRR'),
(107,'395_AMRR'),
(108,'396_AMRR'),
(109,'397_AMRR'),
(110,'399_Noleggio'),
(111,'400_Noleggio'),
(112,'401_Provincia_TO'),
(113,'402_Provincia_TO'),
(114,'403_Noleggio'),
(115,'404_Provincia_TO'),
(116,'407_AMRR'),
(117,'408_AMRR'),
(118,'410_AMRR'),
(119,'450_Urbano'),
(120,'452_Urbano'),
(121,'453_Urbano'),
(122,'456_Urbano'),
(123,'457_Urbano'),
(124,'458_Urbano'),
(125,'459_Urbano'),
(126,'460_Urbano'),
(127,'461_Urbano'),
(128,'462_Urbano'),
(129,'463_Urbano'),
(130,'464_Urbano'),
(131,'465_Urbano'),
(132,'466_Provincia_TO'),
(133,'467_Provincia_TO'),
(134,'468_Provincia_TO'),
(135,'469_Urbano'),
(136,'471_Urbano'),
(137,'473_Urbano');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `wa_addetto`
--
ALTER TABLE `wa_addetto`
 ADD UNIQUE KEY `id` (`id`);

--
-- Indexes for table `wa_pulito`
--
ALTER TABLE `wa_pulito`
 ADD UNIQUE KEY `id` (`id`);

--
-- Indexes for table `wa_pulizia`
--
ALTER TABLE `wa_pulizia`
 ADD UNIQUE KEY `id` (`id`);

--
-- Indexes for table `wa_pullman`
--
ALTER TABLE `wa_pullman`
 ADD UNIQUE KEY `id` (`id`), ADD KEY `id_2` (`id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

CREATE TABLE IF NOT EXISTS `login` (
`id_login` int(1) NOT NULL,
  `username_login` varchar(10) NOT NULL,
  `password_login` varchar(40) NOT NULL
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `login`
--

INSERT INTO `login` (`id_login`, `username_login`, `password_login`) VALUES
(1, 'Canova', 'db58ed70253aaa0cd162fc8e22062b3028e908ba');

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
