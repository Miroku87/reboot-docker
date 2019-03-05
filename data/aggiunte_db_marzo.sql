CREATE TABLE `cartellini` (
  `id_cartellino` int(11) NOT NULL AUTO_INCREMENT,
  `data_creazione_cartellino` varchar(45) NOT NULL DEFAULT 'CURRENT_TIMESTAMP',
  `tipo_cartellino` varchar(255) NOT NULL,
  `titolo_cartellino` varchar(255) NOT NULL,
  `descrizione_cartellino` text NOT NULL,
  `icona_cartellino` varchar(255) DEFAULT NULL,
  `testata_cartellino` varchar(255) DEFAULT NULL,
  `piepagina_cartellino` varchar(255) DEFAULT NULL,
  `costo_attuale_ravshop` int(255) DEFAULT NULL,
  `costo_vecchio_ravshop_cartellino` int(255) DEFAULT NULL,
  `nome_modello_cartellino` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_cartellino`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


