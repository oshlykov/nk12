# выбор всех протоколов ЦИК с фальсификациями

SELECT p7.y, p.id, p.source, p.v1, p.v2, p.v3, p.v4, p.v5, p.v6, p.v7, p.v8, p.v9, p.v10, p.v11, p.v12, p.v13, p.v14, p.v15, p.v16, p.v17, p.v18, p.v19, p.v20, p.v21, p.v22, p.v23, p.v24, p.v25, p.v26
FROM (
# выбор всех протоколов КАРИК с фальсификациями
SELECT p1.id x, p1.commission_id, cs.id y
FROM protocols p1
INNER JOIN commissions cs ON p1.commission_id = cs.id
WHERE cs.conflict = 1
AND p1.priority = 1
) p7
INNER JOIN protocols p ON p.id = p7.x

# выбор всех протоколов КАРИК с фальсификациями
SELECT c.id, p.id, p.source, p.v1, p.v2, p.v3, p.v4, p.v5, p.v6, p.v7, p.v8, p.v9, p.v10, p.v11, p.v12, p.v13, p.v14, p.v15, p.v16, p.v17, p.v18, p.v19, p.v20, p.v21, p.v22, p.v23, p.v24, p.v25, p.v26
FROM `commissions` c
INNER JOIN protocols p ON c.id = p.commission_id
WHERE `conflict` =1
AND priority =1
LIMIT 0 , 30


#Выбор дубликатов
SELECT c.* FROM 
(
   SELECT url, COUNT(*)
   FROM commissions
   GROUP BY url HAVING COUNT(*) > 1
) s,
commissions c
WHERE c.url = s.url