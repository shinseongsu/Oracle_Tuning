-- 인덱스 스캔 동작 원리

-- 인덱스가 생각대로 동작하지 않는다고 하는 경우가 있습니다.
-- 간단하게 내가 만든 훅은 만들어진 인덱스르 잘 사용하는지 체크하기 쉬운 방법이 있다.

WHERE SUBSTR(ITEM_NM,1, 2) = '한우';

-- 인덱스를 컬럼으로 만들어 사용하기 위해 앞처럼 컬럼을 가공하면, 해당 인덱스가 사라지므로 인덱스를 이용할 수 없게 됩니다.

WHERE ITEM_NM LIKE '한우%';


-- 묵시적 형변환

-- SQL문에서 컬럼을 가공하지 않았는데 내부적으로 형변환이 되는 경우가 있습니다.
-- 이런 경우를 만나게 되면 SQL문만으로 형변환이 되었다는 걸 인지하기가 매우 힘듭니다.

WHERE ORD_DT = TO_DATE('20120101');

-- ORD_DT 컬럼으로 인덱스가 만들어져 있는데 인덱스 스캔을 하지 않고 테이블 전체 스캔을 하는 겁니다.
-- 쿼리문의 수행 속도도 매우 느리고요.
-- 알고보니 ORD_DT 컬럼이 VARCHAR(8)로 설정된 것이 원인이었습니다.

WHERE ITEM_ID = '123';

-- 여기서도 ITEM_ID 컬럼이 NUMBER 형으로 만들어진것입니다.

-- 위 두가지 인덱스 정상적으로 이용할수 없는 이유는 다음과 같이 내ㅐ부적으로 SQL문을 변경하였기 때문입니다.


WHERE TO_DATE(ORD_DT) = TO_DATE('20120101')
WHERE TO_CHAR(ITEM_ID) = '123'


==> 좋은 예

WHERE ITEM_ID = TO_NUMBER('123');
