-- 인덱스 스캔 유도 방법

-- 테이블에 실제 적재된 데이터 상황과 다르다면 오라클이 엉뚱한 실행계획을 만들 수도 있습니다.
-- 이런경우 실행계획을 유도하기 위해서 힌트를 사용합니다.

-- INDEX : 인덱스 스캔을 유도. 어떤 인덱스 스캔을 유도할지는 오라클이 선택
-- IDNEX_DESC: 인덱스를 거꾸로 스캔
-- IDNEX_RS : 인덱스 범위 스캔을 유도. 
-- INDEX_SS: 인덱스 스킵 스캔을 유도.



SELECT /*+ INDEX(T T_X01) */ *      -- 테이블의 T_X01 인덱스를 사용
  FROM TMP T
 WHERE A = :a
   AND B = :b
   AND C = :c;
   
   
SELECT /*+ INDEX(T (A, B, C)) */ *  -- 테이블의 A, B, C 컬럼으로 구성된 인덱스 사용
  FROM TMP T
 WHERE A = :a
   AND B = :b
   AND C = :c;
   
   
   
-- INDEX Fast Full Scan

-- Index Fast Full Scan 은 인덱스 스캔 중 유일하게 멀티블록 I/O 방식으로 스캔합니다.
-- 일반적으로 인덱스 스캔을 했을 때 얻게 되는 정렬 순서가 Index Fast Full Scan에는 정렬순서가 보장되지 않는다.

-- Index Fast Full Scan을 위해서 SELECT 절과 WHERE 절에 있는 컬럼은 모두 인덱스에 포함되어야 합니다.
SELECT * FROM ORD;

SET AUTOTRACE ON 
SELECT COUNT(*) FROM ORD;   
   
   
-- INDEX Fast Full Scan이 동작하려명 PK 인덱스 또는 NOT NULL 컬럼이 포함된 인덱스가 있어야 합니다.


-- Index Combine은 한 테이블에서 두 개의 인덱스를 사용할 수 있게 해주는 기능이다.


create index 회원_X01 on 회원 (회원명);
create index 회원_X02 on 회원 (거주지);

SELECT /*+ INDEX_COMBINE(A 회원_x01 회원_X02) */
        *
  FROM 회원 A
 WHERE 회원명 LIKE '박%'
   AND 거주지 = '서울';
   
SELECT /*+ INDEX_COMBINE(A 회원_x01 회원_X02) */
        *
  FROM 회원 A
 WHERE ( 회원명 LIKE '박%' OR 거주지 = '서울' );
