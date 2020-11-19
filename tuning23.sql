-- 피할 수 없는 소트! 소트 영역이라도 적게 사용하기

-- 소트 영역은 로우의 개수와 더불어 컬럼들의 최종 길이도 함께 결정했습니다.
-- 즉 가로길이(컬럼 수)와 세로 길이(로우 수)가 함께 결정됩니다.


-- 1.

SELECT EMPNO
     , ENAME
     , JOB
     , MGR
     , HIREDATE
     , SAL
     , COMM
     , DEPTNO
  FROM EMP,
      ( SELECT LEVEL FROM DUAL CONNECT BT LEVEL <= 100000 )
 ORDER BY ENAME

 ================

 SORT ORDER BY
    MERGE JOIN CARTESIAN
        VIEW
            CONNECT BY WITHOUT FILTERING
                FAST DUAL
        BUFFER SORT
            TABLE ACCESS FULL


-- 2.

SELECT EMPNO
     , ENAME
     , JOB
     , MGR
  FROM EMP
     , ( SELECT LEVEL FROM DUAL CONNECT BT LEVEL <= 100000 )
 ORDER BY ENAME 

=============

 SORT ORDER BY
    MERGE JOIN CARTESIAN
        VIEW
            CONNECT BY WITHOUT FILTERING
                FAST DUAL
        BUFFER SORT
            TABLE ACCESS FULL


-- 두 쿼리의 차이는 SELECT 절의 컬럼의 수입니다.
-- 컬럼수를 달리했더니 1번 쿼리문은 정렬을 디스크에서 한 번, 메모리에서 두 번 수행했습니다.
-- 그런데 2번 쿼리문에서는 메모리에서만 3번 일어났습니다.
-- 즉 컬럼들의 총 길이도 가공하기 전에 수행하고 필요한 컬럼만 정렬될 수 있도록, 필요한 만큼만 수행되도록 노력을 기울여야 합니다.

-- 첫 페이지를 빠르게 동작시키는 페이징 기법

CREATE TABLE EMP_100000 AS
SELECT *
  FROM EMP
     , ( SELECT LEVEL FROM DUAL CONNECT BY LEVEL <= 100000 )


-- 다음 SQL문을 보겠습니다.

SELECT A.*
  FROM (  SELECT ROWNUM RN
               , A.*
            FROM ( SELECT *
                     FROM EMP_100000
                    ORDER BY ENAME DESC 
                 ) A  
       ) A
 WHERE A.RN BETWEEN 1 AND 10;

========

VIEW
    COUNT
        VIEW
            SORT ORDER BY
                TABLE ACCESS FULL


-- 위 예제에서 생성한 EMP_100000 테이블에서 10건을 가져오려고 위 쿼리문을 실행하는 데 2.69초가 소요된다.
-- 정렬은 디스크에서 수행했다.


SELECT A.*
  FROM (  SELECT ROWNUM RN
               , A.*
            FROM ( SELECT *
                     FROM EMP_100000
                    ORDER BY ENAME DESC 
                 ) A  
           WHERE ROWNUM <= 10      
       ) A
 WHERE A.RN >= 1;

===============

VIEW
    COUNT STOPKEY
        VIEW
            SORT ORDER BY STOPKEY
                TABLE ACCESS FULL


-- 이번에는 0.44초가 걸리고 정렬은 메모리에서 수행하였습니다.
-- 속도 차이나는 가장 큰 이유는 소트 영역을 적게 잡아놓고 정렬을 수행했기 때문입니다.

-- 위 쿼리문에서는 정렬을 위한 인덱스도 없고, 딱히 다른 방법으로 회피하기도 힘들었지만 소트 영역을 적게 만들어서 성능을 개선하였습니다.


-- COUNT STOPKEY 원리

-- 오라클이 정렬을 위해 5개의 메모리 공간을 만들고 10개의 숫자를 정렬시킨다고 가정했습니다.
-- 1 ~ 10 까지의 숫자 중 필요한 건 1, 2, 3, 4, 5 입니다.
-- 나머지 6, 7, 8, 9, 10을 순서대로 정렬 할 필요가 없을 경우 COUNT STOPKEY 방식을 유도하면 1 ~ 5는 정렬되지만 6 ~ 10 은 어느순간 메모리에서 밀려납니다.


-- 소트 튜닝은 SQL문만으로 해결되지 않는 경우도 많습니다.
-- 모델링에서 중복 데이터가 많이 발생하도록 설계되어 DISTINCT 등으로 중복 제거를 해야 하는 경우도 있고, 적절한 인덱스가 없어서 발생하는 경우도 있습니다.
-- 소트 영역을 적게 사용하도록 SQL문을 수정하여 해결할 수도 있습니다.