USE [Vertiv]
GO

/****** Object:  StoredProcedure [dbo].[UpsertPaymentReceipt_FromJson]    Script Date: 05-05-2026 11:07:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER      PROCEDURE [dbo].[UpsertPaymentReceipt_FromJson]
    @JsonData NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Result TABLE ( 
        PaymentNumber VARCHAR(50)
        
    );

    BEGIN TRY
        -- Validate the JSON input
        IF @JsonData IS NULL OR ISJSON(@JsonData) = 0
        BEGIN
            RAISERROR('Invalid or NULL JSON passed', 16, 1);
            RETURN;
        END;

        -- Parse the JSON data into the relevant columns
        ;WITH SourceData AS
        (
            SELECT *
            FROM OPENJSON(@JsonData)
            WITH (
                payment_id VARCHAR(36),
                check_id BIGINT,
                payment_number VARCHAR(50),
                payment_date DATETIME,
                payment_method VARCHAR(30),
                payment_type VARCHAR(25),
                payment_status VARCHAR(25),
                payment_amount DECIMAL(18, 2),
                payment_currency_code VARCHAR(15),
                exchange_rate DECIMAL(18, 6),
                base_currency_code VARCHAR(15),
                base_amount DECIMAL(18, 2),
                vendor_id BIGINT,
                vendor_name VARCHAR(200),
                vendor_site_code VARCHAR(50),
                bank_account_name VARCHAR(80),
                bank_account_num VARCHAR(30),
                bank_name VARCHAR(100),
                bank_branch_name VARCHAR(100),
                cleared_date DATETIME,
                void_date DATETIME,
                transaction_reference VARCHAR(100),
                payment_document_num VARCHAR(50),
                payment_process_request_name VARCHAR(100),
                legal_entity_id BIGINT,
                org_id BIGINT,
                description NVARCHAR(500),
                source_system VARCHAR(50),
                created_by VARCHAR(100),
                updated_by VARCHAR(100),
                deleted_by VARCHAR(100),
                created_at DATETIME,
                updated_at DATETIME,
                deleted_at DATETIME
            )
        ),
        CleanData AS
        (
            SELECT *
            FROM SourceData
        )

        -- Use the MERGE statement to either UPDATE or INSERT data
        MERGE dbo.PaymentReceipt AS Target
        USING CleanData AS Source
        ON Target.payment_number = Source.payment_number

        WHEN MATCHED THEN
            -- Update existing record
            UPDATE SET
			
			 Target.payment_id = Source.payment_id,
                Target.check_id = Source.check_id,
                Target.payment_date = Source.payment_date,
                Target.payment_method = Source.payment_method,
                Target.payment_type = Source.payment_type,
                Target.payment_status = Source.payment_status,
                Target.payment_amount = Source.payment_amount,
                Target.payment_currency_code = Source.payment_currency_code,
                Target.exchange_rate = Source.exchange_rate,
                Target.base_currency_code = Source.base_currency_code,
                Target.base_amount = Source.base_amount,
                Target.vendor_id = Source.vendor_id,
                Target.vendor_name = Source.vendor_name,
                Target.vendor_site_code = Source.vendor_site_code,
                Target.bank_account_name = Source.bank_account_name,
                Target.bank_account_num = Source.bank_account_num,
                Target.bank_name = Source.bank_name,
                Target.bank_branch_name = Source.bank_branch_name,
                Target.cleared_date = Source.cleared_date,
                Target.void_date = Source.void_date,
                Target.transaction_reference = Source.transaction_reference,
                Target.payment_document_num = Source.payment_document_num,
                Target.payment_process_request_name = Source.payment_process_request_name,
                Target.legal_entity_id = Source.legal_entity_id,
                Target.org_id = Source.org_id,
                Target.description = Source.description,
                Target.source_system = Source.source_system,
                Target.updated_by = Source.updated_by,
                Target.updated_at = ISNULL(Source.updated_at, GETDATE()),
                Target.deleted_by = Source.deleted_by,
                Target.deleted_at = Source.deleted_at

        WHEN NOT MATCHED THEN
            -- Insert new record
            INSERT (
                payment_id,
                check_id,
                payment_number,
                payment_date,
                payment_method,
                payment_type,
                payment_status,
                payment_amount,
                payment_currency_code,
                exchange_rate,
                base_currency_code,
                base_amount,
                vendor_id,
                vendor_name,
                vendor_site_code,
                bank_account_name,
                bank_account_num,
                bank_name,
                bank_branch_name,
                cleared_date,
                void_date,
                transaction_reference,
                payment_document_num,
                payment_process_request_name,
                legal_entity_id,
                org_id,
                description,
                source_system,
                created_by,
                updated_by,
                created_at
            )
            VALUES (
                Source.payment_id,
                Source.check_id,
                Source.payment_number,
                Source.payment_date,
                Source.payment_method,
                Source.payment_type,
                Source.payment_status,
                Source.payment_amount,
                Source.payment_currency_code,
                Source.exchange_rate,
                Source.base_currency_code,
                Source.base_amount,
                Source.vendor_id,
                Source.vendor_name,
                Source.vendor_site_code,
                Source.bank_account_name,
                Source.bank_account_num,
                Source.bank_name,
                Source.bank_branch_name,
                Source.cleared_date,
                Source.void_date,
                Source.transaction_reference,
                Source.payment_document_num,
                Source.payment_process_request_name,
                Source.legal_entity_id,
                Source.org_id,
                Source.description,
                Source.source_system,
                Source.created_by,
                Source.updated_by,
                GETDATE() -- Created at current time
            )

        OUTPUT
             
            inserted.payment_number
            
        INTO @Result;

        -- Return result
        SELECT * FROM @Result;

    END TRY
    BEGIN CATCH
        SELECT
            'ERROR' AS Status,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;
    END CATCH
END;
GO


