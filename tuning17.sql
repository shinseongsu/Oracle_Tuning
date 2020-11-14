-- Outer 조인

-- Outer NL 조인

-- Outer NL 조인은 NL 조인의 특성상 Outer 조인을 할 때, 조인 방향이 한쪽으로 고정됩니다.
-- (+)가 붙지 않은 테이블을 항상 드라이빙 테이블로 선택합니다.
-- LEADING이나 ORDERED 힌트를 사용하더라도 그 순서를 바꿀 수 없습니다.

SELECT /*+ LEADING(D) USE_NL(E) */
       *
  FROM DEPT D
      , EMP E
 WHERE D.DEPTNO = E.DEPTNO(+)
 
================

NESTED LOOPS OUTER
    TABLE ACCESS FULL   DEPT
    TABLE ACCESS FULL   EMP
    
    
-- 위 힌트를 순서를 바꾸기 위해 /*+ LEADING(E) USE_NL(D) */ 로 변경해도 오라클은 이 힌트를 무시합니다.    

SELECT /*+ LEADING(E) USE_NL(D) */
       *
  FROM DEPT D
      , EMP E
 WHERE D.DEPTNO = E.DEPTNO(+)    
 
 
================

HASH JOIN OUTER
    TABLE ACCESS FULL   DEPT
    TABLE ACCESS FULL   EMP 
 
 
-- 위의 실행계획을 보면 NL 조인이 아닌 해시 조인으로 변경되었음을 알 수 있다.


-- Outer 소트 머지 조인

-- 소트 머지 조인은 각 테이블의 조인 대상 집합을 정렬한 후 조인한다는 점이 NL 조인과 다르지만 원리는 NL 조인과 다르지 않습니다.
-- NL 조인과 마찬가지로 조인 방향이 한쪽으로 고정됩니다.
-- NL 조인과 마찬가지로 LEADING이나 ORDERED 힌트를 사용한다고 해도 그 순서를 바꿀 수 없습니다.


SELECT /*+ LEADING(D) USE_MERGE(E) */
       *
   FROM DEPT D
      , EMP E
  WHERE D.DEPTNO = E.DEPTNO(+)
  
=============

MERGE JOIN OUTER
    SORT JOIN
        TABLE ACCESS FULL
    SORT JOIN
        TABLE ACCESS FULL
        
-- NL 조인과 마찬가지로 위 힌트를 순서를 바꾸기 위해 /*+ LEADING(E) USE_MERGE(D) */ 로 변경해도 오라클은 이 힌트를 무시합니다.


-- Outer 해시 조인

-- Outer 조인에서 해시 조인도 NL 조인과 같은 방식이었다면 이렇게 세부적으로 나누지 않고 간단히 설명하고 넘어 갔었다.
-- 해시 조인에 한해서 조인 방향을 바꿀 수 있다.
-- 데이터가 작은 테이블 데이터로 해시 맵을 만들어야 부하를 줄일 수 있는데, 이것이 가능합니다.


SELECT /*+ USE_HASH(D E) */
       *
   FROM DEPT D
      , EMP E
  WHERE D.DEPTNO = E.DEPTNO(+);
  
================

HASH JOIN OUTER
    TABLE ACCESS FULL   DEPT
    TABLE ACCESS FULL   EMP
    

-- DEPT 테이블을 해시 맵으로 만들었는데, 다음 예제는 EMP 테이블을 해시 맵으로 변경해 보겠습니다.

SELECT /*+ USE_HASH(D E) SWAP_JOIN_INPUTS(E) */
        *
   FROM DEPT D
      , EMP E
  WHERE D.DEPTNO = E.DEPTNO(+)
  
  
=================

HASH JOIN RIGHT OUTER
    TABLE ACCESS FULL    EMP
    TABLE ACCESS FULL   DEPT
    
    
-- 위의 실행 계획을 보면 기존의 HASH JOIN OUTER에 HASH JOIN RIGHT OUTER 로 변경된 것을 알 수 있습니다.
-- SWAP_JOIN_INPUTS 힌트를 사용하여 해시 맵을 어느 테이블로 만들지 결정할 수 있습니다.

