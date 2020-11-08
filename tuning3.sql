SELECT COUNT(*) FROM ORD_TEMP;   -- 저장 된 것이 없으므로 0개

SELECT MAX(ORD_NO) FROM ORD_ITEM;   -- null


-- 상품, 단품과 단품 가격
SELECT I.ITEM_ID            상품ID
     , I.ITEM_NM            상품명
     , I.ITEM_TYPE_CD       상품구분코드
     , ( SELECT UNI_CD_NM
           FROM COM_CD
          WHERE UNI_CD = I.ITEM_TYPE_CD 
       )                    상품구분명
  FROM ITEM I
 WHERE I.ITEM_TYPE_CD = '100101';




SELECT I.ITEM_ID            상품ID
     , I.ITEM_NM            상품명
     , UI.UITEM_NM          단품명
     , I.ITEM_TYPE_CD       상품구분코드
     , ( SELECT UNI_CD_NM 
           FROM COM_CD 
          WHERE UNI_CD = I.ITEM_TYPE_CD 
        )                   상품구분명
  FROM ITEM I
     , UITEM UI
 WHERE I.ITEM_TYPE_CD = '100101'
   AND I.ITEM_ID = UI.ITEM_ID;
   
   

SELECT I.ITEM_ID
     , I.ITEM_NM
     , SUM(UP.SALE_PRICE)
  FROM ITEM I
     , UITEM_PRICE UP
 WHERE I.ITEM_TYPE_CD = '100101'
   AND I.ITEM_ID = UP.ITEM_ID
 GROUP BY I.ITEM_ID
        , I.ITEM_NM
 ORDER BY 1;
