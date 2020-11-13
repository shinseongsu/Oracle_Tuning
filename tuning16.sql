-- 조인 방식에 따라 달라지는 인덱스 설계

-- 경우에 따라 인덱스를 만들지 않는 것이 포인트가 될 수도 있겠지만, 여기에서는 인덱스를 설계한다는 가정하에 설명을 진행하겠습니다.

SELECT A.*
     , B.*
  FROM ITEM A
     , UIEM B
 WHERE A.ITEM_ID = B.ITEM_ID
   AND A.ITEM_TYPE_CD = '100101'
   AND A.SALE_YN = 'Y'
   AND B.SALE_YN = 'Y';
   
   
-- 단, 클러스터링 팩터에 대해서는 고려하지 않겠습니다.   
   
-- NL 조인   

-- ITEM은 드라이빙 테이블이므로 조인 커럼을 인덱스에 추가해야 할 상황이라면 뒤에 배치해야 합니다.
-- 선두에는 ITEM_TYPE_CD + SALE_YN이나 SALE_YN + ITEM_TYPE_CD 로 구성해도 속도는 같습니다.

-- 만약에, 조인 컬럼을 인덱스에 추가했을 때 테이블로의 방문이 사라진다면 성능 향상 효과가 있습니다.
-- 그렇지만 조인 컬럼을 추가해도 테이블로 방문한다면 드라이빙 테이블에 조인 컬럼을 추가하지 않는 것이 좋습니다.

-- UITEM 테이블은 NL 조인에서 Inner 테이블입니다.
-- NL 조인의 핵심은 Inner 테이블에 조인 컬럼이 반드시 인덱스로 있어야 한다는 것입니다.
-- ITEM_ID + SALE_YN 이나 SALE_YN + ITEM_ID 입니다. 대개 ITEM_ID + SALE_YN순으로 인덱스를 만든다고 생각합니다.
-- Inner 테이블이 조건이 모두 등치 조건일 경우에는 순서는 어떻게 해도 같습니다.

create index ITEM_X01 on ITEM(ITEM_TYPE_CD, SALE_YN);
create index UITEM_X01 on UITEM(ITEM_ID, SALE_YN);


-- 소트 머지 조인

-- 소트 머지 조인은 각 테이블에서 조인 컬럼으로 정렬이 발생합니다.
-- 먼저 ITEM 테이블은 ITEM_TYPE_CD + SALE_YN 또는 SALE_YN + ITEM_TYPE_CD 순서로 구성합니다.
-- 소트 머지 조인에서는 정렬이 발생하지 않을 위치에 조인 컬럼을 반드시 추가해야 합니다.
-- 따라서 ITEM_TYPE_CD + SALE_YN + ITEM_ID 또는 SALE_YN + ITEM_TYPE_CD + ITEM_ID 로 구성할 수 있습니다.
-- 만약 위에 설계한 인덱스에서 ITEM_ID 컬럼을 인덱스에서 제거한다면 정렬이 발생합니다.

-- UITEM 테이블도 마찬가지입니다.
-- 소트 머지 조인에서는 두 테이블이 모두 정렬을 위한 인덱스가 있어도 Inner 테이블은 조인 대상 전체를 읽어 PGA에 적재합니다.
-- 이 경우 실행계획 상에서 정렬 연산이 발생하지만 실제로 정렬을 위한 부하까지 발생하는 것은 아닙니다.
-- 따라서 Inner 테이블에도 조인 커럼을 인덱스에 추가해 정렬을 하지 않도록 만드는 것이 좋습니다.

-- UITEM 테이블의 인덱스는 SALE_YN + ITEM_ID 로 만들 수 있습니다.
-- 그렇다면 NL조인에서처럼 ITEM_ID + SALE_YN으로 하면.. 인덱스를 이용해 대신한다면 인덱스 풀 스캔이 발생합니다. 그렇지 않으면 테이블 풀 스캔이 발생합니다.

create index ITEM_X01 on ITEM(ITEM_TYPE_CD, SALE_YN, ITEM_ID);
create index UITEM_X01 on UITEM(SALE_YN, ITEM_ID);



-- 해시 조인

-- 해시 조인으로 조인한다면 다른 조인에 비해 인덱스를 만드는 상황은 덜 발생합니다.
-- 인덱스를 만드는 것도 가장 쉽다고 할 수 있습니다.
-- ITEM 테이블에서는 ITEM_TYPE_CD + SALE_YN 또는 SALE_YN + ITEM_TYPE_CD 순서로 구성합니다.
-- UITEM 테이블은 SALE_YN 만으로 구성할 수 있습니다.

-- 해시 조인에서는 조인 커럼이 인덱스에 포함되지 않아도 성능상의 손익은 없습니다.
-- 다만 조인 컬럼이 인덱스에 포함되어 테이블로의 방문을 막을 수 있다면 고려해 볼만 합니다.

create index ITEM_X01 on ITEM(ITEM_TYPE_CD, SALE_YN);
create index UITEM_X01 ON UITEM(SALE_YN);


-- 주의사항 ; NL 조인과 소트 조인은 인덱스에 포함하지 않거나 순서가 맞지 않을 경우 성능상의 이슈가 생길 수 있다는 점 유의하기 바랍니다.

