-- 불필요한 소트 제거

-- UNION, MINUS, INTERSECT 등 집합 연산자

-- 집합 연산자에서도 소트 연산이 동작합니다.
-- 집합 연산자에서는 어떻게 소트를 피할 수 있는지 그 방법을 하나하나 살펴보겠습니다.

SELECT * FROM EMP WHERE MGR = 7839
UNION
SELECT * FROM EMP WHERE MGR = 7566;

============

SORT UNIQUE
    UNION-ALL
        TABLE ACCESS FULL
        TABLE ACCESS FULL


-- 실행계획을 확인해 보면, SORT UNIQUE에서 UNION ALL로 변경되었고 정렬도 일어나지 않았습니다.


-- IN절 안의 서브쿼리

-- IN절 안에 서브 쿼리를 작성하게 되면 SORT UNIQUE 연산이 나오는 것을 확인하였습니다.
-- 보통 IN절에서 부하가 발생하면 EXISTS절로 바꿔서 사용하라고 말하는 경우가 종종 있습니다.

SELECT *
  FROM DEPT
 WHERE DEPTNO IN ( SELECT DEPTNO FROM EMP )

=============

MERGE JOIN SEMI
    TABLE ACCESS BY INDEX ROWID    (DEPT)
        INDEX FULL SCAN
    SORT UNIQUE
        TABLE ACCESS FULL          (EMP)

-- IN 절에서 EMP 테이블의 DEPTNO 컬럼 중복을 제거하고자 SORT UNIQUE 연산이 나타나고 소트 머지 조인으로 조인을 시도합니다.
-- 이를 EXISTS로 변경하고 확인해보겠습니다.


SELECT *
  FROM DEPT D
 WHERE EXISTS ( SELECT 'X' FROM EMP WHERE DEPTNO = D.DEPTNO ) 

 =============

 MERGE JOIN SEMI
    TABLE ACCESS BY INDEX ROWID
        INDEX FULL SCAN
    SORT UNIQUE
        TABLE ACCESS FULL


-- 위 경우와 완벽하게 동일합니다.
-- 즉, IN절을 단순히 EXISTS로 변경하였다고 하여 성능에 영향을 미치지 않는 것은 아닙니다.
-- 혹시 소트 머지 조인을 시도하기 때문에 발생하는 것은 아닌지 확인하기 위해 확인하기 위해 힌트를 넣어 NL조인으로 시도해보겠습니다.

SELECT /*+ LEADING(D) */
       *
  FROM DEPT D
 WHERE EXISTS ( SELECT /*+ UNNEST NL_SJ */ 'X' FROM EMP WHERE DEPTNO = D.DEPTNO );

 ==============

 NESTED LOOPS SEMI
    TABLE ACCESS FULL
    TABLE ACCESS FULL


-- NL 조인으로 변경하니 정렬 연산은 사라졌습니다.
-- 그런데 테이블을 반복적으로 읽으면서 엑세스가 많아졌습니다.
-- 이 경우에는 정렬하는 게 좋은지, 아니면 엑세스가 증가하는 게 좋은지를 판단해야 합니다.

-- 일반적으로 IN절을 EXISTS로 변경할 경우 가장 좋은 방법은 해당 컬럼은 기존 인덱스를 사용하거나 해당 컬럼으로 인덱스를 추가하는 것입니다.


SELECT /*+ LEADING(D) */
        *
  FROM DEPT D
 WHERE EXISTS ( SELECT /*+ UNNEST NL_SJ */ 'X' FROM EMP WHERE DEPTNO = D.DEPTNO );


===================

NESTED LOOPS SEMI
    TABLE ACCESS FULL   (DEPT)
    INDEX RANGE SCAN    (EMP_X01)

-- 이렇게 변경하였더니 정렬 연산도 없고, 엑세스 양도 줄었습니다.
-- 즉, IN절을 EXISTS로 변경한다고 무조건 성능이 개선되는것이 아니므로 적절한 조치가 추가적으로 필요한지를 확인해야합니다.


-- MERGE와 UNNEST에 대해 알아보겠습니다.

-- MERGE와 UNNEST를 이해하려면 서브 쿼리의 명칭부터 알아야합니다.
-- 서브 쿼리는 위치에 따라 스칼라 서브 쿼리, 인라인 뷰, 중첩된 서브 쿼리라는 이름을 갖고 있습니다.
-- MERGE와 UNNEST는 FROM 절의 메인 쿼리와 합치는 의미에서는 같습니다.
-- 다만 서브쿼리의 위치에 따라 사용하는 힌트가 다릅니다.
-- MERGE는 합친다는 의미로 FROM절에 나열된 테이블과 인라인 뷰를 합치는 시도를 합니다.
-- 따라서 인라인 뷰에서 사용합니다.         // (FROM절)
-- UNNEST는 풀어낸다는 의미로 WHERE 절에 위치한 중첩된 서브 쿼리를 풀어 FROM 절에 합치는 시도를 합니다.
-- 따라서 중첩된 서브 쿼리에서 사용합니다.    // (WHERE절)