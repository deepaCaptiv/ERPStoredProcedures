USE [Vertiv]
GO

/****** Object:  StoredProcedure [dbo].[UpsertPaymentInvoiceMapping_FromJson]    Script Date: 05-05-2026 11:07:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



 ALTER    PROCEDURE [dbo].[UpsertPaymentInvoiceMapping_FromJson]
    @JsonData NVARCHAR(MAX)
AS
BEGIN
    -- Declare a table variable to hold parsed JSON data
    DECLARE @PaymentInvoices TABLE (
        payment_invoice_id VARCHAR(36),
        payment_id VARCHAR(36),
        invoice_id BIGINT,
        invoice_number VARCHAR(50),
        invoice_payment_id BIGINT,
        amount_paid DECIMAL(18, 2),
        discount_taken DECIMAL(18, 2),
        withholding_tax_amount DECIMAL(18, 2),
        accounting_date DATETIME,
        currency_code VARCHAR(15),
        exchange_rate DECIMAL(18, 6),
        base_amount DECIMAL(18, 2),
        created_at DATETIME,
        updated_at DATETIME,
        payment_number VARCHAR(50)
    );

    -- Parse JSON data into the table variable
    INSERT INTO @PaymentInvoices (
        payment_invoice_id,
        payment_id,
        invoice_id,
        invoice_number,
        invoice_payment_id,
        amount_paid,
        discount_taken,
        withholding_tax_amount,
        accounting_date,
        currency_code,
        exchange_rate,
        base_amount,
        created_at,
        updated_at,
        payment_number
    )
    SELECT 
        payment_invoice_id,
        payment_id,
        invoice_id,
        invoice_number,
        invoice_payment_id,
        amount_paid,
        discount_taken,
        withholding_tax_amount,
        accounting_date,
        currency_code,
        exchange_rate,
        base_amount,
        created_at,
        updated_at,
        payment_number
    FROM OPENJSON(@JsonData)
    WITH (
        payment_invoice_id VARCHAR(36) '$.payment_invoice_id',
        payment_id VARCHAR(36) '$.payment_id',
        invoice_id BIGINT '$.invoice_id',
        invoice_number VARCHAR(50) '$.invoice_number',
        invoice_payment_id BIGINT '$.invoice_payment_id',
        amount_paid DECIMAL(18, 2) '$.amount_paid',
        discount_taken DECIMAL(18, 2) '$.discount_taken',
        withholding_tax_amount DECIMAL(18, 2) '$.withholding_tax_amount',
        accounting_date DATETIME '$.accounting_date',
        currency_code VARCHAR(15) '$.currency_code',
        exchange_rate DECIMAL(18, 6) '$.exchange_rate',
        base_amount DECIMAL(18, 2) '$.base_amount',
        created_at DATETIME '$.created_at',
        updated_at DATETIME '$.updated_at',
        payment_number VARCHAR(50) '$.payment_number'
    );

    -- Declare a variable to hold the retrieved payment_id from PaymentReceipt
    DECLARE @RetrievedPaymentId VARCHAR(36);

    -- Get the payment_id from PaymentReceipt based on the payment_number
    SELECT @RetrievedPaymentId = payment_id
    FROM PaymentReceipt
    WHERE payment_number = (SELECT payment_number FROM @PaymentInvoices);

    -- Check if the payment_number exists in the PaymentInvoiceMapping table
    IF EXISTS (SELECT 1 FROM PaymentInvoiceMapping   with(nolock) WHERE payment_number = (SELECT payment_number FROM @PaymentInvoices))
    BEGIN 	PRINT 'Update conditon'
       
        -- If it exists, update the record
        UPDATE pi
        SET
	     pi.payment_invoice_id = piu.payment_invoice_id,
            pi.payment_id = COALESCE( @RetrievedPaymentId,''),
            pi.invoice_id = piu.invoice_id,
            pi.invoice_number = piu.invoice_number,
            pi.invoice_payment_id = piu.invoice_payment_id,
            pi.amount_paid = piu.amount_paid,
            pi.discount_taken = piu.discount_taken,
            pi.withholding_tax_amount = piu.withholding_tax_amount,
            pi.accounting_date = piu.accounting_date,
            pi.currency_code = piu.currency_code,
            pi.exchange_rate = piu.exchange_rate,
            pi.base_amount = piu.base_amount,
            pi.updated_at = piu.updated_at
        FROM PaymentInvoiceMapping pi
        INNER JOIN @PaymentInvoices piu ON pi.payment_number = piu.payment_number;
    END
    ELSE
    BEGIN
	PRINT 'Insert conditon '
        -- If it does not exist, insert a new record
        INSERT INTO PaymentInvoiceMapping (
            payment_invoice_id,
            payment_id,
            invoice_id,
            invoice_number,
            invoice_payment_id,
            amount_paid,
            discount_taken,
            withholding_tax_amount,
            accounting_date,
            currency_code,
            exchange_rate,
            base_amount,
            created_at,
            payment_number
        )
        SELECT
            payment_invoice_id,
            COALESCE(@RetrievedPaymentId,''),  
            invoice_id,
            invoice_number,
            invoice_payment_id,
            amount_paid,
            discount_taken,
            withholding_tax_amount,
            accounting_date,
            currency_code,
            exchange_rate,
            base_amount,
            created_at,
            payment_number
        FROM @PaymentInvoices;
    END
END;
GO


