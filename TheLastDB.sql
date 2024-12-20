Create database [VJNDB491]
GO
USE [VJNDB491]
GO
/****** Object:  UserDefinedFunction [dbo].[CalculateSimilarity]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CalculateSimilarity](@text1 NVARCHAR(MAX), @text2 NVARCHAR(MAX))
RETURNS FLOAT
AS
BEGIN
    DECLARE @DotProduct FLOAT;
    DECLARE @Magnitude1 FLOAT;
    DECLARE @Magnitude2 FLOAT;

    WITH WordCounts AS
    (
        -- Tạo bảng với từ và số lần xuất hiện cho văn bản 1
        SELECT value AS Word, COUNT(*) AS Count1, 0 AS Count2
        FROM STRING_SPLIT(LOWER(dbo.RemoveDiacritics(@text1)), ' ')
        GROUP BY value

        UNION ALL

        -- Tạo bảng với từ và số lần xuất hiện cho văn bản 2
        SELECT value AS Word, 0 AS Count1, COUNT(*) AS Count2
        FROM STRING_SPLIT(LOWER(dbo.RemoveDiacritics(@text2)), ' ')
        GROUP BY value
    ),
    WordCount AS
    (
        SELECT
            Word,
            SUM(Count1) AS Count1,
            SUM(Count2) AS Count2
        FROM WordCounts
        GROUP BY Word
    ),
    SimilarityCalc AS
    (
        SELECT
            SUM(COALESCE(Count1, 0) * COALESCE(Count2, 0)) AS DotProduct,
            SQRT(SUM(POWER(COALESCE(Count1, 0), 2))) AS Magnitude1,
            SQRT(SUM(POWER(COALESCE(Count2, 0), 2))) AS Magnitude2
        FROM WordCount
    )
    SELECT 
        @DotProduct = DotProduct,
        @Magnitude1 = Magnitude1,
        @Magnitude2 = Magnitude2
    FROM SimilarityCalc;

    -- Tính toán độ tương đồng
    RETURN CASE 
        WHEN @Magnitude1 > 0 AND @Magnitude2 > 0 
        THEN @DotProduct / (@Magnitude1 * @Magnitude2) 
        ELSE 0 
    END;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[RemoveDiacritics]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[RemoveDiacritics](@text nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN
    DECLARE @result nvarchar(max);
    SET @result = @text;
    
    SET @result = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@result,N'á',N'a'),N'à',N'a'),N'ả',N'a'),N'ã',N'a'),N'ạ',N'a');
    SET @result = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@result,N'â',N'a'),N'ấ',N'a'),N'ầ',N'a'),N'ẩ',N'a'),N'ẫ',N'a');
    SET @result = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@result,N'ậ',N'a'),N'ă',N'a'),N'ắ',N'a'),N'ằ',N'a'),N'ẳ',N'a');
    SET @result = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@result,N'ẵ',N'a'),N'ặ',N'a'),N'đ',N'd'),N'é',N'e'),N'è',N'e');
    SET @result = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@result,N'ẻ',N'e'),N'ẽ',N'e'),N'ẹ',N'e'),N'ê',N'e'),N'ế',N'e');
    SET @result = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@result,N'ề',N'e'),N'ể',N'e'),N'ễ',N'e'),N'ệ',N'e'),N'í',N'i');
    SET @result = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@result,N'ì',N'i'),N'ỉ',N'i'),N'ĩ',N'i'),N'ị',N'i'),N'ó',N'o');
    SET @result = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@result,N'ò',N'o'),N'ỏ',N'o'),N'õ',N'o'),N'ọ',N'o'),N'ô',N'o');
    SET @result = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@result,N'ố',N'o'),N'ồ',N'o'),N'ổ',N'o'),N'ỗ',N'o'),N'ộ',N'o');
    SET @result = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@result,N'ơ',N'o'),N'ớ',N'o'),N'ờ',N'o'),N'ở',N'o'),N'ỡ',N'o');
    SET @result = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@result,N'ợ',N'o'),N'ú',N'u'),N'ù',N'u'),N'ủ',N'u'),N'ũ',N'u');
    SET @result = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@result,N'ụ',N'u'),N'ư',N'u'),N'ứ',N'u'),N'ừ',N'u'),N'ử',N'u');
    SET @result = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@result,N'ữ',N'u'),N'ự',N'u'),N'ý',N'y'),N'ỳ',N'y'),N'ỷ',N'y');
    SET @result = REPLACE(REPLACE(@result,N'ỹ',N'y'),N'ỵ',N'y');
    
    RETURN @result;
END
GO
/****** Object:  Table [dbo].[ApplyJob]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApplyJob](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Post_Id] [int] NULL,
	[JobSeeker_Id] [int] NULL,
	[cv_ID] [int] NULL,
	[ApplyDate] [datetime] NULL,
	[Reason] [nvarchar](max) NULL,
	[Status] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BanUserLog]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BanUserLog](
	[Ban_Id] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[AdminID] [int] NULL,
	[BanReason] [nvarchar](max) NULL,
	[BanDate] [datetime] NULL,
	[UnbanDate] [datetime] NULL,
	[Status] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Ban_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Blog]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Blog](
	[Blog_Id] [int] IDENTITY(1,1) NOT NULL,
	[BlogTitle] [nvarchar](200) NULL,
	[BlogDescription] [nvarchar](max) NULL,
	[CreateDate] [datetime] NULL,
	[Author_Id] [int] NULL,
	[thumbnail] [int] NULL,
	[status] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Blog_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Chat]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Chat](
	[Chat_Id] [int] IDENTITY(1,1) NOT NULL,
	[SendFrom_Id] [int] NULL,
	[SendTo_Id] [int] NULL,
	[Message] [nvarchar](max) NULL,
	[SendTime] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Chat_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CurrentJob]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CurrentJob](
	[Current_Job_Id] [int] IDENTITY(1,1) NOT NULL,
	[Job_Name] [nvarchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[Current_Job_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Cv]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cv](
	[CvId] [int] IDENTITY(1,1) NOT NULL,
	[NameCv] [nvarchar](max) NULL,
	[UserId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[CvId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Favorite_List]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Favorite_List](
	[Favorite_List_Id] [int] IDENTITY(1,1) NOT NULL,
	[EmployerId] [int] NULL,
	[JobSeekerId] [int] NULL,
	[Description] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Favorite_List_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ImagePostJob]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImagePostJob](
	[ImageJob_Id] [int] IDENTITY(1,1) NOT NULL,
	[Post_Id] [int] NULL,
	[Image_Id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ImageJob_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ItemOfCv]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ItemOfCv](
	[ItemOfCvID] [int] IDENTITY(1,1) NOT NULL,
	[CvId] [int] NULL,
	[ItemName] [nvarchar](max) NULL,
	[ItemDescription] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[ItemOfCvID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[JobCategory]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JobCategory](
	[JobCategory_Id] [int] IDENTITY(1,1) NOT NULL,
	[JobCategoryName] [nvarchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[JobCategory_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[JobPostDates]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JobPostDates](
	[EventDate_Id] [int] IDENTITY(1,1) NOT NULL,
	[Post_Id] [int] NULL,
	[EventDate] [date] NULL,
	[StartTime] [time](7) NULL,
	[EndTime] [time](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[EventDate_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[JobSchedule]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JobSchedule](
	[Schedule_Id] [int] IDENTITY(1,1) NOT NULL,
	[SlotId] [int] NULL,
	[DayOfWeek] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Schedule_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[log]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[log](
	[Log_id] [int] IDENTITY(1,1) NOT NULL,
	[User_Id] [int] NULL,
	[Action] [text] NULL,
	[Description] [text] NULL,
	[time] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MediaItems]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MediaItems](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[URL] [text] NULL,
	[Status] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Notification]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notification](
	[Notifycation_Id] [int] IDENTITY(1,1) NOT NULL,
	[User_ID] [int] NULL,
	[NotifycationContent] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[Notifycation_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PostJob]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PostJob](
	[Post_Id] [int] IDENTITY(1,1) NOT NULL,
	[JobTitle] [nvarchar](200) NULL,
	[JobDescription] [nvarchar](max) NULL,
	[salary_types_id] [int] NULL,
	[Salary] [money] NULL,
	[NumberPeople] [int] NULL,
	[Address] [nvarchar](max) NULL,
	[latitude] [decimal](17, 14) NULL,
	[longitude] [decimal](17, 14) NULL,
	[AuthorId] [int] NULL,
	[CreateDate] [datetime] NULL,
	[ExpirationDate] [datetime] NULL,
	[Status] [int] NULL,
	[censor_Id] [int] NULL,
	[censor_Date] [datetime] NULL,
	[Reason] [nvarchar](max) NULL,
	[IsUrgentRecruitment] [bit] NULL,
	[JobCategory_Id] [int] NULL,
	[time] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Post_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RegisterEmployer]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegisterEmployer](
	[RegisterEmployer_Id] [int] IDENTITY(1,1) NOT NULL,
	[User_Id] [int] NULL,
	[BussinessName] [nvarchar](200) NULL,
	[BussinessAddress] [nvarchar](max) NULL,
	[CreateDate] [datetime2](7) NULL,
	[Reason] [nvarchar](max) NULL,
	[status] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[RegisterEmployer_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RegisterEmployerMedia]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegisterEmployerMedia](
	[RegisterEmployerMedia] [int] IDENTITY(1,1) NOT NULL,
	[RegisterEmployer_Id] [int] NULL,
	[Media_Id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[RegisterEmployerMedia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Report]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Report](
	[Report_Id] [int] IDENTITY(1,1) NOT NULL,
	[JobSeeker_Id] [int] NULL,
	[Reason] [nvarchar](max) NULL,
	[Post_Id] [int] NULL,
	[CreateDate] [datetime] NULL,
	[Status] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Report_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReportMedia]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReportMedia](
	[ReportImage_Id] [int] IDENTITY(1,1) NOT NULL,
	[Report_Id] [int] NULL,
	[Image_Id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ReportImage_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[role]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[role](
	[Role_Id] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Role_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[salary_types]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[salary_types](
	[salary_types_id] [int] IDENTITY(1,1) NOT NULL,
	[type_name] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[salary_types_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Service]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Service](
	[Service_id] [int] IDENTITY(1,1) NOT NULL,
	[User_Id] [int] NULL,
	[NumberPosts] [int] NULL,
	[NumberPostsUrgentRecruitment] [int] NULL,
	[IsFindJobseekers] [int] NULL,
	[Expiration_Date] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Service_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Service_price_list]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Service_price_list](
	[Service_price_id] [int] IDENTITY(1,1) NOT NULL,
	[NumberPosts] [int] NULL,
	[NumberPostsUrgentRecruitment] [int] NULL,
	[IsFindJobseekers] [int] NULL,
	[durationsMonth] [int] NULL,
	[Price] [money] NULL,
	[Service_price_Name] [nvarchar](max) NULL,
	[Status] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Service_price_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Service_price_Log]    Script Date: 12/15/2024 2:38:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Service_price_Log](
	[Service_price_Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[User_Id] [int] NULL,
	[Service_price_id] [int] NULL,
	[Register_Date] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Service_price_Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Slot]    Script Date: 12/15/2024 2:38:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Slot](
	[Slot_Id] [int] IDENTITY(1,1) NOT NULL,
	[Post_Id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Slot_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[User]    Script Date: 12/15/2024 2:38:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User](
	[User_Id] [int] IDENTITY(1,1) NOT NULL,
	[Email] [nvarchar](100) NULL,
	[Avatar] [int] NULL,
	[FullName] [nvarchar](100) NULL,
	[Password] [varchar](max) NULL,
	[Age] [int] NULL,
	[Phonenumber] [varchar](10) NULL,
	[CurrentJob] [int] NULL,
	[Description] [nvarchar](max) NULL,
	[Address] [nvarchar](max) NULL,
	[Balance] [money] NULL,
	[Status] [int] NULL,
	[Gender] [bit] NULL,
	[SendCodeTime] [datetime] NULL,
	[VerifyCode] [varchar](5) NULL,
	[Role_Id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WishJob]    Script Date: 12/15/2024 2:38:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WishJob](
	[WishJob_Id] [int] IDENTITY(1,1) NOT NULL,
	[PostJob_Id] [int] NULL,
	[JobSeeker_Id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[WishJob_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkingHour]    Script Date: 12/15/2024 2:38:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkingHour](
	[WorkingHour_Id] [int] IDENTITY(1,1) NOT NULL,
	[Schedule_Id] [int] NULL,
	[StartTime] [time](7) NULL,
	[EndTime] [time](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[WorkingHour_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[ApplyJob] ON 

INSERT [dbo].[ApplyJob] ([id], [Post_Id], [JobSeeker_Id], [cv_ID], [ApplyDate], [Reason], [Status]) VALUES (1, 3, 19, 1, CAST(N'2024-12-13T08:14:47.173' AS DateTime), NULL, 1)
INSERT [dbo].[ApplyJob] ([id], [Post_Id], [JobSeeker_Id], [cv_ID], [ApplyDate], [Reason], [Status]) VALUES (2, 3, 19, 2, CAST(N'2024-12-13T08:17:36.640' AS DateTime), NULL, 5)
SET IDENTITY_INSERT [dbo].[ApplyJob] OFF
GO
SET IDENTITY_INSERT [dbo].[Blog] ON 

INSERT [dbo].[Blog] ([Blog_Id], [BlogTitle], [BlogDescription], [CreateDate], [Author_Id], [thumbnail], [status]) VALUES (1, N'Các trung tâm giới thiệu việc làm uy tín hàng đầu hiện nay', N'Trung tâm giới thiệu việc làm là gì?
Trung tâm giới thiệu việc làm là đơn vị do cơ quan Nhà nước có thẩm quyền thành lập. Đơn vị này có nhiệm vụ triển khai dịch vụ công về việc làm theo quy định của pháp luật. 

Hiểu đơn giản, trung tâm giới thiệu việc làm là cầu nối giữa người lao động và người sử dụng lao động. Đối với người lao động, trung tâm có nhiệm vụ cung cấp các dịch vụ, thông tin về công việc, nhằm giúp người lao động tìm được công việc phù hợp với nhu cầu và năng lực của bản thân. Đồng thời, trung tâm dịch vụ việc làm hỗ trợ người sử dụng lao động tìm kiếm và lựa chọn ứng viên phù hợp.', CAST(N'2024-12-13T01:39:56.157' AS DateTime), 17, 2, 1)
INSERT [dbo].[Blog] ([Blog_Id], [BlogTitle], [BlogDescription], [CreateDate], [Author_Id], [thumbnail], [status]) VALUES (2, N'Ngành cơ khí là gì? Học ngành cơ khí ra làm gì?', N'Cơ khí là ngành học đóng vai trò vô cùng quan trọng đối với sự phát triển kinh tế và xã hội. Muốn máy móc và các thiết bị phục vụ cho quá trình sản xuất sản phẩm hoạt động tốt thì cần đến sự tham gia của kỹ sư cơ khí. Vậy ngành cơ khí là gì? Ngành cơ khí là khối ngành liên quan đến việc ứng dụng các nguyên lý vật lý, kỹ thuật và khoa học vào quá trình thiết kế, bảo trì, chế tạo, bảo dưỡng những loại máy móc nằm trong hệ thống cơ khí phục vụ cho ngành công nghiệp sản xuất. ', CAST(N'2024-12-13T01:51:21.470' AS DateTime), 17, 3, 1)
INSERT [dbo].[Blog] ([Blog_Id], [BlogTitle], [BlogDescription], [CreateDate], [Author_Id], [thumbnail], [status]) VALUES (3, N'Cộng tác viên viết bài - Nghề "hái ra tiền"', N'Cộng tác viên viết bài là gì?
Để hiểu được khái niệm này, trước tiên bạn cần biết thế nào là một “cộng tác viên”.

Cộng tác viên chính là những người/nhân sự làm một hoặc nhiều công việc khác nhau, không nằm trong biên chế, không mang tính “chính thức” của một đơn vị, công ty, doanh nghiệp, tổ chức hoặc cơ quan nhất định.

Vậy, cộng tác viên viết bài có thể hiểu là một công việc phụ trách sản xuất các bài viết (bài SEO, bài PR cho báo, bài viết Social, v.vv..) cho một đơn vị, cá nhân, tổ chức, doanh nghiệp theo hình thức cộng tác và không chính thức.', CAST(N'2024-12-13T01:52:19.913' AS DateTime), 17, 4, 1)
SET IDENTITY_INSERT [dbo].[Blog] OFF
GO
SET IDENTITY_INSERT [dbo].[CurrentJob] ON 

INSERT [dbo].[CurrentJob] ([Current_Job_Id], [Job_Name]) VALUES (1, N'Thất nghiệp')
INSERT [dbo].[CurrentJob] ([Current_Job_Id], [Job_Name]) VALUES (2, N'Đang đi học')
INSERT [dbo].[CurrentJob] ([Current_Job_Id], [Job_Name]) VALUES (3, N'Đang đi làm')
SET IDENTITY_INSERT [dbo].[CurrentJob] OFF
GO
SET IDENTITY_INSERT [dbo].[Cv] ON 

INSERT [dbo].[Cv] ([CvId], [NameCv], [UserId]) VALUES (1, N'CV xin việc ', NULL)
INSERT [dbo].[Cv] ([CvId], [NameCv], [UserId]) VALUES (2, N'CV xin việc lần 2', NULL)
INSERT [dbo].[Cv] ([CvId], [NameCv], [UserId]) VALUES (3, N'CV nhân viên sự kiện', NULL)
INSERT [dbo].[Cv] ([CvId], [NameCv], [UserId]) VALUES (4, N'CV Công việc chân tay', NULL)
INSERT [dbo].[Cv] ([CvId], [NameCv], [UserId]) VALUES (5, N'CV Lao động chân tay', NULL)
INSERT [dbo].[Cv] ([CvId], [NameCv], [UserId]) VALUES (6, N'CV Lao động chân tay', NULL)
INSERT [dbo].[Cv] ([CvId], [NameCv], [UserId]) VALUES (7, N'CV hành chính ', 21)
INSERT [dbo].[Cv] ([CvId], [NameCv], [UserId]) VALUES (8, N'CV nhân viên sự kiện', NULL)
INSERT [dbo].[Cv] ([CvId], [NameCv], [UserId]) VALUES (9, N'CV nhân viên sự kiện', 19)
SET IDENTITY_INSERT [dbo].[Cv] OFF
GO
SET IDENTITY_INSERT [dbo].[ImagePostJob] ON 

INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (1, 1, 10)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (2, 1, 9)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (3, 1, 12)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (4, 1, 13)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (5, 2, 10)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (6, 2, 9)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (7, 2, 12)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (8, 2, 13)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (9, 3, 16)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (10, 3, 15)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (11, 3, 17)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (12, 5, 22)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (13, 5, 20)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (14, 5, 21)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (15, 6, 23)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (16, 7, 24)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (17, 8, 22)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (18, 8, 20)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (19, 8, 21)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (20, 9, 24)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (21, 9, 25)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (22, 9, 26)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (23, 10, 22)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (24, 10, 20)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (25, 10, 21)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (26, 11, 24)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (27, 11, 26)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (28, 12, 22)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (29, 12, 20)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (30, 12, 21)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (31, 14, 24)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (32, 14, 26)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (33, 13, 24)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (34, 13, 26)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (35, 15, 22)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (36, 15, 23)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (37, 15, 20)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (38, 16, 27)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (39, 16, 25)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (40, 16, 28)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (41, 17, 24)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (42, 17, 25)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (43, 18, 20)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (44, 18, 25)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (45, 18, 21)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (46, 19, 25)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (47, 19, 21)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (48, 19, 26)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (49, 20, 29)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (50, 20, 22)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (51, 20, 20)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (52, 20, 25)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (53, 21, 29)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (54, 21, 23)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (55, 21, 25)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (56, 22, 22)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (57, 22, 23)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (58, 22, 25)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (59, 22, 21)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (60, 23, 22)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (61, 23, 23)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (62, 23, 24)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (63, 24, 25)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (64, 24, 21)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (65, 24, 26)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (66, 25, 27)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (67, 25, 20)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (68, 25, 25)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (70, 26, 29)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (71, 26, 22)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (72, 26, 20)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (73, 26, 25)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (74, 27, 21)
INSERT [dbo].[ImagePostJob] ([ImageJob_Id], [Post_Id], [Image_Id]) VALUES (75, 28, 21)
SET IDENTITY_INSERT [dbo].[ImagePostJob] OFF
GO
SET IDENTITY_INSERT [dbo].[ItemOfCv] ON 

INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (1, 1, N'Kỹ năng ', N'có thể đứng bán hàng, nói chuyện nhẹ nhàng')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (2, 1, N'ưu điểm', N'chăm chỉ cần cù, siêng năng')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (3, 2, N'Kỹ năng', N'có thể đứng bán hàng, nói chuyện nhẹ nhàng')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (4, 2, N'ưu điểm', N'chăm chỉ cần cù, siêng năng')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (5, 3, N'Mục tiêu nghề nghiệp', N'Tìm kiếm cơ hội làm việc part-time trong lĩnh vực tổ chức sự kiện để phát triển kỹ năng giao tiếp, làm việc nhóm và tích lũy kinh nghiệm thực tế trong môi trường năng động.')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (6, 3, N'Kinh nghiệm làm việc', N'Nhân viên hỗ trợ sự kiện tại Công ty ABC 07/2019 - 12/2019')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (7, 3, N'Thành tích', N'Nhận được lời khen từ quản lý vì tinh thần làm việc trách nhiệm')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (8, 3, N'Kỹ năng', N'Giao tiếp tốt, thân thiện với khách hàng.
Làm việc nhóm hiệu quả, chịu áp lực cao.
Kỹ năng tổ chức và quản lý thời gian.
')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (9, 3, N'Trình độ học vấn', N'Sinh viên năm 3, ngành Truyền thông Đa phương tiện')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (10, 4, N'Mục tiêu nghề nghiệp', N'Tìm kiếm công việc part-time chân tay phù hợp để tăng thêm thu nhập và phát triển sự bền bỉ, trách nhiệm trong công việc.')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (11, 4, N'Kinh nghiệm làm việc', N'Nhân viên bốc xếp tại Kho Hàng XYZ 05/2023 - 08/2023')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (12, 4, N'Thành tích', N'Được đề xuất tăng ca nhờ hoàn thành công việc nhanh chóng và chính xác.')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (13, 4, N'Kỹ năng', N'Thể lực tốt, quen với công việc chân tay.
Kỹ năng quản lý thời gian hiệu quả.
Sẵn sàng làm việc ngoài giờ và hỗ trợ nhóm')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (14, 4, N'Trình độ học vấn', N'Sinh viên năm cuối đại học FPT')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (15, 5, N'Mục tiêu nghề nghiệp', N'Tìm kiếm công việc part-time chân tay phù hợp để tăng thêm thu nhập và phát triển sự bền bỉ, trách nhiệm trong công việc.')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (16, 5, N'Kinh nghiệm làm việc', N'Nhân viên bốc xếp, lao động chân tay tại Kho Hàng XYZ 05/2023 - 08/2023')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (17, 5, N'Thành tích', N'Được đề xuất tăng ca nhờ hoàn thành công việc nhanh chóng và chính xác.')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (18, 5, N'Kỹ năng', N'Thể lực tốt, quen với công việc chân tay.
Kỹ năng quản lý thời gian hiệu quả.
Sẵn sàng làm việc ngoài giờ và hỗ trợ nhóm')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (19, 5, N'Trình độ học vấn', N'Sinh viên năm cuối đại học FPT')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (20, 6, N'Mục tiêu nghề nghiệp', N'Tìm kiếm công việc part-time chân tay phù hợp để tăng thêm thu nhập và phát triển sự bền bỉ, trách nhiệm trong công việc.')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (21, 6, N'Kinh nghiệm làm việc', N'Nhân viên bốc xếp, lao động chân tay tại Kho Hàng XYZ 05/2023 - 08/2023')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (22, 6, N'Thành tích', N'Lao động chân tay giỏi')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (23, 6, N'Kỹ năng', N'Thể lực tốt, quen với công việc chân tay.')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (24, 6, N'Trình độ học vấn', N'Sinh viên năm cuối đại học FPT')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (25, 7, N'Kinh nghiệm làm việc', N'Nhân viên hành chính tại Công ty TNHH ABC')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (26, 7, N'Mục tiêu nghề nghiệp', N'Mong muốn phát triển sự nghiệp trong lĩnh vực hành chính văn phòng')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (27, 7, N'Thành tích', N'Nhân viên hành chính xuất sắc')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (28, 7, N'Kỹ năng', N'Có kỹ năng hành chính tốt ')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (29, 7, N'Bằng cấp', N'Có bằng của học viện hành chính')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (30, 8, N'Mục tiêu nghề nghiệp', N'Tìm kiếm cơ hội làm việc part-time trong lĩnh vực tổ chức sự kiện ')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (31, 8, N'Kinh nghiệm làm việc', N'Nhân viên hỗ trợ sự kiện tại Công ty ABC 07/2019 - 12/2019')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (32, 8, N'Thành tích', N'tổ chức sự kiện tốt')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (33, 8, N'Kỹ năng', N'làm việc sự kiện có hiệu quả 
')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (34, 8, N'Trình độ học vấn', N'Sinh viên năm 3, ngành sự kiện ')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (35, 9, N'Mục tiêu nghề nghiệp', N'Tìm kiếm cơ hội làm việc part-time trong lĩnh vực tổ chức sự kiện ')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (36, 9, N'Kinh nghiệm làm việc', N'Nhân viên hỗ trợ sự kiện tại ABC 07/2019 - 12/2019')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (37, 9, N'Thành tích', N'tổ chức sự kiện tốt')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (38, 9, N'Kỹ năng', N'làm việc sự kiện có hiệu quả 
')
INSERT [dbo].[ItemOfCv] ([ItemOfCvID], [CvId], [ItemName], [ItemDescription]) VALUES (39, 9, N'Trình độ học vấn', N'Sinh viên năm 3, ngành sự kiện ')
SET IDENTITY_INSERT [dbo].[ItemOfCv] OFF
GO
SET IDENTITY_INSERT [dbo].[JobCategory] ON 

INSERT [dbo].[JobCategory] ([JobCategory_Id], [JobCategoryName]) VALUES (1, N'Hành chính')
INSERT [dbo].[JobCategory] ([JobCategory_Id], [JobCategoryName]) VALUES (2, N'Bán hàng & Tiếp thị')
INSERT [dbo].[JobCategory] ([JobCategory_Id], [JobCategoryName]) VALUES (3, N'Dịch vụ khách hàng')
INSERT [dbo].[JobCategory] ([JobCategory_Id], [JobCategoryName]) VALUES (4, N'Nhân viên sự kiện')
INSERT [dbo].[JobCategory] ([JobCategory_Id], [JobCategoryName]) VALUES (5, N'Nhà hàng, khách sạn')
INSERT [dbo].[JobCategory] ([JobCategory_Id], [JobCategoryName]) VALUES (6, N'Bán lẻ')
INSERT [dbo].[JobCategory] ([JobCategory_Id], [JobCategoryName]) VALUES (7, N'Hậu cần & Giao hàng')
INSERT [dbo].[JobCategory] ([JobCategory_Id], [JobCategoryName]) VALUES (8, N'Lao động chân tay')
INSERT [dbo].[JobCategory] ([JobCategory_Id], [JobCategoryName]) VALUES (9, N'Sáng tạo & Truyền thông')
INSERT [dbo].[JobCategory] ([JobCategory_Id], [JobCategoryName]) VALUES (10, N'Hỗ trợ kỹ thuật')
SET IDENTITY_INSERT [dbo].[JobCategory] OFF
GO
SET IDENTITY_INSERT [dbo].[JobPostDates] ON 

INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (4, 5, CAST(N'2024-12-30' AS Date), CAST(N'08:00:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (5, 6, CAST(N'2024-12-30' AS Date), CAST(N'08:00:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (6, 7, CAST(N'2024-12-30' AS Date), CAST(N'08:00:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (7, 8, CAST(N'2024-12-30' AS Date), CAST(N'08:00:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (8, 9, CAST(N'2024-12-30' AS Date), CAST(N'08:00:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (9, 10, CAST(N'2024-01-01' AS Date), CAST(N'08:00:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (10, 11, CAST(N'2024-12-30' AS Date), CAST(N'08:00:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (11, 12, CAST(N'2024-12-30' AS Date), CAST(N'08:00:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (13, 14, CAST(N'2024-12-30' AS Date), CAST(N'08:00:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (15, 13, CAST(N'2024-12-30' AS Date), CAST(N'08:00:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (16, 15, CAST(N'2024-12-30' AS Date), CAST(N'08:00:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (17, 16, CAST(N'2024-12-22' AS Date), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (18, 17, CAST(N'2024-12-22' AS Date), CAST(N'08:00:00' AS Time), CAST(N'21:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (20, 18, CAST(N'2024-12-14' AS Date), CAST(N'09:00:00' AS Time), CAST(N'21:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (21, 19, CAST(N'2024-12-30' AS Date), CAST(N'09:00:00' AS Time), CAST(N'21:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (24, 20, CAST(N'2024-12-30' AS Date), CAST(N'09:00:00' AS Time), CAST(N'21:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (25, 21, CAST(N'2024-12-30' AS Date), CAST(N'09:00:00' AS Time), CAST(N'21:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (26, 22, CAST(N'2024-12-30' AS Date), CAST(N'09:00:00' AS Time), CAST(N'21:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (27, 23, CAST(N'2024-12-30' AS Date), CAST(N'09:00:00' AS Time), CAST(N'21:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (28, 24, CAST(N'2024-12-30' AS Date), CAST(N'09:00:00' AS Time), CAST(N'20:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (30, 25, CAST(N'2024-12-30' AS Date), CAST(N'09:00:00' AS Time), CAST(N'21:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (31, 26, CAST(N'2024-12-20' AS Date), CAST(N'09:00:00' AS Time), CAST(N'21:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (32, 27, CAST(N'2024-12-30' AS Date), CAST(N'09:00:00' AS Time), CAST(N'21:00:00' AS Time))
INSERT [dbo].[JobPostDates] ([EventDate_Id], [Post_Id], [EventDate], [StartTime], [EndTime]) VALUES (33, 28, CAST(N'2024-12-30' AS Date), CAST(N'09:00:00' AS Time), CAST(N'21:00:00' AS Time))
SET IDENTITY_INSERT [dbo].[JobPostDates] OFF
GO
SET IDENTITY_INSERT [dbo].[JobSchedule] ON 

INSERT [dbo].[JobSchedule] ([Schedule_Id], [SlotId], [DayOfWeek]) VALUES (4, 2, 2)
INSERT [dbo].[JobSchedule] ([Schedule_Id], [SlotId], [DayOfWeek]) VALUES (5, 2, 3)
INSERT [dbo].[JobSchedule] ([Schedule_Id], [SlotId], [DayOfWeek]) VALUES (6, 2, 4)
INSERT [dbo].[JobSchedule] ([Schedule_Id], [SlotId], [DayOfWeek]) VALUES (7, 2, 5)
INSERT [dbo].[JobSchedule] ([Schedule_Id], [SlotId], [DayOfWeek]) VALUES (8, 3, 2)
INSERT [dbo].[JobSchedule] ([Schedule_Id], [SlotId], [DayOfWeek]) VALUES (9, 3, 3)
INSERT [dbo].[JobSchedule] ([Schedule_Id], [SlotId], [DayOfWeek]) VALUES (10, 3, 4)
INSERT [dbo].[JobSchedule] ([Schedule_Id], [SlotId], [DayOfWeek]) VALUES (11, 3, 5)
INSERT [dbo].[JobSchedule] ([Schedule_Id], [SlotId], [DayOfWeek]) VALUES (12, 4, 2)
INSERT [dbo].[JobSchedule] ([Schedule_Id], [SlotId], [DayOfWeek]) VALUES (13, 4, 3)
INSERT [dbo].[JobSchedule] ([Schedule_Id], [SlotId], [DayOfWeek]) VALUES (14, 4, 4)
INSERT [dbo].[JobSchedule] ([Schedule_Id], [SlotId], [DayOfWeek]) VALUES (15, 4, 5)
INSERT [dbo].[JobSchedule] ([Schedule_Id], [SlotId], [DayOfWeek]) VALUES (16, 4, 6)
SET IDENTITY_INSERT [dbo].[JobSchedule] OFF
GO
SET IDENTITY_INSERT [dbo].[MediaItems] ON 

INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (1, N'https://png.pngtree.com/png-clipart/20210608/ourlarge/pngtree-dark-gray-simple-avatar-png-image_3418404.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (2, N'https://ik.imagekit.io/ryf3sqxfn/blog1.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (3, N'https://ik.imagekit.io/ryf3sqxfn/Blog2.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (4, N'https://ik.imagekit.io/ryf3sqxfn/Blog3.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (5, N'https://lh3.googleusercontent.com/a/ACg8ocKixkPrQCL2KsyTl8Pas6sipJ9kzPRSz60QfhJMNtgtYleuZeDx=s96-c', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (6, N'https://ik.imagekit.io/ryf3sqxfn/sangxacminh1.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (7, N'https://ik.imagekit.io/ryf3sqxfn/sangxacming3.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (8, N'https://ik.imagekit.io/ryf3sqxfn/sangxacminh2.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (9, N'https://ik.imagekit.io/ryf3sqxfn/DH-FPT.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (10, N'https://ik.imagekit.io/ryf3sqxfn/toa-nha-alpha-duoc-coi-hinh-anh-dai-dien-cho-dai-hoc-fpt-ha-noi.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (11, N'https://ik.imagekit.io/ryf3sqxfn/120104872_3268805256506568_7902651859933549703_o.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (12, N'https://ik.imagekit.io/ryf3sqxfn/comchay4mua.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (13, N'https://ik.imagekit.io/ryf3sqxfn/job1.png', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (14, N'https://lh3.googleusercontent.com/a/ACg8ocJzHMzAr-EWL1-ASwQpGzWuLT-qxrkp7xuy6XRZwgqZJ14Zmw=s96-c', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (15, N'https://ik.imagekit.io/ryf3sqxfn/job2.jfif', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (16, N'https://ik.imagekit.io/ryf3sqxfn/quay-le-tan-khach-san-1-min.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (17, N'https://ik.imagekit.io/ryf3sqxfn/job3.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (18, N'https://lh3.googleusercontent.com/a/ACg8ocLwrQJ6bwwLrXbLGc9RVPjEqLHB1ayzrIO918recIh8lOJx4Q=s96-c', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (19, N'https://lh3.googleusercontent.com/a/ACg8ocJNWnkid2P9HcIvKqC3VkTyBv0cYdrSQZoPeYdlE2K7Jkx0hgxV=s96-c', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (20, N'https://ik.imagekit.io/ryf3sqxfn/nhan-vien-to-chuc-su-kien-1583-1.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (21, N'https://ik.imagekit.io/ryf3sqxfn/to-chuc-su-kien-thi-hoc-nganh-gi-7.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (22, N'https://ik.imagekit.io/ryf3sqxfn/cac-vi-tri-nhan-su-khi-to-chuc-su-kien-5.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (23, N'https://ik.imagekit.io/ryf3sqxfn/doan.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (24, N'https://ik.imagekit.io/ryf3sqxfn/giuxe.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (25, N'https://ik.imagekit.io/ryf3sqxfn/thue-cuu-van-hay-dich-vu-boc-xep.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (26, N'https://ik.imagekit.io/ryf3sqxfn/trongxe.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (27, N'https://ik.imagekit.io/ryf3sqxfn/mo-ta-cong-viec-nhan-vien-boc-xep-hang-hoa-va-muc-luong-2.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (28, N'https://ik.imagekit.io/ryf3sqxfn/Van-Chuyen-hang-Hoa-Di-Phu-Quoc-4-800x600.jpg', 1)
INSERT [dbo].[MediaItems] ([Id], [URL], [Status]) VALUES (29, N'https://ik.imagekit.io/ryf3sqxfn/blue-15861430266582095560107.jpg', 1)
SET IDENTITY_INSERT [dbo].[MediaItems] OFF
GO
SET IDENTITY_INSERT [dbo].[PostJob] ON 

INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (1, N'người đứng bán hàng', N'đứng bán hàng ở cổng trường để yêu cầu cần nói chuyện nhẹ nhàng với khách và không được thái độ không hay,  chăn chỉ cần cù siêng năng', 1, 25000.0000, 2, N'đối diện cổng trường đại học fpt cơ sở hòa lạc gần cổng ra vào bãi đỗ xe', CAST(21.01561155365943 AS Decimal(17, 14)), CAST(105.53432340217317 AS Decimal(17, 14)), 18, CAST(N'2024-12-13T02:30:32.013' AS DateTime), NULL, 0, NULL, NULL, NULL, 1, 8, 3)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (2, N'người đứng bán hàng', N'đứng bán hàng ở cổng trường để yêu cầu cần nói chuyện nhẹ nhàng với khách và không được thái độ không hay,  chăn chỉ cần cù siêng năng', 1, 25000.0000, 2, N'đối diện cổng trường đại học fpt cơ sở hòa lạc gần cổng ra vào bãi đỗ xe', CAST(21.01561155365943 AS Decimal(17, 14)), CAST(105.53432340217317 AS Decimal(17, 14)), 18, CAST(N'2024-12-13T02:35:12.357' AS DateTime), CAST(N'2025-03-13T02:43:00.833' AS DateTime), 2, 17, CAST(N'2024-12-13T02:43:00.833' AS DateTime), N'công việc có vấn đề về hình ảnh của công việc', 1, 8, 3)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (3, N'Nhân viên phục vụ, thu ngân', N'Chào đón khách, hướng dẫn khách vào bàn, Ghi nhận order từ khách, truyền đạt đến bộ phận bếp/bar, Đảm bảo khách được phục vụ đúng món, đúng thời gian', 5, 7000000.0000, 3, N'số 98, nguyễn văn linh, thị xã mỹ hào , tỉnh hưng yên', CAST(20.93366487662814 AS Decimal(17, 14)), CAST(106.05471611022950 AS Decimal(17, 14)), 18, CAST(N'2024-12-13T07:48:35.027' AS DateTime), CAST(N'2025-03-13T07:49:11.447' AS DateTime), 2, 17, CAST(N'2024-12-13T07:49:11.447' AS DateTime), NULL, 0, 3, 3)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (5, N'Nhân viên hỗ trợ tổ chức sự kiện', N'Chuẩn bị và sắp xếp bàn ghế, sân khấu.
Phối hợp để trang trí và set up không gian sự kiện.
Hỗ trợ các bộ phận khác trong quá trình tổ chức sự kiện.', 1, 50000.0000, 15, N'Quận 4, thành phố hồ chí minh', CAST(10.76730025000000 AS Decimal(17, 14)), CAST(106.70471844688726 AS Decimal(17, 14)), 20, CAST(N'2024-12-14T20:19:23.867' AS DateTime), CAST(N'2024-12-28T22:38:09.650' AS DateTime), 2, 17, CAST(N'2024-12-14T22:38:09.650' AS DateTime), NULL, 0, 4, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (6, N'Nhân viên phục vụ tại sự kiện', N'Phục vụ đồ ăn, thức uống cho khách tham dự.
Dọn dẹp khu vực sau sự kiện.
Đảm bảo thái độ thân thiện và chuyên nghiệp.', 1, 25000.0000, 20, N'Quận 3, Thành phố Hồ Chí Minh ', CAST(10.77863900000000 AS Decimal(17, 14)), CAST(106.68701560000000 AS Decimal(17, 14)), 20, CAST(N'2024-12-14T20:26:35.767' AS DateTime), CAST(N'2024-12-28T22:38:29.387' AS DateTime), 2, 17, CAST(N'2024-12-14T22:38:29.387' AS DateTime), NULL, 0, 4, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (7, N'Nhân viên check-in khách mời', N'Đón tiếp và hướng dẫn khách đến đúng khu vực.
Quản lý danh sách khách mời và phát tài liệu sự kiện.
Hỗ trợ giải đáp thắc mắc của khách mời.', 1, 40000.0000, 7, N'Quận 5, Thành phố Hồ Chí Minh', CAST(10.75536160000000 AS Decimal(17, 14)), CAST(106.66854410000000 AS Decimal(17, 14)), 20, CAST(N'2024-12-14T20:28:40.377' AS DateTime), CAST(N'2024-12-28T22:38:50.137' AS DateTime), 2, 17, CAST(N'2024-12-14T22:38:50.137' AS DateTime), NULL, 0, 4, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (8, N'Nhân viên quản lý sân khấu', N'Điều phối các tiết mục diễn ra đúng lịch trình.
Hỗ trợ nghệ sĩ, MC, hoặc các đội biểu diễn.
Đảm bảo âm thanh và ánh sáng hoạt động tốt.', 1, 50000.0000, 5, N'Quận 6, Thành phố Hồ Chí Minh', CAST(10.74588600000000 AS Decimal(17, 14)), CAST(106.63929210000000 AS Decimal(17, 14)), 20, CAST(N'2024-12-14T20:30:19.900' AS DateTime), CAST(N'2024-12-28T22:39:06.810' AS DateTime), 2, 17, CAST(N'2024-12-14T22:39:06.810' AS DateTime), NULL, 0, 4, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (9, N'Nhân viên phát tờ rơi và quảng bá sự kiện', N'Phát tờ rơi tại các khu vực đông người.
Quảng bá chương trình đến khách hàng tiềm năng.
Tương tác và giới thiệu sự kiện để thu hút người tham dự', 1, 50000.0000, 13, N'Quận 7, Thành phố Hồ Chí Minh', CAST(10.73754810000000 AS Decimal(17, 14)), CAST(106.73022380000000 AS Decimal(17, 14)), 20, CAST(N'2024-12-14T20:31:38.480' AS DateTime), CAST(N'2024-12-28T22:39:23.907' AS DateTime), 2, 17, CAST(N'2024-12-14T22:39:23.907' AS DateTime), NULL, 0, 4, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (10, N'Nhân viên chụp ảnh/quay phim sự kiện', N'Ghi lại các khoảnh khắc quan trọng tại sự kiện.
Chỉnh sửa hình ảnh hoặc video để sử dụng trong truyền thông.
Hợp tác với đội marketing để xuất bản nội dung.', 1, 100000.0000, 3, N'Quận 8, Thành phố Hồ Chí Minh', CAST(10.73754810000000 AS Decimal(17, 14)), CAST(106.73022380000000 AS Decimal(17, 14)), 20, CAST(N'2024-12-14T20:33:14.110' AS DateTime), CAST(N'2024-12-28T22:39:36.457' AS DateTime), 2, 17, CAST(N'2024-12-14T22:39:36.457' AS DateTime), NULL, 0, 4, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (11, N'Nhân viên bảo vệ sự kiện', N'Kiểm soát an ninh tại địa điểm tổ chức.
Hướng dẫn khách giữ trật tự và bảo vệ tài sản sự kiện.
Xử lý các tình huống khẩn cấp nếu xảy ra.', 1, 40000.0000, 8, N'Quận 8, Thành phố Hồ Chí Minh', CAST(10.72172360000000 AS Decimal(17, 14)), CAST(106.62961510000000 AS Decimal(17, 14)), 20, CAST(N'2024-12-14T20:34:29.430' AS DateTime), CAST(N'2024-12-28T22:39:54.890' AS DateTime), 2, 17, CAST(N'2024-12-14T22:39:54.890' AS DateTime), NULL, 0, 4, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (12, N'Nhân viên phát quà hoặc lưu niệm sự kiện', N'Phát quà tặng, phiếu giảm giá hoặc đồ lưu niệm cho khách mời.
Kiểm kê số lượng quà tặng trước và sau sự kiện.
Tương tác thân thiện để nâng cao trải nghiệm của khách hàng.', 1, 30000.0000, 7, N'Quận 10, Thành phố Hồ Chí Minh', CAST(10.77273200000000 AS Decimal(17, 14)), CAST(106.66836660000000 AS Decimal(17, 14)), 20, CAST(N'2024-12-14T20:35:56.443' AS DateTime), CAST(N'2024-12-28T22:41:36.720' AS DateTime), 2, 17, CAST(N'2024-12-14T22:41:36.720' AS DateTime), NULL, 0, 4, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (13, N'Nhân viên hướng dẫn và điều phối giao thông', N'Hướng dẫn khách đỗ xe đúng nơi quy định.
Đảm bảo không xảy ra ùn tắc tại khu vực sự kiện.
Phối hợp với các đơn vị tổ chức để hỗ trợ khách di chuyển thuận lợi.', 1, 40000.0000, 4, N'Quận 11, Thành phố Hồ Chí Minh', CAST(10.76581240000000 AS Decimal(17, 14)), CAST(106.64749460000000 AS Decimal(17, 14)), 20, CAST(N'2024-12-14T20:37:11.540' AS DateTime), NULL, 0, NULL, NULL, NULL, 0, 4, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (14, N'Nhân viên hướng dẫn và điều phối giao thông', N'Hướng dẫn khách đỗ xe đúng nơi quy định.
Đảm bảo không xảy ra ùn tắc tại khu vực sự kiện.
Phối hợp với các đơn vị tổ chức để hỗ trợ khách di chuyển thuận lợi.', 1, 40000.0000, 4, N'Quận 11, Thành phố Hồ Chí Minh', CAST(10.76581240000000 AS Decimal(17, 14)), CAST(106.64749460000000 AS Decimal(17, 14)), 20, CAST(N'2024-12-14T20:37:56.550' AS DateTime), CAST(N'2024-12-28T22:41:50.637' AS DateTime), 2, 17, CAST(N'2024-12-14T22:41:50.637' AS DateTime), NULL, 0, 4, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (15, N'Nhân viên bán hàng tại sự kiện', N'Tư vấn và bán sản phẩm hoặc dịch vụ tại gian hàng sự kiện.
Thực hiện các chương trình khuyến mãi trực tiếp tại sự kiện.
Ghi nhận phản hồi từ khách hàng để báo cáo sau sự kiện.', 1, 40000.0000, 7, N'Quận 12, Thành phố Hồ Chí Minh', CAST(10.86160360000000 AS Decimal(17, 14)), CAST(106.66097310000000 AS Decimal(17, 14)), 20, CAST(N'2024-12-14T21:30:25.730' AS DateTime), CAST(N'2024-12-28T22:43:06.853' AS DateTime), 2, 17, CAST(N'2024-12-14T22:43:06.853' AS DateTime), NULL, 0, 4, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (16, N'Nhân viên bốc xếp hàng hóa', N'Sắp xếp và vận chuyển hàng hóa tại kho bãi, cửa hàng hoặc siêu thị.', 1, 40000.0000, 7, N'Quận cầu giấy, Hà nội ', CAST(21.02950150000000 AS Decimal(17, 14)), CAST(105.79142120000000 AS Decimal(17, 14)), 18, CAST(N'2024-12-14T22:17:25.847' AS DateTime), CAST(N'2024-12-28T22:43:17.963' AS DateTime), 2, 17, CAST(N'2024-12-14T22:43:17.963' AS DateTime), NULL, 0, 8, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (17, N'Nhân viên giao hàng (shipper)', N'Giao hàng từ kho đến khách hàng trong khu vực được phân công.', 2, 300000.0000, 11, N'Quận đống đa, Hà nội', CAST(21.01364360000000 AS Decimal(17, 14)), CAST(105.82252340000000 AS Decimal(17, 14)), 18, CAST(N'2024-12-14T22:18:40.710' AS DateTime), CAST(N'2024-12-28T22:43:31.860' AS DateTime), 2, 17, CAST(N'2024-12-14T22:43:31.860' AS DateTime), NULL, 0, 8, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (18, N'Nhân viên vệ sinh công nghiệp', N'Lau dọn, làm sạch nhà ở, văn phòng, nhà xưởng, hoặc khu vực sự kiện.', 1, 60000.0000, 10, N'Quận Ba Đình, Hà nội', CAST(21.03444480000000 AS Decimal(17, 14)), CAST(105.83182690000000 AS Decimal(17, 14)), 18, CAST(N'2024-12-14T22:21:05.847' AS DateTime), CAST(N'2024-12-28T22:43:44.177' AS DateTime), 2, 17, CAST(N'2024-12-14T22:43:44.177' AS DateTime), NULL, 0, 8, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (19, N'Nhân viên giữ xe', N'Quản lý xe cộ tại các bãi giữ xe ở tòa nhà, siêu thị, hoặc sự kiện.', 1, 40000.0000, 7, N'Quận Nam Từ Liêm, Hà Nội', CAST(21.01735120000000 AS Decimal(17, 14)), CAST(105.76133290000000 AS Decimal(17, 14)), 18, CAST(N'2024-12-14T22:25:14.000' AS DateTime), CAST(N'2024-12-28T22:43:58.557' AS DateTime), 2, 17, CAST(N'2024-12-14T22:43:58.557' AS DateTime), NULL, 0, 8, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (20, N'Nhân viên thu hoạch nông sản', N'Hái rau, trái cây, hoặc làm các công việc liên quan đến chăm sóc và thu hoạch cây trồng.', 2, 350000.0000, 25, N'Quận Bắc Từ Liêm, Hà Nội', CAST(21.07125480000000 AS Decimal(17, 14)), CAST(105.76448550000000 AS Decimal(17, 14)), 18, CAST(N'2024-12-14T22:26:39.860' AS DateTime), NULL, 0, NULL, NULL, NULL, 0, 8, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (21, N'Nhân viên phụ bếp', N'Chuẩn bị nguyên liệu, rửa chén bát, hỗ trợ nấu ăn tại nhà hàng hoặc tiệc cưới.', 1, 50000.0000, 7, N'Quận Tây Hồ, Hà Nội ', CAST(21.06835760000000 AS Decimal(17, 14)), CAST(105.82409840000000 AS Decimal(17, 14)), 18, CAST(N'2024-12-14T22:28:50.647' AS DateTime), CAST(N'2024-12-28T22:44:25.997' AS DateTime), 2, 17, CAST(N'2024-12-14T22:44:25.997' AS DateTime), NULL, 0, 8, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (22, N'Nhân viên làm việc tại công trường', N'Hỗ trợ xây dựng, làm đường, hoặc các công việc cần sức lao động.', 2, 600000.0000, 15, N'Quận Hai Bà Trưng, Hà Nội', CAST(21.00885410000000 AS Decimal(17, 14)), CAST(105.85078160000000 AS Decimal(17, 14)), 18, CAST(N'2024-12-14T22:30:59.270' AS DateTime), NULL, 0, NULL, NULL, NULL, 0, 8, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (23, N'Nhân viên dọn dẹp tại sự kiện', N'Thu gom rác, lau dọn khu vực trước, trong, và sau sự kiện.', 1, 50000.0000, 11, N'Quận Hoàng Mai, Hà Nội', CAST(20.97575810000000 AS Decimal(17, 14)), CAST(105.86265560000000 AS Decimal(17, 14)), 18, CAST(N'2024-12-14T22:32:18.263' AS DateTime), CAST(N'2024-12-28T22:44:37.507' AS DateTime), 2, 17, CAST(N'2024-12-14T22:44:37.507' AS DateTime), NULL, 0, 8, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (24, N'Nhân viên đóng gói sản phẩm', N'Đóng gói, kiểm tra, và phân loại hàng hóa tại nhà máy hoặc kho.', 1, 40000.0000, 15, N'Quận Hà Đông, Hà Nội', CAST(20.95518550000000 AS Decimal(17, 14)), CAST(105.75801100000000 AS Decimal(17, 14)), 18, CAST(N'2024-12-14T22:34:17.033' AS DateTime), CAST(N'2024-12-28T22:44:49.923' AS DateTime), 2, 17, CAST(N'2024-12-14T22:44:49.923' AS DateTime), NULL, 0, 8, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (25, N'Nhân viên phụ quán ăn/quán cà phê', N'Hỗ trợ bưng bê, dọn bàn, hoặc rửa bát tại quán ăn hoặc quán cà phê.
', 1, 30000.0000, 4, N'Quận Thanh Xuân, Hà Nội', CAST(20.99441710000000 AS Decimal(17, 14)), CAST(105.81713160000000 AS Decimal(17, 14)), 18, CAST(N'2024-12-14T22:36:15.020' AS DateTime), CAST(N'2024-12-28T22:37:45.783' AS DateTime), 2, 17, CAST(N'2024-12-14T22:37:45.783' AS DateTime), NULL, 0, 8, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (26, N'Công việc hành chính ', N' Làm công việc hành chính tại công ti', 5, 10000000.0000, 2, N'Quận đống đa, hà nội ', CAST(21.01364360000000 AS Decimal(17, 14)), CAST(105.82252340000000 AS Decimal(17, 14)), 20, CAST(N'2024-12-14T23:13:57.523' AS DateTime), CAST(N'2025-01-14T23:22:49.747' AS DateTime), 2, 17, CAST(N'2024-12-14T23:22:49.747' AS DateTime), NULL, 0, 1, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (27, N'Trợ lý Hành chính', N'Hỗ trợ sếp hoặc bộ phận trong việc quản lý lịch làm việc, chuẩn bị tài liệu.', 2, 200000.0000, 3, N'Quận Thanh Xuân, Hà Nội', CAST(20.99441710000000 AS Decimal(17, 14)), CAST(105.81713160000000 AS Decimal(17, 14)), 20, CAST(N'2024-12-14T23:21:21.293' AS DateTime), CAST(N'2025-01-14T23:22:33.007' AS DateTime), 2, 17, CAST(N'2024-12-14T23:22:33.007' AS DateTime), NULL, 0, 1, 1)
INSERT [dbo].[PostJob] ([Post_Id], [JobTitle], [JobDescription], [salary_types_id], [Salary], [NumberPeople], [Address], [latitude], [longitude], [AuthorId], [CreateDate], [ExpirationDate], [Status], [censor_Id], [censor_Date], [Reason], [IsUrgentRecruitment], [JobCategory_Id], [time]) VALUES (28, N'Trợ lý Hành chính', N'Trợ lý hành chính của tổng giám đốc hành chính', 2, 200000.0000, 3, N'Quận Thanh Xuân, Hà Nội', CAST(20.99441710000000 AS Decimal(17, 14)), CAST(105.81713160000000 AS Decimal(17, 14)), 20, CAST(N'2024-12-14T23:38:59.663' AS DateTime), CAST(N'2025-01-14T23:39:20.657' AS DateTime), 2, 17, CAST(N'2024-12-14T23:39:20.657' AS DateTime), NULL, 0, 1, 1)
SET IDENTITY_INSERT [dbo].[PostJob] OFF
GO
SET IDENTITY_INSERT [dbo].[RegisterEmployer] ON 

INSERT [dbo].[RegisterEmployer] ([RegisterEmployer_Id], [User_Id], [BussinessName], [BussinessAddress], [CreateDate], [Reason], [status]) VALUES (1, 18, N'Quán cơm bốn mùa', N'Cổng trường đại học fpt cơ sở hòa lạc', CAST(N'2024-12-13T02:16:48.8693497' AS DateTime2), N'ảnh hơi mờ cần chụp rõ và cung cấp nhiều ảnh về địa chỉ hơn', 2)
INSERT [dbo].[RegisterEmployer] ([RegisterEmployer_Id], [User_Id], [BussinessName], [BussinessAddress], [CreateDate], [Reason], [status]) VALUES (2, 18, N'Quán cơm bốn mùa', N'Cổng trước của trường đại học fpt cơ sở hòa lạc', CAST(N'2024-12-13T02:25:25.3989054' AS DateTime2), NULL, 1)
INSERT [dbo].[RegisterEmployer] ([RegisterEmployer_Id], [User_Id], [BussinessName], [BussinessAddress], [CreateDate], [Reason], [status]) VALUES (3, 20, N'gia đinh đặng anh tuấn ', N'tân xã, thạch thất, hà nội', CAST(N'2024-12-13T07:54:09.7298352' AS DateTime2), NULL, 1)
SET IDENTITY_INSERT [dbo].[RegisterEmployer] OFF
GO
SET IDENTITY_INSERT [dbo].[RegisterEmployerMedia] ON 

INSERT [dbo].[RegisterEmployerMedia] ([RegisterEmployerMedia], [RegisterEmployer_Id], [Media_Id]) VALUES (1, 1, 7)
INSERT [dbo].[RegisterEmployerMedia] ([RegisterEmployerMedia], [RegisterEmployer_Id], [Media_Id]) VALUES (2, 1, 8)
INSERT [dbo].[RegisterEmployerMedia] ([RegisterEmployerMedia], [RegisterEmployer_Id], [Media_Id]) VALUES (3, 1, 6)
INSERT [dbo].[RegisterEmployerMedia] ([RegisterEmployerMedia], [RegisterEmployer_Id], [Media_Id]) VALUES (4, 1, 9)
INSERT [dbo].[RegisterEmployerMedia] ([RegisterEmployerMedia], [RegisterEmployer_Id], [Media_Id]) VALUES (5, 2, 7)
INSERT [dbo].[RegisterEmployerMedia] ([RegisterEmployerMedia], [RegisterEmployer_Id], [Media_Id]) VALUES (6, 2, 6)
INSERT [dbo].[RegisterEmployerMedia] ([RegisterEmployerMedia], [RegisterEmployer_Id], [Media_Id]) VALUES (7, 2, 8)
INSERT [dbo].[RegisterEmployerMedia] ([RegisterEmployerMedia], [RegisterEmployer_Id], [Media_Id]) VALUES (8, 2, 10)
INSERT [dbo].[RegisterEmployerMedia] ([RegisterEmployerMedia], [RegisterEmployer_Id], [Media_Id]) VALUES (9, 2, 11)
INSERT [dbo].[RegisterEmployerMedia] ([RegisterEmployerMedia], [RegisterEmployer_Id], [Media_Id]) VALUES (10, 3, 7)
INSERT [dbo].[RegisterEmployerMedia] ([RegisterEmployerMedia], [RegisterEmployer_Id], [Media_Id]) VALUES (11, 3, 8)
INSERT [dbo].[RegisterEmployerMedia] ([RegisterEmployerMedia], [RegisterEmployer_Id], [Media_Id]) VALUES (12, 3, 6)
SET IDENTITY_INSERT [dbo].[RegisterEmployerMedia] OFF
GO
SET IDENTITY_INSERT [dbo].[role] ON 

INSERT [dbo].[role] ([Role_Id], [RoleName]) VALUES (1, N'Job seeker')
INSERT [dbo].[role] ([Role_Id], [RoleName]) VALUES (2, N'Employer')
INSERT [dbo].[role] ([Role_Id], [RoleName]) VALUES (3, N'Staff')
INSERT [dbo].[role] ([Role_Id], [RoleName]) VALUES (4, N'Admin')
SET IDENTITY_INSERT [dbo].[role] OFF
GO
SET IDENTITY_INSERT [dbo].[salary_types] ON 

INSERT [dbo].[salary_types] ([salary_types_id], [type_name]) VALUES (1, N'Theo giờ')
INSERT [dbo].[salary_types] ([salary_types_id], [type_name]) VALUES (2, N'Theo ngày')
INSERT [dbo].[salary_types] ([salary_types_id], [type_name]) VALUES (3, N'Theo công việc')
INSERT [dbo].[salary_types] ([salary_types_id], [type_name]) VALUES (4, N'Theo tuần')
INSERT [dbo].[salary_types] ([salary_types_id], [type_name]) VALUES (5, N'Theo tháng')
INSERT [dbo].[salary_types] ([salary_types_id], [type_name]) VALUES (6, N'Lương cố định')
SET IDENTITY_INSERT [dbo].[salary_types] OFF
GO
SET IDENTITY_INSERT [dbo].[Service] ON 

INSERT [dbo].[Service] ([Service_id], [User_Id], [NumberPosts], [NumberPostsUrgentRecruitment], [IsFindJobseekers], [Expiration_Date]) VALUES (1, 18, 29, 17, 1, CAST(N'2025-06-13T02:38:40.493' AS DateTime))
INSERT [dbo].[Service] ([Service_id], [User_Id], [NumberPosts], [NumberPostsUrgentRecruitment], [IsFindJobseekers], [Expiration_Date]) VALUES (2, 20, 5, 10, 1, CAST(N'2025-12-13T08:01:09.543' AS DateTime))
SET IDENTITY_INSERT [dbo].[Service] OFF
GO
SET IDENTITY_INSERT [dbo].[Service_price_list] ON 

INSERT [dbo].[Service_price_list] ([Service_price_id], [NumberPosts], [NumberPostsUrgentRecruitment], [IsFindJobseekers], [durationsMonth], [Price], [Service_price_Name], [Status]) VALUES (1, 10, 5, 0, 0, 100000.0000, N'Gói Cơ Bản', 1)
INSERT [dbo].[Service_price_list] ([Service_price_id], [NumberPosts], [NumberPostsUrgentRecruitment], [IsFindJobseekers], [durationsMonth], [Price], [Service_price_Name], [Status]) VALUES (2, 20, 10, 0, 0, 190000.0000, N'Gói Tiết Kiệm', 1)
INSERT [dbo].[Service_price_list] ([Service_price_id], [NumberPosts], [NumberPostsUrgentRecruitment], [IsFindJobseekers], [durationsMonth], [Price], [Service_price_Name], [Status]) VALUES (3, 30, 15, 1, 6, 300000.0000, N'Gói Phổ Thông', 1)
SET IDENTITY_INSERT [dbo].[Service_price_list] OFF
GO
SET IDENTITY_INSERT [dbo].[Service_price_Log] ON 

INSERT [dbo].[Service_price_Log] ([Service_price_Log_Id], [User_Id], [Service_price_id], [Register_Date]) VALUES (1, 18, 1, CAST(N'2024-12-13T02:38:40.473' AS DateTime))
INSERT [dbo].[Service_price_Log] ([Service_price_Log_Id], [User_Id], [Service_price_id], [Register_Date]) VALUES (2, 20, 2, CAST(N'2024-12-13T08:01:09.523' AS DateTime))
INSERT [dbo].[Service_price_Log] ([Service_price_Log_Id], [User_Id], [Service_price_id], [Register_Date]) VALUES (3, 18, 3, CAST(N'2024-12-14T22:36:58.947' AS DateTime))
SET IDENTITY_INSERT [dbo].[Service_price_Log] OFF
GO
SET IDENTITY_INSERT [dbo].[Slot] ON 

INSERT [dbo].[Slot] ([Slot_Id], [Post_Id]) VALUES (2, 1)
INSERT [dbo].[Slot] ([Slot_Id], [Post_Id]) VALUES (3, 2)
INSERT [dbo].[Slot] ([Slot_Id], [Post_Id]) VALUES (4, 3)
SET IDENTITY_INSERT [dbo].[Slot] OFF
GO
SET IDENTITY_INSERT [dbo].[User] ON 

INSERT [dbo].[User] ([User_Id], [Email], [Avatar], [FullName], [Password], [Age], [Phonenumber], [CurrentJob], [Description], [Address], [Balance], [Status], [Gender], [SendCodeTime], [VerifyCode], [Role_Id]) VALUES (16, N'thanhdvhe160422@fpt.edu.vn', 1, N'Đồng Văn Thanh', N'thanhham', 22, N'0366568943', NULL, NULL, NULL, NULL, 1, 1, NULL, NULL, 4)
INSERT [dbo].[User] ([User_Id], [Email], [Avatar], [FullName], [Password], [Age], [Phonenumber], [CurrentJob], [Description], [Address], [Balance], [Status], [Gender], [SendCodeTime], [VerifyCode], [Role_Id]) VALUES (17, N'nguyenthanhsang17102002@gmail.com', 1, N'Nguyễn Thanh Sang', N'17102002', NULL, N'0369354782', NULL, NULL, N'số 98 nguyễn văn linh, thị xã mỹ hào, tỉnh hưng yên', NULL, 1, 1, NULL, NULL, 3)
INSERT [dbo].[User] ([User_Id], [Email], [Avatar], [FullName], [Password], [Age], [Phonenumber], [CurrentJob], [Description], [Address], [Balance], [Status], [Gender], [SendCodeTime], [VerifyCode], [Role_Id]) VALUES (18, N'sangnthe160447@fpt.edu.vn', 5, N'Nguyen Thanh Sang', N'123123', 34, N'0369354782', 2, N'tôi là sinh viên năm 4 của đại học fpt cơ sở hòa lạc và tôi đang làm đồ án ', N'Hạ bằng, thạch hòa, thạch thất, hà nội', NULL, 1, 1, NULL, NULL, 2)
INSERT [dbo].[User] ([User_Id], [Email], [Avatar], [FullName], [Password], [Age], [Phonenumber], [CurrentJob], [Description], [Address], [Balance], [Status], [Gender], [SendCodeTime], [VerifyCode], [Role_Id]) VALUES (19, N'tuandahe163847@fpt.edu.vn', 14, N'Đặng Anh ', N'123123', 21, N'0354890782', 2, N'Tôi tên là Tuấn, sinh viên năm 3', N'Quận 1, Thành phố Hồ Chí Minh ', NULL, 1, 1, NULL, NULL, 1)
INSERT [dbo].[User] ([User_Id], [Email], [Avatar], [FullName], [Password], [Age], [Phonenumber], [CurrentJob], [Description], [Address], [Balance], [Status], [Gender], [SendCodeTime], [VerifyCode], [Role_Id]) VALUES (20, N'dangtuan4122@gmail.com', 18, N'Tuấn Đặng', N'123123', 23, N'0354890782', 3, N'tôi tên là tuấn ', N'Quận 4 , thành phố hồ chí minh ', NULL, 1, 1, NULL, NULL, 2)
INSERT [dbo].[User] ([User_Id], [Email], [Avatar], [FullName], [Password], [Age], [Phonenumber], [CurrentJob], [Description], [Address], [Balance], [Status], [Gender], [SendCodeTime], [VerifyCode], [Role_Id]) VALUES (21, N'hungvdhe161733@fpt.edu.vn', 19, N'Vu Duy Hung', N'Hung1234@', 22, N'0858126236', 2, N'tôi là sinh viên năm cuối đại học fpt', N'Đống đa, Hà nội', NULL, 1, 1, NULL, NULL, 1)
INSERT [dbo].[User] ([User_Id], [Email], [Avatar], [FullName], [Password], [Age], [Phonenumber], [CurrentJob], [Description], [Address], [Balance], [Status], [Gender], [SendCodeTime], [VerifyCode], [Role_Id]) VALUES (22, N'thangchaban.sn@gmail.com', 4, N'TCB', N'Hung1234@', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, 1)
SET IDENTITY_INSERT [dbo].[User] OFF
GO
SET IDENTITY_INSERT [dbo].[WishJob] ON 

INSERT [dbo].[WishJob] ([WishJob_Id], [PostJob_Id], [JobSeeker_Id]) VALUES (2, 3, 19)
INSERT [dbo].[WishJob] ([WishJob_Id], [PostJob_Id], [JobSeeker_Id]) VALUES (4, 2, 19)
SET IDENTITY_INSERT [dbo].[WishJob] OFF
GO
SET IDENTITY_INSERT [dbo].[WorkingHour] ON 

INSERT [dbo].[WorkingHour] ([WorkingHour_Id], [Schedule_Id], [StartTime], [EndTime]) VALUES (4, 4, CAST(N'09:00:00' AS Time), CAST(N'11:00:00' AS Time))
INSERT [dbo].[WorkingHour] ([WorkingHour_Id], [Schedule_Id], [StartTime], [EndTime]) VALUES (5, 5, CAST(N'09:00:00' AS Time), CAST(N'11:00:00' AS Time))
INSERT [dbo].[WorkingHour] ([WorkingHour_Id], [Schedule_Id], [StartTime], [EndTime]) VALUES (6, 6, CAST(N'09:00:00' AS Time), CAST(N'11:00:00' AS Time))
INSERT [dbo].[WorkingHour] ([WorkingHour_Id], [Schedule_Id], [StartTime], [EndTime]) VALUES (7, 7, CAST(N'09:00:00' AS Time), CAST(N'23:00:00' AS Time))
INSERT [dbo].[WorkingHour] ([WorkingHour_Id], [Schedule_Id], [StartTime], [EndTime]) VALUES (8, 8, CAST(N'09:00:00' AS Time), CAST(N'11:00:00' AS Time))
INSERT [dbo].[WorkingHour] ([WorkingHour_Id], [Schedule_Id], [StartTime], [EndTime]) VALUES (9, 9, CAST(N'09:00:00' AS Time), CAST(N'11:00:00' AS Time))
INSERT [dbo].[WorkingHour] ([WorkingHour_Id], [Schedule_Id], [StartTime], [EndTime]) VALUES (10, 10, CAST(N'09:00:00' AS Time), CAST(N'11:00:00' AS Time))
INSERT [dbo].[WorkingHour] ([WorkingHour_Id], [Schedule_Id], [StartTime], [EndTime]) VALUES (11, 11, CAST(N'09:00:00' AS Time), CAST(N'23:00:00' AS Time))
INSERT [dbo].[WorkingHour] ([WorkingHour_Id], [Schedule_Id], [StartTime], [EndTime]) VALUES (12, 12, CAST(N'09:00:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[WorkingHour] ([WorkingHour_Id], [Schedule_Id], [StartTime], [EndTime]) VALUES (13, 13, CAST(N'09:00:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[WorkingHour] ([WorkingHour_Id], [Schedule_Id], [StartTime], [EndTime]) VALUES (14, 14, CAST(N'09:00:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[WorkingHour] ([WorkingHour_Id], [Schedule_Id], [StartTime], [EndTime]) VALUES (15, 15, CAST(N'09:00:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[WorkingHour] ([WorkingHour_Id], [Schedule_Id], [StartTime], [EndTime]) VALUES (16, 16, CAST(N'09:00:00' AS Time), CAST(N'17:00:00' AS Time))
SET IDENTITY_INSERT [dbo].[WorkingHour] OFF
GO
/****** Object:  Index [UQ__Service__206D917154653D90]    Script Date: 12/15/2024 2:38:43 PM ******/
ALTER TABLE [dbo].[Service] ADD UNIQUE NONCLUSTERED 
(
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ApplyJob]  WITH CHECK ADD FOREIGN KEY([cv_ID])
REFERENCES [dbo].[Cv] ([CvId])
GO
ALTER TABLE [dbo].[ApplyJob]  WITH CHECK ADD FOREIGN KEY([JobSeeker_Id])
REFERENCES [dbo].[User] ([User_Id])
GO
ALTER TABLE [dbo].[ApplyJob]  WITH CHECK ADD FOREIGN KEY([Post_Id])
REFERENCES [dbo].[PostJob] ([Post_Id])
GO
ALTER TABLE [dbo].[BanUserLog]  WITH CHECK ADD FOREIGN KEY([AdminID])
REFERENCES [dbo].[User] ([User_Id])
GO
ALTER TABLE [dbo].[BanUserLog]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([User_Id])
GO
ALTER TABLE [dbo].[Blog]  WITH CHECK ADD FOREIGN KEY([Author_Id])
REFERENCES [dbo].[User] ([User_Id])
GO
ALTER TABLE [dbo].[Blog]  WITH CHECK ADD FOREIGN KEY([thumbnail])
REFERENCES [dbo].[MediaItems] ([Id])
GO
ALTER TABLE [dbo].[Chat]  WITH CHECK ADD FOREIGN KEY([SendFrom_Id])
REFERENCES [dbo].[User] ([User_Id])
GO
ALTER TABLE [dbo].[Chat]  WITH CHECK ADD FOREIGN KEY([SendTo_Id])
REFERENCES [dbo].[User] ([User_Id])
GO
ALTER TABLE [dbo].[Cv]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([User_Id])
GO
ALTER TABLE [dbo].[Favorite_List]  WITH CHECK ADD FOREIGN KEY([EmployerId])
REFERENCES [dbo].[User] ([User_Id])
GO
ALTER TABLE [dbo].[Favorite_List]  WITH CHECK ADD FOREIGN KEY([JobSeekerId])
REFERENCES [dbo].[User] ([User_Id])
GO
ALTER TABLE [dbo].[ImagePostJob]  WITH CHECK ADD FOREIGN KEY([Image_Id])
REFERENCES [dbo].[MediaItems] ([Id])
GO
ALTER TABLE [dbo].[ImagePostJob]  WITH CHECK ADD FOREIGN KEY([Post_Id])
REFERENCES [dbo].[PostJob] ([Post_Id])
GO
ALTER TABLE [dbo].[ItemOfCv]  WITH CHECK ADD FOREIGN KEY([CvId])
REFERENCES [dbo].[Cv] ([CvId])
GO
ALTER TABLE [dbo].[JobPostDates]  WITH CHECK ADD FOREIGN KEY([Post_Id])
REFERENCES [dbo].[PostJob] ([Post_Id])
GO
ALTER TABLE [dbo].[JobSchedule]  WITH CHECK ADD FOREIGN KEY([SlotId])
REFERENCES [dbo].[Slot] ([Slot_Id])
GO
ALTER TABLE [dbo].[log]  WITH CHECK ADD FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([User_Id])
GO
ALTER TABLE [dbo].[Notification]  WITH CHECK ADD FOREIGN KEY([User_ID])
REFERENCES [dbo].[User] ([User_Id])
GO
ALTER TABLE [dbo].[PostJob]  WITH CHECK ADD FOREIGN KEY([AuthorId])
REFERENCES [dbo].[User] ([User_Id])
GO
ALTER TABLE [dbo].[PostJob]  WITH CHECK ADD FOREIGN KEY([censor_Id])
REFERENCES [dbo].[User] ([User_Id])
GO
ALTER TABLE [dbo].[PostJob]  WITH CHECK ADD FOREIGN KEY([JobCategory_Id])
REFERENCES [dbo].[JobCategory] ([JobCategory_Id])
GO
ALTER TABLE [dbo].[PostJob]  WITH CHECK ADD FOREIGN KEY([salary_types_id])
REFERENCES [dbo].[salary_types] ([salary_types_id])
GO
ALTER TABLE [dbo].[RegisterEmployer]  WITH CHECK ADD FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([User_Id])
GO
ALTER TABLE [dbo].[RegisterEmployerMedia]  WITH CHECK ADD FOREIGN KEY([Media_Id])
REFERENCES [dbo].[MediaItems] ([Id])
GO
ALTER TABLE [dbo].[RegisterEmployerMedia]  WITH CHECK ADD FOREIGN KEY([RegisterEmployer_Id])
REFERENCES [dbo].[RegisterEmployer] ([RegisterEmployer_Id])
GO
ALTER TABLE [dbo].[Report]  WITH CHECK ADD FOREIGN KEY([JobSeeker_Id])
REFERENCES [dbo].[User] ([User_Id])
GO
ALTER TABLE [dbo].[Report]  WITH CHECK ADD FOREIGN KEY([Post_Id])
REFERENCES [dbo].[PostJob] ([Post_Id])
GO
ALTER TABLE [dbo].[ReportMedia]  WITH CHECK ADD FOREIGN KEY([Image_Id])
REFERENCES [dbo].[MediaItems] ([Id])
GO
ALTER TABLE [dbo].[ReportMedia]  WITH CHECK ADD FOREIGN KEY([Report_Id])
REFERENCES [dbo].[Report] ([Report_Id])
GO
ALTER TABLE [dbo].[Service]  WITH CHECK ADD FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([User_Id])
GO
ALTER TABLE [dbo].[Service_price_Log]  WITH CHECK ADD FOREIGN KEY([Service_price_id])
REFERENCES [dbo].[Service_price_list] ([Service_price_id])
GO
ALTER TABLE [dbo].[Service_price_Log]  WITH CHECK ADD FOREIGN KEY([User_Id])
REFERENCES [dbo].[User] ([User_Id])
GO
ALTER TABLE [dbo].[Slot]  WITH CHECK ADD FOREIGN KEY([Post_Id])
REFERENCES [dbo].[PostJob] ([Post_Id])
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD FOREIGN KEY([Avatar])
REFERENCES [dbo].[MediaItems] ([Id])
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD FOREIGN KEY([CurrentJob])
REFERENCES [dbo].[CurrentJob] ([Current_Job_Id])
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD FOREIGN KEY([Role_Id])
REFERENCES [dbo].[role] ([Role_Id])
GO
ALTER TABLE [dbo].[WishJob]  WITH CHECK ADD FOREIGN KEY([JobSeeker_Id])
REFERENCES [dbo].[User] ([User_Id])
GO
ALTER TABLE [dbo].[WishJob]  WITH CHECK ADD FOREIGN KEY([PostJob_Id])
REFERENCES [dbo].[PostJob] ([Post_Id])
GO
ALTER TABLE [dbo].[WorkingHour]  WITH CHECK ADD FOREIGN KEY([Schedule_Id])
REFERENCES [dbo].[JobSchedule] ([Schedule_Id])
GO
