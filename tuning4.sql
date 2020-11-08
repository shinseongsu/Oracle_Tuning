ALTER SESSION SET STATISTICS_LEVEL = ALL;

SELECT *
  FROM  TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ADVANCED ALLSTATS LAST'));
  
  
SELECT /*+ gather_plan_statistics */
       *
   FROM (
            SELECT *
              FROM EMP
             WHERE DEPTNO = 30
             ORDER BY ENAME
        )
  WHERE ROWNUM <= 3;
  