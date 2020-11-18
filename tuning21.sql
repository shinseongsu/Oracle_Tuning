-- 인덱스를 이용한 소트 대체

-- 인덱스는 생성된 컬럼 기준으로 항상 정렬되어 있으므로 SQL 구문에 ORDER BY, GROUP BY 명령이 있더라도 해당 인덱스를 이용해 소트 연산을 생략할 수 있습니다.

-- sort Order by

Create index EMP_X01 ON EMP(DEPTNO);

SELECT *
  FROM EMP
 ORDER BY DEPTNO;

==========

SORT ORDER BY
    TABLE ACCESS FULL

-- 여전히 SORT ORDER BY 연산이 발생하고, 다음 통계 정보애도 한 번의 정렬이 일어났습니다.
-- 실행계획을 보니 인덱스를 이용해 테이블에 접근하지 않았습니다.

SELECT /*+ INDEX(EMP EMP_X01) */
        *
  FROM EMP 
 ORDER BY DEPTNO

===========

SORT ORDER BY
    TABLE ACCESS FULL

-- 힌트를 넣어 확인해 보았지만 별 소용이 없습니다.
-- 이런 경우 많은 분들이 오라클 버그라고 생각하기도 합니다.

-- 하지만 EMP 테이블의 DEPTNO 컬럼이 NULL이 있을 수도 있습니다.
-- 오라클에서는 생성된 인덱스에 모든 컬럼이 NULL인 경우 인덱스에 저장되지 않습니다.
-- NULL을 표시하기 위해 힌트를 주었습니다.
-- 하지만 이를 무시하고 테이블 전체를 스캔하고, SORT ORDER BY 연산을 수행합니다.

SELECT *
  FROM EMP
 WHERE DEPTNO IS NOT NULL
 ORDER BY DEPTNO;

============

TABLE ACCESS BY INDEX ROWID
    INDEX FULL SCAN

-- 위에서는 WHERE DEPTNO IS NOT NULL 구문을 삽입하여 새로 만든 EMP_X01이라는 인덱스를 이용하여 정렬을 발생시키지 않습니다.
-- 만약 시스템이 DEPTNO 컬럼에 실제로 NULL이 존재하고, NULL 데이터를 결과 집합에 포함시켜야 한다면 이 방법은 잘못된것입니다.


-- Sort Group by

-- Group by에서도 마찬가지입니다.
-- 정렬은 발생하지 않았지만 HASH GROUP BY 연산으로 GROUP BY를 수행하였습니다.

SELECT DEPTNO
     , SUM(SAL + NVL(COMM,0))
  FROM EMP
 GROUP BY DEPTNO;

===========

HASH GROUP BY
    TABLE ACCESS FULL

-- ORDER BY에서와 마찬가지로 SQL문을 약간 수정하여 다시 확인해 보겠습니다.

SELECT DEPTNO
     , SUM(SAL + NVL(COMM,0))
  FROM EMP
 WHERE DEPTNO IS NOT NULL
 GROUP BY DEPTNO;

===========

SORT GROUP BY NOSORT
    TABLE ACCESS BY INDEX ROWID
        INDEX FULL SCAN


-- 위의 실행계획을 확인해 보면, SORT GORUP BY NOSORT 라고 표시되었습니다.
-- 즉, 인덱스를 스캔히면서 같은 값을 만나는 동안 집계를 하는 방식으로 진행하기 때문에 HASH GROUP BY 연산이 아닌 SORT GROUP BY 연산을 사용한 것입니다.
-- 정렬을 대체할 인덱스를 사용하였기 떄문에 NOSORT 라고 표시합니다.

-- 또한, 이 방식으로 처리할 경우 필요한 만큼까지 인덱스를 스캔하고 중간에 멈출 수 있기 때문에 부분 범위 처리 또한 가능합니다.
-- 이러한 특징을 잘 이용하면 매우 극적으로 성능을 개선할 수 있습니다.












