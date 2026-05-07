USE [Vertiv]
GO

/****** Object:  StoredProcedure [dbo].[Insert_POERPHeader_FromJson]    Script Date: 05-05-2026 11:43:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   PROCEDURE [dbo].[Insert_POERPHeader_FromJson]
    @JsonData NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Result TABLE (
        POERPHeaderId VARCHAR(36),
        PO_NUMBER VARCHAR(50),
        POUpdatedOn DATETIME
    );

    BEGIN TRY

        -- Validate JSON
        IF @JsonData IS NULL OR ISJSON(@JsonData) = 0
        BEGIN
            RAISERROR('Invalid or NULL JSON passed', 16, 1);
            RETURN;
        END;

        ;WITH SourceData AS
        (
            SELECT *
            FROM OPENJSON(@JsonData)
            WITH (
                POERPHeaderId VARCHAR(36),
                DocId VARCHAR(50),
                PO_NUMBER VARCHAR(50),
                PO_DATE DATETIME,
                PO_Type VARCHAR(50),
                PO_SubType VARCHAR(100),
                REVISION INT,
                VENDOR_NAME VARCHAR(200),
                VENDOR_ADDRESS NVARCHAR(MAX),
                VENDOR_GSTIN VARCHAR(50),
                VENDOR_CONTACT VARCHAR(200),
                VENDOR_PHONE VARCHAR(20),
                VENDOR_EMAIL VARCHAR(200),
                BUYER_ORG VARCHAR(100),
                BUYER_ADDRESS NVARCHAR(MAX),
                BUYER_GSTIN VARCHAR(50),
                BUYER_NAME VARCHAR(200),
                SHIP_TO_LOCATION VARCHAR(150),
                SHIP_TO_ADDRESS NVARCHAR(MAX),
                BILL_TO_LOCATION VARCHAR(150),
                PAYMENT_TERMS VARCHAR(50),
                CURRENCY VARCHAR(10),
                SUBTOTAL DECIMAL(18,2),
                TOTAL_TAX DECIMAL(18,2),
                GRAND_TOTAL DECIMAL(18,2),
                INSTRUCTIONS NVARCHAR(MAX),
                POUpdatedBy BIGINT,
                POUpdatedOn DATETIME,
                DocTypeId VARCHAR(36),
                PO_STATUS VARCHAR(50)
            )
        ),
        CleanData AS
        (
            SELECT *
            FROM SourceData
        )

        MERGE dbo.POERPHeader AS Target
        USING CleanData AS Source
        ON Target.POERPHeaderId = Source.POERPHeaderId

        WHEN MATCHED THEN
            UPDATE SET
                Target.DocId = Source.DocId,
                Target.PO_NUMBER = Source.PO_NUMBER,
                Target.PO_DATE = Source.PO_DATE,
                Target.PO_Type = Source.PO_Type,
                Target.PO_SubType = Source.PO_SubType,
                Target.REVISION = Source.REVISION,
                Target.VENDOR_NAME = Source.VENDOR_NAME,
                Target.VENDOR_ADDRESS = Source.VENDOR_ADDRESS,
                Target.VENDOR_GSTIN = Source.VENDOR_GSTIN,
                Target.VENDOR_CONTACT = Source.VENDOR_CONTACT,
                Target.VENDOR_PHONE = Source.VENDOR_PHONE,
                Target.VENDOR_EMAIL = Source.VENDOR_EMAIL,
                Target.BUYER_ORG = Source.BUYER_ORG,
                Target.BUYER_ADDRESS = Source.BUYER_ADDRESS,
                Target.BUYER_GSTIN = Source.BUYER_GSTIN,
                Target.BUYER_NAME = Source.BUYER_NAME,
                Target.SHIP_TO_LOCATION = Source.SHIP_TO_LOCATION,
                Target.SHIP_TO_ADDRESS = Source.SHIP_TO_ADDRESS,
                Target.BILL_TO_LOCATION = Source.BILL_TO_LOCATION,
                Target.PAYMENT_TERMS = Source.PAYMENT_TERMS,
                Target.CURRENCY = Source.CURRENCY,
                Target.SUBTOTAL = Source.SUBTOTAL,
                Target.TOTAL_TAX = Source.TOTAL_TAX,
                Target.GRAND_TOTAL = Source.GRAND_TOTAL,
                Target.INSTRUCTIONS = Source.INSTRUCTIONS,
                Target.POUpdatedBy = Source.POUpdatedBy,
                Target.POUpdatedOn = ISNULL(Source.POUpdatedOn, GETDATE()),
                Target.DocTypeId = Source.DocTypeId,
                Target.PO_STATUS = Source.PO_STATUS

        WHEN NOT MATCHED THEN
            INSERT (
                POERPHeaderId,
                DocId,
                PO_NUMBER,
                PO_DATE,
                PO_Type,
                PO_SubType,
                REVISION,
                VENDOR_NAME,
                VENDOR_ADDRESS,
                VENDOR_GSTIN,
                VENDOR_CONTACT,
                VENDOR_PHONE,
                VENDOR_EMAIL,
                BUYER_ORG,
                BUYER_ADDRESS,
                BUYER_GSTIN,
                BUYER_NAME,
                SHIP_TO_LOCATION,
                SHIP_TO_ADDRESS,
                BILL_TO_LOCATION,
                PAYMENT_TERMS,
                CURRENCY,
                SUBTOTAL,
                TOTAL_TAX,
                GRAND_TOTAL,
                INSTRUCTIONS,
                POUpdatedBy,
                POUpdatedOn,
                DocTypeId,
                PO_STATUS
            )
            VALUES (
                Source.POERPHeaderId,
                Source.DocId,
                Source.PO_NUMBER,
                Source.PO_DATE,
                Source.PO_Type,
                Source.PO_SubType,
                Source.REVISION,
                Source.VENDOR_NAME,
                Source.VENDOR_ADDRESS,
                Source.VENDOR_GSTIN,
                Source.VENDOR_CONTACT,
                Source.VENDOR_PHONE,
                Source.VENDOR_EMAIL,
                Source.BUYER_ORG,
                Source.BUYER_ADDRESS,
                Source.BUYER_GSTIN,
                Source.BUYER_NAME,
                Source.SHIP_TO_LOCATION,
                Source.SHIP_TO_ADDRESS,
                Source.BILL_TO_LOCATION,
                Source.PAYMENT_TERMS,
                Source.CURRENCY,
                Source.SUBTOTAL,
                Source.TOTAL_TAX,
                Source.GRAND_TOTAL,
                Source.INSTRUCTIONS,
                Source.POUpdatedBy,
                ISNULL(Source.POUpdatedOn, GETDATE()),
                Source.DocTypeId,
                Source.PO_STATUS
            )

        OUTPUT
            inserted.POERPHeaderId,
            inserted.PO_NUMBER,
            inserted.POUpdatedOn
        INTO @Result;

        -- Return result
        SELECT * FROM @Result;

		declare @ponumber varchar(50)
		select @ponumber=PO_NUMBER
		from	@Result

		insert into POJsonfromERP
		values(@ponumber,@JsonData,getdate())

    END TRY
    BEGIN CATCH
        SELECT
            'ERROR' AS Status,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;
    END CATCH
END;
GO


