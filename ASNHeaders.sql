USE [Vertiv]
GO

/****** Object:  StoredProcedure [dbo].[SaveASNHeaderJson]    Script Date: 05-05-2026 11:06:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER        PROCEDURE [dbo].[SaveASNHeaderJson]
    @JsonData NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF @JsonData IS NULL OR ISJSON(@JsonData) = 0
        BEGIN
            RAISERROR('Invalid or NULL JSON passed', 16, 1);
            RETURN;
        END

        DECLARE @Result TABLE (
            ASNNubmer VARCHAR(50)
           
        );

        MERGE dbo.InvoiceASNDetails AS TARGET
        USING (
            SELECT
                ASNNubmer,
                Invoice_no,
                ShippingDate,
                ExpectedRecieptDate,
                ModeOfTransport,
                Remarks,
                VehicleNo,
                DriverName,
                DriverLicenseNo,
                DriverPhone,
                LRNo,
                LRDate,
                TransportCompanyName,
                TransmitTime,
                RRNo,
                RRDate,
                AirwayBillNo,
                FlightNo,
                FlightDate,
                AirlineNo,
                BillofLadingNo,
                BOLDate,
                VesselName,
                voyageNo,
                CourierNo,
                TrackingNo,
                DockerNo
            FROM OPENJSON(@JsonData)
            WITH (
                ASNNubmer VARCHAR(50),
                Invoice_no VARCHAR(36),
                ShippingDate DATETIME,
                ExpectedRecieptDate DATETIME,
                ModeOfTransport INT,
                Remarks NVARCHAR(4000),
                VehicleNo VARCHAR(50),
                DriverName VARCHAR(100),
                DriverLicenseNo VARCHAR(100),
                DriverPhone VARCHAR(100),
                LRNo VARCHAR(100),
                LRDate DATETIME,
                TransportCompanyName VARCHAR(100),
                TransmitTime TIME(7),
                RRNo VARCHAR(100),
                RRDate DATE,
                AirwayBillNo VARCHAR(100),
                FlightNo VARCHAR(100),
                FlightDate DATE,
                AirlineNo VARCHAR(100),
                BillofLadingNo VARCHAR(100),
                BOLDate DATE,
                VesselName VARCHAR(100),
                voyageNo VARCHAR(100),
                CourierNo VARCHAR(100),
                TrackingNo VARCHAR(100),
                DockerNo VARCHAR(100)
            )
        ) AS SOURCE
        ON TARGET.ASNNubmer = SOURCE.ASNNubmer

        WHEN MATCHED THEN
            UPDATE SET
                Invoice_no            = SOURCE.Invoice_no,
                ShippingDate          = SOURCE.ShippingDate,
                ExpectedRecieptDate   = SOURCE.ExpectedRecieptDate,
                ModeOfTransport       = SOURCE.ModeOfTransport,
                Remarks               = SOURCE.Remarks,
                VehicleNo             = SOURCE.VehicleNo,
                DriverName            = SOURCE.DriverName,
                DriverLicenseNo       = SOURCE.DriverLicenseNo,
                DriverPhone           = SOURCE.DriverPhone,
                LRNo                  = SOURCE.LRNo,
                LRDate                = SOURCE.LRDate,
                TransportCompanyName  = SOURCE.TransportCompanyName,
                TransmitTime          = SOURCE.TransmitTime,
                RRNo                  = SOURCE.RRNo,
                RRDate                = SOURCE.RRDate,
                AirwayBillNo          = SOURCE.AirwayBillNo,
                FlightNo              = SOURCE.FlightNo,
                FlightDate            = SOURCE.FlightDate,
                AirlineNo             = SOURCE.AirlineNo,
                BillofLadingNo        = SOURCE.BillofLadingNo,
                BOLDate               = SOURCE.BOLDate,
                VesselName            = SOURCE.VesselName,
                voyageNo              = SOURCE.voyageNo,
                CourierNo             = SOURCE.CourierNo,
                TrackingNo            = SOURCE.TrackingNo,
                DockerNo              = SOURCE.DockerNo

        WHEN NOT MATCHED THEN
            INSERT (
                ASNId,
                ASNNubmer,
                Invoice_no,
                ShippingDate,
                ExpectedRecieptDate,
                ModeOfTransport,
                Remarks,
                VehicleNo,
                DriverName,
                DriverLicenseNo,
                DriverPhone,
                LRNo,
                LRDate,
                TransportCompanyName,
                TransmitTime,
                RRNo,
                RRDate,
                AirwayBillNo,
                FlightNo,
                FlightDate,
                AirlineNo,
                BillofLadingNo,
                BOLDate,
                VesselName,
                voyageNo,
                CourierNo,
                TrackingNo,
                DockerNo
            )
            VALUES (
                NEWID(),
                SOURCE.ASNNubmer,
                SOURCE.Invoice_no,
                SOURCE.ShippingDate,
                SOURCE.ExpectedRecieptDate,
                SOURCE.ModeOfTransport,
                SOURCE.Remarks,
                SOURCE.VehicleNo,
                SOURCE.DriverName,
                SOURCE.DriverLicenseNo,
                SOURCE.DriverPhone,
                SOURCE.LRNo,
                SOURCE.LRDate,
                SOURCE.TransportCompanyName,
                SOURCE.TransmitTime,
                SOURCE.RRNo,
                SOURCE.RRDate,
                SOURCE.AirwayBillNo,
                SOURCE.FlightNo,
                SOURCE.FlightDate,
                SOURCE.AirlineNo,
                SOURCE.BillofLadingNo,
                SOURCE.BOLDate,
                SOURCE.VesselName,
                SOURCE.voyageNo,
                SOURCE.CourierNo,
                SOURCE.TrackingNo,
                SOURCE.DockerNo
            )

        OUTPUT
            INSERTED.ASNNubmer AS ASN_NUMBER
         
        INTO @Result;
		declare @ponumber varchar(50)
		select @ponumber=ASNNubmer
		from	@Result

		insert into POJsonfromERP
		values(@ponumber,@JsonData,getdate())

		SELECT ASNNubmer AS ASN_NUMBER
FROM @Result;

    END TRY
    BEGIN CATCH
        SELECT
            'ERROR' AS Status,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;
    END CATCH
END;
GO


