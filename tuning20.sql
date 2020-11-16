-- RANK(), DENSE_RANK(), ROW_NUMBER() 등 윈도우 함수(Window Sort)

-- 윈도우 함수의 등장으로 데이터 간의 순위, 집계, 순서 등 행과 행간의 관계를 쉽게 표현할 수 있게 되었습니다.
-- 윈도우 함수를 사용하면 WINDOW SORT 연산을 수행합니다.

SELECT EMPNO
     , ENAME
     , JOB
     , SAL
     , RANK() OVER(PARTITION BY JOB ORDER BY SAL DESC)
  FROM EMP

================

WINDOW SORT
    TABLE ACCESS FULL


-- Sort Aggregate 연산

-- 실행계획에서 SORT로 시작하는 연산들 중에서 SORT AGGREGATE 연산은 정렬을 하는 것처럼 보이지만 실제로는 정렬을 하지 않습니다.

SELECT COUNT(*)
     , SUM(SAL)
     , MAX(HIREDATE)
     , MIN(HIREDATE)
  FROM EMP

===========

SORT AGGREGATE
    TABLE ACCESS FULL

-- SORT가 표시되어 정렬된 것을 착각할 수 있어 확인해 보았습니다.



