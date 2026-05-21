CREATE DATABASE hackathon_cuoimon_db;
USE hackathon_cuoimon_db;

CREATE TABLE customers (
	customer_id VARCHAR(10) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(13) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    join_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE insurance_Packages(
	package_id VARCHAR(10) PRIMARY KEY,
    package_name VARCHAR(100) NOT NULL  , -- CHECK (package_name IN ('%Sức khỏe%', '%Ô tô%', '%Nhân thọ%', '%Du lịch%', '%Tai nạn%'))
    max_limit DECIMAL(12,2) NOT NULL CHECK (max_limit > 0 ),
    base_premium DECIMAL(12,2) NOT NULL CHECK (base_premium > 0 )
);

CREATE TABLE Policies (
	policy_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL,
    package_id VARCHAR(10) NOT NULL,
	start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    status ENUM ('Active', 'Expired', 'Cancelled'),
    
    CONSTRAINT ck_date CHECK (end_date > start_date),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON UPDATE CASCADE,
    FOREIGN KEY (package_id) REFERENCES insurance_Packages(package_id) ON DELETE NO ACTION
);

CREATE TABLE claims (
	claim_id VARCHAR(10) PRIMARY KEY,
    policy_id VARCHAR(10) NOT NULL,
    claim_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    claim_amount DECIMAL(12,2) NOT NULL CHECK (claim_amount > 0 ),
    status ENUM ('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    
    FOREIGN KEY (policy_id) REFERENCES Policies(policy_id)
);

CREATE TABLE claim_Processing_Log (
	log_id VARCHAR(10) PRIMARY KEY,
    claim_id VARCHAR(10) NOT NULL,
    action_detail TEXT NOT NULL,
    recorded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processor VARCHAR(100) NOT NULL,
    
    FOREIGN KEY (claim_id) REFERENCES claims(claim_id)
);

INSERT INTO customers (customer_id, full_name, phone_number, email, join_date)
VALUES 
('C001', 'Nguyen Hoang Long', '0901112223', 'long.nh@gmail.com', '2024-01-15'),
('C002', 'Tran Thi Kim Anh', '0988877766', 'anh.tk@gmail.com', '2024-03-10'),
('C003', 'Le Hoang Nam',  '0903334445', 'nam.lh@gmail.com', '2025-05-20'),
('C004', 'Pham Minh Duc', '0355556667', 'duc.pm@gmail.com', '2025-08-12'),
('C005', 'Hoang Thu Thao','0779998881', 'thao.ht@gmail.com', '2026-01-01');

INSERT INTO insurance_packages(package_id, package_name,max_limit, base_premium)
VALUES 
('PKG01', 'Bảo hiểm Sức khỏe Gold', '500000000','5000000'),
('PKG02', 'Bảo hiểm Ô tô Liberty', '1000000000','15000000'),
('PKG03', 'Bảo hiểm Nhân thọ An Bình', '2000000000','25000000'),
('PKG04', 'Bảo hiểm Du lịch Quốc tế', '100000000','1000000'),
('PKG05', 'Bảo hiểm Tai nạn 24/7', '200000000','2500000');

INSERT INTO policies(policy_id, customer_id,package_id, start_date, end_date, status)
VALUES 
('POL101', 'C001', 'PKG01', '2024-01-15', '2025-01-15', 'Expired'),
('POL102', 'C002', 'PKG02', '2024-03-10', '2026-03-10', 'Active'),
('POL103', 'C003', 'PKG03', '2024-05-20', '2035-05-20', 'Active'),
('POL104', 'C004', 'PKG04', '2024-08-12', '2025-09-12', 'Expired'),
('POL105', 'C005', 'PKG01', '2024-01-01', '2027-01-01', 'Active');

INSERT INTO claims(claim_id,policy_id,claim_date,claim_amount,status )
VALUES
('CLM901','POL102','2024-06-15', '12000000', 'Approved'),
('CLM902','POL103','2025-10-20', '50000000', 'Pending'),
('CLM903','POL101','2024-11-05', '5500000', 'Approved'),
('CLM904','POL105','2026-01-15', '2000000', 'Rejected'),
('CLM905','POL102','2025-02-10', '120000000', 'Approved');

INSERT INTO claim_processing_log(log_id, claim_id, action_detail, recorded_at, processor )
VALUES
('L001','CLM901','Đã nhận hồ sơ hiện trường', '2024-06-15 09:00', 'Admin_01'),
('L002','CLM901','Chấp nhận bồi thường xe tai nạn', '2024-06-20 14:30', 'Admin_01'),
('L003','CLM902','Đang thẩm định hồ sơ bệnh án', '2025-10-21 10:00', 'Admin_02'),
('L004','CLM904','Từ chối do lỗi cố ý của khách hàng', '2026-01-16 16:00', 'Admin_03'),
('L005','CLM905','Đã thanh toán qua chuyển khoản', '2025-02-15 08:30', 'Accountant_01');


-- Phần 1.3
-- Câu 1
UPDATE insurance_packages SET base_premium = base_premium * 1.15 WHERE max_limit > 500000000;

-- Câu 2
DELETE FROM claim_processing_log WHERE recorded_at < '2025-06-20';

-- Câu 3
SELECT * FROM policies WHERE status = 'Active' AND YEAR(end_date) = 2026;

-- Câu 4
SELECT full_name, email FROM customers WHERE full_name LIKE '%Hoang%' AND YEAR(join_date) > 2025;

-- Câu 5
SELECT * FROM claims ORDER BY claim_amount DESC LIMIT 3 OFFSET 1;

-- Câu 6
SELECT c.full_name, i.package_name, p.start_date, cl.claim_amount
FROM customers c
LEFT JOIN policies p ON p.customer_id = c.customer_id
LEFT JOIN insurance_packages i ON i.package_id = p.package_id
LEFT JOIN claims cl ON p.policy_id = cl.policy_id;

-- Câu 7
SELECT cs.* , c.claim_amount
FROM claims c
JOIN policies p ON p.policy_id = c.policy_id
JOIN customers cs ON cs.customer_id = p.customer_id
WHERE c.claim_amount > 50000000 AND c.status = 'Approved';

-- Câu 8
SELECT package_name , count_reg
FROM (SELECT package_name , COUNT(policy_id) AS count_reg
FROM insurance_packages i
JOIN policies p ON p.package_id = i.package_id
GROUP BY package_name) AS table_Count
WHERE count_reg = (SELECT MAX(total)
FROM (SELECT COUNT(policy_id) AS total
FROM policies 
GROUP BY package_id) AS table_max);

-- Câu 9
CREATE INDEX idx_policy_status_date ON policies(status, start_date);

-- Câu 10
CREATE VIEW vw_customer_summary AS
SELECT c.full_name, COUNT(policy_id) AS amount_reg, SUM(base_premium) AS Total_Pay_Each_Time
FROM customers c
JOIN policies p ON p.customer_id = c.customer_id
JOIN insurance_packages i ON p.package_id = i.package_id
GROUP BY c.full_name;

SELECT * FROM vw_customer_summary;

-- Câu 11
DROP TRIGGER IF EXISTS trg_after_claim_approved;
DELIMITER //
CREATE TRIGGER trg_after_claim_approved
AFTER UPDATE ON claims
FOR EACH ROW
BEGIN
	DECLARE ck_status VARCHAR(10);
    
    SELECT status INTO ck_status
    FROM claims WHERE OLD.claim_id = NEW.claim_id;
    
    IF ck_status = 'Approved' THEN
		INSERT INTO claim_processing_log (log_id,claim_id, action_detail, processor)
		VALUES 
		('KhongDuThoiGianLamGenID',NEW.claim_id, 'Payment processed to customer', 'Accountant_01');
    END IF;
	
END //
DELIMITER ;

UPDATE claims SET status = 'Approved' WHERE claim_id = 'CLM904';


-- Câu 12
DROP TRIGGER IF EXISTS ck_delete_policy;
DELIMITER //
CREATE TRIGGER ck_delete_policy
BEFORE DELETE ON policies
FOR EACH ROW
BEGIN
	IF OLD.status = 'Active' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hợp động này còn đang hoạt động';
	END IF;
END //
DELIMITER ;

DELETE FROM policies WHERE policy_id = 'POL102';

-- Câu 13
DROP PROCEDURE IF EXISTS sp_check_claim_limit;
DELIMITER //
CREATE PROCEDURE sp_check_claim_limit(IN c_claim_id VARCHAR(10), OUT msg VARCHAR(10) )
BEGIN
	DECLARE v_max_limit DECIMAL(12,2);
    DECLARE v_claim_amount DECIMAL(12,2);
    
    SELECT max_limit INTO v_max_limit
    FROM claims c
    JOIN policies p ON p.policy_id = c.policy_id
    JOIN insurance_packages i ON i.package_id = p.package_id
    WHERE c_claim_id = claim_id;
    
    SELECT claim_amount INTO v_claim_amount
    FROM claims
    WHERE c_claim_id = claim_id;
    
    
    
    IF v_claim_amount > v_max_limit THEN
		SET msg = 'Exceeded';
	ELSEIF v_claim_amount <= v_max_limit THEN
		SET msg = 'Valid';
	END IF;
    
END //
DELIMITER ;

CALL sp_check_claim_limit('CLM901', @msg);
SELECT @msg;

-- Câu 14
DROP PROCEDURE IF EXISTS sp_cancel_policy;
DELIMITER //
CREATE PROCEDURE sp_cancel_policy(IN c_claim_id VARCHAR(10), IN c_policy_id VARCHAR(10), OUT msg VARCHAR(100) )
BEGIN
	DECLARE v_policy_id VARCHAR(10);
    DECLARE v_claim_id VARCHAR(10);
    
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK;
		SET msg = 'Failed';
	END;
    
    
    
    START TRANSACTION;
    
    SELECT policy_id INTO v_policy_id
    FROM policies WHERE policy_id = c_policy_id;
    
    SELECT claim_ID INTO v_claim_id
    FROM claims WHERE claim_id = c_claim_id ;
    
    IF v_policy_id IS NULL THEN 
		SET msg = 'Policy not found';
        ROLLBACK;
	ELSEIF v_claim_id IS NULL THEN
		SET msg = 'Invalid claim for policy';
		ROLLBACK;
	ELSE 
		UPDATE policies SET status = 'Cancelled' WHERE policy_id = v_policy_id;
        
		INSERT INTO claim_processing_log (log_id,claim_id, action_detail, processor)
		VALUES 
		('KhongDuThoiGianLamGenID',v_claim_id, 'Customer requested cancellation', 'Admin');
        
        SET msg = 'Cancelled successfully';
        
        COMMIT;
    END IF;
END //
DELIMITER ;

CALL sp_cancel_policy('CLM902', 'POL103', @msg1);
SELECT @msg1;
