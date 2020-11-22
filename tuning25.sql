-- 복합 파티셔닝

-- 테이블을 파티션할 예정이라면 처음부터 복합 파티션을 고려해 보는게 좋다.
-- 여러 이유가 있겠지만 각각의 파티션 특징이 제한적이고, 파티션을 사용하는 목적이 주로 파티션 단위로 무언가를 하기 때문일 것입니다.
-- 복합 파티션을 만들 때, 삭제와 조회 기준으로 전략을 짜면 매우 좋습니다.

-- 오라클은 복합 파티션을 메인 파티션과 서브 파티션으로 구분합니다.
-- 메인 파티션으로 Range와 리스트만 가능합니다.
-- 서브 파티션으로는 모두 가능합니다.

-- 만약 어떤 테이블에서 오래된 데이터를 삭제하는 일이 번번하고, 특정 컬럼과 조인을 자주 한다면 Range - hash 또는 List - hash 전략이 단일 파티션을 하는 것이 좋습니다.

-- 또는 오래된 데이터를 삭제하는 업무와 지역별 업무를 처리하는 경우도 "Range - List" 또는 "List - List " 형태의 복합 파티션을 만들 수 있다.



-- 인덱스 파티션닝

-- 테이블을 파티션으로 나누어 보관하는 방법을 배웠습니다.
-- 인덱스도 테이블과 마찬가로 나누어 보관할 수 있다.
-- 인덱스는 데이터에 종속적이기 때문에 인덱스를 나눌 때도 테이블을 나누는 전략을 잘 활용해야 합니다.

-- 로컬 파티션 인덱스는 좌측에 위치한 부서별 사원 목록입니다.
-- 사원을 배치한 기준과 사원 목록이 같은 기준을 사용합니다.

-- 글로벌 파티션 인덱스는 우측에 위치한 연도별 사원 목록입니다.
-- 사원은 부서별로 배치하고 사원 목록은 연도별로 배치하여 테이블과 인덱스가 다른 기준을 사용합니다.

-- 비파티션 인덱스는 파티셔닝했지만 인덱스는 파티셔닝하지 않은 인덱스입니다.
-- 일반적으로 PK의 경우에는 논리적으로 비파티션 인덱스를 사용해야 완벽하게 무결성을 유지할 수 있습니다.



-- 로컬 파티션 인덱스는 테이블 파티션과 인덱스 파티션이 1:1로 대응합니다.
-- 테이블 파티션 키 컬럼을 그래로 사용하므로 테이블 파티션 1개당 인덱스 파티션도 1개가 만들어집니다.
-- 문법적으로 일반적인 인덱스 생성 구문 제일 뒤에 LOCAL이라는 키워드만 붙이면 간단하게 만들 수 있습니다.
-- 테이블을 파티셔닝하면 대개 인덱스도 로컬 파티션 인덱스를 사용하려고 합니다.
-- 테이블 파티션을 삭제할 경우 해당 파티션의 로컬 인덱스도 동시에 삭제가 가능합니다.


-- 글로벌 파티션 인덱스는 테이블 파티션의 기준과 다른 키 컬럼을 적용하고자 할 때 사용합니다.
-- 글로벌 파티션 인덱스의 가장 큰 제약은 인덱스 키 컬럼을 항상 파티션 인덱스라고합니다.
-- 테이블과 파티션 기준이 달라서 오는 제약도 많은데 인덱스 생성시 파티션 키 컬럼을 항상 첫 번째 컬럼으로 만드는 것은 여간 큰 제약이 아닐 수 없습니다.
-- 그래서 글로벌 파티션 인덱스를 사용하는 경우를 거의 본 적이 없습니다.



-- 파티션 Pruning

-- 지금까지 파티션을 나누는 방법에 대하여 공부하였습니다.
-- 이제는 파티션만 접근하는 기증에 대하여 살펴보겠습니다.
-- 파티션 Pruning은 테이블 전체를 읽지 않고, 필요한 파티션만 읽을 수 있도록하는 기능입니다.

-- LIST 파티션에서도 동일한 조건으로 하기 위해 주문년월 컬럼을 만들었습니다.

SELECT COUNT(*) FROM ORD_LIST WHERE ORD_YM = '201201';

===========

SORT AGGREGATE
    PARTITION LIST SINGLE
        TABLE ACCESS FULL


-- PARTITION LIST SINGLE을 보면 알 수 있듯이 리스트 파티션으로 나뉜 테이블에서 파티션 한 개를 읽은 것입니다.

-- Rnage 파티션의 예제를 보면

SELECT COUNT(*) FROM ORD_RANGE HWERE ORD_YM = '201201';

===========

SORT AGGREGATE
    PARTITION RANGE SINGLE
        TABLE ACCESS FULL


-- List 파티션과 다른 점은 조건절이 핕터 조건으로 나왔다는 것입니다.
-- 파티션 키 컬럼에 저장된 값이 한 개뿐이라는 것을 알 수 없기 때문에 필터 조건이 나온다.

-- 이번에는 각각 ORD_DT, ORD_HMS 컬럼을 로컬 파티션 인덱스로 가진 테이블에 파티션 Pruning이 동작하도록 하여 리스트 파티션과 Range 파티션을 테스트해 보겠습니다.

create index index_x01 on ORD_LIST(ORD_DT, ORD_HMS);

SELECT COUNT(*)
  FROM ORD_LIST
 WHERE ORD_YM = '201201'
   AND ORD_DT BETWEEN '20120101' AND '20120110';

=============

SORT AGGREGATE
    PARTITION LIST SINGLE
        INDEX RANGE SCAN


create index index_X02 on ORD_RANGE(ORD_DT, ORD_HMS);

select count(*)
  from ORD_RANGE
 where ord_ym = '201201'
   and ord_dt between '20120101' and '20120110';

=========


SORT AGGREGATE
    PARTITION RANGE SINGLE
        TALBE ACCESS BY LOCAL INDEX ROWID
            INDEX RANGE SCAN



-- 리스트 파티셔닝은 ORD_YM의 필터가 없습니다. 테이블로의 랜덤 액세스 없이 인덱스만 읽었습니다.

-- Range 파티션닝은 인덱스를 액세스한 모든 로우에서 테이블로 접근이 있었습니다.
-- ORD_YM 조건 때문에 파티션 Pruing은 일어났지만 ORD_YM의 값이 하나뿐이라고 보장하지 못하므로 테이블로의 랜덤 액세스가 발생합니다.
-- 이런 이유로 Range 파티션에서 키 컬럼 값이 하나만 저장될 것이라면 리스트 파티션도 고려해 보아야 합니다.


SELECT COUNT(*) FROM ORD_LIST WHERE ORD_YM BETWEEN :st AND :ed

==========

SORT AGGREGATE
    FILTER
        PARTITION LIST ITERATOR
            TABLE ACCESS FULL

-- 리스트 파티션을 만들어도 경우에 따라 BETWEEN 과 같은 범위 조건을 사용했을 경우 해당 파티션만 액세스할 수 있습니다.


SELECT COUNT(*) FROM ORD_LIST WHERE SUBSTR(ORD_YM, 1, 6) = :st

===========

SORT AGGREGATE
    PARTITION LIST ALL
        TABLE ACCESS FULL

-- 파티션 키 컬럼도 인덱스 컬럼과 마찬가지로 가공하면 오라클이 어느 파티션으로 액세스 해야 할지 모릅니다.


update ORD_LIST
  SET  SHOP_NO = 'xx'
 WHERE ORD_NO = 1
  AND  ORD_DT = '20120101';

============

UPDATE 
    PARTITION LIST ALL
        TABLE ACCESS BY LOCAL INDEX ROWID
            INDEX RANGE SCAN



update (select * from ORD_LIST where ord_ym = substr('20120101', 1, 6))
   set shop_no = 'xx'
 where ord_no = 1
   and ord_dt = '20120101';

 =========

 update
    PARTITION LIST SINGLE
        TABLE ACCESS BY LOCAL INDEX ROWID
            INDEX UNIQUE SCAN



-- 사실 select 구문에서 파티션 키 컬럼을 가공하지 않고 where 절 구문에 반드시 포함해야 한다는 사실은 이제 대부분 개발현장에서 알고 있습니다.
-- 그렇지만 update 구문이나 merge 구문의 update 기능에서는 모르는 경우도 많이 있습니다.


MERGE INTO ORD_LIST M
USING (
        SELECT ORD_NO, SHOP_NO FROM ORD WHERE ORD_NO = 7 AND ORD_DT = '20120101'
      ) S
   ON ( M.ORD_NO = S.ORD_NO )
  WHEN MATCHED THEN UPDATE
  SET M.SHOP_NO = S.SHOP_NO

==============

MERGE
    VIEW
        NESTED LOOPS
            TABLE ACCESS BY INDEX ROWID
                INDEX UNIQUE SCAN
            PARTITION LIST ALL
                TABLE ACCESS BY LOCAL INDEX ROWID
                    INDEX RANGE SCAN



MERGE INTO ( SELECT * FROM ORD_LIST WHERE ORD_YM = SUBSTR('20120101', 1, 6)) M
USING (
        SELECT ORD_NO, SHOP_NO FROM ORD WHERE ORD_NO = 7 AND ORD_DT = '20120101'
      ) S
  ON ( M.ORD_NO = S.ORD_NO )
 WHEN MATCHED THEN UPDATE
 SET  M.SHOP_NO = S.SHOP_NO

==========================


MERGE
    VIEW
        NESTED LOOPS
            TABLE ACCESS BY INDEX ROWID
                INDEX UNIQUE SCAN
            PARTITION LIST SINGLE
                TABLE ACCESS BY LOCAL INDEX ROWID
                    INDEX UNIQUE SCAN


-- Merge 구문에서도 위 예제처럼 파티션 Pruning 기능이 동작하도록 처리해야 합니다.
-- 특히 Merge 구문이나 update 구문을 사용할 경우, 파티션 Pruning을 실수로 빼 먹는 경우가 많으니 꼭 기억하기 바랍니다.

