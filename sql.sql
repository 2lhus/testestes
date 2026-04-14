IF OBJECT_ID(N'dbo.tickets', N'U') IS NOT NULL DROP TABLE [dbo].[tickets];
IF OBJECT_ID(N'dbo.reviews', N'U') IS NOT NULL DROP TABLE [dbo].[reviews];
IF OBJECT_ID(N'dbo.reservations', N'U') IS NOT NULL DROP TABLE [dbo].[reservations];
IF OBJECT_ID(N'dbo.screenings', N'U') IS NOT NULL DROP TABLE [dbo].[screenings];
IF OBJECT_ID(N'dbo.seats', N'U') IS NOT NULL DROP TABLE [dbo].[seats];
IF OBJECT_ID(N'dbo.auditoriums', N'U') IS NOT NULL DROP TABLE [dbo].[auditoriums];
IF OBJECT_ID(N'dbo.users', N'U') IS NOT NULL DROP TABLE [dbo].[users];
IF OBJECT_ID(N'dbo.movies', N'U') IS NOT NULL DROP TABLE [dbo].[movies];
IF OBJECT_ID(N'dbo.cinemas', N'U') IS NOT NULL DROP TABLE [dbo].[cinemas];

CREATE TABLE [dbo].[cinemas] (
  [cinema_id] INT IDENTITY(1,1) CONSTRAINT [PK_cinemas] PRIMARY KEY,
  [name] VARCHAR(150) NOT NULL,
  [address] VARCHAR(255) NOT NULL,
  [city] VARCHAR(100) NOT NULL
);

CREATE TABLE [dbo].[movies] (
  [movie_id] INT IDENTITY(1,1) CONSTRAINT [PK_movies] PRIMARY KEY,
  [title] VARCHAR(200) NOT NULL,
  [synopsis] VARCHAR(MAX) NULL,
  [duration_mins] INT NOT NULL,
  [release_date] DATE NULL,
  [language] VARCHAR(50) NULL,
  [age_rating] VARCHAR(20) NULL,
  CONSTRAINT [CK_movies_duration_mins] CHECK ([duration_mins] > 0)
);

CREATE TABLE [dbo].[users] (
  [user_id] INT IDENTITY(1,1) CONSTRAINT [PK_users] PRIMARY KEY,
  [full_name] VARCHAR(100) NOT NULL,
  [email] VARCHAR(255) NOT NULL,
  [password_hash] VARCHAR(255) NOT NULL,
  [phone] VARCHAR(20) NULL,
  [created_at] DATETIME2(0) NOT NULL CONSTRAINT [DF_users_created_at] DEFAULT (SYSDATETIME()),
  [status] VARCHAR(20) NOT NULL,
  CONSTRAINT [UQ_users_email] UNIQUE ([email])
);

CREATE TABLE [dbo].[auditoriums] (
  [auditorium_id] INT IDENTITY(1,1) CONSTRAINT [PK_auditoriums] PRIMARY KEY,
  [cinema_id] INT NOT NULL,
  [auditorium_name] VARCHAR(100) NOT NULL,
  CONSTRAINT [UQ_auditorium_name_per_cinema] UNIQUE ([cinema_id], [auditorium_name]),
  CONSTRAINT [FK_auditoriums_cinemas]
    FOREIGN KEY ([cinema_id]) REFERENCES [dbo].[cinemas] ([cinema_id])
);

CREATE TABLE [dbo].[seats] (
  [seat_id] INT IDENTITY(1,1) CONSTRAINT [PK_seats] PRIMARY KEY,
  [auditorium_id] INT NOT NULL,
  [row_label] VARCHAR(10) NOT NULL,
  [seat_number] VARCHAR(10) NOT NULL,
  [seat_type] VARCHAR(30) NOT NULL,
  CONSTRAINT [UQ_seat_per_auditorium] UNIQUE ([auditorium_id], [row_label], [seat_number]),
  CONSTRAINT [FK_seats_auditoriums]
    FOREIGN KEY ([auditorium_id]) REFERENCES [dbo].[auditoriums] ([auditorium_id])
);

CREATE TABLE [dbo].[screenings] (
  [screening_id] INT IDENTITY(1,1) CONSTRAINT [PK_screenings] PRIMARY KEY,
  [movie_id] INT NOT NULL,
  [auditorium_id] INT NOT NULL,
  [start_time] DATETIME2(0) NOT NULL,
  [end_time] DATETIME2(0) NOT NULL,
  [screening_format] VARCHAR(30) NOT NULL,
  [base_price] DECIMAL(10,2) NOT NULL,
  [status] VARCHAR(20) NOT NULL,
  CONSTRAINT [CK_screenings_time] CHECK ([end_time] > [start_time]),
  CONSTRAINT [CK_screenings_base_price] CHECK ([base_price] >= 0),
  CONSTRAINT [FK_screenings_movies]
    FOREIGN KEY ([movie_id]) REFERENCES [dbo].[movies] ([movie_id]),
  CONSTRAINT [FK_screenings_auditoriums]
    FOREIGN KEY ([auditorium_id]) REFERENCES [dbo].[auditoriums] ([auditorium_id])
);

CREATE TABLE [dbo].[reservations] (
  [reservation_id] INT IDENTITY(1,1) CONSTRAINT [PK_reservations] PRIMARY KEY,
  [user_id] INT NOT NULL,
  [screening_id] INT NOT NULL,
  [reserved_at] DATETIME2(0) NOT NULL CONSTRAINT [DF_reservations_reserved_at] DEFAULT (SYSDATETIME()),
  [status] VARCHAR(20) NOT NULL,
  CONSTRAINT [FK_reservations_users]
    FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([user_id]),
  CONSTRAINT [FK_reservations_screenings]
    FOREIGN KEY ([screening_id]) REFERENCES [dbo].[screenings] ([screening_id])
);

CREATE TABLE [dbo].[tickets] (
  [ticket_id] INT IDENTITY(1,1) CONSTRAINT [PK_tickets] PRIMARY KEY,
  [reservation_id] INT NOT NULL,
  [seat_id] INT NOT NULL,
  [ticket_price] DECIMAL(10,2) NOT NULL,
  [ticket_status] VARCHAR(20) NOT NULL,
  [qr_code] VARCHAR(255) NOT NULL,
  CONSTRAINT [CK_tickets_price] CHECK ([ticket_price] >= 0),
  CONSTRAINT [UQ_tickets_qr_code] UNIQUE ([qr_code]),
  CONSTRAINT [UQ_ticket_seat_per_reservation] UNIQUE ([reservation_id], [seat_id]),
  CONSTRAINT [FK_tickets_reservations]
    FOREIGN KEY ([reservation_id]) REFERENCES [dbo].[reservations] ([reservation_id]),
  CONSTRAINT [FK_tickets_seats]
    FOREIGN KEY ([seat_id]) REFERENCES [dbo].[seats] ([seat_id])
);

CREATE TABLE [dbo].[reviews] (
  [review_id] INT IDENTITY(1,1) CONSTRAINT [PK_reviews] PRIMARY KEY,
  [user_id] INT NOT NULL,
  [movie_id] INT NOT NULL,
  [rating] INT NOT NULL,
  [review_text] VARCHAR(MAX) NULL,
  [reviewed_at] DATETIME2(0) NOT NULL CONSTRAINT [DF_reviews_reviewed_at] DEFAULT (SYSDATETIME()),
  CONSTRAINT [CK_reviews_rating] CHECK ([rating] BETWEEN 1 AND 5),
  CONSTRAINT [UQ_review_per_user_movie] UNIQUE ([user_id], [movie_id]),
  CONSTRAINT [FK_reviews_users]
    FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([user_id]),
  CONSTRAINT [FK_reviews_movies]
    FOREIGN KEY ([movie_id]) REFERENCES [dbo].[movies] ([movie_id])
);

/* SAMPLE DATA INSERTS */

INSERT INTO [dbo].[cinemas] ([name], [address], [city]) VALUES
('Star Cinema Ajman', 'Sheikh Khalifa Bin Zayed St, Al Nuaimiya', 'Ajman'),
('Grand Cineplex Dubai', 'City Walk Boulevard', 'Dubai'),
('Oasis Cinema Sharjah', 'Al Majaz Waterfront', 'Sharjah');

INSERT INTO [dbo].[movies] ([title], [synopsis], [duration_mins], [release_date], [language], [age_rating]) VALUES
('Inception', 'A skilled thief enters dreams to steal secrets but is given a final impossible mission.', 148, '2010-07-16', 'English', 'PG-13'),
('Interstellar', 'A team of explorers travels through a wormhole in space to secure humanity''s future.', 169, '2014-11-07', 'English', 'PG-13'),
('The Dark Knight', 'Batman faces the Joker in a battle that tests Gotham''s limits.', 152, '2008-07-18', 'English', 'PG-13'),
('Avatar: The Way of Water', 'Jake Sully and his family face a new threat on Pandora.', 192, '2022-12-16', 'English', 'PG-13'),
('Dune: Part Two', 'Paul Atreides unites with the Fremen on a path of revenge and destiny.', 166, '2024-03-01', 'English', 'PG-13');

INSERT INTO [dbo].[users] ([full_name], [email], [password_hash], [phone], [created_at], [status]) VALUES
('HUSAM ABBAAS', 'husam.abbaas@example.com', 'hash_husam123', '+971501111111', '2026-04-01 10:00:00', 'active'),
('MOHAMMED TAREQ', 'mohammed.tareq@example.com', 'hash_tareq123', '+971502222222', '2026-04-02 11:15:00', 'active'),
('MOHAMMED ALAILA', 'mohammed.alaila@example.com', 'hash_alaila123', '+971503333333', '2026-04-03 09:30:00', 'active'),
('ABDULRAHMAN AWNI', 'abdulrahman.awni@example.com', 'hash_awni123', '+971504444444', '2026-04-03 14:20:00', 'active');

INSERT INTO [dbo].[auditoriums] ([cinema_id], [auditorium_name]) VALUES
(1, 'Screen 1'),
(1, 'Screen 2'),
(2, 'IMAX'),
(2, 'Screen 4'),
(3, 'Screen A');

INSERT INTO [dbo].[seats] ([auditorium_id], [row_label], [seat_number], [seat_type]) VALUES
(1, 'A', '1', 'Regular'),
(1, 'A', '2', 'Regular'),
(1, 'A', '3', 'Regular'),
(1, 'B', '1', 'Premium'),
(1, 'B', '2', 'Premium'),
(2, 'A', '1', 'Regular'),
(2, 'A', '2', 'Regular'),
(2, 'B', '1', 'Premium'),
(2, 'B', '2', 'Premium'),
(3, 'C', '1', 'VIP'),
(3, 'C', '2', 'VIP'),
(3, 'D', '1', 'Regular'),
(3, 'D', '2', 'Regular'),
(4, 'A', '1', 'Regular'),
(4, 'A', '2', 'Regular'),
(4, 'B', '1', 'Premium'),
(5, 'E', '1', 'Regular'),
(5, 'E', '2', 'Regular'),
(5, 'F', '1', 'Premium'),
(5, 'F', '2', 'Premium');

INSERT INTO [dbo].[screenings] ([movie_id], [auditorium_id], [start_time], [end_time], [screening_format], [base_price], [status]) VALUES
(1, 1, '2026-04-15 14:00:00', '2026-04-15 16:28:00', '2D', 35.00, 'scheduled'),
(2, 2, '2026-04-15 17:00:00', '2026-04-15 19:49:00', '2D', 40.00, 'scheduled'),
(3, 3, '2026-04-15 20:00:00', '2026-04-15 22:32:00', 'IMAX', 55.00, 'scheduled'),
(4, 4, '2026-04-16 15:30:00', '2026-04-16 18:42:00', '3D', 50.00, 'scheduled'),
(5, 5, '2026-04-16 19:00:00', '2026-04-16 21:46:00', '2D', 45.00, 'scheduled');

INSERT INTO [dbo].[reservations] ([user_id], [screening_id], [reserved_at], [status]) VALUES
(1, 1, '2026-04-14 18:00:00', 'confirmed'),
(2, 2, '2026-04-14 18:10:00', 'confirmed'),
(3, 3, '2026-04-14 18:20:00', 'pending'),
(4, 5, '2026-04-14 18:30:00', 'confirmed');

INSERT INTO [dbo].[tickets] ([reservation_id], [seat_id], [ticket_price], [ticket_status], [qr_code]) VALUES
(1, 1, 35.00, 'issued', 'QR-RES1-SEAT1'),
(1, 2, 35.00, 'issued', 'QR-RES1-SEAT2'),
(2, 6, 40.00, 'issued', 'QR-RES2-SEAT6'),
(3, 10, 55.00, 'reserved', 'QR-RES3-SEAT10'),
(4, 17, 45.00, 'issued', 'QR-RES4-SEAT17'),
(4, 18, 45.00, 'issued', 'QR-RES4-SEAT18');

INSERT INTO [dbo].[reviews] ([user_id], [movie_id], [rating], [review_text], [reviewed_at]) VALUES
(1, 1, 5, 'Excellent movie with a very clever story.', '2026-04-10 20:00:00'),
(2, 2, 5, 'Amazing visuals and emotional depth.', '2026-04-11 21:15:00'),
(3, 3, 4, 'Great action and performance by the villain.', '2026-04-12 19:40:00'),
(4, 5, 5, 'Epic and visually stunning adaptation.', '2026-04-13 22:05:00');

SELECT * FROM auditoriums;
SELECT * FROM cinemas;
SELECT * FROM movies;
SELECT * FROM reservations;
SELECT * FROM reviews;
SELECT * FROM screenings;
SELECT * FROM seats;
SELECT * FROM tickets;
SELECT * FROM users;
