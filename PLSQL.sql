CREATE TABLE STAFF_AUDIT(
  ID INT NOT NULL,
  NAME VARCHAR(100) NOT NULL,
  CONTACT VARCHAR(10),
  EMAIL VARCHAR(50),
  TYPE VARCHAR(20),
  NEW_NAME VARCHAR(100) NOT NULL,
  NEW_CONTACT VARCHAR(10),
  NEW_EMAIL VARCHAR(50),
  NEW_TYPE VARCHAR(20),
  OPERATION VARCHAR2(20) CHECK( operation IN('INSERT','UPDATE','DELETE')) NOT NULL,
  UPDATEDTIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);
DROP TABLE STAFF_AUDIT;

CREATE OR REPLACE TRIGGER STAFF_AUDIT
  AFTER INSERT OR DELETE OR UPDATE ON STAFF
  FOR EACH ROW
BEGIN
    IF INSERTING THEN 
        INSERT INTO STAFF_AUDIT  VALUES 
                                (:OLD.ID, NULL, NULL,NULL,NULL,:NEW.NAME,:NEW.CONTACT,:NEW.EMAIL,:NEW.TYPE,'INSERT',SYSDATE);
    ELSIF UPDATING THEN  
        INSERT INTO STAFF_AUDIT VALUES 
                                (:OLD.ID,:OLD.NAME,:OLD.CONTACT,:OLD.EMAIL,:OLD.TYPE,:NEW.NAME,:NEW.CONTACT,:NEW.EMAIL,:NEW.TYPE,'UPDATE',SYSDATE);
    ELSIF DELETING THEN
        INSERT INTO STAFF_AUDIT  VALUES 
                                (:OLD.ID,:OLD.NAME,:OLD.CONTACT,:OLD.EMAIL,:OLD.TYPE,NULL,NULL,NULL,NULL,'DELETE',SYSDATE);
    END IF;
END;

-- AUDIT TABLE FOR CUSTOMER
CREATE TABLE CUSTOMER_AUDIT(
   AUDIT_ID INT NOT NULL,
   OLD_NAME VARCHAR(100) NOT NULL,
   OLD_CONTACT VARCHAR(10),
   OLD_EMAIL VARCHAR(50),
   NEW_NAME VARCHAR(100) NOT NULL,
   NEW_CONTACT VARCHAR(10),
   NEW_EMAIL VARCHAR(50),
   OPERATION VARCHAR2(10) CHECK( operation IN('INSERT','UPDATE','DELETE')) NOT NULL,
   UPDATEDTIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);

CREATE OR REPLACE TRIGGER CUSTOMER_AUDIT
  AFTER INSERT OR DELETE OR UPDATE ON CUSTOMER
  FOR EACH ROW
BEGIN
     IF INSERTING THEN 
        INSERT INTO CUSTOMER_AUDIT  VALUES 
                                (:OLD.ID, NULL, NULL,NULL,:NEW.NAME,:NEW.CONTACT,:NEW.EMAIL,'INSERT',SYSDATE);
    ELSIF UPDATING THEN  
        INSERT INTO CUSTOMER_AUDIT VALUES 
                                (:OLD.ID,:OLD.NAME,:OLD.CONTACT,:OLD.EMAIL,:NEW.NAME,:NEW.CONTACT,:NEW.EMAIL,'UPDATE',SYSDATE);
    ELSIF DELETING THEN
        INSERT INTO CUSTOMER_AUDIT  VALUES 
                                (:OLD.ID,:OLD.NAME,:OLD.CONTACT,:OLD.EMAIL,NULL,NULL,NULL,'DELETE',SYSDATE);
    END IF;
END;

-- AUDIT TABLE FOR EVENT TABLE
CREATE TABLE EVENT_AUDIT(
  ID INT NOT NULL,
  OLD_PEOPLE_COUNT INT NOT NULL,
  OLD_STAFF_COUNT INT NOT NULL,
  OLD_CUSTOMER_ID INT NOT NULL,
  OLD_ADDRESS_ID INT NOT NULL,
  OLD_MENU_ID INT NOT NULL,
  OLD_EXPECTED_DURATION INT, 
  OLD_ACTUAL_DURATION INT, 
  OLD_EVENT_DATE DATE, 
  OLD_EVENT_COST NUMBER,
  NEW_PEOPLE_COUNT INT NOT NULL,
  NEW_STAFF_COUNT INT NOT NULL,
  NEW_CUSTOMER_ID INT NOT NULL,
  NEW_ADDRESS_ID INT NOT NULL,
  NEW_MENU_ID INT NOT NULL,
  NEW_EXPECTED_DURATION INT, 
  NEW_ACTUAL_DURATION INT, 
  NEW_EVENT_DATE DATE,
  NEW_EVENT_COST NUMBER,
  OPERATION VARCHAR2(10) CHECK( operation IN('INSERT','UPDATE','DELETE')) NOT NULL,
  UPDATEDTIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);

CREATE OR REPLACE TRIGGER EVENT_AUDIT
  AFTER INSERT OR DELETE OR UPDATE ON EVENT
  FOR EACH ROW
BEGIN
     IF INSERTING THEN 
        INSERT INTO EVENT_AUDIT  VALUES 
                                (:OLD.ID, NULL, NULL,NULL,NULL, NULL,NULL,NULL, NULL,NULL,
                                  :NEW.PEOPLE_COUNT,:NEW.STAFF_COUNT,:NEW.CUSTOMER_ID,:NEW.ADDRESS_ID,:NEW.MENU_ID,:NEW.EXPECTED_DURATION,:NEW.ACTUAL_DURATION,:NEW.EVENT_DATE,:NEW.EVENT_COST,'INSERT',SYSDATE);
    ELSIF UPDATING THEN  
        INSERT INTO EVENT_AUDIT VALUES 
                                (:OLD.ID,:OLD.PEOPLE_COUNT,:OLD.STAFF_COUNT,:OLD.CUSTOMER_ID,:OLD.ADDRESS_ID,:OLD.MENU_ID,:OLD.EXPECTED_DURATION,:OLD.ACTUAL_DURATION,:OLD.EVENT_DATE,:OLD:EVENT_COST,
                                :NEW.PEOPLE_COUNT,:NEW.STAFF_COUNT,:NEW.CUSTOMER_ID,:NEW.ADDRESS_ID,:NEW.MENU_ID,:NEW.EXPECTED_DURATION,:NEW.ACTUAL_DURATION,:NEW.EVENT_DATE,:NEW.EVENT_COST'UPDATE',SYSDATE);
    ELSIF DELETING THEN
        INSERT INTO EVENT_AUDIT  VALUES 
                                (:OLD.ID,:OLD.PEOPLE_COUNT,:OLD.STAFF_COUNT,:OLD.CUSTOMER_ID,:OLD.ADDRESS_ID,:OLD.MENU_ID,:OLD.EXPECTED_DURATION,:OLD.ACTUAL_DURATION,:OLD.EVENT_DATE,:OLD.EVENT_COST,
                                 NULL, NULL,NULL,NULL, NULL,NULL,NULL, NULL,NULL,'DELETE',SYSDATE);
    END IF;
END;
                               
CREATE OR REPLACE PROCEDURE setCost
IS
thiseventcost EVENT_COST%rowtype;
CURSOR Cost_Update IS
    SELECT * FROM EVENT_COST
    FOR UPDATE;
    
BEGIN
    OPEN Cost_Update;
    LOOP
    FETCH Cost_Update INTO thiseventcost;
    EXIT WHEN (Cost_Update%NOTFOUND);
        UPDATE EVENT SET event.COST=thiseventcost.ecost WHERE event.ID=thiseventcost.eid;
    END LOOP;
    CLOSE Cost_Update;
END;
