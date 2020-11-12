-- 3. 해시 조인

-- 해시 조인에 대한 개념을 소개하기에 앞서 해시 알고리즘을 알아보는 것이 선행되어야 잘 이해할 수 있다.

f(x) -> mod(x, 10)

-- 위 함수는 x값이 입력될 때, 10으로 나눈 나머지를 반환합니다.
-- 해시 맵을 만들 때, 해시 버킷을 생성하고 해시 함수를 통해 반환된 값으로 버킷을 찾아 해시 체인을 구성합니다.

-- 해시 맵에는 조인 컬럼과 SELECT 절에서 사용한 컬럼까지 포함됩니다.
-- SQL 작성시 꼭 필요한 컬럼만 기술하는 것이 PGA 사용량을 줄일 수 있다.


SELECT /*+ ORDERED USE_HASH(E) */
        *
  FROM DEPT D
     , EMP E
 WHERE 1 = 1
   AND D.DEPTNO = E.DEPTNO
   
   
=================

HASH JOIN
    TABLE ACCESS FULL
    TABLE ACCESS FULL
    
    
-- DEPT 테이블을 먼저 읽어 Build Input으로 선택해 해시 맵을 만들고, EMP 테이블을 Probe Input으로 선택해 EMP 테이블을 읽으면서 조인을 시도합니다.
-- 사용자가 Build Input을 선택하려면 추가 힌트를 사용해야 합니다.
-- 두 개의 테이블만으로 해시 조인을 할 경우 ORDERED 나 LEADING 힌트를 사용해야 합니다.
-- 두 개의 테이블만으로 해시 조인을 할 경우 ORDERED 나 LEADING 힌트를 사용해서 Build Input을 지정할 수 있습니다.
-- 하지만 3 개 이상의 테이블을 가지고 해시 조인을 할 때, Build Input을 사용자가 지정하려면 SWAP_JOIN_INPUTS(테이블명) 힌트를 사용해야 합니다.



SELECT /*+ USE_HASH(E) SWAP_JOIN_INPUTS(E) */
        *
   FROM DEPT D
      , EMP E
  WHERE 1 = 1
    AND D.DEPTNO = E.DEPTNO;
    

=============

HASH JOIN
    TABLE ACCESS FULL       -- EMP
    TABLE ACCESS FULL       -- DEPT
    



SELECT /*+ USE_HASH(E) */
       D.*
     , E.*
   FROM DEPT D
      , EMP E
  WHERE 1 = 1
    AND D.DEPTNO = E.DEPTNO
    
    
=============

HASH JOIN
    TABLE ACCESS FULL       -- DEPT
    TABLE ACCESS FULL       -- EMP
    
    
-- 이떄는 오라클이 통계 정보를 확인해 더 작은 테이블을 Build Input으로 선택합니다.
-- 해시 조인 할떄는 Build Input이 작아야 더 유리하기 때문이다.
-- Build Input이 지나치게 큰 테이블로 선택되면, PGA 내 해시 영역안에 적재가 힘들어집니다.
-- 결국 디스크 공간을 사용하게 되고, 이런 상황이 발생하면 해시 조인의 성능이 크게 떨어집니다.

    
    
    

    
    