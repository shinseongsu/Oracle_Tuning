-- 인덱스로 테이블 액세스 최적화

-- 인덱스로 테이블 랜덤 액세스

-- 인덱스에는 해당 데이터를 찾기 위해 Rowid를 가지고 있다고 앞에서 설명했습니다.
-- Rowid의 정보 중에는 해당 데이터가 어느 블록에 있는지를 담고 있는 블록정보가 있습니다.
-- 이 블록이 현재 메모리에 로드되어 있는지를 조회해 있으면 메모리에 찾고 없으면 디스크에 가서 해당 블록을 메모리에 적재합니다.

-- 메모리에 적재된 블록들이 어디에 위치하고 있는지를 알려주는 곳이 있어 그곳에 찾으려는 블록이 있는지를 묻습니다.
-- 만약 해당 블록이 메모리에 있으면 바로 접근 가능한지를 체크합니다.
-- 만약 다른 프로세스가 다른 프로세스가 사용중이라면 잠시 대기 상태로 빠집니다.
-- 대기상태에서 다시 사용가능한지를 체크하고, 사용 가능하다면 트랜잭션에 의해 락이 걸려있는지를 또 체크하는데 이때 락이 걸려 있으면 다시 대기해야 합니다.


-- 클러스터링 팩터 와 랜덤으로 된 테이블 비교 해보기

SELECT /*+ INDEX(OI ORD_ITEM_PK) */ *
  FROM ORD_ITEM OI
 WHERE ROWNUM <= 100
UNION ALL
SELECT /*+ INDEX(OIR ORD_ITEM_RANDOM_PK) */ *
  FROM ORD_ITEM_RANDOM OIR
 WHERE ROWNUM <= 100;
 
 
============

UNION-ALL
    COUNT STOPKEY                           -- 랜덤 액세스 6번
        TABLE ACCESS BY INDEX ROWID
            INDEX FULL SCAN
    COUNT STOPKEY                           -- 랜덤 액세스 100번
        TABLE ACCESS BY INDEX ROWID
            INDEX FULL SCAN
            


-- 인덱스 튜닝 사례

-- 인덱스 스캔에서 비효율 판단하기

CREATE INDEX ORD_ITEM_X01 ON ORD_ITEM(ORD_DT, ORD_HMS);

SELECT COUNT(ORD_ITME_QTY)
  FROM ORD_ITEM
 WHERE ORD_DT BETWEEN '20120101' AND '20120131';
 
===============

SORT AGGREGATE
    TABLE ACCESS BY INDEX ROWID
        INDEX RANGE SCAN
 
 
-- 비효율은 없었다.



CREATE INDEX ORD_X01 ON ORD(ORD_DT, ORD_HMS);

SELECT COUNT(UPPER_CASE)
  FROM ORD
 WHERE ORD_DT BETWEEN '20120101' AND '20120331'
   AND SHOP_NO = 'SH0001';
   
============

SORT AGGREGATE
    TABLE ACCESS BY INDEX ROWID
        INDEX RNAGE SCAN
        

-- INDEX RANGE SCAN 에서 비효율이 발생한다.
-- TABLE ACCESS에서 SHOP_NO 필터링이 발생한다.
-- 인덱스에 읽은 건수가 테이블 방문 후에 크게 줄었으므로 비효율이 있다고 봐도 좋습니다.

CREATE INDEX ORD_X02 ON ORD(ORD_DT, ORD_MHS, UPPER_CASE);

SELECT COUNT(SHOP_NO)
  FROM ORD
 WHERE ORD_DT BETWEEN '20120101' AND '20121231'
  AND UPPER_CASE LIKE 'ABCD%';
  
  
===========

SORT AGGREGATE
    TABLE ACCESS BY INDEX ROWID
        INDEX RANGE SCAN
        
-- 추출한 건수에 비해 훨씬 많은 인덱스 블록을 접근한 것입니다.
-- 인덱스 스캔 시 ORD_DT 지점 스캔 과 UPPER_CASE 스캔을 같이 한다.
-- 많은 양의 인덱스 블록을 읽어 적은 양의 데이터를 추출하여 비효율이 있다고 볼 수 있다.



CREATE INDEX ORD_X01 ON ORD(ORD_DT, ORD_HMS);

SELECT COUNT(UPPER_CASE)
  FROM ORD
 WHERE ORD_DT BETWEEN '20120101' AND '20120228'
   AND SHOP_NO = 'SH0001';
   
==============

SORT AGGREGATE
    TABLE ACCESS BY INDEX ROWID
        INDEX RANGE SCAN
        
        
-- 주문일자는 인덱스를 정상적으로 스캔하였으나 매장번호는 인덱스에 없기 때문에 테이블에 방문하여 필터로 처리되었습니다.
-- 인덱스에서는  125만건 하지만, 테이블 필터에서는 5437건이 결과 집합으로 만들어집니다.
-- 124만건 정도가 테이블 방문이 의미가 없는 것입니다.
-- 매장번호 + 주문일자 로 만드는게 제일 이상적이다.


CREATE INDEX ORD_X01 ON ORD(SHOP_NO, ORD_DT);

SELECT COUNT(UPPER_CASE)
  FROM ORD
 WHERE ORD_DT BETWEEN '20120101' AND '20120228'
   AND SHOP_NO = 'SH0001';
   
============

SORT AGGREGATE
    TABLE ACCESS BY INDEX ROWID
        INDEX RANGE SCAN
        

-- 매장번호를 테이블이 아닌 인덱스에서 처리하고, 전체처리 블록수가 줄어 들었다.
-- 다만 인덱스 처리 블록은 컬럼이 추가되어 인덱스 자체 크기가 증가하였으므로 인덱스 블록의 양이 소폭 늘어납니다.
-- 대신 의미없는 테이블에 방문하는 건수는 획기적으로 줄었습니다.
        


