CREATE DATABASE IF NOT EXISTS `patient` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `patient`;

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `patient`
--

-- --------------------------------------------------------

--
-- Table structure for table `strokes`
--

CREATE TABLE `strokes` (
  `time_call` varchar(60) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `time_hospitalization` varchar(60) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `lat_unit` float NOT NULL,
  `lng_unit` float NOT NULL,
  `lat_call` float NOT NULL,
  `lng_call` float NOT NULL,
  `unit_type` varchar(60) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `success` varchar(60) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `date` date NOT NULL,
  `idx` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `strokes`
--

INSERT INTO `strokes` (`time_call`, `time_hospitalization`, `lat_unit`, `lng_unit`, `lat_call`, `lng_call`, `unit_type`, `success`, `date`, `idx`) VALUES
('2020-03-14 21:03:00', '2020-03-14 21:43:00', 45.554, 10.232, 45.579, 10.497, 'CT', 'yes', '2020-05-02', 21);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `strokes`
--
ALTER TABLE `strokes`
  ADD PRIMARY KEY (`idx`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `strokes`
--
ALTER TABLE `strokes`
  MODIFY `idx` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
