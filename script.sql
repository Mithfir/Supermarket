if EXISTS (select name from master.dbo.sysdatabases where Name = 'Supermarche')
drop database Supermarche

GO
CREATE DATABASE Supermarche

GO
USE Supermarche

GO

CREATE TABLE Fournisseurs
(
Pk_Fournisseur INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
Nom VARCHAR(50) NOT NULL,
Contact VARCHAR(50) NOT NULL,
Telephone VARCHAR(25) NOT NULL,
Adresse VARCHAR(100) NOT NULL,
 
)

CREATE TABLE Prix
(
Pk_Prix INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
Montant SMALLMONEY UNIQUE NOT NULL,
DateDebut DATE NOT NULL,
DateFin DATE NOT NULL
)

CREATE TABLE Sections
(
Pk_Section INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
Description VARCHAR(MAX)	
)

CREATE TABLE Livraisons
(
Pk_Livraison INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
Total SMALLMONEY NOT NULL,
StatutLivraison VARCHAR(30),
Fk_Facture INT NOT NULL
)

CREATE TABLE Utilisateurs
(
Pk_Utilisateur INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
Nom VARCHAR(30) UNIQUE NOT NULL,
MotDePasse VARCHAR(200) NOT NULL,
Niveau INT NOT NULL
)

CREATE TABLE Commandes
(
Pk_Commande INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
Total SMALLMONEY NOT NULL,
Numero INT UNIQUE NOT NULL,
DateCommande VARCHAR(22) DEFAULT GETDATE() NOT NULL,
Fk_Fournisseur INT NOT NULL 
)

CREATE TABLE Factures
(
Pk_Facture INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
Total SMALLMONEY,
Numero INT UNIQUE,
DateFacture VARCHAR(22) DEFAULT GETDATE() NOT NULL,
Fk_Utilisateur INT NOT NULL 
)

CREATE TABLE Images
(
Pk_Image INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
Image IMAGE NULL,
Nom VARCHAR(50) NOT NULL,
Titre VARCHAR(50)NOT NULL
)

CREATE TABLE Produits
(
Pk_Produit INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
Nom VARCHAR(100) NOT NULL,
Quantite DECIMAL NOT NULL,
Sku VARCHAR(20) UNIQUE NOT NULL,
Description VARCHAR(MAX) NULL,
Promotion VARCHAR(10) NULL,
Fk_Section INT NOT NULL,
Fk_Prix INT NOT NULL,
Fk_Image INT NULL
)

CREATE TABLE Tri_Fournisseurs_Produits
(
Pk_Tri_Fournisseur_Produit INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
Fk_Fournisseur INT NOT NULL,
Fk_Produit INT NOT NULL
)

CREATE TABLE Tri_Factures_Produits
(
Pk_Tri_Facture_Produit INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
Fk_Facture INT NOT NULL,
Fk_Produit INT NOT NULL
)

CREATE TABLE Tri_Commandes_Produits
(
Pk_Tri_Commande_Produit INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
Fk_Commande INT NOT NULL,
Fk_Produit INT NOT NULL
)

/*ALTER TABLE Commandes
ADD CONSTRAINT C_timestamp DEFAULT GETDATE() FOR DateCommande*/

-- Clés étrangères

-- Produits
ALTER TABLE Produits
ADD CONSTRAINT R_fk_section FOREIGN KEY(Fk_Section)
REFERENCES Sections(Pk_Section),

CONSTRAINT R_fk_prix FOREIGN KEY(Fk_Prix)
REFERENCES Prix(Pk_Prix),

CONSTRAINT R_fk_image FOREIGN KEY(Fk_Image)
REFERENCES Images(Pk_Image)

-- Commandes
ALTER TABLE Commandes
ADD CONSTRAINT R_fk_fournisseur FOREIGN KEY(Fk_Fournisseur)
REFERENCES Fournisseurs(Pk_Fournisseur)

-- Tri_Fournisseurs_Produits
ALTER TABLE Tri_Fournisseurs_Produits
ADD CONSTRAINT R_tri_fk_fournisseur FOREIGN KEY(Fk_Fournisseur)
REFERENCES Fournisseurs(Pk_Fournisseur),

CONSTRAINT R_tri_fk_produit FOREIGN KEY(Fk_Produit)
REFERENCES Produits(Pk_Produit)

-- Tri_Factures_Produits
ALTER TABLE Tri_Factures_Produits
ADD CONSTRAINT R_tri_fk_facture FOREIGN KEY(Fk_Facture)
REFERENCES Factures(Pk_Facture),

CONSTRAINT R_tri_fk_facture_produit FOREIGN KEY(Fk_Produit)
REFERENCES Produits(Pk_Produit)

-- Tri_Commandes_Produits
ALTER TABLE Tri_Commandes_Produits
ADD CONSTRAINT R_tri_fk_commande FOREIGN KEY(Fk_Commande)
REFERENCES Commandes(Pk_Commande),

CONSTRAINT R_tri_fk_commande_produit FOREIGN KEY(Fk_Produit)
REFERENCES Produits(Pk_Produit)

-- Factures
ALTER TABLE Factures
ADD CONSTRAINT R_fk_utilisateur FOREIGN KEY(Fk_Utilisateur)
REFERENCES Utilisateurs(Pk_Utilisateur)

-- Livraisons
ALTER TABLE Livraisons
ADD CONSTRAINT R_fk_facture FOREIGN KEY (Fk_Facture)
REFERENCES Factures(Pk_Facture)


-- Triggers

-- La date de fin ne doit pas être avant la date de début
GO
CREATE TRIGGER TR_Date
ON Prix
AFTER INSERT
AS
DECLARE @Pk INT, 
@Debut DATETIME,
@Fin DATETIME,
@Montant SMALLMONEY
BEGIN
SET @Pk = (SELECT MAX(Pk_Prix) FROM Prix)
SET @Debut = (SELECT DateDebut FROM INSERTED WHERE Pk_Prix = @Pk)
SET @Fin = (SELECT DateFin FROM INSERTED WHERE Pk_Prix = @Pk)
SET @Montant = (SELECT Montant FROM INSERTED WHERE Pk_Prix = @Pk)
IF @Debut > @Fin 
BEGIN
RAISERROR ('La date de fin ne doit pas être avant la date de début!', 16, 1)
ROLLBACK TRANSACTION
RETURN
END
END



-- Données 
GO
USE Supermarche

-- Fournisseurs
-- 1-8 26 juin 
INSERT INTO Fournisseurs(Nom, Contact, Telephone, Adresse)
VALUES('Koyo Foods', 'Florent Despins', '514-744-1299', '4605 Hickmore Montreal Quebec H4T 1S5'),
		('Aliements ADP', 'Line Ouellet', '514-904-1824', '362 Boulevard Cremazie Ouest Montreal Quebec H2P 1C7'),
		('Macchi INC', 'Jean Tremblay', '450-662-8887', '750 Leo-Lacombe suite 200 Laval Quebec H7N 3Y6'),
		('M&M', 'Harold Côté', '819-422-6721', '1050 King Ouest Sherbrooke Quebec 2K2 I7U'),
		('Conan Food', 'Jacques L''Heureux', '514-334-2773', '7007 Henri-Bourassa Ouest St-Laurent Quebec H4S 2E2'),
		('Tannis Food', 'Pauline Savard', '613-736-6000', '2390 Stevenage Drive Ottawa Ontario K1G 3W3'),
		('Dubord & Rainville', 'Alain Dubord', '514-735-6111', '4045 Boulevard Poirier St-Laurent Quebec H4R 2G9'),
		('Altra Foods', 'David Lapp', '514-276-1981', '8250 Rue Edison Anjou Quebec H1J 1S8')



-- 9 27 juin
INSERT INTO Fournisseurs(Nom, Contact, Telephone, Adresse)
VALUES('Laiterie Coaticook', 'Guy Laframboise', '819-849-2272', '1000 rue Child Coaticook Quebec J1A 2S5')

-- 10 30 juin
INSERT INTO Fournisseurs(Nom, Contact, Telephone, Adresse)
VALUES('Sysco Quebec', 'Robert Duncan', '514-494-5200', '11625 55th Avenue Montreal Quebec H1E 2K2')

-- 11 2 juillet
INSERT INTO Fournisseurs(Nom, Contact, Telephone, Adresse)
VALUES('Bulk Barn', 'Bill Williams', '905-726-5000', '320 Don Hillock Drive Aurora Ontario L4G 0G9')

-- 12 7 juillet
INSERT INTO Fournisseurs(Nom, Contact, Telephone, Adresse)
VALUES('Star Marketing', 'Alice Williams', '604-888-4049', '19720 - 94A Ave Unit D Suite 107 Langley BC V1M 3B7')

-- 13 9 juillet
INSERT INTO Fournisseurs(Nom, Contact, Telephone, Adresse)
VALUES('Dovre Import & Export ltd.', 'Jack Johnson', '604-234-4546', '13931 Bridgeport Road Richmond BC V6V 1J6')

-- Sections (Location est un INT, Description est nullable)
GO
INSERT INTO Sections(Description)
VALUES('Fruits et légumes'),
		('Pains et céréales'),
		('Viandes'),
		('Surgelés'),
		('Poissons et fruits de mer'),
		('Frigidaire à alcools'),
		('Produits utilitaires'),
		('Produits bio'),
		('Produits laitiers'),
		('Café et thé'),
		('Croustilles et craquelins'),
		('Jus et boissons gazeuses'),
		('Biscuits et bonbons'),
		('Conserves et pots'),
		('Eau'),
		('Produits pour bébé'),
		('Condiments'),
		('Pâtes et riz')
		

-- Images à ajouter vers la fin du projet

/*GO
INSERT INTO Images(Nom, Titre)
VALUES('Filet mignon', 'Filet Mignon'),
		('Orange', 'Orange'),
		('Pommej', 'Pomme délicieuse jaune')*/

-- Utilisateurs 
GO
INSERT INTO Utilisateurs(Nom, MotDePasse, Niveau)
VALUES('Mith', PWDENCRYPT('root'), 1),
		('Mario', PWDENCRYPT('root'), 1),
		('Drew', PWDENCRYPT('root'), 1),
		('Alex', PWDENCRYPT('root'), 2)

		
-- Commandes
GO
INSERT INTO Commandes(Total, Numero, DateCommande, Fk_Fournisseur)
VALUES('249.99', 4358, DEFAULT, 1),
		('425.99', 4359, DEFAULT, 2),
		('983.25', 4360, DEFAULT, 3)

-- Factures
GO
INSERT INTO Factures(Total, Numero, DateFacture, Fk_Utilisateur)
VALUES('84.99', 12, DEFAULT, 1),
		('73.87', 13, DEFAULT, 2),
		('24.99', 14, DEFAULT, 3)


GO
INSERT INTO Livraisons(Total, StatutLivraison, Fk_Facture)
VALUES(83.99, 'Livré', 1),
		(25.34, 'Non livré', 2),
		(12.99, 'Livré', 3)

-- Prix
GO
-- 1-10 26 juin
INSERT INTO Prix(Montant, DateDebut, DateFin)
VALUES('3.99', '2014-06-26', '2014-09-01'),
		('2.49', '2014-06-26', '2014-09-01'),
		('6.99', '2014-06-26', '2014-09-01'),
		('2.99', '2014-06-26', '2014-09-01'),
		('10.99', '2014-06-26', '2014-09-01'),
		('23.99', '2014-06-26', '2014-09-01'),
		('3.49', '2014-06-26', '2014-09-01'),
		('8.99', '2014-06-26', '2014-09-01'),
		('0.99', '2014-06-26', '2014-09-01'),
		('21.99', '2014-06-26', '2014-09-01')

--11-19 27 juin
INSERT INTO Prix(Montant, DateDebut, DateFin)
VALUES('19.99', '2014-06-27', '2014-09-01'),
	('7.99', '2014-06-27', '2014-09-01'),
	('9.99', '2014-06-27', '2014-09-01'),
	('27.99', '2014-06-27', '2014-09-01'),
	('2.00', '2014-06-27', '2014-09-01'),
	('1.50', '2014-06-27', '2014-09-01'),
	('1.34', '2014-06-27', '2014-09-01'),
	('3.69', '2014-06-27', '2014-09-01'),
	('2.50', '2014-06-27', '2014-09-01')

-- 20-28 30 juin
INSERT INTO Prix(Montant, DateDebut, DateFin)
VALUES('5.99', '2014-06-30', '2014-09-01'),
		('3.33', '2014-06-30', '2014-09-01'),
		('15.99', '2014-06-30', '2014-09-01'),
		('4.99', '2014-06-30', '2014-09-01'),
		('15.49', '2014-06-30', '2014-09-01'),
		('2.24', '2014-06-30', '2014-09-01'),
		('1.99', '2014-06-30', '2014-09-01'),
		('25.97', '2014-06-30', '2014-09-01'),
		('5.19', '2014-06-30', '2014-09-01')

-- 29-35 2 juillet
INSERT INTO Prix(Montant, DateDebut, DateFin)
VALUES('0.75', '2014-07-02', '2014-09-01'),
		('25.99', '2014-07-02', '2014-09-01'),
		('14.99', '2014-07-02', '2014-09-01'),
		('3.24', '2014-07-02', '2014-09-01'),
		('3.00', '2014-07-02', '2014-09-01'),
		('43.99', '2014-07-02', '2014-09-01'),
		('3.29', '2014-07-02', '2014-09-01')

-- 36-39 7 juillet
INSERT INTO Prix(Montant, DateDebut, DateFin)
VALUES('4.49', '2014-07-07', '2014-09-01'),
		('16.98', '2014-07-07', '2014-09-01'),
		('2.75', '2014-07-07', '2014-09-01'),
		('0.60', '2014-07-07', '2014-09-01')

-- 40- 9 juillet
INSERT INTO Prix(Montant, DateDebut, DateFin)
VALUES('1.29', '2014-07-09', '2014-09-01'),
		('2.25', '2014-07-09', '2014-09-01'),
		('4.98', '2014-07-09', '2014-09-01'),
		('13.99', '2014-07-09', '2014-09-01'),
		('1.66', '2014-07-09', '2014-09-01'),
		('7.98', '2014-07-09', '2014-09-01'),
		('1.39', '2014-07-09', '2014-09-01'),
		('1.25', '2014-07-09', '2014-09-01')


		

-- Produits
GO
-- 1-10 26 juin
INSERT INTO Produits(Nom, Quantite, Sku, Description, Promotion, Fk_Section, Fk_Prix, Fk_Image)
VALUES('PC Bleuets Biologique', 30, '100a', 'PC Bleuets paquet plastique 277g', 'Non', 1, 1, NULL),
		('Petits pains kaiser', 25, '100b', 'Paquet de 6 pains kaiser', 'Non', 2, 2, NULL),
		('Brochettes fraîches', 19, '100c', 'Brochettes variées 6,99/lb', 'Non', 3, 3, NULL),
		('PC Poulet au beurre', 10, '100d', 'PC', 'Non', 4, 4, NULL),
		('Darne de marlin bleu', 6, '100e', 'Poisson viande rouge 10,99/lb', 'Non', 5, 5, NULL),
		('Coors Light caisse de 20', 12, '100f', 'Bière Coors Light', 'Non', 6, 6, NULL),
		('M.Net nettoyant assainisseur d''air', 10, '100g', 'M.Net 473ml', 'Non', 7, 7, NULL),
		('PC yogourt grec nature', 13, '100h', 'PC 500g nature', 'Non', 8, 1, NULL),
		('Liberté yogourt méditerranée', 8, '100i', '750g Méditerranée', 'Non', 9, 4, NULL),
		('Café Van Houtte torréfié et moulu Orient Express', 4, '100j', '650g Orient Express', 'Non', 10, 8, NULL)

-- 11-18 26 juin		
INSERT INTO Produits(Nom, Quantite, Sku, Description, Promotion, Fk_Section, Fk_Prix, Fk_Image)
VALUES('Planters arachides grillées à sec', 8, '100k', '600g', 'Non', 11, 4, NULL),
		('Garden Cocktail', 10, '100l', '1,89L', 'Non', 12, 4, NULL),
		('PC Biscuits Le Décadent', 5, '100m', '300g Fondant', 'Non', 13, 2, NULL),
		('St-Hubert soupe poulet et nouilles', 10, '100n', '900ml', 'Non', 14, 2, NULL),
		('PC Eau pétillante claire', 12, '100o', '1L', 'Non', 15, 9, NULL),
		('Huggies couches très grand format', 5, '100p', 'Taille N-6', 'Non', 16, 10, NULL),
		('Renée''s Vinaigrette balsamique', 8, '100q', '355ml', 'Non', 17, 1, NULL),
		('Delverde pâtes', 10, '100r', '500g', 'Non', 18, 9, NULL)

-- 19-28 27 juin
INSERT INTO Produits(Nom, Quantite, Sku, Description, Promotion, Fk_Section, Fk_Prix, Fk_Image)
VALUES('Cerises géantes', 75, '101a', 'Jumbo Produit des É-U', 'Non', 1, 2, NULL),
		('Tarte aux baies avec crème pâtissière', 20, '101b', '9 pouces 700g', 'Non', 2, 11, NULL),
		('Maple Leaf bacon', 16, '101c', 'Natural Selections', 'Non', 3, 1, NULL),
		('PC Boeuf au jalapeno sur bâton', 12, '101d', 'PC 270g', 'Non', 4, 12, NULL),
		('Filets de saumon sockeye sauvage', 12, '101e', '9.99/lb', 'Non', 5, 13, NULL),
		('Budweiser caisse de 24', 10, '101f', 'Caisse 24', 'Non', 6, 14, NULL),
		('Dove nettoyant pour le corps', 9, '101g', 'Dove 355ml', 'Non', 7, 1, NULL),
		('Santa Cruz limonade', 14, '101h', '946ml', 'Non', 8, 15, NULL),
		('Quebon lait au chocolat', 7, '101i', '1L', 'Non', 9, 16, NULL),
		('Maxwell House café moulu', 12, '101j', '925g', 'Non', 10, 12, NULL)

--29-36 27 juin
INSERT INTO Produits(Nom, Quantite, Sku, Description, Promotion, Fk_Section, Fk_Prix, Fk_Image)
VALUES('Ruffles Nature', 8, '101k', 'Croustilles 255g', 'Non', 11, 7, NULL),
		('Tropicana Tropics', 8, '101l', '1,75L', 'Non', 12, 1, NULL),
		('Belvita Petit-Déjeuner', 4, '101m', '500g', 'Non', 13, 4, NULL),
		('Del Monte Pêches en moitié', 8, '101n', '398ml', 'Non', 14, 17, NULL),
		('Nestlé Pure Life paquet de 24 x 500ml', 8, '101o', 'Paquet de 24 x 500ml', 'Non', 15, 7, NULL),
		('Huggies Little Swimmers', 4, '101p', 'Maillots de bain jetables', 'Non', 16, 13, NULL),
		('Heinz Ketchup', 8, '101q', '750mq', 'Non', 17, 18, NULL),
		('Uncle Ben''s Bistro Express poulet rôti', 14, '101r', '250g', 'Non', 18, 19, NULL)
		
-- 37-46 30 juin
INSERT INTO Produits(Nom, Quantite, Sku, Description, Promotion, Fk_Section, Fk_Prix, Fk_Image)
VALUES('Fraises du Quebec', 50, '102a', 'Panier 1L', 'Non', 1, 4, NULL),
		('Vol-au-vent(6)', 6, '102b', 'Paquet de 6 160g', 'Non', 2, 1, NULL),
		('Filets de porc frais', 4, '102c', '5,99/lb', 'Non', 3, 20, NULL),
		('Ristorante Pizza spinaci', 10, '102d', '450g', 'Non', 4, 21, NULL),
		('Filets de tilapia frais', 3, '102e', '6.99/lb', 'Non', 5, 11, NULL),
		('Corona extra caisse de 12', 6, '102f', 'Caisse de 12', 'Non', 6, 22, NULL),
		('Cascades essui-tout', 10, '102g', 'Emballage de 6', 'Non', 7, 20, NULL),
		('Attitude produit nettoyant écologique', 3, '102h', '680ml', 'Non', 8, 7, NULL),
		('Lactantia lait 2% sans lactose 2L', 4, '102i', '2L', 'Non', 9, 15, NULL),
		('Nescafé café instantané', 6, '102j', '100g', 'Non', 10, 23, NULL)

-- 47-54 30 juin
INSERT INTO Produits(Nom, Quantite, Sku, Description, Promotion, Fk_Section, Fk_Prix, Fk_Image)
VALUES('Pringles original', 5, '102k', '187g original', 'Non', 11, 15, NULL),
		('RedBull caisse de 8', 10, '102l', 'Caisse de 8 x 250ml', 'Non', 12, 24, NULL),
		('Pillsbury pâte à biscuits', 4, '102m', '428g', 'Non', 13, 19, NULL),
		('Catelli sauce pâtes à la viande', 10, '102n', '680ml', 'Non', 14, 25, NULL),
		('Eska eau de source naturelle 4L', 2, '102o', '4L', 'Non', 15, 26, NULL),
		('Nestlé préparation en poudre pour nourrisson Bon départ', 4, '102p', '640g', 'Non', 16, 27, NULL),
		('Doyon Miel pur 375g', 3, '102q', '375g', 'Non', 17, 28, NULL),
		('Minute Rice riz précuit', 6, '102r','1.4kg', 'Non', 18, 23, NULL)		
	
-- 55-64 2 juillet
INSERT INTO Produits(Nom, Quantite, Sku, Description, Promotion, Fk_Section, Fk_Prix, Fk_Image)
VALUES('Kiwi vert', 50, '103a', 'Produit de Nouvelle-Zélande', 'Non', 1, 29, NULL),
		('Gâteau La Rocca', 2, '103b', '1,3kg', 'Non', 2, 30, NULL),
		('Bifteck de filet mignon', 4, '103c', 'Canada AA 19.99/lb', 'Non', 3, 11, NULL),
		('Stromboli pizza fromage de chèvre', 4, '103d', '367g', 'Non', 4, 4, NULL),
		('Phillips chair de crabe', 3, '103e', '227g', 'Non', 5, 8, NULL),
		('Heineken caisse de 12', 8, '103f', 'Caisse de 12 x 330ml', 'Non', 6, 31, NULL),
		('Windex original', 5, '103g', 'Nettoyant 765ml', 'Non', 7, 7, NULL),
		('Dad''s sauce bbq', 3, '103h', 'Sauce barbecue biologique 500ml', 'Non', 8, 32, NULL),
		('Yoplait yogourt crémeux Source', 6, '103i', '650g', 'Non', 9, 2, NULL),
		('Tassimo Capsules de café', 3, '103j', 'PC paquet de 14', 'Non', 10, 3, NULL)

-- 65-72 2 juillet
INSERT INTO Produits(Nom, Quantite, Sku, Description, Promotion, Fk_Section, Fk_Prix, Fk_Image)
VALUES('Sun Chips cheddar de campagne', 4, '103k', '220g', 'Non', 11, 33, NULL),
		('Nestea paquet de 12', 5, '103l', 'Paquet de 12 x 355ml', 'Non', 12, 1, NULL),
		('Skittles 200g', 8, '103m', '200g', 'Non', 13, 19, NULL),
		('Campbell''s crème de champignons', 5, '103n', '284ml', 'Non', 14, 16, NULL),
		('Eska eau de source naturelle paquet de 12', 4, '103o', 'Paquet de 12 x 500ml', 'Non', 15, 2, NULL),
		('Similac Advance avec oméga pour nourrissons', 3, '103p', 'Paquet de 12 x 385ml', 'Non', 16, 34, NULL),
		('Red Hot Frank''s sauce 354ml', 4, '103q', '354ml', 'Non', 17, 1, NULL),
		('Uncle Ben''s Sélection Naturelle poulet rôti et riz', 4, '103r', '240g', 'Non', 18, 35, NULL)

-- 73-82 7 juillet
INSERT INTO Produits(Nom, Quantite, Sku, Description, Promotion, Fk_Section, Fk_Prix, Fk_Image)
VALUES('Tomates du Québec', 46, '104a', 'Canada no.1', 'Non', 1, 26, NULL),
		('Compliments Pain blanc tranché', 10, '104b', 'Blanc tranché', 'Non', 2, 2, NULL),
		('Compliments Saucisses de porc Herbes et ail Jamie Oliver', 6, '104c', 'Herbes et ail', 'Non', 3, 20, NULL),
		('McCain Pizza Lève-au-four', 4, '104d', 'Lève-au-four deluxe', 'Non', 4, 20, NULL),
		('Filet d''aiglefin frais', 6, '104e', 'Filet d''aiglefin', 'Non', 5, 8, NULL),
		('Sleeman original Caisse de 24', 10, '104f', 'Sleeman original', 'Non', 6, 14, NULL),
		('Scotties mouchoirs emballage de 6', 4, '104g', 'Scotties emballage 6', 'Non', 7, 23, NULL),
		('Liberté yogourt biologique fraise sans gras', 6, '104h', '620g', 'Non', 8, 36, NULL),
		('Black Diamond tranches cheddar épaisses 24', 8, '104i', '500g 24 tranches', 'Non', 9, 1, NULL),
		('Van Houtte Mélange maison mi-noir velouté et boisé', 4, '104j', '908g', 'Non', 10, 37, NULL)

-- 83-90 7 juillet
INSERT INTO Produits(Nom, Quantite, Sku, Description, Promotion, Fk_Section, Fk_Prix, Fk_Image)
VALUES('Old Dutch croustilles BBQ 270g', 4, '104k', '270g BBQ', 'Non', 11, 38, NULL),
		('Sensations jus d''orange 2.63L', 3, '104l', '2.63L Orange', 'Non', 12, 1, NULL),
		('Pattes d''ours format familial 600g', 6, '104m', '600g', 'Non', 13, 36, NULL),
		('Compliments petits pois 284ml', 6, '104n', '284ml', 'Non', 14, 39, NULL),
		('S.Pellegrino eau minérale naturelle 1L', 4, '104o', '1L', 'Non', 15, 16, NULL),
		('Attitude couches écologiques paquet de 22', 3, '104p', '22 couches', 'Non', 16, 8, NULL),
		('Kraft vinaigrette française 475ml', 8, '104q', '475ml', 'Non', 17, 19, NULL),
		('Catelli pâtes alimentaires lasagne 500g', 4, '104r', '500g', 'Non', 18, 19, NULL)

-- 91-100 9 juillet
INSERT INTO Produits(Nom, Quantite, Sku, Description, Promotion, Fk_Section, Fk_Prix, Fk_Image)
VALUES('Raisins rouges sans pépins des États-Unis', 50, '105a', 'Des États-Unis Catégorie no.1', 'Non', 1, 40, NULL),
		('Robin Hood gruau rapide gros flocons 1kg', 4, '105b', '1kg', 'Non', 2, 41, NULL),
		('Schneiders poitrine de dinde au paprika, fumée', 3, '105c', '15.83/lb', 'Non', 3, 7, NULL),
		('Swanson Repas Poulet Alfredo 595g', 4, '105d', '595g', 'Non', 4, 42, NULL),
		('Sensations pétoncles sauvages du Canada Atlantique 400g', 5, '105e', '400g grosseur 20-40', 'Non', 5, 43, NULL),
		('Nicolas Laloux vin rouge 2013 1L', 8, '105f', '1L 2013 rouge', 'Non', 6, 13, NULL),
		('Colgate dentifrice blanc optique 75ml', 5, '105g', '75ml blanc optique', 'Non', 7, 41, NULL),
		('Natura boisson de soya bio et enrichie non sucré 946ml', 4, '105h', '946ml soya non sucré', 'Non', 8, 44, NULL),
		('Lactantia crème à cuisson 15% 250ml', 5, '105i', '250ml crème à cuisson', 'Non', 9, 26, NULL),
		('Melitta mélange du domaine torréfaction moyenne 652g', 4, '105j', '652g torréfaction moyenne', 'Non', 10, 45, NULL)

-- 101- 9 juillet
INSERT INTO Produits(Nom, Quantite, Sku, Description, Promotion, Fk_Section, Fk_Prix, Fk_Image)
VALUES('Doritos fromage nacho 235g', 9, '105k', 'Fromage nacho 235g', 'Non', 11, 33, NULL),
		('Pepsi paquet de 6 x 710ml', 8, '105l', 'Paquet de 6 x 710ml', 'Non', 12, 18, NULL),
		('Mondoux Friandises Sweet Sixteen 325g', 12, '105m', '325g Sweet Sixteen', 'Non', 13, 1, NULL),
		('Habitant relish sucrée 375ml', 8, '105n', '375ml relish sucrée', 'Non', 14, 46, NULL),
		('Nestlé Pure Life paquet de 12 x 500ml', 4, '105o', 'Paquet de 12 x 500ml', 'Non', 15, 1, NULL),
		('Aveeno Baby crème hydratante 175ml', 3, '105p', '175ml', 'Non', 16, 20, NULL),
		('Maille moutarde dijon à l''ancienne 500ml', 6, '105q', '500ml moutarde dijon ancienne', 'Non', 17, 23, NULL),
		('Barilla macaroni coupé 454g', 10, '105r', '454g macaroni coupé', 'Non', 18, 47, NULL)





-- Tables de tri
GO
INSERT INTO Tri_Fournisseurs_Produits(Fk_Fournisseur, Fk_Produit)
VALUES(1, 1),
		(1, 2),
		(2,1)

-- 26 juin
GO
INSERT INTO Tri_Fournisseurs_Produits(Fk_Fournisseur, Fk_Produit)
VALUES(4, 3),
		(5, 4),
		(2, 5),
		(5, 6),
		(5, 7),
		(8, 8),
		(4, 9),
		(5, 10)

GO
INSERT INTO Tri_Factures_Produits(Fk_Facture, Fk_Produit)
VALUES(1, 1),
		(1, 2),
		(2, 2),
		(1, 1),
		(1, 2)
		
GO
INSERT INTO Tri_Commandes_Produits(Fk_Commande, Fk_Produit)
	VALUES(1, 1),
			(1, 2),
			(2, 1),
			(2, 2),
			(1, 2)

		
