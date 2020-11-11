-- PK 인덱스 확장하기

-- PK 인덱스를 변경할때는 주의할 사항은 기존 pK 컬럼들을 선두에 놓아야 한다는 것입니다.

ALTER TABLE 테이블명 ADD CONSTRAINT PK명 PRIMARY KEY(PK컬럼들) USING INDEX 인덱스명;


-- 대개 대용량 데이터를 다루는 프로젝트라 하더라도 모든 테이블의 데이터가 대용량은 아닙니다.
-- 데이터가 적더라도, 명칭만 PK인덱스에 포함하더라도 조인을 통해 명칭만 가져오는 SQL문에 대해서는 테이블에 접근하지 않고 인덱스에서만 처리가 가능합니다.

-- 1. ITEM_PK 인덱스가 ITEM_ID만 있는 경우

SELECT OI.ORD_NO
     , OI.ITEM_ID
     , I.ITEM_NM
     , OI.ORD_ITEM_QTY
  FROM ORD_ITEM OI
     , ITEM I
 WHERE ORD.DT BETWEEN '20120101' AND '20120110'
   AND I.ITEM_ID = OI.ITEM_ID
   
=======

NESTED LOOPS
    NESTED LOOPS
        TABLE ACCESS BY INDEX ROWID
            INDEX RANGE SCAN
    INDEX UNIQUE SCAN
TABLE ACCESS BY INDEX ROWID


-- 2. ITEM_PK 인덱스를 ITEM_ID + ITEM_NM 으로 만든 경우

SELECT OI.ORD_NO
     , OI.ITEM_ID
     , I.ITEM_NM
     , OI.ORD_ITEM_QTY
  FROM ORD_ITEM OI
     , ITEM I
 WHERE ORD.DT BETWEEN '20120101' AND '20120110'
   AND I.ITEM_ID = OI.ITEM_ID
   
=========

NESTED LOOPS
    TABLE ACCESS BY INDEX ROWID
        INDEX RANGE SCAN
    INDEX RANGE SCAN
    


-- 인덱스에서만 처리하기


-- SQL문에서 사용하는 모든 컬럼을 포함해 테이블로 액세스하지 않도록 만드는 것이 다릅니다.

CREATE INDEX ORD_ITEM_X01 ON ORD_ITEM(ORD_DT, ORD_HMS);

SELECT ORD_DT
     , ITEM_ID
     , SUM(ORD_ITEM_QTY)
  FROM ORD_ITEM
 WHERE ORD_DT BETWEEN '20120101' AND '20120131'
 GROUP BY ORD_DT
        , ITEM_ID
        
==============

HASH GROUP BY
    TABLE ACCESS BY INDEX ROWID
        INDEX RANGE SCAN
        
   
CREATE INDEX ORD_ITEM_X99 ON ORD_ITEM(ORD_DT, ORD_HMS, ORD_ITEM_QTY);


=============

SORT GROUP BY NOSORT
    INDEX RANGE SCAN
    
    


        


   