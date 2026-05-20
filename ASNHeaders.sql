CREATE PROCEDURE [dbo].[saveasnheaderjson_new]  
    @jsondata NVARCHAR(MAX)  
AS  
BEGIN  
    SET NOCOUNT ON;  
  
    BEGIN TRY  
  
        IF @jsondata IS NULL OR ISJSON(@jsondata) = 0  
        BEGIN  
            RAISERROR('Invalid or Null JSON Passed',16,1);  
            RETURN;  
        END;  
  
        INSERT INTO pojsonfromerp  
        VALUES ('asn before insert', @jsondata, GETDATE());  
  
        DECLARE @tempasnheader TABLE  
        (  
            ASNId VARCHAR(36),  
            ASNNubmer VARCHAR(50),  
            Invoice_no VARCHAR(50),  
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
            DockerNo VARCHAR(100),  
  
            -- NEW FIELDS ADDED  
            PoNumber VARCHAR(50),  
            VendorName VARCHAR(200),  
            ShipToLocation VARCHAR(200),  
            NumOfContainers INT,  
            FreightCarrier VARCHAR(100),  
            PackingSlip VARCHAR(100),  
            WaybillNumber VARCHAR(100)  
        );  
  
        INSERT INTO @tempasnheader  
        SELECT *  
        FROM OPENJSON(@jsondata)  
        WITH  
        (  
            ASNId VARCHAR(36) '$.asn_id',  
            ASNNubmer VARCHAR(50) '$.asn_number',  
            Invoice_no VARCHAR(50) '$.invoice_no',  
  
            ShippingDate DATETIME '$.ship_date',  
            ExpectedRecieptDate DATETIME '$.expected_receipt_date',  
            ModeOfTransport INT '$.mode_of_transport',  
            Remarks NVARCHAR(4000) '$.remarks',  
  
            VehicleNo VARCHAR(50) '$.vehicle_no',  
            DriverName VARCHAR(100) '$.driver_name',  
            DriverLicenseNo VARCHAR(100) '$.driver_license_no',  
            DriverPhone VARCHAR(100) '$.driver_phone',  
  
            LRNo VARCHAR(100) '$.lr_no',  
            LRDate DATETIME '$.lr_date',  
  
            TransportCompanyName VARCHAR(100) '$.transport_company_name',  
            TransmitTime TIME(7) '$.transmit_time',  
  
            RRNo VARCHAR(100) '$.rr_no',  
            RRDate DATE '$.rr_date',  
  
            AirwayBillNo VARCHAR(100) '$.airway_bill_no',  
            FlightNo VARCHAR(100) '$.flight_no',  
            FlightDate DATE '$.flight_date',  
            AirlineNo VARCHAR(100) '$.airline_no',  
  
            BillofLadingNo VARCHAR(100) '$.bill_of_lading_no',  
            BOLDate DATE '$.bol_date',  
  
            VesselName VARCHAR(100) '$.vessel_name',  
            voyageNo VARCHAR(100) '$.voyage_no',  
  
            CourierNo VARCHAR(100) '$.courier_no',  
            TrackingNo VARCHAR(100) '$.tracking_no',  
            DockerNo VARCHAR(100) '$.docker_no',  
  
            -- NEW JSON MAPPING  
            PoNumber VARCHAR(50) '$.po_number',  
            VendorName VARCHAR(200) '$.vendor_name',  
            ShipToLocation VARCHAR(200) '$.ship_to_location',  
            NumOfContainers INT '$.num_of_containers',  
            FreightCarrier VARCHAR(100) '$.freight_carrier',  
            PackingSlip VARCHAR(100) '$.packing_slip',  
            WaybillNumber VARCHAR(100) '$.waybill_number'  
        );  
  
           
  
        UPDATE tar  
        SET  
            tar.ASNNubmer = src.ASNNubmer,  
            tar.Invoice_no = src.Invoice_no,  
            tar.ShippingDate = src.ShippingDate,  
            tar.ExpectedRecieptDate = src.ExpectedRecieptDate,  
            tar.ModeOfTransport = src.ModeOfTransport,  
            tar.Remarks = src.Remarks,  
  
            tar.VehicleNo = src.VehicleNo,  
            tar.DriverName = src.DriverName,  
            tar.DriverLicenseNo = src.DriverLicenseNo,  
            tar.DriverPhone = src.DriverPhone,  
  
            tar.LRNo = src.LRNo,  
            tar.LRDate = src.LRDate,  
  
            tar.TransportCompanyName = src.TransportCompanyName,  
            tar.TransmitTime = src.TransmitTime,  
  
            tar.RRNo = src.RRNo,  
            tar.RRDate = src.RRDate,  
  
            tar.AirwayBillNo = src.AirwayBillNo,  
            tar.FlightNo = src.FlightNo,  
            tar.FlightDate = src.FlightDate,  
            tar.AirlineNo = src.AirlineNo,  
  
            tar.BillofLadingNo = src.BillofLadingNo,  
            tar.BOLDate = src.BOLDate,  
  
            tar.VesselName = src.VesselName,  
            tar.voyageNo = src.voyageNo,  
  
            tar.CourierNo = src.CourierNo,  
            tar.TrackingNo = src.TrackingNo,  
            tar.DockerNo = src.DockerNo,  
  
            -- NEW UPDATE FIELDS  
            tar.PoNumber = src.PoNumber,  
            tar.VendorName = src.VendorName,  
            tar.ShipToLocation = src.ShipToLocation,  
            tar.NumOfContainers = src.NumOfContainers,  
            tar.FreightCarrier = src.FreightCarrier,  
            tar.PackingSlip = src.PackingSlip,  
            tar.WaybillNumber = src.WaybillNumber  
  
        FROM vertiv..invoiceasndetails tar  
        INNER JOIN @tempasnheader src  
            ON tar.ASNId = src.ASNId;  
  
          
        -- INSERT NEW RECORDS  
          
  
        INSERT INTO vertiv..invoiceasndetails  
        (  
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
            DockerNo,  
  
            -- NEW INSERT FIELDS  
            ponumber,  
            VendorName,  
            ShipToLocation,  
            NumOfContainers,  
            FreightCarrier,  
            PackingSlip,  
            WaybillNumber  
        )  
        SELECT  
            t.ASNId,  
            t.ASNNubmer,  
            t.Invoice_no,  
            t.ShippingDate,  
            t.ExpectedRecieptDate,  
            t.ModeOfTransport,  
            t.Remarks,  
            t.VehicleNo,  
            t.DriverName,  
            t.DriverLicenseNo,  
            t.DriverPhone,  
            t.LRNo,  
            t.LRDate,  
            t.TransportCompanyName,  
            t.TransmitTime,  
            t.RRNo,  
            t.RRDate,  
            t.AirwayBillNo,  
            t.FlightNo,  
            t.FlightDate,  
            t.AirlineNo,  
            t.BillofLadingNo,  
            t.BOLDate,  
            t.VesselName,  
            t.voyageNo,  
            t.CourierNo,  
            t.TrackingNo,  
            t.DockerNo,  
            t.PoNumber,  
            t.VendorName,  
            t.ShipToLocation,  
            t.NumOfContainers,  
            t.FreightCarrier,  
            t.PackingSlip,  
            t.WaybillNumber  
  
        FROM @tempasnheader t  
        LEFT JOIN vertiv..invoiceasndetails p  
            ON t.ASNId = p.ASNId  
        WHERE p.ASNId IS NULL;  
  
          
        -- RETURN RESULT  
          
  
        SELECT ASNNubmer as asn_number  
        FROM @tempasnheader;  
  
        INSERT INTO pojsonfromerp (ponumber, jsondata, createdat)  
        SELECT ASNNubmer, @jsondata, GETDATE()  
        FROM @tempasnheader;  
  
    END TRY  
  
    BEGIN CATCH  
        SELECT  
            'error' AS status,  
            ERROR_MESSAGE() AS errormessage,  
            ERROR_LINE() AS errorline;  
    END CATCH  
END;  