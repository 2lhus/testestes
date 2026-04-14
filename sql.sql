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
