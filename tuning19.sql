-- 소트 튜닝

-- 소트 연산은 CPU의 부하를 높이고, 경우에 따라서는 사용자가 SELECT만 수행했는데 디스크 쓰기까지 발생시킬 수도 있습니다.
-- 온라인 트랜잭션이 많이 일어나는 곳에서 소트 연산이 많다면 CPU 부하를 가중시키고, 경우에 따라서는 디스크 쓰기까지 발생해 시스템 전체적으로 영향을 미칩니다.

-- 소트 연산의 종류

-- Order by(Sort Order by)
-- 소트하면 떠오르는 것이 ORDER BY 연산입니다.
-- 실행 계획에서는 SORT ORDER BY 연산으로 수행합니다.

SELECT *
FROM EMP
ORDER BY DEPTNO;

===========

SORT ORDER BY
    TABLE ACCESS FULL


 -- GROUP BY(SORT GROUP BY, HASH GROUP BY)
 -- Group by 명령과 Order by 명령을 SQL문을 동시에 사용할 때 SORT GROUP BY로 수행합니다.

 SELECT DEPTNO
       , SUM(SAL + NVL(COMM, 0))
   FROM EMP
  GROUP BY DEPTNO
  ORDER BY DEPTNO;

 =============

 SORT GROUP BY
    TABLE ACCESS FULL


-- GROUP BY 예제를 하나 더 보겠습니다.

SELECT DEPTNO
     , SUM(SAL + NVL(COMM, 0))
  FROM EMP
 GROUP BY DEPTNO

====================

HASH GROUP BY
    TABLE ACCESS FULL

 -- 오라클 10g 버전부터 GROUP BY만을 수행할 때는 대부분 HASH GROUP BY 연산으로 수행합니다.
 -- 정렬을 연산하지 않고 GROUP BY 만 수행을 한다.

 -- GROUP BY 명령은 특정 컬럼을 묶어서 같은 값끼리 집계 연산을 하기 위해 사용합니다.
 -- 소트 머지 조인에서 살펴보았듯이 집계 연산을 수행하는 데에 정렬이 필요한 것은 아닙니다.
 -- 오라클은 해시 조인에서처럼 같은 값끼리 같은 해시 값을 받아 해시 맵을 구성해 처리하는 방식이다.
 -- 같은 값끼리 정렬을 해서 처리하는 방식보다 빠르다고 판단한다.

 -- 또한 GROUP BY의 결괏값으로 정렬된 데이터가 필요하다면 SQL문에 반드시 ORDER BY 절을 포함해야 한다.
 -- SORT GORUP BY 연산으로 GROUP BY 를 했다고 하더라도 정렬된 결괏값을 얻을 수 없습니다.
 -- ORDER BY를 생략하고 실행계획에서 SORT GROUP BY 연산을 수행한다고 해서 정렬이 되는 것은 아닙니다.
 -- 오라클은 ORDER BY 외에는 정렬을 보장하지 않습니다.


-- Distinct, IN, UNION, MINUS, INTERSECT 등의 집합 연산자

-- Sort Unique 연산과 Hash Unique 연산을 발생시키는 키워드는 여러 가지가 있습니다.

SELECT *
  FROM DEPT
 WHERE DEPTNO IN ( SELECT DEPTNO FROM EMP )

================

MERGE JOIN SEMI
    TABLE ACCESS BY INDEX ROWID
        INDEX FULL SCAN
    SORT UNIQUE
        TABLE ACCESS FULL

-- IN절에서 소트 연산이 수행 될 수 있다는 것을 알고 깜짝 놀라는 경우를 자주 접합니다.
-- SQL문을 작성하다 보면 IN 절이 작성하기 편하다고 생각할 것입니다.
-- 그렇지만 대부분의 개발자들은 그것이 비효율을 유발할 수 있다고는 생각하지 않을 것입니다.

SELECT * FROM EMP WHERE MGR = 7839
UNION
SELECT * FROM EMP WHERE MGR = 7566;

================

SORT UNIQUE
    UNION-ALL
        TABLE ACCESS FULL
        TABLE ACCESS FULL

-- 집합 연산자인 UNION, MINUS, INTERSECT를 사용할 때 SORT UNIQUE 연산이 나타납니다.
-- 위 SQL문에서는 UNION 명령을 사용하여 중복 제거된 합집합을 만들기 위해 SORT UNIQUE 연산을 사용합니다.

SELECT * FROM EMP WHERE COMM > 0
INTERSECT
SELECT * FROM EMP WHERE SAL > 500


=============

INTERSECTION
    SORT UNIQUE
        TABLE ACCESS FULL
    SORT UNIQUE
        TABLE ACCESS FULL

-- 또 다른 집합 연산자인 INSTERSECT도 중복을 제거한 후 교잡헙울 결과 집합으로 만듭니다.
-- 중복 제거를 위해 SORT UNIQUE 연산을 사용하였습니다.


SELECT DISTINCT JOB FROM EMP

============

HASH UNIQUE
    TABLE ACCESS FULL


-- DISTINCT 연산은 SQL문에 따라 SORT UNIQUE와 HASH UNIQUE 연산을 사용합니다.
-- HASH UNIQUE 를 사용하여 정렬은 발생하지 않습니다.


SELECT DISTINCT JOB FROM EMP ORDER BY JOB


=============


SORT UNIQUE
    TABLE ACCESS FULL


-- JOB 컬럼 기준으로 정렬하여 결과를 보여주는 구문으로 일부 수정하였습니다.
-- SORT UNIQUE 연산을 사용하였습니다.
-- 정렬 연산을 사용하였기에 메모리에서 한 번 정렬되었다고 표시합니다.    















