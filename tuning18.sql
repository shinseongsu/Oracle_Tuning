-- 스칼라 서브 쿼리로의 조인

-- 스칼라 서브 쿼리는 프로그래밍 언어의 함수처럼 입력값에 대한 반환 값을 한 개만 반환하는 쿼리입니다.

SELECT E.EMPNO
     , E.ENAME
     , E.JOB
     , ( SELECT DNAME FROM DEPT WHERE DEPTNO = E.DEPTNO) DNAME
  FROM EMP E
  
================

TABLE ACCESS BY INDEX ROWID     DEPT
    INDEX UNIQUE SCAN
TABLE ACCESS FULL               EMP


-- 스칼라 서브 쿼리의 가장 큰 특징은 내부적으로 캐시에 값을 저장해 둔다는 점입니다.
-- 입력 값과 출력값이 같으면 쿼리를 수행하지 않는다는 원리로 캐시에 저장합니다.
-- 입력 값과 출력 값을 저장해 두고 스칼라 서브 쿼리가 실행될 때, 캐시에서 입력값을 찾아봅니다.
-- 만약 있으면 미리 저장된 출력값을 반환하고, 없으면 스칼라 서브 쿼리를 실행해 결괏값을 캐시에 저장합니다.

-- 하지만 캐시도 한정된 자원입니다.
-- SQL 문의 결괏값이 많다면 스칼라 서브 쿼리의 호출도 많아집니다.
-- 스칼라 서브 쿼리로의 입력 값이 다양하게 들어오면 캐시에 저장해야 할 값이 많아짐과 동시에 재사용될 가능성도 낮아집니다.
-- 재사용 가능성이 낮은 상황에서 캐시를 확인하는 불필요한 과정이 발생합니다.

-- 이러한 상황을 피하려면 가급적이면 자주 반복되고 값의 종류가 다양하지 않은 테이블과 조인이 필요할 때 사용하면 효과가 좋습니다.
-- 스칼라 서브 쿼리는 매우 편리한 반면 반환 값을 하나밖에 사용하지 못한다는 단점이 있습니다.

SELECT E.EMPNO
     , E.ENAME
     , E.JOB
     , ( SELECT DNAME FROM DEPT WHERE DEPTNO = E.DEPTNO ) DNAME
     , ( SELECT LOC FROM SWPR WHERE DEPTNO = E.DEPTNO ) LOC
  FROM EMP E
  
===================

TABLE ACCESS BY INDEX ROWID     DEPT
    INDEX UNIQUE SCAN
TABLE ACCESS BY INDEX ROW ID    DEPT
    INDEX UNIQUE SCAN
TABLE ACCESS FULL               EMP


-- 프로젝트를 하다 보면 위 SQL문처럼 같은 테이블에 같은 조건으로 스칼라 서브 쿼리를 두 개 이상 사용하는 것을 간혹 접하게 됩니다.
-- 이렇게 사용하면 같은 테이블을 두 번 액세스하는 비효율이 발생합니다.


-- 극복하는 첫 번째 방법은


SELECT EMPNO
    , ENAME
    , JOB
    , EXGEXP_SUBSTR(SUB, '[^$]+', 1, 1) DNAME
    , EXGEXP_SUBSTR(SUB, '[^$]+', 1, 2) LOC
 FROM (
        SELECT E.EMPNO
             , E.ENAME
             , E.JOB
             , ( SELECT D.NAME || '$' || LOC FROM DEPT WHERE DEPTNO = E.DEPTNO ) SUB
          FROM EMP E
     );
     
============

TABLE ACCESS BY INDEX ROWID     DEPT
    INDEX UNIQUE SCAN
TABLE ACCESS FULL               EMP

-- REGEXP_SUBSTR 함수는 문자열에 대해 정규식을 사용하게 되는데 쿼리 결괏값이 많으면 약간의 부하가 발생합니다.


-- 두번째 방법은


SELECT EMPNO
    , ENAME
    , JOB
    , TRIM(SUBSTR(SUB, 1, 20)) DNAME
    , TRIM(SUBSTR(SUB, 21, 20)) LOC
 FROM (
        SELECT E.EMPNO
             , E.ENAME
             , E.JOB
             , ( SELECT LPAD(DNAME, 20) || LPAD(LOC, 20) FROM DEPT WHERE DEPTNO = E.DEPTNO ) SUB
          FROM EMP E
     );
    
==============

TABLE ACCESS BY INDEX ROWID     DEPT
    INDEX UNIQUE SCAN
TALBE ACCESS FULL               EMP


-- LPAD를 사용하여 SUBSTR 함수로 깅이를 예측해 컬럼을 다시 날수 있기 때문에 더 작은 부로 사용이 가능합니다.



