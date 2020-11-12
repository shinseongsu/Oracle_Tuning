-- 2. 소트 머지 조인

-- 소트 머지 조인은 두 테이블을 각각 조건에 맞게 먼저 읽습니다.
-- 그리고 읽은 두 테이블을 조인컬럼을 기준으로 정렬해 놓고 조인을 수행합니다.

-- NL 조인은 드라이빙 테이블을 읽어 조인 대상을 먼저 거르고, 조인 대상이 되는 데이터가 한 건 발생할 떄 마다 Inner 테이블과 조인을 시도하게 됩니다.
-- 소트 머지 조인은 각 테이블에서 조인 대상이 되는 조건을 먼저 걸러 대상이 되는 두 테이블 데이터를 만든 후에 조인을 시도합니다.
-- 테이블 미리 읽어 조인 대상을 추출해 놓는다는 점을 제외하면 NL 조인과 다른 점이 없습니다.

-- 오라클에서는 정렬을 PGA 공간에서 수행합니다.
-- PGA 공간은 프로세스에 할당된 독립된 공간이므로 버퍼 캐시(SGA)를 사용하는 NL 조인에 비해 조인을 시도하는 데이터 접근이 더 빠릅니다.

SELECT /*+ ORDERED USE_MERGE(E) */
       *
  FROM DEPT D
     , EMP E
 WHERE 1 =1 
   AND D.DEPTNO = E.DEPTNO
   
   
============

MERGE JOIN
    SORT JOIN
        TABLE ACCESS FULL
    SORT JOIN
        TABLE ACCESS FULL
        

-- 풀이 방식

-- 1. first 테이블을 조인 컬럼 기준으로 정렬한다.
SELECT * FROM DEPT ORDER BY DEPTNO;

-- 2. second 테이블을 조인 컬럼 기준으로 정렬한다.
SELECT * FROM EMP ORDER BY DEPTNO;

-- 3. 테이블을 조인한다.

begin_point = 0;

for(i = 0 ; i < I_MAX ; i++)                -- DEPT 테이블
    for(j = begin_point; j < J_MAX ; j++)   -- EMP 테이블 
        while(d.deptno == e.deptno) 
            begin_point = j + 1
        break;
        
-- 한번 더 정리해 보자면, DEPT 테이블을 DEPTNO 컬럼 기준으로 정렬하고,
-- EMP 테이블을 읽어 DEPTNO 컬럼 기준으로 정렬한 다음, 정렬된 각 테이블을 DEPTNO 컬럼으로 조인을 시도합니다.
-- 각 테이블을 한 번씩만 읽어 1차로 데이터를 추출 정렬하여 조인키로 정렬했으므로 조인 횟수를 줄일 수 있다.

-- NL 조인은 Inner 테이블에 조인키가 없으며, 드라이빙 테이블에서 추출된 건 마다 Inner 테이블을 반복적으로 액세스해야 합니다.
-- 조인키에 인덱스가 있다고 하더라도 대량의 데이터 조인 발생시 많은 양의 랜덤 액세스를 해야 하는 단점이 있다.


-- 반면 소트 머지 조인은 각 테이블을 한 번 씩만 읽고 조인 시에는 PGA 공간에서 이루어지기 때문에 조인으로 인한 랜덤 액세스 부하는 없다고 할 수 있다.



SELECT /*+ ORDERED USE_MERGE(B) */
        A.*
     ,  B.*
   FROM ITEM A
      , UITEM B
  WHERE A.ITEM_ID = B.ITEM_ID           -- 1
    AND A.iTEM_TYPE_CD = '100101'       -- 2
    AND A.SALE_YN = 'Y'                 -- 3
    AND B.SALE_YN = 'Y';                -- 4
    
    
create index itme_x01 on item(item_type_cd);


-- 위 쿼리문은 WHERE 절의 동작 순서는 ORDERED 힌트를 명시했기 때문에 ITEM을 먼저 읽습니다.
-- 위 SQL 문은 2 -> 3 -> 4 -> 1 로 실행됩니다.

-- 위의 쿼리문의 최적의 방법을 찾는다면..

create index item_new on item(item_type_cd, sale_yn, item_id);
create index uitem_new on uitem(sale_yn, item_id);

-- 여기서도 sale_yn 으로 많이 걸러진다면 인덱스 효율이 높아진다.

-- 최종적으로 추려진 데이터를 조인키 기준으로 정렬하게 됩니다.
-- 이때 정렬을 대신할 인덱스가 있으면 정렬을 위한 부하를 줄일 수 있다.
 
 
 
    
    
    






        
            
            
            
            
            
