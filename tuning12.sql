-- 조인

-- 조인 방식에는 크게 NL 조인(Nested Loop Join), 소트 머지 조인(Sort Merge Join), 해시 조인(Hash join) 이 있습니다.

-- 1. NL 조인

-- NL 조인은 두 테이블이 조인을 할 때, 드라이빙 테이블에서 읽은 결과를 Inner 테이블로 건건이 조인을 시도하는 방식이다.

-- for( i = 0 ; i < I_MAX ; i++ )
--  for( j = 0 ; j < J_MAX ; j++ )



-- 다음 SQL문을 보면서 NL 조인을 유도하는 방법과 앞 로직을 이해해 보자.

SELECT /*+ ORDERED USER_NL(E) */
       *
  FROM DEPT D
     , EMP E
 WHERE 1 = 1
   AND D.DEPTNO = E.DEPTNO
   
==========

NESTED LOOPS
    TABLE ACCESS
    TABLE ACCESS
    
    
    
-- DEPT 테이블에서 데이터를 한 건 읽어서 EMP 테이블로 조인을 시도하고, 조인에 성공하는 만큼을 결과 집합에 담습니다.
-- 다시 DEPT 테이블로 돌아가서 다음 한 건을 읽습니다. EMP 테이블로 또 조인을 시도하고, 조인에 성공하는 만큼을 결과 집합에 담습니다.

-- /*+ ORDERED USER_NL(E) */
-- ORDERED: FROM 절에 나열된 순서대로 테이블을 읽도록 명령
-- USE_NL(E): E와 조인을 할떄 NL 조인을 사용.



create index item_x01 on item(item_type_cd);
create index uitem_pk on uitem(item_id, uitem_id);

SELECT /*+ ORDERED USE_NL(B) */
       A.*
     , B.*
  FROM ITEM A
     , UITEM B
 WHERE A.ITEM_ID = B.ITEM_ID            -- 1
   AND A.ITEM_TYPE_CD = '100100'        -- 2
   AND A.SALE_YN = 'Y'                  -- 3
   AND B.SALE_YN = 'Y';                 -- 4
   
   
-- ORDERED 힌트를 명시했기 때문에 ITEM을 먼저 읽습니다.
-- WHERE 순서로 2 -> 3 -> 1 -> 4 로 실행됩니다.


-- NL 조인은 랜덤 액세스 방식이라 비효율적으로 보이지만, 한 건씩 처리하기  떄문에 중간에 멈추는 경우에서 만큼은 적절한 인덱스만 있다면 극적으로 처리속도 개선의 여지가 있는 것입니다.
-- 위에 인덱스를 최적화 하기 위해서는 

create index item_new on item(item_type_cd, sale_yn);
create index uitem_new on uitem(item_id, sale_yn);

-- sale_yn = 'y' 의 조건으로 걸러지는 데이터가 많다면 인덱스의 효과가 더욱 커질 것이다.



   
   