-- 병렬 처리

-- 프로세스 한 개가 처리하는 것이 더 효율적인 경우도 있지만 버거운 경우도 있습니다.
-- 이를 잘 활용하면 SQL문을 처리할 때 실행 시간을 극적으로 단축할 수 있다.


-- 병렬도

-- 오라클의 병렬처리는 자동으로 이뤄지지 않습니다.
-- 힌트를 이용해 수동으로 지정해야 병렬처리가 가능합니다.

SELECT /*+ FULL(OI) PARALLEL(OI 2) */
        COUNT(*)
  FROM ORD_ITEM OI
 WHERE ORD_DT BETWEEN '20120101' AND '20120331';


-- 위 예제에서 보면 힌트 /*+ FULL(OI) PARALLEL(OI 2) */ 구믄을 표현했습니다.
-- 병렬 힌트를 사용할 때, 옵티마이저 스캔 방식을 인덱스 스캔으로 결정하면 병렬 힌트를 사용하지 않습니다.
-- 그래서 위 예제 처럼 FULL(OI) 힌트를 같이 사용하는 것이 좋습니다.
-- PARALLEL 힌트를 사용할 때는 병렬로 읽을 테이블과 병렬도를 지정합니다.
-- 위와 같이 2라고 지정하였으면 일반적으로 2개의 프로세스가 나누어 처리합니다.


-- 데이터 재분배

-- 병렬 프로세스로 데이터를 처리할 때, 각각의 프로세는 데이터를 공유하지 못합니다.
-- 하나의 프로그램에서 프로세스를 여러 개 생성하는 것과 다르지 않습니다.
-- 데이터 재분배는 각각의 프로세스가 더 효율적으로 처리할 수 있도록 할당 받은 데이터를 다시 분배하는 일입니다.

SELECT /*+ FULL(OI) PARLLEL(OI 2) */
        ORD_DT
     , ITEM_ID
     , SUM(ORD_ITEM_QTY)
  FROM ORD_ITEM OI
 WHERE ORD_DT BETWEEN '20120101' AND '20120331'
 GROUP BY ORD_DT, ITEM_ID

===================

PX COORDINATOR
    PX SEND QC (RANDOM)
        HASH GROUP BY
            PX RECEIVE
                PX SEND HASH
                    HASH GROUP BY
                        PX BLOCK ITERATOR
                            TABLE ACCESS FULL


-- 위 실행계획에서 P -> P 오퍼레이션이 발생하면 프로세스가 두 배로 생성되었다고 생각할 수 있습니다.
-- 이 처럼 P -> P 오퍼레이션이 발생하면 프로세스는 두 배로 생성되고, 프로세스 간 통신은 제곱만큼 발생합니다.
-- 분배 방식으로 HASH를 선택하였습니다.
-- 최종 결과 집합으로 만들어질때는 먼저 처리된 순서대로 결과 집합이 만들어 집니다.


SELECT /*+ FULL(O) PARALLEL(O 2) */
        *
  FROM ORD O
 WHERE ORD_DT BETWEEN '20120101' AND '20120331'
   AND SHOP_NO = 'SH0001'
 ORDER BY ORD_NO;

============

PX COORDINATOR
    PX SEND QC(ORDER)
        SORT ORDER BY
            PX RECEIVE
                PX SEND RAGNE
                    PX BLOCK ITERATOR
                        TABLE ACCESS FULL


-- GROUP BY와 마찬가지로 ORDER BY에서도 데이터 재분배가 일어납니다.
-- 재분배가 일어나면 병렬도의 두 배로 프로세스를 생성합니다.
-- 원리는 GROUP BY와 같고, 분배는 RANGE 방식으로 진행합니다.
-- 최종 결과 집합이 만들어질 떄 정렬되면서 만들어 집니다.



-- 인덱스 스캔 vs 테이블 풀 스캔 vs 병렬 수행

-- 테이블 데이터를 가져올 때, 인덱스를 이용할지 테이블 풀 스캔을 해야 할지 병렬 프로세스로 수행해야 할지 애매한 경우가 있습니다.
-- 다음 SQL문에서 ORD_ITEM 테이블에는 약 3700만 건이 있고, 처리해야 할 범위의 건수는 약 460만 건입니다.

SELECT ORD_DT
     , ITEM_ID
     , SUM(ORD_ITEM_QTY)
  FROM ORD_ITEM OI
 WHERE ORD_DT BETWEEN '20120101' AND '20120331'
 GROUP BY ORD_DT, ITEM_ID

===========

HASH GROUP BY
    TABLE ACCESS BY INDEX ROWID
        INDEX RANGE SCAN


SELECT /*+ FULL(OI) */
        ORD_DT
      , ITEM_ID
      , SUM(ORD_ITEM_QTY)
  FROM ORD_ITEM OI
 WHERE ORD_DT BETWEEN '20120101' AND '20120331'
 GROUP BY ORD_DT, ITEM_ID 

=============

HASH GROUP BY
    TABLE ACCESS FULL


SELECT /*+ FULL(OI) PARALLEL(OI 2) */
        ORD_DT
      , ITEM_ID
      , SUM(ORD_ITEM_QTY)
   FROM ORD_ITEM OI
  WHERE ORD_DT BETWEEN '20120101' AND '20120331'
  GROUP BY ORD_DT, ITEM_ID

===============

PX COORDINATOR
    PX SEND QC
        HASH GROUP BY
            PX RECEIVE
                PX SEND HASH
                    HASH GROUP BY
                        PX BLOCK ITERATOR
                            TABLE ACCESS FULL


-- 단일 테이블에서는 병렬 수행효과가 생각보다는 낮다는 점과 인덱스 이용이 무조건 좋은 것은 아님을 말하고 싶습니다.
-- 병렬로 수행하는 것은 파티션이 되어 있을 때 더 좋은 성능을 냅니다.



SELECT /*+ FULL(OI) */
        SUBSTR(ORD_DT, 1, 6) ORD_NM
     , ITEM_ID
     , SUM(ORD_ITEM_QTY)
  FROM ORD_ITEM_LIST OI
 WHERE 1=1
   AND ORD_YM BETWEEN '201201' AND '201206'
   AND ORD_DT BETWEEN '20120101' AND '20120630'
 GROUP BY SUBSTR(ORD_DT, 1, 6)
        , ITEM_ID;

===============               

HASH GROUP BY
    PARTITION LIST ITERATOR
        TABLE ACCESS FULL


SELECT /*+ FULL(OI) PARALLEL(OI 2) */
        SUBSTR(ORD_DT, 1, 6) ORD_NM
     , ITEM_ID
     , SUM(ORD_ITEM_QTY)
  FROM ORD_ITEM_LIST OI
 WHERE 1=1
   AND ORD_YM BETWEEN '201201' AND '201206'
   AND ORD_DT BETWEEN '20120101' AND '20120630'
 GROUP BY SUBSTR(ORD_DT, 1, 6)
        , ITEM_ID;

===========

PX COORDINATOR
    PX SEND QC
        HASH GROUP BY 
            PX RECEIVE
                PX SEND HASH
                    HASH GROUP BY
                        PX BLOCK ITERATOR
                            TABLE ACCESS FULL


-- 리스트 파티션 테이블에서 병렬로 수행한 것과 싱글로 수행한 것과 싱글로 수행한 것의 차이를 확인한 결과입니다.
-- 단일 테이블에서보다 확실히 병렬 처리가 빠릅니다.


-- 병렬 해시 조인과 파티션 와이즈 조인

-- 병렬 프로세스로 조인을 수행할 때, 가장 많이 사용하는 조인 방식은 해시 조인입니다.
-- 병렬 테이블을 읽을 때 테이블 풀 스캔을 진행하고, 풀 스캔으로 읽은 대용량의 데이터를 인덱스 없이 NL 조인을 수행하거나 소트 머지 조인을 위해 대용량의 데이터를 조인키로 정렬하기가 버겁기 때문입니다.
-- 병렬 프로세스에서 처리할 데이터는 상호 배타적입니다.
-- 이는 각 프로세스에서 서로 데이터를 공유할 수 없기 때문입니다.
-- 이 처럼 각 프로세스가 조인을 위해 데이터 쌍을 만드는 작업을 하게 되는데, 이를 파티션 와이즈 조인이라고 합니다.


-- 두 테이블 모두 파티션 테이블인 경우

SELECT /*+ FULL(O) FULL(OI) USE_HASH(OI) */
        COUNT(*)
  FROM ORD_LIST O
     , ORD_ITEM_LIST OI
 WHERE O.ORD_YM BETWEEN '201201' AND '201212'
   AND O.ORD_NO = OI.ORD_NO
   AND OI.ORD_YM = O.ORD_YM

 ==================

SORT AGGREGATE
    PARTITION LIST ITERATOR
        HASH JOIN
            TABLE ACCESS FULL
            TABLE ACCESS FULL


SELECT /*+
            FULL(O) PARALLEL(O 2)
            FULL(OI) PARALLEL(OI 2)
            USE_HASH(OI)
            PQ_DISTRIBUTE(OI NONE NONE)
        */
        COUNT(*)
  FROM ORD_LIST O
     , ORD_ITEM_LIST OI
 WHERE O.ORD_YM BETWEEN '201201' AND '201212'
   AND O.ORD_NO = OI.ORD_NO
   AND OI.ORD_YM = O.ORD_YM

============

SORT AGGREGATE
    PX COORDINATOR
        PX SEND QC(RANDOM)
            SORT AGGREGATE
                PX PARTITION LIST ITERATOR
                    HASH JOIN
                        TABLE ACCESS FULL
                        TABLE ACCESS FULL

-- 싱글로 수행되었어도 두 테이블 모두 파티션되었고, 필요한 파티션만 읽었기 때문에 블록 수가 많이 감소되었습니다.
-- 이처럼 파티션 끼리 조인이 되는 것을 파티션 와이즈 조인이라고 합니다.
-- 파티션 와이즈 조인이 가능한 경우, 이를 병렬로 수행하면 재분배 과정 없이 조인이 가능합니다.
-- 만약 옵티마이저가 다른 판단을 하게 된다면 위에처럼 PQ_DISTRIBUTE 힌트를 사용하여 SQL문을 제어할 수 있습니다.



